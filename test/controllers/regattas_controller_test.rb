require 'test_helper'

class RegattasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regatta = regattas(:one)
  end

  test "should get index" do
    get regattas_url
    assert_response :success
  end

  test "should get new" do
    get new_regatta_url
    assert_response :success
  end

  test "should create regatta" do
    assert_difference('Regatta.count') do
      post regattas_url, params: { regatta: { confirmation: @regatta.confirmation, email_from: @regatta.email_from, email_to: @regatta.email_to, name: @regatta.name, name_from: @regatta.name_from, organizer: @regatta.organizer } }
    end

    assert_redirected_to regatta_url(Regatta.last)
  end

  test "should show regatta" do
    get regatta_url(@regatta)
    assert_response :success
  end

  test "should get edit" do
    get edit_regatta_url(@regatta)
    assert_response :success
  end

  test "should update regatta" do
    patch regatta_url(@regatta), params: { regatta: { confirmation: @regatta.confirmation, email_from: @regatta.email_from, email_to: @regatta.email_to, name: @regatta.name, name_from: @regatta.name_from, organizer: @regatta.organizer } }
    assert_redirected_to regatta_url(@regatta)
  end

  test "should destroy regatta" do
    assert_difference('Regatta.count', -1) do
      delete regatta_url(@regatta)
    end

    assert_redirected_to regattas_url
  end
end
