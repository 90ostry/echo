local plugin = require("kong.plugins.base_plugin"):extend()
local cjson = require("cjson")

local req_read_body = ngx.req.read_body
local req_get_body_data = ngx.req.get_body_data
local req_set_header = ngx.req.set_header
local pcall = pcall

local function parse_json(body)
    if body then
      local status, res = pcall(cjson.decode, body)
      if status then
        return res
      end
    end
  end

function plugin:access(conf)
    req_read_body() 

    local headers = ngx.req.get_headers()
    local body = ngx.req.get_body_data()
    local method = ngx.req.get_method()
    local querystring_params = ngx.req.get_uri_args()
    
    local body_size = string.len(body)

    encoded_headers, err = cjson.encode({headers = headers})
    local body_parameters = parse_json(body)
    
    encoded, err = cjson.encode({
        querystring = querystring_params,
        method = method, 
        body = body_parameters,
        body_size = body_size,
        headers = headers
    })

    -- response to caller    
    ngx.header["Content-Type"] = "application/json; charset=utf-8"
    ngx.say(encoded)
    ngx.exit(200)
end



return plugin
