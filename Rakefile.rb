
namespace 'chef_server' do
  
  task :build do
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
    Rake.sh("docker build -t #{image_name} .")
  end

end
