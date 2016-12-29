require 'test_helper'

class BoatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @boat = boats(:one)
  end

  test "should get index" do
    get boats_url
    assert_response :success
  end

  test "should get new" do
    get new_boat_url
    assert_response :success
  end

  test "should create boat" do
    assert_difference('Boat.count') do
      post boats_url, params: { boat: { ais_mmsi: @boat.ais_mmsi, boat_class_id: @boat.boat_class_id, external_id: @boat.external_id, external_system: @boat.external_system, name: @boat.name, sail_number: @boat.sail_number, vhf_call_sign: @boat.vhf_call_sign } }
    end

    assert_redirected_to boat_url(Boat.last)
  end

  test "should show boat" do
    get boat_url(@boat)
    assert_response :success
  end

  test "should get edit" do
    get edit_boat_url(@boat)
    assert_response :success
  end

  test "should update boat" do
    patch boat_url(@boat), params: { boat: { ais_mmsi: @boat.ais_mmsi, boat_class_id: @boat.boat_class_id, external_id: @boat.external_id, external_system: @boat.external_system, name: @boat.name, sail_number: @boat.sail_number, vhf_call_sign: @boat.vhf_call_sign } }
    assert_redirected_to boat_url(@boat)
  end

  test "should destroy boat" do
    assert_difference('Boat.count', -1) do
      delete boat_url(@boat)
    end

    assert_redirected_to boats_url
  end
end
