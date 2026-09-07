-- ============================================
-- MU Eternal - Fast Attack & Respawn (Lua)
-- Tốc độ đánh gấp 2 lần + Hồi sinh nhanh
-- ============================================

local ATTACK_BUTTON_X = 512   -- Tọa độ X nút đánh
local ATTACK_BUTTON_Y = 850   -- Tọa độ Y nút đánh
local RESPAWN_BUTTON_X = 512  -- Tọa độ X nút hồi sinh
local RESPAWN_BUTTON_Y = 900  -- Tọa độ Y nút hồi sinh

-- Tốc độ tấn công (ms giữa các cú đánh)
local ATTACK_SPEED = 150      -- 150ms = tấn công gấp 2 lần (bình thường 300ms)
local RESPAWN_DELAY = 100     -- Độ trễ hồi sinh
local CHECK_INTERVAL = 1000   -- Kiểm tra tình trạng

-- Biến toàn cục
local isRunning = false
local isAttacking = false
local deathCount = 0
local attackCount = 0
local lastRespawnTime = 0

-- ============================================
-- TẤN CÔNG NHANH GẤPI 2
-- ============================================
function fastAttack()
    while isAttacking do
        -- Click đánh
        touch.press(ATTACK_BUTTON_X, ATTACK_BUTTON_Y)
        mSleep(50)
        touch.release(ATTACK_BUTTON_X, ATTACK_BUTTON_Y)
        
        -- Độ trễ giữa các cú (tốc độ gấp 2)
        mSleep(ATTACK_SPEED)
        attackCount = attackCount + 1
        
        -- Cập nhật giao diện mỗi 10 cú đánh
        if attackCount % 10 == 0 then
            print("⚔️ Đã đánh: " .. attackCount .. " cú")
        end
    end
end

-- ============================================
-- HỒI SINH NHANH TẠI VỊ TRÍ 1
-- ============================================
function fastRespawn()
    toast("💀 Hồi sinh ngay!")
    isAttacking = false
    mSleep(200)
    
    -- Click nút hồi sinh
    touch.press(RESPAWN_BUTTON_X, RESPAWN_BUTTON_Y)
    mSleep(50)
    touch.release(RESPAWN_BUTTON_X, RESPAWN_BUTTON_Y)
    mSleep(300)
    
    -- Chọn vị trí 1 (thành phố) - auto confirm
    touch.press(300, 700)
    mSleep(100)
    touch.release(300, 700)
    mSleep(200)
    
    -- Xác nhận
    touch.press(512, 850)
    mSleep(50)
    touch.release(512, 850)
    mSleep(RESPAWN_DELAY)
    
    deathCount = deathCount + 1
    toast("✅ Hồi sinh lần " .. deathCount .. " xong!")
    
    -- Bắt đầu đánh lại
    isAttacking = true
    mSleep(500)
    fastAttack()
end

-- ============================================
-- PHÁT HIỆN NHÂN VẬT CHẾT
-- ============================================
function isPlayerDead()
    -- Cách 1: Kiểm tra màu pixel (điều chỉnh theo game)
    local color = getColor(RESPAWN_BUTTON_X, RESPAWN_BUTTON_Y)
    
    -- Cách 2: OCR text "Hồi sinh" 
    -- local text = ocr(480, 880, 550, 920)
    -- return string.find(text, "Hồi sinh") ~= nil
    
    return color ~= 0xFFFFFF
end

-- ============================================
-- CHẾ ĐỘ FULL AUTO (Đánh liên tục + Hồi sinh tự động)
-- ============================================
function fullAutoMode()
    toast("🤖 Chế độ Full Auto bắt đầu!")
    print("⚔️ Tấn công gấp 2 lần | 💀 Hồi sinh tự động")
    isRunning = true
    isAttacking = true
    
    -- Thread 1: Tấn công liên tục
    local attackThread = coroutine.create(function()
        fastAttack()
    end)
    
    -- Thread 2: Giám sát tình trạng
    while isRunning do
        if isPlayerDead() then
            local currentTime = os.time() * 1000
            if currentTime - lastRespawnTime > 2000 then
                fastRespawn()
                lastRespawnTime = currentTime
                coroutine.resume(attackThread)
            end
        end
        mSleep(CHECK_INTERVAL)
    end
end

-- ============================================
-- CHỈ TẤN CÔNG NHANH (Không tự động hồi sinh)
-- ============================================
function attackOnlyMode()
    toast("⚔️ Chế độ Tấn công nhanh!")
    isRunning = true
    isAttacking = true
    fastAttack()
end

-- ============================================
-- ĐIỀU KHIỂN BẰNG PHÍM
-- ============================================
function keyControl()
    -- F1: Full Auto (đánh + hồi sinh)
    if keyDown(19) then
        if not isRunning then
            fullAutoMode()
        end
    end
    
    -- F2: Chỉ đánh nhanh
    if keyDown(20) then
        if not isRunning then
            attackOnlyMode()
        end
    end
    
    -- F3: Dừng
    if keyDown(21) then
        isRunning = false
        isAttacking = false
        toast("⛔ Dừng script")
        print("📊 Thống kê:")
        print("   Tổng cú đánh: " .. attackCount)
        print("   Tổng lần chết: " .. deathCount)
    end
end

-- ============================================
-- MAIN
-- ============================================
print("╔════════════════════════════════════╗")
print("║  MU Eternal - Tấn Công Gấp 2 Lần   ║")
print("║        + Hồi Sinh Tự Động          ║")
print("╚════════════════════════════════════╝")
print("")
print("📌 ĐIỀU KHIỂN:")
print("   F1: Chế độ Full Auto (Đánh + Hồi sinh)")
print("   F2: Chỉ đánh nhanh (Manual hồi sinh)")
print("   F3: Dừng script")
print("")
print("⚙️  CẤU HÌNH:")
print("   Tốc độ đánh: " .. ATTACK_SPEED .. "ms (Gấp 2 lần)")
print("   Kiểm tra: " .. CHECK_INTERVAL .. "ms")
print("")

-- Vòng lặp chính
while true do
    keyControl()
    mSleep(100)
end
