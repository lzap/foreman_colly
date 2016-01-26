module Api
  module V2
    class CollyReportsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      def_param_group :colly_report do
        param :colly_report, Hash, :required => true, :action_aware => true do
          param :host, String, :required => true, :desc => N_("Hostname, required")
          param :logs, Array, :desc => N_("Array of log hashes, required"), :required => true do
            param :message, String, :required => true, :desc => N_("Collectd notification message")
            param :time, String, :desc => N_("Collectd notification time (default now)")
            param :level, String, :desc => N_("Collectd notification level (default 'okay')")
          end
        end
      end

      api :POST, "/colly_reports/", N_("Create a collectd notification report")
      param_group :colly_report, :as => :create

      def create
        @colly_report = ::ForemanColly::ReportImporter.import(params[:colly_report])
        render_message('Report created', :status => :ok) if @colly_report.save
      rescue ::Foreman::Exception => e
        render_message(e.to_s, :status => :unprocessable_entity)
      end

      private

      def resource_name
        "colly_report"
      end

      def resource_class
        ::ConfigReport
      end

      def controller_permission
        'config_reports'
      end
    end
  end
end
