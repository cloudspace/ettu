class Nester < ActiveSupport::OrderedOptions
  def initialize
    super { |h, k| h[k] = Nester.new }
  end
end

class Controller < Nester
  def initialize
    super

    self.request.format['html?'] = true
    self.controller_name = 'controller_name'
    self.action_name = 'action_name'
  end

  def fresh_when(*args)
    :old_fresh_when
  end

  include ::Ettu::FreshWhen
end

class Digestor
  def self.method_missing(name, *args, &block)
    args.first.to_s + '.digest'
  end
end

class Record
  attr_accessor :updated_at

  def initialize(updated_at)
    @updated_at = updated_at
  end
end

module Rails
  module VERSION
    MAJOR = ''
  end
  def self.application
    @nested ||= Nester.new
  end
end
Rails.application.assets['application.js'].digest = 'application.js.digest'
Rails.application.assets['application.css'].digest = 'application.css.digest'
Rails.application.assets['custom.js'].digest = 'custom.js.digest'
Rails.application.assets['custom.css'].digest = 'custom.css.digest'
Rails.application.assets['first.ext'].digest = 'first.ext.digest'
Rails.application.assets['second.ext'].digest = 'second.ext.digest'
Rails.application.config.assets.digests = nil

module ActionView
  class Base
    def self.assets_manifest
      @nested ||= Nester.new
    end
  end
end
ActionView::Base.assets_manifest.assets = {}

