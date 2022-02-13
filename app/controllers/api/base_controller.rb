# frozen_string_literal: true

class Api::BaseController < ApplicationController
  before_action :check_xhr

  private
    def check_xhr
      render status: :unprocessable_entity unless request.xhr?
    end
end
