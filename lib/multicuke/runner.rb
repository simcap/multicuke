require 'fileutils'
require 'builder'
require 'nokogiri'
require 'ostruct'

module Multicuke
  
  class Runner

    attr_accessor :features_dir_path
    attr_accessor :output_dir_name
    attr_accessor :output_path
    attr_accessor :excluded_dirs, :reports_path, :dry_run
    attr_reader :features_dirs_to_run

    def initialize
      yield self if block_given?

      @dry_run = false if dry_run.nil?
      @output_dir_name = "cucumber_reports" unless output_dir_name
      @output_path = "" unless output_path
      @excluded_dirs = [] unless excluded_dirs
      @reports_path = File.join(output_path, output_dir_name)
    end

    def start
      FileUtils.mkdir_p reports_path
      index_file_path = File.join(reports_path, "index.html")
      index_file = File.new(index_file_path, "w")

      unless dry_run
        features_dirs_to_run.each { |dir_name|
          report_file_path = File.join(reports_path, "#{dir_name}.html")
          feature_full_path = File.join(features_dir_path, "#{dir_name}")
          fork {
            command = "bundle exec cucumber #{feature_full_path} -r #{features_dir_path} --format html --out #{report_file_path}"
            p "RUNNING #{command}"
            system command
          } 

          p Process.waitall         
        }
      end

      features = {}

      features_dirs_to_run.each { |dir_name|
        File.open(File.join(reports_path, "#{dir_name}.html")) { |file|
          content = file.read
          duration = content.match(/Finished in\s+<\w+>(.*?)</).captures.first
          scenarios = content.match(/\d+ scenarios? \((.*?)\)/).captures.first
          steps = content.match(/\d+ steps? \((.*?)\)/).captures.first
        
          features[dir_name] = OpenStruct.new(:scenarios => scenarios, :steps => steps, :duration => duration)
        }

      }

      b = Builder::XmlMarkup.new :target => index_file, :indent => 2
      b.html {
        b.head { 
          b.title("Cucumber reports") 
          b.style(css_content)
        }
        b.body {
          b.h2("Features")
          b.ul {
            features_dirs_to_run.each { |dir_name|
                b.li { 
                  b.a(dir_name, :href => "#{dir_name}.html") 
                  b.span("[#{features[dir_name].duration}]", :class => "duration")                              
                  b.span("Scenarios: #{features[dir_name].scenarios}, Steps: #{features[dir_name].steps}")
                }              
            }
          }
        }
      }      

      index_file.close
    end

    private 

    def css_content
      <<-CSS       
        body {font-family: "Lucida Grande", Helvetica, sans-serif; margin: 2em 8em 2em 8em;}
        ul {list-style-type: square;} 
        li {margin: 1em 0 1em 0;}
        li span {float: right; margin-left: 1em;}
        .duration {font-family: ‘Lucida Console’, Monaco, monospace;}
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