#/bin/bash
#################################################
## u2專用 passkey 轉 Secure 轉換程式 -         ##
##                                取得種子清單 ##
## 作者：dd-han                                ##
## 本程無償提供u2.dmhy.org所有使用者使用與修改 ##
#################################################

## 過濾條件，基本上就是檢查所有的資訊，包含以下就是目標
Torrent_grep='dmhy.org/announce.php?passkey'

## 取得清單並把空白換成{space}，因為for看到空白就會當成下一個案例去處理(汗)
torrent_list=$(ls $1/*.torrent | sed s/\ /\{space\}/g);

## 開始檢查種子
for torrent in ${torrent_list} 
do
	## 先還原檔名
	torrent_name=$(echo ${torrent} | sed s/\{space\}/\ /g )
	#echo torrent=${torrent}  and  torrent_name=${torrent_name}
	
	## 呼叫transmission-show檢視種子
	## 並將資訊輸出到current_info，變數內不能儲存換行
	transmission-show "$torrent_name" > current_info
	
	## 測試是不是u2的種子
	cat current_info | grep "${Torrent_grep}" >> /dev/null
	if [ $? == "0" ]; then
		## 如果是花園的種子(而且是包含passkey的種子)就列入清單
		#echo ${torrent}是u2花園的種子
		echo ${torrent}\{hash\}$(cat current_info  | grep Hash | sed s/[^H]*Hash\:\ //g | sed s/\ .*//g ) >> list
	#else
		## 否則啥都別做
		#echo ${torrent}不是u2花園的種子
	fi
	
	## 清除暫存資訊
	rm current_info
done

