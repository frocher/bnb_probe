require 'tempfile'

class CheckController < ApplicationController
  before_action :check_token

  def index
    url = sanitized_url
    target = params[:target]

    connection = ""
    size = ""
    if target == "mobile"
      connection = "mobilefast3g"
      size = "357x627"
    else
      connection = "cable"
      size = "1280x1024"
    end

    jsonFile = Tempfile.new('bnb')
    harFile = Tempfile.new('bnb')
    begin
      browser = Rails.configuration.browser
      cmd = "browsertime -u #{url} -b #{browser} -w #{size} --connection #{connection} -n 1 --filename #{jsonFile.path} --harFile #{harFile.path}"
      Rails.logger.info cmd
      status = system(cmd)
      if status
        render json: {stats: JSON.parse(jsonFile.read), har: JSON.parse(harFile.read)}
      else
        render json: { status: "error"}, status: 422
      end
    rescue => e
      render json: {status: "failed", errorMessage: e.to_s}, status: 422
    ensure
      jsonFile.close!
      harFile.close!
    end
  end
end
