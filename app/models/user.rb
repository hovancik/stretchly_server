class User < ApplicationRecord
  has_secure_token :auth_token
  has_one :setting

  validates :uid, presence: true
  validates :provider, presence: true, uniqueness: { scope: :uid }
  validates_inclusion_of :contributor, in: [true, false]

  def self.find_or_create_from_auth_hash(auth_hash)
    User.find_or_create_by(uid: auth_hash.uid, provider: auth_hash.provider)
  end
end
