require 'api_constraints'

Foreman::Application.routes.draw do
  constraints(:id => /[^\/]+/) do
    get '/hosts/:id/probes', to: 'hosts#probes', as: 'probes_host'
  end

  namespace :api, :defaults => {:format => 'json'} do
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'}, :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
      constraints(:id => /[^\/]+/) do
        get '/hosts/:id/list_probes', to: 'hosts#list_probes'
        get '/hosts/:id/read_probe/:probe_name', to: 'hosts#read_probe', :constraints => {:probe_name => /.*/}
        get '/hosts/:id/read_probes', to: 'hosts#read_probes'
      end
    end
  end
end
