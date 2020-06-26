# Daily check for Github contributors
module Recurring
  class SetGithubContributorsJob
    include Delayed::RecurringJob
    run_every 1.day
    run_at '11:00pm'

    def perform
      contributor_ids = (Github::GetContributorsService.perform +
        Github::GetSponsorsService.perform).uniq
      service = Users::SetGithubContributorsService.new(contributor_ids)
      service.perform
    end
  end
end
