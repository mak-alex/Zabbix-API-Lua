package = "zabbix-lua-api"
version = "0.1.0-1"
source = {
   url = "https://bitbucket.org/enlab/zabbix-lua-api/get/master.tar.gz",
   dir = 'enlab-zabbix-lua-api-bb281ea5574e'
}
description = {
   summary = "Zabbix API Wrapper",
   detailed = [[
   This is an implementation of the Zabbix API in Lua. Please note that the Zabbix API is still in a draft state, and subject to change.

   Implementations of the Zabbix API in other languages may be found on the wiki.
   ]],
   homepage = "https://bitbucket.org/enlab/zabbix-lua-api",
   license = "MIT"
}
dependencies = {
  "luasocket ~> 3.0rc1-2",
  "lua-cjson ~> 2.1.0-1",
}
build = {
   type = "builtin",
   modules = {
      Log = "src/Log.lua",
      zabbix = "src/zabbix.lua"
   }
}
