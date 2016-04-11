#encoding: utf-8

#spec = Gem::Specification.find_by_name 'fias'
spec = Gem::Specification.find_all_by_name ['pg_closure_tree_rebuild','fias']
Dir.glob("#{spec.gem_dir}/tasks/*.rake") { |file| load file }

namespace :fiasco do
  desc "Инициирует данные, проливает базу"
  task :init do
    %x[mkdir -p tmp/fias && cd tmp/fias]
    unless File.exist? "fias_dbf.rar"
      puts "DBF file doesn't exist: go to tmp/fias and run \"bundle exec rake fias:download | xargs wget --continue\""
    else
      puts "Already got fias_dbf.rar"
    end
  end
end


