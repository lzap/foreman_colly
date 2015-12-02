module ForemanColly
  # Example: Plugin's HostsController inherits from Foreman's HostsController
  class HostsController < ::HostsController
    # change layout if needed
    # layout 'foreman_colly/layouts/new_layout'

    def new_action
      # automatically renders view/foreman_colly/hosts/new_action
    end
  end
end
