class Ettu
  module FreshWhen
    extend ActiveSupport::Concern

    def fresh_when(record_or_options, additional_options = {})
      ettu = ettu_instance(record_or_options, additional_options, self)

      ettu_params = {etag: ettu.etags, last_modified: ettu.last_modified}

      super nil, ettu.options.merge(ettu_params)
    end

    private

    def ettu_instance(record_or_options, additional_options, controller)
      Ettu.new record_or_options, additional_options, controller
    end
  end
end
