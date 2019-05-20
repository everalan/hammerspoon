--[[
管理openconnect启动,停止
]]--
local inInternet = false --是否连接外网
local iconLockedFile = '/Users/everalan/.hammerspoon/vpn/lock.png' --icon图标地址
local iconUnlockedFile = '/Users/everalan/.hammerspoon/vpn/unlock.png' --icon图标地址
local state = 'disconnect' --连接状态
local frequency = 10 --检查周期
local menubar = hs.menubar.new()
local iconLocked = hs.image.imageFromPath(iconLockedFile):setSize({w=16, h=16})
local iconUnocked = hs.image.imageFromPath(iconUnlockedFile):setSize({w=16, h=16})

local function getState()
    local code, state = hs.http.get('http://127.0.0.1:9501/state')
    if state == 'connected' then
        menubar:setIcon(iconLocked)    
    else
        menubar:setIcon(iconUnocked)    
    end         
    return state
end
local function connect()
    hs.http.get('http://127.0.0.1:9501/connect')
end
local function disconnect()
    hs.http.get('http://127.0.0.1:9501/disconnect')
end

local vpnPopulateMenu = function(key)
    local menuData = {}
    local code
    local state

    if inInternet == false then
        table.insert(menuData, {title="无网络连接", disabled=true})
    else
        state = getState()
        if state == 'connected' then
            table.insert(menuData, {
                title="断开连接", 
                fn = function() 
                    disconnect()
                end
            })
        elseif state == 'reconnecting' then
            table.insert(menuData, {title="重新连接中", disabled=true})
            table.insert(menuData, {
                title="断开连接", 
                fn = disconnect
            })
        elseif state == 'disconnect' then
            table.insert(menuData, {
                title="连接", 
                fn = function() 
                    connect()
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


menubar:setTooltip("VPN管理")
menubar:setIcon(iconUnocked)
menubar:setMenu(vpnPopulateMenu)

timer = hs.timer.new(frequency, getState)
timer:start()