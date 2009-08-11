#
# Handles exceptions for all crabgrass controllers.
#
# This is the proper way to report an error in crabgrass:
#
#   raise ErrorMessage.new("i am sorry dave, i can't do that right now")
#
# Or, you can use the helper:
#
#   raise_error("i am sorry dave, i can't do that right now")
#
# For not found, use:
#
#   raise_not_found("Invite"[:invite])
#

module ControllerExtension::RescueErrors

  def self.included(base)
    base.class_eval do
      rescue_from ErrorNotFound,    :with => :render_not_found
      rescue_from PermissionDenied, :with => :render_permission_denied
      rescue_from ErrorMessage,     :with => :render_error
      rescue_from ActionController::InvalidAuthenticityToken, :with => :render_csrf_error
      helper_method :rescues_path
    end
  end

  protected

  # allows us to set a new path for the rescue templates
  def rescues_path(template_name)
    file = "#{RAILS_ROOT}/app/views/rescues/#{template_name}.erb"
    if File.exists?(file)
      return file
    else
      return super(template_name)
    end
  end

  # handles suspected "cross-site request forgery" errors
  def render_csrf_error(exception=nil)
    render :template => 'account/csrf_error'
  end

  # shows a generic not found page
  def render_not_found(exception=nil)
    @skip_context = true
    render :template => 'common/not_found', :status => :not_found
  end

  # show a permission denied page, or prompt for login
  def render_permission_denied(exception=nil)
    @skip_context = true

    respond_to do |format|
      # rails defaults to first format if params[:format] is not set
      format.html do
        if logged_in?
          render :template => 'common/permission_denied'
        else
          flash_auth_error(:later)
          redirect_to :controller => '/account', :action => 'login',
            :redirect => request.request_uri
        end
      end
      format.js do
        flash_auth_error(:now)
        render :update do |page|
          page.replace_html 'message', display_messages
          page << 'window.location.hash = "message"'
        end
      end
      format.xml do
        headers["Status"]           = "Unauthorized"
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")
        render :text => "Could not authenticate you", :status => '401 Unauthorized'
      end
    end
  end

  # display an error message or messages
  def render_error(exception=nil)
    respond_to do |format|
      format.html do
        if exception
          if exception.try(:options).try[:redirect]
            flash_message :exception => exception
            redirect_to exception.options[:redirect]
            return
          else
            flash_message_now :exception => exception
          end
        end
        @skip_context = true
        render :template => 'common/error', :status => exception.try(:status)
      end
      format.js do
        if exception
          flash_message_now :exception => exception
        end
        render :update do |page|
          page.replace_html 'message', display_messages
          page << 'window.location.hash = "message"'
        end
      end
    end
  end

  private

  def flash_auth_error(mode)
    if mode == :now
      flsh = flash.now
    else
      flsh = flash
    end

    if logged_in?
      add_flash_message(flsh, :title => "Permission Denied"[:alert_permission_denied], :error => 'You do not have sufficient permission to perform that action.'[:permission_denied_description])
    else
      add_flash_message(flsh, :title => 'Login Required'[:login_required], :success => 'Please login to perform that action.'[:login_required_description])
    end
  end

end
