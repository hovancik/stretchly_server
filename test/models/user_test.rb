require 'test_helper'
require 'ostruct'

class UserTest < ActiveSupport::TestCase
  test "provider and uid are unique" do
    assert_not User.new(provider: 'github',
      uid: '123456', auth_token: 'adfg',
      contributor: false).valid?
  end

  test "different provider and same uid are ok" do
    assert User.new(provider: 'patreon',
      uid: '123456', auth_token: 'adfg',
      contributor: false).valid?
  end

  test "same provider and different uid are ok" do
    assert User.new(provider: 'github',
      uid: '123450', auth_token: 'adfg',
      contributor: false).valid?
  end

  test "new user created via find_or_create_from_auth_hash has manual_contributor true" do
    auth_hash = OpenStruct.new(uid: '999999', provider: 'github')
    user = User.find_or_create_from_auth_hash(auth_hash)
    assert user.manual_contributor
  end

  test "new user created directly has manual_contributor true" do
    user = User.create(uid: '888888', provider: 'patreon', contributor: false)
    assert user.manual_contributor
  end

  test "existing user find_or_create_from_auth_hash preserves manual_contributor" do
    existing_user = users(:one)
    original_manual_contributor = existing_user.manual_contributor
    auth_hash = OpenStruct.new(uid: existing_user.uid, provider: existing_user.provider)
    found_user = User.find_or_create_from_auth_hash(auth_hash)
    assert_equal original_manual_contributor, found_user.manual_contributor
    assert_equal existing_user.id, found_user.id
  end
end
