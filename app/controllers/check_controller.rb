class CheckController < ApplicationController
  def index
    url = params[:url]
    file = File.join(Rails.root, 'app', 'phantom', 'check.js')
    cmd = 'phantomjs --ssl-protocol=any ' + file + ' ' + url
    stdout,stderr,status = Open3.capture3(cmd)
    if status.success?
      Rails.logger.info "*********** success for " + url
      Rails.logger.info stdout
      render json: stdout
    else
      render json: { error: "error"}, status: 422
      Rails.logger.error stdout
      Rails.logger.error stderr
    end
  end
end
