module ForemanPuppet
  module ProxyStatus
    class Puppet < ::ProxyStatus::Base
      def environment_stats
        fetch_proxy_data do
          env_counts = {}
          api.environments.each { |env| env_counts[env] = api.class_count(env) }
          env_counts
        end
      end

      def self.humanized_name
        'Puppet'
      end
    end
  end
end
