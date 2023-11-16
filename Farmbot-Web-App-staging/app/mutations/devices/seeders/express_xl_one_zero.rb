module Devices
  module Seeders
    class ExpressXlOneZero < AbstractExpress
      def settings_device_name
        device.update!(name: Names::EXPRESS_XL)
      end

      def settings_firmware
        device
          .fbos_config
          .update!(firmware_hardware: FbosConfig::EXPRESS_K10)
      end

      def settings_default_map_size_x
        device.web_app_config.update!(map_size_x: 6_000)
      end

      def settings_default_map_size_y
        device.web_app_config.update!(map_size_y: 2_400)
      end
    end
  end
end
