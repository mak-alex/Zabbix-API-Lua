--
--------------------------------------------------------------------------------
-- @file:  zabbix.lua
--
-- @usage:  ./zabbix.lua
--
-- @description:  
--
-- @options:  ---
-- @requirements:  ---
-- @bugs:  ---
-- @notes:  ---
-- @author:  Alexandr Mikhailenko a.k.a Alex M.A.K. (), <alex-m.a.k@yandex.kz>
-- @organization:  
-- @version:  1.0
-- @created:  08/12/2017
-- @revision:  ---
--------------------------------------------------------------------------------
--
require'luarocks.loader'
local http = require'socket.http'
local ltn12 = require'ltn12'
local cjson = require'cjson'

local Zabbix = {
    Log = require'src.Log',
    _request = {
        jsonrpc = '2.0',
        method = nil,
        params = {},
        id = 1,
        auth = nil
    },
}

local _response = {
    jsonrpc = '2.0',
    result = {},
    error = {},
    id = 1
}

Zabbix.__index     = Zabbix   -- get indices from the table
Zabbix.__metatable = Zabbix   -- protect the metatable

------------------------------------------------------------------------
-- @name: Zabbix:new
-- @purpose: 
-- @description: {+DESCRIPTION+}
-- @params: ip - {+DESCRIPTION+} ({+TYPE+})
-- @params: verbose - {+DESCRIPTION+} ({+TYPE+})
-- @params: _debug - {+DESCRIPTION+} ({+TYPE+})
-- @returns: {+RETURNS+}
------------------------------------------------------------------------

function Zabbix:new (ip, verbose, _debug)
    Zabbix.url = 'http://'..ip..'/api_jsonrpc.php'
    Zabbix.Log.pid = 'ZabbixAPI'
    Zabbix.verbose = verbose or false
    Zabbix.debug = _debug or false

    return Zabbix
end  -----  end of function Zabbix_mt:new  -----

------------------------------------------------------------------------
-- @name: Zabbix:set_credentials
-- @purpose: 
-- @description: {+DESCRIPTION+}
-- @params: credentials - {+DESCRIPTION+} ({+TYPE+})
-- @returns: {+RETURNS+}
------------------------------------------------------------------------

function Zabbix:set_credentials (credentials)
    if not self.username then
        if credentials.username or credentials[1] then
            self.username = credentials.username or credentials[1]
        else
            self.Log.warn('`credentials.username\' can\'t be empty', self.verbose)
            os.exit(1)
        end
    end

    if not self.password then
        if credentials.password or credentials[2] then
            self.password = credentials.password or credentials[2]
        else
            self.Log.warn('`credentials.password\' can\'t be empty', self.verbose)
            os.exit(1)
        end
    end
    self.login = function(userData)
    local request = self._request
        request.method = 'user.login'
        request.params.user = self.username
        request.params.password = self.password
        request.params.userData = userData or nil
        self:__call(request)
    end  -----  end of function Zabbix_mt:auth  -----
    return self
end  -----  end of function Zabbix_mt:set_credentials  -----


------------------------------------------------------------------------
-- @name: Zabbix:logout
-- @purpose: 
-- @description: {+DESCRIPTION+}
-- @params: -
-- @returns: {+RETURNS+}
------------------------------------------------------------------------

function Zabbix:logout ()
    local request = self._request
    request.method = 'user.logout'
    request.params = {}
    self:__call(request)
end  -----  end of function Zabbix_mt:auth  -----

------------------------------------------------------------------------
-- @name: Zabbix:__call
-- @purpose: 
-- @description: {+DESCRIPTION+}
-- @params: request - {+DESCRIPTION+} ({+TYPE+})
-- @returns: {+RETURNS+}
------------------------------------------------------------------------

function Zabbix:__call (request)
    local function httpPOST(query)
        local response_body = {}
        if not query then
            self.Log.warn(
                'Method name: `__call\', arguments: `query\' can\'t be empty', self.verbose
            )
            os.exit(-1)
        end
        if type(query) == 'table' then
            query = query
        else
            query = cjson.decode(query)
        end
        if self._request.auth then
            query.auth = self._request.auth
        end
        if not query.jsonrpc then
            query.jsonrpc = '2.0'
        end
        if not query.id then
            query.id = 1
        end
        query = cjson.encode(query)

        local headers = {}
        headers["Accept-Encoding"] = "gzip, deflate"
        headers["Content-Type"] = "application/json"
        headers["Content-Length"] = string.len(query)
        
        self.Log.debug('JSON-RPC Request: '..query, self.debug)

        http.request{
            url = self.url,
            method = "POST",
            headers = headers,
            source = ltn12.source.string(query),
            sink = ltn12.sink.table(response_body)
        }

        self.Log.debug('JSON-RPC Response: '..table.concat(response_body), self.debug)

        _response = cjson.decode(table.concat(response_body) or {})

        if request.method == 'user.login' and not self._request.auth then
            self._request.auth = _response.result or _response.result.sessionid
        end
    end
    
    httpPOST(request)
    ------------------------------------------------------------------------
    -- response.tprint
    -- Recursively print arbitrary data
    -- @param l - Set limit (default 100000) to stanch infinite loops (number)
    -- @param i - Indents tables as [KEY] VALUE, nested tables as [KEY] [KEY]...[KEY] VALUE (string)
    -- Set indent ("") to prefix each line:    Mytable [KEY] [KEY]...[KEY] VALUE
    -- @return
    ------------------------------------------------------------------------
    _response.tprint = function(l, i) -- recursive Print (structure, limit, indent)
        local function rPrint(s, l, i)
            l = (l) or 100000;
            i = i or ""; -- default item limit, indent string
            if (l < 1) then
                print "ERROR: Item limit reached.";
                return l - 1
            end;
            local ts = type(s);
            if (ts ~= "table") then
                print(i, ts, s);
                return l - 1
            end
            print(i, ts); -- print "table"
            for k, v in pairs(s) do -- print "[KEY] VALUE"
                if k ~= 'tprint' and k ~= 'pretty' then
                    l = rPrint(v, l, i .. "\t[" .. tostring(k) .. "]");
                end
                if (l < 0) then break end
            end
            return l
        end

        return rPrint(_response, l, i)
    end

    ------------------------------------------------------------------------
    -- @name: _response.pretty
    -- @purpose: 
    -- @description: {+DESCRIPTION+}
    -- @params: lf - {+DESCRIPTION+} ({+TYPE+})
    -- @params: id - {+DESCRIPTION+} ({+TYPE+})
    -- @params: ac - {+DESCRIPTION+} ({+TYPE+})
    -- @params: ec - {+DESCRIPTION+} ({+TYPE+})
    -- @returns: {+RETURNS+}
    ------------------------------------------------------------------------

    _response.pretty = function(lf, id, ac, ec)
        self:pretty(_response)
    end

    return _response
end  -----  end of function Zabbix_mt:__call  -----

------------------------------------------------------------------------
-- @name: Zabbix:pretty
-- @purpose: 
-- @description: {+DESCRIPTION+}
-- @params: _response - {+DESCRIPTION+} ({+TYPE+})
-- @params: lf - {+DESCRIPTION+} ({+TYPE+})
-- @params: id - {+DESCRIPTION+} ({+TYPE+})
-- @params: ac - {+DESCRIPTION+} ({+TYPE+})
-- @params: ec - {+DESCRIPTION+} ({+TYPE+})
-- @returns: {+RETURNS+}
------------------------------------------------------------------------

function Zabbix:pretty(_response, lf, id, ac, ec)
    local dt = {
        jsonrpc = '2.0',
        id = 1
    }
    if _response.result then
        dt.result = _response.result
    else
        dt.error = _response.error
    end
    local s, e = (ec or cjson.encode)(dt)
    if not s then
        return s, e
    end
    lf, id, ac = lf or "\n", id or "\t", ac or " "
    local i, j, k, n, r, p, q = 1, 0, 0, #s, {}, nil, nil
    local al = string.sub(ac, -1) == "\n"
    for x = 1, n do
        local c = string.sub(s, x, x)
        if not q and (c == "{" or c == "[") then
            r[i] = p == ":" and table.concat { c, lf } 
                or table.concat { string.rep(id, j), c, lf }
            j = j + 1
        elseif not q and (c == "}" or c == "]") then
            j = j - 1
            if p == "{" or p == "[" then
                i = i - 1
                r[i] = table.concat { string.rep(id, j), p, c }
            else
                r[i] = table.concat { lf, string.rep(id, j), c }
            end
        elseif not q and c == "," then
            r[i] = table.concat { c, lf }
            k = -1
        elseif not q and c == ":" then
            r[i] = table.concat { c, ac }
            if al then
                i = i + 1
                r[i] = string.rep(id, j)
            end
        else
            if c == '"' and p ~= "\\" then
                q = not q and true or nil
            end
            if j ~= k then
                r[i] = string.rep(id, j)
                i, k = i + 1, j
            end
            r[i] = c
        end
        p, i = c, i + 1
    end
    print(table.concat(r))
end

return Zabbix
