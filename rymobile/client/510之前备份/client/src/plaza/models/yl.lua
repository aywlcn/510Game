 
 --用户ID等信息哈
 strtable = strtable or {}


yl = yl or {}
yl.APPAuditing = false                     --苹果审核开关
yl.APPSTORE_VERSION                     = (device.platform == "ios") and yl.APPAuditing             --是否是苹果审核版本
yl.IS_MAJIA   							= false 
yl.IS_ANDROID_MAJIA 					= false
yl.WIDTH								= 1334--1136--1334
yl.HEIGHT								= 750--640--750

yl.DEVICE_TYPE							= 0x10
yl.KIND_ID								= 122
yl.STATION_ID							= 1

yl.isReExit								=false
yl.reKindID 							=0
yl.reServerID							=0

yl.isOuted 								= false
yl.isTT									= false --冻结的限制

yl.isClientConnectedFailed				= false --大厅重连
yl._clientConnectedCount  				= 0
yl.webStrdata							= nil

yl.DidEnterBackground					= false
yl.IsWxEnterBack						= false

yl.reConnectWebInit						= false
yl.logonMsg								= nil

yl.heartSchedule						= nil
yl.dddddschedule 						= nil
yl.LogonSchedule						= nil
yl.logongCallback						= nil

yl.isShuashuashua						= false --是否切屏幕
yl.isShuaShuaShuaShua					= false --游戏中切屏 重进房间 区分开yl.isreexit游戏杀进程重进
yl.nowScene = 
{
	Z_LOGONSCENE 	=1,
	Z_CLIENTSCENE   =2,
	Z_GAMESCENE		=3,
}

yl.CurrentScene							= nil

-- 登陆地址列表
yl.SERVER_LIST = 
{
    appdf.LOGONSERVER,
}
-- 当前地址索引
yl.CURRENT_INDEX = 1
yl.TOTAL_COUNT = #yl.SERVER_LIST

--测试
yl.LOGONSERVER							= yl.SERVER_LIST[yl.CURRENT_INDEX] --@login_ip

--演示
--yl.LOGONSERVER                          = "120.25.147.47" --@login_ip
--yl.LOGONPORT							= 8600 --@login_port
yl.LOGONPORT							= 8600 --@login_port

--yl.LOGONSERVER							= "172.16.0.24"
--yl.LOGONPORT							= 8600

--yl.FRIENDPORT							= 8630 --@friend_port
yl.FRIENDPORT							= 8630 --@friend_port
--编译码
yl.VALIDATE 							= "B3D44854-9C2F-4C78-807F-8C08E940166D" --@compilation

--http请求链接地址
yl.HTTP_URL								= appdf.HTTP_URL --@http_url前端
yl.HTTP_SERVER_URL                      = appdf.HTTP_SERVER_URL  --http 后端
yl.HTTP_NOTICE_URL                      = appdf.HTTP_NOTICE_URL  --http 公告

-- http请求支持(loginScene)
yl.HTTP_SUPPORT							= true
-- 是否显示信息弹窗的ip和位置信息
yl.SHOW_IP_ADDRESS                      = false
-- 是否单游戏模式(游戏列表数目为1生效)
yl.SINGLE_GAME_MODOLE                   = false

--客服QQ
yl.SERVICE_QQ                           = 800863961
--客服电话
yl.SERVICE_PHONE                        = 15021138412

yl.DOWN_PRO_INFO						= 1
yl.DOWN_UNZIP_STATUS					= 2
yl.DOWN_COMPELETED						= 3
yl.DOWN_ERROR_PATH						= 4 									--路径出错
yl.DOWN_ERROR_CREATEFILE				= 5 									--文件创建出错
yl.DOWN_ERROR_CREATEURL					= 6 									--创建连接失败
yl.DOWN_ERROR_NET		 				= 7 									--下载失败
yl.DOWN_ERROR_UNZIP 					= 8

yl.SCENE_GAMELIST 						= 1
yl.SCENE_ROOMLIST 						= 2
yl.SCENE_USERINFO 						= 3
yl.SCENE_BANK							= 4
yl.SCENE_OPTION							= 5
yl.SCENE_RANKINGLIST					= 6
yl.SCENE_BANKRECORD						= 8
yl.SCENE_ORDERRECORD					= 10
yl.SCENE_EVERYDAY						= 11
yl.SCENE_CHECKIN						= 12
yl.SCENE_TASK							= 13
yl.SCENE_AGENT							= 14
yl.SCENE_ROOM  							= 20
yl.SCENE_GAME 							= 21
yl.SCENE_SHOP							= 22
yl.SCENE_SHOPDETAIL						= 23
yl.SCENE_BAG							= 24
yl.SCENE_BAGDETAIL						= 25
yl.SCENE_BAGTRANS						= 26
yl.SCENE_BINDING						= 27
yl.SCENE_FRIEND							= 28
yl.SCENE_MODIFY							= 29		--密码修改
yl.SCENE_TABLE							= 30		--转盘界面
yl.SCENE_FEEDBACK					 	= 31		--反馈界面
yl.SCENE_FEEDBACKLIST				 	= 32		--反馈列表
yl.SCENE_FAQ							= 33		--常见问题
yl.SCENE_BINDINGREG						= 34		--绑定注册

yl.SCENE_EX_END 						= 50

yl.MAIN_SOCKET_INFO						= 0

yl.SUB_SOCKET_CONNECT					= 1
yl.SUB_SOCKET_ERROR						= 2
yl.SUB_SOCKET_CLOSE						= 3

yl.US_NULL								= 0x00		--没有状态
yl.US_FREE								= 0x01		--站立状态
yl.US_SIT								= 0x02		--坐下状态
yl.US_READY								= 0x03		--同意状态
yl.US_LOOKON							= 0x04		--旁观状态
yl.US_PLAYING					 		= 0x05		--游戏状态
yl.US_OFFLINE							= 0x06		--断线状态

yl.INVALID_TABLE						= 65535
yl.INVALID_CHAIR						= 65535
yl.INVALID_ITEM							= 65535
yl.INVALID_USERID						= 0			--无效用户
yl.INVALID_BYTE                         = 255
yl.INVALID_WORD                         = 65535

--头像信息
yl.FACE_CX 								= 48
yl.FACE_CY								= 48
yl.FACE_COUNT                           = 8        --头像数量

yl.GENDER_FEMALE						= 0				--女性性别
yl.GENDER_MANKIND						= 1				--男性性别

yl.GAME_GENRE_GOLD						= 0x0001		--金币类型
yl.GAME_GENRE_SCORE						= 0x0002		--点值类型
yl.GAME_GENRE_MATCH						= 0x0004		--比赛类型
yl.GAME_GENRE_EDUCATE					= 0x0008		--训练类型
yl.GAME_GENRE_PERSONAL 					= 0x0010 		-- 约战类型

yl.SERVER_GENRE_PASSWD					= 0x0002 		-- 密码类型

yl.SR_ALLOW_AVERT_CHEAT_MODE			= 0x00000040	--隐藏信息

yl.LEN_GAME_SERVER_ITEM					= 183			--房间长度
--yl.LEN_GAME_SERVER_ITEM					= 177			--房间长度
yl.LEN_TASK_PARAMETER					= 813			--任务长度
yl.LEN_TASK_STATUS						= 5             --任务长度

yl.LEN_MD5								= 33			--加密密码
yl.LEN_ACCOUNTS							= 32			--帐号长度
yl.LEN_NICKNAME							= 32			--昵称长度
yl.LEN_PASSWORD							= 33			--密码长度
yl.LEN_USER_UIN							= 33
yl.LEN_QQ                               = 16            --Q Q 号码
yl.LEN_EMAIL                            = 33            --电子邮件
yl.LEN_COMPELLATION 					= 16			--真实名字
yl.LEN_SEAT_PHONE                       = 33            --固定电话
yl.LEN_MOBILE_PHONE                     = 12            --移动电话
yl.LEN_PASS_PORT_ID                     = 19            --证件号码
yl.LEN_COMPELLATION                     = 16            --真实名字
yl.LEN_DWELLING_PLACE                   = 128           --联系地址
yl.LEN_UNDER_WRITE                      = 32            --个性签名
yl.LEN_PHONE_MODE                       = 21            --手机型号
yl.LEN_SERVER                           = 32            --房间长度
yl.LEN_TRANS_REMARK						= 32			--转账备注
yl.LEN_TASK_NAME						= 64			--任务名称

yl.LEN_MOBILE_PHONE						= 12			--移动电话
yl.LEN_COMPELLATION						= 16			--真实名字
yl.LEN_MACHINE_ID						= 33			--序列长度
yl.LEN_USER_CHAT						= 128			--聊天长度
yl.SOCKET_TCP_BUFFER					= 16384			--网络缓冲

yl.MDM_GP_LOGON							= 1				--广场登录
yl.MDM_MB_LOGON							= 100			--广场登录

yl.SUB_MB_LOGON_ACCOUNTS				= 2				--帐号登录
yl.SUB_MB_REGISTER_ACCOUNTS 			= 3				--注册帐号
yl.SUB_MB_LOGON_VISITOR					= 5             --游客登录

yl.SUB_MB_LOGON_SUCCESS					= 100			--登录成功
yl.SUB_MB_LOGON_FAILURE					= 101			--登录失败
yl.SUB_MB_UPDATE_NOTIFY					= 200			--升级提示


yl.MDM_MB_SERVER_LIST					= 101			--列表信息

yl.SUB_MB_LIST_KIND						= 100			--种类列表
yl.SUB_MB_LIST_SERVER					= 101			--房间列表
yl.SUB_MB_LIST_FINISH					= 200			--列表完成

yl.SUB_MB_AGENT_KIND					= 400			--代理列表


yl.MDM_GP_USER_SERVICE					= 3 			--用户服务

yl.SUB_GP_MODIFY_LOGON_PASS				= 101			--修改密码
yl.SUB_GP_MODIFY_INSURE_PASS			= 102			--修改密码
yl.SUB_GP_MODIFY_UNDER_WRITE			= 103			--修改签名

--修改头像
yl.SUB_GP_USER_FACE_INFO				= 120			--头像信息
yl.SUB_GP_SYSTEM_FACE_INFO				= 122			--系统头像
yl.SUB_GP_CUSTOM_FACE_INFO				= 123			--自定义头像

yl.SUB_GP_USER_INDIVIDUAL				= 140			--个人资料
yl.SUB_GP_QUERY_INDIVIDUAL				= 141			--查询信息
yl.SUB_GP_MODIFY_INDIVIDUAL				= 152			--修改资料

yl.SUB_GP_USER_ENABLE_INSURE		    = 160			--开通银行
yl.SUB_GP_USER_SAVE_SCORE				= 161			--存款操作
yl.SUB_GP_USER_TAKE_SCORE				= 162			--取款操作
yl.SUB_GP_USER_INSURE_INFO				= 164			--银行资料
yl.SUB_GR_USER_TRANSFER_SCORE  			= 163 			--转帐操作
yl.SUB_GP_QUERY_INSURE_INFO				= 165			--查询银行
yl.SUB_GP_USER_INSURE_SUCCESS			= 166			--银行成功
yl.SUB_GP_USER_INSURE_FAILURE			= 167			--银行失败
yl.SUB_GP_USER_INSURE_ENABLE_RESULT 	= 170			--开通结果

yl.SUB_GP_OPERATE_SUCCESS				= 500			--操作成功
yl.SUB_GP_OPERATE_FAILURE				= 501			--操作失败

yl.DTP_GP_UI_NICKNAME					= 2				--用户昵称
yl.DTP_GP_UI_UNDER_WRITE				= 3				--个性签名
yl.DTP_GP_MODIFY_UNDER_WRITE			= 4

yl.DTP_GP_MEMBER_INFO					= 2 			--会员信息

yl.SUB_GP_GROWLEVEL_QUERY				= 300			--查询等级
yl.SUB_GP_GROWLEVEL_PARAMETER			= 301			--等级参数
yl.SUB_GP_GROWLEVEL_UPGRADE				= 302			--等级升级

yl.SUB_GP_TASK_LOAD						= 240			--任务加载
yl.SUB_GP_TASK_TAKE						= 241			--任务领取
yl.SUB_GP_TASK_REWARD					= 242			--任务奖励
yl.SUB_GP_TASK_GIVEUP					= 243			--任务放弃
yl.SUB_GP_TASK_INFO						= 250			--任务信息
yl.SUB_GP_TASK_LIST						= 251			--任务信息
yl.SUB_GP_TASK_RESULT					= 252			--任务结果
yl.SUB_GP_TASK_GIVEUP_RESULT			= 253			--放弃结果

--低保服务
yl.SUB_GP_BASEENSURE_LOAD				= 260			--加载低保
yl.SUB_GP_BASEENSURE_TAKE				= 261			--领取低保
yl.SUB_GP_BASEENSURE_PARAMETER			= 262			--低保参数
yl.SUB_GP_BASEENSURE_RESULT				= 263			--低保结果

--帐号绑定
yl.SUB_GP_ACCOUNT_BINDING				= 380			--注册绑定
yl.SUB_GP_ACCOUNT_BINDING_EXISTS		= 381			--帐号绑定

yl.MDM_GR_LOGON							= 1				--登录信息
yl.SUB_GR_LOGON_MOBILE					= 2				--手机登录

yl.SUB_GR_LOGON_SUCCESS					= 100			--登录成功
yl.SUB_GR_LOGON_FAILURE					= 101			--登录失败
yl.SUB_GR_LOGON_FINISH					= 102			--登录完成

yl.SUB_GR_UPDATE_NOTIFY					= 200			--升级提示


yl.MDM_GR_CONFIG						= 2				--配置信息
yl.SUB_GR_CONFIG_COLUMN					= 100			--列表配置
yl.SUB_GR_CONFIG_SERVER					= 101			--房间配置
yl.SUB_GR_CONFIG_FINISH					= 102			--配置完成

yl.MDM_GR_USER							= 8--yl.MDM_GR_USER							= 3				--用户信息

yl.SUB_GR_USER_SITDOWN					= 3				--坐下请求
yl.SUB_GR_USER_STANDUP					= 4				--(强退游戏)起立请求

yl.SUB_GR_USER_CHAIR_REQ 	   			= 10 			--请求更换位置
yl.SUB_GR_USER_CHAIR_INFO_REQ 	 		= 11 			--请求椅子用户信息

yl.SUB_GR_USER_ENTER					= 100			--用户进入
yl.SUB_GR_USER_SCORE					= 101			--用户分数
yl.SUB_GR_USER_STATUS					= 102			--用户状态
yl.SUB_GR_REQUEST_FAILURE				= 103			--请求失败
yl.SUB_GR_USER_GAME_DATA				= 104			--用户游戏数据

yl.SUB_GR_USER_CHAT						= 201			--聊天消息
yl.SUB_GR_USER_EXPRESSION				= 202			--表情消息
yl.SUB_GR_WISPER_CHAT					= 203			--私聊消息
yl.SUB_GR_WISPER_EXPRESSION				= 204			--私聊表情
yl.SUB_GR_COLLOQUY_CHAT					= 205			--会话消息
yl.SUB_GR_COLLOQUY_EXPRESSION			= 206			--会话表情

yl.MDM_GF_FRAME							= 6--yl.MDM_GF_FRAME							= 100    		--框架命令

yl.SUB_GF_GAME_OPTION					= 1				--游戏配置
yl.SUB_GF_USER_READY					= 2				--用户准备
yl.SUB_GF_LOOKON_CONFIG					= 3				--旁观配置

yl.SUB_GF_GAME_STATUS					= 100			--游戏状态
yl.SUB_GF_GAME_SCENE					= 101			--游戏场景
yl.SUB_GF_LOOKON_STATUS					= 102			--旁观状态

yl.SUB_GF_SYSTEM_MESSAGE				= 202--200 暂时修改			--系统消息
yl.SUB_GF_ACTION_MESSAGE				= 201			--动作消息

yl.MDM_GR_STATUS						= 4				--状态信息

yl.SUB_GR_TABLE_INFO					= 100			--桌子信息
yl.SUB_GR_TABLE_STATUS					= 101			--桌子状态

yl.MDM_GF_GAME							= 9--yl.MDM_GF_GAME							= 200			--游戏命令

yl.DTP_GR_TABLE_PASSWORD				= 1				--桌子密码
yl.DTP_GR_NICK_NAME						= 10			--用户昵称
yl.DTP_GR_UNDER_WRITE					= 12 			--个性签名

yl.REQUEST_FAILURE_NORMAL				= 0				--常规原因
yl.REQUEST_FAILURE_NOGOLD				= 1				--金币不足
yl.REQUEST_FAILURE_NOSCORE				= 2				--积分不足
yl.REQUEST_FAILURE_PASSWORD				= 3				--密码错误

yl.MDM_CM_SYSTEM						= 1000			--系统命令

ylSUB_CM_SYSTEM_MESSAGE					= 1				--系统消息
ylSUB_CM_ACTION_MESSAGE					= 2				--动作消息

yl.SMT_CHAT								= 0x0001		--聊天消息
yl.SMT_EJECT							= 0x0002		--弹出消息
yl.SMT_GLOBAL							= 0x0004		--全局消息
yl.SMT_PROMPT							= 0x0008		--提示消息
yl.SMT_TABLE_ROLL						= 0x0010		--滚动消息

yl.SMT_CLOSE_ROOM						= 0x0100		--关闭房间
yl.SMT_CLOSE_GAME						= 0x0200		--关闭游戏
yl.SMT_CLOSE_LINK						= 0x0400		--中断连接
yl.SMT_CLOSE_INSURE						= 0x0800		--关闭银行

--任务类型
yl.TASK_TYPE_WIN_INNINGS				= 0x01			--赢局任务
yl.TASK_TYPE_SUM_INNINGS				= 0x02			--总局任务
yl.TASK_TYPE_FIRST_WIN					= 0x04			--首胜任务
yl.TASK_TYPE_JOIN_MATCH					= 0x08			--比赛任务

--任务状态
yl.TASK_STATUS_UNFINISH					= 0				--任务状态
yl.TASK_STATUS_SUCCESS					= 1				--任务成功
yl.TASK_STATUS_FAILED					= 2				--任务失败	
yl.TASK_STATUS_REWARD					= 3				--领取奖励
yl.TASK_STATUS_WAIT						= 4 			--等待领取

--任务数量
yl.TASK_MAX_COUNT						= 128			--任务数量

--签到服务
yl.SUB_GP_CHECKIN_QUERY					= 220			--查询签到
yl.SUB_GP_CHECKIN_INFO					= 221			--签到信息
yl.SUB_GP_CHECKIN_DONE					= 222			--执行签到
yl.SUB_GP_CHECKIN_RESULT				= 223			--签到结果

--会员服务
yl.SUB_GP_MEMBER_PARAMETER				= 340			--会员参数
yl.SUB_GP_MEMBER_QUERY_INFO				= 341			--会员查询
yl.SUB_GP_MEMBER_DAY_PRESENT			= 342			--会员送金
yl.SUB_GP_MEMBER_DAY_GIFT				= 343			--会员礼包
yl.SUB_GP_MEMBER_PARAMETER_RESULT		= 350			--参数结果
yl.SUB_GP_MEMBER_QUERY_INFO_RESULT		= 351			--查询结果
yl.SUB_GP_MEMBER_DAY_PRESENT_RESULT		= 352			--送金结果
yl.SUB_GP_MEMBER_DAY_GIFT_RESULT		= 353			--礼包结果

--道具命令
yl.MDM_GP_PROPERTY						= 6	

--道具信息
yl.SUB_GP_QUERY_PROPERTY				= 1				--道具查询
yl.SUB_GP_PROPERTY_BUY					= 2				--购买道具
yl.SUB_GP_PROPERTY_USE					= 3				--道具使用
yl.SUB_GP_QUERY_BACKPACKET				= 4				--背包查询
yl.SUB_GP_QUERY_SEND_PRESENT			= 6				--查询赠送
yl.SUB_GP_PROPERTY_PRESENT				= 7				--赠送道具
yl.SUB_GP_GET_SEND_PRESENT				= 8				--获取赠送

yl.SUB_GP_QUERY_PROPERTY_RESULT			= 101			--道具查询
yl.SUB_GP_PROPERTY_BUY_RESULT			= 102			--购买道具
yl.SUB_GP_PROPERTY_USE_RESULT			= 103			--道具使用
yl.SUB_GP_QUERY_BACKPACKET_RESULT		= 104			--背包查询
yl.SUB_GP_QUERY_SEND_PRESENT_RESULT		= 106			--查询赠送
yl.SUB_GP_PROPERTY_PRESENT_RESULT		= 107			--赠送道具
yl.SUB_GP_GET_SEND_PRESENT_RESULT		= 108			--获取赠送
yl.SUB_GP_PROPERTY_FAILURE				= 404			--道具失败

yl.LEN_WEEK								= 5

--货币类型
yl.CONSUME_TYPE_GOLD					= 0x01			--游戏币
yl.CONSUME_TYPE_USEER_MADEL				= 0x02			--元宝
yl.CONSUME_TYPE_CASH					= 0x03			--游戏豆
yl.CONSUME_TYPE_LOVELINESS				= 0x04			--魅力值

--发行范围
yl.PT_ISSUE_AREA_PLATFORM				= 0x01			--大厅道具（大厅可以使用）
yl.PT_ISSUE_AREA_SERVER					= 0x02			--房间道具（在房间可以使用）
yl.PT_ISSUE_AREA_GAME					= 0x04			--游戏道具（在玩游戏时可以使用）
--喇叭物品
yl.LARGE_TRUMPET                        = 306           --大喇叭id
yl.SMALL_TRUMPET                        = 307           --小喇叭id

--赠送目标类型
yl.PRESEND_NICKNAME						= 0
yl.PRESEND_GAMEID						= 1

--notifycation
yl.RY_USERINFO_NOTIFY					= "ry_userinfo_notify"		--玩家信息更新通知
yl.RY_MSG_USERHEAD						= 101						--更新用户头像
yl.RY_MSG_USERWEALTH					= 102						--更新用户财富

yl.RY_FRIEND_NOTIFY                     = "ry_friend_notify"        --好友更新
yl.RY_MSG_FRIENDDEL                     = 101                       --好友删除

yl.TRUMPET_COUNT_UPDATE_NOTIFY			= "ry_trumpet_count_update" --喇叭数量更新


yl.RY_NEARUSER_NOTIFY                   = "ry_nearuser_notify"      --附近玩家信息获取
yl.RY_IMAGE_DOWNLOAD_NOTIFY             = "ry_image_download_notify"--图片下载结束

yl.RY_PERSONAL_TABLE_NOTIFY             = "ry_personal_table_notify"--私人桌信息通知

--埋雷
yl.MDM_GR_THNDER                        =21 
yl.SUB_GR_USER_THNDER                   =700   --埋雷结果
yl.SUB_GR_USER_DISMANTLING              =702
yl.SUB_GR_USER_REDDATA				    =703	
-- yl.CMD_GR_MaiLeinfo_Result=
-- {
-- 	bool                            bSuccess;                            //成功标识
-- 	WORD                            bIdentifier;                         //埋雷标识
-- 	TCHAR							szNotifyContent[128];				 //提示内容
-- };

-- //拆雷结果
-- struct CMD_GR_ChaiLeiInfo_Result
-- {
-- 	BYTE							cbColumnCount;						//列表数目
--     tatMineResult                   MineLeiresult[UD_GROUP_NAME];       //列表信息
-- };

-- //拆雷结果
-- struct tatMineResult
-- {
--     WORD							wGetNumber;                         //已经拆个数
-- 	WORD							wTotalNumber;                       //总雷个数
-- 	SCORE							wGetmoney;                          //已经被拆金额
-- 	SCORE                           wTotalmoney;                        //总金额
-- 	TCHAR							szUserName[LEN_SERVER];			    //用户名称
-- 	WORD							wThunder;                           //是否中雷0-1
-- 	SCORE							wWinmoney;							//拆雷金额
-- 	TCHAR							wTime[LEN_SERVER];			        //拆雷时间
	
-- };

--红包

yl.SUB_GR_RECEIVEREDPACKETS=413 

yl.MDM_GR_REDENVEL						= 20
yl.SUB_GR_GAME_RED_ENVELOPESD 			= 101

yl.GAME_CURNUMBER						= 0
yl.GAME_TARNUMBER						= 3
yl.GAME_BOOSNUMBER						= 3
--领取红包
yl.GAME_HBAWARD_COUNT					=0
yl.CMD_GR_ReceiveRedPackets = 
{


}
--分享配置
yl.SocialShare =
{
	title 								= "有人@你一起玩游戏", --@share_title_social
	content 							= "你的好友正在玩游戏！玩法超多超精彩！快来打败他！", --@share_content_social
	url 								= yl.HTTP_URL,
	AppKey							 	= "59c877fdc895761c8f000031", --@share_appkey_social
}

-- 分享错误代码
yl.ShareErrorCode = 
{
    NOT_CONFIG                          = 1
}

--微信配置定义
yl.WeChat = 
{
	AppID 								= "wxb0581f74e43c1368",--"wx17096c88f8b600cb", --@wechat_appid_wx
	AppSecret 							= "ddab2b1e1d3c0d0e8570d317336e5303", --@wechat_secret_wx
	-- 商户id
	PartnerID 							= "1491471652", --@wechat_partnerid_wx
	-- 支付密钥					        
	PayKey 								= "560161646BABB7692B7574CB56A45667", --@wechat_paykey_wx
	URL 								= yl.HTTP_URL,
}

--z配置
yl.zhifu_1 = 
{
	-- 合作者身份id
	PartnerID							= "2088122749268834", --
	-- 收款账号						
	SellerID							= "2088122749268834", --
	-- rsa密钥
	RsaKey								= "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMI6t48ha1ab1+bJqWHHJ+SWhOcWAR6g3vN2c/swZNbFGEn94LK1Oc1wtFcDnZlNuwgfGtJj/rIyjFr8S/5Ha+oV0SsAbK6zBYqKy5oA0NJObVVnjJDOd7fKlWD2PCKt7xK21e0+RyoZb4GEuKAiVKAfW555y1jWovau/Ju7j8qVAgMBAAECgYBUqbGPo1qdgwsGX4sEwwIBoxbFgBL23dqxN0XxDTQ3ZexjfFWwsExE38bMUxgkVfyb2qsfYFUKKfyCQI2DhnBj84QnvJ1y2/gQf0Afyibs3E1fMIH6xgh54XfrteaVXyZRZTCKT1xbXotFGx+2QquxHkYp+QIoFer3Fl+vdKJ/dQJBAOoQ6eT1q+BouDkLWEr7Joe1ojEFKBoMijTvUdFTCpVfzX5/TLMbTJpVpU5a6rvctQ5wNjDwOgdarov/yltkXwsCQQDUbiXW/4rhNhxkMB8QJmwF24Fe7zA2SO2sJL6lR6AYq4MFsG8GHZniOeZ6hOAZDSnAVhKTifur4mieYQRGAwDfAkEAks2o5QFwm38SjDShW+XJdLRm1Xf2ft/+jtTK7A65RJahvAT7hhpJIUM2Or6rGsiChlu6oVcKDjLB5uy3bjq1oQJBAId63E07WxJ5FTBcdGMzbe9qaB7ow0HLzzDbmm8EuDkjoYNOW/B1jn/2V2TKO7YebANLobtQ5B5iXkCsNTKFldcCQDtIstqpNMnj7dclce+mMsx+12ITx/5Cjf0fwq7yLelozJzh74kbkbYg34/smZOVYorXxKunItemvCh3ShUIunQ=", --
	NotifyURL							= "/Pay/ZFB/notify_url.aspx",
	-- ios支付宝Schemes
	AliSchemes							= "game316ali", --
}


--高德配置
yl.AMAP = 
{
	-- 开发KEY
	AmapKeyIOS							= " ", --@ios_devkey_amap
	AmapKeyAndroid						= " ", --@android_devkey_amap
}

yl.PLATFORM_WX							= 5				--微信平台

--第三方平台定义(同java/ios端定义值一致)
yl.ThirdParty = 
{
	WECHAT 								= 0,	--微信
	WECHAT_CIRCLE						= 1,	--朋友圈
	zhifu_1								= 2,	--支付宝
	AMAP 								= 4,	--高德地图
	IAP 							 	= 5,	--ios iap
	SMS                                 = 6,    --分享到短信
	AYW									= 2001,	--爱悦玩
}
--平台id列表(服务器登陆用)
yl.PLATFORM_LIST = {}
yl.PLATFORM_LIST[yl.ThirdParty.WECHAT]	= 5

yl.MAX_INT                              = 2 ^ 15
--是否动态加入
yl.m_bDynamicJoin                       = false
--设备类型
yl.DEVICE_TYPE_LIST = {}
yl.DEVICE_TYPE_LIST[cc.PLATFORM_OS_WINDOWS] 	= 0x01
yl.DEVICE_TYPE_LIST[cc.PLATFORM_OS_ANDROID] 	= 0x11
yl.DEVICE_TYPE_LIST[cc.PLATFORM_OS_IPHONE] 	= 0x31
yl.DEVICE_TYPE_LIST[cc.PLATFORM_OS_IPAD] 	= 0x41


yl.isClientBack = false
--右移
function yl.rShiftOp(left,num) 
    return math.floor(left / (2 ^ num))  
end  

--左移
function yl.lShiftOp(left, num) 
 return left * (2 ^ num)  
end


function yl.tab_cutText(str)
    local list = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end
    return list, len
end


function yl.IsCCGame(KindID)

     local cckindlist ={601};
     for _, v in ipairs(cckindlist) do
       if v == KindID then 
        return true
        end
    end
        return false
end

function yl.stringCount(szText)
	
	local i = 1
	local nCount = 0
	
	if szText ~= nil then
		--文本长度
		while true do
			local cur = string.sub(szText,i)
			local c = string.byte(cur)
			if c == nil then
				break
			end
			if c > 0 and c <= 127 then
				i = i + 1
			elseif (c >= 192 and c <= 223) then
				i = i + 2
			elseif (c >= 224 and c <= 239) then
			 	i = i + 3
			elseif (c >= 240 and c <= 247) then
			 	i = i + 4
			else
				i = i + 1
			end
			nCount = nCount + 1
			-- if byte > 128 then
			-- 	i = i + 3
			-- else
			-- 	i = i + 1
			-- end
			-- nCount = nCount + 1
		end
	end
	
	return nCount
end

function string.getConfig(fontfile,fontsize)
	local config = {}
	local tmpEN = cc.LabelTTF:create("C", fontfile, fontsize)
	local tmpCN = cc.LabelTTF:create("网", fontfile, fontsize)
	local tmpen = cc.LabelTTF:create("c", fontfile, fontsize)
	local tmpNu = cc.LabelTTF:create("7", fontfile, fontsize)
	config.upperEnSize = tmpEN:getContentSize().width
	config.cnSize = tmpCN:getContentSize().width
	config.lowerEnSize = tmpen:getContentSize().width
	config.numSize = tmpNu:getContentSize().width
	return config
end

function string.EllipsisByConfig(szText, maxWidth,config)
    --szText = "原諒，我吥乖A2C7593A"
    --szText = "TommyAC3FA15E"
	if not config then
		return szText
	end
--当前计算宽度
	local width = 0
	--截断结果
	local szResult = "..."
	--完成判断
	local bOK = false
	 
	local i = 1

	local endwidth = 3*config.numSize
	 
	while true do
		local cur = string.sub(szText,i,i)
		local byte = string.byte(cur)
		if byte == nil then
			break
		end
		if byte > 128 then
			if width + config.cnSize <= maxWidth - endwidth then
				width = width + config.cnSize
				i = i + 3
			else
				bOK = true
				break
			end
		elseif	byte ~= 32 then
			if width + config.upperEnSize <= maxWidth - endwidth then
				if string.byte('A') <= byte and byte <= string.byte('Z') then
					width = width + config.upperEnSize
				elseif string.byte('a') <= byte and byte <= string.byte('z') then
					width = width + config.lowerEnSize
				else
					width = width + config.numSize
				end
				i = i + 1
			else
				bOK = true
				break
			end
		else
            width = width + config.lowerEnSize
			i = i + 1
		end
	end
	 
 	if i ~= 1 then
		szResult = string.sub(szText, 1, i-1)
		if(bOK) then
			szResult = szResult.."..."
		end
	end
	return szResult
end

--依据宽度截断字符
function string.stringEllipsis(szText, sizeE,sizeCN,maxWidth)
	--当前计算宽度
	local width = 0
	--截断结果
	local szResult = "..."
	--完成判断
	local bOK = false
	 
	local i = 1
	 
	while true do
		local cur = string.sub(szText,i,i)
		local byte = string.byte(cur)
		if byte == nil then
			break
		end
		if byte > 128 then
			if width <= maxWidth - 3*sizeE then
				width = width + sizeCN
				i = i + 3
			else
				bOK = true
				break
			end
		elseif	byte ~= 32 then
			if width <= maxWidth - 3*sizeE then
				width = width +sizeE
				i = i + 1
			else
				bOK = true
				break
			end
		else
			i = i + 1
		end
	end
	 
 	if i ~= 1 then
		szResult = string.sub(szText, 1, i-1)
		if(bOK) then
			szResult = szResult.."..."
		end
	end
	return szResult
end

-- 获取余数
function math.mod(a, b)
    return a - math.floor(a/b)*b
end

function string.formatNumberThousands(num,dot,flag)
    num=num or -1;  --IORI--2017年8月11日 11:17:15
	local formatted 
	if not dot then
    	formatted = string.format("%0.2f",tonumber(num))
    else
    	formatted = tonumber(num)
    end
    local sp
    if not flag then
    	sp = ","
    else
    	sp = flag
    end
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d%d)", '%1'..sp..'%2')
        if k == 0 then break end
    end
    return formatted
end


function yl.getLevelDescribe(lScore)
    local lLevelScore = { 2000, 4000, 8000, 20000, 40000, 80000, 150000, 300000, 500000, 1000000, 2000000, 5000000, 10000000, 50000000, 100000000, 500000000, 1000000000 };
	local lLevelDesc={ "务农","佃户","雇工","作坊主","农场主","地主","大地主","财主","富翁","大富翁","小财神","大财神","赌棍","赌侠","赌王","赌圣","赌神","职业赌神"}
	for i=#lLevelScore ,1,-1 do
		if lScore >= lLevelScore[i] then
			return lLevelDesc[i]
		end
	end
	return lLevelDesc[1]
end

local poker_data = 
{
	0x00,
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, -- 方块
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, -- 梅花
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, -- 红桃
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, -- 黑桃
    0x4E, 0x4F
}
-- 逻辑数值
yl.POKER_VALUE = {}
-- 逻辑花色
yl.POKER_COLOR = {}
-- 纹理花色
yl.CARD_COLOR = {}
function yl.GET_POKER_VALUE()
	for k,v in pairs(poker_data) do
		yl.POKER_VALUE[v] = math.mod(v, 16)
		yl.POKER_COLOR[v] = bit:_and(v , 0XF0)
		yl.CARD_COLOR[v] = math.floor(v / 16)
	end
end
yl.GET_POKER_VALUE()

-- 界面z轴定义
function yl.GET_ZORDER_ENUM( nStart, nStep, keyTable )
    local enStart = 1
    if nil ~= nStart then
        enStart = nStart
    end

    local args = keyTable
    local enum = {}
    for i=1,#args do
        enum[args[i]] = enStart
        enStart = enStart + nStep
    end

    yl.ZORDER = enum
end
local zOrderTab = 
{
    "Z_FILTER_LAYER",       -- 触摸过滤
    "Z_AD_WEBVIEW",         -- 首页广告
    "Z_HELP_WEBVIEW",       -- 帮助界面(网页对话框)
    "Z_HELP_BUTTON",        -- 通用帮助按钮
    "Z_TARGET_SHARE",       -- 通用分享选择层
    "Z_VOICE_BUTTON",       -- 通用语音按钮
    "Z_INVITE_DLG",         -- 邀请对话框
}
yl.GET_ZORDER_ENUM( yl.MAX_INT, -1, zOrderTab )

