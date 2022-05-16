-- title:   The Imposition of Angles
-- author:  Ian Brassard <ib3655@bard.edu>
-- desc:    CMSC 336 Games Systems MAKE assignment
-- license: GNU GPL 3.0
-- version: 0.1
-- script:  lua

trace("Licensed under GPLv3")

--[[
TODO:
1. Enemies hurt player
2. Special enemy types
3. 10 levels
]]

-- constants
WIDTH = 240
HEIGHT = 136
MAX_ENEMIES = 100
BLACK = 0
RED = 2
BLUE = 9

-- class Player
Player = {x = 0, y = 8, sprite_id = 256, hp = 100, pwr = 1, score = 0}

function Player:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function Player:display()
	spr(self.sprite_id,self.x,self.y,BLACK,2,0,0,4,8)
end

function Player:laser(xpos, ypos)
	origin = {x = self.x + 37, y = self.y + 12}
	line(origin.x, origin.y, xpos, ypos, RED)
	line(origin.x, origin.y, xpos, ypos-1, RED)
	line(origin.x, origin.y, xpos, ypos+1, RED)
end

function Player:add_score()
	self.score = self.score + 1
end

function Player:get_score()
	return self.score
end

function Player:get_pwr()
	return self.pwr
end
-- Player end

-- class Enemy
Enemy = {x = WIDTH+10, y = HEIGHT/2, spr_id = 260, hp = 10, spd = 1, dead = false}

function Enemy:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function Enemy:display()
	spr(self.spr_id, self.x, self.y, 0, 1, 0, 0, 2, 2)
	circb(self.x+7,self.y+7,8,BLACK)
	rect(self.x,self.y,self.hp,3,RED)
end

function Enemy:hurt(dmg)
	if self.hp > 0 then self.hp = self.hp - dmg end
end

function Enemy:die()
	self.dead = true
end

function Enemy:move()
	self.x = self.x - self.spd
end

function Enemy:isAt(xpos, ypos)
	return dist(xpos, ypos, self.x + 7, self.y + 7) <= 8
end

function Enemy:update()
	if not self.dead then
		self:move()
		self:display()
	end
end
-- Enemy end

function dist(x1, y1, x2, y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function init_level(list, length, level)
	list = list or {}
	length = length or 10
	level = level or 1
	if level == 1 then
		for i = 1, length do
			list[i] = Enemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), spd = map(math.random(), 0, 1, 0.5, 1.5)}
		end
	elseif level == 2 then
		
	end
	set_state(level)
	total_dead = 0
	total_enemies = #list
	timer = nil
end

function map(n,x1,y1,x2,y2)  -- adapted from https://stackoverflow.com/questions/5731863/mapping-a-numeric-range-onto-another
	return x2 + ((y2 - x2)/(y1 - x1)) * (n - x1)
end

function set_state(n)
	last_state = game_state
	game_state = n
end

-- initialization
player = Player:new()
enemies = {}
total_enemies = 0
total_dead = 0
game_state = 0
last_state = 0

function TIC()
	mx,my,left = mouse()
	cls(BLUE)
	if game_state == -1 then							-- state -1: defeat
		print("u lose lmao", WIDTH/2, HEIGHT/2, RED)
	elseif game_state == 0 then							-- state 0: title
		str0 = "The Imposition"
		str1 = "Of Angles"
		str2 = "Click to fire laser."
		str3 = "Destroy all enemies."
		str4 = "Space to begin."
		pos0 = print(str0, 0, -100, BLACK, false, 2)
		pos1 = print(str1, 0, -100, BLACK, false, 2)
		pos2 = print(str2, 0, -100, BLACK, false, 1)
		pos3 = print(str3, 0, -100, BLACK, false, 1)
		pos4 = print(str4, 0, -100, BLACK, false, 1)
		print(str0, (WIDTH/2)-(pos0/2), 15, BLACK, false, 2)
		print(str1, (WIDTH/2)-(pos1/2), 27, BLACK, false, 2)
		print(str2, (WIDTH/2)-(pos2/2), HEIGHT/2, BLACK, false, 1)
		print(str3, (WIDTH/2)-(pos3/2), HEIGHT/2 + 10, BLACK, false, 1)
		print(str4, (WIDTH/2)-(pos4/2), HEIGHT/2 + 20, BLACK, false, 1)
		if keyp(48) then init_level(enemies, 10, 1) end
	elseif game_state == 1 then							-- state 1: level 1
		rem = MAX_ENEMIES - total_dead
		for i = 1, #enemies do
			if enemies[i] then
				enemies[i]:update()
				if left and enemies[i]:isAt(mx, my) then
					enemies[i]:hurt(player:get_pwr())
				end
				if enemies[i].hp <= 0 or enemies[i].x <= (player.x + 8) then
					enemies[i]:die()
					total_dead = total_dead + 1
					if total_enemies < MAX_ENEMIES then
						enemies[i] = Enemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), spd = map(math.random(), 0, 1, 0.5, 1.5)}
						total_enemies = total_enemies + 1
					else
						table.remove(enemies, i)
					end
				end
			end
		end
		player:display()
		if left then player:laser(mx, my) end
		print("enemies remaining: "..rem, WIDTH/2, 10, BLACK)
		if rem == 0 and not timer then
			timer = time()
		end
		if timer and time() - timer >= 2000 then
			init_level(enemies,10,2)
		end
	elseif game_state == 2 then							-- state 2: level 2
		print("space to restart", WIDTH/2 - 32, HEIGHT/2, BLACK)
		if keyp(48) then init_level(enemies, 10, 0) end
	elseif game_state == 11 then						-- state 11: victory
		mid_y = HEIGHT/2
		str0 = "Congratulations!"
		str1 = "You completed level "..last_state.."!"
		pos0 = print(str0, 0, -100, BLACK, false, 2)
		pos1 = print(str1, 0, -100, BLACK, false, 2)
		print(str0, (WIDTH/2)-(pos0/2), mid_y - 11, BLACK, false, 2)
		print(str1,(WIDTH/2)-(pos1/2), mid_y, BLACK, false, 2)
	end
end

-- <SPRITES>
-- 001:000000020000002c000002cc00002ccc0002cccc002ccccc02cccccc2ccccccc
-- 002:20000000c2000000cc200000ccc20000cccc2000ccfcc200ccfccc20ccccccc2
-- 004:0000000400000046000004660000466600046666004666660466666646666666
-- 005:4000000064000000640000006640004466404400666400006664000066640000
-- 017:2ccccccc02cccccc002ccccc0002cccc00002ccc000002cc00001c2c0001ccc2
-- 018:ccccccc2cccccc20ccccc200cccc2000ccc20000cc200000c2c100002ccc1000
-- 020:4666666604666666004666660004666600004666000004660000004600000004
-- 021:6664000066640000666400006640440066400044640000006400000040000000
-- 032:000000000000000000000000000000010000001c000001cc00001ccc0001cccc
-- 033:001ccccc01cccccc1ccccccccccccccccccccccccccccccccccccccccccccccc
-- 034:ccccc100cccccc10ccccccc1cccccccccccccccccccccccccccccccccccccccc
-- 035:00000000000000000000000010000000c1000000cc100000ccc10000cccc1000
-- 036:0000000400000049000004990000499900049999004999990499999949999999
-- 037:4000000094000000940000009940004499404400999400009994000099940000
-- 048:001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc
-- 049:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 050:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 051:ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100
-- 052:4999999904999999004999990004999900004999000004990000004900000004
-- 053:9994000099940000999400009940440099400044940000009400000040000000
-- 064:001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc
-- 065:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 066:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 067:ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100
-- 068:0000000400000041000004110000411100041111004111110411111141111111
-- 069:4000000014000000140000001140004411404400111400001114000011140000
-- 080:0001cccc00001ccc000001cc0000001c00000001000000000000000000000000
-- 081:cccccccccccccccccccccccccccccccccccccccc1ccccccc01cccccc001ccccc
-- 082:ccccccccccccccccccccccccccccccccccccccccccccccc1cccccc10ccccc100
-- 083:cccc1000ccc10000cc100000c100000010000000000000000000000000000000
-- 084:4111111104111111004111110004111100004111000004110000004100000004
-- 085:1114000011140000111400001140440011400044140000001400000040000000
-- 096:000000010000001c000001cc00001ccc0001cccc001ccccc01cccccc1ccccccc
-- 097:1001ccc2c1001c2ccc1002ccccc12cccccc2cccccc2cccccc2cccccc2ccccccc
-- 098:2ccc1001c2c1001ccc2001ccccc21ccccccc2cccccccc2cccccccc2cccccccc2
-- 099:10000000c1000000cc100000ccc10000cccc1000ccccc100cccccc10ccccccc1
-- 112:1ccccccc01cccccc001ccccc0001cccc00001ccc000001cc0000001c00000001
-- 113:2cccccccc2cccccccc2cccccccc2ccccccc12ccccc1002ccc100002c10000002
-- 114:ccccccc2cccccc2cccccc2cccccc2cccccc21ccccc2001ccc200001c20000001
-- 115:ccccccc1cccccc10ccccc100cccc1000ccc10000cc100000c100000010000000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

