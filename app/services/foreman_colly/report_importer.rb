module ForemanColly

  #
  # Example input JSON:
  #
  class ReportImporter
    COLLECTD_LEVELS = {
      'OKAY' => :info,
      'FAILURE' => :err,
      'WARNING' => :notice
    }

    delegate :logger, :to => :Rails
    attr_reader :report

    def self.import(raw)
      fail ::Foreman::Exception.new(_('Invalid report - expecting a hash')) unless raw.is_a?(Hash)
      importer = ForemanColly::ReportImporter.new(raw['host'], raw['logs'])
      importer.import
    end

    def initialize(host, logs)
      @host = find_or_create_host(host)
      @logs = logs
    end

    def import
      logger.info "Processing colly notification report for #{@host}"
      logger.debug { "Report: #{@logs.inspect}" }

      if @host.nil?
        logger.info("Skipping report for an unknown host #{@host}")
        return Report.new
      end

      current_time = Time.now.utc
      @report = Report.create!(:host => @host, :reported_at => current_time, :status => 0)
      @host.last_report = current_time
      @logs.each do |line|
        time = Time.parse(line['time']) rescue current_time
        severity = line['severity'] || 'OKAY'
        level = COLLECTD_LEVELS[severity] || :info
        source = Source.find_or_create('collectd')
        message = Message.find_or_create(line['message'])
        Log.create!(:message_id => message.id, :source_id => source.id, :report => @report, :level => level)
      end

      # TODO implement status change
      #@host.refresh_statuses

      @host.save(:validate => false)
      @report
    end

    private

    def find_or_create_host(host)
      @host ||= Host::Managed.find_by_name(host)
    end
  end
end
