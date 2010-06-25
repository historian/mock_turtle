class MockTurtle::Railtie < Rails::Railtie

  # config.mock_turtle = ActiveSupport::OrderedOptions.new

  initializer "mock_turtle.register_handler" do
    ActionView::Template.register_template_handler(:mock, MockTurtle::Handler)
  end

  config.to_prepare do
    MockTurtle.load!
  end

end