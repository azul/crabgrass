class SocialActivitiesSweeper < ActionController::Caching::Sweeper
  observe Activity

  def after_save(record)
    record.affected_users.each do |u|
      expire_action :controller => 'me/social_activities', :action => 'index', :user => u
    end
    record.affected_users(:peers).each do |u|
      expire_action :controller => 'me/social_activities', :action => 'peers', :user => u
    end
  end

  def after_destroy(record)
    record.affected_users.each do |u|
      expire_action :controller => 'me/social_activities', :action => 'index', :user => u
    end
    record.affected_users(:peers).each do |u|
      expire_action :controller => 'me/social_activities', :action => 'peers', :user => u
    end
  end
end
