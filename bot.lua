package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
URL = require('socket.url')
JSON = require('dkjson')
HTTPS = require('ssl.https')
redis_server = require('redis') --https://github.com/nrk/redis-lua
redis = redis_server.connect('127.0.0.1', 6379)
----config----
local bot_api_key = "" --Your telegram bot api key
local BASE_URL = "https://api.telegram.org/bot"..bot_api_key
local BASE_FOLDER = ""
local start = [[/setdn `<done msg>`
_will set auto response message_
/setid 
_will set realm id_
/block
_block user by reply_
/unblock
_unblock user by reply_
/getid
_get realm id_    `(for test)`
/users
_list users count_
/setst `<start msg>`
_set start text you can use {USERNAME} and {FIRSTNAME} for info of user started bot_
/id
_send group id_
/init
_reload bot!_
]] 

-------

----utilites----

function is_admin(msg)-- Check if user is admin or not
  local var = false
  local admins = {140529465}-- put your id here
  for k,v in pairs(admins) do
    if msg.from.id == v then
      var = true
    end
  end
  return var
end
function is_realm(msg)
local var = false
local realm = redis:get('pmrsn:setid')
if realm and msg.from.id == realm then
	var = true
end
return var
end
function sendRequest(url)
-- 	local test = print(url)
  local dat, res = HTTPS.request(url)
  local tab = JSON.decode(dat)

  if res ~= 200 then
    return false, res
  end

  if not tab.ok then
    return false, tab.description
  end

  return tab

end
function adduser(msg)
	redis:sadd('pmrsn:users',msg.from.id)
end
function userlist(msg)
	local users = 'Bot users count:\n`'..redis:scard('pmrsn:users')..'`'
return users
end
function getMe()--https://core.telegram.org/bots/api#getfile
    local url = BASE_URL .. '/getMe'
  return sendRequest(url)
end

function getUpdates(offset)--https://core.telegram.org/bots/api#getupdates

  local url = BASE_URL .. '/getUpdates?timeout=20'

  if offset then

    url = url .. '&offset=' .. offset

  end

  return sendRequest(url)

end
sendSticker = function(chat_id, sticker, reply_to_message_id)

	local url = BASE_URL .. '/sendSticker'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "sticker=@' .. sticker .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	io.popen(curl_command):read("*all")
	return end

sendPhoto = function(chat_id, photo, caption, reply_to_message_id)

	local url = BASE_URL .. '/sendPhoto'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "photo=@' .. photo .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if caption then
		curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
	end

	io.popen(curl_command):read("*all")
	return end

forwardMessage = function(chat_id, from_chat_id, message_id)

	local url = BASE_URL .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	return sendRequest(url)

end

function sendMessage(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)--https://core.telegram.org/bots/api#sendmessage

	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	if disable_web_page_preview == true then
		url = url .. '&disable_web_page_preview=true'
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end

	return sendRequest(url)

end
function sendDocument(chat_id, document, reply_to_message_id)--https://github.com/topkecleon/otouto/blob/master/bindings.lua

	local url = BASE_URL .. '/sendDocument'

	local curl_command = 'cd \''..BASE_FOLDER..currect_folder..'\' && curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end
	io.popen(curl_command):read("*all")
	return

end

function download_to_file(url, file_name, file_path)--https://github.com/yagop/telegram-bot/blob/master/bot/utils.lua
  print("url to download: "..url)

  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  -- nil, code, headers, status
  local response = nil
    options.redirect = false
    response = {HTTPS.request(options)}
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return nil end
  local file_path = BASE_FOLDER..currect_folder..file_name

  print("Saved to: "..file_path)

  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------

function bot_run()
	bot = nil

	while not bot do -- Get bot info
		bot = getMe()
	end

	bot = bot.result

	local bot_info = "Username = @"..bot.username.."\nName = "..bot.first_name.."\nId = "..bot.id.." \nbased on linux-file-manager :D\nthx to @imandaneshi\neditor: @unfriendly"

	print(bot_info)

	last_update = last_update or 0

	is_running = true

	currect_folder = ""
end

function msg_processor(msg)
	if msg.new_chat_participant or msg.new_chat_title or msg.new_chat_photo or msg.left_chat_participant then return end
	if msg.audio or msg.document or msg.video or msg.voice then return end -- Admins only !
	if msg.date < os.time() - 5 then -- Ignore old msgs
		return
    end



	if msg.sticker then
		if msg.chat.type == 'private' then
		local output = redis:get('pmrsn:setid')
		if output then
			forwardMessage(output,msg.chat.id,msg.message_id)
			if msg.from.username then
				username = '@'..msg.from.username
			else
				username = '----'
			end
			local text = sendMessage(output,'`sticker from:`\n\n'..username..'\n*'..msg.chat.first_name..'*',true,nil,true)
		end
			end
		end
	if msg.photo then
		if msg.chat.type == 'private' then
		local output = redis:get('pmrsn:setid')
		if output then
			forwardMessage(output,msg.chat.id,msg.message_id)
			if msg.from.username then
				username = '@'..msg.from.username
			else
				username = '----'
			end
			local text = sendMessage(output,'`photo from:`\n\n'..username..'\n*'..msg.chat.first_name..'*',true,nil,true)
		end
		
			
	elseif msg.sticker and msg.reply_to_message and msg.reply_to_message.forward_from then
	local user = msg.reply_to_message.forward_from.id
				forwardMessage(user,msg.chat.id,msg.message_id)
	end
		
	elseif msg.text:match("^/setdn (.*)") and is_realm(msg) then
		local matches = { string.match(msg.text, "^/setdn (.*)") }
		redis:set('pmrsn:setdn',matches[1])
		sendMessage(msg.chat.id,'Done!')
 
	
	elseif msg.text:match("^/setid") and is_admin(msg) then
	redis:set('pmrsn:setid',msg.chat.id)
  sendMessage(msg.chat.id, 'i added `'..msg.chat.id..'` as realm', true, false, true)
	
	elseif msg.reply_to_message and msg.reply_to_message.forward_from then
		if msg.text:match("^/block") and msg.chat.type ~= 'private' then
		local user = msg.reply_to_message.forward_from.id
		redis:sadd('pmrsn:blocks',user)
		local torealm = sendMessage(msg.chat.id,'User has been added to block list!')
		local touser = sendMessage(user, 'You are *blocked* from bot \n _Sorry_', true, false, true)
			elseif msg.text:match("^/unblock") and msg.chat.type ~= 'private' then
		local user = msg.reply_to_message.forward_from.id
		redis:srem('pmrsn:blocks',user)
		local torealm = sendMessage(msg.chat.id,'User has been removed from block list!')
		local touser = sendMessage(user, 'You has been *unblocked* :)))', true, false, true)
		else
		local user = msg.reply_to_message.forward_from.id
		sendMessage(user,msg.text)
		end
	
	elseif msg.text:match("^/getid") and is_admin(msg) then
	local output = redis:get('pmrsn:setid')
		if output then
  		sendMessage(msg.chat.id, 'realm id is :\n`'..output..'`', true, false, true)
		else
	   	sendMessage(msg.chat.id,"i don't have any realm")
		end
	
	elseif msg.text:match("^/users") and is_realm(msg) then
		local list = userlist(msg)
		sendMessage(msg.chat.id,list,true,nil,true)
	elseif msg.text:match("^/blocklist") and is_realm(msg) then
		local list = redis:hkeys('pmrsn:blocks')
		    local text = 'Blocked Users list :\n______________________________\n'
                    for i=1, #list do
                    text = text..'> '..list[i]..'\n'
                end
		sendMessage(msg.chat.id,text,true,nil,true)
		
	elseif msg.text:match("^/setst (.*)") and is_realm(msg) then
		local matches = { string.match(msg.text, "^/setst (.*)") }
		local text = matches[1]
		redis:set('pmrsn:setst',matches[1])
		sendMessage(msg.chat.id,'Done!')

	
	elseif msg.text:match("^/id") then
	sendMessage(msg.chat.id,msg.chat.id)
	
	elseif msg.text:match("^/init") and is_realm(msg) then
	bot_run()
		local txt = sendMessage(msg.chat.id,'Done!')



  
elseif msg.chat.type == 'private' then
		if msg.text:match("^/[Hh]elp") then
			sendMessage(msg.chat.id,start,true,msg.message_id,true)
	        end
		if msg.text:match("^/[sS]tart") then
			local text = redis:get('pmrsn:setst')
 			local text = string.gsub(text,"{USERNAME}",msg.from.username)
			local text = string.gsub(text,"{FIRSTNAME}",msg.from.first_name)
			sendMessage(msg.chat.id,text,false,nil,true)
			local ttaua = adduser(msg)
			--[[local ttaub = redis:get('pmrsn:users')
			local ttauc = sendMessage(msg.chat.id,ttaub)]]
		else
			local output = redis:get('pmrsn:setid')
			local dn = redis:get('pmrsn:setdn')
			local blocked = redis:sismember('pmrsn:blocks',msg.from.id)
			
			if output and dn then
				if blocked then
					return false
					
					else
					
					forwardMessage(output,msg.chat.id,msg.message_id)
					local text = sendMessage(msg.chat.id,dn,true,nil,true)
					end
			else
				return 
			end
				
			end

return end

end
bot_run() -- Run main function
while is_running do -- Start a loop witch receive messages.
	local response = getUpdates(last_update+1) -- Get the latest updates using getUpdates method
	if response then
		for i,v in ipairs(response.result) do
			last_update = v.update_id
			msg_processor(v.message)
		end
	else
		print("Conection failed")
	end

end
print("Bot halted")
