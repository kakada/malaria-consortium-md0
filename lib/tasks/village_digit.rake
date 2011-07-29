namespace :db do
  desc "strip all village code to 8 digit only"
  task :strip_village_code => :environment do
    Village.strip_code
  end
  desc "Read repository tag"
  task :version_update => :environment do
    f = File.open File.join("#{Rails.root}",".hgtags"), "r"
    last =   f.read().split("\n").last
    items = last.split(" ")
    version = items[1,items.size-1]
    p version.join("")

    Setting["app_version"] = version.join("")

  end

end