require File.dirname(__FILE__) + '/../test_helper'

class RootControllerTest < ActionController::TestCase
  fixtures :groups, :users, :pages, :memberships,
            :user_participations, :page_terms, :sites

  include UrlHelper

  def test_index_logged_in
    login_as :red

    with_site :test do
      get :index
      assert_response :success
    end
  end

  def test_still_redirect_without_site
    login_as :red
    get :index
    assert_response :redirect
  end

  def test_index_not_logged_in
    with_site :test do
      get :index
      assert_response :success
      assert_not_nil assigns["current_site"].id
      assert_not_nil assigns["group"]
      assert_template 'root/site_home'
    end
  end

  def test_normal_login_without_site
    get :index
    assert_response :success
    assert_nil assigns["current_site"].id
    assert_template 'account/index'
  end

  def test_normal_login_with_hidden_network
    net = sites(:test).network
    profile = net.profiles.public
    profile.may_see=false
    profile.save
    with_site :test do
      get :index
      assert_response :success
      assert assigns["current_site"]
      assert_template 'account/index'
    end
  end

  def test_site_home_content
    with_site :test do
      get :index
      assert_response :success

      # just make sure the Site specific stuff worked...
      assert_not_nil assigns["current_site"].id,
        "Response did not come from the site we expected."
      current_site=assigns["current_site"]

      assert_not_equal @controller.send(:most_active_users), [],
        "Expecting a list of most active users."
      assert_nil @controller.send(:most_active_users).detect{|u| !u.site_ids.include?(current_site.id)},
        "All users should be on current_site."
    end
  end

  def test_all_pages_public
    page = Page.create! :site_id => sites(:test).id, :title => "hide me"
    page.owner=users(:blue)
    page.add sites(:test).network
    page.save
    with_site :test do
      get :recent_pages
      assert_response :success
      assert_not_nil pages = @controller.send(:paginate)
      assert_nil pages.detect{|p| !p.public?}
    end
  end

  def test_non_public_pages_when_logged_in
    page = Page.create! :site_id => sites(:test).id, :title => "show me"
    page.owner=users(:blue)
    page.add sites(:test).network
    page.save
    login_as :blue
    with_site :test do
      get :recent_pages
      assert_response :success
      assert_not_nil pages = @controller.send(:paginate)
      assert pages.detect{|p| !p.public?}
    end
  end

end

