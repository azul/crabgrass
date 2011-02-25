module Admin::WidgetsPermission

  def may_index_widgets?
    may_admin_site?
  end

  def may_destroy_widgets?(page=nil)
    may_index_widgets?
  end

  alias_method :may_new_widgets?, :may_index_widgets?
  alias_method :may_create_widgets?, :may_index_widgets?
  alias_method :may_edit_widgets?, :may_index_widgets?
  alias_method :may_update_widgets?, :may_index_widgets?
  alias_method :may_show_widgets?, :may_index_widgets?
end
