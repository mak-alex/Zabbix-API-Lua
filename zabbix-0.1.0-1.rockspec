package = "zabbix-lua-api"
version = "0.1.0-1"
source = {
   url = "https://bitbucket.org/enlab/zabbix-lua-api"
}
description = {
   summary = "*** please specify description summary ***",
   detailed = "*** please enter a detailed description ***",
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {}
build = {
   type = "builtin",
   modules = {
      Log = "src/Log.lua",
      zabbix = "src/zabbix.lua"
   }
}
