module CSVImportExport

  def self.to_csv(object, attributes, dependents)
    CSV.generate(headers: true) do |csv|
      header = attributes
      dependents.each do | dependent |
        (_, _, _, dependent_names) = dependent
        header += dependent_names
      end
      csv.add_row header

      object.all.each do | item |
        values = item.attributes.values_at(*attributes)
        dependents.each do | dependent |
          (_, get_dependent, dependent_attributes, _, _) = dependent
          values += get_dependent.call(item).attributes.values_at(*dependent_attributes)
        end
        csv.add_row values
      end
    end
  end


  # (object, get_from_main_obj, attributes, names)
  def self.from_csv(object, attributes, dependents, file)
    created = 0
    updated = 0

    CSV.foreach(file.path, :headers => true, :encoding => 'ISO-8859-1') do |row|

      dependents.each do | dependent |
        (dependent_object, _, dependent_attributes, dependent_names, dependent_link) = dependent
        link_attribute = dependent_names[dependent_attributes.index(dependent_link)]
        dependent_item = dependent_object.find_by(dependent_link.to_sym => row[link_attribute]) || dependent_object.new
        dependent_attributes = row.to_hash.slice(*dependent_names)
        dependent_attributes[dependent_link] = dependent_attributes.delete link_attribute
        dependent_item.attributes = dependent_attributes
        dependent_item.save!
      end

      item = object.find_by_id(row["id"]) || object.new

      row_item = row.to_hash.slice(*attributes)
      if item.id.to_s == row["id"].to_s
        item_attributes = item.attributes.keep_if { |k,v| row_item.key? k }
        item_attributes = item_attributes.map { |k,v| [k,v.to_s] }.to_h
        row_item = row_item.map { |k,v| [k,v.to_s] }.to_h # for nil descriptions

        different_dependents = false
        dependents.each do | dependent |
          (dependent_object, _, dependent_attributes, dependent_names, dependent_link) = dependent
          link_attribute = dependent_names[dependent_attributes.index(dependent_link)]
          different_dependents = different_dependents || (item["#{dependent_object.name.underscore}_id"] != dependent_object.find_by(dependent_link.to_sym => row[link_attribute]).id)
        end

        if item_attributes != row_item || different_dependents
          updated += 1
        end
      else
        created += 1
      end

      item_attributes = row_item
      dependents.each do | dependent |
        (dependent_object, _, dependent_attributes, dependent_names, dependent_link) = dependent
        link_attribute = dependent_names[dependent_attributes.index(dependent_link)]
        dependent_item = dependent_object.find_by(dependent_link.to_sym => row[link_attribute]) # Now garunteed to succede!
        item_attributes["#{dependent_object.name.underscore}_id"] = dependent_item.id
      end
      item.attributes = item_attributes
      item.save!
    end

    return { :updated => updated, :created => created }
  end

  def self.as_message(object, status)
    object_name = object.name.humanize.downcase.pluralize
    if status[:updated] + status[:created] == 0
      message = { :error => "No new #{object_name} were created or updated." }
    else
      message = { :notice => "Successfully created #{status[:created]} new #{object_name} and updated #{status[:updated]} old #{object_name}." }
    end
  end

end
