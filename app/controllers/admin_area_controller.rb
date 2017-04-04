class AdminAreaController < ApplicationController

  load_and_authorize_resource :class => AdminAreaController
  before_action :set_models

  def index
  end

  private

  def set_models
    @models = [ Tool, Shift, Organization, Membership ]
  end

end
