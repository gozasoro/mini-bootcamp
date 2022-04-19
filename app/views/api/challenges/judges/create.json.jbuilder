# frozen_string_literal: true

json.challenge_success @challenge_success
json.result @result, :stdout, :stderr, :exitcode, :success

json.model_answer @challenge.model_answer if @challenge_success
