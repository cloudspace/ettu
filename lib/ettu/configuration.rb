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
      self.assets = LateLoadAssets.new(self, :assets)

      # Don't actually set view by default.
      # This'll allow #fetch to return the real default
      # at runtime.
      # self.view = "#{controller_name}/#{action_name}"
      delete :view if key? :view

      self.template_digestor = LateLoadTemplateDigestor.new(self, :template_digestor)
    end

    class LateLoad
      def initialize(config, name)
        @config = config
        @name = name
      end

      def method_missing(method, *args, &block)
        late_load = defaults
        @config[@name] = late_load
        late_load.send method, *args, &block
      end
    end

    class LateLoadAssets < LateLoad
      def to_a
        super
      end

      def defaults
        ::ActionView::Base.assets_manifest.assets.keys
      end
    end

    class LateLoadTemplateDigestor < LateLoad
      def defaults
        ::ActionView::Digestor
      end
    end
  end
end
