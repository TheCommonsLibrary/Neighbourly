require 'rubygems'
require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:unit_tests) do |task|
    task.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
    task.pattern    = 'spec/unit_tests/**/*_spec.rb'
  end
  RSpec::Core::RakeTask.new(:acceptance) do |task|
    task.rspec_opts = ["-c", "-f documentation", "-r ./spec/acceptance_helper.rb"]
    task.pattern    = 'spec/acceptance/**/*_feature.rb'
  end
end

namespace :db do
  require "sequel"
  Sequel.extension :migration
  
  desc "Prints current schema version"
  task :version do
    DB = Sequel.connect(ENV['DATABASE_URL'])
    version = if DB.tables.include?(:schema_info)
      DB[:schema_info].first[:version]
    end || 0

    puts "Schema Version: #{version}"
  end

  desc "Perform migration up to latest migration available"
  task :migrate do
    DB = Sequel.connect(ENV['DATABASE_URL'])
    Sequel::Migrator.run(DB, "migrations")
    Rake::Task['db:version'].execute
  end
    
  desc "Perform rollback to specified target or full rollback as default"
  task :rollback, :target do |t, args|
    DB = Sequel.connect(ENV['DATABASE_URL'])
    args.with_defaults(:target => 0)

    Sequel::Migrator.run(DB, "migrations", :target => args[:target].to_i)
    Rake::Task['db:version'].execute
  end

  desc "Perform migration reset (full rollback and migration)"
  task :reset do
    DB = Sequel.connect(ENV['DATABASE_URL'])
    Sequel::Migrator.run(DB, "migrations", :target => 0)
    Sequel::Migrator.run(DB, "migrations")
    Rake::Task['db:version'].execute
  end    
end
