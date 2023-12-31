module Devices
  module Seeders
    class DemoAccountSeeder < AbstractSeeder
      BASE_URL = "/app-resources/img/demo_accounts/"
      FEEDS = {
        "Express XL" => "Express_XL_Demo_Webcam.JPG",
        "Express" => "Express_Demo_Webcam.JPG",
        "Genesis XL" => "Genesis_XL_Demo_Webcam.jpg",
        "Genesis" => "Genesis_Demo_Webcam.jpg",
      }
      UNUSED_ALERTS = ["api.seed_data.missing", "api.user.not_welcomed"]

      def feed(product_line)
        feed_name = ""
        feed_name += "Genesis" if product_line.include?("genesis")
        feed_name += "Express" if product_line.include?("express")
        feed_name += " XL" if product_line.include?("xl")
        feed_name
      end

      def create_webcam_feed(product_line)
        feed_name = feed(product_line)
        WebcamFeeds::Create.run!({ name: feed_name,
                                   url: BASE_URL + FEEDS[feed_name],
                                   device: device })
      end

      def plants
        PLANTS.map { |x| Points::Create.run!(x, device: device) }
      end

      def point_groups_spinach
        add_point_group(name: "Spinach plants", openfarm_slug: "spinach")
      end

      def point_groups_broccoli
        add_point_group(name: "Broccoli plants", openfarm_slug: "broccoli")
      end

      def point_groups_beet
        add_point_group(name: "Beet plants", openfarm_slug: "beet")
      end

      MARKETING_BULLETIN = GlobalBulletin.find_or_create_by(slug: "buy-a-farmbot") do |gb|
        gb.href = "https://farm.bot"
        gb.href_label = "Visit our website"
        gb.slug = "buy-a-farmbot"
        gb.title = "Buy a FarmBot"
        gb.type = "info"
        gb.content = [
          "Ready to get a FarmBot of your own? Check out our website to",
          " learn more about our various products. We offer FarmBots at",
          " all different price points, sizes, and capabilities so you'",
          "re sure to find one that suits your needs.",
        ].join("")
      end

      DEMO_ALERTS = [
        Alert::DEMO,
        Alert::BULLETIN.merge(slug: "buy-a-farmbot", priority: 9999),
      ]

      DEMO_LOGS = [
        {message: "Your FarmBot says hi!", type: "fun", verbosity: 3},
      ]

      # Note: At the time of publish, FBOS v8.0.0
      # was the latest release. We are setting
      # demo accounts to v100 because:
      #  * We don't want to update this value
      #    on every FBOS release.
      #  * We don't want demo users hitting bugs
      #    by setting their account to the beta
      #    tester FBOS version `1000.0.0`.
      READ_COMMENT_ABOVE = "100.0.0"

      def misc(product_line)
        create_webcam_feed(product_line)
        plants
        point_groups_spinach
        point_groups_broccoli
        point_groups_beet

        device.alerts.where(problem_tag: UNUSED_ALERTS).destroy_all
        DEMO_ALERTS
          .map { |p| p.merge(device: device) }
          .map { |p| Alerts::Create.run!(p) }
        DEMO_LOGS
          .map { |p| p.merge(device: device) }
          .map { |p| Logs::Create.run!(p) }
        device
          .update!(fbos_version: READ_COMMENT_ABOVE)
        device
          .web_app_config
          .update!(discard_unsaved: true)
      end
    end
  end
end
