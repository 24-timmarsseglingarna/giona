require 'test_helper'

class OrganizersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organizer = organizers(:one)
  end

  test "should get index" do
    get organizers_url
    assert_response :success
  end

  test "should get new" do
    get new_organizer_url
    assert_response :success
  end

  test "should create organizer" do
    assert_difference('Organizer.count') do
      post organizers_url, params: { organizer: { confirmation: @organizer.confirmation, email_from: @organizer.email_from, email_to: @organizer.email_to, external_id: @organizer.external_id, external_system: @organizer.external_system, name: @organizer.name, name_from: @organizer.name_from } }
    end

    assert_redirected_to organizer_url(Organizer.last)
  end

  test "should show organizer" do
    get organizer_url(@organizer)
    assert_response :success
  end

  test "should get edit" do
    get edit_organizer_url(@organizer)
    assert_response :success
  end

  test "should update organizer" do
    patch organizer_url(@organizer), params: { organizer: { confirmation: @organizer.confirmation, email_from: @organizer.email_from, email_to: @organizer.email_to, external_id: @organizer.external_id, external_system: @organizer.external_system, name: @organizer.name, name_from: @organizer.name_from } }
    assert_redirected_to organizer_url(@organizer)
  end

  test "should destroy organizer" do
    assert_difference('Organizer.count', -1) do
      delete organizer_url(@organizer)
    end

    assert_redirected_to organizers_url
  end
end
