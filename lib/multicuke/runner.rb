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
      @scenarios_results = ""
      @steps_results = ""
    end

    # True if one feature has failed
    def failed?
      (scenarios_results.include?"failed") || (steps_results.include?"failed")
    end

    # Human readable name used for index page (ex: user_logout --> User logout) 
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

    # Optional only the features directories to be included
    attr_accessor :included_only_dirs

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
      @included_only_dirs = [] unless included_only_dirs
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
        
          features_dir.scenarios_results = scenarios
          features_dir.steps_results = steps
          features_dir.duration = duration
        } if File.exists?(feature_file)
      }
    end

    def features_dirs
      @features_dirs ||= resolve_features_dirs_name
    end

    def resolve_features_dirs_name
      Dir.glob(File.join(features_root_path, "*", "*.feature")).select{ |path|
        configured_dir?(path)
      }.map { |feature_path|
        dir_name = File.basename(File.dirname(feature_path))
        FeaturesDir.new(dir_name)
      }
    end

    def configured_dir?(path)
      if included_only_dirs.empty?
        included_dir?(path)
      else
        path.match(Regexp.new(included_only_dirs.join("|")))
      end
    end

    def included_dir?(path)
      excluded_dirs.empty? || (not path.match(Regexp.new(excluded_dirs.join("|"))))
    end

  end

end