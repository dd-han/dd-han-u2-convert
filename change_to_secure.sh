#/bin/bash
#################################################
## u2專用 passkey 轉 Secure 轉換程式 -         ##
##                                修改種子檔案 ##
## 作者：dd-han                                ##
## 本程無償提供u2.dmhy.org所有使用者使用與修改 ##
#################################################

## transmission-edit允許修改tracker的「部分」 但是沒辦法用萬用字元把原本的Tracker刪除
## 完整的是https://tracker.u2.dmhy.org/announce.php?passkey=XXXXXXXX
## 我們要把?後面的passkey=XXXXXXXX改成secure=XXXXXXXX
## 因此這裡需要提供Passkey才能修改種子內的Tracker
passkey='輸入您的Passkey XXXXXXXX就好，=或是前面的都別輸入'

## 開始一個種子一個種子的處理
for torrent_data in $(cat list) 
do
	## 抽出檔名並還原
	torrent_name=$(echo ${torrent_data} | sed s/\{secure\}.*//g | sed s/\{space\}/\ /g )
	
	## 抽出Secure資訊
	torrent_secure=$(echo ${torrent_data} | sed s/.*\{secure\}//g )
	
	#echo torrent_name=${torrent_name} and torrent_secure=${torrent_secure}
	
	## 開始修改Tracker後面的passkey、並改為secure
	transmission-edit -r "passkey=*" "secure=${torrent_secure}" "${torrent_name}"
	## 好像沒差也好像不能用...
	##transmission-edit -r "tracker.dmhy.org" "tracker.u2.dmhy.org" "${torrent_name}"
	## 順便全部改用https連線
	transmission-edit -r "http://" "https://" "${torrent_name}"
	
done
