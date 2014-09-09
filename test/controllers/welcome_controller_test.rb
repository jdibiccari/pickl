require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get welcome index if not logged in" do
    get :index
    assert_template :index
  end

  test "should get polls index if logged in" do
    sign_in users(:user_1)
    get :index
    assert_redirected_to polls_path
  end
end