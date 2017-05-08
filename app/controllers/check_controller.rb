class CheckController < ApplicationController
  before_action :check_token

  def index
    url = sanitized_url
    target = params[:target]

    connection = ""
    size = ""
    if target == "mobile"
      connection = "3gfast"
      size = "360x640"
    else
      connection = "cable"
      size = "1366x768"
    end

    basedir = Rails.root.join('tmp');
    filename = SecureRandom.uuid
    json_filename = File.join(basedir, filename + ".json")
    har_filename = File.join(basedir, filename + ".har")

    begin
      browser = Rails.configuration.browser
      cmd = "browsertime #{url} --output #{filename} --har #{filename} --resultDir #{basedir} -n 1 -b #{browser} --viewPort #{size} -c #{connection} --speedIndex"
      Rails.logger.info cmd
      status = system(cmd)
      if status
        stats = generate_stats(json_filename)
        har = generate_har(har_filename)
        render json: {stats: stats, har: har}
      else
        render json: { status: "error"}, status: 422
      end
    rescue => e
      logger.error e.message
      e.backtrace.each { |line| logger.error line }
      render json: {status: "failed", errorMessage: e.to_s}, status: 422
    ensure
      File.delete(json_filename) if File.exist?(json_filename)
      File.delete(har_filename) if File.exist?(har_filename)
    end
  end

  def generate_stats(filename)
    json_file = File.open(filename)
    output = JSON.parse(json_file.read)
    json_file.close

    timings = output["statistics"]["timings"]
    visual = output["statistics"]["visualMetrics"]

    stats = {
      responseStart: timings["navigationTiming"]["responseStart"]["median"].to_i,
      firstPaint: visual["FirstVisualChange"]["median"].to_i,
      speedIndex: visual["SpeedIndex"]["median"].to_i,
      domInteractive: timings["navigationTiming"]["domInteractive"]["median"].to_i,
      pageLoadTime: timings["fullyLoaded"]["median"].to_i,
    }
  end

  def generate_har(filename)
    har_file = File.open(filename)
    har = JSON.parse(har_file.read)
    har_file.close
    har
  end
end
