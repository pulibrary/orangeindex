require 'yaml'
require 'erb'
require 'json'
require 'faraday'
require 'zlib'

config = YAML.load(ERB.new(File.read('config/solr.yml')).result)

conn = Faraday.new(:url => config['marc_liberation']) do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end


desc "Index against SET_URL, default traject config solr.url"
task :index do
  url_arg = ENV['SET_URL'] ? "-u #{ENV['SET_URL']}" : ''
  sh "traject -c lib/traject_config.rb spec/fixtures/sampleconc.mrx #{url_arg}"
end

namespace :index do

  desc "Index sample fixtures in development"
  task :development do
    ENV['SET_URL'] = config['development']['url']
    Rake::Task["index"].invoke
  end  

  desc "Index sample fixtures in production"
  task :production do
    ENV['SET_URL'] = config['production']['url']
    Rake::Task["index"].invoke
  end  

  desc "Index sample fixtures in test"
  task :test do
    ENV['SET_URL'] = config['test']['url']
    Rake::Task["index"].invoke    
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

  desc "Index VoyRec with all changed records, against SET_URL"
  task :updates do
    url_arg = ENV['SET_URL'] ? "-u #{ENV['SET_URL']}" : '' 
    resp = conn.get '/events.json'
    all_events = JSON.parse(resp.body).each do |event| 
      if event['success'] && event['dump_type'] == 'CHANGED_RECORDS' && event['id'] != 17
        dump = JSON.parse(Faraday.get(event['dump_url']).body)
        if dump['files']['updated_records'][0]     
          File.write('/tmp/update.gz', Faraday.get(dump['files']['updated_records'][0]['dump_file']).body)      
          Zlib::GzipReader.open('/tmp/update.gz') do |gz|
            File.open("/tmp/update.xml", "w") do |g|
              IO.copy_stream(gz, g)
            end
          end 
          sh "traject -c lib/traject_config.rb /tmp/update.xml #{url_arg}"
        end
        if dump['files']['new_records'][0]     
          File.write('/tmp/new.gz', Faraday.get(dump['files']['new_records'][0]['dump_file']).body)      
          Zlib::GzipReader.open('/tmp/new.gz') do |gz|
            File.open("/tmp/new.xml", "w") do |g|
              IO.copy_stream(gz, g)
            end
          end 
          sh "traject -c lib/traject_config.rb /tmp/new.xml #{url_arg}"
        end        
        #File.write('/tmp/new.json', Faraday.get(dump['files']['new_records'][0]['dump_file']).body) if dump['files']['new_records'][0]        
      end
    end
  end

   namespace :updates do

    desc "Index VoyRec with all changed records in development"
    task :development do
      ENV['SET_URL'] = config['development']['url']
      Rake::Task["liberate:updates"].invoke
    end
    desc "Index VoyRec with all changed records in production"
    task :production do
      ENV['SET_URL'] = config['production']['url']
      Rake::Task["liberate:updates"].invoke
    end

    desc "Index VoyRec with all changed records in test"
    task :test do
      ENV['SET_URL'] = config['test']['url']
      Rake::Task["liberate:updates"].invoke
    end    
  end 

end


  # desc "Copies solr config files to Jetty wrapper"
  # task solr2jetty: :environment do
		# cp Rails.root.join('solr_conf','solr.xml'), Rails.root.join('jetty','solr')
		# cp Rails.root.join('solr_conf','conf','schema.xml'), Rails.root.join('jetty','solr','blacklight-core','conf')
		# cp Rails.root.join('solr_conf','conf','solrconfig.xml'), Rails.root.join('jetty','solr','blacklight-core','conf')	
		# cp Rails.root.join('solr_conf', 'core.properties'), Rails.root.join('jetty','solr', 'blacklight-core')
  # end
  
  # desc "Drops and readds tables before seeding"
  # task setstep: :environment do
  # 	ENV['STEP'] = ENV['STEP'] ? ENV['STEP'] : '3'
  # 	Rake::Task["db:migrate:redo"].invoke
  # end


  # desc "Reset jetty"
  # task rejetty: :environment do
  #   Rake::Task["jetty:stop"].invoke
  #   Rake::Task["jetty:clean"].invoke
  #   Rake::Task["jetty:start"].invoke        
  # end
  # # desc "Posts fixtures to Solr"
  # # task solradd: :environment do

  # # end

