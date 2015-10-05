require "uri"

class ApplicationController < ActionController::API
  rescue_from Exception do |exception|
    trace = exception.backtrace

    message = "\n#{exception.class} (#{exception.message}):\n"
    message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
    message << "  " << trace.join("\n  ")

    logger.fatal message
    render json: { message: '500 Internal Server Error'}, status: 500
  end

protected

  def sanitized_url
    url = params[:url]
    url = URI.escape(url)
    url = ActionController::Base.helpers.sanitize(url)
  end


end
