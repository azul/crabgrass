class MainWidget < Widget

  after_save :create_children

  def create_children
    return if children.count > 0

    intro = IntroWidget.new :position => 0
    self.children.push intro
    intro.save

    map = MapWidget.new :position => 1
    self.children.push map
    map.save

    double = TwoColumnsWidget.new :position => 2
    self.children.push double
    double.save

    opinion = TeaserWidget.new :position => 3
    self.children.push opinion
    opinion.save

    pages = PageListWidget.new :position => 4
    self.children.push pages
    pages.save
  end

end
