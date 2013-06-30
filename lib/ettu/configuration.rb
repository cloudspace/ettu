class Ettu
  class Configuration < ActiveSupport::OrderedOptions
    def initialize
      super
      set_defaults
    end

    def reset
      set_defaults
    end

    private

    def set_defaults
      self.js = 'application.js'
      self.css = 'application.css'
      self.assets = []

      # Don't actually set view by default.
      # This'll allow #fetch to return the real default
      # at runtime.
      # self.view = "#{controller_name}/#{action_name}"
      delete :view if key? :view

      if defined? ActionView::Digestor
        self.template_digestor = ActionView::Digestor
      end
    end
  end
end
