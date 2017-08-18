
--overwrite these because they are only appended to package.c/path by default.
package.path = os.getenv'LUA_PATH'
package.cpath = os.getenv'LUA_CPATH'

--global error handler: log and print the error and exit with 500.
--http error objects coming from webb are handled separately.
local function try_call(func, ...)
	local function pass(ok, ...)
		if ok then return ... end
		local err_obj = ...
		local err = tostring(err_obj)
		ngx.log(ngx.ERR, err)
		if type(err_obj) == 'table' then
			ngx.status = err_obj.http_code
			err = err_obj.message
		else
			ngx.status = 500
			if ngx.var.hide_errors then --can't use config() here
				err = 'Internal error'
			else
				ngx.header.content_type = 'text/plain'
			end
		end
		if err then
			ngx.print(err)
		end
		ngx.exit(0)
	end
	return pass(xpcall(func, debug.traceback, ...))
end

try_call(function()
	local handle_request = require'main'
	handle_request()
end)
