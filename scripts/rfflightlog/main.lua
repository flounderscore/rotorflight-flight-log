-- ListViewer.lua
-- ETHOS standalone app using form module to show a list

local items = {
    "Check battery",
    "Inspect control surfaces",
    "Check GPS lock",
    "Verify failsafe",
    "Range check",
    "Arming procedure"
  }

local form

local function init()
    form = form.create()
    form:setTitle("Preflight Checklist")

    for i = 1, #items do
        form:addStaticText(items[i])
    end
end

local function run()
if not form then
    init()
end
end

return { run = run }