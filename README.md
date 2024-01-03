![image](https://github.com/httpRick/mtasa-proximityPrompts/assets/8506863/250fde2d-254e-4930-9358-9c71f02302c8)
# Proximity Prompts
ProximityPrompt enables interactions in the 3D world, such as opening a door/gate or picking up an object.

[screenshot.png](https://i.imgur.com/T0lk3tY.png)

# Authors
- [Rick](https://github.com/httpRick)
- [T34P07](https://github.com/T34P07)

# Installation
1. Download resource.
2. Place the resource in your server resources folder.

# Documentation

    createProximityPrompt(float x, float y, float z, float rotation, float maxDistance, string actionText, string objectText, [string keyboardKeyCode, float holdDuration, string exclusivity, string mode])

Required Arguments
- x: A floating point number representing the X coordinate on the map.
- y: A floating point number representing the Y coordinate on the map.
- z: A floating point number representing the Z coordinate on the map.
- rotation: A floating point number representing the Z rotation on the map.
- range: the range in which the proximity Prompt will be usable and visible.
- actionText: action name shown to the player.
- objectText: name for the object being interacted with.

Optional Arguments
- keyboardKeyCode: The keyboard key which will trigger the prompt, default set "E".
- holdDuration: time for three to hold the key to trigger the prompt, default set 0 ms.
- exclusivity: This property is used to customize which prompts can be shown at the same time, default set "onePerButton".
- mode: This property is used to determine how the prompt behaves when it comes to interacting with it, default set "time".

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
- exclusivity [default: "onePerButton"]
- mode [default: "time"]
- enabled [default: true]: Determines whether prompt interaction is enabled or disabled
- isPostGUI [default: false]: A bool representing whether the text should be drawn on top of or behind any ingame GUI (rendered by CEGUI).
- faceCamera [default: false]: Defines whether the position is to be set so that the camera position is always oriented so that the front of the line faces the camera.

Available properties for mode:
- time: When using an interaction with a prompt, if it does not reach the end, it will go backwards and start from the point left in time
- state: Every time we release a key during an interaction, we start from scratch

Available properties for exclusivity:
- onePerButton: Only one, i.e. if you have many proximity prompts next to each other, it will show them all BUT if more than one has the same keycode, it will only show the 1 that is closest and the rest that have a different keycode.
Example: 2 proximity prompts with keycode E and next to each other 2 proximity prompts with keycode F and 1 proximity prompt with keycode D. In this case you see the proximity prompt E closest to the camera and the proximity prompt F and proximity prompt D closest to the camera.
In short: show all, but if more than one has the same keycode, select only the one closest to the camera from all those that have the same keycode.

- alwaysShow: In this state, it doesn't matter what proximity prompt is on the screen if it is in a given range, it doesn't matter if there are the same proximity prompts with the same keycodes next to each other, if they have alwaysShow, they show up in pairs at once and can be triggered at once.
The onePerButton state ignores alwaysShow and only works on states with onePerButton. That is: If we have 3 Proximity Prompts with the same key codes, 2 of them will be onePerButton and 1 Always on show, then we will see 2 proximity prompts, the game will always show the one with always on show and will select the onePerButton closest to the camera.

- oneGlobally Works similarly to onePerButton, except that you only see one proximity prompt from this group out of all. Example: You have 2 Proximity prompts next to each other from oneGlobally, one has keycode F and the other keycode E. In this case, only the one that is closest to the camera will be shown, regardless of the fact that there is another one next to it with a different code.


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

      addEventHandler("onClientPromptTriggered", element Proximity Prompt, function functionName)

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
