stream = {}
local locked = svgCreate(1024, 1024, [[
<svg fill="white" height="800px" width="800px" version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" 
	 viewBox="0 0 330 330" xml:space="preserve">
<g id="XMLID_509_">
	<path id="XMLID_510_" d="M65,330h200c8.284,0,15-6.716,15-15V145c0-8.284-6.716-15-15-15h-15V85c0-46.869-38.131-85-85-85
		S80,38.131,80,85v45H65c-8.284,0-15,6.716-15,15v170C50,323.284,56.716,330,65,330z M180,234.986V255c0,8.284-6.716,15-15,15
		s-15-6.716-15-15v-20.014c-6.068-4.565-10-11.824-10-19.986c0-13.785,11.215-25,25-25s25,11.215,25,25
		C190,223.162,186.068,230.421,180,234.986z M110,85c0-30.327,24.673-55,55-55s55,24.673,55,55v45H110V85z"/>
</g>
</svg>]])
local clickPrompt = {}

function getElementsCount(table)
	local counter = 0
	for i,v in pairs(table) do
		counter = counter+1
	end
	return counter
end

function onClientElementStreamInPrompt()
	if getElementType(source) == "object" and not stream[source] and proximityPrompts[source] then
		stream[source] = proximityPrompts[source]
		stream[source].renderTarget = dxCreateRenderTarget(1024, 1024, true)
		if getElementsCount(stream) == 1 and not isEventHandlerAdded("onClientPreRender", root, onClientPreRenderPrompt) then
			addEventHandler("onClientKey", root, onClientKeyPrompt)
			addEventHandler("onClientPreRender", root, onClientPreRenderPrompt)
		end
	end
end
addEventHandler("onClientElementStreamIn", resourceRoot, onClientElementStreamInPrompt)

function onClientElementStreamOutPrompt()
	if getElementType(source) == "object" and stream[source] then
		if isElement(stream[source].renderTarget) then
			destroyElement(stream[source].renderTarget)
			stream[source].renderTarget = nil
		end
		stream[source] = nil
		if getElementsCount(stream) == 0 and isEventHandlerAdded("onClientPreRender", root, onClientPreRenderPrompt) then
			removeEventHandler("onClientKey", root, onClientKeyPrompt)
			removeEventHandler("onClientPreRender", root, onClientPreRenderPrompt)
		end
	end
end
addEventHandler("onClientElementStreamOut", resourceRoot, onClientElementStreamOutPrompt)

function onClientResourceStartPrompt()
	for i,v in pairs(getElementsByType("object", resourceRoot) ) do
		if proximityPrompts[v] then
			stream[v] = proximityPrompts[v]
			stream[v].renderTarget = dxCreateRenderTarget(1024, 1024, true)
		end
		if getElementsCount(stream) == 1 and not isEventHandlerAdded("onClientPreRender", root, onClientPreRenderPrompt) then
			addEventHandler("onClientKey", root, onClientKeyPrompt)
			addEventHandler("onClientPreRender", root, onClientPreRenderPrompt)
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStartPrompt) 

function getPositionInfrontOfElement(element, meters)
    if (not element or not isElement(element)) then return false end
    local meters = (type(meters) == "number" and meters) or 1
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))
    return posX, posY, posZ
end

function calculatePercentage(value, min, max)
    if value < min then
        value = min
    elseif value > max then
        value = max
    end
    local range = max - min
    local adjustedValue = value - min
    local percentage = adjustedValue / range
    return percentage
end

function dxDrawBorderedRectangleProgress(x, y, width, height, color1, border, postGUI, progress)
    if progress > 0 then
        local _progress = calculatePercentage(progress, 0, 0.25)
        dxDrawLine ( x, y, x+width*_progress, y, color1, border, postGUI)
    end
    if progress > 0.25 then
        local _progress = calculatePercentage(progress, 0.25, 0.5)
        dxDrawLine ( x+width, y, x+width, y+height*(_progress), color1, border, postGUI)
    end
    if progress > 0.5 then
        local _progress = calculatePercentage(progress, 0.5, 0.75)
        dxDrawLine(x+width, y+height, (x+width)-width*_progress, y+height, color1, border, postGUI)
    end
    if progress > 0.75 then
        local _progress = calculatePercentage(progress, 0.75, 1.0)
        dxDrawLine(x, y+height, x, (y+height)-height*_progress, color1, border, postGUI)
    end
end

function dxDrawProximityPrompt(x, y, z, lx, ly, lz, prompt)
	local x, y, w, h, width = 0, 0, 256, 256, 8
	local x2, y2, w2, h2 = 300, y+width, 1024-260, 256+width
	local padding = 25
	local progress = 0
	if stream[prompt.this].hold then
		if prompt.mode == "time" then
			local now = getTickCount()
			local data = stream[prompt.this].hold
			local elapsedTime = data.stopTime and (now - data.startTime) - (now - data.stopTime) - (now - data.stopTime) or now  - data.startTime
			local duration = data.endTime - data.startTime
			progress = elapsedTime / duration
		elseif prompt.mode == "state" and stream[prompt.this].hold.press then 
			local now = getTickCount()
			local data = stream[prompt.this].hold
			local elapsedTime = now  - data.startTime
			local duration = data.endTime - data.startTime
			progress = elapsedTime / duration			
		end
	end
	dxSetRenderTarget(stream[prompt.this].renderTarget, true)
		dxSetBlendMode("modulate_add")
			dxDrawRectangle(x+width, y+width, x+w+width, y+h+width, tocolor(0, 0, 0, 200) )
			dxDrawText(prompt.keyboardKeyCode:upper(), x+width, y+width, x+w+width, y+h+width, tocolor(255, 255, 255), 8.0, "default-bold", "center", "center")
			dxDrawBorderedRectangleProgress(x+width, y+width, x+w+width, y+h+width, tocolor(255, 255, 255, 255), 10, false, progress)
            dxDrawRectangle(x2, y2, w2, h2, tocolor(0, 0, 0, 200) )
            local _width = dxGetTextWidth(prompt.objectText, 0.8, "default-bold")
            dxDrawText(prompt.objectText, x2, y2+padding, (x2+w2)-_width/2, y2+h2, tocolor(255, 255, 255, 100), 3.5, "default-bold", "center", "top")
            local _width = dxGetTextWidth(prompt.actionText, 0.8, "default-bold")
            dxDrawText(prompt.actionText, x2, y2, (x2+w2)-_width/2, y2+h2-padding, tocolor(255, 255, 255, 100), 3.5, "default-bold", "center", "bottom")
		dxSetBlendMode("blend")
	dxSetRenderTarget(false)
	dxDrawProximityPrompt3D(x, y, z, lx, ly, lz, prompt)
	if 1.0 <= progress then
		stream[prompt.this].hold = nil
		triggerEvent("onClientPromptTriggered", prompt.this)
		if not isElementLocal(prompt.this) then
			triggerServerEvent("onPromptTriggered", prompt.this)
		end
	end
end


function dxDrawProximityPromptDisabled(x, y, z, lx, ly, lz, prompt)
	local x, y, w, h, width = 0, 0, 256, 256, 8
	local x2, y2, w2, h2 = 300, y+width, 1024-260, 256+width
	local padding = 25
	dxSetRenderTarget(stream[prompt.this].renderTarget, true)
		dxSetBlendMode("modulate_add")
			dxDrawRectangle(x+width, y+width, x+w+width, y+h+width, tocolor(0, 0, 0, 200) )
            local imgX, imgY, imgW, imgH = x+width, y+width, x+w+width, y+h+width
            dxDrawImage(imgX+imgW*0.5-w*0.25, imgY+imgH*0.5-h*0.25, w*0.5, h*0.5, locked, 0, 0, 0, tocolor(255, 255, 255, 100) )
            dxDrawRectangle(x2, y2, w2, h2, tocolor(0, 0, 0, 200) )
            local _width = dxGetTextWidth(prompt.objectText, 0.8, "default-bold")
            dxDrawText(prompt.objectText, x2, y2+padding, (x2+w2)-_width/2, y2+h2, tocolor(255, 255, 255, 100), 3.5, "default-bold", "center", "top")
            local _width = dxGetTextWidth(prompt.actionText, 0.8, "default-bold")
            dxDrawText(prompt.actionText, x2, y2, (x2+w2)-_width/2, y2+h2-padding, tocolor(255, 255, 255, 100), 3.5, "default-bold", "center", "bottom")
		dxSetBlendMode("blend")
	dxSetRenderTarget(false)
	dxDrawProximityPrompt3D(x, y, z, lx, ly, lz, prompt)
end



function dxDrawProximityPrompt3D(x, y, z, lx, ly, lz, prompt)
	if prompt.faceCamera then
    	local inFrontOfElement = Vector3( getPositionInfrontOfElement(prompt.this, 0.001) )
    	local positionElement =  Vector3( getElementPosition(prompt.this) )
    	local x, y, z = getElementPosition(localPlayer)
    	local distance = getDistanceBetweenPoints3D(x, y, z, positionElement.x, positionElement.y, positionElement.z)
		local alpha = 255 - 255 *(distance / prompt.maxDistance)
		if isElement(stream[prompt.this].renderTarget) then
			dxSetBlendMode("add")
				dxDrawMaterialLine3D(positionElement.x, positionElement.y, positionElement.z, inFrontOfElement.x, inFrontOfElement.y, inFrontOfElement.z-1, stream[prompt.this].renderTarget, 1, tocolor(255, 255, 255, alpha), stream[prompt.this].isPostGUI)
			dxSetBlendMode("blend")
		end
    else
    	local inFrontOfElement = Vector3( getPositionInfrontOfElement(prompt.this, 0.001) )
    	local positionElement =  Vector3( getElementPosition(prompt.this) )
    	local x, y, z = getElementPosition(localPlayer)
    	local distance = getDistanceBetweenPoints3D(x, y, z, positionElement.x, positionElement.y, positionElement.z)
		local alpha = 255 - 255 *(distance / prompt.maxDistance)
		if isElement(stream[prompt.this].renderTarget) then
			dxSetBlendMode("add")
				dxDrawMaterialLine3D(positionElement.x, positionElement.y, positionElement.z, inFrontOfElement.x, inFrontOfElement.y, inFrontOfElement.z-1, stream[prompt.this].renderTarget, 1, tocolor(255, 255, 255, alpha), stream[prompt.this].isPostGUI, inFrontOfElement.x, inFrontOfElement.y, inFrontOfElement.z)
			dxSetBlendMode("blend")
		end
	end
end

function onClientPreRenderPrompt(dt)
	local x, y, z, lx, ly, lz = getCameraMatrix()
	clickPrompt = {}
	local distanceElement = {}
	local distanceElement2 = {}
	for _,prompt in pairs(stream) do
		local exclusivity = prompt.exclusivity
		if exclusivity == "alwaysShow" then
			local x2, y2, z2 = getElementPosition(prompt.this)
			local distance = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			prompt.active = distance <= prompt.maxDistance
			if prompt.active then
				if prompt.enabled then
					dxDrawProximityPrompt(x, y, z, lx, ly, lz, prompt)
					clickPrompt[prompt.this] = prompt
				else
					dxDrawProximityPromptDisabled(x, y, z, lx, ly, lz, prompt)
					if clickPrompt[prompt.this] then
						clickPrompt[prompt.this] = nil
					end
				end
			end
		elseif exclusivity == "onePerButton" then
			local x2, y2, z2 = getElementPosition(prompt.this)
			local distance = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			prompt.active = distance <= prompt.maxDistance
			if prompt.active then
				distanceElement[prompt.keyboardKeyCode] = distanceElement[prompt.keyboardKeyCode] or {}
				table.insert(distanceElement[prompt.keyboardKeyCode], {prompt = prompt, distance = distance} )
			end
		elseif exclusivity == "oneGlobally" then
			local x2, y2, z2 = getElementPosition(prompt.this)
			local distance = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			prompt.active = distance <= prompt.maxDistance
			if prompt.active then
				table.insert(distanceElement2, {prompt = prompt, distance = distance} )
			end			
		end
	end
	for i,v in pairs(distanceElement) do
		local proximityPrompt = v[1].prompt
		if #v > 1 then
			local nearest, proximityPrompt
			for i,v in pairs(distanceElement) do
				if not nearest or nearest > v.distance then
					nearest = v.distance
					proximityPrompt = v.prompt
				end
			end
		end
		if proximityPrompt.enabled then
			dxDrawProximityPrompt(x, y, z, lx, ly, lz, proximityPrompt)
			clickPrompt[proximityPrompt.this] = proximityPrompt
		else
			dxDrawProximityPromptDisabled(x, y, z, lx, ly, lz, proximityPrompt)
			if clickPrompt[proximityPrompt.this] then
				clickPrompt[proximityPrompt.this] = nil
			end
		end
	end
	local nearest, proximityPrompt
	for i,v in pairs(distanceElement2) do
		if not nearest or nearest > v.distance then
			nearest = v.distance
			proximityPrompt = v.prompt
		end
	end
	if proximityPrompt then
		if proximityPrompt.enabled then
			dxDrawProximityPrompt(x, y, z, lx, ly, lz, proximityPrompt)
			clickPrompt[proximityPrompt.this] = proximityPrompt
		else
			dxDrawProximityPromptDisabled(x, y, z, lx, ly, lz, proximityPrompt)
			if clickPrompt[proximityPrompt.this] then
				clickPrompt[proximityPrompt.this] = nil
			end
		end
	end
end

function onClientKeyPrompt(button, press)
    for _,prompt in pairs(clickPrompt) do
        if button == prompt.keyboardKeyCode then
            local now = getTickCount()
            local element = prompt.this
            if press then
            	if not stream[element].hold then
            		stream[element].hold = {}
            		stream[element].hold.duration = stream[element].holdDuration
            		stream[element].hold.startTime = now
					stream[element].hold.endTime = stream[element].hold.startTime + stream[element].hold.duration
					stream[element].hold.press = press
				else
            		local data = stream[element].hold
					local elapsedTime = data.stopTime and (now - data.startTime) - (now - data.stopTime) - (now - data.stopTime) or now  - data.startTime
            		local progress = elapsedTime / stream[element].hold.duration
            		if progress >= 0 and prompt.mode == "time" then 
            			stream[element].hold.stopTime = nil
						stream[element].hold.startTime = now
						stream[element].hold.endTime = now + (stream[element].hold.duration - elapsedTime)
						stream[element].hold.startTime = stream[element].hold.startTime - elapsedTime
            		else
            			stream[element].hold.stopTime = nil
						stream[element].hold.startTime = now
						stream[element].hold.endTime = now + stream[element].hold.duration	
            		end
            		stream[element].hold.press = press
            	end
            else
            	if stream[element].hold then
            		stream[element].hold.relase = now
            		stream[element].hold.elapsedPress = getTickCount() - stream[element].hold.startTime 
					stream[element].hold.stopTime = getTickCount()
					stream[element].hold.press = nil
				end
            end
        end
    end
end
