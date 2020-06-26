# Returns array of Githubs' IDs
module Github
  class GetSponsorsService
    def self.perform
      client = Graphlient::Client.new('https://api.github.com/graphql',
          headers: {
            'Authorization' => "Bearer #{ENV.fetch('GITHUB_API_TOKEN')}",
            'Content-Type' => 'application/json'
          }
        )
      response = client.query <<~GRAPHQL
        query {
          user(login: "hovancik") {
            name
            sponsorshipsAsMaintainer(first: 1) {
              nodes {
                sponsor {
                  databaseId
                }
              }
            }
          }
        }
      GRAPHQL
      response.data.user.sponsorships_as_maintainer.nodes.map { |u| u.sponsor.database_id.to_s }
    end
  end
end
