require 'test_helper'

class StartFinishesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @start_finish = start_finishes(:one)
  end

  test "should get index" do
    get start_finishes_url
    assert_response :success
  end

  test "should get new" do
    get new_start_finish_url
    assert_response :success
  end

  test "should create start_finish" do
    assert_difference('StartFinish.count') do
      post start_finishes_url, params: { start_finish: { organizer_id: @start_finish.organizer_id, point_number: @start_finish.point_number, start: @start_finish.start } }
    end

    assert_redirected_to start_finish_url(StartFinish.last)
  end

  test "should show start_finish" do
    get start_finish_url(@start_finish)
    assert_response :success
  end

  test "should get edit" do
    get edit_start_finish_url(@start_finish)
    assert_response :success
  end

  test "should update start_finish" do
    patch start_finish_url(@start_finish), params: { start_finish: { organizer_id: @start_finish.organizer_id, point_number: @start_finish.point_number, start: @start_finish.start } }
    assert_redirected_to start_finish_url(@start_finish)
  end

  test "should destroy start_finish" do
    assert_difference('StartFinish.count', -1) do
      delete start_finish_url(@start_finish)
    end

    assert_redirected_to start_finishes_url
  end
end
