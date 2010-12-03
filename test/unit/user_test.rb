require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships

  def setup
    Time.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_ensure_values_in_receive_notifications
    user = User.make

    user.receive_notifications = nil
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = true
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = false
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = "Any"
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = "Digest"
    user.save!
    assert_equal "Digest", user.receive_notifications

    user.receive_notifications = "Single"
    user.save!
    assert_equal "Single", user.receive_notifications

    user.receive_notifications = ""
    user.save!
    assert_equal nil, user.receive_notifications
  end

  ## ensure that a user and a group cannot have the same handle
  def test_namespace
    assert_no_difference 'User.count' do
      u = create_user(:login => 'groups')
      assert u.errors.on(:login)
    end

    g = Group.create :name => 'robot-overlord'
    assert_no_difference 'User.count' do
      u = create_user(:login => 'robot-overlord')
      assert u.errors.on(:login)
    end
  end

  def test_associations
    assert check_associations(User)
  end

  def test_alphabetized
    assert_equal User.all.size, User.alphabetized('').size

    # find numeric group names
    assert_equal 0, User.alphabetized('#').size
    User.create! :login => '2unlimited', :password => '3qasdb43!sdaAS...', :password_confirmation => '3qasdb43!sdaAS...'
    assert_equal 1, User.alphabetized('#').size

    # case insensitive
    assert_equal User.alphabetized('G').size, User.alphabetized('g').size

    # nothing matches
    assert User.alphabetized('z').empty?
  end

  def test_peers_of
    u = users(:blue)
    assert_equal u.peers, User.peers_of(u)
  end

  def test_removal_deletes_chat_channels_users
    user = create_user
    user_id = user.id

    group1 = groups(:true_levellers)
    group1.add_user! user
    channel1 = ChatChannel.create(:name => group1.name, :group_id => group1.id)
    ChatChannelsUser.create({:channel => channel1, :user => user})

    group2 = groups(:rainbow)
    group2.add_user! user
    channel2 = ChatChannel.create(:name => group2.name, :group_id => group2.id)
    ChatChannelsUser.create({:channel => channel2, :user => user})

    user.destroy
    assert ChatChannelsUser.find(:all, :conditions => {:user_id => user_id}).empty?
  end

  def test_new_user_has_discussion
    u = User.create! :login => '2unlimited', :password => '3qasdb43!sdaAS...', :password_confirmation => '3qasdb43!sdaAS...'
    assert !u.reload.wall_discussion.new_record?
  end

  def test_active_since
    u_active = User.create! :login => 'activeuser', :password => 'password', :password_confirmation => 'password', :last_seen_at => 2.days.ago
    u_inactive = User.create! :login => 'inactiveuser', :password => 'password', :password_confirmation => 'password', :last_seen_at => 2.months.ago
    u_inactive_never_logged_in = User.create! :login => 'inactiveuser_never_logged_in', :password => 'password', :password_confirmation => 'password'
    active_users = User.active_since(1.week.ago)
    inactive_users = User.inactive_since(1.week.ago)
    assert (active_users.include?(u_active) and !active_users.include?(u_inactive))
    assert (inactive_users.include?(u_inactive) and inactive_users.include?(u_inactive_never_logged_in) and !inactive_users.include?(u_active))
  end

  def test_current_status_escaped
    u = User.create!(:login => 'badhacker', :password => 'password', :password_confirmation => 'password');
    sp = make_status_post('</textarea><script>alert("Hello")</script>', u)
    assert !u.current_status.match(/<[^>]+>/)
    u2 = User.create!(:login => 'gooduser', :password => 'password', :password_confirmation => 'password');
    sp = make_status_post('hello', u2)
    assert (u2.current_status == 'hello')
  end

  def test_both_names
    u = User.create!(:login => 'loginname', :display_name => 'display name!', :password => 'password', :password_confirmation => 'password');
    assert(u.both_names == 'display name! (loginname)')
  end

  protected

  def create_user(options = {})
    User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
  end

  def make_status_post(body, u)
    StatusPost.create do |post|
      post.body = body 
      post.body = post.body[0..140] if post.body
      post.discussion = u.wall_discussion
      post.user = u
      post.recipient = u
      post.body_html = post.lite_html
    end
  end


end
