module ForemanColly
  module SmartProxiesHelperExtensions
    extend ActiveSupport::Concern

    def probe_name_html_attribute_safe(probe_name)
       "id-" + probe_name.gsub(/(\s+|\/)/, "-")
    end
  end
end
