class Ettu
  module FreshWhen
    extend ActiveSupport::Concern

    included do
      alias_method :old_fresh_when, :fresh_when

      def fresh_when(record_or_options, additional_options = {})
        ettu = Ettu.new(record_or_options, additional_options, self)

        ettu_params = {etag: ettu.etags, last_modified: ettu.last_modified}

        old_fresh_when nil, ettu.options.merge(ettu_params)
      end

    end
  end
end
