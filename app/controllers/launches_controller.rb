class LaunchesController < ApplicationController
  def index
    @launches = Launch.all
  end

  def show
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
    launch_data[:pkce] = Digest::SHA256.hexdigest "ourcode"

    @launch = Launch.new(launch_data)

    # ex target: https://launch.smarthealthit.org/v/r4/auth/authorize?response_type=code&client_id=whatever&scope=patient%2F*.*%20user%2F*.*%20launch%20launch%2Fpatient%20launch%2Fencounter%20openid%20fhirUser%20profile%20offline_access&redirect_uri=https%3A%2F%2Flaunch.smarthealthit.org%2Fsample-app&aud=https%3A%2F%2Flaunch.smarthealthit.org%2Fv%2Fr4%2Ffhir&state=kuPNPLBtO2TqvSOF&launch=WzAsIiIsIiIsIkFVVE8iLDAsMCwwLCIiLCIiLCIiLCIiLCIiLCIiLCIiLDAsMSwiIl0&code_challenge=SWTzkX6Kdd58nGK6zIq0iHH7YAr8QGbwmFBUhRk6EIk&code_challenge_method=S256
    # todo handle failure saving
    if @launch.save
      app_url = URI.join("http://" + request.host_with_port, launches_path)
      target = @launch.CalcAuthRedirect(app_url)
      redirect_to target, allow_other_host: true
    end
  end

  private

  def launch_parms
    params.permit(:iss, :launch)
  end
end
