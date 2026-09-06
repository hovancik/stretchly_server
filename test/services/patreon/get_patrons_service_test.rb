require 'test_helper'

class Patreon::GetPatronsServiceTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :requests

    def initialize(responses)
      @responses = responses
      @requests = []
    end

    def get(path, query = {})
      @requests << [path, query]
      @responses.fetch(@requests.length - 1)
    end
  end

  test 'returns active patron user ids across v2 member pages' do
    client = FakeClient.new([
      { 'data' => [{ 'id' => 'campaign-123' }] },
      {
        'data' => [
          active_member('user-1'),
          active_member('user-2'),
          inactive_member('user-3')
        ],
        'meta' => { 'pagination' => { 'cursors' => { 'next' => 'cursor-2' } } }
      },
      {
        'data' => [active_member('user-2'), active_member(nil)],
        'meta' => { 'pagination' => { 'cursors' => { 'next' => nil } } }
      }
    ])

    assert_equal ['user-1', 'user-2'], Patreon::GetPatronsService.perform(client: client)
    assert_equal '/campaigns', client.requests[0][0]
    assert_empty client.requests[0][1]
    assert_equal '/campaigns/campaign-123/members', client.requests[1][0]
    assert_nil client.requests[1][1]['page[cursor]']
    assert_equal 'cursor-2', client.requests[2][1]['page[cursor]']
    assert_equal 'user', client.requests[1][1]['include']
    assert_equal 'patron_status', client.requests[1][1]['fields[member]']
    assert_equal 1000, client.requests[1][1]['page[count]']
  end

  test 'raises when Patreon returns no campaigns' do
    client = FakeClient.new([{ 'data' => [] }])

    error = assert_raises(Patreon::GetPatronsService::APIError) do
      Patreon::GetPatronsService.perform(client: client)
    end

    assert_includes error.message, 'no campaigns'
  end

  private

  def active_member(user_id)
    member = { 'attributes' => { 'patron_status' => 'active_patron' } }
    member['relationships'] = { 'user' => { 'data' => { 'id' => user_id } } } if user_id
    member
  end

  def inactive_member(user_id)
    {
      'attributes' => { 'patron_status' => 'former_patron' },
      'relationships' => { 'user' => { 'data' => { 'id' => user_id } } }
    }
  end
end
