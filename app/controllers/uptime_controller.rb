
class UptimeController < ApplicationController
  before_action :check_token

  def index
    url = sanitized_url

    easy = Curl::Easy.new
    easy.follow_location = true
    easy.max_redirects = 3
    easy.useragent = "curb"
    easy.url = url
    easy.perform

    error_message = nil

    # Check header code
    if easy.status.to_i >= 400
      error_message = "Status code failed : #{easy.status}"
    end

    # Check presence or absence of keyword
    if error_message.nil? and params.has_key?(:keyword)
      check_type = params[:type] || "presence"
      if !check_keyword(easy.body_str, params[:keyword], check_type)
        error_message = "Check of #{check_type} of #{params[:keyword]} failed."
      end
    end

    if error_message.nil?
      render json: {status: "success"}, status: 200
    else
      easy.body_str.force_encoding('UTF-8')
      render json: {status: "failed", errorMessage: error_message, content: easy.body_str}, status: 200
    end

  rescue => e
    render json: {status: "failed", errorMessage: e.to_s}, status: 422
  end

private

  def check_keyword(text, keyword, check_type)
    check_type == "presence" ? text.include?(keyword) : !text.include?(keyword)
  end

end
