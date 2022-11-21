namespace :<app name> do
  
  desc "clean"
  task clean: :environment do
    sh "rm -rf public"
  end

end