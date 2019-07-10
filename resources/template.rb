# resources/template.rb
#
# Resource for Kapacitor

property :id, String, name_property: true
property :host, String, default: 'localhost'
property :port, Integer, default: 9092
property :type, String
property :script, String

default_action :create

include KapacitorCookbook::KapacitorApi

action :create do
  options = {
    host: new_resource.host,
    port: new_resource.port,
  }
  template_options = {
    id: new_resource.id,
    type: new_resource.type,
    script: new_resource.script,
  }

  # Find wether template already exists
  template = get_template(options, template_options)

  # If not found let's create it
  if template.nil?
    converge_by("Creating template #{new_resource.name}") do
      create_template(options, template_options)
    end
  else
    converge_by("Update template #{new_resource.name}") do
      update_template(options, template_options)
    end
  end
end

action :delete do
  options = {
    host: new_resource.host,
    port: new_resource.port,
  }
  template_options = {
    id: new_resource.id,
  }

  # Find wether template already exists
  template = get_template(options, template_options)

  # If already exist enable
  if template
    converge_by("Delete template #{new_resource.name}") do
      delete_template(options, template_options)
    end
  end
end
