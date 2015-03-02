
namespace 'chef_server' do
  
  task :build do

    # read image name from file
    image_name = String.new()
    File.open('./scripts/image_metadata.txt','r')do |f|
      # file is opened
      file_contents = f.readlines
      file_contents.each do |line|
        if line.start_with?("image_name")
          no_space_line = line.gsub(/\s+/, "")
          image_name = no_space_line.gsub(/image_name=/, "") 
        end
      end
    end
    begin

      # since docker build --privileged is not supported yet 
      # (https://github.com/docker/docker/issues/1916)
      # I cannot run:
      Rake.sh("docker build -t #{image_name} .")

      # scripts_path = File.expand_path('./scripts') # must be absolute
      # Rake.sh("docker run --privileged --name chef_server -dti -p 443:443 -v #{scripts_path}:/scripts ubuntu:14.04")
      # Rake.sh("docker exec -ti chef_server /scripts/install_chef_server.sh && mv /scripts/image_metadata.txt /etc/docker_image_metadata.txt && /scripts/cleanup.sh")
    rescue Exception => ex
      # catch any Exception (including StandardError)
      fail "Failed to build docker image, error: #{ex.message}"      
    end
  end

end
