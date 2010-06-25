module MockTurtle

  require 'mock_turtle/version'
  require 'mock_turtle/railtie'
  require 'mock_turtle/handler'
  require 'mock_turtle/template'
  require 'mock_turtle/mockup'

  def self.load!
    app      = Rails.application
    railties = [app] + app.railties.all

    view_dirs = railties.collect do |railtie|
      railtie.paths.app.views.to_a rescue []
    end.flatten

    @mockups = {}
    view_dirs.collect do |view_dir|
      glob_pattern = File.join(view_dir, '**/*.mock')
      Dir.glob(glob_pattern).collect do |path|
        cs = MockTurtle::Mockup.new(
          File.read(path), File.expand_path(path))
        @mockups[cs.path] = cs
        cs.compile!
      end
    end
  end

  def self.mockups
    @mockups || begin
      load!
      @mockups
    end
  end

  def self.templates
    @templates || begin
      templates = {}
      self.mockups.each do |name, mockup|
        templates.merge!(mockup.templates)
      end
      templates
    end
  end

end