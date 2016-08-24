
class UptimeController < ApplicationController
  before_action :check_token

  def index
    success = true
    error_message = nil
    code = 200
    body = ""

    easy = launch_curl(sanitized_url, 45)

    # Check header code
    if easy.status.to_i >= 400
      if check_alternative
        success = false
        error_message = "Status code failed : #{easy.status}"
      end
    elsif params.has_key?(:keyword)
      check_type = params[:type] || "presence"
      if !check_keyword(easy.body_str, params[:keyword], check_type)
        success = false
        error_message = "Check of #{check_type} of #{params[:keyword]} failed."
      end
    end

    easy.body_str.force_encoding('UTF-8')
    body = easy.body_str

  rescue => e
    if check_alternative
      success = false
      error_message = e.to_s
      code = 422
    end

  ensure
    if success
      render json: {status: "success"}, status: code
    else
      render json: {status: "failed", errorMessage: error_message, content: body}, status: code
    end
  end

  def check_alternative
    easy = launch_curl("https://www.google.com", 15)
    easy.status.to_i < 400
  rescue
    false
  end

  def launch_curl(url, timeout)
    easy = Curl::Easy.new
    easy.follow_location = true
    easy.max_redirects = 3
    easy.useragent = "curb"
    easy.url = url
    easy.timeout = timeout
    easy.perform

    easy
  end

  def check_keyword(text, keyword, check_type)
    check_type == "presence" ? text.include?(keyword) : !text.include?(keyword)
  end
end
