# frozen_string_literal: true

class Challenge < ApplicationRecord
  belongs_to :category
  has_many :checks, dependent: :destroy, inverse_of: :challenge
  has_many :archivements, dependent: :destroy
  accepts_nested_attributes_for :checks, reject_if: :all_blank, allow_destroy: true

  include RankedModel
  ranks :row_order, with_same: :category_id

  validates :title, presence: true, uniqueness: { scope: :category_id }
  validates :content, presence: true
  validates :model_answer, presence: true

  validates :checks, presence: true, length: { in: 1..10, too_long: "は最大10個までです", too_short: "は1個以上必要です" }

  DOCKER_DIR_PATH = Rails.root.join("tmp/docker").freeze

  def previous
    Challenge.rank(:row_order).all.where("row_order < ? AND category_id = ?", row_order, category_id).reverse.first
  end

  def next
    Challenge.rank(:row_order).all.where("row_order > ? AND category_id = ?", row_order, category_id).first
  end

  def has_archivement?(user)
    user ? self.archivements.where(user_id: user.id).exists? : nil
  end

  def run(code, check_index)
    result = {}
    check = checks[check_index]
    Dir.mktmpdir(nil, DOCKER_DIR_PATH) do |tmpdir|
      file = Tempfile.new(["", ".#{category.extension}"], tmpdir)
      begin
        file.write code
        file.flush
        filename = File.basename(file.path)

        container = Docker::Container.create(container_options(image: category.docker_image, volume_path: tmpdir))
        container.start

        stdout, stderr, result[:exitcode] = container.exec(["bash", "-c", "timeout 2 #{category.command} #{filename} || echo ContainerTimeout 1>&2"], stdin: StringIO.new(check.stdin))
        stderr.pop if stderr.length > 1 # Remove timeout error when an error other than timeout occurs.

        result[:stderr] = stderr.join.force_encoding("UTF-8")
        result[:stdout] = stdout.join.force_encoding("UTF-8")
      ensure
        container.stop if container
        file.close
        file.unlink
      end

      result[:success] = result[:stdout].chomp == check.stdout.gsub(/\R/, "\n").chomp
    end
    result
  end

  def judge(code)
    result = []
    challenge_success = true
    Dir.mktmpdir(nil, DOCKER_DIR_PATH) do |tmpdir|
      file = Tempfile.new(["", ".#{category.extension}"], tmpdir)
      begin
        file.write code
        file.flush
        filename = File.basename(file.path)

        container = Docker::Container.create(container_options(image: category.docker_image, volume_path: tmpdir))
        container.start

        checks.each_with_index do |check, index|
          this_result = {}
          stdout, stderr, this_result[:exitcode] = container.exec(["bash", "-c", "timeout 2 #{category.command} #{filename} || echo ContainerTimeout 1>&2"], stdin: StringIO.new(check.stdin))
          stderr.pop if stderr.length > 1 # Remove timeout error when an error other than timeout occurs.

          this_result[:stderr] = stderr.join.force_encoding("UTF-8")
          this_result[:stdout] = stdout.join.force_encoding("UTF-8")
          this_result[:success] = this_result[:stdout].chomp == check.stdout.gsub(/\R/, "\n").chomp
          challenge_success = false unless this_result[:success]
          result.push this_result
        end
      ensure
        container.stop if container
        file.close
        file.unlink
      end
    end
    [result, challenge_success]
  end

  private
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
