class Ettu
  class Railtie < Rails::Railtie
    config.ettu = ActiveSupport::OrderedOptions.new

    initializer 'load' do |app|

      unless app.config.ettu.disabled
        require 'ettu'
        ActiveSupport.on_load :action_controller do
          ActionController::Base.send :include, FreshWhen
        end
      end

    end
  end
end
