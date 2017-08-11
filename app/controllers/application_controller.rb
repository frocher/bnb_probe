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

  def tmp_filename(extension)
    basedir = Rails.root.join('tmp');
    filename = SecureRandom.uuid
    File.join(basedir, filename + extension)
  end

  def generate_report(filename)
    json_file = File.open(filename)
    output = JSON.parse(json_file.read)
    json_file.close
    output
  end
  
  def sanitized_url
    url = params[:url]
    url = URI.escape(url)
    url = ActionController::Base.helpers.sanitize(url)
  end

  def check_token
    probe_token = Rails.configuration.probe_token
    unless probe_token.nil?
      token = params[:token]
      if token.nil? or token != probe_token
        logger.error "Invalid token: #{token}"
        forbidden!
      end

    end
  end

  def forbidden!
    render_api_error!('403 Forbidden', 403)
  end

  def render_api_error!(message, status)
    render json: { message: message}, status: status
  end

end
