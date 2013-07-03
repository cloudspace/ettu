class Ettu
  module FreshWhen
    extend ActiveSupport::Concern

    included do
      alias_method_chain :fresh_when, :ettu
    end

    private

    def fresh_when_with_ettu(record_or_options, additional_options = {})
      ettu = ettu_instance(record_or_options, additional_options, self)

      ettu_params = {etag: ettu.etags, last_modified: ettu.last_modified}

      fresh_when_without_ettu nil, ettu.options.merge(ettu_params)
    end

    def ettu_instance(record_or_options, additional_options, controller)
      Ettu.new record_or_options, additional_options, controller
    end
  end
end
