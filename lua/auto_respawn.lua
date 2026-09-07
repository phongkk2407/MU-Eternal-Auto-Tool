-- ============================================
-- MU Eternal - Auto Respawn Script (Lua)
-- Hồi sinh nhanh tại vị trí 1
-- ============================================
-- Sử dụng trên BlueStacks/Memu

local RESPAWN_BUTTON_X = 512  -- Tọa độ X nút hồi sinh (điều chỉnh theo màn hình)
local RESPAWN_BUTTON_Y = 900  -- Tọa độ Y nút hồi sinh
local DELAY_MS = 100          -- Độ trễ giữa các click (ms)
local CHECK_INTERVAL = 2000   -- Kiểm tra tình trạng mỗi 2 giây
local RESPAWN_LOCATION = 1    -- Vị trí hồi sinh (1 = thành)

-- Biến toàn cục
local isRunning = false
local deathCount = 0
local lastRespawnTime = 0

-- Hàm click vào nút hồi sinh
function clickRespawn()
    touch.press(RESPAWN_BUTTON_X, RESPAWN_BUTTON_Y)
    mSleep(50)
    touch.release(RESPAWN_BUTTON_X, RESPAWN_BUTTON_Y)
    mSleep(DELAY_MS)
end

-- Hàm chọn vị trí hồi sinh
function selectRespawnLocation()
    -- Click vào vị trí 1 (thành phố)
    touch.press(300, 700)  -- Điều chỉnh theo UI game
    mSleep(100)
    touch.release(300, 700)
    mSleep(500)
    
    -- Xác nhận
    touch.press(512, 850)
    mSleep(50)
    touch.release(512, 850)
    mSleep(DELAY_MS)
end

-- Hàm phát hiện khi nhân vật chết
function isPlayerDead()
    -- Kiểm tra xem nút hồi sinh có xuất hiện không
    -- Bạn cần chụp màn hình nhân vật chết để OCR hoặc pixel color
    local color = getColor(RESPAWN_BUTTON_X, RESPAWN_BUTTON_Y)
    -- Nếu màu khác = nhân vật chết, trả về true
    return color ~= 0xFFFFFF  -- Điều chỉnh màu theo thực tế
end

-- Hàm hồi sinh tự động
function autoRespawn()
    toast("🎮 Auto Respawn bắt đầu!")
    isRunning = true
    
    while isRunning do
        if isPlayerDead() then
            deathCount = deathCount + 1
            local currentTime = os.time() * 1000
            
            -- Kiểm tra thời gian giữa các lần hồi sinh (tránh spam)
            if currentTime - lastRespawnTime > 1000 then
                toast("💀 Nhân vật đã chết! Hồi sinh lần " .. deathCount)
                
                -- Click nút hồi sinh
                clickRespawn()
                mSleep(300)
                
                -- Chọn vị trí hồi sinh
                selectRespawnLocation()
                
                lastRespawnTime = currentTime
                toast("✅ Hồi sinh thành công!")
            end
        end
        
        mSleep(CHECK_INTERVAL)
    end
end

-- Hàm dừng script
function stopAutoRespawn()
    isRunning = false
    toast("⛔ Auto Respawn đã dừng")
    print("Tổng số lần chết: " .. deathCount)
end

-- Hàm bắt đầu/dừng bằng keypress
function startKeyListener()
    -- Nhấn F1 để bắt đầu
    if keyDown(19) then  -- F1
        if not isRunning then
            autoRespawn()
        end
    end
    
    -- Nhấn F2 để dừng
    if keyDown(20) then  -- F2
        stopAutoRespawn()
    end
end

-- ============================================
-- MAIN - Chạy script
-- ============================================
print("=== MU Eternal Auto Respawn ===")
print("F1: Bắt đầu | F2: Dừng")
print("Vị trí hồi sinh: " .. RESPAWN_LOCATION)
print("================================")

-- Lặp lại để lắng nghe phím
while true do
    startKeyListener()
    mSleep(100)
end
