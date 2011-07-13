namespace :db do
  desc "strip all village code to 8 digit only"
  task :strip_village_code => :environment do
    Village.strip_code
  end
end