require 'action_view/template'

class MockTurtle::Template < ActionView::Template

  attr_reader :fragment

  def initialize(source, fragment, identifier, handler, details)
    @fragment = fragment
    super(source, identifier, handler, details)
  end

end