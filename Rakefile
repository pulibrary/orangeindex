require 'yaml'
require 'erb'
require 'json'
require 'faraday'
require 'zlib'
require 'rsolr'
require 'time'
require './lib/index_functions'

config = YAML.load(ERB.new(File.read('config/solr.yml')).result)

conn = Faraday.new(:url => config['marc_liberation']) do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end


desc "Index MARC against SET_URL, default sample fixtures against traject config solr.url"
task :index do
  url_arg = ENV['SET_URL'] ? "-u #{ENV['SET_URL']}" : ''
  fixtures = ENV['MARC'] || 'spec/fixtures/sampleconc.mrx'
  sh "traject -c lib/traject_config.rb #{fixtures} #{url_arg}"
end

desc "Index MARC_PATH files against SET_URL (default is production)"
task :index_folder do
  solr_url = ENV['SET_URL'] || config['production']['url']
  Dir["#{ENV['MARC_PATH']}/*.xml"].sort.each {|fixtures| sh "rake index SET_URL=#{solr_url} MARC=#{fixtures}; true"}
end

namespace :index do

  desc "Index MARC in development"
  task :development do
    ENV['SET_URL'] = config['development']['url']
    Rake::Task["index"].invoke
  end  

  desc "Index MARC in production"
  task :production do
    ENV['SET_URL'] = config['production']['url']
    Rake::Task["index"].invoke
  end  

  desc "Index MARC in test"
  task :test do
    ENV['SET_URL'] = config['test']['url']
    Rake::Task["index"].invoke    
  end    

end

desc "which chunks from BIB_DUMP didn't index against SET_URL?"
task :check do
  if ENV['BIB_DUMP']
    index_url = ENV['SET_URL'] || config['production']['url']
    solr = RSolr.connect :url => index_url
    `awk 'NR % 50000 == 0 {print} END {print}' #{ENV['BIB_DUMP']}`.split("\n").each_with_index do |bib, i|
      puts i if solr.get('get', :params => {id: "#{bib}"})["doc"].nil?
    end
  end
end

desc "which chunks from BIB_DUMP index against SET_URL?"
task :check_included do
  if ENV['BIB_DUMP']
    index_url = ENV['SET_URL'] || config['production']['url']
    solr = RSolr.connect :url => index_url
    `awk 'NR % 50000 == 0 {print} END {print}' #{ENV['BIB_DUMP']}`.split("\n").each_with_index do |bib, i|
      puts i unless solr.get('get', :params => {id: "#{bib}"})["doc"].nil?
    end
  end
end

desc "Deletes given BIB from SET_URL, default development"
task :delete_bib do
  solr_url = ENV['SET_URL'] || config['development']['url']
  if ENV['BIB']
    sh "curl '#{solr_url}/update?commit=true' --data '<delete><id>#{ENV['BIB']}</id></delete>' -H 'Content-type:text/xml; charset=utf-8'"
  else
    puts 'Please provide a BIB argument (BIB=####)'
  end
end

namespace :delete_bib do

  desc "Deletes given BIB in development"
  task :development do
    ENV['SET_URL'] = config['development']['url']
    Rake::Task["delete_bib"].invoke
  end

  desc "Deletes given BIB in production"
  task :production do
    ENV['SET_URL'] = config['production']['url']
    Rake::Task["delete_bib"].invoke
  end

  desc "Deletes given BIB in test"
  task :test do
    ENV['SET_URL'] = config['test']['url']
    Rake::Task["delete_bib"].invoke
  end
end


namespace :liberate do

  desc "Index VoyRec for given BIB, against SET_URL"
  task :bib do
    url_arg = ENV['SET_URL'] ? "-u #{ENV['SET_URL']}" : '' 
    if ENV['BIB']
      resp = conn.get "/bibliographic/#{ENV['BIB']}"
      File.write('/tmp/tmp.xml', resp.body)   
      sh "traject -c lib/traject_config.rb /tmp/tmp.xml #{url_arg}"
    else
      puts 'Please provide a BIB argument (BIB=####)'
    end
  end

  namespace :bib do

    desc "Index VoyRec for given BIB in development"
    task :development do
      ENV['SET_URL'] = config['development']['url']
      Rake::Task["liberate:bib"].invoke
    end
    desc "Index VoyRec for given BIB in production"
    task :production do
      ENV['SET_URL'] = config['production']['url']
      Rake::Task["liberate:bib"].invoke
    end

    desc "Index VoyRec for given BIB in test"
    task :test do
      ENV['SET_URL'] = config['test']['url']
      Rake::Task["liberate:bib"].invoke
    end    
  end

  desc "Index VoyRec with all changed records since SET_DATE, against SET_URL"
  task :updates do
    solr_url = ENV['SET_URL'] || config['development']['url']  
    resp = conn.get '/events.json'
    comp_date = ENV['SET_DATE'] ? Date.parse(ENV['SET_DATE']) : (Date.today-1)
    all_events = JSON.parse(resp.body).select {|e| Date.parse(e['start']) >= comp_date && e['success'] && e['dump_type'] == 'CHANGED_RECORDS'}.each do |event| 
      IndexFunctions::update_records(event, solr_url).each do |marc_xml|
        sh "traject -c lib/traject_config.rb #{marc_xml}.xml -u #{solr_url}; true"
        File.delete("#{marc_xml}.xml")
        File.delete("#{marc_xml}.gz")
      end
      sh "curl '#{solr_url}/update/json?commit=true' --data-binary @/tmp/delete_ids.json -H 'Content-type:application/json'; true"
    end
  end

   namespace :updates do

    desc "Index VoyRec with all changed records since given SET_DATE in development"
    task :development do
      ENV['SET_URL'] = config['development']['url']
      Rake::Task["liberate:updates"].invoke
    end
    desc "Index VoyRec with all changed records since given SET_DATE in production"
    task :production do
      ENV['SET_URL'] = config['production']['url']
      Rake::Task["liberate:updates"].invoke
    end

    desc "Index VoyRec with all changed records since given SET_DATE in test"
    task :test do
      ENV['SET_URL'] = config['test']['url']
      Rake::Task["liberate:updates"].invoke
    end
  end

  desc "Index VoyRec updates on SET_DATE against SET_URL, default development"
  task :on do
    solr_url = ENV['SET_URL'] || config['development']['url']  
    resp = conn.get '/events.json'
    if event = JSON.parse(resp.body).detect {|e| Date.parse(e['start']) == Date.parse(ENV['SET_DATE']) && e['success'] && e['dump_type'] == 'CHANGED_RECORDS'}
      IndexFunctions::update_records(event, solr_url).each do |marc_xml|
        sh "traject -c lib/traject_config.rb #{marc_xml}.xml -u #{solr_url}; true"
        File.delete("#{marc_xml}.xml")
        File.delete("#{marc_xml}.gz")
      end
      sh "curl '#{solr_url}/update/json?commit=true' --data-binary @/tmp/delete_ids.json -H 'Content-type:application/json'"
    end
  end

  namespace :on do

    desc "Index VoyRec updates for given SET_DATE in development"
    task :development do
      ENV['SET_URL'] = config['development']['url']
      Rake::Task["liberate:on"].invoke
    end
    desc "Index VoyRec updates for given SET_DATE in production"
    task :production do
      ENV['SET_URL'] = config['production']['url']
      Rake::Task["liberate:on"].invoke
    end

    desc "Index VoyRec updates for given SET_DATE in test"
    task :test do
      ENV['SET_URL'] = config['test']['url']
      Rake::Task["liberate:on"].invoke
    end
  end

  desc "Index VoyRec with today's changed records, against SET_URL"
  task :latest do
    solr_url = ENV['SET_URL'] || config['development']['url']  
    resp = conn.get '/events.json'
    event = JSON.parse(resp.body).last
    if event['success'] && event['dump_type'] == 'CHANGED_RECORDS'
      IndexFunctions::update_records(event, solr_url).each do |marc_xml|
        sh "traject -c lib/traject_config.rb #{marc_xml}.xml -u #{solr_url}; true"
        File.delete("#{marc_xml}.xml")
        File.delete("#{marc_xml}.gz")
      end
      sh "curl '#{solr_url}/update/json?commit=true' --data-binary @/tmp/delete_ids.json -H 'Content-type:application/json'"      
    end
  end

   namespace :latest do

    desc "Index VoyRec with latest day's changed records in development"
    task :development do
      ENV['SET_URL'] = config['development']['url']
      Rake::Task["liberate:latest"].invoke
    end
    desc "Index VoyRec with latest day's changed records in production"
    task :production do
      ENV['SET_URL'] = config['production']['url']
      Rake::Task["liberate:latest"].invoke
    end

    desc "Index VoyRec with latest day's changed records in test"
    task :test do
      ENV['SET_URL'] = config['test']['url']
      Rake::Task["liberate:latest"].invoke
    end
  end 

  desc "Index latest full record dump against SET_URL, default development"
  task :full do
    solr_url = ENV['SET_URL'] || config['development']['url']
    resp = conn.get '/events.json'
    if event = JSON.parse(resp.body).select {|e| e['success'] && e['dump_type'] == 'ALL_RECORDS'}.last
      IndexFunctions::full_dump(event, solr_url).each do |marc_xml|
        sh "traject -c lib/traject_config.rb #{marc_xml}.xml -u #{solr_url}; true"
        File.delete("#{marc_xml}.xml")
        File.delete("#{marc_xml}.gz")
      end
    end
  end

  namespace :full do

    desc "Index latest full record dump in development"
    task :development do
      ENV['SET_URL'] = config['development']['url']
      Rake::Task["liberate:full"].invoke
    end
    desc "Index latest full record dump in production"
    task :production do
      ENV['SET_URL'] = config['production']['url']
      Rake::Task["liberate:full"].invoke
    end

    desc "Index latest full record dump in test"
    task :test do
      ENV['SET_URL'] = config['test']['url']
      Rake::Task["liberate:full"].invoke
    end
  end
end