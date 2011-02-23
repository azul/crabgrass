class SiteRootWidget < Widget

  def partial
    '/widgets/site_root'
  end

  after_save :create_children

  def create_children
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
