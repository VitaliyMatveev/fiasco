# Can be run in cloned repo
# DATABASE_URL=postgres://localhost/fiasco_db bundle exec ruby generate_index.rb

require 'ruby-progressbar'
require 'sequel'
require 'active_support/core_ext/object/blank'
require 'fias'



# DB = Sequel.connect(ENV['DATABASE_URL'])
# DB.extension :pg_array

# ADDRESS_OBJECTS_TABLE_NAME = :address_objects
# ADDRESS_OBJECTS = DB[ADDRESS_OBJECTS_TABLE_NAME]

namespace :fiasco do  

  desc "Add tokens field to 'address_objects' table"
  task :alter_table do     
    DB ||= connect_db
    DB.alter_table(:address_objects) do
      add_column :tokens, 'text[]'
      add_column :ancestry, 'integer[]'
      add_column :forms, 'text[]'
    end

    DB.run 'CREATE INDEX idx_tokens on "address_objects" USING GIN ("tokens");'
  end

  desc "Generate tokens for search"
  task :tokenize do  
    DB ||= connect_db
    DB.extension :pg_array
    
    scope = DB[:address_objects]    

    bar =  ProgressBar.create(total: scope.count, format: '%a |%B| [%E] (%c/%C) %p%%')

    scope.select(:id, :name).each do |row|
      bar.increment

      tokens = Fias::Name::Synonyms.tokens(row[:name])
      forms = Fias::Name::Synonyms.forms(row[:name])
      ancestry = ancestry_for(row[:id])

      scope.where(id: row[:id]).update(
        tokens: Sequel.pg_array(tokens, :text),
        forms:  Sequel.pg_array(forms, :text),
      ancestry: Sequel.pg_array(ancestry, :integer)
      )
    end
  end

  private
    def ancestry_for(id)
      DB[:address_objects]
        .select(:id)
        .join(:address_object_hierarchies, ancestor_id: :id)
        .where(address_object_hierarchies__descendant_id: id)
        .order(:address_object_hierarchies__generations)
        .select_map(:id) - [id]
    end
end