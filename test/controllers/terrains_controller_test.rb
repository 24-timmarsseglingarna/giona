require 'test_helper'

class TerrainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @terrain = terrains(:one)
  end

  test "should get index" do
    get terrains_url
    assert_response :success
  end

  test "should get new" do
    get new_terrain_url
    assert_response :success
  end

  test "should create terrain" do
    assert_difference('Terrain.count') do
      post terrains_url, params: { terrain: { name: @terrain.name, published: @terrain.published, version: @terrain.version } }
    end

    assert_redirected_to terrain_url(Terrain.last)
  end

  test "should show terrain" do
    get terrain_url(@terrain)
    assert_response :success
  end

  test "should get edit" do
    get edit_terrain_url(@terrain)
    assert_response :success
  end

  test "should update terrain" do
    patch terrain_url(@terrain), params: { terrain: { name: @terrain.name, published: @terrain.published, version: @terrain.version } }
    assert_redirected_to terrain_url(@terrain)
  end

  test "should destroy terrain" do
    assert_difference('Terrain.count', -1) do
      delete terrain_url(@terrain)
    end

    assert_redirected_to terrains_url
  end
end
