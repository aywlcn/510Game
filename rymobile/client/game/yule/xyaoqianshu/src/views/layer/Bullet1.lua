--
-- Author: Tang
-- Date: 2016-08-09 10:26:25
-- 子弹

local Bullet = class("Bullet", cc.Sprite)

local module_pre = "game.yule.xyaoqianshu.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_YQSGame"
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()
local Game_CMD = appdf.req(module_pre .. ".models.CMD_YQSGame")

Bullet.bulletType =
{
   Normal_Bullet = 0, --正常炮
   Bignet_Bullet = 1,--网变大
   Special_Bullet = 2--加速炮
}

local Type =  Bullet.bulletType

function Bullet:ctor(angle,chairId,score,mutipleIndex,CannonType,cannon, maxScore, bulletSpeed)

   self.m_Type = Type.Normal_Bullet
   self.m_fishIndex = Game_CMD.INT_MAX --鱼索引
   self.m_cannonPos = -1 --炮台索引	
   self.m_index     = -1 --子弹索引
   --self.m_netColor = cc.RED
   self.m_moveDir = cc.p(0,0)
   self.m_targetPoint = cc.p(0,0)
   self.m_isSelf = false
   self.m_bRemove = false
   self.orignalAngle = 0
   self.ifdie=false
   self.movedir = cc.p(0, 0)
   self.m_cannon = cannon
   self._dataModule = self.m_cannon._dataModel
   self._gameFrame  = self.m_cannon.frameEngine
   self._maxScore = maxScore
   self.m_speed = bulletSpeed or 0.2	--子弹速度  self._dataModule.m_secene.nBulletVelocity/1000*25
   self.spx = bulletSpeed or 0.2   --真子弹速度x
   self.spy = bulletSpeed or 0.2   --真子弹速度y
   if CannonType == Game_CMD.CannonType.Special_Cannon then
        self.spx = bulletSpeed * 1.5
        self.spy = bulletSpeed * 1.5
   end
   self.m_nScore = score --子弹分数
   self.bulletnum=2
   --dyj1
   self.m_nMultipleIndex = mutipleIndex
   self.chairId=chairId
   --self.m_nMultipleIndex = 1
   self = nil
   --dyj2

   --self:initWithAngle(angle, chairId, score, CannonType)
 
   	 --注册事件
    --ExternalFun.registerTouchEvent(self,false)
end

function Bullet:getT()
    return self.bulletnum
end

function Bullet:setV(ifV)
    if ifV then
       self:setVisible(true)
       self.m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
       self:getPhysicsBody():setCategoryBitmask(2)
    else
       self:setVisible(false)
       self.m_bRemove = false
       self.m_moveDir = cc.p(0,0)
       self.spx=0.2
       self.spy=0.2
       self.orignalAngle = 0
       self:getPhysicsBody():setCategoryBitmask(8)
    end
end


function Bullet:initWithAngle(angle,chairId,score,CannonType)
	-- body
	local nBulletNum = self:getBulletNum()
	local tmpChairId = chairId
	if chairId >= 4 then
		chairId = chairId - 3
	end
	local file = string.format("Bullet1_Normal_%d_b.png",chairId+1)
	if CannonType ~= Game_CMD.CannonType.Special_Cannon then
		file = string.format("Bullet%d_Normal_%d_b.png", nBulletNum,chairId+1)
	else
		file = string.format("Bullet%d_Specialt_b.png", nBulletNum)
	end
	self.m_nScore = score
	self:initWithSpriteFrameName(file)
    self:setRotation(angle)
    self.orignalAngle = angle
--    self:initPhysicsBody()
	self.m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))

end

function Bullet:setIndex( index )
	--子弹索引
	self.m_index = index
end

function Bullet:setIsSelf( isself )
	self.m_isSelf = isself
end

function Bullet:setNetColor( color )
	self.m_netColor = color
end

function Bullet:setFishIndex( index )
	self.m_fishIndex = index

--[[	
    if self.m_fishIndex ~= Game_CMD.INT_MAX then
		--开启锁定
        self:schedulerUpdate()
	end
    --]]


end


function Bullet:onEnter()
	
	self:schedulerUpdate()

end


function Bullet:onExit( )
	self.m_bRemove = true
	self:removeAllComponents()
	self:unSchedule()
end


function Bullet:schedulerUpdate() 
	local function updateBullet( dt )
		--self:update(dt)
        self:followFish(dt) --锁定鱼
	end

	--定时器
	if nil == self.m_schedule then
		self.m_schedule = scheduler:scheduleScriptFunc(updateBullet, 0, false)
	end

end

function Bullet:unSchedule()
	if nil ~= self.m_schedule then
		scheduler:unscheduleScriptEntry(self.m_schedule)
	self.m_schedule = nil
	end
end

function Bullet:getBulletNum( )
	-- body
	--local mutiple = math.floor(self.m_nMultipleIndex/4)+1

    local mutiple = 1 --math.floor(self.m_nMutipleIndex/4) + 1
    if self.m_nMultipleIndex / self._maxScore >= 0 and self.m_nMultipleIndex / self._maxScore < 0.4 then
        mutiple = 1
    elseif self.m_nMultipleIndex / self._maxScore >= 0.4 and self.m_nMultipleIndex / self._maxScore < 0.7  then
        mutiple = 2
    elseif self.m_nMultipleIndex / self._maxScore >= 0.7 and self.m_nMultipleIndex / self._maxScore <= 1  then
        mutiple = 3
    end
	return mutiple
end



function Bullet:setType( type )

	self.m_Type = type
	if	self.m_Type == Type.Special_Bullet  then
		self.m_speed = self.m_speed * 1.5
	end
end

function Bullet:initPhysicsBody()


	if self.m_fishIndex  ~= Game_CMD.INT_MAX then

		return	
	end

	self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    self:getPhysicsBody():setCategoryBitmask(2)
    self:getPhysicsBody():setCollisionBitmask(0)
    self:getPhysicsBody():setContactTestBitmask(1)
    self:getPhysicsBody():setGravityEnable(false)
end

function Bullet:setPhy(ifno)
    if ifno then
        self:getPhysicsBody():setCategoryBitmask(4)
        self:getPhysicsBody():setContactTestBitmask(3)
    else
        self:getPhysicsBody():setCategoryBitmask(2)
        self:getPhysicsBody():setContactTestBitmask(1)
    end

end

function Bullet:changeDisplayFrame(chairId ,score)
	local nBulletNum = self:getBulletNum()
	local frame = string.format("Bullet%d_Normal_%d_b.png", nBulletNum,chairId + 1)
	self:setSpriteFrame(frame)
end

function Bullet:update( dt )
	--if self.m_fishIndex == Game_CMD.INT_MAX then

		--self:normalUpdate(dt) --正常发射
	--else
		self:followFish(dt) --锁定鱼
	--end
end

--正常发射
function Bullet:normalUpdate( dt )
	
	local movedis = dt * self.m_speed
	local movedir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis)  
	local pos = cc.p(self:getPositionX()+movedir.x,self:getPositionY()+movedir.y)
	self:setPosition(pos.x,pos.y)
	local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
	pos = cc.p(self:getPositionX(),self:getPositionY())

	if not cc.rectContainsPoint(rect,pos) then
		
		if pos.x<0 or pos.x>yl.WIDTH then
			local angle = self:getRotation()
			self:setRotation(-angle)
			if pos.x<0 then
			   pos.x = 0
			else
				pos.x = yl.WIDTH
			end
		else
			local angle = self:getRotation()
			self:setRotation(-angle + 180)
			if pos.y<0 then
				pos.y = 0
			else
				pos.y = yl.HEIGHT
			end
		end

		self.m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
		local movedis = dt * self.m_speed
		local moveDir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis) 
		pos = cc.p(self:getPositionX()+moveDir.x,self:getPositionY()+moveDir.y)
		self:setPosition(pos.x,pos.y)
	end

end

--锁定鱼
function Bullet:followFish(dt)
	if true == self.m_bRemove or (nil ~= self.m_cannon and nil ~= self.m_cannon.parent and nil ~= self.m_cannon.parent.parent and true == self.m_cannon.parent.parent.m_bLeaveGame) then
		return
	end
	local fish = self._dataModule.m_fishList[self.m_fishIndex]

	if nil == fish then
		self.m_fishIndex = Game_CMD.INT_MAX
		self:initPhysicsBody()
        --self:unSchedule()
		return
	end
	
	local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
	if not cc.rectContainsPoint(rect, cc.p(fish:getPositionX(), fish:getPositionY())) then
		self.m_fishIndex = Game_CMD.INT_MAX
		self:initPhysicsBody()
        --self:unSchedule()
		return
	end


	local fishPos = cc.p(fish:getPositionX(),fish:getPositionY())
	if self._dataModule.m_reversal then
		fishPos = cc.p(yl.WIDTH - fishPos.x , yl.HEIGHT - fishPos.y)
	end

	local angle = self._dataModule:getAngleByTwoPoint(fishPos, cc.p(self:getPositionX(),self:getPositionY()))

	self:setRotation(angle)

	--[[self.m_cannon.m_fort:setRotation(angle - self.m_cannon.orignalAngle)
			self.m_cannon.orignalAngle = angle]]


	self.m_moveDir = cc.pForAngle(math.rad(90-angle))

	local movedis = dt * self.m_speed
	local movedir = cc.pMul(self.m_moveDir,movedis)

	self:setPosition(self:getPositionX()+movedir.x,self:getPositionY()+movedir.y)

	if cc.pGetDistance(fishPos,cc.p(self:getPositionX(),self:getPositionY())) <= movedis then
		self:setPosition(fishPos)
		self:fallingNet()
		self:removeFromParent(true)
	end

end

--撒网
function Bullet:fallingNet()

	local points1 = {cc.p(-25,0),cc.p(25,0)} --两个网
	local points2 = {cc.p(0,20),cc.p(-math.cos(3.14/6)*20,-math.sin(3.14/6)*20),cc.p(math.cos(3.14/6)*20,-math.sin(3.14/6)*20)} --三个网
	local points3 = {cc.p(-25,25),cc.p(25,25),cc.p(25,-25),cc.p(-25,-25)} --四个网

	self:unSchedule()

	local parent = self:getParent()
	if parent == nil then
		return
	end
	self.m_bRemove = true
	local bulletNum = 0
	local tmp = {}
	bulletNum = self:getBulletNum()

	if bulletNum == 1 then
		tmp = points1
	elseif bulletNum == 2 then
		tmp = points2
	elseif bulletNum == 3 then
		tmp = points3
	end

	local offset =  cc.pMul(self.m_moveDir,20)
	local rect = nil

	for i=1,bulletNum+1 do

		local net = cc.Sprite:create("game_res/im_net.png") 
		if self.m_Type == Type.Normal_Bullet or self.m_Type == Type.Special_Bullet  then
			net = cc.Sprite:create("game_res/im_net.png")
		elseif self.m_Type == Type.Bignet_Bullet then
			net = cc.Sprite:create("game_res/im_net_big.png")
		end

		net:setScale(205/net:getContentSize().width)

		if self.m_Type == Type.Bignet_Bullet then
			net:setScale(net:getScale()*1.5)
		end

		local pos = cc.p(self:getPositionX(),self:getPositionY())
		pos = cc.pAdd(pos,offset)
		net:setPosition(pos.x,pos.y)

		rect = net:getBoundingBox()
	    pos = cc.pAdd(pos,offset)
		net:setPosition( cc.pAdd(pos,tmp[i]))

		local scalTo = cc.ScaleTo:create(0.08,net:getScale()*1.16)
		local scalTo1 = cc.ScaleTo:create(0.08,net:getScale())
		local call = cc.CallFunc:create(function()		
  	       net:removeFromParent(true)
   		end)	

		local seq = cc.Sequence:create(scalTo,scalTo1,scalTo,call)
		net:runAction(seq)
		net:runAction(cc.Sequence:create(cc.DelayTime:create(0.16),cc.FadeTo:create(0.05,0)))
		parent:addChild(net,20)

	end

	if self.m_isSelf then

		local net = cc.Sprite:create("game_res/im_net.png") 
		if self.m_Type == Type.Normal_Bullet or self.m_Type == Type.Special_Bullet  then
			net = cc.Sprite:create("game_res/im_net.png")
		elseif self.m_Type == Type.Bignet_Bullet then
			net = cc.Sprite:create("game_res/im_net_big.png")
		end


		local pos = cc.p(self:getPositionX(),self:getPositionY())
		pos = cc.pAdd(pos,offset)
		local catchPos = self._dataModule:convertCoordinateSystem(pos, 2, self._dataModule.m_reversal)
		net:setPosition(catchPos)

		local rect = net:getBoundingBox()
		rect.width = rect.width - 20 + bulletNum*10
		rect.height = rect.height - 20 + bulletNum*10

		--self:sendCathcFish(rect)
	end
end

--dyj (暂时废弃)
--发送捕获消息
function Bullet:sendCathcFish( rect )

	local tmp = {}

	for k,v in pairs(self._dataModule.m_fishList) do
		local fish = v
		local pos = fish:getPosition()
		local _rect = fish:getBoundingBox()

		local bIntersect = cc.rectIntersectsRect(rect,_rect)
		if bIntersect then
			table.insert(tmp, fish)
		end

	end

	local count = 0 --网中符合条件的鱼的个数
	local catchList = {}
	local isBigFish = true
	local bigFishList = {}

	--筛选大鱼
	local bigIndex = {}
	for i=1,#tmp do
		local fish = tmp[i]
		if fish.m_data.nFishState ~= Game_CMD.FishState.FishState_Normal then
			table.insert(bigFishList,fish)
			table.insert(bigIndex,i)
		end
	end

	for i=1,#bigIndex do
		table.remove(tmp,bigIndex[i])
	end

	bigIndex = {}

	--把大鱼插入队列的前端
	if 0 ~= #bigFishList then
		for i=1,#bigFishList do
			local fish = bigFishList[i]
			table.insert(tmp, 1,fish)
		end
	end

	bigFishList = nil

	--取出前5条鱼
	if #tmp > 5 then
		count = 5
	else
		count = #tmp
	end

	for i=1,count do
		local fish = tmp[i]
		table.insert(catchList,fish)
	end

--发送消息包
	local request = {0,0,0,0,0}

	for i=1,#catchList do
		local fish = catchList[i]
		request[i] = fish.m_data.nFishKey
	end

	local cmddata = CCmd_Data:create(24)
   	cmddata:setcmdinfo(yl.MDM_GF_GAME, Game_CMD.SUB_C_CATCH_FISH);
    cmddata:pushint(self.m_index)
    for i=1,5 do
    	cmddata:pushint(request[i])
    end

     if nil ==  self._gameFrame or nil == self._gameFrame.sendSocketData then
    	return
    end

    --发送失败
	if nil ~= self._gameFrame then
    	if not self._gameFrame:sendSocketData(cmddata) then
    	if nil ~= self._gameFrame then
    		self._gameFrame._callBack(-1,"发送捕鱼信息失败")
    	end

		end
   end
end
--dyj2

return Bullet