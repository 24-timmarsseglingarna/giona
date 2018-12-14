require 'test_helper'

class HandicapsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @handicap = handicaps(:one)
  end

  test "should get index" do
    get handicaps_url
    assert_response :success
  end

  test "should get new" do
    get new_handicap_url
    assert_response :success
  end

  test "should create handicap" do
    assert_difference('Handicap.count') do
      post handicaps_url, params: { handicap: { expired_at: @handicap.expired_at, boat_name: @handicap.boat_name, external_id: @handicap.external_id, external_system: @handicap.external_system, sxk: @handicap.sxk, name: @handicap.name, owner_name: @handicap.owner_name, registry_id: @handicap.registry_id, sail_number: @handicap.sail_number, source: @handicap.source, srs: @handicap.srs, type: @handicap.type } }
    end

    assert_redirected_to handicap_url(Handicap.last)
  end

  test "should show handicap" do
    get handicap_url(@handicap)
    assert_response :success
  end

  test "should get edit" do
    get edit_handicap_url(@handicap)
    assert_response :success
  end

  test "should update handicap" do
    patch handicap_url(@handicap), params: { handicap: { expired_at: @handicap.expired_at, boat_name: @handicap.boat_name, external_id: @handicap.external_id, external_system: @handicap.external_system, sxk: @handicap.sxk, name: @handicap.name, owner_name: @handicap.owner_name, registry_id: @handicap.registry_id, sail_number: @handicap.sail_number, source: @handicap.source, srs: @handicap.srs, type: @handicap.type } }
    assert_redirected_to handicap_url(@handicap)
  end

  test "should destroy handicap" do
    assert_difference('Handicap.count', -1) do
      delete handicap_url(@handicap)
    end

    assert_redirected_to handicaps_url
  end
end
