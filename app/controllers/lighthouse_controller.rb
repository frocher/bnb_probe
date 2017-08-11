class LighthouseController < ApplicationController
  before_action :check_token

  def index
    url = sanitized_url
    filename = tmp_filename(".json")

    begin
      cmd = "lighthouse #{url} --output json --output-path #{filename}"
      Rails.logger.info cmd
      status = system(cmd)
      if status
        report = generate_report(filename)
        render json: report
      else
        render json: { status: "error"}, status: 422
      end
    rescue => e
      logger.error e.message
      e.backtrace.each { |line| logger.error line }
      render json: {status: "failed", errorMessage: e.to_s}, status: 422
    ensure
      File.delete(filename) if File.exist?(filename)
    end
  end
end
