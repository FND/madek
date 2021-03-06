require 'digest'
require 'action_controller'

namespace :madek do

  task import_institutional_groups: :environment do
    InstitutionalGroupsImporter.import!
  end


  desc "Reset"
  task :reset => :environment do
     Rake::Task["app:setup:make_directories"].execute(:reset => "reset")
     Rake::Task["log:clear"].invoke
      # workaround for realoading Models
     ActiveRecord::Base.subclasses.each { |a| a.reset_column_information }
  end
  
end # madek namespace
