module Ettu
  class Railtie < Rails::Railtie
    config.ettu = ActiveSupport::OrderedOptions.new

    initializer 'load' do |app|

      unless app.config.ettu.disabled
        require 'ettu'
        ActiveSupport.on_load :action_controller do
          ActionController::Base.send :include, FreshWhen
        end

        if app.config.ettu.development_hack
          class BlackHole < Hash
            def []=(k, v); end
          end
          module ::ActionView
            class Digestor
              @@cache = BlackHole.new
            end
          end
        end

      end
    end
  end
end
