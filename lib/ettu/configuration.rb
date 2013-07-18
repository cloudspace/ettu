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

      self.template_digestor = ActionView::Digestor
    end

    class LateLoadAssets
      def initialize(config, name)
        @config = config
        @name = name
      end

      def method_missing(method, *args, &block)
        assets = Array.new(defaults)
        @config[@name] = array
        assets.send method, *args, &block
      end

      private

      def defaults
        ::ActionView::Base.assets_manifest.assets.keys
      end
    end
  end
end
