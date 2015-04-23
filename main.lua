-- Project: GameDev-02- DisplayAnimate
-- Copyright 2012 Three Ring Ranch
-- http://MasteringCoronaSDK.com
--  Hide the status bar
display.setStatusBar(display.HiddenStatusBar)

centerX = display.contentWidth  *  .5  
centerY = display.contentHeight * .5musicIsPlaying = truesfxIsPlaying = true

-- pads table
local pads = {}
local idx = 0 
local frog
local frogJumpSpeed = 1000
audio.reserveChannels ( 1 )sndChanMusic = 1sndJump = audio.loadSound ( "audio/boing.mp3")sndMusic = audio.loadStream("audio/HappyPants.wav")-- not a local function playing any Sfx parametrizedfunction playSFX(audioHandle, opt)	-- to be sure is intialized even if there's no parameter passed	local options = opt or {}	local loopNum = options.loop or 0	local channel = options.channel or 0	local chanUsed = nil	if sfxIsPlaying then 		chanUsed = audio.play(audioHandle, { channel = channel, loops = loopNum})	end	return chanUsedendfunction playMusic()	if musicIsPlaying then		-- loops = -1 => forever		audio.play( sndMusic, {channel = sndChanMusic, loops=-1})		audio.setVolume ( .25 ,{ channel= sndChanMusic } )	endend	
local function frogTapped (event)
	print ("Croac!")
	transition.to( event.target, {rotation = 90, delta=true})
end

local function padTouched(event)
	local pad = event.target
	
	-- in the phase = ended
	if event.phase=="ended" then
			local angleBetween = math.ceil(math.atan2((pad.y -frog.y), (pad.x - frog.x))* 180 / math.pi) + 90
			frog.rotation=angleBetween
			transition.to (frog, {time = frogJumpSpeed, x=pad.x, y=pad.y, transition=easing.inOutQuad})			local function hopSound()				playSFX(sndJump)			end			timer.performWithDelay( frogJumpSpeed/5, hopSound)				
	end
end


local bg = display.newImageRect ( "images/bg_iPhone.png", 480,320)
bg.x =centerX
bg.y = centerY

local function hopDone(obj)
	-- lilipad object = lpobj
	local function killPad(lpobj)
		display.remove(lpobj)
	end
	
	transition.to ( pads [1] ,  { time = 600,  alpha=0 , xScale = .1 , yScale = .1 , rotation = 360, onComplete= killPad})	
end


--verticalValue, horizontalValue
for vVal = 1,4 do 
	for hVal= 1,6 do
		idx = idx + 1		
		local  pad = display.newImageRect("images/lilypad_green.png",64,64)
		--rotate  and scalethe lilypads , so they're not always the same (up or down by 10% size )
		local sizer = 1 + math.random(-1,1) /10 
		pad:rotate( math.random(0,359))
		pad: scale( sizer, sizer)		
		pad:addEventListener("touch",padTouched)
		
		-- horizontal value of the pad position first time 75 - 23, second time 150 -23, etc		
		pad.x = (hVal * 75) - 23 
		pad .y = (vVal * 70) 
		
		
		-- putting the pad in the table
		pads[idx] = pad
		
		-- adding a propertities to the table pads for referencing with a number each pad
		pads[idx].idx = idx
	end
end
frog = display.newImageRect("images/frog.png",64,95)
frog.x = 52
frog.y = 70
frog:addEventListener("tap", frogTapped)

local function  flyTouched(event)
		local obj= event.target

		if event.phase =="began" then
			-- focus on fly
			display.getCurrentStage ( ):setFocus(obj)
			obj.startMoveX = obj.x
			obj.startMoveY = obj.y
			
			elseif event.phase == "moved" then
				-- where is now - where it started
				obj.x = (event.x - event.xStart) + obj.startMoveX
				obj.y = (event.y - event.yStart) + obj.startMoveY
			
			elseif event.phase == "ended" or event.phase == "cancelled" then
			 --RELEASE FOCUS
				display.getCurrentStage ( ):setFocus(nil)
			
		end
		return true
end

local fly = display.newImageRect("images/fly.png", 32, 22)
fly.x = centerX
fly.y = 15
fly : addEventListener("touch",flyTouched)playMusic()