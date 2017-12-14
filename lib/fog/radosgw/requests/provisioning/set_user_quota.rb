module Fog
  module Radosgw
    class Provisioning
      class Real
        include Utils

        def set_user_quota(user_id, quota = {})
          path = "admin/user"
          user_id = escape(user_id)
          query = "?quota&uid=#{user_id}&quota-type=user&format=json"
          params = {
              :method => 'PUT',
              :path => path,
          }
          if quota.key?(:max_size_kb)
            query += "&max-size-kb="+ quota[:max_size_kb]
          end
          if quota.key?(:max_objects)
            query += "&max-objects="+ quota[:max_objects]
          end
          if quota.key?(:enabled)
            query += "&enabled="+ quota[:enabled]
          else
            query += "&enabled=true"
          end
          begin
            response = Excon.put("#{@scheme}://#{@host}:#{@port}/#{path}#{query}",
                                 :headers => signed_headers(params))
            if !response.body.empty?
              response.body = Fog::JSON.decode(response.body)
            end
            response
          rescue Excon::Errors::BadRequest => e
            raise Fog::Radosgw::Provisioning::ServiceUnavailable.new
          end
        end
      end

      class Mock
        def get_user_quota(user_id)

          Excon::Response.new.tap do |response|
            response.status = 200
            response.headers['Content-Type'] = 'application/json'
            response.body = {
                "max_size_kb" => -1,
                "max_objects" => -1,
                "enabled" => true,
            }
          end
        end
      end
    end
  end
end
