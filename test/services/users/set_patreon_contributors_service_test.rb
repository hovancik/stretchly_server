
require 'test_helper'

class Users::SetPatreonContributorsServiceTest < ActiveSupport::TestCase
  test 'perform' do
    patron_ids = ["456", "3456"]
    service = Users::SetPatreonContributorsService.new(patron_ids)
    service.perform
    assert users(:three).contributor
    assert users(:four).contributor
  end
end
