module Proxy
  module Ansible
    class Api < Sinatra::Base
      get '/roles' do
        `ls /etc/ansible/roles/`.split("\n").to_json
      end

      get '/roles/:role_name/variables' do |role_name|
        # not anything matching item, }}, {{, ansible_hostname or 'if'
        role_files = Dir.glob("/etc/ansible/roles/#{role_name}/**/*.yml")
        variables = role_files.map do |role_file|
          File.read(role_file).scan(/{{(.*?)}}/).select do |param|
            param.first.scan(/item/) == [] && param.first.scan(/if/) == []
          end.first
        end.compact
        variables.uniq!
        variables = variables.map(&:first).map(&:strip).to_json
      end
    end
  end
end
