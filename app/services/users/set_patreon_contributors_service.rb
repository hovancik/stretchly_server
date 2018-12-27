# Set correct `contributor` for all patreon users
module Users
  class SetPatreonContributorsService
    def initialize(patron_ids)
      @patron_ids = patron_ids
    end

    def perform
      User.where(provider: 'patreon').each do |user|
        user.update(contributor: @patron_ids.include?(user.uid))
      end
    end
  end
end
