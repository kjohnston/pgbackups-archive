guard "rspec", cli: "--color --format Fuubar", all_on_start: false, all_after_pass: false do
  watch(%r{^spec/(.*)_spec\.rb$})
  watch(%r{^lib/(.*)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
end
