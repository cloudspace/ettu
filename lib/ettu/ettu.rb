module Ettu
  class Ettu
    attr_reader :options

    def initialize(record_or_options = nil, additional_options = {})
      if record_or_options.is_a? Hash
        @record = nil
        @options = record_or_options
      else
        @record = record_or_options
        @options = additional_options
      end
      @asset_etags = []
    end

    def response_etag
      @options.fetch(:etag, @record)
    end

    def last_modified
      @options.fetch(:last_modified, @record.try(:updated_at))
    end

    def view_etag(view)
      @view_etag ||= view_digest(view)
    end

    def asset_etag(asset)
      @asset_etags[asset] ||= asset_digest(asset)
    end

    def js_etag
      js = @options.fetch(:js, 'application.js')
      asset_etag js
    end

    def css_etag
      css = @options.fetch(:css, 'application.css')
      asset_etag css
    end

    private

    # Jeremy Kemper
    # https://gist.github.com/jeremy/4211803
    def view_digest(view)
      CacheDigests::TemplateDigestor.digest(
        view,
        request.format.try(:to_sym),
        lookup_context
      )
    rescue ActionView::MissingTemplate
      '' # Ignore missing templates
    end

    # Jeremy Kemper
    # https://gist.github.com/jeremy/4211803
    # Check precompiled asset manifest (production) or compute the digest (dev).
    def asset_digest(asset)
      return nil unless asset.present?
      if manifest = Rails.application.config.assets.digests
        manifest[asset]
      else
        Rails.application.assets[asset].digest
      end
    end
  end
end
