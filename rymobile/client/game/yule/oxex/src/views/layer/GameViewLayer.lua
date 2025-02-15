local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

require("client/src/plaza/models/yl")
local cmd = appdf.req(appdf.GAME_SRC.."yule.oxex.src.models.CMD_Game")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local GameChatLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.game.GameChatLayer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

GameViewLayer.BT_PROMPT 			= 2
GameViewLayer.BT_OPENCARD 			= 3
GameViewLayer.BT_START 				= 4
GameViewLayer.BT_CALLBANKER 		= 5
GameViewLayer.BT_CANCEL 			= 6
GameViewLayer.BT_CHIP 				= 7
GameViewLayer.BT_CHIP1 				= 8
GameViewLayer.BT_CHIP2 				= 9
GameViewLayer.BT_CHIP3 				= 10
GameViewLayer.BT_CHIP4 				= 11

GameViewLayer.BT_SWITCH 			= 12
GameViewLayer.BT_EXIT 				= 13
GameViewLayer.BT_HELP				= 14
GameViewLayer.BT_CHAT 				= 15
GameViewLayer.BT_SOUND 				= 16
GameViewLayer.BT_CHANGETABLE		= 17
--GameViewLayer.BT_TAKEBACK 			= 16

GameViewLayer.FRAME 				= 1
GameViewLayer.NICKNAME 				= 2
GameViewLayer.SCORE 				= 3
GameViewLayer.FACE 					= 7

GameViewLayer.TIMENUM   			= 1
GameViewLayer.CHIPNUM 				= 1

--牌间距
GameViewLayer.CARDSPACING 			= 35

GameViewLayer.VIEWID_CENTER 		= 5

GameViewLayer.RES_PATH 				= "game/yule/oxex/res/"

local pointPlayer = {cc.p(170, 115), cc.p(897, 625)}
local pointCard = {cc.p(667, 110), cc.p(667, 617)}
local pointClock = {cc.p(display.cx, display.cy - 5), cc.p(1037, 640)}
local pointOpenCard = {cc.p(917, 115), cc.p(407, 625)}
local pointTableScore = {cc.p(667, 290), cc.p(667, 460)}
local pointBankerFlag = {cc.p(243, 208), cc.p(965, 715)}
local pointChat = {cc.p(230, 250), cc.p(767, 690)}
local ptWinLoseAnimate = {cc.p(170, 60), cc.p(897, 500)}
local pointUserInfo = {cc.p(205, 170), cc.p(445, 240)}
local anchorPoint = {cc.p(0, 0), cc.p(1, 1)}
local GameNotice = appdf.req(appdf.BASE_SRC .."app.views.layer.other.GameNotice")
local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")

local AnimationRes = 
{
	{name = "banker", file = GameViewLayer.RES_PATH.."animation_banker/banker_", nCount = 11, fInterval = 0.2, nLoops = 1},
	{name = "faceFlash", file = GameViewLayer.RES_PATH.."animation_faceFlash/faceFlash_", nCount = 2, fInterval = 0.6, nLoops = -1},
	{name = "lose", file = GameViewLayer.RES_PATH.."animation_lose/lose_", nCount = 17, fInterval = 0.1, nLoops = 1},
	{name = "start", file = GameViewLayer.RES_PATH.."animation_start/start_", nCount = 11, fInterval = 0.15, nLoops = 1},
	{name = "victory", file = GameViewLayer.RES_PATH.."animation_victory/victory_", nCount = 17, fInterval = 0.13, nLoops = 1},
	{name = "yellow", file = GameViewLayer.RES_PATH.."animation_yellow/yellow_", nCount = 5, fInterval = 0.2, nLoops = 1},
	{name = "blue", file = GameViewLayer.RES_PATH.."animation_blue/blue_", nCount = 5, fInterval = 0.2, nLoops = 1}
}

function GameViewLayer:onInitData()
	self.bCardOut = {false, false, false, false, false}
	self.lUserMaxScore = {0, 0, 0, 0}
	self.chatDetails = {}
	self.bCanMoveCard = false
	self.isChange = true
end

function GameViewLayer:onExit()
	print("GameViewLayer onExit")
	self._laba:closeTime()
	cc.Director:getInstance():getTextureCache():removeTextureForKey(GameViewLayer.RES_PATH.."card.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(GameViewLayer.RES_PATH.."game_oxnew_res.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey(GameViewLayer.RES_PATH.."game_oxnew_res.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

local this
function GameViewLayer:ctor(scene)
	this = self
	self._scene = scene

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --用户信息改变事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create("ry_GetGameNotice", handler(self, self.NoticeCallBack)),
        self
		)
		
	self:onInitData()
	self:preloadUI()

	--节点事件
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	display.newSprite(GameViewLayer.RES_PATH.."background.png")
		:move(display.center)
		:addTo(self)

	--房间名
	local roomnamebg = display.newSprite(GameViewLayer.RES_PATH.."sp_room_bg.png")
		:move(display.cx,display.cy - 70)
		:setVisible(true)
		:addTo(self)
	local txt_GameRoomName = cc.Label:createWithTTF("","fonts/round_body.ttf",24)
		:move(roomnamebg:getContentSize().width / 2, roomnamebg:getContentSize().height / 2)
		:setColor(cc.c3b(40,70,0))
		:addTo(roomnamebg)

	if GlobalUserItem.oxexRoomName then
		txt_GameRoomName:setString(GlobalUserItem.oxexRoomName)
	else
		roomnamebg:setVisible(false)
	end

	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    --特殊按钮
    local pointBtSwitch = cc.p(yl.WIDTH - 60, yl.HEIGHT - 60)
	-- self.btTakeBack = ccui.Button:create("bt_takeBack_0.png", "bt_takeBack_1.png", "", ccui.TextureResType.plistType)
	-- 	:move(pointBtSwitch)
	-- 	:setTag(GameViewLayer.BT_TAKEBACK)
	-- 	:setTouchEnabled(false)
	-- 	:addTo(self)
	-- self.btTakeBack:addTouchEventListener(btcallback)

	local bAble = GlobalUserItem.bSoundAble or GlobalUserItem.bVoiceAble					--声音
	if GlobalUserItem.bVoiceAble then
		AudioEngine.playMusic(GameViewLayer.RES_PATH.."sound/backMusic.mp3", true)
	end
	self.btSound = ccui.CheckBox:create("bt_sound_0.png",
										"bt_sound_1.png",
										"bt_soundOff_0.png",
										"bt_soundOff_1.png", 
										"bt_soundOff_1.png", ccui.TextureResType.plistType)
		:move(cc.p(1160,700))
		:setTag(GameViewLayer.BT_SOUND)
		:setTouchEnabled(true)
		:setSelected(not bAble)
		:setVisible(false)
		:addTo(self)
	self.btSound:addTouchEventListener(btcallback)

	self.btChat = ccui.Button:create(GameViewLayer.RES_PATH.."bt_chat_0.png", GameViewLayer.RES_PATH.."bt_chat_1.png")
		:move(cc.p(1265,700))
		:setTag(GameViewLayer.BT_CHAT)
		:setTouchEnabled(true)
		:setVisible(false)
		:addTo(self)
	self.btChat:addTouchEventListener(btcallback)

	self.btSwitch = ccui.Button:create("bt_switch_0.png", "bt_switch_1.png", "", ccui.TextureResType.plistType)
		:move(cc.p(65,700))
		:setTag(GameViewLayer.BT_SWITCH)
		:addTo(self)
	self.btSwitch:addTouchEventListener(btcallback)

	self.btPanel = display.newSprite(GameViewLayer.RES_PATH.."sp_buttonBg.png")--cc.Sprite:createWithSpriteFrameName("sp_menubg.png")
		:move(cc.p(30,665))
		:setAnchorPoint(cc.p(0,1))
		:setVisible(false)
		:setScale(0)
		:addTo(self)

	self.btExit = ccui.Button:create("bt_takeBack_0.png", "bt_takeBack_1.png", "", ccui.TextureResType.plistType)
		:move(cc.p(91,168))
		:setTag(GameViewLayer.BT_EXIT)
		:setTouchEnabled(false)
		:addTo(self.btPanel)
	self.btExit:addTouchEventListener(btcallback)

	self.btHelp = ccui.Button:create("bt_help_0.png", "bt_help_1.png", "", ccui.TextureResType.plistType)
		:move(cc.p(91,105))
		:setTag(GameViewLayer.BT_HELP)
		:addTo(self.btPanel)
	self.btHelp:addTouchEventListener(btcallback)

	self.btnChangeTable = ccui.Button:create(GameViewLayer.RES_PATH.."bt_hz_0.png",GameViewLayer.RES_PATH.."bt_hz_1.png")
		:move(cc.p(91,42))
		:setTag(GameViewLayer.BT_CHANGETABLE)
		:addTo(self.btPanel)
	self.btnChangeTable:addTouchEventListener(btcallback)

	self.sp_help = display.newSprite(GameViewLayer.RES_PATH.."help.png")
		:move(display.center)
		:setVisible(false)
		:setScale(0)
		:addTo(self,100)
	ccui.Button:create(GameViewLayer.RES_PATH.."btn_help_close.png")
		:move(cc.p(610,505))
		:addTo(self.sp_help)
		:addClickEventListener(function()
			self:helpAnimate()
			end)
	--普通按钮
	-- self.btPrompt = ccui.Button:create("bt_prompt_0.png", "bt_prompt_1.png", "", ccui.TextureResType.plistType)
	-- 	:move(yl.WIDTH - 163, 60)
	-- 	:setTag(GameViewLayer.BT_PROMPT)
	-- 	:setVisible(false)
	-- 	:addTo(self)
	-- self.btPrompt:addTouchEventListener(btcallback)

	self.btOpenCard = ccui.Button:create("bt_showCard_0.png", "bt_showCard_1.png", "", ccui.TextureResType.plistType)
		:move(yl.WIDTH - 163, 112)
		:setTag(GameViewLayer.BT_OPENCARD)
		:setVisible(false)
		:addTo(self)
	self.btOpenCard:addTouchEventListener(btcallback)

	self.btStart = ccui.Button:create(GameViewLayer.RES_PATH.."bt_start_0.png", GameViewLayer.RES_PATH.."bt_start_1.png")
		:move(yl.WIDTH - 163, 112)
		:setVisible(false)
		:setTag(GameViewLayer.BT_START)
		:addTo(self)
	self.btStart:addTouchEventListener(btcallback)

	self.btCallBanker = ccui.Button:create("bt_callBanker_0.png", "bt_callBanker_1.png", "", ccui.TextureResType.plistType)
		:move(display.cx + 150, 250)
		:setTag(GameViewLayer.BT_CALLBANKER)
		:setVisible(false)
		:addTo(self)
	self.btCallBanker:addTouchEventListener(btcallback)

	self.btCancel = ccui.Button:create("bt_cancel_0.png", "bt_cancel_1.png", "", ccui.TextureResType.plistType)
		:move(display.cx - 150, 250)
		:setTag(GameViewLayer.BT_CANCEL)
		:setVisible(false)
		:addTo(self)
	self.btCancel:addTouchEventListener(btcallback)

	--四个下注的筹码按钮
	self.btChip = {}
	for i = 1, 4 do
		self.btChip[i] = ccui.Button:create("bt_chip_0.png", "bt_chip_1.png", "", ccui.TextureResType.plistType)
			:move(420 + 165*(i - 1), 253)
			:setTag(GameViewLayer.BT_CHIP + i)
			:setVisible(false)
			:addTo(self)
		self.btChip[i]:addTouchEventListener(btcallback)
		--cc.LabelAtlas:_create("123456", GameViewLayer.RES_PATH.."num_chip.png", 17, 24, string.byte("0"))
		cc.Label:createWithTTF("123456", "fonts/round_body.ttf", 28)
			:move(self.btChip[i]:getContentSize().width/2, self.btChip[i]:getContentSize().height/2 + 5)
			:setAnchorPoint(cc.p(0.5, 0.5))
			:setTag(GameViewLayer.CHIPNUM)
			:addTo(self.btChip[i])
	end

	self.txt_CellScore = cc.Label:createWithTTF("底注：0","fonts/round_body.ttf",24)
		:move(1040, yl.HEIGHT - 20)
		:setVisible(false)
		:addTo(self)
	self.txt_TableID = cc.Label:createWithTTF("桌号：","fonts/round_body.ttf",24)
		:move(293, yl.HEIGHT - 20)
		:setVisible(false)
		:addTo(self)

	--牌提示背景
	self.spritePrompt = display.newSprite("#prompt.png")
		:move(display.cx, display.cy - 108)
		:setVisible(false)
		:addTo(self)
	--牌值
	self.labAtCardPrompt = {}
	for i = 1, 3 do
		self.labAtCardPrompt[i] = cc.LabelAtlas:_create("", GameViewLayer.RES_PATH.."num_prompt.png", 23, 34, string.byte("0"))
			:move(72 + 162*(i - 1), 25)
			:setAnchorPoint(cc.p(0.5, 0.5))
			:addTo(self.spritePrompt)
	end
	self.labCardType = cc.Label:createWithTTF("", "fonts/round_body.ttf", 34)
		:move(568, 25)
		:addTo(self.spritePrompt)

	--时钟
	self.spriteClock = display.newSprite("#sprite_clock.png")
		:move(display.cx, display.cy - 5)
		:setVisible(false)
		:addTo(self)
	local labAtTime = cc.LabelAtlas:_create("", GameViewLayer.RES_PATH.."num_time.png", 26, 47, string.byte("0"))
		:move(self.spriteClock:getContentSize().width/2, self.spriteClock:getContentSize().height/2)
		:setAnchorPoint(cc.p(0.5, 0.5))
		:setScale(0.7)
		:setTag(GameViewLayer.TIMENUM)
		:addTo(self.spriteClock)
	--用于发牌动作的那张牌
	self.animateCard = display.newSprite(GameViewLayer.RES_PATH.."card.png")
		:move(display.center)
		:setVisible(false)
		:setLocalZOrder(2)
		:addTo(self)
	local cardWidth = self.animateCard:getContentSize().width/13
	local cardHeight = self.animateCard:getContentSize().height/5
	self.animateCard:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))

	--提示
	self.sp_callBakerLoad = display.newSprite(GameViewLayer.RES_PATH.."sp_callbankload.png")
		:move(display.cx, display.cy - 75)
		:setVisible(false)
		:addTo(self,1)
	self.sp_betLoad = display.newSprite(GameViewLayer.RES_PATH.."sp_betload.png")
		:move(display.cx, display.cy - 75)
		:setVisible(false)
		:addTo(self,1)
	self.sp_openCardLoad = display.newSprite(GameViewLayer.RES_PATH.."sp_opencardload.png")
		:move(display.cx, display.cy - 75)
		:setVisible(false)
		:addTo(self,1)

	--四个玩家
	self.nodePlayer = {}
	for i = 1 ,cmd.GAME_PLAYER do
		--玩家结点
		self.nodePlayer[i] = cc.Node:create()
			:move(pointPlayer[i])
			:setVisible(false)
			:addTo(self)
		--人物框
		local spriteFrame = display.newSprite(GameViewLayer.RES_PATH.."oxex_frame.png")
			:setTag(GameViewLayer.FRAME)
			:addTo(self.nodePlayer[i])
		--昵称
		self.nicknameConfig = string.getConfig("fonts/round_body.ttf", 20)
		cc.Label:createWithTTF("小白狼大白兔", "fonts/round_body.ttf", 20)
			:move(-55, -33)
			:setAnchorPoint(cc.p(0, 0.5))
			--:setScaleX(0.8)
			--:setColor(cc.c3b(0, 0, 0))
			:setTag(GameViewLayer.NICKNAME)
			:addTo(self.nodePlayer[i])
		--金币
		--cc.LabelAtlas:_create("123456", GameViewLayer.RES_PATH.."num_score.png", 15, 15, string.byte("0"))
		cc.Label:createWithTTF("123456", "fonts/round_body.ttf", 20)
			:move(-35, -64)
			:setAnchorPoint(cc.p(0, 0.5))
			:setColor(cc.c3b(255,220,0))
			:setTag(GameViewLayer.SCORE)
			:addTo(self.nodePlayer[i])
	end

	

	--牌背景
	self.spriteCardBG = display.newSprite("#cardBG.png")
		:move(display.cx, 110)
		:setVisible(false)
		:addTo(self)

	self.bBtnInOutside = false
	--牌节点
	self.nodeCard = {}
	--牌的类型
	self.cardType = {}
	--桌面金币
	self.tableScore = {}
	--准备标志
	self.flag_ready = {}
	--摊牌标志
	self.flag_openCard = {}
	--性别记录
	self.userGender = {}
	for i = 1, cmd.GAME_PLAYER do
		--牌
		self.nodeCard[i] = cc.Node:create()
			:move(pointCard[i])
			:setAnchorPoint(cc.p(0.5, 0.5))
			:addTo(self)
		for j = 1, 5 do
			local card = display.newSprite(GameViewLayer.RES_PATH.."card.png")
				:setTag(j)
				:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
				:setVisible(false)
				:addTo(self.nodeCard[i])
		end
		--牌型
		self.cardType[i] = display.newSprite("#ox_10.png")
			:move(cc.p(pointCard[i].x,pointCard[i].y - 35))
			:setVisible(false)
			:setScale(0.8)
			:addTo(self)
		--桌面金币
		self.tableScore[i] = ccui.Button:create(GameViewLayer.RES_PATH.."score_bg.png")
			:move(pointTableScore[i])
			:setEnabled(false)
			:setBright(true)
			:setVisible(false)
			:setTitleText("0")
			:setTitleColor(cc.c3b(20, 125, 0))
			:setTitleFontSize(20)
			:addTo(self)
		--准备
		self.flag_ready[i] = display.newSprite("#sprite_prompt.png")
			:move(pointCard[i].x,pointCard[i].y + 20)
			:setVisible(false)
			:addTo(self)
		--摊牌
		self.flag_openCard[i] = display.newSprite("#sprite_openCard.png")
			:move(pointOpenCard[i])
			:setVisible(false)
			:addTo(self)
	end

	self.nodeLeaveCard = cc.Node:create():addTo(self)

	self.spriteBankerFlag = display.newSprite()
		:setVisible(false)
		:setLocalZOrder(2)
		:addTo(self)

	--聊天框
    self._chatLayer = GameChatLayer:create(self._scene._gameFrame)
    self._chatLayer:addTo(self)
	--聊天泡泡
	self.chatBubble = {}
	for i = 1 , cmd.GAME_PLAYER do
		if i == cmd.MY_VIEWID then
		self.chatBubble[i] = display.newSprite(GameViewLayer.RES_PATH.."game_chat_lbg.png", {scale9 = true ,capInsets=cc.rect(0, 0, 180, 110)})
			:setAnchorPoint(cc.p(0,0.5))
			:move(pointChat[i])
			:setVisible(false)
			:addTo(self, 2)
		else
		self.chatBubble[i] = display.newSprite(GameViewLayer.RES_PATH.."game_chat_rbg.png", {scale9 = true ,capInsets=cc.rect(0, 0, 180, 110)})
			:setAnchorPoint(cc.p(1,0.5))
			:move(pointChat[i])
			:setVisible(false)
			:addTo(self, 2)
		end
	end
	--点击事件
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(function(eventType, x, y)
		if eventType == "ended" then
			self:onEventTouchCallback(x, y)
		end
		return true
	end)

	self._laba =  GameNotice:create("",cc.p(667,630))
	self._laba:addTo(self)

end

function GameViewLayer:onResetView()
	self.nodeLeaveCard:removeAllChildren()
	self.spriteBankerFlag:setVisible(false)
	self.spriteCardBG:setVisible(false)
	--重排列牌
	local cardWidth = self.animateCard:getContentSize().width
	local cardHeight = self.animateCard:getContentSize().height
	for i = 1, cmd.GAME_PLAYER do
		local fSpacing		--牌间距
		local fX 			--起点
		local fWidth 		--宽度
		--以上三个数据是保证牌节点的坐标位置位于其下五张牌的正中心
		if i == cmd.MY_VIEWID then
			fSpacing = 130
			fX = fSpacing/2
			fWidth = fSpacing*5
		else
			fSpacing = GameViewLayer.CARDSPACING
			fX = cardWidth/2
			fWidth = cardWidth + fSpacing*4
		end
		self.nodeCard[i]:setContentSize(cc.size(fWidth, cardHeight))
		for j = 1, 5 do
			local card = self.nodeCard[i]:getChildByTag(j)
				:move(fX + fSpacing*(j - 1), cardHeight/2)
				:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
				:setVisible(false)
				:setLocalZOrder(1)
		end
		self.tableScore[i]:setVisible(false)
		self.cardType[i]:setVisible(false)
	end
	self.bCardOut = {false, false, false, false, false}
	self.labCardType:setString("")
	for i = 1, 3 do
		self.labAtCardPrompt[i]:setString("")
	end
end

function GameViewLayer:NoticeCallBack( event )
	
	local msg  =  event._usedata["NoticeMsg"]
	
	if self._laba ~=nil then
		self._laba:addTrugTxt(msg)
	end
	
end
	
--更新用户显示
function GameViewLayer:OnUpdateUser(viewId, userItem)
	if not viewId or viewId == yl.INVALID_CHAIR then
		print("OnUpdateUser viewId is nil")
		return
	end
	local head = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.FACE)
	if not userItem then
		self.nodePlayer[viewId]:setVisible(false)
		self.flag_ready[viewId]:setVisible(false)
		if head then
			head:setVisible(false)
		end
	else
		self.nodePlayer[viewId]:setVisible(true)

		self:setNickname(viewId, userItem.szNickName)
		self:setScore(viewId, userItem.lScore)
		self.userGender[viewId] = userItem.cbGender
		self.flag_ready[viewId]:setVisible(yl.US_READY == userItem.cbUserStatus)
		if viewId == 1 and yl.US_READY == userItem.cbUserStatus then
			self.isChange = false
		end
		if not head then
			head = PopupInfoHead:createNormal(userItem, 78)
			head:setPosition(1, 29)
			head:enableHeadFrame(false)
			head:enableInfoPop(false, pointUserInfo[viewId], anchorPoint[viewId])
			head:setTag(GameViewLayer.FACE)
			self.nodePlayer[viewId]:addChild(head)

			--遮盖层，美化头像
			--display.newSprite(GameViewLayer.RES_PATH.."oxex_frameTop.png")
				--:move(1, 1)
			--	:addTo(head)

		else
			head:updateHead(userItem)
		end
		head:setVisible(true)
	end
end

--****************************      计时器        *****************************--
function GameViewLayer:OnUpdataClockView(viewId, time)
	if not viewId or viewId == yl.INVALID_CHAIR or not time then
		self.spriteClock:getChildByTag(GameViewLayer.TIMENUM):setString("")
		self.spriteClock:setVisible(false)
	else
		self.spriteClock:getChildByTag(GameViewLayer.TIMENUM):setString(time)
	end
end

function GameViewLayer:setClockPosition(viewId)
	--[[if viewId then
		self.spriteClock:move(pointClock[viewId])
	else
		self.spriteClock:move(display.cx, display.cy + 50)
	end]]
    self.spriteClock:setVisible(true)
end

--**************************      点击事件        ****************************--
--用于触发手牌的点击事件
function GameViewLayer:onEventTouchCallback(x, y)
	--按钮滚回
	if self.bBtnInOutside then
		self:onButtonSwitchAnimate(true)
	end

	--帮助
	if self.sp_help:isVisible() then
		self:helpAnimate()
	end

	-- --聊天框
	-- if self._chatLayer:isVisible() then
	-- 	self._chatLayer:showGameChat(false)
	-- end

	--牌可点击
	if self.bCanMoveCard == true then
		local size1 = self.nodeCard[cmd.MY_VIEWID]:getContentSize()
		local x1, y1 = self.nodeCard[cmd.MY_VIEWID]:getPosition()
		for i = 1, 5 do
			local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
			local x2, y2 = card:getPosition()
			local size2 = card:getContentSize()
			local rect = card:getTextureRect()
			rect.x = x1 - size1.width/2 + x2 - size2.width/2
			rect.y = y1 - size1.height/2 + y2 - size2.height/2
			if cc.rectContainsPoint(rect, cc.p(x, y)) then
				if false == self.bCardOut[i] then
					card:move(x2, y2 + 30)
				elseif true == self.bCardOut[i] then
					card:move(x2, y2 - 30)
				end
				self.bCardOut[i] = not self.bCardOut[i]
				self:updateCardPrompt()
				return
			end
		end
	end

end

--按钮点击事件
function GameViewLayer:onButtonClickedEvent(tag,ref)
	if tag == GameViewLayer.BT_EXIT then
		self._scene:onQueryExitGame()
	elseif tag == GameViewLayer.BT_OPENCARD then
		self.bCanMoveCard = false
		self.btOpenCard:setVisible(false)
		--self.btPrompt:setVisible(false)
		self.spritePrompt:setVisible(false)
		self.spriteCardBG:setVisible(false)

		self._scene:onOpenCard()
	elseif tag == GameViewLayer.BT_PROMPT then
		self:promptOx()
	elseif tag == GameViewLayer.BT_START then
		self.btStart:setVisible(false)
		self._scene:onStartGame()
	elseif tag == GameViewLayer.BT_CALLBANKER then
		self.btCallBanker:setVisible(false)
		self.btCancel:setVisible(false)
		self._scene:onBanker(1)
	elseif tag == GameViewLayer.BT_CANCEL then
		self.btCallBanker:setVisible(false)
		self.btCancel:setVisible(false)
		self._scene:onBanker(0)
	elseif tag - GameViewLayer.BT_CHIP == 1 or
			tag - GameViewLayer.BT_CHIP == 2 or
			tag - GameViewLayer.BT_CHIP == 3 or
			tag - GameViewLayer.BT_CHIP == 4 then
		for i = 1, 4 do
			self.btChip[i]:setVisible(false)
		end
		local index = tag - GameViewLayer.BT_CHIP
		self._scene:onAddScore(self.lUserMaxScore[index])
	elseif tag == GameViewLayer.BT_CHAT then
		self._chatLayer:showGameChat(true)
	elseif tag == GameViewLayer.BT_SWITCH then
		print("BT_SWITCH")
		self:onButtonSwitchAnimate()
	elseif tag == GameViewLayer.BT_SOUND then
		local effect = not (GlobalUserItem.bSoundAble or GlobalUserItem.bVoiceAble)
		if effect == true then
			AudioEngine.playMusic(GameViewLayer.RES_PATH.."sound/backMusic.mp3", true)
		end
		GlobalUserItem.setSoundAble(effect)
		GlobalUserItem.setVoiceAble(effect)
		print("BT_SOUND", effect)
	-- elseif tag == GameViewLayer.BT_TAKEBACK then
	-- 	print("BT_TAKEBACK")
	-- 	self:onButtonSwitchAnimate(true)
	elseif tag == GameViewLayer.BT_HELP then
		self:helpAnimate()
	elseif tag == GameViewLayer.BT_CHANGETABLE then
		local chairid = self._scene:GetMeChairID() + 1
		if self._scene.cbPlayStatus[chairid] ~= 0 then
			showToast(nil,"游戏中不允许换桌!",1)
			return
		end
		if self.isChange == false then
			showToast(nil,"您已准备喽，请耐心等待一下吧！",1)
			return
		end
		self._scene:onUserChangeTalbe()
		self.btnChangeTable:setTouchEnabled(false)	
	else
		showToast(self,"功能尚未开放！",1)
	end
end

function GameViewLayer:onButtonSwitchAnimate(bTakeBack)
	--[[local fInterval = 0.15
	local spacing = 100
	local originX, originY = self.btSwitch:getPosition()
	for i = GameViewLayer.BT_EXIT, GameViewLayer.BT_SOUND do
		local nCount = i - GameViewLayer.BT_EXIT + 1
		local button = self:getChildByTag(i)
		button:setTouchEnabled(false)
		--算时间和距离
		local time = fInterval*nCount
		local pointTarget = cc.p(0, spacing*nCount)

		local fRotate = 720
		if not bTakeBack then 			--按钮滚出(否则滚回)
			fRotate = -fRotate
			pointTarget = cc.p(-pointTarget.x, -pointTarget.y)
		end

		button:runAction(cc.Sequence:create(
			cc.Spawn:create(cc.MoveBy:create(time, pointTarget), cc.RotateBy:create(time, fRotate)),
			cc.CallFunc:create(function()
				if not bTakeBack then
					button:setTouchEnabled(true)
					self.bBtnInOutside = true
				else
					self.bBtnInOutside = false
				end
			end)))
	end
	if not bTakeBack then
		self.btSwitch:setTouchEnabled(false)
	else
		self.btSwitch:setTouchEnabled(true)
	end]]
	local time = 0.2
	local helpshow = self.btPanel:isVisible()
	local scaleLv = helpshow and 0 or 1
	self.btPanel:setVisible(true)

	--简单的缩放功能
	self.btPanel:runAction(cc.Sequence:create(
						   cc.ScaleTo:create(time,scaleLv),
						   cc.CallFunc:create(function()
						   		self.bBtnInOutside = not helpshow
						   		self.btExit:setTouchEnabled(self.bBtnInOutside)
						   		self.btHelp:setTouchEnabled(self.bBtnInOutside)
						   		self.btPanel:setVisible(not helpshow)
						   end)))
end

function GameViewLayer:showGameTips(cbGameStatus)
	self.sp_callBakerLoad:setVisible(cbGameStatus == cmd.GS_TK_CALL)
	self.sp_betLoad:setVisible(cbGameStatus == cmd.GS_TK_SCORE)
	self.sp_openCardLoad:setVisible(cbGameStatus == cmd.GS_TK_PLAYING)
end

function GameViewLayer:gameCallBanker(callBankerViewId, bFirstTimes)

    if callBankerViewId == cmd.MY_VIEWID  and bFirstTimes ~= true then
        self.btCallBanker:setVisible(true)
        self.btCancel:setVisible(true)
        --self:showGameTips(nil)
    elseif callBankerViewId ~= cmd.MY_VIEWID  and bFirstTimes ~= true then
        --self:showGameTips(cmd.GS_TK_CALL)
    end

    if bFirstTimes then
		local startAnime = 	display.newSprite()
			:move(display.center)
			:addTo(self)
			--:runAction(self:getAnimate("start", true))
    	AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_START.WAV")

    	local animation = cc.AnimationCache:getInstance():getAnimation("start")
		local animate = cc.Animate:create(animation)

		animate = cc.Sequence:create(animate, cc.CallFunc:create(function(ref)
				ref:removeFromParent()  
                if callBankerViewId == cmd.MY_VIEWID then
                	self.btCallBanker:setVisible(true)
                	self.btCancel:setVisible(true)
                	--self:showGameTips(nil)
                else
                	--self:showGameTips(cmd.GS_TK_CALL)
				end
			end))

        startAnime:runAction(animate)
    end
end

function GameViewLayer:gameStart(bankerViewId)
    if bankerViewId ~= cmd.MY_VIEWID then
        for i = 1, 4 do
            self.btChip[i]:setVisible(true)
        end
        self:showGameTips(nil)
    else
    	self:showGameTips(cmd.GS_TK_SCORE)
    end
end

function GameViewLayer:gameAddScore(viewId, score)
	self.tableScore[viewId]:setTitleText(score)
	self.tableScore[viewId]:setVisible(true)
    local labelScore = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SCORE)
    
    local lScore = labelScore:getString()
    print(lScore)
    if string.len(lScore) >= 4 then
		lScore = (string.gsub(lScore, ",", ""))
	end	
	lScore = tonumber(lScore)
	print(lScore)
    self:setScore(viewId, lScore - score)
end

function GameViewLayer:gameSendCard(firstViewId, totalCount)
	--开始发牌
	self.spriteCardBG:setVisible(true)
	self:showGameTips(nil)
	self:runSendCardAnimate(firstViewId, totalCount)
end

--开牌
function GameViewLayer:gameOpenCard(wViewChairId, cbOx)
	local cardWidth = self.animateCard:getContentSize().width
	local cardHeight = self.animateCard:getContentSize().height
	local fSpacing = GameViewLayer.CARDSPACING
	local fWidth
	if cbOx > 0 then
		fWidth = cardWidth + fSpacing*2
	else
		fWidth = cardWidth + fSpacing*4
	end
	--牌的排列
	self.nodeCard[wViewChairId]:setContentSize(cc.size(fWidth, cardHeight))
	for i = 1, 5 do
        local card = self.nodeCard[wViewChairId]:getChildByTag(i)
		if wViewChairId == cmd.MY_VIEWID then
			card:move(cardWidth/2 + fSpacing*(i - 1), cardHeight/2)
		end

		if cbOx > 0 and i >= 4 then
			local positionX, positionY = card:getPosition()
			positionX = positionX - (fSpacing*2 + fSpacing/2)
			positionY = positionY + 50
			card:move(positionX, positionY)
			card:setLocalZOrder(0)
		end
	end

	--牌型
	if cbOx >= 10 then
		--AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_OXOX.wav")
		cbOx = 10
	end
	if wViewChairId == cmd.MY_VIEWID then
		self:showGameTips(cmd.GS_TK_PLAYING)
	else
		self:showGameTips(nil)
		self:playSound(wViewChairId,cbOx)
	end

	local strFile = string.format("ox_%d.png", cbOx)
	local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strFile)
	self.cardType[wViewChairId]:setSpriteFrame(spriteFrame)
	self.cardType[wViewChairId]:setVisible(true)
	--隐藏摊牌图标
    self:setOpenCardVisible(wViewChairId, false)
end

function GameViewLayer:playSound( wViewChairId,cbox )
	local Gender = self.userGender[wViewChairId]
	local soundfile = string.format("sound/oxex_%d_%d.mp3",Gender,cbox)
	AudioEngine.playEffect(GameViewLayer.RES_PATH..soundfile)
end

function GameViewLayer:gameEnd(bMeWin)
	local name
	if bMeWin then
		name = "victory"
		AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_WIN.WAV")
	else
		name = "lose"
		AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_LOST.WAV")
	end

    self.btStart:setVisible(true)
    --提示内容隐藏
    self:showGameTips(nil)
    --逃跑 按钮隐藏
    self.btCallBanker:setVisible(false)
	self.btCancel:setVisible(false)

    for i = 1, 4 do
		self.btChip[i]:setVisible(false)
	end


	display.newSprite()
		:move(display.center)
		:addTo(self)
		:runAction(self:getAnimate(name, true))
end

function GameViewLayer:gameScenePlaying()
    self.btOpenCard:setVisible(true)
    --self.btPrompt:setVisible(true)
    --self.spritePrompt:setVisible(true)
end

function GameViewLayer:setCellScore(cellscore)
	if not cellscore then
		self.txt_CellScore:setString("底注：")
	else
		self.txt_CellScore:setString("底注："..cellscore)
	end
end

function GameViewLayer:setTableID(id)
	if not id or id == yl.INVALID_TABLE then
		self.txt_TableID:setString("桌号：")
	else
		self.txt_TableID:setString("桌号："..(id + 1))
	end
end

function GameViewLayer:setCardTextureRect(viewId, tag, cardValue, cardColor)
	if viewId < 1 or viewId > 4 or tag < 1 or tag > 5 then
		print("card texture rect error!")
		return
	end
	
	local card = self.nodeCard[viewId]:getChildByTag(tag)
	local rectCard = card:getTextureRect()
	rectCard.x = rectCard.width*(cardValue - 1)
	rectCard.y = rectCard.height*cardColor
	card:setTextureRect(rectCard)
end

function GameViewLayer:setNickname(viewId, strName)
	local name = string.EllipsisByConfig(strName, 133, self.nicknameConfig)
	local labelNickname = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.NICKNAME)
	labelNickname:setString(name)

	-- local labelWidth = labelNickname:getContentSize().width
	-- if labelWidth > 113 then
	-- 	labelNickname:setScaleX(113/labelWidth)
	-- elseif labelNickname:getScaleX() ~= 1 then
	-- 	labelNickname:setScaleX(1)
	-- end
end

function GameViewLayer:setScore(viewId, lScore)
	local labelScore = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SCORE)
	labelScore:setString(ExternalFun.numberThousands(tonumber(lScore)))

	local labelWidth = labelScore:getContentSize().width
	if labelWidth > 98 then
		labelScore:setScaleX(98/labelWidth)
	elseif labelScore:getScaleX() ~= 1 then
		labelScore:setScaleX(1)
	end
end

function GameViewLayer:setUserScore(wViewChairId, lScore)
	self.nodePlayer[wViewChairId]:getChildByTag(GameViewLayer.SCORE):setString(ExternalFun.numberThousands(tonumber(lScore)))
end

function GameViewLayer:setReadyVisible(wViewChairId, isVisible)
	self.flag_ready[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setOpenCardVisible(wViewChairId, isVisible)
	self.flag_openCard[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setTurnMaxScore(lTurnMaxScore)
	for i = 4, 1, -1 do
		self.lUserMaxScore[i] = math.max(lTurnMaxScore, 1)
		self.btChip[i]:getChildByTag(GameViewLayer.CHIPNUM):setString(self.lUserMaxScore[i])
		lTurnMaxScore = math.floor(lTurnMaxScore/2)
	end
end

function GameViewLayer:setBankerUser(wViewChairId)
	self.spriteBankerFlag:move(pointBankerFlag[wViewChairId])
	self.spriteBankerFlag:setVisible(true)
	self.spriteBankerFlag:runAction(self:getAnimate("banker"))
	self:showGameTips(nil)
	----闪烁动画
	-- display.newSprite()
	-- 	:move(pointPlayer[wViewChairId].x + 2, pointPlayer[wViewChairId].y - 12)
	-- 	:addTo(self)
	-- 	:runAction(self:getAnimate("faceFlash", true))
end

function GameViewLayer:setUserTableScore(wViewChairId, lScore)
	if lScore == 0 then
		return
	end

	self.tableScore[wViewChairId]:setTitleText(lScore)
	self.tableScore[wViewChairId]:setVisible(true)
end


--发牌动作
function GameViewLayer:runSendCardAnimate(wViewChairId, nCount)
	if nCount == cmd.GAME_PLAYER*5 then
		self.animateCard:setVisible(true)
	elseif nCount < 1 then
		self.bCanMoveCard = true
		self.animateCard:setVisible(false)
		self.btOpenCard:setVisible(true)
		--self.btPrompt:setVisible(true)
		--self.spritePrompt:setVisible(true)
		self._scene:sendCardFinish()
		return
	end

	local pointMove = {cc.p(0, -180), cc.p(0, 250)}
	self.animateCard:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.15, pointMove[wViewChairId]),
			cc.CallFunc:create(function(ref)
				ref:move(display.center)
				--显示一张牌
				local nTag = math.floor(5 - nCount/cmd.GAME_PLAYER) + 1
				if wViewChairId == 2 then 		--2号位发牌时牌居中对齐
					local size = self.nodeCard[wViewChairId]:getContentSize()
					if nTag == 1 then
						size.width = size.width - 120
					else
						size.width = size.width + GameViewLayer.CARDSPACING
					end
					self.nodeCard[wViewChairId]:setContentSize(size)
				end
				local card = self.nodeCard[wViewChairId]:getChildByTag(nTag)
				if not card then return end
				card:setVisible(true)
				--开始下一个人的发牌
				wViewChairId = wViewChairId == 1 and 2 or 1
				AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/SEND_CARD.wav")
				self:runSendCardAnimate(wViewChairId, nCount - 1)
			end)))
end

--检查牌类型
function GameViewLayer:updateCardPrompt()
	--弹出牌显示，统计和
	local nSumTotal = 0
	local nSumOut = 0
	local nCount = 1
	for i = 1, 5 do
		local nCardValue = self._scene:getMeCardLogicValue(i)
		nSumTotal = nSumTotal + nCardValue
		if self.bCardOut[i] then
	 		if nCount <= 3 then
	 			self.labAtCardPrompt[nCount]:setString(nCardValue)
	 		end
	 		nCount = nCount + 1
			nSumOut = nSumOut + nCardValue
		end
	end
	for i = nCount, 3 do
		self.labAtCardPrompt[i]:setString("")
	end
	--判断是否构成牛
	local nDifference = nSumTotal - nSumOut
	if nCount == 1 then
		self.labCardType:setString("")
	elseif nCount == 3 then 		--弹出两张牌
		if self:mod(nDifference, 10) == 0 then
			self.labCardType:setString("牛  "..(nSumOut > 10 and nSumOut - 10 or nSumOut))
		else
			self.labCardType:setString("无牛")
		end
	elseif nCount == 4 then 		--弹出三张牌
		if self:mod(nSumOut, 10) == 0 then
			self.labCardType:setString("牛  "..(nDifference > 10 and nDifference - 10 or nDifference))
		else
			self.labCardType:setString("无牛")
		end
	else
		self.labCardType:setString("无牛")
	end
end

function GameViewLayer:preloadUI()
	display.loadSpriteFrames(GameViewLayer.RES_PATH.."game_oxex_res.plist",
							GameViewLayer.RES_PATH.."game_oxex_res.png")

	for i = 1, #AnimationRes do
		local animation = cc.Animation:create()
		animation:setDelayPerUnit(AnimationRes[i].fInterval)
		animation:setLoops(AnimationRes[i].nLoops)

		for j = 1, AnimationRes[i].nCount do
			local strFile = AnimationRes[i].file..string.format("%d.png", j)
			animation:addSpriteFrameWithFile(strFile)
		end

		cc.AnimationCache:getInstance():addAnimation(animation, AnimationRes[i].name)
	end
end

function GameViewLayer:getAnimate(name, bEndRemove)
	local animation = cc.AnimationCache:getInstance():getAnimation(name)
	local animate = cc.Animate:create(animation)

	if bEndRemove then
		animate = cc.Sequence:create(animate, cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end))
	end

	return animate
end

function GameViewLayer:promptOx()
	--首先将牌复位
	for i = 1, 5 do
		if self.bCardOut[i] == true then
			local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
			local x, y = card:getPosition()
			y = y - 30
			card:move(x, y)
			self.bCardOut[i] = false
		end
	end
	--将牛牌弹出
	local index = self._scene:GetMeChairID() + 1
	local cbDataTemp = self:copyTab(self._scene.cbCardData[index])
	if self._scene:getOxCard(cbDataTemp) then
		for i = 1, 5 do
			for j = 1, 3 do
				if self._scene.cbCardData[index][i] == cbDataTemp[j] then
					local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
					local x, y = card:getPosition()
					y = y + 30
					card:move(x, y)
					self.bCardOut[i] = true
				end
			end
		end
	end
	self:updateCardPrompt()
end

--用户聊天
function GameViewLayer:userChat(wViewChairId, chatString)
	if chatString and #chatString > 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

		--创建label
		local limWidth = 24*12
		local labCountLength = cc.Label:createWithSystemFont(chatString,"Arial", 24)  
		if labCountLength:getContentSize().width > limWidth then
			self.chatDetails[wViewChairId] = cc.Label:createWithSystemFont(chatString,"Arial", 24, cc.size(limWidth, 0))
		else
			self.chatDetails[wViewChairId] = cc.Label:createWithSystemFont(chatString,"Arial", 24)
		end
		if wViewChairId == cmd.MY_VIEWID then
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x + 24 , pointChat[wViewChairId].y + 9)
				:setAnchorPoint( cc.p(0, 0.5) )
		else
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x - 24 , pointChat[wViewChairId].y + 9)
				:setAnchorPoint(cc.p(1, 0.5))
		end
		self.chatDetails[wViewChairId]:addTo(self, 2)

	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(self.chatDetails[wViewChairId]:getContentSize().width+48, self.chatDetails[wViewChairId]:getContentSize().height + 40)
			:setVisible(true)
		--动作
	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function(ref)
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

--用户表情
function GameViewLayer:userExpression(wViewChairId, wItemIndex)
	if wItemIndex and wItemIndex >= 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

	    local strName = string.format("e(%d).png", wItemIndex)
	    self.chatDetails[wViewChairId] = cc.Sprite:createWithSpriteFrameName(strName)
	        :move(pointChat[wViewChairId])
	        :addTo(self, 2)
	    if wViewChairId == cmd.MY_VIEWID then
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x + 45 , pointChat[wViewChairId].y + 5)
		else
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x - 45 , pointChat[wViewChairId].y + 5)
		end

	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(90,80)
			:setVisible(true)

	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function(ref)
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

--拷贝表
function GameViewLayer:copyTab(st)
    local tab = {}
    for k, v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
 end

--取模
function GameViewLayer:mod(a,b)
    return a - math.floor(a/b)*b
end

--运行输赢动画
function GameViewLayer:runWinLoseAnimate(viewid, score)
	if score == 0 then
		return
	end
	local strAnimate
	local strSymbol
	local strNum
	if score > 0 then
		strAnimate = "yellow"
		strSymbol = GameViewLayer.RES_PATH.."symbol_add.png"
		strNum = GameViewLayer.RES_PATH.."num_add.png"
	else
		score = -score
		strAnimate = "blue"
		strSymbol = GameViewLayer.RES_PATH.."symbol_reduce.png"
		strNum = GameViewLayer.RES_PATH.."num_reduce.png"
	end

	--加减
	local node = cc.Node:create()
		:move(ptWinLoseAnimate[viewid])
		:setAnchorPoint(cc.p(0.5, 0.5))
		:setOpacity(0)
		:setCascadeOpacityEnabled(true)
		:addTo(self, 4)

	local spriteSymbol = display.newSprite(strSymbol)		--符号
		:addTo(node)
	local sizeSymbol = spriteSymbol:getContentSize()
	spriteSymbol:move(sizeSymbol.width/2, sizeSymbol.height/2)

	local labAtNum = cc.LabelAtlas:_create(score, strNum, 33, 37, string.byte("0"))		--数字
		:setAnchorPoint(cc.p(0.5, 0.5))
		:addTo(node)
	local sizeNum = labAtNum:getContentSize()
	labAtNum:move(sizeSymbol.width + sizeNum.width/2, sizeNum.height/2)

	node:setContentSize(sizeSymbol.width + sizeNum.width, sizeSymbol.height)

	--底部动画
	local nTime = 1.5
	local spriteAnimate = display.newSprite()
		:move(ptWinLoseAnimate[viewid])
		:addTo(self, 3)
	spriteAnimate:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveBy:create(nTime, cc.p(0, 200)),
			self:getAnimate(strAnimate)
		),
		cc.DelayTime:create(2),
		cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end)
	))

	node:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveBy:create(nTime, cc.p(0, 200)), 
			cc.FadeIn:create(nTime)
		),
		cc.DelayTime:create(2),
		cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end)
	))
end

--帮助弹出动画
function GameViewLayer:helpAnimate()
	local time = 0.2	
	local helpshow = self.sp_help:isVisible()
	local scaleLv = helpshow and 0 or 1
	self.sp_help:setVisible(true)
	self.sp_help:runAction(cc.Sequence:create(
						   cc.ScaleTo:create(time,scaleLv),
						   cc.CallFunc:create(function()
						   		self.sp_help:setVisible(not helpshow)
						   end)))
end

return GameViewLayer