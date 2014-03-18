#動漫花園PT站u2轉換工具

##功能：
可以呼叫transmission的cli工具，將種子從passkey改成每個種子獨立的密鑰。

##系統需求：
* bash
* curl
* grep
* sed
* transmission-cli

#用法：
1. 執行./get__torrent.sh torrent__file__path，這個動作會收集該資料夾中所有u2站的「種子檔案的檔名」與「種子的HASH」並以絕對路徑紀錄在list檔案。
2. 修改get__secure.sh第19行的API鑰匙後，執行./get__secure.sh，接著就會產生包含序號、Hash的JSON並丟給伺服器取得鑰匙後，將list中的HASH替換成安全密鑰。
3. 修改change__to__secure第13行，填入passkey好讓transmission-cli取代資訊後，執行./change__to__secure.sh，將種子檔案的track訊息換成安全密鑰，會順便把所有的種子換成https連線，如果不需要請註解第31行
