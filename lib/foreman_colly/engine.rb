require 'deface'

module ForemanColly
  class Engine < ::Rails::Engine
    engine_name 'foreman_colly'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
    config.autoload_paths += Dir["#{config.root}/lib"]

    initializer 'foreman_colly.load_default_settings', :before => :load_config_initializers do |app|
      require_dependency File.expand_path("../../../app/models/setting/colly.rb", __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer 'foreman_colly.load_app_instance_data' do |app|
      ForemanColly::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_colly.register_plugin', after: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_colly do
        requires_foreman '>= 1.11'

        #security_block :foreman_colly do
          #permission :view_foreman_colly, :'foreman_colly/hosts' => [:new_action]
        #end

        #role 'ForemanColly', [:view_foreman_colly]

        #menu :top_menu, :template,
             #url_hash: { controller: :'foreman_colly/hosts', action: :new_action },
             #caption: 'ForemanColly',
             #parent: :hosts_menu,
             #after: :hosts

        widget 'single_probe_widget', name: N_('Single probe widget'), sizex: 6, sizey: 1

        extend_page "smart_proxies/show" do |cx|
          # cx.add_pagelet :main_tabs, :name => "Probes", :partial => "smart_proxies/show/probe_contents"
          # Setting::Colly.colly_proxy_probes.each do |probe_name|
          #   cx.add_pagelet :probe_contents, :partial => "smart_proxies/show/configured_probes_pagelet", :probe_name => probe_name
          # end
        end
      end
    end

    assets_to_precompile =
      Dir.chdir(root) do
        Dir['app/assets/javascripts/**/*', 'app/assets/stylesheets/**/*'].map do |f|
          f.split(File::SEPARATOR, 4).last
        end
      end
    initializer 'foreman_colly.assets.precompile' do |app|
      app.config.assets.precompile += assets_to_precompile
    end
    initializer 'foreman_colly.configure_assets', group: :assets do
      SETTINGS[:foreman_colly] = { assets: { precompile: assets_to_precompile } }
    end

    config.to_prepare do
      ::Host::Managed.send :include, ForemanColly::HostExtensions
      ::HostsController.send :include, ForemanColly::HostsControllerExtensions
      ::SmartProxiesHelper.send :include, ForemanColly::SmartProxiesHelperExtensions
      ::Api::V2::HostsController.send :include, ForemanColly::Api::V2::HostsControllerExtensions
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanColly::Engine.load_seed
      end
    end

    initializer 'foreman_colly.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_colly'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_colly.deface_host_view' do |_app|
      Deface::Override.new(:virtual_path => "hosts/show.html.erb",
                       :name => "remove_parent_organization_on_create",
                       :insert_bottom => 'erb[loud]:contains("select_f"):contains(":parent")',
                       :text => '<% if taxonomy.is_a?(Location) %><%= render_original %><% end %>'
                       )
    end

  end

  def self.logger
    Foreman::Logging.logger('foreman_colly')
  end
end
