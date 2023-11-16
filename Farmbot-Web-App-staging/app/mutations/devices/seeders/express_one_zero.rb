module Devices
  module Seeders
    class ExpressOneZero < AbstractExpress
      def settings_firmware
        device
          .fbos_config
          .update!(firmware_hardware: FbosConfig::EXPRESS_K10)
      end
    end
  end
end
