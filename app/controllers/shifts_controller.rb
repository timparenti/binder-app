class ShiftsController < ApplicationController
  load_and_authorize_resource skip_load_resource only: [:create]
  before_action :set_shift, only: [:show, :edit, :update, :destroy]

  include CSVImportExport
  before_filter :set_csv_descriptor, :only => [:index, :import]

  # GET /shifts
  # GET /shifts.json
  # Regular index is watch shifts by default
  def index
    unless ( params[:organization_id].blank? )
      @organization = Organization.find(params[:organization_id])
      @shifts = @organization.shifts
    else
      @shifts = Shift
    end

    if (params[:type].blank?)
      @title = "Shifts"
      @shifts = @shifts
    elsif (params[:type] == "watch")
      @title = "Watch Shifts"
      @shifts = @shifts.watch_shifts
    elsif (params[:type] == "security")
      @title = "Security Shifts"
      @shifts = @shifts.sec_shifts
    elsif (params[:type] == "coordinator")
      @title = "Coordinator Shifts"
      @shifts = @shifts.coord_shifts
    end

    @shifts = @shifts.paginate(:page => params[:page]).per_page(20)

    respond_to do |format|
      format.html
      authorize! :export, Shift
      format.csv { send_data CSVImportExport.to_csv(Shift, @csv_attributes, @csv_dependents), filename: "shifts-#{Date.today}.csv" }
    end
  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
    @number_spots_left = @shift.required_number_of_participants - @shift.shift_participants.count
  end

  # GET /shifts/new
  # GET /shifts/new.json
  def new
    @shift = Shift.new
  end

  # GET /shifts/1/edit
  def edit
  end

  # POST /shifts
  # POST /shifts.json
  def create
    @shift = Shift.new(shift_params)
    @shift.save
    respond_with(@shift)
  end

  # PUT /shifts/1
  # PUT /shifts/1.json
  def update
    @shift.update(shift_params)
    respond_with(@shift)
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
    @shift.destroy
    respond_with(@shift)
  end

  def import
    authorize! :import, Shift

    if params[:delete_all_shifts] then Shift.delete_all end
    status = CSVImportExport.from_csv(Shift, @csv_attributes, @csv_dependents, params[:file])
    message = CSVImportExport.as_message(Shift, status)

    redirect_to :back, :flash => message
  end

  private

  def set_shift
    @shift = Shift.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:starts_at, :ends_at, :shift_type_id, :organization_id, :required_number_of_participants, :description)
  end

  def set_csv_descriptor
    @csv_attributes = ["id", "starts_at", "ends_at", "description", "required_number_of_participants"]
    @csv_dependents = [ [ShiftType, lambda { | t | t.shift_type }, ["name"], ["shift_type"], "name"],
                        [Organization, lambda { | t | t.organization }, ["name"], ["organization"], "name"] ]
  end
end
