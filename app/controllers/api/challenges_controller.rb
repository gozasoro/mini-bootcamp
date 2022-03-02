# frozen_string_literal: true

class Api::ChallengesController < Api::BaseController
  before_action :authenticate_user_for_api
  before_action :authenticate_admin_for_api, only: %i(update)
  before_action :set_category_and_challenge, only: %i(run judge)

  DOCKER_DIR_PATH = Rails.root.join("tmp/docker").freeze

  def show
    @challenge = Challenge.preload(:checks).preload(:category).find(params[:id])
  end

  def update
    @challenge = Challenge.find(params[:id])
    if @challenge.update(challenge_params)
      head :created
    else
      render json: { messages: @challenge.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def run
    extension = @category.extension
    image = @category.docker_image
    command = @category.command
    check = @challenge.checks[params[:check]]
    stdin = check.stdin
    stdout = check.stdout
    @result = {}

    Dir.mktmpdir(nil, DOCKER_DIR_PATH) do |tmpdir|
      file = Tempfile.new(["", ".#{extension}"], tmpdir)
      begin
        file.write params[:code]
        file.flush
        filename = File.basename(file.path)

        container = Docker::Container.create(container_options(image: image, volume_path: tmpdir))
        container.start

        stdout, stderr, @result[:exitcode] = container.exec(["bash", "-c", "timeout 2 #{command} #{filename} || echo ContainerTimeout 1>&2"], stdin: StringIO.new(stdin))
        stderr.pop if stderr.length > 1 # Remove timeout error when an error other than timeout occurs.

        @result[:stderr] = stderr.join.force_encoding("UTF-8")
        @result[:stdout] = stdout.join.force_encoding("UTF-8")
      ensure
        container.stop if container
        file.close
        file.unlink
      end

      @result[:success] = @result[:stdout].chomp == check.stdout.gsub(/\R/, "\n").chomp
    end
  end

  def judge
    extension = @category.extension
    image = @category.docker_image
    command = @category.command
    checks = @challenge.checks
    @result = []
    @challenge_success = true

    Dir.mktmpdir(nil, DOCKER_DIR_PATH) do |tmpdir|
      file = Tempfile.new(["", ".#{extension}"], tmpdir)
      begin
        file.write params[:code]
        file.flush
        filename = File.basename(file.path)

        container = Docker::Container.create(container_options(image: image, volume_path: tmpdir))
        container.start

        checks.each_with_index do |check, index|
          this_result = {}
          stdout, stderr, this_result[:exitcode] = container.exec(["bash", "-c", "timeout 2 #{command} #{filename} || echo ContainerTimeout 1>&2"], stdin: StringIO.new(check.stdin))
          stderr.pop if stderr.length > 1 # Remove timeout error when an error other than timeout occurs.

          this_result[:stderr] = stderr.join.force_encoding("UTF-8")
          this_result[:stdout] = stdout.join.force_encoding("UTF-8")
          this_result[:success] = this_result[:stdout].chomp == check.stdout.gsub(/\R/, "\n").chomp
          @challenge_success = false unless this_result[:success]
          @result.push this_result
        end

        @challenge.archivements.create!(user_id: current_user.id) if logged_in? && @challenge_success && @challenge.archivements.where(user_id: current_user.id).empty?
      ensure
        container.stop if container
        file.close
        file.unlink
      end
    end
  end

  private
    def set_category_and_challenge
      @challenge = Challenge.preload(:checks).preload(:category).find(params[:challenge_id])
      @category = @challenge.category
    end

    def challenge_params
      params.require(:challenge).permit(:row_order_position)
    end

    def container_options(image:, volume_path:)
      {
        "Image": image,
        "WorkingDir": "/code",
        "NetworkDisabled": true,
        "Tty": true,
        "OpenStdin": true,
        "HostConfig": {
          "NetworkMode": "none",
          "PidsLimit": 20,
          "ReadonlyRootfs": true,
          "AutoRemove": true,
          "Mounts": [
            {
              "Target": "/code",
              "Source": volume_path,
              "Type": "bind",
              "ReadOnly": true,
              "Consistency": "delegated"
            }
          ]
        }
      }
    end
end
