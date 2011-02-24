class TwoColumnsWidget < Widget

  after_save :create_children

  def create_children
    return if children.count > 0
    teaser = TeaserWidget.new :position => 0
    self.children.push teaser
    teaser.save

    tag_cloud = TagCloudWidget.new :position => 1
    self.children.push tag_cloud
    tag_cloud.save
  end

end
