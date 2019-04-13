namespace :recurring do
  task init: :environment do
    Recurring::SetGithubContributorsJob.schedule!
    Recurring::SetPatreonContributorsJob.schedule!
  end
end
