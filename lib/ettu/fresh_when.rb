class Ettu
  module FreshWhen
    extend ActiveSupport::Concern

    included do
      alias_method :old_fresh_when, :fresh_when

      def fresh_when(record_or_options, additional_options = {})
        ettu = Ettu.new(record_or_options, additional_options)

        etags = [*ettu.response_etag]
        if view = ettu.options.fetch(:view, "#{controller_name}/#{action_name}")
          # TODO: This is ugly. How do we clean it up?
          etags << ettu.view_etag(view, request.format.try(:to_sym), lookup_context)
        end
        if request.format.try(:html?)
          etags << ettu.js_etag
          etags << ettu.css_etag
        end
        etags.concat ettu.asset_etags

        ettu_params = {etag: etags, last_modified: ettu.last_modified}

        old_fresh_when nil, ettu.options.merge(ettu_params)
      end

    end
  end
end
