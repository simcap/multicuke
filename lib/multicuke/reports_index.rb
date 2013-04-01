module Multicuke

  # Generate the index page reporting on the features and their status.
  # Provides the links to the actual full Cucumber html reports.
  class ReportsIndex

    # Collection of ran features directories results used for reporting
    attr_reader :features_dirs

    # Full path for the index html file
    attr_reader :index_path

    def initialize(reports_path, features_dirs)
      @features_dirs = features_dirs
      @index_path = File.join(reports_path, "index.html")
    end
    
    def generate      
      index_file = File.new(index_path, "w")

      b = Builder::XmlMarkup.new :target => index_file, :indent => 2
      b.html {
        b.head { 
          b.title("Cucumber reports") 
          b.style(css_content)
        }
        b.body {
          b.h2("Features")
          b.ul {
            features_dirs.each { |features_dir|
                b.li(:class => (features_dir.failed? ? "failed" : "success")) { 
                  b.a(features_dir.human_name, :href => "#{features_dir.name}.html") 
                  b.span("[#{features_dir.duration}]", :class => "duration")                              
                  b.span("Scenarios: #{features_dir.scenarios_results}, Steps: #{features_dir.steps_results}", :class => "result")
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
        li span {float: right; margin-left: 1em; padding: 0 0.3em;}
        li.failed span.result{background: #DC6E6E;}
        li.success span.result{background: #C1E799;}
        span.duration {color: #999999;}
      CSS
    end

  end
end