require 'test_helper'

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users :one
    @competition = Competition.current
    @competition.update(
      start_time: Time.now.yesterday,
      end_time: Time.now.tomorrow
    )
  end

  test 'should get new' do
    get new_team_url
    assert_response :success
  end

  test 'should redirect to projects if competition closed' do
    Competition.current.update end_time: Time.now.yesterday
    get new_team_url
    assert_redirected_to projects_url
  end

  test 'should redirect to competition events if not registered for one' do
    User.first.event_assignment.destroy
    get new_team_url
    assert_redirected_to competition_events_url
  end

  test 'should post create' do
    assert_difference('Team.count') do
      post teams_url params: { team: { event_id: 2, youth_team: false } }
    end
    assert_redirected_to team_management_team_path(Team.last)
  end
end
