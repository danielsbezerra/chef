# chef-apply multipleCopies.rb

for i in 1..3
  directory "../multipleCopy#{i}" do
    recursive true
    action :delete
  end

  directory "../multipleCopy#{i}" do
    action :create
    mode "0755"
    owner "ubuntu"
    group "root"
  end

  file "../multipleCopy#{i}/secret.txt" do
    action :create
    mode "0755"
    owner "ubuntu"
    group "root"
    notifies :run, "ruby_block[get-latest-version]", :delayed
  end
  
end


latestVersion = 0
ruby_block "get-latest-version" do
  block do
    # times needs to delimit a block {}
    # 3.times { do something  }
    # 3.times do |x|
    #   do something
    # end
    # max_by Returns the object with the max value in the given enum
    latestVersion = (3.times.max_by { |x| ::File.mtime("../multipleCopy#{x+1}/secret.txt") }) + 1
    print "\nLatest version: #{latestVersion}"
  end
  action :nothing
  notifies :run, "ruby_block[update-old-to-latest]", :delayed
end


ruby_block "update-old-to-latest" do
  block do
    require 'fileutils'
    fromPath = "../multipleCopy#{latestVersion}/secret.txt"
    for i in 1..3
      if i != latestVersion
        # Hard link (older files ponit to latest). Just another directory entry to the same file.
        # link "../multipleCopy#{i}/secret.txt" do
        #   to "../multipleCopy#{latestVersion}/secret.txt"
        #   link_type :hard
        # end
	toPath = "../multipleCopy#{i}/secret.txt"
	FileUtils.cp(fromPath, toPath)
        print "\nCopied from latest #{latestVersion} to #{i}"
      end
    end
  end
  action :nothing
end
