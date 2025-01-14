local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

--PopupLayer弹出框，需要屏蔽触摸及模糊背景

local PopupLayer=class("PopupLayer",cc.Layer)

function PopupLayer:ctor()
	ExternalFun.registerTouchEvent(self,true)
	self.darkBg=display.newLayer(cc.c4b(18,34,67,125))
	--local curScene=cc.Director:getInstance():getRunningScene()
	self:addChild(self.darkBg)
end

function PopupLayer:onExit()
	 self.darkBg:removeFromParent() --scene:addChild(self.darkBg) remove时有bug，why？
end

function PopupLayer:onTouchBegan(touch, event)
	return true
end

return PopupLayer