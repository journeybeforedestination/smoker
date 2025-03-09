class LaunchesController < ApplicationController
  require "fhir_server"

  REDIRECT_URI = ENV["FHIR_REDIRECT_URI"]

  def index
    @launches = Launch.all
  end

  def show
    @launch = Launch.find(params[:id])
    unless @launch.launch_token
      token = @launch.TradeCodeForToken(params[:code])
      token_data = {
        access_token: token["access_token"],
        experation: Time.now.utc + token["expires_in"],
        scope: token["scope"]
      }
      @launch.create_launch_token(token_data)
    end
  end

  def initiate
    launch_data = launch_params

    smart_config = FhirServer.new(launch_data[:iss]).fetch_config

    launch_data[:authorization_endpoint] = smart_config.body["authorization_endpoint"]
    launch_data[:token_endpoint] = smart_config.body["token_endpoint"]
    launch_data[:state] = SecureRandom.uuid.delete("-")
    launch_data[:pkce] = "ourcode"

    @launch = Launch.new(launch_data)

    # todo handle failure saving
    if @launch.save
      @launch.app_url = URI.join("http://" + request.host_with_port, launch_path(@launch))
      @launch.save
      target = @launch.CalcAuthRedirect
      redirect_to target, allow_other_host: true if target.start_with?(REDIRECT_URI)
    end
  end

  private

  def launch_params
    params.permit(:iss, :launch)
  end
end
