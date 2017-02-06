require "sinatra"
require 'RMagick'

module BoilerPlace
  class App < Sinatra::Base
    configure do
      set :logging, true
    end

    set :hostname, ENV['HOST']
    set :ga, ENV['GA']

    not_found do
      erb :notfound, :layout => :layout
    end

    get "/" do
      erb :index, :layout => :layout
    end

    get "/assets/style.css" do
      send_file "assets/style.css"
    end

    get "/:width/:height/?" do
      width = params[:width]
      height = params[:height]
      halt 400 unless valid_params width, height
      if (valid_params(width, height))
        send_file generate_file_name(width, height)
      else
        halt 400
      end
    end

    private
      def generate_file_name(width, height)
        sample_name = Dir.glob("source/*.jpg").sample
        candidate_name = File.basename(sample_name, ".jpg").to_s
        candidate_path = ["output/", candidate_name, "-", width, "-", height, ".jpg"].join
        if (FileTest.exist?(candidate_path))
          candidate_path # File already exists, send em the cached version
        else
          generate_file(width, height, candidate_path, sample_name)
        end
      end

      def generate_file(width, height, path, name)
        image = Magick::Image.read(name).first
        image = image.resize_to_fill(width.to_i, height.to_i)
        image.write(path)
        send_file path
      end

      def valid_params(width, height)
        if !(width.to_i.to_s === width && width.to_i > 0 && width != nil)
          halt 400, "Width is not a number"
        elsif !(height.to_i.to_s === height && height.to_i > 0 && height != nil)
          halt 400, "Height is not a number"
        else
          true
        end
      end
  end
end
