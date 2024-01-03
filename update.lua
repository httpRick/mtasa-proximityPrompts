local CHECK_FOR_UPDATES = true
local VERSION = 1
local url = "https://api.github.com/repos/httpRick/mtasa-proximityPrompts/releases/latest"

if CHECK_FOR_UPDATES then
    addEventHandler("onResourceStart", resourceRoot, function()
        fetchRemote(url, function(data, status)
            assert(status == 0 and data, "[proximityPrompts] Can't fetch 'api.github.com' for new releases! (Status code: "..tostring(status)..")")
            data = fromJSON(data)
            if data then
                local tag_name       = tostring(data["tag_name"])
                local latest_version = tonumber( (tag_name:gsub("v",""):gsub("%.","")) )
                if latest_version then
                    if latest_version > VERSION then
                        local asset = data["assets"][1]
                        if asset then
                            local path = "releases/"..asset["name"]
                            if fileExists(path) then
                                print("[proximityPrompts] New release ("..tag_name..") available on Github! It's already downloaded into 'releases' directory inside proximityPrompts, just replace the old one!")
                            else
                                fetchRemote(asset["browser_download_url"], function(data, status)
                                    assert(status == 0 and data, "[proximityPrompts] Can't download latest release ("..tag_name..") from Github! (Status code: "..tostring(status)..")")
                                    local zip = fileCreate(path)
                                    if zip then
                                        fileWrite(zip, data)
                                        fileClose(zip)
                                        print("[proximityPrompts] New release ("..tag_name..") available on Github! Automatically downloaded into 'releases' directory inside proximityPrompts, just replace the old one!")
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end)
    end)
end
