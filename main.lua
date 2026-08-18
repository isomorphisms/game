-- Cheetah first playable.
--
-- GAME_SPEC.md leaves movement, bomb consequences, food types, and level
-- differences unanswered. This file therefore keeps the core game state
-- separate from a clearly marked TEST CONTROL layer:
--   * arrow/WASD/touch controls only move the prototype fixture;
--   * bomb contact is detected and reported, but has no game consequence;
--   * food pickups are generic icons rather than chosen food types;
--   * positions/counts below are only a one-level test fixture.

local player
local foods
local bombs
local collectedCount
local won
local runPhase
local bombContactTimer
local fonts = {}

local TEST_FIXTURE_FOODS = {
    { x = 0.28, y = 0.24 },
    { x = 0.49, y = 0.18 },
    { x = 0.72, y = 0.28 },
    { x = 0.36, y = 0.64 },
    { x = 0.66, y = 0.61 },
}

local TEST_FIXTURE_BOMBS = {
    { x = 0.43, y = 0.43 },
    { x = 0.59, y = 0.42 },
    { x = 0.81, y = 0.57 },
}

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function rebuildFonts()
    local _, h = love.graphics.getDimensions()
    fonts.small = love.graphics.newFont(math.max(12, math.floor(h * 0.025)))
    fonts.medium = love.graphics.newFont(math.max(16, math.floor(h * 0.036)))
    fonts.large = love.graphics.newFont(math.max(30, math.floor(h * 0.085)))
end

local function resetTestFixture()
    player = {
        x = 0.12,
        y = 0.52,
        radius = 0.040,
        testSpeed = 0.42,
        facing = 1,
    }

    foods = {}
    for i, item in ipairs(TEST_FIXTURE_FOODS) do
        foods[i] = { x = item.x, y = item.y, collected = false }
    end

    bombs = {}
    for i, item in ipairs(TEST_FIXTURE_BOMBS) do
        bombs[i] = { x = item.x, y = item.y, touching = false }
    end

    collectedCount = 0
    won = false
    runPhase = 0
    bombContactTimer = 0
end

local function worldMetrics()
    local w, h = love.graphics.getDimensions()
    local top = h * 0.12
    local bottom = h * 0.77
    return w, h, top, bottom, bottom - top
end

local function worldToScreen(x, y)
    local w, _, top, _, worldHeight = worldMetrics()
    return x * w, top + y * worldHeight
end

local function entityScale()
    local w, _, _, _, worldHeight = worldMetrics()
    return math.min(w, worldHeight)
end

local function overlapsWorld(ax, ay, ar, bx, by, br)
    local w, _, _, _, worldHeight = worldMetrics()
    local dx = (ax - bx) * w
    local dy = (ay - by) * worldHeight
    local radius = (ar + br) * entityScale()
    return dx * dx + dy * dy <= radius * radius
end

local function controlLayout()
    local w, h = love.graphics.getDimensions()
    local panelTop = h * 0.79
    local panelHeight = h - panelTop
    local size = clamp(math.min(w, h) * 0.070, 30, 48)
    local step = size * 1.04
    local cx = math.max(size * 2.1, w * 0.10)
    local cy = panelTop + panelHeight * 0.52

    local buttons = {
        left  = { x = cx - step - size / 2, y = cy - size / 2, w = size, h = size, label = "LT" },
        right = { x = cx + step - size / 2, y = cy - size / 2, w = size, h = size, label = "RT" },
        up    = { x = cx - size / 2, y = cy - step - size / 2, w = size, h = size, label = "UP" },
        down  = { x = cx - size / 2, y = cy + step - size / 2, w = size, h = size, label = "DN" },
    }

    local resetWidth = clamp(w * 0.14, 92, 150)
    local resetHeight = clamp(panelHeight * 0.36, 34, 52)
    local reset = {
        x = w - resetWidth - w * 0.025,
        y = panelTop + (panelHeight - resetHeight) / 2,
        w = resetWidth,
        h = resetHeight,
    }

    return panelTop, buttons, reset
end

local function pointInRect(x, y, rect)
    return x >= rect.x and x <= rect.x + rect.w
       and y >= rect.y and y <= rect.y + rect.h
end

local function buttonAt(x, y)
    local _, buttons = controlLayout()
    for name, rect in pairs(buttons) do
        if pointInRect(x, y, rect) then
            return name
        end
    end
    return nil
end

local function addDirection(name, vector)
    if name == "left" then vector.x = vector.x - 1 end
    if name == "right" then vector.x = vector.x + 1 end
    if name == "up" then vector.y = vector.y - 1 end
    if name == "down" then vector.y = vector.y + 1 end
end

local function getTestDirection()
    local vector = { x = 0, y = 0 }

    if love.keyboard.isDown("left", "a") then addDirection("left", vector) end
    if love.keyboard.isDown("right", "d") then addDirection("right", vector) end
    if love.keyboard.isDown("up", "w") then addDirection("up", vector) end
    if love.keyboard.isDown("down", "s") then addDirection("down", vector) end

    if love.touch then
        for _, id in ipairs(love.touch.getTouches()) do
            local x, y = love.touch.getPosition(id)
            local name = buttonAt(x, y)
            if name then addDirection(name, vector) end
        end
    end

    if love.mouse.isDown(1) then
        local x, y = love.mouse.getPosition()
        local name = buttonAt(x, y)
        if name then addDirection(name, vector) end
    end

    local length = math.sqrt(vector.x * vector.x + vector.y * vector.y)
    if length > 0 then
        vector.x = vector.x / length
        vector.y = vector.y / length
    end

    return vector.x, vector.y
end

local function starPoints(cx, cy, outerRadius, innerRadius)
    local points = {}
    for i = 0, 9 do
        local radius = (i % 2 == 0) and outerRadius or innerRadius
        local angle = -math.pi / 2 + i * math.pi / 5
        points[#points + 1] = cx + math.cos(angle) * radius
        points[#points + 1] = cy + math.sin(angle) * radius
    end
    return points
end

local function drawSavanna(w, h, top, bottom)
    love.graphics.setColor(0.48, 0.78, 0.94)
    love.graphics.rectangle("fill", 0, top, w, bottom - top)

    love.graphics.setColor(1.00, 0.84, 0.29, 0.92)
    love.graphics.circle("fill", w * 0.86, top + (bottom - top) * 0.16, h * 0.055)

    love.graphics.setColor(1, 1, 1, 0.70)
    for _, cloud in ipairs({ { 0.16, 0.18, 1.0 }, { 0.54, 0.12, 0.75 } }) do
        local cx = w * cloud[1]
        local cy = top + (bottom - top) * cloud[2]
        local s = h * 0.035 * cloud[3]
        love.graphics.ellipse("fill", cx - s * 0.9, cy, s, s * 0.58)
        love.graphics.ellipse("fill", cx, cy - s * 0.20, s * 1.15, s * 0.74)
        love.graphics.ellipse("fill", cx + s * 0.95, cy, s * 0.86, s * 0.54)
    end

    love.graphics.setColor(0.82, 0.70, 0.31)
    love.graphics.rectangle("fill", 0, bottom - h * 0.12, w, h * 0.12)
    love.graphics.setColor(0.39, 0.59, 0.20)
    love.graphics.rectangle("fill", 0, bottom - h * 0.035, w, h * 0.035)

    love.graphics.setColor(0.32, 0.48, 0.16, 0.75)
    love.graphics.setLineWidth(math.max(1, h * 0.004))
    local grassBase = bottom - h * 0.025
    local blade = h * 0.025
    for i = 0, 28 do
        local x = (i / 28) * w
        local lean = (i % 2 == 0) and -0.35 or 0.35
        love.graphics.line(x, grassBase, x + blade * lean, grassBase - blade)
    end
end

local function drawFood(item)
    if item.collected then return end

    local x, y = worldToScreen(item.x, item.y)
    local s = entityScale() * 0.034

    love.graphics.setColor(1.00, 0.95, 0.76)
    love.graphics.circle("fill", x, y, s)
    love.graphics.setColor(0.34, 0.22, 0.12)
    love.graphics.setLineWidth(math.max(2, s * 0.09))
    love.graphics.circle("line", x, y, s)
    love.graphics.circle("line", x, y, s * 0.56)

    -- Generic fork-and-knife mark: "food" without choosing a food type.
    local mark = s * 0.52
    love.graphics.line(x - mark * 0.42, y - mark, x - mark * 0.42, y + mark)
    love.graphics.line(x - mark * 0.70, y - mark, x - mark * 0.70, y - mark * 0.15)
    love.graphics.line(x - mark * 0.14, y - mark, x - mark * 0.14, y - mark * 0.15)
    love.graphics.line(x + mark * 0.48, y - mark, x + mark * 0.48, y + mark)
end

local function drawBomb(bomb)
    local x, y = worldToScreen(bomb.x, bomb.y)
    local s = entityScale() * 0.035

    love.graphics.setColor(0.09, 0.10, 0.12)
    love.graphics.circle("fill", x, y + s * 0.12, s * 0.82)
    love.graphics.rectangle("fill", x - s * 0.22, y - s * 0.85, s * 0.44, s * 0.32, s * 0.08, s * 0.08)

    love.graphics.setLineWidth(math.max(2, s * 0.12))
    love.graphics.line(x + s * 0.05, y - s * 0.78, x + s * 0.45, y - s * 1.17, x + s * 0.72, y - s * 1.02)

    love.graphics.setColor(1.00, 0.68, 0.12)
    love.graphics.circle("fill", x + s * 0.78, y - s * 1.00, s * 0.16)

    if bomb.touching then
        love.graphics.setColor(0.95, 0.20, 0.16, 0.85)
        love.graphics.setLineWidth(math.max(2, s * 0.10))
        love.graphics.circle("line", x, y, s * 1.28)
    end
end

local function drawCheetah()
    local x, y = worldToScreen(player.x, player.y)
    local s = entityScale() * 0.065
    local stride = math.sin(runPhase)
    local counter = math.sin(runPhase + math.pi)

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(player.facing, 1)

    love.graphics.setColor(0.88, 0.62, 0.16)
    love.graphics.setLineWidth(math.max(4, s * 0.18))
    love.graphics.line(-s * 1.05, -s * 0.05, -s * 1.48, -s * 0.22, -s * 1.78, -s * 0.02, -s * 1.96, -s * 0.20)
    love.graphics.setColor(0.12, 0.10, 0.08)
    love.graphics.setLineWidth(math.max(3, s * 0.11))
    love.graphics.line(-s * 1.77, -s * 0.02, -s * 1.96, -s * 0.20)

    -- Running animation is presentation only. Spatial movement uses the
    -- temporary test controls until the actual movement rule is answered.
    love.graphics.setColor(0.85, 0.57, 0.12)
    love.graphics.setLineWidth(math.max(5, s * 0.16))
    local legY = s * 0.34
    love.graphics.line(-s * 0.58, legY, -s * 0.72 + stride * s * 0.25, s * 0.82, -s * 0.98 + stride * s * 0.38, s * 1.12)
    love.graphics.line( s * 0.52, legY,  s * 0.67 + counter * s * 0.25, s * 0.82,  s * 0.97 + counter * s * 0.38, s * 1.08)
    love.graphics.line(-s * 0.18, legY, -s * 0.05 + counter * s * 0.22, s * 0.78,  s * 0.12 + counter * s * 0.34, s * 1.09)
    love.graphics.line( s * 0.82, legY,  s * 0.88 + stride * s * 0.22, s * 0.78,  s * 1.12 + stride * s * 0.34, s * 1.06)

    love.graphics.setColor(0.93, 0.67, 0.19)
    love.graphics.ellipse("fill", 0, 0, s * 1.16, s * 0.58)
    love.graphics.ellipse("fill", s * 1.02, -s * 0.25, s * 0.55, s * 0.50)
    love.graphics.circle("fill", s * 1.34, -s * 0.53, s * 0.40)

    love.graphics.setColor(0.77, 0.47, 0.10)
    love.graphics.polygon("fill", s * 1.08, -s * 0.83, s * 1.22, -s * 1.07, s * 1.34, -s * 0.78)
    love.graphics.polygon("fill", s * 1.43, -s * 0.82, s * 1.58, -s * 1.02, s * 1.64, -s * 0.72)
    love.graphics.setColor(0.98, 0.83, 0.43)
    love.graphics.ellipse("fill", s * 1.60, -s * 0.42, s * 0.30, s * 0.21)

    love.graphics.setColor(0.12, 0.10, 0.07)
    local spots = {
        {-0.74, -0.18, 0.09}, {-0.43, 0.17, 0.08}, {-0.20, -0.30, 0.10},
        { 0.10,  0.12, 0.08}, { 0.35, -0.18, 0.09}, { 0.64, 0.13, 0.08},
        { 0.87, -0.31, 0.07}, { 1.18, -0.54, 0.06},
    }
    for _, spot in ipairs(spots) do
        love.graphics.circle("fill", s * spot[1], s * spot[2], s * spot[3])
    end

    love.graphics.circle("fill", s * 1.47, -s * 0.59, s * 0.045)
    love.graphics.setLineWidth(math.max(2, s * 0.045))
    love.graphics.line(s * 1.47, -s * 0.54, s * 1.56, -s * 0.34)
    love.graphics.circle("fill", s * 1.85, -s * 0.43, s * 0.055)

    love.graphics.pop()
end

local function drawTestControls()
    local w, h = love.graphics.getDimensions()
    local panelTop, buttons, reset = controlLayout()

    love.graphics.setColor(0.08, 0.09, 0.11)
    love.graphics.rectangle("fill", 0, panelTop, w, h - panelTop)
    love.graphics.setColor(0.22, 0.24, 0.28)
    love.graphics.rectangle("fill", 0, panelTop, w, 2)

    love.graphics.setFont(fonts.small)
    for _, rect in pairs(buttons) do
        love.graphics.setColor(0.21, 0.24, 0.29)
        love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 8, 8)
        love.graphics.setColor(0.94, 0.95, 0.97)
        love.graphics.printf(rect.label, rect.x, rect.y + rect.h * 0.30, rect.w, "center")
    end

    local textLeft = math.min(w * 0.23, 230)
    local textRight = reset.x - w * 0.025
    love.graphics.setColor(1.00, 0.78, 0.23)
    love.graphics.setFont(fonts.medium)
    love.graphics.print("TEST CONTROLS", textLeft, panelTop + (h - panelTop) * 0.18)
    love.graphics.setColor(0.84, 0.86, 0.90)
    love.graphics.setFont(fonts.small)
    love.graphics.printf(
        "Temporary only -- touch arrows or use WASD/arrows. Movement and bomb consequences are still unanswered game rules.",
        textLeft,
        panelTop + (h - panelTop) * 0.50,
        math.max(120, textRight - textLeft),
        "left"
    )

    love.graphics.setColor(0.27, 0.30, 0.35)
    love.graphics.rectangle("fill", reset.x, reset.y, reset.w, reset.h, 8, 8)
    love.graphics.setColor(0.96, 0.96, 0.97)
    love.graphics.printf("RESET TEST", reset.x, reset.y + reset.h * 0.31, reset.w, "center")
end

local function drawHud()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0.055, 0.06, 0.075, 0.94)
    love.graphics.rectangle("fill", 0, 0, w, h * 0.12)

    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.96, 0.96, 0.97)
    love.graphics.print("CHEETAH -- CORE PLAYABLE", w * 0.025, h * 0.033)

    love.graphics.setColor(1.00, 0.84, 0.31)
    love.graphics.printf(string.format("FOOD  %d / %d", collectedCount, #foods), w * 0.68, h * 0.033, w * 0.29, "right")
end

local function drawBombContactNotice()
    if bombContactTimer <= 0 then return end

    local w, h = love.graphics.getDimensions()
    local boxW = math.min(w * 0.58, 560)
    local boxH = h * 0.10
    local x = (w - boxW) / 2
    local y = h * 0.14

    love.graphics.setColor(0.10, 0.10, 0.12, 0.88)
    love.graphics.rectangle("fill", x, y, boxW, boxH, 10, 10)
    love.graphics.setColor(1.00, 0.48, 0.25)
    love.graphics.setFont(fonts.small)
    love.graphics.printf(
        "TEST: bomb contact detected. No consequence is implemented because the rule is unanswered.",
        x + 12, y + boxH * 0.28, boxW - 24, "center"
    )
end

local function drawWinResult()
    if not won then return end

    local w, h = love.graphics.getDimensions()
    local cx = w * 0.50
    local cy = h * 0.43
    local outer = math.min(w, h) * 0.13

    love.graphics.setColor(0.04, 0.05, 0.07, 0.74)
    love.graphics.rectangle("fill", w * 0.28, h * 0.23, w * 0.44, h * 0.43, 18, 18)

    love.graphics.setColor(1.00, 0.80, 0.12)
    love.graphics.polygon("fill", starPoints(cx, cy - outer * 0.18, outer, outer * 0.46))
    love.graphics.setColor(0.29, 0.20, 0.03)
    love.graphics.setLineWidth(math.max(2, outer * 0.035))
    love.graphics.polygon("line", starPoints(cx, cy - outer * 0.18, outer, outer * 0.46))

    love.graphics.setFont(fonts.large)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("1 STAR", 0, cy + outer * 1.02, w, "center")
end

function love.load()
    love.graphics.setBackgroundColor(0.08, 0.09, 0.12)
    rebuildFonts()
    resetTestFixture()
end

function love.resize()
    rebuildFonts()
end

function love.update(dt)
    runPhase = runPhase + dt * 12
    bombContactTimer = math.max(0, bombContactTimer - dt)

    local dx, dy = getTestDirection()
    if dx ~= 0 or dy ~= 0 then
        if dx < 0 then player.facing = -1 end
        if dx > 0 then player.facing = 1 end
        player.x = clamp(player.x + dx * player.testSpeed * dt, 0.055, 0.945)
        player.y = clamp(player.y + dy * player.testSpeed * dt, 0.07, 0.90)
    end

    for _, food in ipairs(foods) do
        if not food.collected and overlapsWorld(player.x, player.y, player.radius, food.x, food.y, 0.034) then
            food.collected = true
            collectedCount = collectedCount + 1
            if collectedCount == #foods then won = true end
        end
    end

    for _, bomb in ipairs(bombs) do
        local touching = overlapsWorld(player.x, player.y, player.radius, bomb.x, bomb.y, 0.038)
        if touching and not bomb.touching then bombContactTimer = 1.35 end
        bomb.touching = touching
        -- Intentionally no state change: GAME_SPEC.md has no bomb consequence yet.
    end
end

function love.draw()
    local w, h, top, bottom = worldMetrics()
    drawSavanna(w, h, top, bottom)

    for _, food in ipairs(foods) do drawFood(food) end
    for _, bomb in ipairs(bombs) do drawBomb(bomb) end
    drawCheetah()

    drawHud()
    drawBombContactNotice()
    drawWinResult()
    drawTestControls()
end

local function resetPressedAt(x, y)
    local _, _, reset = controlLayout()
    if pointInRect(x, y, reset) then
        resetTestFixture()
        return true
    end
    return false
end

function love.touchpressed(_, x, y)
    resetPressedAt(x, y)
end

function love.mousepressed(x, y, button)
    if button == 1 then resetPressedAt(x, y) end
end

function love.keypressed(key)
    if key == "r" then
        resetTestFixture()
    elseif key == "escape" then
        love.event.quit()
    end
end
