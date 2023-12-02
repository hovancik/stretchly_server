# Set correct `contributor` for all github users
module Users
  class SetGithubContributorsService
    def initialize(patron_ids)
      @patron_ids = patron_ids
    end

    def perform
      User.where(provider: 'github').each do |user|
        user.update(contributor: @patron_ids.include?(user.uid) || user.manual_contributor)
      end
    end
  end
end
