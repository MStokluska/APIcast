use lib 't';
use Test::APIcast::Blackbox 'no_plan';

run_tests();

__DATA__

=== TEST 1: sets default user key for request without credentials
--- configuration
{
  "services": [
    {
      "id": 42,
      "backend_version":  1,
      "backend_authentication_type": "service_token",
      "backend_authentication_value": "token-value",
      "proxy": {
        "policy_chain": [
          {
            "name": "apicast.policy.default_credentials",
            "configuration": {
              "auth_type": "user_key",
              "user_key": "uk"
            }
          },
          {
            "name": "apicast.policy.apicast"
          }
        ],
        "api_backend": "http://test:$TEST_NGINX_SERVER_PORT/",
        "proxy_rules": [
          { "pattern": "/", "http_method": "GET", "metric_system_name": "hits", "delta": 2 }
        ]
      }
    }
  ]
}
--- backend
  location /transactions/authrep.xml {
    content_by_lua_block {
      local expected = "service_token=token-value&service_id=42&usage%5Bhits%5D=2&user_key=uk"
      require('luassert').same(ngx.decode_args(expected), ngx.req.get_uri_args(0))
    }
  }
--- upstream
  location / {
     echo 'yay, api backend';
  }
--- request
GET /
--- response_body
yay, api backend
--- error_code: 200
--- no_error_log
[error]

=== TEST 2: sets default app_id + app_key for request without credentials
--- configuration
{
  "services": [
    {
      "id": 42,
      "backend_version":  2,
      "backend_authentication_type": "service_token",
      "backend_authentication_value": "token-value",
      "proxy": {
        "policy_chain": [
          {
            "name": "apicast.policy.default_credentials",
            "configuration": {
              "auth_type": "app_id_and_app_key",
              "app_id": "some_id",
              "app_key": "some_key"
            }
          },
          {
            "name": "apicast.policy.apicast"
          }
        ],
        "api_backend": "http://test:$TEST_NGINX_SERVER_PORT/",
        "proxy_rules": [
          { "pattern": "/", "http_method": "GET", "metric_system_name": "hits", "delta": 2 }
        ]
      }
    }
  ]
}
--- backend
  location /transactions/authrep.xml {
    content_by_lua_block {
      local expected = "service_token=token-value&service_id=42&usage%5Bhits%5D=2&app_id=some_id&app_key=some_key"
      require('luassert').same(ngx.decode_args(expected), ngx.req.get_uri_args(0))
    }
  }
--- upstream
  location / {
     echo 'yay, api backend';
  }
--- request
GET /
--- response_body
yay, api backend
--- error_code: 200
--- no_error_log
[error]

=== TEST 3: does not set user key when it is in the request
--- configuration
{
  "services": [
    {
      "id": 42,
      "backend_version":  1,
      "backend_authentication_type": "service_token",
      "backend_authentication_value": "token-value",
      "proxy": {
        "policy_chain": [
          {
            "name": "apicast.policy.default_credentials",
            "configuration": {
              "auth_type": "user_key",
              "user_key": "set_by_the_policy"
            }
          },
          {
            "name": "apicast.policy.apicast"
          }
        ],
        "api_backend": "http://test:$TEST_NGINX_SERVER_PORT/",
        "proxy_rules": [
          { "pattern": "/", "http_method": "GET", "metric_system_name": "hits", "delta": 2 }
        ]
      }
    }
  ]
}
--- backend
  location /transactions/authrep.xml {
    content_by_lua_block {
      local expected = "service_token=token-value&service_id=42&usage%5Bhits%5D=2&user_key=uk"
      require('luassert').same(ngx.decode_args(expected), ngx.req.get_uri_args(0))
    }
  }
--- upstream
  location / {
     echo 'yay, api backend';
  }
--- request
GET /?user_key=uk
--- response_body
yay, api backend
--- error_code: 200
--- no_error_log
[error]

=== TEST 4: does not set app_id + app_key when they are in the request
--- configuration
{
  "services": [
    {
      "id": 42,
      "backend_version":  2,
      "backend_authentication_type": "service_token",
      "backend_authentication_value": "token-value",
      "proxy": {
        "policy_chain": [
          {
            "name": "apicast.policy.default_credentials",
            "configuration": {
              "auth_type": "app_id_and_app_key",
              "app_id": "id_set_by_the_policy",
              "app_key": "key_set_by_the_policy"
            }
          },
          {
            "name": "apicast.policy.apicast"
          }
        ],
        "api_backend": "http://test:$TEST_NGINX_SERVER_PORT/",
        "proxy_rules": [
          { "pattern": "/", "http_method": "GET", "metric_system_name": "hits", "delta": 2 }
        ]
      }
    }
  ]
}
--- backend
  location /transactions/authrep.xml {
    content_by_lua_block {
      local expected = "service_token=token-value&service_id=42&usage%5Bhits%5D=2&app_id=some_id&app_key=some_key"
      require('luassert').same(ngx.decode_args(expected), ngx.req.get_uri_args(0))
    }
  }
--- upstream
  location / {
     echo 'yay, api backend';
  }
--- request
GET /?app_id=some_id&app_key=some_key
--- response_body
yay, api backend
--- error_code: 200
--- no_error_log
[error]
