class Setting::Colly < ::Setting
  BLANK_ATTRS << 'colly_proxy_probes'

  def self.load_defaults
    return unless super

    Setting.transaction do
      [
        self.set('colly_proxy_probes', N_("Probes for the Foreman Smart Proxy show page (separate by comma, Rails restart needed)"), "cpu/percent-system, memory/memory-free, swap/swap-free, webrick-request-time-avg/duration"),
      ].compact.each { |s| self.create s.update(:category => "Setting::Colly")}
    end

    true
  end

  def self.colly_proxy_probes
    return [] unless Setting['colly_proxy_probes'].present?
    list = Setting['colly_proxy_probes'].to_s.split(",").collect{ |x| x.strip }
  rescue => error
    logger.warn "Failed to parse comma delimited list [%s] into array. Error: %s" % [list, error]
  ensure
    list
  end
end
