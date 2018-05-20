require 'test_helper'

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
  end

  test "should get index" do
    get teams_url
    assert_response :success
  end

  test "should get new" do
    get new_team_url
    assert_response :success
  end

  test "should create team" do
    assert_difference('Team.count') do
      post teams_url, params: { team: { boat_type_name: @team.boat_type_name, boat_name: @team.boat_name, boat_sail_number: @team.boat_sail_number, external_id: @team.external_id, external_system: @team.external_system, handicap: @team.handicap, name: @team.name, plaque_distance: @team.plaque_distance, race_id: @team.race_id, start_number: @team.start_number, start_point: @team.start_point } }
    end

    assert_redirected_to team_url(Team.last)
  end

  test "should show team" do
    get team_url(@team)
    assert_response :success
  end

  test "should get edit" do
    get edit_team_url(@team)
    assert_response :success
  end

  test "should update team" do
    patch team_url(@team), params: { team: { boat_type_name: @team.boat_type_name, boat_name: @team.boat_name, boat_sail_number: @team.boat_sail_number, external_id: @team.external_id, external_system: @team.external_system, handicap: @team.handicap, name: @team.name, paid_fee: @team.paid_fee, plaque_distance: @team.plaque_distance, race_id: @team.race_id, start_number: @team.start_number, start_point: @team.start_point } }
    assert_redirected_to team_url(@team)
  end

  test "should destroy team" do
    assert_difference('Team.count', -1) do
      delete team_url(@team)
    end

    assert_redirected_to teams_url
  end
end
