namespace :snort do 
  desc "generate so_rule stubs"
  task :so_stubs do
    %x{ snort -c snort.conf --dump-dynamic-rules=/etc/snort/so_rule_stubs }
  end
end
