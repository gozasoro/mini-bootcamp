# frozen_string_literal: true

namespace :admin do
  desc "ユーザーを管理者に追加する"
  task :add, ["username"] => :environment do |_, args|
    user = User.find_by(name: args[:username])
    user && user.update!(admin: true)
  end

  desc "ユーザーを管理者から削除する"
  task :remove, ["username"] => :environment do |_, args|
    user = User.find_by(name: args[:username])
    user && user.update!(admin: false)
  end
end
