class Launch < ApplicationRecord
  validates :iss, presence: true
  validates :launch, presence: true
  validates :token_endpoint, presence: true
  validates :authorization_endpoint, presence: true
  validates :state, presence: true

  has_one :launch_token

  # CalcAuthRedirect will build an approriate redirect URL for this launch.
  # The redirect will include the app_url as a query param along with the
  # other launch fields defined by SMART on FHIR
  def CalcAuthRedirect(app_url)
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
      query["code_challenge"] = pkce
      query["code_challenge_method"] = "S256"

      url.query = URI.encode_www_form(query)
      url.to_s
  end
end
