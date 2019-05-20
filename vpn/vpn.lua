local vpnMenubar = hs.menubar.new()
vpnMenubar:setTooltip("VPN管理")
vpnMenubar:setTitle("V")

local inInternet = false --是否连接外网

vpnPopulateMenu = function(key)
    local menuData = {}
    local code
    local state

    if inInternet == false then
        table.insert(menuData, {title="无网络连接", disabled=true})
    else
        code, state = hs.http.get('http://127.0.0.1:9501/state')
        if state == 'connected' then
            table.insert(menuData, {
                title="断开连接", 
                fn = function() 
                    hs.http.get('http://127.0.0.1:9501/disconnect')
                end
            })
        elseif state == 'reconnecting' then
            table.insert(menuData, {title="重新连接中", disabled=true})
            table.insert(menuData, {
                title="断开连接", 
                fn = function() 
                    hs.http.get('http://127.0.0.1:9501/disconnect')
                end
            })
        elseif state == 'disconnect' then
            table.insert(menuData, {
                title="连接", 
                fn = function() 
                    hs.http.get('http://127.0.0.1:9501/connect')
                end
            })
        else
            table.insert(menuData, {title="服务未启动", disabled=true})    
        end         
    end

    return menuData
end

hs.network.reachability.forHostName('baidu.com'):setCallback(function(self, flags)
    print("INTERNET " .. flags)
    if flags > 0 then
        inInternet = true
    else
        inInternet = false
    end
end):start()

vpnMenubar:setMenu(vpnPopulateMenu)