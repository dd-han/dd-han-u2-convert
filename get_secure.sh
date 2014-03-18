#!/bin/bash
#################################################
## u2專用 passkey 轉 Secure 轉換程式 -         ##
##                                  取得Secure ##
## 作者：dd-han                                ##
## 本程無償提供u2.dmhy.org所有使用者使用與修改 ##
#################################################

## 一次只能搜尋100個種子
count=0
count_max=99

## 冷卻時間設定(其實可以改短一點，甚至產生JSON過程有可能會超過2秒)
coldown=2


## API Key請在這裡輸入
## API Key就是https://u2.dmhy.org/jsonrpc_torrentkey.php?apikey= 後面的64碼亂入
API='請把apikey=後面的64碼亂數貼上這邊'

## API URL自動產生處
## 雖然是用HTTPS但是沒有檢查證書，請小心偽造網站
API_URL="https://u2.dmhy.org/jsonrpc_torrentkey.php?apikey=${API}"

## 送出查詢請求並將查到的結果更新至list的函數
function submitJSON () {
	## 配合API的查詢間隔
	echo "查詢技能冷卻中"
	sleep $coldown
	GET_JSON=$(curl --insecure -H "Content-Type: application/json" -X POST -d "$1" "${API_URL}")
	
	#echo 送出的JSON長這樣：
	#echo $1 >> sent_jsons
	#echo "$GET_JSON" >> get_json
	
	## 簡單的處理一下JSON，讓Shell更好解析
	echo $GET_JSON | sed s/[\]\[\{]//g | sed s/[}]/\\n/g | sed s/^,//g | sed s/\"jsonrpc\":\"2\.0\"\,//g | grep "result" > secure.txt
	
	#cat secure.txt >> secures.txt
	
	## 將查詢到的secure寫入list
	for lines in $(cat secure.txt)
	do
		## 抽離代號num與密鑰secure
		num=$(echo $lines | sed s/.*id\"\://g)
		sec=$(echo $lines | sed s/\"result\":\"//g | sed s/\".*//g)
		#echo num=${num} key=${sec} >> num_secs.txt
		
		## 修改list中的num改為key
	    sed -i s/\{id\}${num}$/\{secure\}${sec}/g list
	done
	
	##清除簡單解析的JSON
	rm secure.txt
}



## 抓出清單中種子的Hash，如果到達單筆查詢上限就先查詢並寫入list
for line in $(cat list) 
do
	## 過濾出列表中的hash
	torrent_hash=$(echo $line | sed s/.*\{hash\}//g)
	count=$(($count+1))
	#echo $count $torrent_hash
	
	## 產生JSON內容
	if [ $count == "1" ]; then
		## JSON內容初始化
		JSON_DATA="["
	else
		## 加上不同筆資料的,
		JSON_DATA="${JSON_DATA},"
	fi
	JSON_DATA="${JSON_DATA}{\"jsonrpc\":\"2.0\",\"method\":\"query\",\"params\":\"${torrent_hash}\",\"id\":${count}}"
	
	## 將清單中的hash取代成ID(count)，查詢之後只剩ID(count)沒有Hash
	sed -i s/\{hash\}${torrent_hash}/\{id\}${count}/g list
	
	## 檢查有沒有超過上限，超過就送出查詢
	if [ ${count} == "${count_max}"  ]; then
		## 把JSON資料結束(加上])並送出
		JSON_DATA="${JSON_DATA}]"
		#echo $JSON_DATA
		submitJSON "$JSON_DATA"
		
		## 歸零，繼續累積資料
		count=0
	fi
done

## 可能還剩下一些資料沒送出，在這裡一併送出
JSON_DATA="${JSON_DATA}]"
submitJSON "${JSON_DATA}"
