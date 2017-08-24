namespace :ninetyninetests do
	task :crowdci do
		on primary(:crowdci_roles) do
			stage = fetch(:crowdci_stage)
			conf = YAML::load(File.open('config/crowdci.yml'))[stage]
			if stage == "production"
				@server_name = "http://99tests.com"
			elsif stage == "staging"
				@server_name = "http://testfolio.in"
			else
				@server_name = "http://localhost:3000"
			end
			response = HTTParty.get("#{@server_name}/api/v1/enterprisecycles?product_id=#{conf['product_id']}",
				:headers => {"X-Auth-User" => "#{conf['email']}", "X-Auth-Key" => "#{conf['api_key']}"})
			
			rex = /TESTME.md/
			git_messages = `git log --since="#{response['start_time']}" --name-only`
			if git_messages.match(rex).present?
				puts "CrowdCI: Found new Test requirements in TESTME.md"
				if Time.now < Time.parse(response["end_time"])
					puts "CrowdCI: You currently have a cycle running, not creating a new cycle right now"
					update_fixed_bugs(response,response)
				else
					puts "CrowdCI: Creating new test cycle"
					new_cycle = HTTParty.post("#{@server_name}/api/v1/enterprisecycles",
						:body => {enterprisecycle_id: response["id"]}.to_json,
						:headers => {"X-Auth-User" => "#{conf['email']}", "X-Auth-Key" => "#{conf['api_key']}",'Content-Type' => 'application/json'})
					if new_cycle.code == 201
						puts "CrowdCI: Cycle successfully created"
						update_fixed_bugs(response,new_cycle,File.read("TESTME.md"))
					else
						puts "CrowdCI: Issue creating cycle, admins have been notified"
					end
				end
			else
				puts "CrowdCI: Updating current cycle with fixed bugs"
				update_fixed_bugs(response,response)
			end
			puts "CrowdCI: Deployment check complete"
		end
	end
	def update_fixed_bugs(from_cycle,to_cycle,initial_requirement=nil)
		# puts "updating requirements from cycle #{from_cycle['id']} to #{to_cycle['id']}"
		stage = fetch(:crowdci_stage)
		conf = YAML::load(File.open('config/crowdci.yml'))[stage]
		git_messages = `git log --since="#{from_cycle['start_time']}" --name-only`
		re = /#bug-([0-9]+)/
		bugs_ids = git_messages.scan re
		bugs_ids.flatten!
		bugs_ids.uniq!
		puts "CrowdCI: Marking bugs " + bugs_ids.join(',') + " as fixed"
		HTTParty.post("#{@server_name}/api/v1/enterprisecycle_bugs",
			:body => {enterprisecycle_id: from_cycle["id"], bugs_ids: bugs_ids}.to_json,
			:headers => {"X-Auth-User" => "#{conf['email']}", "X-Auth-Key" => "#{conf['api_key']}",'Content-Type' => 'application/json'})
		if initial_requirement
			requirement = "<p> #{initial_requirement} </p>"+ "<p>Bugs fixed in previous cycle</p>" 
		else
			requirement = from_cycle["requirement"] + "<p>New Deployment #{Time.now}</p>" + "<p>Bugs fixed</p>" 
		end
		url = "#{@server_name}/enterprise-test-cycle/#{from_cycle['id']}/bugs/"
		bugs_ids.each do |bug_id|
			requirement +=  "<a href = #{url+bug_id}>#{bug_id}</a> "
		end
		HTTParty.put("#{@server_name}/api/v1/enterprisecycles/#{to_cycle['id']}",
			:body => {requirement: requirement}.to_json,
			:headers => {"X-Auth-User" => "#{conf['email']}", "X-Auth-Key" => "#{conf['api_key']}",'Content-Type' => 'application/json'})
	end
	after 'deploy:published', 'ninetyninetests:crowdci' do
	    invoke 'ninetyninetests:crowdci'
	end
end
namespace :load do
	task :defaults do
		set_if_empty :crowdci_roles, -> { roles(:web) }
		set_if_empty :crowdci_stage, "production"
	end
end
