namespace :admin do
  desc "create a new Admin"
  task :create, [:email, :password] => :environment do |t, args|
    puts "Creating Admin Account for #{args[:email]}"
    Admin.create!(email: args[:email], password: args[:password])
  end
end
