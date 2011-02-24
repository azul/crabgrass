class SidebarWidget < Widget

  after_save :create_children

  def create_children
    return if children.count > 0

    toplinks = ToplinkWidget.new :position => 0
    self.children.push toplinks
    toplinks.save

    quickfinder = QuickfinderWidget.new :position => 1
    self.children.push quickfinder
    quickfinder.save

    users = ActiveUsersWidget.new :position => 2
    self.children.push users
    users.save

    groups = ActiveGroupsWidget.new :position => 3
    self.children.push groups
    groups.save
  end

end
