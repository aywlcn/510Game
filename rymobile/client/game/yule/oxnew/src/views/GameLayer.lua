local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")

local GameLayer = class("GameLayer", GameModel)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxnew.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxnew.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.oxnew.src.views.layer.GameViewLayer")
local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")

-- 初始化界面
function GameLayer:ctor(frameEngine,scene)
    GameLayer.super.ctor(self, frameEngine, scene)

end

--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end

-- 初始化游戏数据
function GameLayer:OnInitGameEngine()
    self.cbPlayStatus = {0, 0, 0, 0}
    self.cbCardData = {}
    self.wBankerUser = yl.INVALID_CHAIR
    self.cbDynamicJoin = 0
    self.m_tabPrivateRoomConfig = {}
    self.m_bStartGame = false

    GameLayer.super.OnInitGameEngine(self)
end

--换位
function GameLayer:onChangeDesk()

end
--用户换桌
function GameLayer:onUserChangeTalbe()
    --桌面扑克清理
    for i = 1 ,cmd.GAME_PLAYER do
        self._gameView:OnUpdateUser(i,nil)
        self._gameView:setOpenCardVisible(i, false)
        self._gameView.cardType[i]:setVisible(false)
        self._gameView.btChip[i]:setVisible(false)
        local cardnode = self._gameView:getChildByTag(10000 + i)
        if cardnode then
            cardnode:stopAllActions()
            cardnode:removeFromParent()
        end
        --结算动画清理
        local scoreAmi = self._gameView:getChildByTag(13000 + i)
        if scoreAmi then
            scoreAmi:stopAllActions()
            scoreAmi:removeFromParent()
        end
        local sprAmi = self._gameView:getChildByTag(14000 + i)
        if sprAmi then
            sprAmi:stopAllActions()
            sprAmi:removeFromParent()
        end
        for m = 1, 5 do
            local handcard = self._gameView.nodeCard[i]:getChildByTag(m)
            --if handcard then
                handcard:setVisible(false)
            --end 
        end
    end
    --庄家标识清理
    self._gameView.spriteBankerFlag:setVisible(false)
    self._gameView.spriteBankerFlag:stopAllActions()
    local bankerami = self._gameView:getChildByTag(12000)
    if bankerami then
        bankerami:stopAllActions()
        bankerami:removeFromParent()
    end
    --动画清理
    local gameendami = self._gameView:getChildByTag(15000)
    if gameendami then
        gameendami:stopAllActions()
        gameendami:removeFromParent()
    end

    self._gameView:onButtonSwitchAnimate()
    self._gameView:onResetView()
    self._gameView:stopAllActions()
    --数据清理
    self.cbPlayStatus = {0, 0, 0, 0}
    self.cbCardData = {}
    self.wBankerUser = yl.INVALID_CHAIR
    self.cbDynamicJoin = 0
    self.m_tabPrivateRoomConfig = {}
    self.m_bStartGame = false
    GlobalUserItem.bIsChangeTableUser = true 
    self._gameFrame:QueryChangeDesk()
    
end

-- 椅子号转视图位置,注意椅子号从0~nChairCount-1,返回的视图位置从1~nChairCount
function GameLayer:SwitchViewChairID(chair)
    local viewid = yl.INVALID_CHAIR
    local nChairCount = 4
    local nChairID = self:GetMeChairID()
    if chair ~= yl.INVALID_CHAIR and chair < nChairCount then
        viewid = math.mod(chair + math.floor(nChairCount * 3/2) - nChairID, nChairCount) + 1
    end
    return viewid
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    -- body
    GameLayer.super.OnResetGameEngine(self)
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

-- 时钟处理
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
    -- body
    if clockId == cmd.IDI_NULLITY then
        if time <= 5 then
            self:PlaySound(GameViewLayer.RES_PATH.."sound/GAME_WARN.WAV")
        end
    elseif clockId == cmd.IDI_START_GAME then
        if time <= 0 then
            self._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊
            self:onExitTable()
        elseif time <= 5 then
            self:PlaySound(GameViewLayer.RES_PATH.."sound/GAME_WARN.WAV")
        end
    elseif clockId == cmd.IDI_CALL_BANKER then
        if time < 1 then
            -- 非私人房处理叫庄
            if not GlobalUserItem.bPrivateRoom then
                self._gameView:onButtonClickedEvent(GameViewLayer.BT_CANCEL)
            end
        end
    elseif clockId == cmd.IDI_TIME_USER_ADD_SCORE then
        if time < 1 then
            if not GlobalUserItem.bPrivateRoom then
                self._gameView:onButtonClickedEvent(GameViewLayer.BT_CHIP + 4)
            end
        elseif time <= 5 then
            self:PlaySound(GameViewLayer.RES_PATH.."sound/GAME_WARN.WAV")
        end
    elseif clockId == cmd.IDI_TIME_OPEN_CARD then
        if time < 1 then
            -- 非私人房处理摊牌
            --if not GlobalUserItem.bPrivateRoom then
                self._gameView:onButtonClickedEvent(GameViewLayer.BT_OPENCARD)
            --end
        end
    end
end

--用户聊天
function GameLayer:onUserChat(chat, wChairId)
    self._gameView:userChat(self:SwitchViewChairID(wChairId), chat.szChatString)
end

--用户表情
function GameLayer:onUserExpression(expression, wChairId)
    self._gameView:userExpression(self:SwitchViewChairID(wChairId), expression.wItemIndex)
end

-- 语音播放开始
function GameLayer:onUserVoiceStart( useritem, filepath )
    local viewid = self:SwitchViewChairID(useritem.wChairID)
    self._gameView:onUserVoiceStart(viewid)
end

-- 语音播放结束
function GameLayer:onUserVoiceEnded( useritem, filepath )
    local viewid = self:SwitchViewChairID(useritem.wChairID)
    self._gameView:onUserVoiceEnded(viewid)
end

--退出桌子
--[[function GameLayer:onExitTable()
    self:KillGameClock()
    local MeItem = self:GetMeUserItem()
    if MeItem and MeItem.cbUserStatus > yl.US_FREE then
        self:showPopWait()
        self:runAction(cc.Sequence:create(
            cc.CallFunc:create(
                function () 
                    self._gameFrame:StandUp(1)
                end
                ),
            cc.DelayTime:create(10), 
            cc.CallFunc:create(
                function ()
                    print("delay leave")
                    self:onExitRoom()
                end
                )
            )
        )
        return
    end

   self:onExitRoom()
end]]

--离开房间
function GameLayer:onExitRoom()
    self._scene:onKeyBack()
end

function GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
    GameLayer.super.onExit(self)
end

function GameLayer:onGetSitUserNum()
    local num = 0
    for i = 1, cmd.GAME_PLAYER do
        if nil ~= self._gameView.m_tabUserItem[i] then
            num = num + 1
        end
    end

    return num
end

function GameLayer:getUserInfoByChairID(chairId)
    local viewId = self:SwitchViewChairID(chairId)
    return self._gameView.m_tabUserItem[viewId]
end

function GameLayer:onGetNoticeReady()
    print("牛牛 系统通知准备")
    if nil ~= self._gameView and nil ~= self._gameView.btStart then
        self._gameView.btStart:setVisible(true)
    end
end

--系统消息
function GameLayer:onSystemMessage( wType,szString )
    print("处理金币不足")
    if self.m_bStartGame then
        local msg = szString or ""
        self.m_querydialog = QueryDialog:create(msg,function()
            self:onExitTable()
        end,nil,1)
        self.m_querydialog:setCanTouchOutside(false)
        self.m_querydialog:addTo(self)
    else
        self.m_bPriScoreLow = true
        self.m_szScoreMsg = szString
    end
end
function GameLayer:onSubSystemMessage(wType,szString)
    
    if wType == 515 then
        self:KillGameClock()
        GlobalUserItem.bWaitQuit = true
        local msg = szString or ""
        
        local scene = cc.Director:getInstance():getRunningScene()
        --创建遮罩
        local mask = ccui.Layout:create()
        mask:setContentSize(cc.Director:getInstance():getVisibleSize())
        mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        mask:setBackGroundColor(cc.BLACK)
        mask:setBackGroundColorOpacity(153)
        mask:setTouchEnabled(true)
        mask:addTo(scene)
        mask:setOpacity(0)
        mask:runAction(cc.EaseSineOut:create(cc.FadeIn:create(0.4)))
        
        --背景
        local _content = display.newSprite("query_bg.png")
        :move(appdf.WIDTH / 2, appdf.HEIGHT / 2)
        :addTo(mask)
        local contentSize = _content:getContentSize()
        
        cc.Label:createWithTTF(msg, "fonts/round_body.ttf", 32)
        :setTextColor(cc.c4b(255, 255, 255, 255))
        :setAnchorPoint(cc.p(0.5, 0.5))
        :setDimensions(640, 180)
        :setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        :setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        :move(contentSize.width / 2, 210)
        :addTo(_content)
        
        ccui.Button:create("bt_query_confirm_0.png", "")
        :move(contentSize.width / 2, 80)
        :addTo(_content)
        :addClickEventListener(function()
            GlobalUserItem.bWaitQuit = false            
            self:onExitTable()
            mask:removeFromParent()
        end)
        _content:setScale(0.75)
        -- print("处理金币不足")
        -- self:KillGameClock()
        -- GlobalUserItem.bWaitQuit = true
        -- local msg = szString or ""

        -- QueryDialog:create(msg,function()
        --     GlobalUserItem.bWaitQuit = false
        --     self:onExitTable()
        -- end,nil,1)        
        -- :setCanTouchOutside(false)
        -- :addTo(cc.Director:getInstance():getRunningScene())
    end
end



function GameLayer:addPrivateGameLayer( layer )
    if nil == layer then
        return
    end

    self._gameView:addChild(layer, 2)
end

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    if GlobalUserItem.bIsChangeTableUser == true  then
        GlobalUserItem.bIsChangeTableUser = false
        self._gameView.btnChangeTable:setTouchEnabled(true)
    end
    --初始化已有玩家   
    local tableId = self._gameFrame:GetTableID()
    --self._gameView:setTableID(tableId)
    for i = 1, cmd.GAME_PLAYER do
        local userItem = self._gameFrame:getTableUserItem(tableId, i-1)
        if nil ~= userItem then
            local wViewChairId = self:SwitchViewChairID(i-1)
            self._gameView:OnUpdateUser(wViewChairId, userItem)
        end
    end
    self._gameView:onResetView()
    self.m_cbGameStatus = cbGameStatus

	if cbGameStatus == cmd.GS_TK_FREE	then				--空闲状态
        self:onSceneFree(dataBuffer)
	elseif cbGameStatus == cmd.GS_TK_CALL	then			--叫分状态
        self:onSceneCall(dataBuffer)
	elseif cbGameStatus == cmd.GS_TK_SCORE	then			--下注状态
        self:onSceneScore(dataBuffer)
    elseif cbGameStatus == cmd.GS_TK_PLAYING  then            --游戏状态
        self:onScenePlaying(dataBuffer)
	end
    self:dismissPopWait()
end

--空闲场景
function GameLayer:onSceneFree(dataBuffer)
    print("onSceneFree")
    local int64 = Integer64.new()
    local lCellScore = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()
--    -- 反作弊标识
--    local bIsAllowAvertCheat = dataBuffer:readbool()
--    -- 坐庄模式
--    self.m_tabPrivateRoomConfig.bankerMode = dataBuffer:readint()
--    -- 房卡积分模式
--    self.m_tabPrivateRoomConfig.bRoomCardScore = dataBuffer:readbool()
--    -- 积分房卡配置的下注
--    local tabJetton = {}
--    tabJetton[1] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[2] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[3] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[4] = dataBuffer:readscore(int64):getvalue()
--    self.m_tabPrivateRoomConfig.lRoomCardJetton = tabJetton    

--    -- 反作弊标识
--    local bIsAllowAvertCheat = dataBuffer:readbool()

    if not GlobalUserItem.isAntiCheat() then
        self._gameView.btStart:setVisible(true)
        self._gameView:setClockPosition(cmd.MY_VIEWID)

        -- 私人房无倒计时
        if not GlobalUserItem.bPrivateRoom then
            -- 设置倒计时
            self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
        else
            self._gameView.spriteClock:setVisible(false)
        end
    end
end

--叫庄场景
function GameLayer:onSceneCall(dataBuffer)
    print("onSceneCall")
    local int64 = Integer64.new()
    local wCallBanker = dataBuffer:readword()
    self.cbDynamicJoin = dataBuffer:readbyte()
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~动态加入：", self.cbDynamicJoin)
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
    end
    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()
    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    

    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()
--    -- 反作弊标识
--    local bIsAllowAvertCheat = dataBuffer:readbool()
--    -- 坐庄模式
--    self.m_tabPrivateRoomConfig.bankerMode = dataBuffer:readint()
--    -- 房卡积分模式
--    self.m_tabPrivateRoomConfig.bRoomCardScore = dataBuffer:readbool()
--    -- 积分房卡配置的下注
--    local tabJetton = {}
--    tabJetton[1] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[2] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[3] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[4] = dataBuffer:readscore(int64):getvalue()
--    self.m_tabPrivateRoomConfig.lRoomCardJetton = tabJetton

    local wViewBankerId = self:SwitchViewChairID(wCallBanker)
    
    self._gameView:gameCallBanker(self:SwitchViewChairID(wCallBanker))
    self._gameView:setClockPosition(wViewBankerId)
    self:SetGameClock(wCallBanker, cmd.IDI_CALL_BANKER, cmd.TIME_USER_CALL_BANKER)

    -- 刷新局数
    if PriRoom and GlobalUserItem.bPrivateRoom then
        local curcount = PriRoom:getInstance().m_tabPriData.dwPlayCount
        PriRoom:getInstance().m_tabPriData.dwPlayCount = curcount - 1
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
end
--下注场景
function GameLayer:onSceneScore(dataBuffer)
    print("onSceneScore")
    local int64 = Integer64.new()
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
    end
    self.cbDynamicJoin = dataBuffer:readbyte()
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~动态加入：", self.cbDynamicJoin)
    local lTurnMaxScore = dataBuffer:readscore(int64):getvalue()
    local lTableScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTableScore[i] = dataBuffer:readscore(int64):getvalue() 
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:setUserTableScore(wViewChairId, lTableScore[i])
        end
    end
    self.wBankerUser = dataBuffer:readword()
    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()
    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()
    -- 反作弊标识
--    local bIsAllowAvertCheat = dataBuffer:readbool()
--    -- 坐庄模式
--    self.m_tabPrivateRoomConfig.bankerMode = dataBuffer:readint()
--    -- 房卡积分模式
--    self.m_tabPrivateRoomConfig.bRoomCardScore = dataBuffer:readbool()
--    -- 积分房卡配置的下注
--    local tabJetton = {}
--    tabJetton[1] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[2] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[3] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[4] = dataBuffer:readscore(int64):getvalue()
--    self.m_tabPrivateRoomConfig.lRoomCardJetton = tabJetton

    
    -- 积分房卡配置的下注
--    if self.m_tabPrivateRoomConfig.bRoomCardScore then
--        self._gameView:setScoreRoomJetton(tabJetton)
--    else
--        self._gameView:setTurnMaxScore(lTurnMaxScore)
--    end

    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser))
    self._gameView:setTurnMaxScore(lTurnMaxScore)
    self._gameView:gameStart(self:SwitchViewChairID(self.wBankerUser))

    self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)
end
--游戏场景
function GameLayer:onScenePlaying(dataBuffer)
    print("onScenePlaying")
    local int64 = Integer64.new()
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
    end
    self.cbDynamicJoin = dataBuffer:readbyte()
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~动态加入：", self.cbDynamicJoin)
    local lTurnMaxScore = dataBuffer:readscore(int64):getvalue()
    local lTableScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTableScore[i] = dataBuffer:readscore(int64):getvalue()
        if self.cbPlayStatus[i] == 1 and lTableScore[i] ~= 0 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:gameAddScore(wViewChairId, lTableScore[i])
        end
    end
    self.wBankerUser = dataBuffer:readword()
    --local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    --local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()

    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, 5 do
            self.cbCardData[i][j] = dataBuffer:readbyte()
        end
    end

    local bOxCard = {}
    for i = 1, cmd.GAME_PLAYER do
        bOxCard[i] = dataBuffer:readbyte()
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if nil ~= bOxCard[i] and self.cbPlayStatus[i] == 1 and wViewChairId ~= cmd.MY_VIEWID then
            self._gameView:setOpenCardVisible(wViewChairId, true)
        end
    end

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    --local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    --local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    --local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    --local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    --local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()
    -- 反作弊标识
--    local bIsAllowAvertCheat = dataBuffer:readbool()
--    -- 坐庄模式
--    self.m_tabPrivateRoomConfig.bankerMode = dataBuffer:readint()
--    -- 房卡积分模式
--    self.m_tabPrivateRoomConfig.bRoomCardScore = dataBuffer:readbool()
--    -- 积分房卡配置的下注
--    local tabJetton = {}
--    tabJetton[1] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[2] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[3] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[4] = dataBuffer:readscore(int64):getvalue()
--    self.m_tabPrivateRoomConfig.lRoomCardJetton = tabJetton

    --显示牌并开自己的牌
    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            for j = 1, 5 do
                local card = self._gameView.nodeCard[wViewChairId]:getChildByTag(j)
                card:setVisible(true)
                if wViewChairId == cmd.MY_VIEWID then          --是自己则打开牌
                    local value = GameLogic:getCardValue(self.cbCardData[i][j])
                    local color = GameLogic:getCardColor(self.cbCardData[i][j])
                    self._gameView:setCardTextureRect(wViewChairId, j, value, color)
                end
            end
        end
    end
    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser))
    self._gameView:gameScenePlaying()
    self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_OPEN_CARD, cmd.TIME_USER_OPEN_CARD)

    -- 刷新局数
    if PriRoom and GlobalUserItem.bPrivateRoom then
        local curcount = PriRoom:getInstance().m_tabPriData.dwPlayCount
        PriRoom:getInstance().m_tabPriData.dwPlayCount = curcount - 1
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
end

function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
     if self._gameView then 
        if self._gameFrame._UserList[GlobalUserItem.dwUserID] then
            if self._gameFrame._UserList[GlobalUserItem.dwUserID].cbUserStatus > 1 then

                local viewid = self:SwitchViewChairID(oldstatus.wChairID)
                --local viewid = self:SwitchViewChairID(useritem.wChairID)
                self._gameView:OnUpdateUser(viewid , useritem)
            end
            
        end
 
    end
    
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
	if sub == cmd.SUB_S_CALL_BANKER then 
        self.m_cbGameStatus = cmd.GS_TK_CALL
		self:onSubCallBanker(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_START then
        self.m_cbGameStatus = cmd.GS_TK_CALL 
		self:onSubGameStart(dataBuffer)
	elseif sub == cmd.SUB_S_ADD_SCORE then 
        self.m_cbGameStatus = cmd.GS_TK_SCORE
		self:onSubAddScore(dataBuffer)
	elseif sub == cmd.SUB_S_SEND_CARD then 
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubSendCard(dataBuffer)
	elseif sub == cmd.SUB_S_OPEN_CARD then 
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubOpenCard(dataBuffer)
	elseif sub == cmd.SUB_S_PLAYER_EXIT then 
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubPlayerExit(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_END then 
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubGameEnd(dataBuffer)
	else
		print("unknow gamemessage sub is"..sub)
	end
end

--用户叫庄
function GameLayer:onSubCallBanker(dataBuffer)

    local wCallBanker = dataBuffer:readword()
    local bFirstTimes = dataBuffer:readbool()
    if bFirstTimes then
        self.cbDynamicJoin = 0
        for i = 1, cmd.GAME_PLAYER do
            self.cbPlayStatus[i] = dataBuffer:readbyte()
        end
    end
    self._gameView:gameCallBanker(self:SwitchViewChairID(wCallBanker), bFirstTimes)
    self._gameView:setClockPosition(self:SwitchViewChairID(wCallBanker))
    self:SetGameClock(wCallBanker, cmd.IDI_CALL_BANKER, cmd.TIME_USER_CALL_BANKER)
    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
		 -- 注释下面这句，修复房卡局数错误
            -- PriRoom:getInstance().m_tabPriData.dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount + 1
            self._gameView._priView:onRefreshInfo()
        end
    end
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    local int64 = Integer64:new()
    local lTurnMaxScore = dataBuffer:readscore(int64):getvalue()
    self.wBankerUser = dataBuffer:readword()

    self._gameView.isChange = true
    -- 坐庄模式
--    self.m_tabPrivateRoomConfig.bankerMode = dataBuffer:readint()

--    -- 房卡积分模式
--    self.m_tabPrivateRoomConfig.bRoomCardScore = dataBuffer:readbool()
--    -- 积分房卡配置的下注
--    local tabJetton = {}
--    tabJetton[1] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[2] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[3] = dataBuffer:readscore(int64):getvalue()
--    tabJetton[4] = dataBuffer:readscore(int64):getvalue()
--    self.m_tabPrivateRoomConfig.lRoomCardJetton = tabJetton

--    self.cbDynamicJoin = 0
--    -- 玩家状态
--    for i = 1, cmd.GAME_PLAYER do
--        self.cbPlayStatus[i] = dataBuffer:readbyte()
--    end

    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser))

--    -- 积分房卡配置的下注
--    if self.m_tabPrivateRoomConfig.bRoomCardScore then
--        self._gameView:setScoreRoomJetton(tabJetton)
--    else
        self._gameView:setTurnMaxScore(lTurnMaxScore)
--    end

    self._gameView:gameStart(self:SwitchViewChairID(self.wBankerUser))
    self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)
    self:PlaySound(GameViewLayer.RES_PATH.."sound/GAME_START.WAV")


    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            PriRoom:getInstance().m_tabPriData.dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount + 1
            self._gameView._priView:onRefreshInfo()
        end
    end
end

--用户下注
function GameLayer:onSubAddScore(dataBuffer)
    local int64 = Integer64:new()
    local wAddScoreUser = dataBuffer:readword()
    local lAddScoreCount = dataBuffer:readscore(int64):getvalue()

    local userViewId = self:SwitchViewChairID(wAddScoreUser)
    self._gameView:gameAddScore(userViewId, lAddScoreCount)

    self:PlaySound(GameViewLayer.RES_PATH.."sound/ADD_SCORE.WAV")
end

--发牌消息
function GameLayer:onSubSendCard(dataBuffer)
    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, 5 do
            self.cbCardData[i][j] = dataBuffer:readbyte()
        end
    end
    --打开自己的牌
    for i = 1, 5 do
        local index = self:GetMeChairID() + 1
        local data = self.cbCardData[index][i]
        local value = GameLogic:getCardValue(data)
        local color = GameLogic:getCardColor(data)
        local card = self._gameView.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
        self._gameView:setCardTextureRect(cmd.MY_VIEWID, i, value, color)
    end
    self._gameView:gameSendCard(self:SwitchViewChairID(self.wBankerUser), self:getPlayNum()*5)
    self:KillGameClock()
end

--用户摊牌
function GameLayer:onSubOpenCard(dataBuffer)
    local wPlayerID = dataBuffer:readword()
    local bOpen = dataBuffer:readbyte()
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    if wViewChairId == cmd.MY_VIEWID then
        local index = wPlayerID + 1
        local cbOx = GameLogic:getCardType(self.cbCardData[index])
        self._gameView:playSound(wViewChairId,cbOx)
        self:openCard(wPlayerID)
    else
        self._gameView:setOpenCardVisible(wViewChairId, true)
    end
    self:PlaySound(GameViewLayer.RES_PATH.."sound/OPEN_CARD.wav")
end

--用户强退
function GameLayer:onSubPlayerExit(dataBuffer)
    local wPlayerID = dataBuffer:readword()
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    self.cbPlayStatus[wPlayerID + 1] = 0
    self._gameView.bCanMoveCard = false
    self._gameView.nodePlayer[wViewChairId]:setVisible(false)
    --self._gameView.btOpenCard:setVisible(false)
    --self._gameView.btPrompt:setVisible(false)
    self._gameView.spritePrompt:setVisible(false)
    --for i = 1, 5 do
    self._gameView.cardFrame:setVisible(false)
        --self._gameView.cardFrame[i]:setSelected(false)
    --end
    self._gameView:setOpenCardVisible(wViewChairId, false)
end


--游戏结束
function GameLayer:onSubGameEnd(dataBuffer)
    local int64 = Integer64:new()

    local lGameTax = {}
    for i = 1, cmd.GAME_PLAYER do
        lGameTax[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lGameScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lGameScore[i] = dataBuffer:readscore(int64):getvalue()
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:setUserTableScore(wViewChairId, lGameScore[i])
            self._gameView:runWinLoseAnimate(wViewChairId, lGameScore[i])
        end
    end
    --开牌
    local data = {}
    for i = 1, cmd.GAME_PLAYER do
        data[i] = dataBuffer:readbyte()
        if self.cbPlayStatus[i] == 1 then
            self:openCard(i - 1,true)
        end
    end

    local cbDelayOverGame = dataBuffer:readbyte()

    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = 0
    end

    local index = self:GetMeChairID() + 1
    self._gameView:gameEnd(lGameScore[index] >= 0)

    self._gameView:setClockPosition(cmd.MY_VIEWID)
    -- 私人房无倒计时
    if not GlobalUserItem.bPrivateRoom then
        -- 设置倒计时
        self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
    else
        self._gameView.spriteClock:setVisible(false)
    end
    AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_END.WAV")
end

--游戏结束
--function GameLayer:onSubGameEnd(dataBuffer)
--    self.m_bStartGame = false
--    local int64 = Integer64:new()

--    local lGameTax = {}
--    for i = 1, cmd.GAME_PLAYER do
--        lGameTax[i] = dataBuffer:readscore(int64):getvalue()
--    end

--    local lGameScore = {}
--    for i = 1, cmd.GAME_PLAYER do
--        lGameScore[i] = dataBuffer:readscore(int64):getvalue()
--        if self.cbPlayStatus[i] == 1 then
--            local wViewChairId = self:SwitchViewChairID(i - 1)
--            self._gameView:setUserTableScore(wViewChairId, lGameScore[i])
--            self._gameView:runWinLoseAnimate(wViewChairId, lGameScore[i])
--        end
--    end
--    --开牌
--    local data = {}
--    for i = 1, cmd.GAME_PLAYER do
--        data[i] = dataBuffer:readbyte()
--        if self.cbPlayStatus[i] == 1 then
--            self:openCard(i - 1, true)
--        end
--    end

--    local cbDelayOverGame = dataBuffer:readbyte()

--    for i = 1, cmd.GAME_PLAYER do
--        self.cbPlayStatus[i] = 0
--    end

--    local index = self:GetMeChairID() + 1
--    self._gameView:gameEnd(lGameScore[index] > 0)

--    self:KillGameClock()
--    self._gameView:setClockPosition(cmd.MY_VIEWID)
--    -- 私人房无倒计时
--        if not GlobalUserItem.bPrivateRoom then
--            -- 设置倒计时
--            self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
--        else
--            self._gameView.spriteClock:setVisible(false)
--        end
--    self:PlaySound(GameViewLayer.RES_PATH.."sound/GAME_END.WAV")
--end

--开始游戏
function GameLayer:onStartGame()
    if true == self.m_bPriScoreLow then
        local msg = self.m_szScoreMsg or ""
        self.m_querydialog = QueryDialog:create(msg,function()
            self:onExitTable()
        end,nil,1)
        self.m_querydialog:setCanTouchOutside(false)
        self.m_querydialog:addTo(self)
    else
        -- body
        self:KillGameClock()
        self._gameView:onResetView()
        self._gameFrame:SendUserReady()
        self.m_bStartGame = true
    end

    
end

function GameLayer:getPlayNum()
    local num = 0
    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then
            num = num + 1
        end
    end

    return num
end

--将视图id转换为普通id
function GameLayer:isPlayerPlaying(viewId)
    if viewId < 1 or viewId > 4 then
        print("view chair id error!")
        return false
    end

    for i = 1, cmd.GAME_PLAYER do
        if self:SwitchViewChairID(i - 1) == viewId then
            if self.cbPlayStatus[i] == 1 then
                return true
            end
        end
    end

    return false
end

function GameLayer:sendCardFinish()
    self._gameView:setClockPosition()
    self:SetGameClock(self:GetMeChairID(), cmd.IDI_TIME_OPEN_CARD, cmd.TIME_USER_OPEN_CARD)
end

function GameLayer:openCard(chairId, bEnded)
    --排列cbCardData
    local index = chairId + 1
    if self.cbCardData[index] == nil then
        print("出错")
        return false
    end
    GameLogic:getOxCard(self.cbCardData[index])
    local cbOx = GameLogic:getCardType(self.cbCardData[index])

    local viewId = self:SwitchViewChairID(chairId)
    for i = 1, 5 do
        local data = self.cbCardData[index][i]
        local value = GameLogic:getCardValue(data)
        local color = GameLogic:getCardColor(data)
        local card = self._gameView.nodeCard[viewId]:getChildByTag(i)
        self._gameView:setCardTextureRect(viewId, i, value, color)
    end

    self._gameView:gameOpenCard(viewId, cbOx, bEnded)

    return true
end

function GameLayer:getMeCardLogicValue(num)
    local index = self:GetMeChairID() + 1
    local value = GameLogic:getCardLogicValue(self.cbCardData[index][num])
    local str = string.format("index:%d, num:%d, self.cbCardData[index][num]:%d, return:%d", index, num, self.cbCardData[index][num], value)
    print(str)
    return value
end

function GameLayer:getOxCard(cbCardData)
    return GameLogic:getOxCard(cbCardData)
end

function GameLayer:getPrivateRoomConfig()
    return self.m_tabPrivateRoomConfig
end

--********************   发送消息     *********************--
function GameLayer:onBanker(cbBanker)
    local dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(yl.MDM_GF_GAME,cmd.SUB_C_CALL_BANKER)
    dataBuffer:pushbyte(cbBanker)
    return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:onAddScore(lScore)
    print("牛牛 发送下注")
    if self:SwitchViewChairID(self.wBankerUser) == cmd.MY_VIEWID then
        print("牛牛: 自己庄家不下注")
        return
    end
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:setcmdinfo(yl.MDM_GF_GAME, cmd.SUB_C_ADD_SCORE)
    dataBuffer:pushscore(lScore)
    return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:onOpenCard()
    local index = self:GetMeChairID() + 1
    local bOx = GameLogic:getOxCard(self.cbCardData[index])
    dump(self.cbCardData)
    local dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(yl.MDM_GF_GAME, cmd.SUB_C_OPEN_CARD)
    dataBuffer:pushbyte(bOx and 1 or 0)
    return self._gameFrame:sendSocketData(dataBuffer)
end

return GameLayer