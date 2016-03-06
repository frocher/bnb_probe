require 'tempfile'

class CheckController < ApplicationController
  def index
    url = sanitized_url

    jsonFile = Tempfile.new('twb')
    harFile = Tempfile.new('twb')
    browser = Rails.configuration.browser
    cmd = "browsertime -u #{url} -b #{browser} -n 1 --filename #{jsonFile.path} --harFile #{harFile.path}"
    stdout,stderr,status = Open3.capture3(cmd)
    if status.success?
      render json: {stats: JSON.parse(jsonFile.read), har: JSON.parse(harFile.read)}
    else
      render json: { status: "error"}, status: 422
      Rails.logger.error stdout
      Rails.logger.error stderr
    end
  end
end
