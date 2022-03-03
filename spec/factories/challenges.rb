# frozen_string_literal: true

FactoryBot.define do
  factory :challenge do
    sequence(:title) { |i| "タイトル#{i}" }
    sequence(:content) { |i| "問題文#{i}" }
    sequence(:model_answer) { |i| "模範解答#{i}" }

    after(:build) do |challenge|
      challenge.checks << FactoryBot.build(:check)
    end
  end

  factory :check do
    sequence(:stdin) { |i| "stdin#{i}" }
    sequence(:stdout) { |i| "stdout#{i}" }
  end
end
