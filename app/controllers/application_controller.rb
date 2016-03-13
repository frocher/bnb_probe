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

  def check_token
    probe_token = Rails.configuration.probe_token
    unless probe_token.nil?
      token = params[:token]
      forbidden! if token.nil? or token != probe_token
    end
  end

  def forbidden!
    render_api_error!('403 Forbidden', 403)
  end

  def render_api_error!(message, status)
    render json: { message: message}, status: status
  end

end
