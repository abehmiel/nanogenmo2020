-- hubcapp's (totally unrelated) xpos split timer script https://raw.githubusercontent.com/Hubcapp/smb1-timer-splits-xpos/master/smb1_timer_splits_xpos.lua was helpful in development

-- Initialize story file
file = io.open('story.txt','w')

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
    drawn = {memory.readbyte(0x000F), memory.readbyte(0x0010), 
             memory.readbyte(0x0011), memory.readbyte(0x0012), 
             memory.readbyte(0x0013)}
    objects = {memory.readbyte(0x0016), memory.readbyte(0x0017),
               memory.readbyte(0x0018), memory.readbyte(0x0019),
               memory.readbyte(0x001A)}
    views = {memory.readbyte(0x00B6), memory.readbyte(0x00B7),
               memory.readbyte(0x00B8), memory.readbyte(0x00B9),
               memory.readbyte(0x00BA)}
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
    local phrase = "\nChapter "..wo.."-"..lv.." \n \n"
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

function timePhrase(curtime, text)
    local phrase = "Mario glanced at his watch and realized that there is now "..curtime..
                   " units of time remaining in this stage. "
    text = safeAppend(text, phrase)
    return text
end

function safeAppend(text, phr)
    if text ~= nil then
        text = text..phr
    else 
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
    elseif spriteState == 0x06 and gameOver ~= true then
        phrase = phrase.."Mario stands up, brushes off his overalls, and gets ready for another go. "
    elseif spriteState == 0x01 then
        phrase = phrase.."Mario climbs a vine. "
    elseif spriteState == 0x07 then
        phrase = phrase.."Mario enters a new area. "
    elseif spriteState == 0x02 then
        phrase = phrase.."Mario walks into a pipe. "
    end
    text = safeAppend(text, phrase)
    return text
end

function duckPhrase(duckState, oldDuckState, text)
    local phrase=""
    if duckState == 0x04 and oldDuckState == 0x00 and spriteState ~= 0x03 then
        phrase = phrase.."Mario ducks down. "
    else --if duckstate == 0x00 and oldDuckState == 0x04 then
        phrase = phrase.."Mario stands upright. "
    end
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

    if (level > 2 and (world == 1 or world == 2 or world == 4 or world == 7)) then --the cute animation where you go into a pipe before starting the level counts as a level internally
        level = level - 1; --for worlds with that cutscene, we have to subtract off that cutscene level
    end;
    lives = memory.readbyte(0x075A)+1;

    if powerUpState ~= oldPowerUpState and oldPowerUpState ~= nil then
        text = powerUpPhrase(powerUpState, oldPowerUpState, text)
    end
    oldPowerUpState = powerUpState

    if runningScore > 0 and (lastRunningScore-runningScore) == 0 then
        text = scorePhrase(runningScore, text)
        runningScore = 0
    end
    lastRunningScore = runningScore

    if (gameTimer % 20) == 0 and oldGameTimer ~= nil and oldGameTimer ~= gameTimer 
        and gameTimer ~= 0 and (oldGameTimer - gameTimer) < 2 then 
        text = timePhrase(gameTimer, text)
    end
    oldGameTimer = gameTimer
end

--Initialize stuff
runningScore = 0
lastRunningScore = 0
world = 0
level = 0

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
    isPreLevel = memory.readbyte(0x075E)
    starStatus = getStarStatus()
    playerView = memory.readbyte(0x00B5)

    --Enemies/Objects
    getObjects() --drawn, objects, oldDrawn, oldObjects

    if state == 3 then --GAME OVER, also detectable if lives == 256
        gameOver = true
    end

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

    emu.frameadvance() -- This essentially tells FCEUX to keep running.
end

