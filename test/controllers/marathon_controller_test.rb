require 'test_helper'

class MarathonControllerTest < ActionDispatch::IntegrationTest
  test "public access to index" do
    get marathon_url
    assert_response :success
  end

  test "index with year filter" do
    get marathon_url, params: { year: 2024 }
    assert_response :success
  end

  test "index responds to xlsx" do
    get marathon_url, params: { format: :xlsx }
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', response.content_type
  end
end
