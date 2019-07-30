#!/bin/bash

Cur_Dir=$(pwd)
CIPHERCODE_DIR=$Cur_Dir/../client/ciphercode
GAMELIST_TXT="game_list.txt"

# 加密出错提示
function CipherSrcError() {
echo $1
read -n 1
exit
}


# 压缩文件
function ZipFile() {

pushd $CIPHERCODE_DIR

echo "zip client .."
zip -q -r $CIPHERCODE_DIR/base/res/client.zip client

if [ $? -eq 1 ]
then
CipherSrcError "压缩client出错"
fi

#压缩游戏
echo "zip game .."
cp -f $Cur_Dir/$GAMELIST_TXT $CIPHERCODE_DIR
i=0
for line in  `cat $GAMELIST_TXT`
do
	#跳过第一行
	i=`expr $i + 1`
	if [ $i == 1 ] 
	then 
		continue 
	fi

    iszip1=`echo $line | cut -d \, -f 5`
    iszip2=`echo $iszip1 | cut -d \= -f 2`
    if [ $iszip2 == 0 ]
    then
        continue
    fi
	
	name1=`echo $line | cut -d \, -f 1`
	name2=`echo $name1 | cut -d \= -f 2`
	
	folder1=`echo $line | cut -d \, -f 4`
	folder2=`echo $folder1 | cut -d \= -f 2`

	echo "          -> "${name2}" "${folder2}

	game1=`echo $line | cut -d \, -f 3`
	game2=`echo $game1 | cut -d \= -f 2`
	
	zip -q -r $CIPHERCODE_DIR/base/res/game.zip ${game2}/${folder2}
done
rm $CIPHERCODE_DIR/$GAMELIST_TXT

}

# 主体代码
echo "*********************lua文件加密*********************"

rm -rf $CIPHERCODE_DIR/client
rm -rf $CIPHERCODE_DIR/game
rm -rf $CIPHERCODE_DIR/base
rm -rf $CIPHERCODE_DIR/command

echo "    -> client"
cocos luacompile -s $Cur_Dir/../client/client -d $CIPHERCODE_DIR/client -e -k c5l0qU0aIZRBLfI2pKf -b R3HkX82TtxvEK0 --disable-compile
if [ $? -eq 1 ]
then
CipherSrcError "lua文件加密出错"
fi

echo "    -> game"
cocos luacompile -s $Cur_Dir/../client/game -d $CIPHERCODE_DIR/game -e -k c5l0qU0aIZRBLfI2pKf -b R3HkX82TtxvEK0 --disable-compile
if [ $? -eq 1 ]
then
CipherSrcError "lua文件加密出错"
fi

echo "    -> base"
cocos luacompile -s $Cur_Dir/../client/base -d $CIPHERCODE_DIR/base -e -k c5l0qU0aIZRBLfI2pKf -b R3HkX82TtxvEK0 --disable-compile
if [ $? -eq 1 ]
then
CipherSrcError "lua文件加密出错"
fi

echo "    -> command"
cocos luacompile -s $Cur_Dir/../client/command -d $CIPHERCODE_DIR/command -e -k c5l0qU0aIZRBLfI2pKf -b R3HkX82TtxvEK0 --disable-compile
if [ $? -eq 1 ]
then
CipherSrcError "lua文件加密出错"
fi

echo "*********************复制资源文件*********************"
# 复制资源文件
cp -Rf $Cur_Dir/../client/game $CIPHERCODE_DIR
cp -Rf $Cur_Dir/../client/client $CIPHERCODE_DIR
cp -Rf $Cur_Dir/../client/base $CIPHERCODE_DIR
# 删除所有.lua文件
find $CIPHERCODE_DIR -type f -name '*.lua' -delete
echo ""

#echo "*********************加密图片文件*********************"
## 加密图片文件
#. ./encryptImage.sh
#echo ""

echo "*********************生成文件的md5表*********************"
# 生成文件的md5表
. ./make_FileMD5List.sh
echo ""

echo "*********************压缩zip*********************"
# 压缩文件
if [ $? -eq 0 ]
then
ZipFile
fi

date=`date +%H:%M:%S`
echo "*********************完成(${date})*********************"
exit