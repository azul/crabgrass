class Admin::WidgetsController < Admin::BaseController

  helper :widgets
  permissions 'admin/widgets'

  def index
    @widget = current_site.widget
    render :action => 'edit'
  end

  def show
    @widget = Widget.find params[:id]
  end

  def edit
    @widget = Widget.find params[:id]
  end

  def update
    @widget = Widget.find params[:id]
  end

  def new
  end

  def create
  end

end
