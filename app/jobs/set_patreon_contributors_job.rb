# Check for Patreaon contributors
class SetPatreonContributorsJob < ApplicationJob
  def perform
    patron_ids = Patreon::GetPatronsService.perform
    service = Users::SetPatreonContributorsService.new(patron_ids)
    service.perform
  end
end
