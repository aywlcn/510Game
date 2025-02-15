#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#include "lua_extensions.h"
#include "FileAsset.h"
#include "MobileClientKernel.h"
#include "LuaAssert/CurlAsset.h"
#include "LuaAssert/LogAsset.h"
#include "LuaAssert/CircleBy.h"
#include "LuaAssert/QrNode.h"
#include "LuaAssert/AESEncrypt.h"
#include "LuaAssert/AudioRecorder/AudioRecorder.h"
#include "LuaAssert/ry_Util.h"
#include "tools/global.h"
#include "tools/manager/SoundManager.h"
#include "tools/manager/Game_Path_Manager.h"
#include "tools/tools/StaticData.h"
#include "tools/tools/StringData.h"
#include "tools/tools/MTNotification.h"
#include "platform/data/ServerListData.h"
#include "platform/data/OptionParameter.h"
#include "platform/data/PlatformGameConfig.h"
#include "lua/lua_module_register.h"

#include "lua/auto/lua_cocos2dx_game_auto.hpp"
#include "lua/auto/lua_cocos2dx_kernel_auto.hpp"
#include "lua/auto/lua_cocos2dx_platform_auto.hpp"
#include "lua/auto/lua_cocos2dx_tool_auto.hpp"

#include "lua/manual/lua_cocos2dx_notification_manual.hpp"
#include "lua/manual/lua_cocos2dx_game_cocos_extention_manual.hpp"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_LINUX)
#include "ide-support/CodeIDESupport.h"
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
#include "runtime/Runtime.h"
#include "ide-support/RuntimeLuaImpl.h"
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 

#elif  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	#include "platform/android/jni/JniHelper.h"
	#include "bugly/CrashReport.h"
	#include "bugly/lua/BuglyLuaAgent.h"
    #include "SimpleAudioEngine.h"
    using namespace CocosDenshion;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
	#include "CrashReport.h"
	#include "BuglyLuaAgent.h"
#endif
#include "audio/include/AudioEngine.h"
using namespace experimental;

#include "ClientKernel.h"
#include "ImageToByte.h"
#include "LuaAssert.h"
#include "ClientSocket.h"
#include "Integer64.h"
#include "CMD_Data.h"
#include "ry_MD5.h"
#include "UnZipAsset.h"
#include "DownAsset.h"

USING_NS_CC;
using namespace std;

#define SCHEDULE CCDirector::sharedDirector()->getScheduler()

AppDelegate* AppDelegate::m_instance = NULL;

AppDelegate::AppDelegate()
{
	m_instance = this;
	m_pClientKernel = new CClientKernel();
	m_ImageToByte = new CImageToByte();
	m_BackgroundCallBack =  0;
}

AppDelegate::~AppDelegate()
{
#if  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	SimpleAudioEngine::end();
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    AudioEngine::end();
#endif
	CC_SAFE_DELETE(m_pClientKernel);
	CC_SAFE_DELETE(m_ImageToByte);

 #if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
//     // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
     RuntimeEngine::getInstance()->end();
 #endif

}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

static int toLua_AppDelegate_MD5(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 1)
	{
		const char* szData = lua_tostring(tolua_S,1);
		if(EMPTY_CHAR(szData) == false)
		{
			string md5pass = md5(szData);
			lua_pushstring(tolua_S,md5pass.c_str());
			return 1;
		}
	}
	return 0;
}

static int toLua_AppDelegate_LoadImageByte(lua_State* tolua_S)
{
	bool result = false;
	int argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
		const char* szData = lua_tostring(tolua_S, 1);
		if (EMPTY_CHAR(szData) == false)
		{
			CImageToByte* help = (CImageToByte*)AppDelegate::getAppInstance()->m_ImageToByte;
			if (help)
				result = help->onLoadData(szData);
		}
	}
	lua_pushboolean(tolua_S, result ? 1 : 0);
	return 1;
}

static int toLua_AppDelegate_CleanImageByte(lua_State* tolua_S)
{
	CImageToByte* help = (CImageToByte*)AppDelegate::getAppInstance()->m_ImageToByte;
	if (help)
		help->onCleanData();
	return 0;
}

static int toLua_AppDelegate_checkData(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 2)
	{
		CImageToByte* help = (CImageToByte*)AppDelegate::getAppInstance()->m_ImageToByte;
		if (help)
		{		
			int x = lua_tointeger(tolua_S,1);
			int y = lua_tointeger(tolua_S,2);
			unsigned int data = help->getData(x,y);
			int r= data & 0xff;
			int g = (data >> 8) & 0xff;
			int b = (data >> 16) & 0xff;
			int a = (data >> 24) & 0xff;        
			lua_pushinteger(tolua_S,r);
			lua_pushinteger(tolua_S,g);
			lua_pushinteger(tolua_S,b);
			lua_pushinteger(tolua_S,a);
		}
		return 4;
	}
	return 0;
}

static int toLua_AppDelegate_SaveByEncrypt(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 3)
	{
		const char* filename = lua_tostring(tolua_S,1);
		const char* szKey = lua_tostring(tolua_S,2);
		const char* szData = lua_tostring(tolua_S,3);
		
		std::string filePath = FileUtils::getInstance()->getWritablePath();
		std::string sp = "";
		if (filePath[filePath.length()-1]=='/')
		{
			sp = "";
		}else
		{
			sp = '/';
		}
		filePath = FileUtils::getInstance()->fullPathForFilename(filePath+sp+filename);
		CCLOG("save_path:%s",filePath.c_str());
		ValueMap valueMap = FileUtils::getInstance()->getValueMapFromFile(filePath);
		ValueVector dataArray;
		int len = strlen(szData);
		if (len > 0)
		{
			
			char *pData = new char[len+4];
			memset(pData,0,len+4);
			memcpy(pData+4,szData,len);
			//CCipher::encryptBuffer(pData,len+4);
			for(int i = 0;i<len+4;i++)
			{
				int tmp = pData[i];
				dataArray.push_back(Value(tmp));
			}
			CC_SAFE_DELETE(pData);
		}
		valueMap[szKey] = Value(dataArray);
		FileUtils::getInstance()->writeToFile(valueMap, filePath);
	}
	return 0;
}

static int toLua_AppDelegate_ReadByDecrypt(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 2)
	{
		const char* filename = lua_tostring(tolua_S,1);
		const char* szKey = lua_tostring(tolua_S,2);
		std::string filePath = FileUtils::getInstance()->getWritablePath();
		std::string sp = "";
		if (filePath[filePath.length()-1]=='/')
		{
			sp = "";
		}else
		{
			sp = '/';
		}
		filePath = FileUtils::getInstance()->fullPathForFilename(filePath+sp+filename);
		ValueMap valueMap = FileUtils::getInstance()->getValueMapFromFile(filePath);
		if (valueMap[szKey].isNull())
		{
			lua_pushstring(tolua_S,"");
		}
		else
		{
			ValueVector& dataArray = valueMap[szKey].asValueVector();
			int len = dataArray.size();
			if(len == 0)
			{
				lua_pushstring(tolua_S,"");
			}
			else
			{
				BYTE *pData = new BYTE[len+1];
				memset(pData,0,len+1);
				for (int i = 0;i<len ;i++)
				{
					pData[i] = dataArray.at(i).asByte();
				}
				//CCipher::decryptBuffer(pData,len);
				lua_pushstring(tolua_S,(char*)(pData+4));
				CC_SAFE_DELETE(pData);
			}
		}
		return 1;
	}
	return 0;
}

static int toLua_AppDelegate_downFileAsync(lua_State* tolua_S)
{

	int argc = lua_gettop(tolua_S);
	if ( argc == 4 )
	{

		const char* szUrl = lua_tostring(tolua_S,1);
		const char* szSaveName = lua_tostring(tolua_S,2);
		const char* szSavePath = lua_tostring(tolua_S,3);
		int handler = toluafix_ref_function(tolua_S,4,0);
		if (handler != 0)
		{
			CDownAsset::DownFile(szUrl,szSaveName,szSavePath,handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}
		else
		{
			CCLOG("toLua_AppDelegate_setHttpDownCallback hadler or listener is null");
		}
	}
	else
	{
		CCLOG("toLua_AppDelegate_setHttpDownCallback arg error now is %d",argc);
	}

	return 0;
}

static int toLua_AppDelegate_unZipAsync(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 3)
	{
		const char* file = lua_tostring(tolua_S,1);
		const char* path = lua_tostring(tolua_S,2);
		int handler = toluafix_ref_function(tolua_S,3,0);
		if (handler != 0)
		{
			CUnZipAsset::UnZipFile(file,path,handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}else{
			if (handler == NULL)
				CCLOG("toLua_AppDelegate_unZipAsync error handler is null");
		}
	}else{
		CCLOG("toLua_AppDelegate_unZipAsync error argc is %d",argc);
	}
	return 0;
}

static int toLua_AppDelegate_setbackgroundcallback(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 1)
	{
		int handler = toluafix_ref_function(tolua_S,1,0);

		if (handler != 0)
		{
			AppDelegate::getAppInstance()->setBackgroundListener(handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}

	}
	return 0;
}
static int toLua_AppDelegate_removebackgroundcallback(lua_State* tolua_S)
{
	AppDelegate::getAppInstance()->setBackgroundListener(0);
	return 0;
}

static int toLua_AppDelegate_onUpDateBaseApp(lua_State* tolua_S)
{
	const char* path = lua_tostring(tolua_S,1);
	if(path != NULL)
	{	
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	WCHAR wszClassName[256] ={};
	MultiByteToWideChar(CP_ACP,0,path,strlen(path)+1,wszClassName,sizeof(wszClassName)/sizeof(wszClassName[0]));
	ShellExecute(NULL, L"open", L"explorer.exe",wszClassName, NULL, SW_SHOW);
#endif
    	lua_pushboolean(tolua_S, 1);
		return 1;
	}
	return 0;
}

static int toLua_AppDelegate_createDirectory(lua_State* tolua_S)
{

	const char* path = lua_tostring(tolua_S,1);
	if(path != NULL)
	{
		bool result = createDirectory(path);
		lua_pushboolean(tolua_S, result?1:0);
		return 1;
	}

	return 0;
}

static int toLua_AppDelegate_removeDirectory(lua_State* tolua_S)
{
	const char* path = lua_tostring(tolua_S,1);
	if(path != NULL)
	{
		bool result = removeDirectory(path);
		lua_pushboolean(tolua_S, result?1:0);
		return 1;
	}

	return 0;
}

static unsigned char* getBMPFileData(const std::string &path, bool &haveData)
{
    haveData = false;
    //文件判断
    if (!FileUtils::getInstance()->isFileExist(path))
    {
        log("%s not exist!", path.c_str());
        return nullptr;
    }
    Data tmp = FileUtils::getInstance()->getDataFromFile(path);
    unsigned char* pBmpData = tmp.getBytes();
    //文件长度判断
    if (tmp.getSize() < 2)
    {
    	log("%s not exist!", path.c_str());
    	return nullptr;
    }
    //bmp格式判断
    static const unsigned char BMP[] = {0X42, 0X4d};
    if (memcmp(BMP, pBmpData, sizeof(BMP)) != 0)
    {
        log("%s is not .bmp type file!", path.c_str());
        return nullptr;
    }
    
    unsigned char *bytecs = new unsigned char[96 * 96 * 4 + 1];
    int idx1 = 0;
    int idx2 = 0;
    for (int i = 0; i < 96 ; ++i)
    {
        for (int j = 0; j < 96; ++j)
        {
            idx1 = ((95 - i) * 96 + j)*4;
            idx2 = (i * 96 + j)*4;
            bytecs[idx1] = pBmpData[54 + idx2 + 2];          //R
            bytecs[idx1 + 1] = pBmpData[54 + idx2 + 1];      //G
            bytecs[idx1 + 2] = pBmpData[54 + idx2];          //B
            bytecs[idx1 + 3] = 0xff;                         //A
        }
    }
    haveData = true;
    return bytecs;
}

static int toLua_AppDelegate_createSpriteByBMPFile(lua_State* tolua_S)
{
    const char* path = lua_tostring(tolua_S, 1);

    cocos2d::Texture2D* tex = nullptr;
    bool bInit = false;
    //判断是否存在纹理缓存
    auto it = AppDelegate::getAppInstance()->m_cachedBmpTex.find(path);
    if (it != AppDelegate::getAppInstance()->m_cachedBmpTex.end())
    {
    	tex = it->second;
    	bInit = true;
    }
    else
    {
    	bool bHave = false;
	    unsigned char *data = getBMPFileData(path, bHave);
	    if (nullptr == data || false == bHave )
	    {
	        object_to_luaval<cocos2d::Sprite>(tolua_S, "cc.Sprite", nullptr);
	        CC_SAFE_DELETE_ARRAY(data);
	        return 1;
	    }
	    
	    tex = new Texture2D();
	    bInit = tex->initWithData(data, 96 * 96 * 4, Texture2D::PixelFormat::RGBA8888, 96, 96, cocos2d::Size(96, 96));
	    if (bInit)
	    {
	    	//缓存纹理
	        AppDelegate::getAppInstance()->m_cachedBmpTex.insert(std::make_pair(path,tex));
	    }
	    CC_SAFE_DELETE_ARRAY(data);
    }
    if (nullptr != tex && true == bInit)
    {
    	//创建
        cocos2d::Sprite* ret = cocos2d::Sprite::createWithTexture(tex);
        object_to_luaval<cocos2d::Sprite>(tolua_S, "cc.Sprite", (cocos2d::Sprite*)ret);
    }
    else
    {
    	log("init texture error");
        object_to_luaval<cocos2d::Sprite>(tolua_S, "cc.Sprite", nullptr);
        CC_SAFE_DELETE(tex);
    }
    return 1;
}

static int toLua_AppDelegate_createSpriteFrameByBMPFile(lua_State* tolua_S)
{
    const char* path = lua_tostring(tolua_S, 1);

    cocos2d::Texture2D* tex = nullptr;
    bool bInit = false;
    //判断是否存在纹理缓存
    auto it = AppDelegate::getAppInstance()->m_cachedBmpTex.find(path);
    if (it != AppDelegate::getAppInstance()->m_cachedBmpTex.end())
    {
    	tex = it->second;
    	bInit = true;
    }
    else
    {
    	bool bHave = false;
	    unsigned char *data = getBMPFileData(path, bHave);
	    if (nullptr == data || false == bHave )
	    {
	        object_to_luaval<cocos2d::SpriteFrame>(tolua_S, "cc.SpriteFrame", nullptr);
	        CC_SAFE_DELETE_ARRAY(data);
	        return 1;
	    }
	    
	    tex = new Texture2D();
	    bInit = tex->initWithData(data, 96 * 96 * 4, Texture2D::PixelFormat::RGBA8888, 96, 96, cocos2d::Size(96, 96));
	    if (bInit)
	    {
	    	//缓存纹理
	        AppDelegate::getAppInstance()->m_cachedBmpTex.insert(std::make_pair(path,tex));
	    }
	    CC_SAFE_DELETE_ARRAY(data);
    }
    if (nullptr != tex && true == bInit)
    {
    	//创建
        cocos2d::SpriteFrame* ret = cocos2d::SpriteFrame::createWithTexture(tex, Rect(0,0,96,96));
        object_to_luaval<cocos2d::SpriteFrame>(tolua_S, "cc.SpriteFrame", (cocos2d::SpriteFrame*)ret);
    }
    else
    {
    	log("init texture error");
        object_to_luaval<cocos2d::SpriteFrame>(tolua_S, "cc.SpriteFrame", nullptr);
        CC_SAFE_DELETE(tex);
    }
    return 1;

}

static int toLua_AppDelegate_reSizeGivenFile(lua_State* tolua_S)
{
    auto argc = lua_gettop(tolua_S);
    if (argc == 4)
    {
        std::string path = lua_tostring(tolua_S, 1);
        std::string newpath = lua_tostring(tolua_S, 2);
        std::string notifyfun = lua_tostring(tolua_S, 3);
        if (FileUtils::getInstance()->isFileExist(path))
        {
            auto sp = Sprite::create(path);
            if (nullptr != sp)
            {            	
                int nSize = lua_tonumber(tolua_S, 4);
                auto size = sp->getContentSize();
                auto scale = nSize / size.width;
                sp->setScale(scale);
                sp->setAnchorPoint(Vec2(0.0f, 0.0f));

                auto render = RenderTexture::create(nSize, nSize);
                render->retain();
                render->beginWithClear(0, 0, 0, 0);
                sp->visit();
                render->end();
                Director::getInstance()->getRenderer()->render();
                render->saveToFile("tmp.png", true, [=](RenderTexture* render, const std::string& fullpath)
                                   {
                                   		if (newpath != "")
                                   		{
                                   			Director::getInstance()->getTextureCache()->removeTextureForKey(path);
	                                       	FileUtils::getInstance()->renameFile(fullpath, newpath);
	                                       
	                                       	lua_getglobal(tolua_S, notifyfun.c_str());
	                                       	if (!lua_isfunction(tolua_S, -1))
	                                       	{
	                                           	CCLOG("value at stack [%d] is not function", -1);
	                                           	lua_pop(tolua_S, 1);
	                                       	}
	                                       	else
	                                       	{
	                                           	lua_pushstring(tolua_S, fullpath.c_str());
	                                           	lua_pushstring(tolua_S, newpath.c_str());
	                                           	int iRet = lua_pcall(tolua_S, 2, 0, 0);
	                                           	if (iRet)
	                                           	{ 
	                                               log("call lua fun error:%s", lua_tostring(tolua_S, -1));
	                                               lua_pop(tolua_S, 1);
	                                           	}
	                                       	}
                                   		}
                                       	render->release();
                                   });
            }
        }
        
    }
    return 0;
}

static int toLua_AppDelegate_nativeMessageBox(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (2 == argc)
	{
		std::string msg = lua_tostring(tolua_S, 1);
        std::string title = lua_tostring(tolua_S, 2);

        MessageBox(msg.c_str(), title.c_str());
	}
	return 1;
}

static int toLua_AppDelegate_nativeIsDebug(lua_State* tolua_S)
{
#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
	lua_pushboolean(tolua_S, 1);
#else
	lua_pushboolean(tolua_S, 0);
#endif
	return 1;
}

static int toLua_AppDelegate_containEmoji(lua_State* tolua_S)
{
    bool bContain = false;
    auto argc = lua_gettop(tolua_S);
    if (1 == argc)
    {
        std::string msg = lua_tostring(tolua_S, 1);
        std::u16string ut16;
        if (StringUtils::UTF8ToUTF16(msg, ut16))
        {
            if (false == ut16.empty())
            {
                size_t len = ut16.length();
                for (size_t i = 0; i < len; ++i)
                {
                    char16_t hs = ut16[i];
                    if (0xd800 <= hs && hs <= 0xdbff)
                    {
                        if (ut16.length() > (i + 1))
                        {
                            char16_t ls = ut16[i + 1];
                            int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                            if (0x1d000 <= uc && uc <= 0x1f77f)
                            {
                                bContain = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        if (0x2100 <= hs && hs <= 0x27ff)
                        {
                            bContain = true;
                        }
                        else if (0x2B05 <= hs && hs <= 0x2b07)
                        {
                            bContain = true;
                        }
                        else if (0x2934 <= hs && hs <= 0x2935)
                        {
                            bContain = true;
                        }
                        else if (0x3297 <= hs && hs <= 0x3299)
                        {
                            bContain = true;
                        }
                        else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
                        {
                            bContain = true;
                        }
                    }
                }
            }
        }
    }
    lua_pushboolean(tolua_S, bContain);
    return 1;
}

static int toLua_AppDelegate_convertToGraySprite(lua_State* tolua_S)
{
    bool bSuccess = false;
    auto argc = lua_gettop(tolua_S);
    if (1 == argc)
    {
        Sprite *sp = (Sprite*)tolua_tousertype(tolua_S, 1, nullptr);
        if (nullptr != sp)
        {
            const GLchar* pszFragSource =
            "#ifdef GL_ES \n \
            precision mediump float; \n \
            #endif \n \
            uniform sampler2D u_texture; \n \
            varying vec2 v_texCoord; \n \
            varying vec4 v_fragmentColor; \n \
            void main(void) \n \
            { \n \
            // Convert to greyscale using NTSC weightings \n \
            vec4 col = texture2D(u_texture, v_texCoord); \n \
            float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114)); \n \
            gl_FragColor = vec4(grey, grey, grey, col.a); \n \
            }";
            GLProgram* pProgram = new GLProgram();
            pProgram->initWithByteArrays(ccPositionTextureColor_noMVP_vert, pszFragSource);
            sp->setGLProgram(pProgram);
            pProgram->release();
            
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORD);
            
            sp->getGLProgram()->link();
            sp->getGLProgram()->updateUniforms();
            bSuccess = true;
        }
    }
    lua_pushboolean(tolua_S, bSuccess);
    return 1;
}

static int toLua_AppDelegate_convertToNormalSprite(lua_State* tolua_S)
{
    bool bSuccess = false;
    auto argc = lua_gettop(tolua_S);
    if (1 == argc)
    {
        Sprite *sp = (Sprite*)tolua_tousertype(tolua_S, 1, nullptr);
        if (nullptr != sp)
        {
            const GLchar* pszFragSource =
            "#ifdef GL_ES \n \
            precision mediump float; \n \
            #endif \n \
            uniform sampler2D u_texture; \n \
            varying vec2 v_texCoord; \n \
            varying vec4 v_fragmentColor; \n \
            void main(void) \n \
            { \n \
            // Convert to greyscale using NTSC weightings \n \
            vec4 col = texture2D(u_texture, v_texCoord); \n \
            gl_FragColor = vec4(col.r, col.g, col.b, col.a); \n \
            }";
            GLProgram* pProgram = new GLProgram();
            pProgram->initWithByteArrays(ccPositionTextureColor_noMVP_vert, pszFragSource);
            sp->setGLProgram(pProgram);
            pProgram->release();
            
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORD);
            
            sp->getGLProgram()->link();
            sp->getGLProgram()->updateUniforms();
            bSuccess = true;
        }
    }
    lua_pushboolean(tolua_S, bSuccess);
    return 1;
}

#ifdef WIN32
static int win_gettimeofday(struct timeval * val, struct timezone *)
{
	if (val)
	{
		SYSTEMTIME wtm;
		GetLocalTime(&wtm);

		struct tm tTm;
		tTm.tm_year	 = wtm.wYear - 1900;
		tTm.tm_mon	  = wtm.wMonth - 1;
		tTm.tm_mday	 = wtm.wDay;
		tTm.tm_hour	 = wtm.wHour;
		tTm.tm_min	  = wtm.wMinute;
		tTm.tm_sec	  = wtm.wSecond;
		tTm.tm_isdst	= -1;

		val->tv_sec	 = (long)mktime(&tTm);	   // time_t is 64-bit on win32
		val->tv_usec	= wtm.wMilliseconds * 1000;
	}
   return 0;
}
#endif

static long long getCurrentTime()  
{   
    struct timeval tv;   
#ifdef WIN32
    win_gettimeofday(&tv,NULL);
#else
    gettimeofday(&tv,NULL);
#endif 
	long long ms = tv.tv_sec;
    return ms * 1000 + tv.tv_usec / 1000;
} 
static int toLua_AppDelegate_currentTime(lua_State* tolua_S)
{
	long long curtime = getCurrentTime();
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	//CCLOG("currentTime:%I64d",curtime);
#else
	//CCLOG("currentTime:%lld",curtime);
#endif
	lua_pushnumber(tolua_S, curtime);
	return 1;
}


// If you want to use packages manager to install more packages,
// don't modify or remove this function
static int register_all_packages()
{
	lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
	luaopen_lua_extensions_j(tolua_S);

	register_all_cocos2dx_game(tolua_S);
	register_all_cocos2dx_notification(tolua_S);
	register_all_cocos2dx_game_cocos_extention(tolua_S);
	register_all_cocos2dx_kernel(tolua_S);
	register_all_cocos2dx_platform(tolua_S);
	register_all_cocos2dx_tool(tolua_S);

	register_all_cmd_data();
	register_all_Integer64();
	register_all_client_socket();
	register_all_curlasset();
	register_all_logasset();
	register_all_Circleasset();
    register_all_QrNode();
    register_all_AESEncrypt();
    register_all_recorder();
    register_all_RyUtil();

	lua_register(tolua_S,"checkData",toLua_AppDelegate_checkData);
	lua_register(tolua_S,"md5",toLua_AppDelegate_MD5);
	lua_register(tolua_S,"readByDecrypt",toLua_AppDelegate_ReadByDecrypt);
	lua_register(tolua_S,"saveByEncrypt",toLua_AppDelegate_SaveByEncrypt);
	lua_register(tolua_S,"loadImageByte",toLua_AppDelegate_LoadImageByte);
	lua_register(tolua_S, "cleanImageByte", toLua_AppDelegate_CleanImageByte);
	lua_register(tolua_S,"downFileAsync",toLua_AppDelegate_downFileAsync);
	lua_register(tolua_S,"unZipAsync",toLua_AppDelegate_unZipAsync);
	lua_register(tolua_S,"setbackgroundcallback",toLua_AppDelegate_setbackgroundcallback);
	lua_register(tolua_S,"removebackgroundcallback",toLua_AppDelegate_removebackgroundcallback);
	lua_register(tolua_S,"onUpDateBaseApp",toLua_AppDelegate_onUpDateBaseApp);
	lua_register(tolua_S,"createDirectory",toLua_AppDelegate_createDirectory);
	lua_register(tolua_S,"removeDirectory",toLua_AppDelegate_removeDirectory);
	lua_register(tolua_S,"currentTime",toLua_AppDelegate_currentTime);

	lua_register(tolua_S,"createSpriteWithBMPFile",toLua_AppDelegate_createSpriteByBMPFile);
    lua_register(tolua_S,"createSpriteFrameWithBMPFile",toLua_AppDelegate_createSpriteFrameByBMPFile);
    lua_register(tolua_S,"reSizeGivenFile",toLua_AppDelegate_reSizeGivenFile);
    lua_register(tolua_S,"nativeMessageBox",toLua_AppDelegate_nativeMessageBox);
    lua_register(tolua_S,"isDebug",toLua_AppDelegate_nativeIsDebug);
    lua_register(tolua_S,"containEmoji",toLua_AppDelegate_containEmoji);
    lua_register(tolua_S,"convertToGraySprite", toLua_AppDelegate_convertToGraySprite);
    lua_register(tolua_S,"convertToNormalSprite", toLua_AppDelegate_convertToNormalSprite);
    
    return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    AudioEngine::lazyInit();
#endif
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);
     Director::getInstance()->setDisplayStats(false);
    auto listener = EventListenerCustom::create(EVENT_MESSAGEBOX_OK_CLICK, [](EventCustom *event)
                                                {
                                                    __String *msg = (__String*)event->getUserData();
                                                    if(0 == strcmp(msg->getCString(), "lua_src_error"))
                                                    {
                                                        cocos2d::log("lua_error");
                                                        bool bHandle = false;
                                                        #if CC_ENABLE_SCRIPT_BINDING
                                                        	lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    														lua_getglobal(tolua_S, "g_LuaErrorHandle");
    														if (lua_isfunction(tolua_S, -1))
    														{
    															int nRes = lua_pcall(tolua_S, 0, 1, 0);
    															if (0 == nRes)
    															{
    																if (lua_isnumber(tolua_S, -1))
    																{
    																	bHandle = lua_tointeger(tolua_S, -1) == 1;
    																}
    																else if (lua_isboolean(tolua_S, -1))
    																{
    																	bHandle = lua_toboolean(tolua_S, -1);
    																}    																
    															}
    														}
                                                        #endif
    													if (false == bHandle)
    													{
    														Director::getInstance()->end();
    													}
                                                    }
                                                });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(listener, 1);


	CCTexture2D::setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
	CCTexture2D::PVRImagesHavePremultipliedAlpha(true);
	ZipUtils::ccSetPvrEncryptionKeyPart(0, 0x11111111);
	ZipUtils::ccSetPvrEncryptionKeyPart(1, 0x22222222);
	ZipUtils::ccSetPvrEncryptionKeyPart(2, 0x33333333);
	ZipUtils::ccSetPvrEncryptionKeyPart(3, 0x44444444);
	srand((unsigned int)time(0));

    // register lua module
    auto engine = LuaEngine::getInstance();

    auto isDebug = false;
#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
	isDebug = true;
#endif
    // Init the Bugly
#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
    #if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    	CrashReport::initCrashReport("a5f9bb958c", isDebug);
    #elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    	CrashReport::initCrashReport("3e0294e192", isDebug);
    #endif    
    BuglyLuaAgent::registerLuaExceptionHandler(engine);
#endif

    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

    register_all_packages();

    Device::setKeepScreenOn(true);
	
	if(((CClientKernel*)m_pClientKernel)->OnInit()==false)
	{
		CCLOG("[_DEBUG]	ClientKernel_onInit_FALSE!");
		return false;
	}

    LuaStack* stack = engine->getLuaStack();
	
	stack->setXXTEAKeyAndSign("c5l0qU0aIZRBLfI2pKf", strlen("c5l0qU0aIZRBLfI2pKf"), "R3HkX82TtxvEK0", strlen("R3HkX82TtxvEK0"));
	stack->addSearchPath("src/");
    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());
	/*
 #if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
     // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
     auto runtimeEngine = RuntimeEngine::getInstance();
     runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
     runtimeEngine->start();
#else*/
	CCLOG("wirtePath:%s", CCFileUtils::getInstance()->getWritablePath().c_str());
    if (engine->executeScriptFile("base/src/main.lua"))
    {
        return false;
    }
	/*
#endif*/

	IMCKernel *kernel = GetMCKernel();
	if (kernel)
	{
		kernel->SetLogOut((ILog*)((CClientKernel*)m_pClientKernel));
		CCLOG("KERNEL SUCCEED:%s", kernel->GetVersion());
	}
	else{
		CCLOG("Load MCKernel Faild************************************************");
		return false;
	}

	SCHEDULE->scheduleSelector(schedule_selector(AppDelegate::GlobalUpdate), this, 0, kRepeatForever, 0,false);
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
#if  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    AudioEngine::pauseAll();
#endif
    //一个监听
    auto _eventAppdidWillenter = new(std::nothrow)EventCustom("APP_ENTER_BACKGROUND_ENENT_WEBCLOSE");
    Director::getInstance()->getEventDispatcher()->dispatchEvent(_eventAppdidWillenter);
	if (m_BackgroundCallBack != 0)
	{
		lua_State* tolua_S=LuaEngine::getInstance()->getLuaStack()->getLuaState();
		toluafix_get_function_by_refid(tolua_S, m_BackgroundCallBack);
		if (lua_isfunction(tolua_S, -1))
		{
			lua_pushboolean(tolua_S, 0);
			LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(m_BackgroundCallBack, 1)!=0;
		}else{
			CCLOG("applicationDidEnterBackground-luacallback-handler-false:%d",m_BackgroundCallBack);
		}
	}
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
   
    Director::getInstance()->startAnimation();

#if  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    AudioEngine::resumeAll();
#endif
    //一个监听
    auto _eventAppdidWillenter = new(std::nothrow)EventCustom("APP_ENTER_BACKGROUND_ENENT_WEBRECONNECTED");
    Director::getInstance()->getEventDispatcher()->dispatchEvent(_eventAppdidWillenter);
    //处理缓存
    for (auto it = m_cachedBmpTex.cbegin(); it != m_cachedBmpTex.cend();)
    {
    	Texture2D *tex = it->second;
    	CCLOG("ref count %d", tex->getReferenceCount());
    	if (tex->getReferenceCount() == 1)
    	{
    		CCLOG("removing unused bmp texture :%s", it->first.c_str());
    		tex->release();
    		m_cachedBmpTex.erase(it++);
    	}
    	else
    	{
    		++it;
    	}
    }
    //重新加载数据
    for (auto it = m_cachedBmpTex.cbegin(); it != m_cachedBmpTex.cend(); ++it)
    {
    	bool bHave = false;
	    unsigned char *data = getBMPFileData(it->first.c_str(), bHave);
	    if (nullptr != data && true == bHave )
	    {
	    	it->second->initWithData(data, 96 * 96 * 4, Texture2D::PixelFormat::RGBA8888, 96, 96, cocos2d::Size(96, 96));
	    }    	
    }

	if (m_BackgroundCallBack != 0)
	{
		lua_State* tolua_S=LuaEngine::getInstance()->getLuaStack()->getLuaState();
		toluafix_get_function_by_refid(tolua_S, m_BackgroundCallBack);
		if (lua_isfunction(tolua_S, -1))
		{
			lua_pushboolean(tolua_S, 1);
			LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(m_BackgroundCallBack, 1)!=0;
		}else{
			CCLOG("applicationDidEnterBackground-luacallback-handler-false:%d",m_BackgroundCallBack);
		}
	}
}

void AppDelegate::GlobalUpdate(float dt)
{
	CClientKernel* pKernel = (CClientKernel*)AppDelegate::getAppInstance()->getClientKernel();
	if(pKernel)
		pKernel->GlobalUpdate(dt);
	else
		CCLOG("GlobalUpdate m_pClientKernel is null");
}

