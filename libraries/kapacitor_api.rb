module KapacitorCookbook
  # Use kapacitor API
  module KapacitorApi
    class BackendError < StandardError
    end

    def create_task(options, task)
      options[:method] = 'Post'
      options[:endpoint] = '/kapacitor/v1/tasks'
      task = _do_request(options, task.to_json)
      raise StandardError, task['error'].to_s unless task['error'].empty?
    rescue BackendError
      nil
    end

    def update_task(options, task)
      options[:method] = 'Patch'
      options[:endpoint] = '/kapacitor/v1/tasks/' + task[:id]

      task = _do_request(options, task.to_json)

      raise StandardError, task['error'].to_s unless task['error'].empty?
      task
    end

    # Fetch the json representation of the task
    # curl http://localhost:9092/kapacitor/v1/tasks/sample-task
    def get_task(options, task)
      options[:method] = 'Get'
      options[:endpoint] = '/kapacitor/v1/tasks/' + task[:id]

      task = _do_request(options)

      return if task['error'] == 'no task exists'
      task
    end

    def enable_task(options, task)
      options[:method] = 'Patch'
      options[:endpoint] = '/kapacitor/v1/tasks/' + task[:id]

      enable = { 'status' => 'enabled' }

      _do_request(options, enable.to_json)
    end

    def disable_task(options, task)
      options[:method] = 'Patch'
      options[:endpoint] = '/kapacitor/v1/tasks/' + task[:id]

      enable = { 'status' => 'disabled' }

      _do_request(options, enable.to_json)
    end

    def delete_task(options, task)
      options[:method] = 'Delete'
      options[:endpoint] = '/kapacitor/v1/tasks/' + task[:id]

      _do_request(options, enable.to_json)
    end

    def create_template(options, template)
      options[:method] = 'Post'
      options[:endpoint] = '/kapacitor/v1/templates'
      template = _do_request(options, template.to_json)
      raise StandardError, template['error'].to_s unless template['error'].empty?
    rescue BackendError
      nil
    end

    def update_template(options, template)
      options[:method] = 'Patch'
      options[:endpoint] = '/kapacitor/v1/templates/' + template[:id]

      template = _do_request(options, template.to_json)

      raise StandardError, template['error'].to_s unless template['error'].empty?
      template
    end

    def get_template(options, template)
      options[:method] = 'Get'
      options[:endpoint] = '/kapacitor/v1/templates/' + template[:id]

      template = _do_request(options)

      return if template['error'] == 'no template exists'
      template
    end

    def delete_template(options, template)
      options[:method] = 'Delete'
      options[:endpoint] = '/kapacitor/v1/templates/' + template[:id]

      _do_request(options, enable.to_json)
    end

    # Fetch the json representation of the handler
    # curl http://localhost:9092/kapacitor/v1preview/alerts/topics/<topic id>/handlers/<handler id>.
    def get_handler(options, topic, handler_id)
      options[:method] = 'Get'
      options[:endpoint] = '/kapacitor/v1/alerts/topics/' + topic + '/handlers/' + handler_id

      handler = _do_request(options)

      return if /unknown handler/ =~ handler['error']
      handler
    end

    # create a handler
    def create_handler(options, topic, handler)
      options[:method] = 'Post'
      options[:endpoint] = '/kapacitor/v1/alerts/topics/' + topic + '/handlers'

      _do_request(options, handler.to_json)
    end

    def update_handler(options, topic, handler)
      options[:method] = 'Put'
      options[:endpoint] = '/kapacitor/v1/alerts/topics/' + topic + '/handlers/' + handler[:id]

      handler = _do_request(options, handler.to_json)

      handler
    end

    private

    def _do_request(options, payload = nil)
      http = Net::HTTP.new(options[:host], options[:port])
      request = case options[:method]
                when 'Post'
                  Net::HTTP::Post.new(options[:endpoint])
                when 'Patch'
                  Net::HTTP::Patch.new(options[:endpoint])
                when 'Put'
                  Net::HTTP::Put.new(options[:endpoint])
                when 'Delete'
                  Net::HTTP::Delete.new(options[:endpoint])
                else
                  Net::HTTP::Get.new(options[:endpoint])
                end
      request.add_field('Content-Type', 'application/json;charset=utf-8;')
      request.add_field('Accept', 'application/json')
      request.body = payload if payload

      response = with_limited_retry(tries: 10, exceptions: Errno::ECONNREFUSED) do
        http.request(request)
      end

      JSON.parse(response.body)
    rescue BackendError
      nil
    end

    # Retry limited number of time a block catching only specific exceptions
    # opts:
    #   :tries - Integer - number of time to retry the block (required)
    #   :exceptions - Exception or Array of Exception - exceptions to catch (required)
    def with_limited_retry(opts)
      tries = opts.fetch :tries
      exceptions = Array(opts.fetch(:exceptions))

      return if tries == 0

      begin
        yield
      rescue *exceptions
        Chef::Log.warn('Bad response, try again...')
        if (tries -= 1) > 0
          sleep 1
          retry
        end
      end
    end
  end
end
