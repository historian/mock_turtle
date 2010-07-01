class MockTurtle::Railtie < Rails::Engine

  initializer "mock_turtle.register_handler" do
    ActionView::Template.register_template_handler(:bind, MockTurtle::Handler)
  end

  config.to_prepare do
    MockTurtle.load!
  end

end