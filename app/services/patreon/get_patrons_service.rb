# Returns array of Patrons' IDs from Patreon
# adapted from https://github.com/Patreon/patreon-ruby/blob/master/example/fetch_all_patrons.rb
module Patreon
  class GetPatronsService
    def self.perform
      api_client = Patreon::API.new(ENV.fetch('PATREON_ACCESS_TOKEN'))
      campaign_response = api_client.fetch_campaign
      campaign_id = campaign_response['data'][0]['id']
      all_pledges = []
      cursor = nil
      loop do
        page_response = api_client.fetch_page_of_pledges(campaign_id, count: 25, cursor: cursor)
        all_pledges += page_response['data']
        next_page_link = page_response['links']['next']
        break unless next_page_link
        parsed_query = CGI::parse(next_page_link)
        cursor = parsed_query['page[cursor]'][0]
      end
      all_pledges.map { |pledge| pledge['relationships']['patron']['data']['id'] }
    end
  end
end
