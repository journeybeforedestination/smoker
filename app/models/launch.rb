class Launch < ApplicationRecord
  validates :iss, presence: true
  validates :launch, presence: true
  validates :token_endpoint, presence: true
  validates :authorization_endpoint, presence: true
  validates :state, presence: true

  has_one :launch_token, dependent: :destroy

  # CalcAuthRedirect will build an approriate redirect URL for this launch.
  # The redirect will include the app_url as a query param along with the
  # other launch fields defined by SMART on FHIR
  def CalcAuthRedirect
      url = URI.parse(authorization_endpoint)
      query = if url.query
              CGI.parse(url.query)
      else
              {}
      end

      query["response_type"] = "code"
      query["client_id"] = "whatever"
      query["launch"] = launch
      query["scope"] = "launch/patient"
      query["redirect_uri"] = app_url
      query["aud"] = iss
      query["state"] = state
      query["code_challenge"] = Digest::SHA256.base64digest(pkce).delete("=")
      query["code_challenge_method"] = "S256"

      url.query = URI.encode_www_form(query)
      url.to_s
  end

  # todo, we should maybe create a token in the DB here? Maybe that should be the job of the controller?
  def TradeCodeForToken(code)
    data = {
      grant_type: "authorization_code",
      code: code,
      redirect_uri: app_url,
      code_verifier: pkce,
      client_id: "whatever"
    }

    response = Faraday.post(token_endpoint) do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      req.body = URI.encode_www_form(data)
    end

    if response.success?
      JSON.parse(response.body)
    else
      "Error: #{response.status}"
    end
  end
end
