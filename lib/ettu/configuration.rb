class Ettu
  class Configuration < ActiveSupport::OrderedOptions
    def initialize
      super

      self.js = 'application.js'
      self.css = 'application.css'
      self.assets = []

      # Don't actually set view by default.
      # This'll allow #fetch to return the real default
      # at runtime.
      # self.view = nil

      if defined? ActionView::Digestor
        self.template_digestor = ActionView::Digestor
      end
    end
  end
end
