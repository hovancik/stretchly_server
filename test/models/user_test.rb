require 'test_helper'

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
end
