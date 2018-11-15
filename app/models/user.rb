class User < ApplicationRecord
  has_secure_token :auth_token

  validates :uid, presence: true
  validates :provider, presence: true, uniqueness: { scope: :uid }
  validates_inclusion_of :contributor,:in => [true, false]
end
