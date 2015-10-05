require 'tempfile'

class UptimeController < ApplicationController

  rescue_from Curl::Easy::Error do |exception|
    render json: {status: "failed", errorMessage: exception.msg}, status: 422
  end

  def index
    url = sanitized_url
    headerFile = Tempfile.new('twb')

    easy = Curl::Easy.new
    easy.follow_location = true
    easy.max_redirects = 3 
    easy.useragent = "curb"
    easy.url = url
    res = easy.perform

    error_message = nil

    # Check header code
    if res.status.to_i >= 400
      error_message = "Status code failed : #{res.status}"
    end

    # Check presence or absence of keyword
    if error_message.nil? and params.has_key?(:keyword)
      check_type = params[:type] || "presence"
      if !check_keyword(res.body_str, params[:keyword], check_type)
        error_message = "Check of #{check_type} of #{params[:keyword]} failed."
      end
    end

    if error_message.nil?
      render json: {status: "success"}, status: 200
    else
      render json: {status: "failed", errorMessage: error_message, content: JSON.generate(res.body_str, quirks_mode: true)}, status: 200
    end
  end

private

  def check_keyword(text, keyword, check_type)
    check_type == "presence" ? text.include?(keyword) : !text.include?(keyword)
  end

end
