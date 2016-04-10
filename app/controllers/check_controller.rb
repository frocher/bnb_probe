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
      stdout,stderr,status = Open3.capture3_with_timeout(cmd, :timeout => 90, :kill_after => true)
      #stdout,stderr,status = Open3.capture3_with_timeout(cmd)
      if status.success?
        render json: {stats: JSON.parse(jsonFile.read), har: JSON.parse(harFile.read)}
      else
        render json: { status: "error"}, status: 422
        Rails.logger.error stdout
        Rails.logger.error stderr
      end
    rescue => e
      render json: {status: "failed", errorMessage: e.to_s}, status: 422
    ensure
      jsonFile.close!
      harFile.close!
    end
  end

  # https://gist.github.com/pasela/9392115
  def capture3_with_timeout(*cmd)
    spawn_opts = Hash === cmd.last ? cmd.pop.dup : {}
    opts = {
      :stdin_data => spawn_opts.delete(:stdin_data) || "",
      :binmode    => spawn_opts.delete(:binmode) || false,
      :timeout    => spawn_opts.delete(:timeout),
      :signal     => spawn_opts.delete(:signal) || :TERM,
      :kill_after => spawn_opts.delete(:kill_after),
    }

    in_r,  in_w  = IO.pipe
    out_r, out_w = IO.pipe
    err_r, err_w = IO.pipe
    in_w.sync = true

    if opts[:binmode]
      in_w.binmode
      out_r.binmode
      err_r.binmode
    end

    spawn_opts[:in]  = in_r
    spawn_opts[:out] = out_w
    spawn_opts[:err] = err_w

    result = {
      :pid     => nil,
      :status  => nil,
      :stdout  => nil,
      :stderr  => nil,
      :timeout => false,
    }

    out_reader = nil
    err_reader = nil
    wait_thr = nil

    begin
      Timeout.timeout(opts[:timeout]) do
        result[:pid] = spawn(*cmd, spawn_opts)
        wait_thr = Process.detach(result[:pid])
        in_r.close
        out_w.close
        err_w.close

        out_reader = Thread.new { out_r.read }
        err_reader = Thread.new { err_r.read }

        in_w.write opts[:stdin_data]
        in_w.close

        result[:status] = wait_thr.value
      end
    rescue Timeout::Error
      result[:timeout] = true
      pid = spawn_opts[:pgroup] ? -result[:pid] : result[:pid]
      Process.kill(opts[:signal], pid)
      if opts[:kill_after]
        unless wait_thr.join(opts[:kill_after])
          Process.kill(:KILL, pid)
        end
      end
    ensure
      result[:status] = wait_thr.value if wait_thr
      result[:stdout] = out_reader.value if out_reader
      result[:stderr] = err_reader.value if err_reader
      out_r.close unless out_r.closed?
      err_r.close unless err_r.closed?
    end

    result
  end
end
