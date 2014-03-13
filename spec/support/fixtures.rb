class Nester < ActiveSupport::OrderedOptions
  def initialize
    super { |h, k| h[k] = Nester.new }
  end
end

class Controller < Nester
  def initialize
    super

    self.request.format = 'html'
    self.controller_name = 'controller_name'
    self.action_name = 'action_name'
    self.template_digestor = ::ActionView::Digestor
  end

  module Freshness
    def fresh_when(*args)
      [*args]
    end
  end
  include Freshness

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