# ## Schema Information
#
# Table name: `shifts`
#
# ### Columns
#
# Name                                   | Type               | Attributes
# -------------------------------------- | ------------------ | ---------------------------
# **`created_at`**                       | `datetime`         |
# **`description`**                      | `string(255)`      |
# **`ends_at`**                          | `datetime`         |
# **`id`**                               | `integer`          | `not null, primary key`
# **`organization_id`**                  | `integer`          |
# **`required_number_of_participants`**  | `integer`          |
# **`shift_type_id`**                    | `integer`          |
# **`starts_at`**                        | `datetime`         |
# **`updated_at`**                       | `datetime`         |
#
# ### Indexes
#
# * `index_shifts_on_organization_id`:
#     * **`organization_id`**
#

class Shift < ActiveRecord::Base
  validates_presence_of :starts_at, :ends_at, :required_number_of_participants, :shift_type
  validates_associated :organization, :shift_type

  belongs_to :organization
  belongs_to :shift_type

  has_many :participants, :through => :shift_participants
  has_many :shift_participants, :dependent => :destroy

  default_scope { order('starts_at asc') }
  scope :current, lambda { where("starts_at < ? and ends_at > ?", Time.zone.now, Time.zone.now ) }
  scope :future, lambda { where("starts_at > ?", Time.zone.now ) }
  scope :upcoming, lambda { where("starts_at > ? and starts_at < ?", Time.zone.now, Time.zone.now + 4.hours ) }
  scope :past, lambda { where("ends_at < ?", Time.zone.now) }
  scope :missed, lambda { where("required_number_of_participants > (
                                    SELECT COUNT(*)
                                    FROM shift_participants
                                    WHERE shift_participants.shift_id = shifts.id)")}

  #scopes for each type of shift, selected by their shift_type ID
  scope :watch_shifts, -> { where('shift_type_id = ?', 1) }
  scope :sec_shifts, -> { where('shift_type_id = ?', 2) }
  scope :coord_shifts, -> { where('shift_type_id = ?', 3) }

  def formatted_name
    if organization.blank?
      shift_type.name + " @ " + starts_at.strftime("%b %e at %l:%M %p")
    else
      shift_type.name + " @ " + starts_at.strftime("%b %e at %l:%M %p") + ' - ' +  organization.name
    end
  end

  def is_checked_in
    return participants.size == required_number_of_participants
  end

  def self.to_csv
    shift_attributes = ["id", "starts_at", "ends_at", "description", "required_number_of_participants"]
    shift_attributes_names = shift_attributes
    shift_type_attributes = ["name"]
    shift_type_attributes_names = ["shift_type"]
    organization_attributes = ["name"]
    organization_attributes_names = ["organization"]

    CSV.generate(headers: true) do |csv|
      csv.add_row shift_attributes_names + shift_type_attributes_names + organization_attributes_names

      all.each do |x|
        values = x.attributes.values_at(*shift_attributes)
        values += x.shift_type.attributes.values_at(*shift_type_attributes)
        values += x.organization.attributes.values_at(*organization_attributes)
        csv.add_row values
      end
    end
  end

  def self.from_csv(file)
    created = 0
    updated = 0

    CSV.foreach(file.path, :headers => true, :encoding => 'ISO-8859-1') do |row|
      shift_type = ShiftType.find_by_name(row["shift_type"]) || ShiftType.new
      shift_type_attributes = row.to_hash.slice(*["shift_type"])
      shift_type_attributes["name"] = shift_type_attributes.delete "shift_type"
      shift_type.attributes = shift_type_attributes
      shift_type.save!

      organization = Organization.find_by_name(row["organization"]) || Organization.new
      organization_attributes = row.to_hash.slice(*["organization"])
      organization_attributes["name"] = organization_attributes.delete "organization"
      organization.attributes = organization_attributes
      organization.save!

      shift = find_by_id(row["id"]) || new
      row_shift = row.to_hash.slice(*["id", "starts_at", "ends_at", "description", "required_number_of_participants"])
      if shift.id.to_s == row["id"].to_s
        shift_attributes = shift.attributes.keep_if { |k,v| row_shift.key? k }
        shift_attributes = shift_attributes.map { |k,v| [k,v.to_s] }.to_h
        row_shift = row_shift.map { |k,v| [k,v.to_s] }.to_h # for nil descriptions
        if shift_attributes != row_shift || shift.shift_type_id != shift_type.id || shift.organization_id != organization.id
          updated += 1
        end
      else
        created += 1
      end
      shift_attributes = row_shift
      shift_attributes["shift_type_id"] = shift_type.id
      shift_attributes["organization_id"] = organization.id
      shift.attributes = shift_attributes
      shift.save!
    end

    return {:updated => updated, :created => created, :changes => updated + created}
  end
end
