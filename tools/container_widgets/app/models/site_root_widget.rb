class SiteRootWidget < Widget

  debugger
  after_save :create_children

  def create_children
    debugger
    return if children.count > 0
    main = MainWidget.new :position => 0
    self.children.push main
    main.save
    sidebar = SidebarWidget.new :position => 1
    self.children.push sidebar
    sidebar.save
  end

  def sidebar
    self.children.last
  end

  def main
    self.children.first
  end
end
