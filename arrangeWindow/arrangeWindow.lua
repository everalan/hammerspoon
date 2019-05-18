local arranger = hs.menubar.new()
arranger:setTooltip("排列窗口")
arranger:setTitle("排")
--arranger:setIcon(hs.image.iconForFile("/Users/everalan/wwwroot/hammerspoon/arrangeWindow/logo.png"))
menuData = {}
table.insert(menuData, {title="PhpStorm:Chrome 1:1", fn = function() dev() end})
table.insert(menuData, {title="访达全屏", fn = function() finder() end})
arranger:setMenu(menuData)

--for k,v in pairs(hs.window.visibleWindows()) do
--	print(v:application())
--end

function dev()
	layout1 = {
		{"Google Chrome", nil, nil, hs.layout.right50, nil, nil},
		{"PhpStorm", nil, nil, hs.layout.left50, nil, nil},
	}
	hs.layout.apply(layout1)
end

function finder()
	layout1 = {
		{"访达", nil, nil, hs.layout.maximized, nil, nil},
	}
	hs.layout.apply(layout1)
end