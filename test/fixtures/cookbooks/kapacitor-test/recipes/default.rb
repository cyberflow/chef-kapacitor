include_recipe 'kapacitor::default'

# Service start
service 'kapacitor' do
  action :restart
end

# Create a test task
kapacitor_task 'test' do
  id 'cpu_alert'
  type 'stream'
  dbrps [{ 'db' => 'collectd', 'rp' => 'one_hour' }]
  script "stream\n    // Select just the cpu measurement from our example database.\n    |from()\n        .measurement('cpu_value')\n        .where(lambda: \"type_instance\" == 'idle' AND \"type\" == 'percent')\n    |alert()\n        .crit(lambda: \"value\" \u003c 70)\n        // Whenever we get an alert write it to a file.\n        .log('/tmp/alerts.log')\n        .topic('test')\n"
  action %i(create enable)
end

# update created task
kapacitor_task 'test' do
  id 'cpu_alert'
  type 'stream'
  dbrps [{ 'db' => 'collectd', 'rp' => 'one_hour' }]
  script "stream\n    |from()\n        .measurement('cpu_value')\n        .where(lambda: \"type_instance\" == 'idle' AND \"type\" == 'percent')\n    |alert()\n        .crit(lambda: \"value\" \u003c 70)\n                .log('/tmp/alerts.log')\n"
  rewrite true
  action %i(create enable)
end

kapacitor_handler 'test_handler' do
  id 'test_handler'
  topic 'test'
  actions [{ 'kind' => 'log', 'options' => { 'path' => '/tmp/alerts.log' } }]
  action :create
end

# Update a test hendler
kapacitor_handler 'test_handler' do
  id 'test_handler'
  topic 'test'
  actions [{ 'kind' => 'log', 'options' => { 'path' => '/tmp/update_alerts.log' } }]
  action :create
end

kapacitor_template 'test_template' do
  id 'mem_alert'
  type 'stream'
  script "var crit = 70\nstream\n    |from()\n        .measurement('mem')\n    |alert()\n        .crit(lambda: \"used_percent\" \u003e crit)\n        .log('/tmp/memory_ololert.log')\n        .topic('test')\n"
  action :create
end

kapacitor_task 'templated_task' do
  id 'mem_alert'
  template 'mem_alert'
  dbrps [{ 'db' => 'node_stats', 'rp' => 'one_hour' }]
  vars 'crit' => { 'value' => 79, 'type' => 'int' }
  rewrite true
  action %i(create enable)
end
