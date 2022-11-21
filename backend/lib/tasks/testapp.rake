namespace :testapp do
  
  desc "clean"
  task clean: :environment do
    sh "rm -rf public"
  end

end