# Daily check for Patreaon contributors
module Recurring
  class SetPatreonContributorsJob
    include Delayed::RecurringJob
    run_every 1.day
    run_at '11:00pm'

    def perform
      patron_ids = Patreon::GetPatronsService.perform
      service = Users::SetPatreonContributorsService.new(patron_ids)
      service.perform
    end
  end
end
