require "rbs"
rbs :sudo, :whoami, :gcc, :ruby

sudo do
  puts whoami
end

puts ruby :version