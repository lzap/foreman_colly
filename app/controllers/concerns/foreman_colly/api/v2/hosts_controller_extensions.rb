module ForemanColly::Api::V2::HostsControllerExtensions
  extend ActiveSupport::Concern

  included do
    api :GET, "/hosts/:host_id/list_probes/", N_("Lists available probe names for this host as an array")
    def list_probes
      render :json => { :probes => @host.list_probes }
    end

    api :GET, "/hosts/:host_id/read_probe/", N_("Returns probe as a hash indexed by value name")
    param :probe_name, String, :desc => N_("Name of a probe without hostname (e.g. memory/memory-free)"), :required => true
    def read_probe
      render :json => { :probe => @host.read_probe(params[:probe_name]) }
    end

    api :GET, "/hosts/:host_id/read_probes/", N_("Returns probe(s) as a hash indexed by value name")
    param :probe_names, Array, :desc => N_("Name of a probes to return (returns all probes if omitted)")
    def read_probes
      render :json => { :probes => @host.read_probes(params[:probe_names]) }
    end

    alias_method_chain :action_permission, :colly
  end

  def action_permission_with_colly
    case params[:action]
      when 'list_probes', 'read_probe', 'read_probes'
        :view
      else
        action_permission_without_colly
    end
  end
end
