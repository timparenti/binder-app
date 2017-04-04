class OrganizationsController < ApplicationController
  load_and_authorize_resource

  include CSVImportExport
  before_filter :set_csv_descriptor, :only => [:index, :import]

  # GET /organizations
  # GET /organizations.json
  def index
    if (params[:type] == "building")
      @organizations = @organizations.only_categories(['Fraternity', 'Sorority', 'Independent', 'Blitz', 'Concessions'])
    end

    respond_to do |format|
      format.html
      authorize! :export, Shift
      format.csv { send_data CSVImportExport.to_csv(Organization, @csv_attributes, @csv_dependents), filename: "orgs-#{Date.today}.csv" }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    @booth_chairs = @organization.booth_chairs
    @tools = Tool.checked_out_by_organization(@organization).just_tools
    @shifts = @organization.shifts
    @participants = @organization.participants
    @documents = @organization.documents
    @charges = @organization.charges
  end

  # GET /organizations/new
  # GET /organizations/new.json
  def new
  end

  # GET /organizations/1/edit
  def edit
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization.save
    respond_with(@organization)
  end

  # PUT /organizations/1
  # PUT /organizations/1.json
  def update
    @organization.update(organization_params)
    respond_with(@organization)
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy
    respond_with(@organization)
  end

  def hardhats
    @hardhats = Tool.checked_out_by_organization(@organization).hardhats
  end

  def import
    authorize! :import, Organization

    if params[:delete_all_organizations] then Organization.destroy_all end
    status = CSVImportExport.from_csv(Organization, @csv_attributes, @csv_dependents, params[:file])
    message = CSVImportExport.as_message(Organization, status)

    redirect_to :back, :flash => message
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :short_name, :organization_category_id)
  end

  def set_csv_descriptor
    @csv_attributes = ["id", "name", "short_name"]
    @csv_dependents = [ [OrganizationCategory, lambda { | x | x.organization_category }, ["name"], ["organization_category"], "name"] ]
  end
end
