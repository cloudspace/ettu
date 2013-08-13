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
      self.assets = LateLoadAssets.new

      # Don't actually set view by default.
      # This'll allow #fetch to return the real default
      # at runtime.
      # self.view = "#{controller_name}/#{action_name}"
      delete :view if key? :view

      # Don't attempt to reset the template_digestor
      # if one has already been found
      unless self.template_digestor
        self.template_digestor = LateLoadTemplateDigestor.new(self)
      end
    end

    class LateLoadAssets
      def to_a
        ::Rails.application.config.assets.digests.keys
      end
    end

    class LateLoadTemplateDigestor
      def initialize(config)
        @config = config
      end

      def digest(*args)
        digestor = attempt_late_template_digestor_set
        digestor.digest(*args)
      end

      private

      def attempt_late_template_digestor_set
        unless defined? CacheDigests::TemplateDigestor
          # Attempt to load cache_digets
          require 'cache_digests'
        end
        # Attempt to use CacheDigests::TemplateDigestor on Rails 3
        @config.template_digestor = CacheDigests::TemplateDigestor
      rescue LoadError
        raise "Ettu requires the cache_digests gem in Rails v#{Rails::VERSION::STRING}"
      end
    end
  end
end
