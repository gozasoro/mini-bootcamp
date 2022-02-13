# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |i| "category#{i}" }

    trait :ruby do
      editor_mode { "ace/mode/ruby" }
      docker_image { "ruby:3.0.2" }
      command { "ruby" }
      extension { "rb" }
    end

    trait :node do
      editor_mode { "ace/mode/javascript" }
      docker_image { "node:16.13" }
      command { "node" }
      extension { "js" }
    end

    trait :golang do
      editor_mode { "ace/mode/golang" }
      docker_image { "golang:1.17" }
      command { "go run" }
      extension { "go" }
    end
  end
end
