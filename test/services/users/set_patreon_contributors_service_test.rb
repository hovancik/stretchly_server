
require 'test_helper'

class Users::SetPatreonContributorsServiceTest < ActiveSupport::TestCase
  test 'perform' do
    patron_ids = ["456"]
    service = Users::SetPatreonContributorsService.new(patron_ids)
    service.perform
    assert users(:three).contributor
    # benefit stays forever
    assert users(:three).manual_contributor
    # not
    refute users(:four).contributor
    refute users(:four).manual_contributor
    # manual
    assert users(:five).contributor
    assert users(:five).manual_contributor
  end
end
