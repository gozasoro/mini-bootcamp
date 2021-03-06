# frozen_string_literal: true

class User < ApplicationRecord
  has_many :archivements, dependent: :destroy

  def self.find_or_create_from_auth_hash!(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]
    nickname = auth_hash[:info][:nickname]
    image_url = auth_hash[:info][:image]

    User.find_or_create_by!(provider: provider, uid: uid) do |user|
      user.name = nickname
      user.image_url = image_url
      user.admin = Rails.application.credentials.admin.present? && Rails.application.credentials.admin.split(",").include?(user.name)
    end
  end
end
