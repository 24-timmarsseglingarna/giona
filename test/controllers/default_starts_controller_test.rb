require 'test_helper'

class DefaultStartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @default_start = default_starts(:one)
  end

  test "should get index" do
    get default_starts_url
    assert_response :success
  end

  test "should get new" do
    get new_default_start_url
    assert_response :success
  end

  test "should create default_start" do
    assert_difference('DefaultStart.count') do
      post default_starts_url, params: { default_start: { number: @default_start.number, organizer_id: @default_start.organizer_id } }
    end

    assert_redirected_to default_start_url(DefaultStart.last)
  end

  test "should show default_start" do
    get default_start_url(@default_start)
    assert_response :success
  end

  test "should get edit" do
    get edit_default_start_url(@default_start)
    assert_response :success
  end

  test "should update default_start" do
    patch default_start_url(@default_start), params: { default_start: { number: @default_start.number, organizer_id: @default_start.organizer_id } }
    assert_redirected_to default_start_url(@default_start)
  end

  test "should destroy default_start" do
    assert_difference('DefaultStart.count', -1) do
      delete default_start_url(@default_start)
    end

    assert_redirected_to default_starts_url
  end
end
