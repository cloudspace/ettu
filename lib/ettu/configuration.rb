class Ettu
  class Configuration < ActiveSupport::OrderedOptions
    def initialize
      super
      set_defaults
    end

    def reset
      set_defaults
    end

    def attempt_late_template_digestor_set
      if defined? ActionView::Digestor
        # Attempt to use ActionView::Digestor on Rails 4
        self.template_digestor = ActionView::Digestor
      elsif defined? CacheDigests::TemplateDigestor
        # Attempt to use CacheDigests::TemplateDigestor on Rails 3
        self.template_digestor = CacheDigests::TemplateDigestor
      end
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

      attempt_late_template_digestor_set
    end
  end
end
