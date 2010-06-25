class MockTurtle::MockupsController < ActionController::Base

  layout false

  def show
    path = (Rails.root + 'app/views' + (params[:path].ends_with?('.html.mock') ?
            params[:path] : "#{params[:path]}.html.mock")).to_s
    render :text         => MockTurtle.mockups[path].source,
           :content_type => 'text/html'
  end

end