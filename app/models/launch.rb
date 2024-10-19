class Launch < ApplicationRecord
  validates :iss, presence: true
  validates :launch, presence: true
  validates :token_endpoint, presence: true
  validates :authorization_endpoint, presence: true
  validates :state, presence: true

  has_one :launch_token
end
