# Encoding: utf-8

require 'spec_helper'

describe port(9092) do
  it { should be_listening }
end

describe command('curl http://127.0.0.1:9092/kapacitor/v1/tasks/cpu_alert') do
  its(:stdout) { should contain('cpu_alert') }
end

describe command('curl http://127.0.0.1:9092/kapacitor/v1/alerts/topics/test/handlers/test_handler') do
  its(:stdout) { should contain('test_handler') }
end

describe command('curl http://127.0.0.1:9092/kapacitor/v1/templates/mem_alert') do
  its(:stdout) { should contain('mem_alert') }
end

describe command('curl http://127.0.0.1:9092/kapacitor/v1/tasks/mem_alert') do
  its(:stdout) { should contain('"template-id": "mem_alert"') }
end
