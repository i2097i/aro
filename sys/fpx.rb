=begin

  fpx.rb

  aos flie proxy.

  by i2097i

=end

require :"rack/cors".to_s
require :sinatra.to_s

module Aos
  module Fpx
    def self.read_you(you_name)
      url = URI.parse(File.join(Aos::Fpx::Server::URL, :"you/#{you_name}".to_s))
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      res.body
    end

    class Server < Sinatra::Base
      PORT = 7474
      HOST = :localhost
      # no ssl for now
      URL = :"http://#{Aos::Fpx::Server::HOST}:#{Aos::Fpx::Server::PORT}/".to_s
      TIMEOUT = Aro::Mancy::NUMERALS[:VI] * Aro::Mancy::NUMERALS[:X]

      def self.serve_pid_file
        return "" if Aro::Dom.dom_root.nil? || Aro::Dom.room_path(:abot).nil?
        File.join(Aro::Dom.dom_root, Aro::Dom.room_path(:flie), "fpx.pid")
      end

      # def self.log_file
      #   File.new(
      #     File.join(
      #       Aro::Dom.dom_root,
      #       Aro::Dom.room_path(:flie),
      #       "fpx.log"
      #     ),
      #     "a+"
      #   )
      # end

      def self.start
        return if File.exist?(Aos::Fpx::Server.serve_pid_file)

        serve_pid = fork {Aos::Fpx::Server.run!}
        Process.detach(serve_pid)
        File.open(Aos::Fpx::Server.serve_pid_file, "w") do |f|
          f.write(serve_pid)
        end
      end

      def self.stop
        if File.exist?(Aos::Fpx::Server.serve_pid_file)
          system("kill -9 #{File.read(Aos::Fpx::Server.serve_pid_file)}")
          FileUtils.rm(Aos::Fpx::Server.serve_pid_file)
        end
      end

      set :port, Aos::Fpx::Server::PORT
      # set :bind, "0.0.0.0"
      set :server_settings, timeout: Aos::Fpx::Server::TIMEOUT

      # configure do
      #   enable :logging
      #   file = Aos::Fpx::Server.log_file
      #   file.sync = true
      #   use Rack::CommonLogger, file
      #   set :logging, Logger::DEBUG
      # end

      # after do
      #   ActiveRecord::Base.clear_active_connections!
      # end

      use Rack::Cors do |config|
        config.allow do |allow|
          allow.origins Aos::Fpx::Server::HOST.to_s + ":3000"
          allow.resource "*"
          # allow.resource "/file/list_all/", :headers => :any
          # allow.resource "/file/at/*",
          #     :methods => [:get, :post, :put, :delete],
          #     :headers => :any,
          #     :max_age => 0
        end
      end

      get "/" do
        status 200
        "".to_json
      end

      get "/you/:name" do
        Aos::Db.load
        you = Aos::You.find_by(name: params[:name])
        content_type :json
        if you.nil?
          status 404
          "".to_json
        else
          status 200
          you.fpx.to_json
        end
      end

      not_found do
        redirect "/"
      end
    end
  end
end