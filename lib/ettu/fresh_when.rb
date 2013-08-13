class Ettu
  module FreshWhen
    extend ActiveSupport::Concern

    def fresh_when(record_or_options, additional_options = {})
      ettu = Ettu.new record_or_options, additional_options, self

      ettu_params = {etag: ettu.etags, last_modified: ettu.last_modified}

      super nil, ettu.options.merge(ettu_params)
    end
  end
end
