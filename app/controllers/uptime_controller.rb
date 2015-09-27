require "uri"
class UptimeController < ApplicationController
  def index
    url = params[:url]
    url = URI.escape(url)
    # TODO : sanitize url
    url = ActionController::Base.helpers.sanitize(url)
    cmd = "curl -L #{url}"
    stdout,stderr,status = Open3.capture3(cmd)
    if status.success?
      if stdout.include?("Could not resolve")
        render json: { status: "failed"}, status: 200
      else
        render json: { status: "success"}, status: 200
      end
    else
      render json: { status: "error"}, status: 422
      Rails.logger.error stdout
      Rails.logger.error stderr
    end

  end
end
