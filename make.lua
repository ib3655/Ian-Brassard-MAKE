--[[
	Ian Brassard <ib3655@bard.edu>
	23 May 2022
	CMSC 336 Games Systems
	Make assignment
	I worked alone on this, but I consulted Stack Overflow for my map function.
	The appropriate thread is linked there.
--]]

-- license: GNU GPL 3.0
trace("Licensed under GPLv3")

-- constants
WIDTH = 240
HEIGHT = 136
MAX_ENEMIES = 100
BLACK = 0
PURPLE = 1
RED = 2
GREEN = 6
TURQOISE = 7
DARK_BLUE = 8
BLUE = 9
LIGHT_BLUE = 10
WHITE = 12
GRAY = 14
DARK_GRAY = 15

-- class Player
Player = {x = 0, y = 8, sprite_id = 256, hp = 50, pwr = 1, score = 0}

function Player:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function Player:add_score()
	self.score = self.score + 1
end

function Player:display()
	spr(self.sprite_id,self.x,self.y,BLACK,2,0,0,4,8)
	rect((self.x + 32) - math.ceil(self.hp/2), self.y, math.ceil(self.hp/2), 3, RED)
	rect(self.x + 32, self.y, math.ceil(self.hp/2), 3, RED)
end

function Player:get_score()
	return self.score
end

function Player:get_pwr()
	return self.pwr
end

function Player:heal(dmg)
	self.hp = self.hp + dmg
end

function Player:hurt(dmg)
	self.hp = self.hp - dmg
end

function Player:laser(xpos, ypos)
	origin = {x = self.x + 37, y = self.y + 12}
	line(origin.x, origin.y, xpos, ypos, RED)
	line(origin.x, origin.y, xpos, ypos-1, RED)
	line(origin.x, origin.y, xpos, ypos+1, RED)
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
	rect((self.x + 7) - math.ceil(self.hp/2), self.y, math.ceil(self.hp/2), 3, RED)
	rect(self.x + 7, self.y, math.ceil(self.hp/2), 3, RED)
end

function Enemy:hurt(dmg)
	if self.hp > 0 then self.hp = self.hp - dmg end
end

function Enemy:die()
	self.dead = true
	total_dead = total_dead + 1
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

-- class Health Enemy extends Enemy
HealthEnemy = Enemy:new()

function HealthEnemy:display()
	spr(self.spr_id + 32, self.x, self.y, 0, 1, 0, 0, 2, 2)
	rect((self.x + 7) - math.ceil(self.hp/2), self.y, math.ceil(self.hp/2), 3, RED)
	rect(self.x + 7, self.y, math.ceil(self.hp/2), 3, RED)
end
-- Health Enemy end

-- class Super Enemy extends Enemy
SuperEnemy = Enemy:new()

function SuperEnemy:display()
	spr(self.spr_id + 64, self.x, self.y, 0, 1, 0, 0, 2, 2)
	rect((self.x + 7) - math.ceil(self.hp/2), self.y, math.ceil(self.hp/2), 3, RED)
	rect(self.x + 7, self.y, math.ceil(self.hp/2), 3, RED)
end
-- Super Enemy end

function dist(x1, y1, x2, y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function init_level(list, length, level)
	local list = list or {}
	local length = length or 10
	local level = level or 1
	for i = 1, length do
		list[i] = spawn_enemy(level)
	end
	set_state(level)
	total_dead = 0
	total_enemies = #list
	timer = nil
end

function map(n,a,b,x,y)  -- adapted from https://stackoverflow.com/questions/5731863/mapping-a-numeric-range-onto-another
	return x + ((y - x)/(b - a)) * (n - a)
end

function set_state(n)
	last_state = game_state
	game_state = n
end

function spawn_enemy(lvl)
	total_enemies = total_enemies + 1
	local selection = math.random()
	if lvl < 3 then
		if selection < 0.1 then
			return HealthEnemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), spd = map(math.random(), 0, 1, 0.5, 1.5)}
		else 
			return Enemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), spd = map(math.random(), 0, 1, 0.5, 1.5)}
		end
	elseif lvl < 9 then
		if selection < 0.01 then
			return SuperEnemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), hp = 100, spd = map(math.random(), 0, 1, 0.2, 0.7)}
		elseif selection >= 0.8 then
			return HealthEnemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), spd = map(math.random(), 0, 1, 0.5, 1.5)}
		else
			return Enemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), spd = map(math.random(), 0, 1, 0.5, 1.5)}
		end
	else
		if selection < 0.05 then
			return SuperEnemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), hp = 100, spd = map(math.random(), 0, 1, 0.2, 0.7)}
		elseif selection >= 0.8 then
			return HealthEnemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), spd = map(math.random(), 0, 1, 0.5, 1.5)}
		else
			return Enemy:new{x = math.random(WIDTH + 10, WIDTH*1.5), y = math.random(8, HEIGHT - 16), spd = map(math.random(), 0, 1, 0.5, 1.5)}
		end
	end
end

function update_enemies()
	for i = 1, #enemies do
		if enemies[i] then
			enemies[i]:update()
			if left and enemies[i]:isAt(mx, my) then
				enemies[i]:hurt(player:get_pwr())
			end
			if enemies[i].x <= player.x + 54 then
				player:hurt(enemies[i].hp)
				enemies[i]:die()
				if total_enemies < MAX_ENEMIES then
					enemies[i] = spawn_enemy(game_state)
				else
					table.remove(enemies, i)
				end
			end
			if enemies[i] and enemies[i].hp <= 0 then
				enemies[i]:die()
				player:add_score()
				if getmetatable(enemies[i]) == HealthEnemy and player.hp <= 50 then
					player:heal(10)
				end
				if total_enemies < MAX_ENEMIES then
					enemies[i] = spawn_enemy(game_state)
				else
					table.remove(enemies, i)
				end
			end
		end
	end
end

-- game states
function state_one()								-- states 1 - 10 are levels 1 - 10
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(LIGHT_BLUE)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, BLACK)
	print("level: "..game_state, player.x + 64, 10, BLACK)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_two()
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(BLUE)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, BLACK)
	print("level: "..game_state, player.x + 64, 10, BLACK)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_three()
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(DARK_BLUE)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, WHITE)
	print("level: "..game_state, player.x + 64, 10, WHITE)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_four()
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(PURPLE)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, WHITE)
	print("level: "..game_state, player.x + 64, 10, WHITE)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_five()
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(GRAY)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, BLACK)
	print("level: "..game_state, player.x + 64, 10, BLACK)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_six() 
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(GREEN)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, BLACK)
	print("level: "..game_state, player.x + 64, 10, BLACK)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_seven()
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(TURQOISE)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, BLACK)
	print("level: "..game_state, player.x + 64, 10, BLACK)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_eight()
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(GRAY)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, BLACK)
	print("level: "..game_state, player.x + 64, 10, BLACK)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_nine()
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(DARK_GRAY)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, WHITE)
	print("level: "..game_state, player.x + 64, 10, WHITE)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_ten()
	if player.hp <= 0 then
		init_level(enemies, 0, 12)
	end
	cls(BLACK)
	rem = MAX_ENEMIES - total_dead
	update_enemies()
	player:display()
	if left then player:laser(mx, my) end
	print("enemies remaining: "..rem, WIDTH/2, 10, WHITE)
	print("level: "..game_state, player.x + 64, 10, WHITE)
	if rem == 0 and not timer then
		timer = time()
	end
	if timer and time() - timer >= 2000 then
		init_level(enemies,10,game_state + 1)
	end
end

function state_eleven()								-- state 11: victory screen
	cls(LIGHT_BLUE)
	local mid_y = HEIGHT/2
	local str0 = "Congratulations!"
	local str1 = "You won!"
	local str2 = "Score: "..player:get_score()
	local pos0 = print(str0, 0, -100, BLACK, false, 2)
	local pos1 = print(str1, 0, -100, BLACK, false, 2)
	local pos2 = print(str2, 0, -100, BLACK, false, 2)
	print(str0, (WIDTH/2)-(pos0/2), mid_y - 11, BLACK, false, 2)
	print(str1,(WIDTH/2)-(pos1/2), mid_y, BLACK, false, 2)
	print(str2,(WIDTH/2)-(pos2/2), mid_y + 21, BLACK, false, 2)
end

function state_twelve()								-- state 12: defeat screen
	cls(BLUE)
	local str0 = ""
	if last_state > 7 then
		str0 = "Almost there!"
	else
		str0 = "Tough luck!"
	end
	local str1 = "You died, but keep trying!"
	local str2 = "Your enemies must be destroyed!"
	local str3 = "Space to restart."
	local pos0 = print(str0, 0, -100, BLACK, false, 2)
	local pos1 = print(str1, 0, -100, BLACK, false, 1)
	local pos2 = print(str2, 0, -100, BLACK, false, 1)
	local pos3 = print(str3, 0, -100, BLACK, false, 1)
	print(str0, (WIDTH/2)-(pos0/2), 15, BLACK, false, 2)
	print(str1, (WIDTH/2)-(pos1/2), HEIGHT/2 - 7, BLACK, false, 1)
	print(str2, (WIDTH/2)-(pos2/2), HEIGHT/2, BLACK, false, 1)
	print(str3, (WIDTH/2)-(pos3/2), 107, BLACK, false, 1)
	if keyp(48) then reset() end
end

function state_thirteen()							-- state 13: title screen
	cls(BLUE)
	local str0 = "The Imposition"
	local str1 = "Of Angles"
	local str2 = "Z for instructions."
	local str3 = "Space to begin."
	local pos0 = print(str0, 0, -100, BLACK, false, 2)
	local pos1 = print(str1, 0, -100, BLACK, false, 2)
	local pos2 = print(str2, 0, -100, BLACK, false, 1)
	local pos3 = print(str3, 0, -100, BLACK, false, 1)
	print(str0, (WIDTH/2)-(pos0/2), 15, BLACK, false, 2)
	print(str1, (WIDTH/2)-(pos1/2), 27, BLACK, false, 2)
	print(str2, (WIDTH/2)-(pos2/2), HEIGHT/2, BLACK, false, 1)
	print(str3, (WIDTH/2)-(pos3/2), HEIGHT/2 + 10, BLACK, false, 1)
	if keyp(48) then
		init_level(enemies, 10, 1)
	elseif keyp(26) then
		init_level(enemies, 0, 14)
	end
end

function state_fourteen()							-- state 14: instructions screen
	cls(BLUE)
	local str0 = "Instructions"
	local str1 = "Hold left-click to fire laser at enemies."
	local str2 = "If enemies hit you, they will hurt you"
	local str3 = "equal to their current health."
	local str4 = "Blue enemies are the most basic"
	local str5 = "Green enemies heal you when destroyed"
	local str6 = "Purple enemies are strong but slow"
	local str7 = "Space to begin."
	local pos0 = print(str0, 0, -100, BLACK, false, 2)
	print(str0, (WIDTH/2)-(pos0/2), 5, BLACK, false, 2)
	print(str1, 10, 21, BLACK, false, 1)
	print(str2, 10, 27, BLACK, false, 1)
	print(str3, 10, 33, BLACK, false, 1)
	spr(260, 10, 44, BLACK, 1, 1, 0, 2, 2)
	print(str4, 28, 49, BLACK, false, 1)
	spr(292, 10, 60, BLACK, 1, 1, 0, 2, 2)
	print(str5, 28, 65, BLACK, false, 1)
	spr(324, 10, 76, BLACK, 1, 1, 0, 2, 2)
	print(str6, 28, 81, BLACK, false, 1)
	print(str7, 10, 107, BLACK, false, 1)
	if keyp(48) then init_level(enemies, 10, 1) end
end

-- initialization
player = Player:new()
enemies = {}
total_enemies = 0
total_dead = 0
states = {
	state_one,			-- one thru ten are gameplay levels
	state_two,
	state_three,
	state_four,
	state_five,
	state_six,
	state_seven,
	state_eight,
	state_nine,
	state_ten,
	state_eleven,		-- victory screen
	state_twelve,		-- defeat screen
	state_thirteen,		-- title screen
	state_fourteen		-- instructions screen
}
game_state = 13
last_state = 13

-- abstract each game state to its own function, then dump them in an array (at index game_state), call into that array during run time
function TIC()
	mx,my,left = mouse()
	states[game_state]()
end

-- <SPRITES>
-- 001:000000020000002c000002cc00002ccc0002cccc002ccccc02cccccc2ccccccc
-- 002:20000000c2000000cc200000ccc20000cccc2000ccfcc200ccfccc20ccccccc2
-- 004:0000000400000049000004990000499900049999004999990499999949999999
-- 005:4000000094000000940000009940004499404400999400009994000099940000
-- 017:2ccccccc02cccccc002ccccc0002cccc00002ccc000002cc00001c2c0001ccc2
-- 018:ccccccc2cccccc20ccccc200cccc2000ccc20000cc200000c2c100002ccc1000
-- 020:4999999904999999004999990004999900004999000004990000004900000004
-- 021:9994000099940000999400009940440099400044940000009400000040000000
-- 032:000000000000000000000000000000010000001c000001cc00001ccc0001cccc
-- 033:001ccccc01cccccc1ccccccccccccccccccccccccccccccccccccccccccccccc
-- 034:ccccc100cccccc10ccccccc1cccccccccccccccccccccccccccccccccccccccc
-- 035:00000000000000000000000010000000c1000000cc100000ccc10000cccc1000
-- 036:0000000400000046000004660000466600046666004666660466666646666666
-- 037:4000000064000000640000006640004466404400666400006664000066640000
-- 048:001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc001ccccc
-- 049:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 050:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 051:ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100ccccc100
-- 052:4666666604666666004666660004666600004666000004660000004600000004
-- 053:6664000066640000666400006640440066400044640000006400000040000000
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

