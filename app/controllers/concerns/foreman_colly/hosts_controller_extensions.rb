module ForemanColly::HostsControllerExtensions
  extend ActiveSupport::Concern

  included do
    alias_method_chain :action_permission, :colly
  end

  def probes
    find_resource
    render :partial => 'probes', :locals => { :probes => @host.read_probes }
  rescue ActionView::Template::Error => exception
    process_ajax_error exception, 'fetch probes'
  end

  def action_permission_with_colly
    case params[:action]
      when 'probes'
        :view
      else
        action_permission_without_colly
    end
  end
end
