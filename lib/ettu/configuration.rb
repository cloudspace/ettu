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

      self.template_digestor = LateLoadTemplateDigestor.new(self)
    end

    class LateLoadAssets
      def initialize
        @array = []
      end

      def to_a
        ::ActionView::Base.assets_manifest.assets.keys + [*@array]
      end

      def method_missing(method, *args, &block)
        @array.send method, *args, &block
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
        # Attempt to use ActionView::Digestor
        if defined? ActionView::Digestor
          @config.template_digestor = ActionView::Digestor
        end
      end
    end
  end
end
