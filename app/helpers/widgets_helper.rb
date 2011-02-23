module WidgetsHelper

  def render_widget(widget)
    render :partial => widget.partial, :locals => {
      :widget => widget
    }
  end

end
