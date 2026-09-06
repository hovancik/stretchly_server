require 'json'
require 'net/http'
require 'uri'

# Returns array of active patrons' user IDs from Patreon API V2.
module Patreon
  class GetPatronsService
    API_BASE_URL = 'https://www.patreon.com/api/oauth2/v2'.freeze
    PAGE_COUNT = 1000

    class APIError < StandardError; end

    class HttpClient
      def initialize(token)
        @token = token
      end

      def get(path, query = {})
        uri = URI.parse("#{API_BASE_URL}#{path}")
        uri.query = URI.encode_www_form(query)
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{@token}"
        request['User-Agent'] = 'Stretchly Patreon V2 Sync'
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
          open_timeout: 5, read_timeout: 15) { |http| http.request(request) }

        unless response.is_a?(Net::HTTPSuccess)
          raise APIError, "Patreon API returned HTTP #{response.code}: #{response.body}"
        end

        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise APIError, "Patreon API returned invalid JSON: #{e.message}"
      end
    end

    def self.perform(client: HttpClient.new(ENV.fetch('PATREON_ACCESS_TOKEN')))
      new(client).perform
    end

    def initialize(client)
      @client = client
    end

    def perform
      campaign_id = find_campaign_id
      patron_ids = []
      cursor = nil
      page_number = 0

      loop do
        page_number += 1
        response = @client.get("/campaigns/#{campaign_id}/members", members_query(cursor))
        members = response.fetch('data')
        patron_ids.concat(active_patron_ids(members))
        cursor = response.dig('meta', 'pagination', 'cursors', 'next')
        Rails.logger.info("Patreon V2 sync page=#{page_number} members=#{members.length} active_patron_ids=#{patron_ids.length}")
        break if cursor.nil? || cursor.empty?
      end

      patron_ids.uniq
    rescue KeyError, TypeError => e
      raise APIError, "Patreon API returned an unexpected response: #{e.message}"
    end

    private

    def find_campaign_id
      campaigns = @client.get('/campaigns').fetch('data')
      # This creator currently has one campaign, so use the first campaign Patreon returns.
      campaign = campaigns.first
      raise APIError, 'Patreon returned no campaigns' unless campaign

      campaign.fetch('id')
    end

    def members_query(cursor)
      query = {
        'include' => 'user',
        'fields[member]' => 'patron_status',
        'page[count]' => PAGE_COUNT
      }
      query['page[cursor]'] = cursor if cursor
      query
    end

    def active_patron_ids(members)
      members.filter_map do |member|
        next unless member.dig('attributes', 'patron_status') == 'active_patron'

        user_id = member.dig('relationships', 'user', 'data', 'id')
        Rails.logger.warn('Patreon member missing user relationship') unless user_id
        user_id
      end
    end
  end
end
