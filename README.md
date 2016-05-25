# lua-pmrsn
*Bot commands =>*
```
/setdn <done msg>
```
will set auto response message
```
/setid 
```
will set realm id
```
/block
```
block user by reply
```
/unblock
```
unblock user by reply
```
/blocklist
```
will send blocked users list
```
/getid
```
get realm id    (for test)
```
/users
```
list users count
```
/setst <start msg>
```
set start text you can use {USERNAME} and {FIRSTNAME} for info of user started bot
```
/id
```
send group id
```
/init
```
reload bot!

#installation
```
# Download and install LuaSocket, LuaSec, Redis-Lua, ansicolors and serpent

 wget http://luarocks.org/releases/luarocks-2.2.2.tar.gz
 tar zxpf luarocks-2.2.2.tar.gz
 cd luarocks-2.2.2
 ./configure; sudo make bootstrap
 sudo luarocks install luasocket
 sudo luarocks install luasec
 sudo luarocks install redis-lua
 sudo luarocks install lua-term
 sudo luarocks install serpent
 cd ..
 
 #Launch BOT!
 git clone https://github.com/Mrhalix/lua-pmrsn
 cd lua-pmrsn
 chmod +x ./launch.sh
 ./launch.sh
```
then add bot to your realm
and send
```
/setid
```
and set your start text and done text by
```
/setdn <msg>
/sets <your text> you can use {USERNAME} and {FIRSTNAME}
```
#Credits
Created by ❤️ in iran

by =>

[Mrhalix](http://telegram.me/mrhalix)

Powered By [ROYALTEAM](http://telegram.me/royalteamch)
{Special Tnx To [AmirSbss](http://telegram.me/Amir_h) For Block List}
