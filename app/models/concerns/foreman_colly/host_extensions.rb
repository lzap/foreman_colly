require 'uxsock'

module ForemanColly
  module HostExtensions
    extend ActiveSupport::Concern

    def list_probes
      # TODO use Rails cache to speed up listing for larger deployments
      result = []
      ::Uxsock::CollectdUnixSock.open do |socket|
        socket.each_value do |time, id|
          begin
            ids = id.split('/')
            result << ids[1..-1].join('/') if ids[0] == name
          rescue Exception => e
            ForemanColly.logger.warn "Unable to parse probe #{id}: #{e}"
          end
        end
      end
      result
    end

    def read_probe probe_name
      result = {}
      ::Uxsock::CollectdUnixSock.open do |socket|
        socket.each_value_data("#{name}/#{probe_name}") do |col, val|
          val = nil if val == 'U' # undefined value
          result[col] = (val.to_f rescue val)
        end
      end
      result
    rescue Exception => e
      ForemanColly.logger.warn "Unable to read probe #{probe_name}: #{e}"
      {}
    end

    def read_probes probe_names = nil
      probe_names = list_probes if probe_names.nil?
      result = {}
      ::Uxsock::CollectdUnixSock.open do |socket|
        probe_names.each do |probe_name|
          socket.each_value_data("#{name}/#{probe_name}") do |col, val|
            val = nil if val == 'U' # undefined value
            result[probe_name] = {} if result[probe_name].nil?
            result[probe_name][col] = (val.to_f rescue val)
          end
        end
      end
      result
    rescue Exception => e
      ForemanColly.logger.warn "Unable to read probes: #{e}"
      {}
    end
  end
end
