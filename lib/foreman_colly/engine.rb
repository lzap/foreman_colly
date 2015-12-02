require 'deface'

module ForemanColly
  class Engine < ::Rails::Engine
    engine_name 'foreman_colly'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    # Add any db migrations
    initializer 'foreman_colly.load_app_instance_data' do |app|
      ForemanColly::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_colly.register_plugin', after: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_colly do
        requires_foreman '>= 1.4'

        # Add permissions
        security_block :foreman_colly do
          permission :view_foreman_colly, :'foreman_colly/hosts' => [:new_action]
        end

        # Add a new role called 'Discovery' if it doesn't exist
        role 'ForemanColly', [:view_foreman_colly]

        # add menu entry
        menu :top_menu, :template,
             url_hash: { controller: :'foreman_colly/hosts', action: :new_action },
             caption: 'ForemanColly',
             parent: :hosts_menu,
             after: :hosts

        # add dashboard widget
        widget 'foreman_colly_widget', name: N_('Foreman plugin template widget'), sizex: 4, sizey: 1
      end
    end

    # Precompile any JS or CSS files under app/assets/
    # If requiring files from each other, list them explicitly here to avoid precompiling the same
    # content twice.
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

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      begin
        Host::Managed.send(:include, ForemanColly::HostExtensions)
        HostsHelper.send(:include, ForemanColly::HostsHelperExtensions)
      rescue => e
        Rails.logger.warn "ForemanColly: skipping engine hook (#{e})"
      end
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
  end
end
