local isClient = isElement(localPlayer)
local modes = {
	["time"] = true,
	["state"] = true,
}
local group = {
	["onePerButton"] = true,
	["alwaysShow"] = true,
	["oneGlobally"] = true,
}
local blocked = {
	["this"] = true,
}

addEvent(isClient and "onClientPromptTriggered" or "onPromptTriggered", true)

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
	    local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
			for i, v in ipairs( aAttachedFunctions ) do
				if v == func then
					return true
				end
			end
		end
	end
	return false
end

function getTypeValue(value)
	local theType = type(value)
	if theType == "userdata" then
		local userdataType = getUserdataType(value)
		return tostring(userdataType)
	else
		return theType
	end
	return false
end

proximityPrompts = {}

function proximityPromptDestroy()
	if isProximityPrompt(source) then
		if stream[source] then
			if isElement(stream[source].renderTarget) then
				destroyElement(stream[source].renderTarget)
			end
			stream[source] = nil
		end
		proximityPrompts[source] = nil
	end
end

function createProximityPrompt(x, y, z, rotation, maxDistance, actionText, objectText, keyboardKeyCode, holdDuration, exclusivity, mode)
	local object = createObject(1529, x, y, z, 0, 0, rotation)
	proximityPrompts[object] = {
		this = object,
		maxDistance = maxDistance,
		actionText = actionText,
		objectText = objectText,
		keyboardKeyCode = keyboardKeyCode or "e",
		holdDuration = holdDuration or 0,
		exclusivity = group[exclusivity] and exclusivity or "onePerButton",
		mode = modes[mode] and mode or "time",
		enabled = true,
		isPostGUI = false,
		faceCamera = false,
	}
	setElementAlpha(object, 0)
	addEventHandler(isClient and "onClientElementDestroy" or "onElementDestroy", object, proximityPromptDestroy)
	if not isClient then
		triggerClientEvent("onClientUpdateProximityPrompt", object, proximityPrompts[object])
	end
	return object
end

if isClient then
	function onClientUpdateProximityPrompt(prompt)
		proximityPrompts[source] = prompt
		if stream[prompt.this] then
			if isElement(stream[prompt.this].renderTarget) then
				destroyElement(stream[prompt.this].renderTarget)
			end
			stream[prompt.this] = prompt
			stream[prompt.this].renderTarget = dxCreateRenderTarget(1024, 1024, true)
		end
		if not isEventHandlerAdded(isClient and "onClientElementDestroy" or "onElementDestroy", source, proximityPromptDestroy) then
			addEventHandler(isClient and "onClientElementDestroy" or "onElementDestroy", source, proximityPromptDestroy)
		end
	end
	addEvent("onClientUpdateProximityPrompt", true)
	addEventHandler("onClientUpdateProximityPrompt", root, onClientUpdateProximityPrompt)

	function onClientLoadProximityPrompts(table)
		proximityPrompts = table
	end
	addEvent("onClientLoadProximityPrompts", true)
	addEventHandler("onClientLoadProximityPrompts", root, onClientLoadProximityPrompts)	
else
	function onPlayerJoinLoadPrompt()
		triggerClientEvent("onClientLoadProximityPrompts", source, proximityPrompts)
	end
	addEventHandler("onPlayerJoin", root, onPlayerJoinLoadPrompt)
end

function isProximityPrompt(element)
	return proximityPrompts[element] ~= nil
end

function proximityPromptSetProperty(element, property, value)
	if isProximityPrompt(element) then
		if blocked[property] then
			assert(false, "Bad Argument @proximityPromptSetProperty at argument 2, this property is blocked please use the correct function.")
			return
		end
		if proximityPrompts[element][property] ~= nil then
			if property == "mode" then
				assert(property == "mode" and type(value) == "string" and modes[value],"Bad Argument @proximityPromptSetProperty at argument 3, expected a string and mode got "..getTypeValue(value))
			end
			if property == "exclusivity" then assert(property == "exclusivity" and type(value) == "string" and group[value],"Bad Argument @proximityPromptSetProperty at argument 3, expected a string and group got "..getTypeValue(value)) end
			if property == "holdDuration" then assert(property == "holdDuration" and type(value) == "number","Bad Argument @proximityPromptSetProperty at argument 3, expected a number got "..getTypeValue(value)) end
			if property == "maxDistance" then assert(property == "maxDistance" and type(value) == "number","Bad Argument @proximityPromptSetProperty at argument 3, expected a number got "..getTypeValue(value)) end
			if property == "objectText" then assert(property == "objectText" and (type(value) == "string" or type(value) == "number"),"Bad Argument @proximityPromptSetProperty at argument 3, expected a string/number got "..getTypeValue(value)) end
			if property == "actionText" then assert(property == "actionText" and (type(value) == "string" or type(value) == "number"),"Bad Argument @proximityPromptSetProperty at argument 3, expected a string/number got "..getTypeValue(value)) end
			if property == "enabled" then assert(property == "enabled" and type(value) == "boolean","Bad Argument @proximityPromptSetProperty at argument 3, expected a boolean got "..getTypeValue(value)) end
			if property == "isPostGUI" then assert(property == "isPostGUI" and (type(value) == "boolean"),"Bad Argument @proximityPromptSetProperty at argument 3, expected a boolean got "..getTypeValue(value)) end
			proximityPrompts[element][property] = value
			if not isClient then
				triggerClientEvent("onClientUpdateProximityPrompt", element, proximityPrompts[element])
			end
		end
	end
end
