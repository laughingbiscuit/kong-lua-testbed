-- A small example

-- transform /foo/1 to /1

local path = kong.request.get_path()

-- replace '/foo' with empty string
new_path = string.gsub(path, '/foo', '')

-- set new path
kong.service.request.set_path(new_path)
