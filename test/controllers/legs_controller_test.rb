require 'test_helper'

class LegsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @leg = legs(:one)
  end

  test "should get index" do
    get legs_url
    assert_response :success
  end

  test "should get new" do
    get new_leg_url
    assert_response :success
  end

  test "should create leg" do
    assert_difference('Leg.count') do
      post legs_url, params: { leg: { distance: @leg.distance, offshore: @leg.offshore, point_id: @leg.point_id, to_point_id: @leg.to_point_id, version: @leg.version } }
    end

    assert_redirected_to leg_url(Leg.last)
  end

  test "should show leg" do
    get leg_url(@leg)
    assert_response :success
  end

  test "should get edit" do
    get edit_leg_url(@leg)
    assert_response :success
  end

  test "should update leg" do
    patch leg_url(@leg), params: { leg: { distance: @leg.distance, offshore: @leg.offshore, point_id: @leg.point_id, to_point_id: @leg.to_point_id, version: @leg.version } }
    assert_redirected_to leg_url(@leg)
  end

  test "should destroy leg" do
    assert_difference('Leg.count', -1) do
      delete leg_url(@leg)
    end

    assert_redirected_to legs_url
  end
end
