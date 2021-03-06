require File.dirname(__FILE__) + '/../test_helper'

class Admin::BaseControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  def setup
    enable_site_testing("moderation")
  end

  def test_user_authorization
    login_as :blue
    get :index
    assert @controller.current_user.moderator?, 'user blue should be a moderator'
  end

end

