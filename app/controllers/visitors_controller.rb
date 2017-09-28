class VisitorsController < ApplicationController

  def index
    YAML.load_file('config/ryanair_september.yml')
  end
end
