# Check for Github contributors
class SetGithubContributorsJob < ApplicationJob
  def perform
    contributor_ids = (Github::GetContributorsService.perform +
      Github::GetSponsorsService.perform).uniq
    service = Users::SetGithubContributorsService.new(contributor_ids)
    service.perform
  end
end
