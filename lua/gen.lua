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


function checkScore(sc, oldsc)
	if (sc ~= nil) and (oldsc ~= nil) and (sc > oldsc) then
		diff = sc - oldsc
	else
        diff = 0
    end
	return diff
end

function scorePhrase(sc, text)
    local phrase = "Mario added "..sc.." points to his score. "
    if text ~= nil then
        text = text..phrase
    else 
        text = phrase
    end
    return text
end

function frameRuleUpdate()

    -- Obtain information about the game state that doesn't change often
    state = memory.readbyte(0x0770); --0 = title screen, 1 = playing the game, 2 = rescued toad/peach, 3 = game over
    gameTimer = memory.readbyte(0x07F8)*100 + memory.readbyte(0x07F9)*10 + memory.readbyte(0x07FA);
    world = memory.readbyte(0x075F)+1;
    level = memory.readbyte(0x0760)+1;
    if (level > 2 and (world == 1 or world == 2 or world == 4 or world == 7)) then --the cute animation where you go into a pipe before starting the level counts as a level internally
        level = level - 1; --for worlds with that cutscene, we have to subtract off that cutscene level
    end;
    lives = memory.readbyte(0x075A)+1;
end

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
    
	scoreDiff = checkScore(score, oldScore)
    if scoreDiff ~= 0 then
        text = scorePhrase(scoreDiff, text)
    end
    oldScore = score

    if state == 3 then --GAME OVER, also detectable if lives == 256
        gameOver = true;
    end;

	--Write text
    if text ~= nil then
        emu.message(text)
        file:write(text)
        text = nil
    end 

    emu.frameadvance() -- This essentially tells FCEUX to keep running.
end

