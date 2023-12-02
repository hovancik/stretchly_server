
require 'test_helper'

class Users::SetGithubContributorsServiceTest < ActiveSupport::TestCase
  test 'perform' do
    contributor_ids = ["123456", "234567"]
    service = Users::SetGithubContributorsService.new(contributor_ids)
    service.perform
    assert users(:one).contributor
    assert users(:two).contributor
  end

  test 'manual contributor' do 
    contributor_ids = ["123456", "234567"]
    service = Users::SetGithubContributorsService.new(contributor_ids)
    service.perform
    assert users(:one).contributor
    assert users(:two).contributor
    assert users(:six).contributor
  end

end
