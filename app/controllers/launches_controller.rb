class LaunchesController < ApplicationController
  def index
    @launches = Launch.all
  end

  def show
    @launch = Launch.find(params[:id])
    @token = @launch.TradeCodeForToken(params[:code])
  end

  def initiate
    launch_data = launch_parms

    # this will break on windows... do we really need a gem for this???
    conn = Faraday.new(url: File.join(launch_data[:iss], ".well-known/smart-configuration")) do |builder|
      builder.request :json
      builder.response :json
      builder.response :raise_error
      builder.response :logger
    end

    # todo handle errors from remote server
    smart_config = conn.get
    launch_data[:authorization_endpoint] = smart_config.body["authorization_endpoint"]
    launch_data[:token_endpoint] = smart_config.body["token_endpoint"]

    launch_data[:state] = SecureRandom.uuid.delete("-")
    launch_data[:pkce] = "ourcode"

    @launch = Launch.new(launch_data)

    # todo handle failure saving
    if @launch.save
      app_url = URI.join("http://" + request.host_with_port, launch_path(@launch))
      @launch.update(app_url: app_url)
      target = @launch.CalcAuthRedirect(app_url)
      redirect_to target, allow_other_host: true
    end
  end

  private

  def launch_parms
    params.permit(:iss, :launch)
  end
end
