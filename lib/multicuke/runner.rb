require 'fileutils'
require 'builder'
require 'nokogiri'
require 'multicuke/reports_index'

module Multicuke

  # Set of features under one specific directory
  class FeaturesDir

    # Directory name fo the features
    attr_reader :name

    # Result string for passed/failed scenarios
    attr_accessor :scenarios_results

    # Result string for passed/failed steps
    attr_accessor :steps_results

    # Running time in ms for all features in this feature directory
    attr_accessor :duration

    # True if a scenario or step has failed for this set of features
    attr_writer :failed

    def initialize(dir_name)
      @name = dir_name
      @failed = false
    end

    def failed?
      @failed
    end

    def human_name
      name.gsub(/[_-]/, " ").capitalize
    end
    
  end

  # Actual clas that will spawn one command process per directory of features collected
  # according to configuration
  class Runner

    # Root path to your features directory
    attr_accessor :features_root_path

    # Optional name for directory containing the reports
    attr_accessor :output_dir_name

    # Optional full path for generated reports. Default to where it is run from.
    attr_accessor :output_path

    # Optional features directories to exclude
    attr_accessor :excluded_dirs

    # Full final path where html reports will be generated
    attr_reader :reports_path

    # Optional. If true will generate index file but not launch processes. Used for testing.
    attr_accessor :dry_run

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
      launch_process_per_dir
      collect_results
      reports = ReportsIndex.new(reports_path, features_dirs).generate
      puts "See reports index at #{reports.index_path}" if reports
    end

    private

    def launch_process_per_dir
      unless dry_run
        features_dirs.each { |features_dir|
          report_file_path = File.join(reports_path, "#{features_dir.name}.html")
          feature_full_path = File.join(features_root_path, "#{features_dir.name}")
          fork {
            main_command = %W[bundle exec cucumber #{feature_full_path}]
            options = %W[-r #{features_root_path} --format html --out #{report_file_path}]
            full_command = main_command + options
            result = system *full_command
            puts "Features '#{features_dir.name}' finished. #{result ? 'SUCCESS' : 'FAILURE'} (pid: #{Process.pid})"
          } 
        }
        Process.waitall
      end
    end

    def collect_results
      features_dirs.each { |features_dir|
        feature_file = File.join(reports_path, "#{features_dir.name}.html")
        File.open(feature_file) { |file|
          content = file.read
          duration_match = content.match(/Finished in\s+<\w+>(.*?)</)
          duration = duration_match ? duration_match.captures.first : ""
          scenarios_match = content.match(/\d+ scenarios? \((.*?)\)/)
          scenarios =  scenarios_match ? scenarios_match.captures.first : ""
          steps_match = content.match(/\d+ steps? \((.*?)\)/)
          steps =  steps_match ? steps_match.captures.first : ""
          failed = (scenarios.include?"failed") || (steps.include?"failed")
        
          features_dir.scenarios_results = scenarios
          features_dir.steps_results = steps
          features_dir.duration = duration
          features_dir.failed = failed
        } if File.exists?(feature_file)
      }
    end

    def match_excluded_dirs(path)
      path.match(Regexp.new(excluded_dirs.join("|")))
    end

    def features_dirs
      @features_dirs ||= find_features_dirs
    end

    def find_features_dirs
      @features_dirs = []
      Dir.glob(File.join(features_root_path, "*")).reject{ |path|
        File.file?(path) || match_excluded_dirs(path)
      }.map { |feature_path|
        File.basename(feature_path)
      }.each { |dir_name|
        @features_dirs << FeaturesDir.new(dir_name)
      }
      @features_dirs      
    end

  end

end