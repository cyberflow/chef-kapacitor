source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'apt', '~> 6.1'
  cookbook 'influxdb'
  cookbook 'seven_zip', '~> 2'
end

group :test do
  cookbook 'kapacitor-test', path: 'test/fixtures/cookbooks/kapacitor-test'
  cookbook 'curl'
end
