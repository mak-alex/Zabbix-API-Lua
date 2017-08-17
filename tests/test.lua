#!/usr/bin/env lua
require'luarocks.loader'
-- создаем новый инстанс с нужным нам IP адресом, verbose (bool), debug (bool) 
local zabbix = require'zabbix':new('10.244.244.139', true, false)

-- вводим логин/пароль и авторизовываемся
zabbix:set_credentials{'Admin', 'zabbix'}.login()

-- получаем хост
local hosts = zabbix:__call({method='host.get',params={}})

-- создаем фильтр для сбора зависимостей
local params = { hostids = hosts.result[1].hostid }

-- выводим в stdout форматированный json
zabbix:pretty(hosts)

-- выходим из zabbix'a
zabbix:logout()
