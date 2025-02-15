local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")

local GameLayer = class("GameLayer", GameModel)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxex.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxex.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.oxex.src.views.layer.GameViewLayer")

function GameLayer:ctor(frameEngine, scene)
    GameLayer.super.ctor(self, frameEngine, scene)
end

function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end

function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
    self.cbPlayStatus = {0, 0}
    self.cbCardData = {}
    self.wBankerUser = yl.INVALID_CHAIR
end

function GameLayer:OnResetGameEngine()
    GameLayer.super.OnResetGameEngine(self)
end

function GameLayer:SwitchViewChairID(chair)
    local viewid = yl.INVALID_CHAIR
    local meChairID = self:GetMeChairID()
    if chair ~= yl.INVALID_CHAIR and chair < 2 then
        viewid = 0 == meChairID and chair + 1 or chair + 2

        if viewid == 3 then
        	viewid = 1
        end
    end
    return viewid
end

-- 计时器响应
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
    -- body
    if clockId == cmd.IDI_NULLITY then
        if time <= 5 then
            AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_WARN.WAV")
        end
    elseif clockId == cmd.IDI_START_GAME then
        if time == 0 then
            self._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊
            self:onExitTable()
        elseif time <= 5 then
            AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_WARN.WAV")
        end
    elseif clockId == cmd.IDI_CALL_BANKER then
        if time < 1 then
            self._gameView:onButtonClickedEvent(GameViewLayer.BT_CANCEL)
        end
    elseif clockId == cmd.IDI_TIME_USER_ADD_SCORE then
        if time < 1 then
            self._gameView:onButtonClickedEvent(GameViewLayer.BT_CHIP + 4)
        elseif time <= 5 then
            AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_WARN.WAV")
        end
    elseif clockId == cmd.IDI_TIME_OPEN_CARD then
        if time < 1 then
            self._gameView:onButtonClickedEvent(GameViewLayer.BT_OPENCARD)
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

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    print("场景信息")
    if GlobalUserItem.bIsChangeTableUser == true  then
        GlobalUserItem.bIsChangeTableUser = false
        self._gameView.btnChangeTable:setTouchEnabled(true)
    end
	local tableId = self._gameFrame:GetTableID()
	self._gameView:setTableID(tableId)
    --初始化已有玩家
    for i = 1, cmd.GAME_PLAYER do
        local userItem = self._gameFrame:getTableUserItem(tableId, i - 1)
        dump(userItem)
        if nil ~= userItem then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:OnUpdateUser(wViewChairId, userItem)
        end
    end
    
    self._gameView:onResetView()

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
    

    self._gameView:setCellScore(lCellScore)
    if not GlobalUserItem.isAntiCheat() then    --非作弊房间
        self._gameView.btStart:setVisible(true)
        self._gameView:setClockPosition(cmd.MY_VIEWID)
        self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
    end
end
--叫庄场景
function GameLayer:onSceneCall(dataBuffer)
    print("onSceneCall")
    local int64 = Integer64.new()
    local wCallBanker = dataBuffer:readword()
    self.cbDynamicJoin = dataBuffer:readbyte()
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
    end
    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()

    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()

    local wViewBankerId = self:SwitchViewChairID(wCallBanker)

    
    self._gameView:gameCallBanker(self:SwitchViewChairID(wCallBanker))
    self._gameView:setClockPosition(wViewBankerId)
    self:SetGameClock(wCallBanker, cmd.IDI_CALL_BANKER, cmd.TIME_USER_CALL_BANKER)
end
--下注场景
function GameLayer:onSceneScore(dataBuffer)
    print("onSceneScore")
    local int64 = Integer64.new()
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
    end
    self.cbDynamicJoin = dataBuffer:readbyte()
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
    --机器人配置
    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    local viewBankerId = self:SwitchViewChairID(self.wBankerUser)
    self._gameView:setBankerUser(viewBankerId)
    self._gameView:setTurnMaxScore(lTurnMaxScore)
    self._gameView:gameStart(viewBankerId)

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

    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()

    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()

    --显示牌并开自己的牌
    for i = 1, cmd.GAME_PLAYER do
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
    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser))
    self._gameView:gameScenePlaying()
    self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_OPEN_CARD, cmd.TIME_USER_OPEN_CARD)
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
	if sub == cmd.SUB_S_CALL_BANKER then 
		self:onSubCallBanker(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_START then 
		self:onSubGameStart(dataBuffer)
	elseif sub == cmd.SUB_S_ADD_SCORE then 
		self:onSubAddScore(dataBuffer)
	elseif sub == cmd.SUB_S_SEND_CARD then 
		self:onSubSendCard(dataBuffer)
	elseif sub == cmd.SUB_S_OPEN_CARD then 
		self:onSubOpenCard(dataBuffer)
	elseif sub == cmd.SUB_S_PLAYER_EXIT then 
		self:onSubPlayerExit(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_END then 
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
	    for i = 1, cmd.GAME_PLAYER do
	        local userItem = self._gameFrame:getTableUserItem(self._gameFrame:GetTableID(), i - 1)
	        if userItem and not self.cbDynamicJoin then
	        	self.cbPlayStatus[i] = 1
	        end
	    end
    end

    self._gameView:gameCallBanker(self:SwitchViewChairID(wCallBanker), bFirstTimes)
    self._gameView:setClockPosition(self:SwitchViewChairID(wCallBanker))
    self:SetGameClock(wCallBanker, cmd.IDI_CALL_BANKER, cmd.TIME_USER_CALL_BANKER)
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    local int64 = Integer64:new()
    local lTurnMaxScore = dataBuffer:readscore(int64):getvalue()
    self.wBankerUser = dataBuffer:readword()
    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser))

    self._gameView:setTurnMaxScore(lTurnMaxScore)

    self._gameView:gameStart(self:SwitchViewChairID(self.wBankerUser))
    self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)
    self._gameView.isChange = true
end

--用户下注
function GameLayer:onSubAddScore(dataBuffer)
    local int64 = Integer64:new()
    local wAddScoreUser = dataBuffer:readword()
    local lAddScoreCount = dataBuffer:readscore(int64):getvalue()

    local userViewId = self:SwitchViewChairID(wAddScoreUser)
    print("onSubAddScore",wAddScoreUser,  userViewId, lAddScoreCount)
    self._gameView:gameAddScore(userViewId, lAddScoreCount)

    AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/ADD_SCORE.WAV")
end

--发牌消息
function GameLayer:onSubSendCard(dataBuffer)
    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, 5 do
            self.cbCardData[i][j] = dataBuffer:readbyte()
        end
    end
    local bAllAndroidUser = dataBuffer:readbool()
    --打开自己的牌
    for i = 1, 5 do
        local index = self:GetMeChairID() + 1
        local data = self.cbCardData[index][i]
        local value = GameLogic:getCardValue(data)
        local color = GameLogic:getCardColor(data)
        local card = self._gameView.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
        self._gameView:setCardTextureRect(cmd.MY_VIEWID, i, value, color)
    end
    self._gameView:gameSendCard(self:SwitchViewChairID(self.wBankerUser), cmd.GAME_PLAYER*5)
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
    AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/OPEN_CARD.wav")
end

--用户强退
function GameLayer:onSubPlayerExit(dataBuffer)
    local wPlayerID = dataBuffer:readword()
    --强退开牌
    self:openCard(wPlayerID)
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    self.cbPlayStatus[wPlayerID + 1] = 0
    self._gameView.nodePlayer[wViewChairId]:setVisible(false)
    self._gameView.userGender[wViewChairId] = nil
    self._gameView.bCanMoveCard = false
    self._gameView.btOpenCard:setVisible(false)
    --self._gameView.btPrompt:setVisible(false)
    self._gameView.spritePrompt:setVisible(false)
    self._gameView.spriteCardBG:setVisible(false)
    self._gameView:setOpenCardVisible(wViewChairId, false)
    print("======================================用户强退==========================================")
end

--用户换桌
function GameLayer:onUserChangeTalbe()
    self._gameView:stopAllActions()
    for i = 1 ,cmd.GAME_PLAYER do
        self._gameView:OnUpdateUser(i,nil)
    end
    self._gameView:onResetView()
    --self._scene._delegate:GameLoadingView()
    GlobalUserItem.bIsChangeTableUser = true 
    self._gameFrame:QueryChangeDesk()
    
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
        --if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:setUserTableScore(wViewChairId, lGameScore[i])
            self._gameView:runWinLoseAnimate(wViewChairId, lGameScore[i])
        --end
    end
    dump(lGameScore,"游戏结束输赢分")
    --开牌
    local data = {}
    for i = 1, cmd.GAME_PLAYER do
        data[i] = dataBuffer:readbyte()
        if self.cbPlayStatus[i] == 1 then
            
            --只要手上没有牌的 游戏结束
            if self.cbCardData[i] ~= nil then
                 self:openCard(i - 1)
             end

           
        end
    end

    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = 0
    end

    local index = self:GetMeChairID() + 1
    self._gameView:gameEnd(lGameScore[index] > 0)

    self._gameView:setClockPosition(cmd.MY_VIEWID)
    self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
    AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_END.WAV")
end

--开始游戏
function GameLayer:onStartGame()
    -- body
    self:KillGameClock()
    self._gameView:onResetView()
    self._gameFrame:SendUserReady()
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

function GameLayer:openCard(chairId)
    --排列cbCardData
    local index = chairId + 1
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
    self._gameView:gameOpenCard(viewId, cbOx)
end

function GameLayer:getMeCardLogicValue(num)
    local index = self:GetMeChairID() + 1

    --此段为测试错误
    if nil == index then
        showToast(self, "nil == index", 1)
        return false
    end
    if nil == num then
        showToast(self, "nil == index", 1)
        return false
    end
    if nil == self.cbCardData[index][num] then
        showToast(self, "nil == index", 1)
        return false
    end

    return GameLogic:getCardLogicValue(self.cbCardData[index][num])
end

function GameLayer:getOxCard(cbCardData)
    return GameLogic:getOxCard(cbCardData)
end

--********************   发送消息     *********************--
function GameLayer:onBanker(cbBanker)
    local dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(yl.MDM_GF_GAME,cmd.SUB_C_CALL_BANKER)
    dataBuffer:pushbyte(cbBanker)
    return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:onAddScore(lScore)
    print("下注金币", lScore)
    if lScore == 1 then
        --下注额是0 会max出来1 非法操作 return
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
    
    local dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(yl.MDM_GF_GAME, cmd.SUB_C_OPEN_CARD)
    dataBuffer:pushbyte(bOx and 1 or 0)
    return self._gameFrame:sendSocketData(dataBuffer)
end

return GameLayer