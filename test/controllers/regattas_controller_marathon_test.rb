require 'test_helper'

class RegattasControllerMarathonTest < ActionDispatch::IntegrationTest
  setup do
    @regatta = regattas(:one)
  end

  test "confirm_marathon requires authentication" do
    post confirm_marathon_regatta_url(@regatta)
    # Unauthenticated users should be redirected to sign-in
    assert_response :redirect
  end
end
