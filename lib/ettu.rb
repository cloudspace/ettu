require 'active_support/concern'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'

require 'ettu/version'
require 'ettu/fresh_when'
require 'ettu/railtie' if defined? Rails

class Ettu
  attr_reader :options

  class << self
    @@config = ActiveSupport::OrderedOptions.new
    @@config.js = 'application.js'
    @@config.css = 'application.css'
    @@config.assets = []

    def configure
      yield @@config
    end
  end

  def initialize(record_or_options = nil, additional_options = {})
    if record_or_options.is_a? Hash
      @record = nil
      @options = record_or_options
    else
      @record = record_or_options
      @options = additional_options
    end
    @asset_etags = {}
  end

  def response_etag
    @options.fetch(:etag, @record)
  end

  def last_modified
    @options.fetch(:last_modified, @record.try(:updated_at))
  end

  def view_etag(view, format, lookup_context)
    @view_etag ||= view_digest(view, format, lookup_context)
  end

  def js_etag
    js = @options.fetch(:js, @@config.js)
    asset_etag js
  end

  def css_etag
    css = @options.fetch(:css, @@config.css)
    asset_etag css
  end

  def asset_etags
    assets = @config.fetch(:assets, @@config.assets)
    [*assets].map { |asset| asset_etag(asset) }
  end

  private

  def asset_etag(asset)
    @asset_etags[asset] ||= asset_digest(asset)
  end

  # Jeremy Kemper
  # https://gist.github.com/jeremy/4211803
  def view_digest(view, format, lookup_context)
    ActionView::Digestor.digest(
      view,
      format,
      lookup_context
    )
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
