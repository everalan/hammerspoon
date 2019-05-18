local vpnMenubar = hs.menubar.new()
vpnMenubar:setTooltip("VPN管理")
vpnMenubar:setTitle("V")

local inInternet = false --是否连接外网

vpnPopulateMenu = function(key)
    menuData = {}

    if inInternet == false then
        table.insert(menuData, {title="无网络连接", disabled=true})
    else
        state = io.popen('/opt/cisco/anyconnect/bin/vpn state|fgrep state|head -n 1|awk \'{print $4}\''):read("*all"):gsub("%s+", "")
        print(state == 'Connected')
        if state == 'Connected' then
            table.insert(menuData, {
                title="断开连接", 
                fn = function() 
                    io.popen('/opt/cisco/anyconnect/bin/vpn disconnect')
                end
            })
        elseif state == 'Reconnecting' then
            table.insert(menuData, {title="重新连接中", disabled=true})
        else
            table.insert(menuData, {
                title="连接", 
                fn = function() 
                    io.popen('/opt/cisco/anyconnect/bin/vpn connect vpn.everalan.com -s < /opt/cisco/anyconnect/login.txt')
                end
            })
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