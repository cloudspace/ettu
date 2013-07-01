require 'active_support/concern'
require 'active_support/ordered_options'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'

require 'ettu/version'
require 'ettu/configuration'
require 'ettu/fresh_when'
require 'ettu/railtie' if defined? Rails::Railtie

class Ettu
  attr_reader :options

  class << self
    @@config = Configuration.new

    def configure
      yield @@config
    end
  end

  def initialize(record_or_options = nil, additional_options = {}, controller = nil)
    @controller, @asset_etags = controller, {}
    if record_or_options.is_a? Hash
      @record, @options = nil, record_or_options
    else
      @record, @options = record_or_options, additional_options
    end
  end

  def etags
    etags = [*response_etag]
    etags << view_etag
    if @controller.request.format.try(:html?)
      etags << js_etag
      etags << css_etag
    end
    etags.concat asset_etags
  end

  def last_modified
    @options.fetch(:last_modified, @record.try(:updated_at))
  end

  def response_etag
    @options.fetch(:etag, @record)
  end

  def view_etag
    default_view = @@config.fetch(:view, "#{@controller.controller_name}/#{@controller.action_name}")
    view = @options.fetch(:view, default_view)
    @view_etag ||= view_digest(view)
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
    assets = @options.fetch(:assets, @@config.assets)
    [*assets].map { |asset| asset_etag(asset) }
  end

  private

  def asset_etag(asset)
    @asset_etags[asset] ||= asset_digest(asset)
  end

  # Jeremy Kemper
  # https://gist.github.com/jeremy/4211803
  def view_digest(view)
    return nil unless view.present?

    if @@config.template_digestor.nil? && Rails::VERSION::MAJOR == 3
      raise "Ettu requires the cache_digests gem when using Rails v#{Rails::VERSION::STRING}"
    end

    @@config.template_digestor.digest(
      view,
      @controller.request.format.try(:to_sym),
      @controller.lookup_context
    )
  end

  # Jeremy Kemper
  # https://gist.github.com/jeremy/4211803
  # Check precompiled asset manifest (production) or compute the digest (dev).
  def asset_digest(asset)
    return nil unless asset.present?
    # Is Rails.application.config.assets.digests needed?
    # Seems to always be nil...
    if manifest = Rails.application.config.assets.digests
      manifest[asset]
    else
      Rails.application.assets[asset].digest
    end
  end
end
