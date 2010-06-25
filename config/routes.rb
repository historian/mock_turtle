Rails::Application.routes.draw do |map|

  if Rails.env.development?
    match '/mockups/*path', :to => 'mock_turtle/mockups#show'
  end

end