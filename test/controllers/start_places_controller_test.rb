require 'test_helper'

class StartPlacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @start_place = start_places(:one)
  end

  test "should get index" do
    get start_places_url
    assert_response :success
  end

  test "should get new" do
    get new_start_place_url
    assert_response :success
  end

  test "should create start_place" do
    assert_difference('StartPlace.count') do
      post start_places_url, params: { start_place: { number: @start_place.number, organizer_id: @start_place.organizer_id } }
    end

    assert_redirected_to start_place_url(StartPlace.last)
  end

  test "should show start_place" do
    get start_place_url(@start_place)
    assert_response :success
  end

  test "should get edit" do
    get edit_start_place_url(@start_place)
    assert_response :success
  end

  test "should update start_place" do
    patch start_place_url(@start_place), params: { start_place: { number: @start_place.number, organizer_id: @start_place.organizer_id } }
    assert_redirected_to start_place_url(@start_place)
  end

  test "should destroy start_place" do
    assert_difference('StartPlace.count', -1) do
      delete start_place_url(@start_place)
    end

    assert_redirected_to start_places_url
  end
end
