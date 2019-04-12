# Returns array of Githubs' IDs
module Github
  class GetContributorsService
    def self.perform
      result = Net::HTTP.get(URI.parse('https://api.github.com/repos/hovancik/stretchly/contributors'))
      parsed_result = JSON.parse(result)
      parsed_result.map { |user| user['id'].to_s  }
    end
  end
end
