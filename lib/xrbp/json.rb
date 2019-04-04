# Attempt to use yajl bindings,
# else fallback to stock json
begin
  require 'yajl/json_gem'
rescue LoadError
  require 'json'
end
