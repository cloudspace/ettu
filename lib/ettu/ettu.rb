module Ettu
  class Ettu
    attr_reader :options

    def initialize(record_or_options, additional_options)
      if options.is_a Hash
        @record = nil
        @options = record_or_options
      else
        @record = record_or_options
        @options = additional_options
      end
    end

    def response_etag
      @options.fetch(:etag, @record)
    end

    def last_modified
      @options.fetch(:last_modified, @record.try(:updated_at))
    end

    def js_etag
      @js_etag ||= js_digest
    end

    def css_etag
      @css_etag ||= css_digest
    end

    def view_etag
      @view_etag ||= view_digest
    end

    private

    def ettu_params
      @ettu_params ||= extract_ettu_params
    end

    def extract_ettu_params
      js = @options.fetch(:js, nil)
      css = @options.fetch(:css, nil)

      js = 'application.js' if js.nil?
      css = 'application.css' if css.nil?

      { js: js, css: css }
    end

    def css_digest
      asset_digest(ettu_params[:css])
    end

    def js_digest
      asset_digest(ettu_params[:js])
    end

    # Jeremy Kemper
    # https://gist.github.com/jeremy/4211803
    def view_digest
      CacheDigests::TemplateDigestor.digest(
        "#{controller_name}/#{action_name}",
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
