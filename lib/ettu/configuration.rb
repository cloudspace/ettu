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

      set_template_digestor
    end

    def set_template_digestor
      if defined? ActionView::Digestor
        # Attempt to use ActionView::Digestor on Rails 4
        self.template_digestor = ActionView::Digestor
      else
        # Attempt to use CacheDigests::TemplateDigestor
        require 'cache_digests'
        if defined? CacheDigests::TemplateDigestor
          self.template_digestor = CacheDigests::TemplateDigestor
        end
      end
    rescue LoadError
      raise "Ettu requires the cache_digests gem when using Rails v#{Rails::VERSION::STRING}"
    end
  end
end
