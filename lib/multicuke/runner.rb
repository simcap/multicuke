require 'fileutils'
require 'builder'

module Multicuke
  
  class Runner

    attr_accessor :features_dir_path
    attr_accessor :output_dir_name
    attr_accessor :output_path
    attr_accessor :excluded_dirs, :reports_path
    attr_reader :features_dirs_to_run

    def initialize
      yield self if block_given?

      @output_dir_name = "cucumber_reports" unless output_dir_name
      @output_path = "" unless output_path
      @excluded_dirs = [] unless excluded_dirs
      @reports_path = File.join(output_path, output_dir_name)
    end

    def start
      FileUtils.mkdir_p reports_path
      index_file_path = File.join(reports_path, "index.html")
      index_file = File.new(index_file_path, "w")

      b = Builder::XmlMarkup.new :target => index_file, :indent => 2
      b.html {
        b.head { 
          b.title("Cucumber reports") 
          b.style(css_content)
        }
        b.body {
          b.ul {
            features_dirs_to_run.each { |dir_name|
                b.li { b.a(dir_name, :href => "#{dir_name}.html") }              
            }
          }
        }
      }      

      index_file.close
    end

    private 

    def css_content
      <<-CSS       
        body { }
      CSS
    end

    def match_excluded_dirs(path)
      path.match(Regexp.new(excluded_dirs.join("|")))
    end

    def features_dirs_to_run
      @features_dirs_to_run ||= Dir.glob(File.join(features_dir_path, "*")).reject{ |path|
        File.file?(path) || match_excluded_dirs(path)
      }.map { |feature_path|
        File.basename(feature_path)
      }
    end

  end

end