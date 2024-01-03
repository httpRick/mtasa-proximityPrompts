
# Proximity Prompts
ProximityPrompt enables interactions in the 3D world, such as opening a door/gate or picking up an object.

# Authors
- [Rick](https://github.com/httpRick)
- [T34P07](https://github.com/T34P07)

# Installation
1. Download resource.
2. Place the resource in your server resources folder.

# Documentation

    createProximityPrompt(float x, float y, float z, float rotation, float maxDistance, string actionText, string objectText, [string keyboardKeyCode, float holdDuration, string exclusivity, string mode])

- Required Arguments
x: A floating point number representing the X coordinate on the map.
y: A floating point number representing the Y coordinate on the map.
z: A floating point number representing the Z coordinate on the map.
rotation: A floating point number representing the Z rotation on the map.
range: the range in which the proximity Prompt will be usable and visible.
actionText: action name shown to the player.
objectText: name for the object being interacted with.

- Optional Arguments
keyboardKeyCode: The keyboard key which will trigger the prompt, default set "E".
holdDuration: time for three to hold the key to trigger the prompt, default set 0 ms.
exclusivity: This property is used to customize which prompts can be shown at the same time, default set "onePerButton".
mode: This property is used to determine how the prompt behaves when it comes to interacting with it, default set "time".

Return:
- If the function succeeds, it returns element proximity prompt, false otherwise.
##
      proximityPromptSetProperty(element proximityPrompt, string property, [number/string/boolean] value)

Required Arguments:
- proximityPrompt: the proximity prompt element you wish to set a property to.
- property: the name of of property you want the value to.
- value: the value you want to set.

Property List:
- maxDistance
- actionText
- objectText
- keyboardKeyCode
- holdDuration
- exclusivity
- mode [default: "time"]
- enabled [default: true]: Determines whether prompt interaction is enabled or disabled
- isPostGUI [default: false]: A bool representing whether the text should be drawn on top of or behind any ingame GUI (rendered by CEGUI).
- faceCamera [default: false]: Defines whether the position is to be set so that the camera position is always oriented so that the front of the line faces the camera.

Available properties for mode:
- time: When using an interaction with a prompt, if it does not reach the end, it will go backwards and start from the point left in time
- state: Every time we release a key during an interaction, we start from scratch

Return:
- If the function succeeds, it returns true, false otherwise.
##
# Event Server Side:

      addEventHandler("onPromptTriggered", element Proximity Prompt, function functionName)

This event is triggered every time a player activates a Prixmity Prompt.

Example Server Side:
        
        local isColumbianGateOpen = false
        local columbianGate = createObject(975, 2719.92578125, -2405.2861328125, 14.136102676392, 0, 0, 90)
        local prompt = exports["mtasa-proximityPrompts"]:createProximityPrompt(2719.92578125, -2405.2861328125, 14.136102676392, 0, 5, "Open Gate", "Gate", "G", 1200)
        attachElements(prompt, columbianGate, -3.5, 0.15, 0, 0, 0, 0)

        function moveColumbianGate()
            isColumbianGateOpen = not isColumbianGateOpen
            moveObject(columbianGate, 1000, 2719.92578125, -2405.2861328125+(isColumbianGateOpen and 4.73685 or 0), 14.136102676392)
            exports["mtasa-proximityPrompts"]:proximityPromptSetProperty(source, "actionText", isColumbianGateOpen and "Close Gate" or "Open Gate")
        end
        addEventHandler("onPromptTriggered", prompt, moveColumbianGate)

# Event Client Side:

      addEventHandler("onPromptTriggered", element Proximity Prompt, function functionName)

This event is triggered every time a player activates a Prixmity Prompt.

Example Client Side:
        
        local isColumbianGateOpen = false
        local columbianGate = createObject(975, 2719.92578125, -2405.2861328125, 14.136102676392, 0, 0, 90)
        local prompt = exports["mtasa-proximityPrompts"]:createProximityPrompt(2719.92578125, -2405.2861328125, 14.136102676392, 0, 5, "Open Gate", "Gate", "G", 1200)
        attachElements(prompt, columbianGate, -3.5, 0.15, 0, 0, 0, 0)

        function moveColumbianGate()
            isColumbianGateOpen = not isColumbianGateOpen
            moveObject(columbianGate, 1000, 2719.92578125, -2405.2861328125+(isColumbianGateOpen and 4.73685 or 0), 14.136102676392)
            exports["mtasa-proximityPrompts"]:proximityPromptSetProperty(source, "actionText", isColumbianGateOpen and "Close Gate" or "Open Gate")
        end
        addEventHandler("onClientPromptTriggered", prompt, moveColumbianGate)
