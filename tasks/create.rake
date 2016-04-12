require 'pg_data_encoder'
require 'ruby-progressbar'
require 'sequel'
require 'active_support/core_ext/object/blank'
require 'fias'

namespace :fiasco do  
  # DB = Sequel.connect(ENV['DATABASE_URL'])

  # PREFIX = ENV['PREFIX'] || 'fias'

  # FIAS_ADDRESS_OBJECTS_TABLE_NAME =
  #   [PREFIX, 'address_objects'].delete_if(&:blank?).join('_').to_sym

  # FIAS_ADDRESS_OBJECTS = DB[FIAS_ADDRESS_OBJECTS_TABLE_NAME]

  # ADDRESS_OBJECTS_TABLE_NAME = :address_objects

  # ADDRESS_OBJECTS = DB[ADDRESS_OBJECTS_TABLE_NAME]

  desc "Create target tables"
  task :create_table do        
    connect_db.create_table(:address_objects) do
      primary_key :id

      column :aoid, :uuid
      column :aoguid, :uuid
      column :parentguid, :uuid
      column :parent_id, :integer    
      column :name, :text
      column :abbr, :text
      column :code, :text
      column :level, :integer
      column :region, :text
      column :center, :boolean
    end

    puts "Table 'address_objects' created."
    connect_db.create_table(:address_object_hierarchies) do
      column :ancestor_id, Integer
      column :descendant_id, Integer
      column :generations, Integer

      index [:ancestor_id, :descendant_id, :generations]
      index [:ancestor_id]
      index [:descendant_id]
    end
    puts "Table 'address_object_hierarchies' created."
  end

  desc "Copy actual data from FIAS ADDRESS OBJECTS table"
  task :copy_data do
    puts 'Copying data from FIAS...'    
    encoder = PgDataEncoder::EncodeForCopy.new(
      column_types: { 0 => :uuid, 1 => :uuid, 2 => :uuid }
    )
    PREFIX = ENV['PREFIX'] || 'fias'

    FIAS_ADDRESS_OBJECTS_TABLE_NAME =
      [PREFIX, 'address_objects'].delete_if(&:blank?).join('_').to_sym

    FIAS_ADDRESS_OBJECTS = connect_db[FIAS_ADDRESS_OBJECTS_TABLE_NAME]

    # Nonhistorical records
    scope = FIAS_ADDRESS_OBJECTS.where(livestatus: 1)

    bar = ProgressBar.create(total: scope.count, format: '%a |%B| [%E] (%c/%C) %p%%')

    scope.each do |row|
      bar.increment

      encoder.add([
        row[:aoid],
        row[:aoguid],
        row[:parentguid],
        row[:formalname],
        row[:shortname],
        row[:code],
        row[:aolevel],
        row[:regioncode],
        row[:centerst].to_i > 0
      ])
    end

    io = encoder.get_io

    columns = %i(aoid aoguid parentguid name abbr code level region center)

    connect_db.copy_into(:address_objects, columns: columns, format: :binary) do
      begin
        io.readpartial(65_536)
      rescue EOFError => _e
        nil
      end
    end
  end

  desc "Restore parent_id value"
  task :restore_hierarchy do
    puts 'Restoring parent_id values...'    
    Fias::Import::RestoreParentId.new(connect_db[:address_objects]).restore
    puts 'Parent_id values successfully restored'    
  end
  private
    def connect_db
    if ENV['DATABASE_URL'].blank?
      fail 'Specify DATABASE_URL (eg. postgres://localhost/fias)'
    end

    Sequel.connect(ENV['DATABASE_URL'])
  end
end


  # # Uncomment this migration if you want to use closure_tree for hierarchies:
  # #
  # DB.create_table(:address_object_hierarchies) do
  #   column :ancestor_id, Integer
  #   column :descendant_id, Integer
  #   column :generations, Integer

  #   index [:ancestor_id, :descendant_id, :generations]
  #   index [:ancestor_id]
  #   index [:descendant_id]
  # end
  # #
  # # Use http://github.com/gzigzigzeo/pg_closure_tree_rebuild to fill it.
  # #
  # # Database ready!