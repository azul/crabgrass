require 'test/unit'
require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SiteRootWidgetTest < Test::Unit::TestCase

  def test_class
    test = SiteRootWidget.create
    assert_equal 3, Widget.count
    assert Widget.last.is_a? SidebarWidget
  end
end
