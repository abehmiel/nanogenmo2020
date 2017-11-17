-- hubcapp's (totally unrelated) xpos split timer script https://raw.githubusercontent.com/Hubcapp/smb1-timer-splits-xpos/master/smb1_timer_splits_xpos.lua was helpful in development

-- Initialize story file
file = io.open('story.txt','w')

objLookup = {[0x00] = "Green Koopa Troopa",
			 [0x01] = "Red Koopa Troopa",
			 [0x02] = "Buzzy beetle",
			 [0x03] = "Red Koopa Troopa",
			 [0x04] = "Green Koopa Troopa",
			 [0x05] = "Hammer brother",
			 [0x06] = "Goomba",
			 [0x07] = "Blooper",
			 [0x08] = "Bullet Bill",
			 [0x09] = "Green Koopa Paratroopa",
			 [0x0A] = "Grey CheepCheep",
			 [0x0B] = "Red CheepCheep",
			 [0x0C] = "Pobodoo",
			 [0x0D] = "Piranha Plant",
			 [0x0E] = "Green Jumping Paratroopa",
			 [0x10] = "Bowser's flame",
			 [0x11] = "Lakitu",
			 [0x12] = "Spiny",
			 [0x14] = "Flying CheepCheep",
			 [0x15] = "Bowser's Flame",
			 [0x16] = "fireworks",
			 [0x17] = "Bullet Bill",
			 [0x20] = "firebar",
			 [0x21] = "long firebar",
			 [0x24] = "static platform",
			 [0x25] = "static platform",
			 [0x26] = "vertical moving platform",
			 [0x27] = "elevator platform",
			 [0x28] = "horizontal moving platform",
			 [0x29] = "buckling platform",
			 [0x2A] = "horizontal moving platform",
			 [0x2B] = "elevator platform",
			 [0x2C] = "elevator platform",
			 [0x2D] = "Bowser",
			 [0x2F] = "vine ",
			 [0x30] = "flagpole",
			 [0x32] = "jump spring",
			 [0x33] = "Bullet Bill Cannon",
			 [0x34] = "Warp Zone",
			 [0x35] = "Toad",
			 [0x37] = "Goombas in a row",
			 [0x38] = "Goombas in a row",
			 [0x3A] = "skewed Goomba",
			 [0x3B] = "Koopa Troopas in a row",
			 [0x3C] = "Koopa Troopas in a row"
}

objArticleLookup = {[0x00] = "a ",
			 [0x01] = "a ",
			 [0x02] = "a ",
			 [0x03] = "a ",
			 [0x04] = "a ",
			 [0x05] = "a ",
			 [0x06] = "a ",
			 [0x07] = "a ",
			 [0x08] = "a ",
			 [0x09] = "a ",
			 [0x0A] = "a ",
			 [0x0B] = "a ",
			 [0x0C] = "a ",
			 [0x0D] = "a ",
			 [0x0E] = "a ",
			 [0x10] = "a ",
			 [0x11] = "a ",
			 [0x12] = "a ",
			 [0x14] = "a ",
			 [0x15] = "a ",
			 [0x16] = "",
			 [0x17] = "a ",
			 [0x20] = "a ",
			 [0x21] = "a ",
			 [0x24] = "a ",
			 [0x25] = "a ",
			 [0x26] = "a ",
			 [0x27] = "an ",
			 [0x28] = "a ",
			 [0x29] = "a ",
			 [0x2A] = "a ",
			 [0x2B] = "an ",
			 [0x2C] = "an ",
			 [0x2D] = "",
			 [0x2F] = "a ",
			 [0x30] = "a ",
			 [0x32] = "a ",
			 [0x33] = "a ",
			 [0x34] = "a ",
			 [0x35] = "",
			 [0x37] = "two ",
			 [0x38] = "three ",
			 [0x3A] = "a ",
			 [0x3B] = "two ",
			 [0x3C] = "three "
}

function getScore()
    return memory.readbyte(0x07DD)*1000000 +
           memory.readbyte(0x07DE)*100000 +
           memory.readbyte(0x07DF)*10000 +
           memory.readbyte(0x07E0)*1000 +
           memory.readbyte(0x07E1)*100 +
           memory.readbyte(0x07E2)*10           
end

function getObjects()
    if drawn ~= nil then
        oldDrawn = drawn
    end
    if objects ~= nil then
        oldObjects = objects
    end
    if views ~= nil then
        oldViews = views
    end
    if objStates ~= nil then
        oldObjStates = objStates
    end
    drawn = {memory.readbyte(0x000F), memory.readbyte(0x0010), 
             memory.readbyte(0x0011), memory.readbyte(0x0012), 
             memory.readbyte(0x0013)}
    objects = {memory.readbyte(0x0016), memory.readbyte(0x0017),
               memory.readbyte(0x0018), memory.readbyte(0x0019),
               memory.readbyte(0x001A)}
    views = {memory.readbyte(0x00B6), memory.readbyte(0x00B7),
               memory.readbyte(0x00B8), memory.readbyte(0x00B9),
               memory.readbyte(0x00BA)}
    objStates = {memory.readbyte(0x01E), memory.readbyte(0x01F),
                 memory.readbyte(0x020), memory.readbyte(0x021),
                 memory.readbyte(0x022)}
    for i, value in ipairs(objects) do
		if oldDrawn[i] == 0 and drawn[i] == 1 then
			text = objPhrase(value, text)
    	end
    end
    for i, value in ipairs(objStates) do
        if oldObjStates[i] < objStates[i] then
            text = objStatePhrase(value, i, text)
        end
    end       
end

function objPhrase(val, text)
	local phrase = "Mario sees "
	local target = objLookup[val]
    local article = objArticleLookup[val]
	if target ~= nil then
		phrase = phrase..article..target.." in the distance. "
    	text = safeAppend(text, phrase)
    	return text
	end
end

function objStatePhrase(val, i, text)
	local phrase = ""
	local target = objLookup[objects[i]]
    local article = objArticleLookup[objects[i]]
	if target ~= nil then
        if val == 0x04 or val == 0x20 or val == 0xC4 then
            phrase = phrase.."Mario stomps on "..article..target..". "
        elseif val == 0x22 then
            if brickon == 1 then
                phrase = phrase.."Mario's bash underneath a block defeats "..article..target..". "
            elseif starStatus == 0 and powerUpState >= 2 then
                phrase = phrase.."Mario's fireball defeats "..article..target..". "
            elseif starStatus == 0 then
                phrase = phrase.."The kicked shell defeats "..article..target..". "
            else
                phrase = phrase.."Mario's star power defeats "..article..target..". " 
            end
        elseif val == 0x23 then
            phrase = phrase.."Mario defeats "..article..target..", "
            if world ~= 8 then
                phrase = phrase.."which was disguised as Bowser! "
            else
                phrase = phrase.."and it seems like it was really him! "
            end
        elseif val == 64 and i == 3 then
            phrase = phrase.."Mario grabs the axe and the bridge falls! Bowser falls into the lava. "
        elseif val == 0x84 then
            phrase = phrase.."Mario kicks a "..target.." shell! "
        end

    	text = safeAppend(text, phrase)
    	return text
	end
end

function checkScore(sc, oldsc)
	if (sc ~= nil) and (oldsc ~= nil) and (sc > oldsc) then
		diff = sc - oldsc
    else
        diff = 0
    end
	return diff
end

function levelPhrase(lv, wo, text)
    local phrase = ""
    local fort = fortPhrase(lv, wo)
    if fort ~= nil then 
        phrase = phrase..fort.."\n\nChapter "..wo.."-"..lv.." \n \n"
    else
        phrase = "\n\nChapter "..wo.."-"..lv.." \n \n"
    end
    text = safeAppend(text, phrase)
    return text
end

function scorePhrase(sc, text)
    local phrase = "Mario added "..sc.." points to his score. "
    text = safeAppend(text, phrase)
    return text
end

function checkCoins(co, oldco)
	if (co ~= nil) and (oldco ~= nil) and ((co > oldco) or (oldco-co==99)) then
		if oldco-co ~= 99 then
            diff = co - oldco
        else
            diff = 1
        end
	else
        diff = 0
    end
	return diff
end

function coinsPhrase(text)
    local phrase = "Mario collected a coin. "
    text = safeAppend(text, phrase)
    return text
end

function getStarStatus()
    if memory.readbyte(0x079F) > 0 then
        return 1
    else 
        return 0
    end
end

function starPhrase(starStatus, oldStarStatus, text)
    local phrase = ""
    if starStatus == 1 and oldStarStatus == 0 then
        phrase = phrase.."Mario obtained a star and became invincible! "
    else
        phrase = phrase.."Mario's star power has dissipated.  "
    end
    text = safeAppend(text, phrase)
    return text
end

function viewPhrase(playerView, text)
    local phrase = ""
    if playerView == 5 then
        phrase = phrase.."Mario has fallen into a pit. "
    end
    text = safeAppend(text, phrase)
    return text
end

function brickPhrase(text)
    local phrase = "Mario hits a brick with his head"
    if powerUpState > 1 then
        phrase = phrase.." and destroys it! "
    else
        phrase = phrase..". "
    end
    text = safeAppend(text, phrase)
    return text
end

function timePhrase(curtime, text)
    local phrase = "Mario glanced at his watch and realized that there is now "..curtime..
                   " units of time remaining in this stage. "
    text = safeAppend(text, phrase)
    return text
end

function safeAppend(text, phr)
    if text ~= nil and state ~= 0 then
        text = text..phr
    elseif state ~= 0 then 
        text = phr
    end
    return text
end

function floatPhrase(floatState, spriteState, text)
    local phrase = ""
    if floatState == 0x00 then
        phrase = phrase.."Mario lands on solid ground. "
    elseif floatState == 0x01 and spriteState ~= 0x0B then
        phrase = phrase.."Mario jumps! "
    elseif floatState == 0x02 then
        phrase = phrase.."Mario falls off an edge. "
    elseif floatState == 0x03 then
        phrase = phrase.."Mario slides down the flagpole. "
    end
    text = safeAppend(text, phrase)
    return text
end

function skidPhrase(text)
--    local phrase = "Mario abruptly changes his direction and starts skidding. "
--    text = safeAppend(text, phrase)
--    return text
end

function spritePhrase(spriteState, oldSpriteState, text)
    local phrase = ""
    if spriteState == 0x03 then
        phrase = phrase.."Mario ducks down a pipe. "
    elseif spriteState == 0x0B then 
        phrase = phrase.."Mario shrugs and slinks away in defeat. "
    elseif spriteState == 0x06 and lives ~= 1 then
        phrase = phrase.."Mario stands up, brushes off his overalls, and gets ready for another go. "
    elseif spriteState == 0x01 then
        phrase = phrase.."Mario climbs a vine. "
    elseif spriteState == 0x07 then
        moretext = levelPalettePhrase(thisPalette)
        phrase = phrase.."Mario enters a new area. "..moretext
    elseif spriteState == 0x02 then
        phrase = phrase.."Mario walks into a pipe. "
    end
    text = safeAppend(text, phrase)
    return text
end

function levelPalettePhrase(pal)
    local moretext = ""
    if pal == 0x01 and world ~= 3 and world ~= 5 and world ~= 6 and world ~= 7 then
        moretext = moretext.."It's a sunny day in the Mushroom Kingdom. "
    elseif pal == 0x00 then
        moretext = moretext.."Mario finds himself underwater! "
    elseif pal == 0x01 and (world == 5 or world == 7)  then
        moretext = moretext.."It's a freezing cold day in the Mushroom Kingdom. "
    elseif pal == 0x01 and (world == 3 or world == 6)  then
        moretext = moretext.."It's night-time in the Mushroom Kingdom. "
    elseif pal == 0x02 then
        moretext = moretext.."Mario finds himself underground. "
    elseif pal == 0x03 then
        moretext = moretext.."Mario is inside Bowser's castle. "
    end 
    return moretext 
end


function duckPhrase(duckState, oldDuckState, text)
    local phrase=""
    if duckState == 0x04 and oldDuckState == 0x00 and spriteState ~= 0x03 then
        phrase = phrase.."Mario ducks down. "
    elseif spriteState ~= 0x03 then --if duckstate == 0x00 and oldDuckState == 0x04 then
        phrase = phrase.."Mario stands upright. "
    end
    text = safeAppend(text, phrase)
    return text
end

function seePowerUpPhrase(pwr, text)
    local phrase = "Mario hits a block and a "
    if pwr == 0 then
        target = "super mushroom"
    elseif pwr == 1 then
        target = "fire flower"
    elseif pwr == 2 then
        target = "star"
    elseif pwr == 3 then
        target = "1-Up"
    end
    phrase = phrase..target.." comes out! "
    text = safeAppend(text, phrase)
    return text
end 

function runPhrase(vel, text)
    local phrase = ""
    if vel == 2 then
        spd = "running. "
    elseif vel == 4 then
        spd = "walking. "
    elseif vel == 7 then
        spd = "to slow down. "
    end
    if spd ~= nil then
        phrase = phrase.."Mario begins "..spd
        text = safeAppend(text, phrase)
        return text
    end
end

function fortPhrase(lv, wo)
    local phrase = ""
    if lv <= 3 and lv ~= 1 then
        phrase = phrase.."Mario enters the fort. "
    elseif lv == 4 then
        phrase = phrase.."Mario enters the castle. "
    elseif (wo ~= 1 and lv == 1) then
        if world < 8 then
            phrase = phrase..'Toad says, "Thank you Mario! But our princess is in another castle!" '
            phrase = phrase.."Mario leaves the castle. "
        else
            phrase = phrase.."It's Princess Peach! Mario has finally saved her from Bowser. She says, \"Thank you Mario! Your quest is over. Push button B to select a world.\" Mario leaves the castle. "
        end
    end
    text = safeAppend(text, phrase)
    return text
end

function powerUpPhrase(pwr, oldpwr, text)
    local phrase = ""
    if pwr == 0 and (oldpwr == 1)  then
        phrase = phrase.."Mario lost his super mushroom power. "
    elseif pwr == 0 and (oldpwr == 2)  then
        phrase = phrase.."Mario lost his fire flower power. "
    elseif pwr == 1 and (oldpwr == 0)  then
        phrase = phrase.."Mario obtained a super mushroom and grew big! "
    elseif pwr == 2 and (oldpwr == 1)  then
        phrase = phrase.."Mario obtained a fire flower and changed his overalls! "
    end
    text = safeAppend(text, phrase)
    return text
end

function upPhrase(text)
    text = safeAppend(text, "Mario earns an extra life! ")
    return text
end

function fireballPhrase(fireballCount, oldFireballCount, text)
    local phrase = ""
    if fireballCount > oldFireballCount then
        phrase = phrase.."Mario shoots a fireball. "
    end
    text = safeAppend(text, phrase)
    return text
end

function frameRuleUpdate()

    -- Obtain information about the game state that doesn't change often
    state = memory.readbyte(0x0770); --0 = title screen, 1 = playing the game, 2 = rescued toad/peach, 3 = game over

    gameTimer = memory.readbyte(0x07F8)*100 + memory.readbyte(0x07F9)*10 + memory.readbyte(0x07FA);

    if oldLevel ~= level then
        text = levelPhrase(level, world, text)
    end
    oldLevel = level

    if level == nil then
        oldLevel = nil
    end
    
    coinsBuffer = 0
    scoreBuffer = 0
    world = memory.readbyte(0x075F)+1
    level = memory.readbyte(0x0760)+1
    powerUpState = memory.readbyte(0x0756)
    powerUpDrawn = memory.readbyte(0x0014)
    powerUpType = memory.readbyte(0x0039)
    isPreLevel = memory.readbyte(0x0757)


    if (level > 2 and (world == 1 or world == 2 or world == 4 or world == 7)) then --the cute animation where you go into a pipe before starting the level counts as a level internally
        level = level - 1; --for worlds with that cutscene, we have to subtract off that cutscene level
    end;
    lives = memory.readbyte(0x075A)+1;
    if (lives == oldLives + 1) and oldLives ~= nil and oldLives ~= 256 and lives ~= 256 then
        text = upPhrase(text)
    end
    oldLives = lives

    if powerUpState ~= oldPowerUpState and oldPowerUpState ~= nil then
        text = powerUpPhrase(powerUpState, oldPowerUpState, text)
    end
    oldPowerUpState = powerUpState

    if runningScore > 0 and (lastRunningScore-runningScore) == 0 then
        text = scorePhrase(runningScore, text)
        runningScore = 0
    end
    lastRunningScore = runningScore

    if (gameTimer % 20) == 0 and oldGameTimer ~= nil and oldGameTimer > gameTimer 
        and gameTimer ~= 0 and (oldGameTimer - gameTimer) < 2 then 
        text = timePhrase(gameTimer, text)
    end
    oldGameTimer = gameTimer

    if powerUpDrawn == 1 and oldPowerUpDrawn == 0 and spriteState ~= 0x07 then
        text = seePowerUpPhrase(powerUpType, text)
    end
    oldPowerUpDrawn = powerUpDrawn
    --oldPowerUpState = powerUpState


    --debug
    --emu.message(objStates[1]..objStates[2]..objStates[3]..objStates[4]..objStates[5])
    --emu.message(thisPalette)

end

--Initialize stuff
runningScore = 0
lastRunningScore = 0
powerUpState = 0
world = nil
level = nil
oldLives = 3
floatState = 0x00
oldDrawn = {0, 0, 0, 0, 0}
oldviews = {0, 0, 0, 0, 0}
oldObjects = {0, 0, 0, 0, 0}
oldObjStates = {0, 0, 0, 0, 0}
oldBrickState1 = 0
oldBrickState2 = 0
brickon = 0

--Infinite loop to take control over frame advancing.
while true do

	--Initialize the text to write this frame
	text = nil

    frameRule = memory.readbyte(0x077F) --runs from 20 to 0
    --Obtain information about the present game state 
    if frameRule == 0 then
        frameRuleUpdate()
    end

    --present player related variables, checked every frame
    coins = memory.readbyte(0x07ED)*10 + memory.readbyte(0x07EE)
    --xpos = memory.readbyte(0x03AD); --number of pixels between mario (or luigi...) and the left side of the screen
    score = getScore()
    floatState = memory.readbyte(0x001D) --0x00: on solid, 0x01: airborne jump
                                         --0x02: airborne fall, 0x03: sliding down flagpole
    blockColl = memory.readbyte(0x0490) --0xFF: off, 0xFE: collision
    enemyColl = memory.readbyte(0x0491)
    fireballCount = memory.readbyte(0x06CE)
    spriteState = memory.readbyte(0x000E) 
    runVelocity = memory.readbyte(0x070C) --max: 0x30
    duckState = memory.readbyte(0x0714)
    walkAnimation = memory.readbyte(0x0702) --0x30 is skidding
    starStatus = getStarStatus()
    playerView = memory.readbyte(0x00B5)
    brickState1 = memory.readbyte(0x008F)
    brickState2 = memory.readbyte(0x0090)
    thisPalette = memory.readbyte(0x074E)

    --Check bricks
    if (brickState1 ~= oldBrickState1 or brickState2 ~= oldBrickState2) and 
        (brickState1 > oldBrickState1 or brickState2 > oldBrickState2) then
        text = brickPhrase(text)
        brickon = 1
    end
    oldBrickState1 = brickState1
    oldBrickState2 = brickState2

    --Enemies/Objects
    getObjects() --drawn, objects, oldDrawn, oldObjects

    --Check player state
    if (spriteState ~= oldSpriteState) and (oldSpriteState ~= nil) then
        text = spritePhrase(spriteState, oldSpriteState, text)
    end
    if (duckState ~= oldDuckState) and (oldDuckState ~= nil) then
        text = duckPhrase(duckState, oldDuckState, text)
    end
    oldSpriteState = spriteState
    oldDuckState = duckState

    --Check float state
    if (floatState ~= oldFloatState) and (oldFloatState ~= nil) then
        text = floatPhrase(floatState, spriteState, text)
    end 
    oldFloatState = floatState

    --Check coins
    coinsDiff = checkCoins(coins, oldCoins)
    if coinsDiff ~= 0 then
        text = coinsPhrase(text)
    end
    oldCoins = coins

    --Check score
	scoreDiff = checkScore(score, oldScore)
    if scoreDiff ~= 0 and runningScore >= 0 then
        runningScore = scoreDiff + runningScore
        --text = scorePhrase(scoreDiff, text)
    end
    oldScore = score

    if (playerView ~= oldPlayerView) and (oldPlayerView ~= nil) then
        text = viewPhrase(playerView, text)
    end 
    oldPlayerView = playerView

    if fireballCount ~= oldFireballCount and oldFireballCount ~= nil then
        text = fireballPhrase(fireballCount, oldFireballCount, text)
    end
    oldFireballCount = fireballCount

    --Check velocity
    if ((runVelocity ~= oldRunVelocity) and (oldRunVelocity ~= nil)) then
        text = runPhrase(runVelocity, text)
    end
    oldRunVelocity = runVelocity

    --Check skidding
    if walkAnimation ~= oldWalkAnimation and oldWalkAnimation ~= nil and 
       (walkAnimation == 0x30 or 0xA0) then
        text = skidPhrase(text)
    end
    oldWalkAnimation = walkAnimation

    --Check Star Status
    if starStatus ~= oldStarStatus and oldStarStatus ~= nil then
        text = starPhrase(starStatus, oldStarStatus, text)
    end
    oldStarStatus = starStatus

	--Write text
    if text ~= nil then
        emu.message(text)
        file:write(text)
        text = nil
    end 

    brickon = 0
    emu.frameadvance() -- This essentially tells FCEUX to keep running.
end

