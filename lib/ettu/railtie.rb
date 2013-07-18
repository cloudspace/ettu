class Ettu
  class Railtie < Rails::Railtie
    config.ettu = ActiveSupport::OrderedOptions.new
    initializer 'load' do |app|

      unless app.config.ettu.disabled
        require 'ettu'
        if app.config.ettu.development_hack

          class BlackHole < Hash
            def []=(k, v); end
          end
          module EtagBuster
            extend ActiveSupport::Concern
            included do
              def fresh_when(*args); end
            end
          end

          module ::ActionView
            class Digestor
              @@cache = BlackHole.new
            end
          end
          ActiveSupport.on_load :action_controller do
            ActionController::Base.send :include, EtagBuster
          end

        else

          ActiveSupport.on_load :action_controller do
            ActionController::Base.send :include, FreshWhen
          end

        end
      end

    end
  end
end
