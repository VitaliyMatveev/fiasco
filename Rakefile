#encoding: utf-8

fias_spec = Gem::Specification.find_by_name 'fias'
pg_closure_tree_rebuild_spec = Gem::Specification.find_by_name 'pg_closure_tree_rebuild'

Dir.glob('tasks/*.rake').each { |r| load r}
Dir.glob("#{fias_spec.gem_dir}/tasks/*.rake") { |file| load file }
Dir.glob("#{pg_closure_tree_rebuild_spec.gem_dir}/tasks/*.rake") { |file| load file }

ENV['DATABASE_URL'] ||= "postgres://localhost/fiasco_db"
ENV['TABLE'] ||= 'address_objects'
namespace :fiasco do
  desc "Инициирует данные, проливает базу"
  task :init do
    # %x[mkdir -p tmp/fias && cd tmp/fias]
    # unless File.exist? "fias_dbf.rar"
    #   puts "DBF file doesn't exist: go to tmp/fias and run \"bundle exec rake fias:download | xargs wget --continue\""
    # else
    #   puts "Start importing FIAS data to database"
    #   Rake::Task["fias:create_tables"].invoke
    #   Rake::Task["fias:import"].invoke      
    # Rake::Task["fiasco:create_table"].invoke      
    # Rake::Task["fiasco:copy_data"].invoke      
    # Rake::Task["fiasco:restore_hierarchy"].invoke      
    # Rake::Task["closure_tree:rebuild"].invoke   
    #Rake::Task["fiasco:alter_table"].invoke      
    Rake::Task["fiasco:tokenize"].invoke      
   # end

  end
  

end


