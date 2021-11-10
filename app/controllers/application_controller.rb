class ApplicationController < ActionController::Base
  def hello
    render html: "Hello, sample-app"
  end
end
