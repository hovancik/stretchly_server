
require 'test_helper'

class Users::SetGithubContributorsServiceTest < ActiveSupport::TestCase
  test 'classic contributor' do
    contributor_ids = ["123456"]
    service = Users::SetGithubContributorsService.new(contributor_ids)
    service.perform
    # contributor
    assert users(:one).contributor
    # benefit stays forever
    assert users(:one).manual_contributor
    # non contrib
    refute users(:two).contributor
    refute users(:two).manual_contributor
    # manual
    assert users(:six).contributor
    assert users(:six).manual_contributor
  end
end
