require 'multicuke/reports_index'

module Multicuke

  # Wrapper of {Kernel#system} method for test/mock
  class SystemCommand

    def run(full_command_as_array)
      system *full_command_as_array
    end

    def exit(status = 0)
      Kernel.exit(status == 0)
    end

  end

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

    # Root path to your features directory. Ex: your_project/features
    attr_accessor :features_root_path

    # Optional name for directory containing the reports. Default to 'cucumber_reports'
    attr_accessor :output_dir_name

    # Optional full path for generated reports. Default to ../{features_root_path}.
    attr_accessor :output_path

    # Optional regexp for name of features directories to exclude.
    attr_accessor :excluded_dirs

    # Optional only the features directories to be included
    attr_accessor :included_only_dirs

    # Array of extra options to pass to the command. Ex: ["-p", "my_profile", "--backtrace"]
    attr_accessor :extra_options

    # Define the size for the pool of forks. Default is 5
    attr_accessor :forks_pool_size

    # Full final path where html reports will be generated
    attr_reader :reports_path

    # Optional. If true will generate index file but not launch processes. Used for testing.
    attr_accessor :dry_run

    # Add cucumber --require option load *.rb files under features root path by default unless specified to false.
    attr_accessor :require_features_root_option

    # Delegate to a wrapper of system call in order mock/test
    attr_accessor :system_command

    def initialize(features_root)
      @features_root_path = features_root

      yield self if block_given?

      @dry_run = false if dry_run.nil?
      @forks_pool_size ||= 5
      @require_features_root_option = true if require_features_root_option.nil?
      @output_dir_name = "cucumber_reports" unless output_dir_name
      @output_path = File.expand_path("..", features_root_path) unless output_path
      @excluded_dirs ||= []
      @included_only_dirs ||= []
      @extra_options ||= []
      @reports_path = File.join(output_path, output_dir_name)
      @system_command ||= SystemCommand.new
    end

    def start
      FileUtils.mkdir_p reports_path
      exit_status = launch_process_per_dir
      collect_results
      reports = ReportsIndex.new(reports_path, features_dirs).generate
      puts "See reports index at #{reports.index_path}" if reports
      system_command.exit(exit_status)
    end

    private

    def launch_process_per_dir
      if dry_run
        0
      else
        results = features_dirs.forkoff!(:processes => forks_pool_size){ |features_dir|
            report_file_path = File.join(reports_path, "#{features_dir.name}.html")
            feature_full_path = File.join(features_root_path, "#{features_dir.name}")
            main_command = %W[bundle exec cucumber #{feature_full_path}]
            options = %W[--format html --out #{report_file_path}]
            options.concat %W[--require #{features_root_path}] if require_features_root_option
            full_command = main_command + options + extra_options
            result = system_command.run full_command
            puts "Features '#{features_dir.name}' finished. #{result ? 'SUCCESS' : 'FAILURE'} (pid: #{Process.pid})"
            result
        }
        global_exit_status = results.inject(0) { |acc, result|
          result ? acc : acc +1
        }
        puts "Global exit status = #{global_exit_status}"
        global_exit_status
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
      }.uniq { |feature_dir|
        feature_dir.name
      }
    end

    def configured_dir?(path)
      if included_only_dirs.empty?
        included_dir?(path)
      else
        exact_word_match_expressions = included_only_dirs.map { |dir_name|
          "\\b#{dir_name}\\b"
        }
        path.match(Regexp.new(exact_word_match_expressions.join("|")))
      end
    end

    def included_dir?(path)
      excluded_dirs.empty? || (not path.match(Regexp.new(excluded_dirs.join("|"))))
    end

  end

end