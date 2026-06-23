-- [[ PREMIUM ROBLOX HUB UI LIBRARY ]] --
-- Chủ đạo: Đỏ (Primary) | Phụ: Xanh Lá (Secondary)
-- Tính năng mới: Check game 5 giây đếm ngược, nếu sai hỗ trợ sẽ tự động Kick!

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local HubLib = {}

-- Khởi tạo ScreenGui chính để chứa toàn bộ các tầng UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumHubUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

---- ====================================================================
-- DANH SÁCH ID CÁC GAME ĐƯỢC PHÉP CHẠY SCRIPT (TARGET GAMES)
-- ====================================================================
local TargetGames = {
    [99078474560152] = "M.E.G Gameplay Map",
    [98629859043211] = "M.E.G Lobby Map",
    [6516141723]     = "DOORS (Main)",
    [6839171747]     = "DOORS (Lobby/Other)",
    [88323040672117] = "Divaz Game",
    [97598239454123] = "Grow A Garden 2",
    [7577961216]     = "Squid Game X (Lobby)",
    [7577981568]     = "Squid Game X (Gameplay)",
}

local CorrectKey = "bloxypremium2026" -- Key mặc định để đăng nhập Hub
local CurrentPlaceId = game.PlaceId
local CurrentGameName = TargetGames[CurrentPlaceId]

local function VerifyGameSupport(callback)
    -- Tạo một bảng thông báo kiểm tra game nhỏ gọn, thiết kế đỏ đen cao cấp
    local CheckFrame = Instance.new("Frame")
    CheckFrame.Name = "CheckFrame"
    CheckFrame.Parent = ScreenGui
    CheckFrame.Size = UDim2.new(0, 320, 0, 90)
    CheckFrame.Position = UDim2.new(0.5, -160, 0.5, -45)
    CheckFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    
    local C_Corner = Instance.new("UICorner")
    C_Corner.CornerRadius = UDim.new(0, 10)
    C_Corner.Parent = CheckFrame
    
    local C_Stroke = Instance.new("UIStroke")
    C_Stroke.Color = Color3.fromRGB(255, 0, 0) -- Viền đỏ rực nhấn mạnh tính năng check
    C_Stroke.Thickness = 1.5
    C_Stroke.Parent = CheckFrame

    local CheckText = Instance.new("TextLabel")
    CheckText.Parent = CheckFrame
    CheckText.Size = UDim2.new(1, 0, 1, 0)
    CheckText.BackgroundTransparency = 1
    CheckText.Text = "Checking Game Compatibility...\nInitializing in 5s"
    CheckText.Font = Enum.Font.GothamBold
    CheckText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CheckText.TextSize = 14

    -- Thực hiện vòng lặp đếm ngược 5 giây (Check 5s)
    for i = 5, 1, -1 do
        CheckText.Text = "Checking Game Compatibility...\nVerifying system in " .. i .. "s"
        task.wait(1)
    end

    -- Sau 5 giây, tiến hành so khớp ID Game
    if not CurrentGameName then
        CheckText.TextColor3 = Color3.fromRGB(255, 50, 50)
        CheckText.Text = "🔴 Game Not Supported!"
        task.wait(1)
        LocalPlayer:Kick("🔴 Hub Error: This game is not supported by BloxY Hub!")
        return
    else
        CheckText.TextColor3 = Color3.fromRGB(0, 180, 90) -- Đổi sang xanh khi check thành công
        CheckText.Text = "🟢 Game Verified: " .. CurrentGameName
        task.wait(1.2)
        CheckFrame:Destroy()
        callback() -- Chạy tiếp sang phần Loading Bar nếu hợp lệ
    end
end


-- ====================================================================
-- 2. HỆ THỐNG LOADING BAR (1% -> 100%)
-- ====================================================================
local function StartLoadingAnimation(callback)
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "LoadingFrame"
    LoadingFrame.Parent = ScreenGui
    LoadingFrame.Size = UDim2.new(0, 350, 0, 100)
    LoadingFrame.Position = UDim2.new(0.5, -175, 0.5, -50)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    
    local L_Corner = Instance.new("UICorner")
    L_Corner.CornerRadius = UDim.new(0, 12)
    L_Corner.Parent = LoadingFrame
    
    local L_Stroke = Instance.new("UIStroke")
    L_Stroke.Color = Color3.fromRGB(255, 0, 0)
    L_Stroke.Thickness = 1.5
    L_Stroke.Parent = LoadingFrame

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Parent = LoadingFrame
    LoadingText.Size = UDim2.new(1, 0, 0, 30)
    LoadingText.Position = UDim2.new(0, 0, 0, 15)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = "Loading Assets... 0%"
    LoadingText.Font = Enum.Font.GothamBold
    LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingText.TextSize = 14

    local BarBackground = Instance.new("Frame")
    BarBackground.Parent = LoadingFrame
    BarBackground.Size = UDim2.new(1, -40, 0, 12)
    BarBackground.Position = UDim2.new(0, 20, 0, 55)
    BarBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    
    local BarBgCorner = Instance.new("UICorner")
    BarBgCorner.CornerRadius = UDim.new(1, 0)
    BarBgCorner.Parent = BarBackground

    local BarProgress = Instance.new("Frame")
    BarProgress.Parent = BarBackground
    BarProgress.Size = UDim2.new(0, 0, 1, 0)
    BarProgress.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    
    local BarProgCorner = Instance.new("UICorner")
    BarProgCorner.CornerRadius = UDim.new(1, 0)
    BarProgCorner.Parent = BarProgress

    for i = 1, 100 do
        task.wait(0.015)
        LoadingText.Text = "Loading System Assets... " .. i .. "%"
        TweenService:Create(BarProgress, TweenInfo.new(0.015, Enum.EasingStyle.Linear), {Size = UDim2.new(i/100, 0, 1, 0)}):Play()
    end

    LoadingText.Text = "Ready!"
    task.wait(0.4)
    LoadingFrame:Destroy()
    callback()
end


-- ====================================================================
-- 3. HỆ THỐNG KIỂM TRA KEY (KEY SYSTEM)
-- ====================================================================
local function StartKeySystem(callback)
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Name = "KeyFrame"
    KeyFrame.Parent = ScreenGui
    KeyFrame.Size = UDim2.new(0, 360, 0, 180)
    KeyFrame.Position = UDim2.new(0.5, -180, 0.5, -90)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    
    local K_Corner = Instance.new("UICorner")
    K_Corner.CornerRadius = UDim.new(0, 14)
    K_Corner.Parent = KeyFrame
    
    local K_Stroke = Instance.new("UIStroke")
    K_Stroke.Color = Color3.fromRGB(255, 0, 0)
    K_Stroke.Thickness = 1.5
    K_Stroke.Parent = KeyFrame

    local KeyTitle = Instance.new("TextLabel")
    KeyTitle.Parent = KeyFrame
    KeyTitle.Size = UDim2.new(1, 0, 0, 40)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = "KEY VERIFICATION"
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
    KeyTitle.TextSize = 16

    local KeyInput = Instance.new("TextBox")
    KeyInput.Parent = KeyFrame
    KeyInput.Size = UDim2.new(1, -40, 0, 38)
    KeyInput.Position = UDim2.new(0, 20, 0, 55)
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.Text = ""
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    KeyInput.TextSize = 14
    
    local KI_Corner = Instance.new("UICorner")
    KI_Corner.CornerRadius = UDim.new(0, 8)
    KI_Corner.Parent = KeyInput

    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Parent = KeyFrame
    SubmitBtn.Size = UDim2.new(0, 150, 0, 35)
    SubmitBtn.Position = UDim2.new(0.5, -75, 0, 115)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SubmitBtn.Text = "Check Key"
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 14
    
    local SB_Corner = Instance.new("UICorner")
    SB_Corner.CornerRadius = UDim.new(0, 8)
    SB_Corner.Parent = SubmitBtn

    SubmitBtn.MouseButton1Click:Connect(function()
        if KeyInput.Text == CorrectKey then
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
            SubmitBtn.Text = "Access Granted!"
            task.wait(0.7)
            KeyFrame:Destroy()
            callback()
        else
            SubmitBtn.Text = "Invalid Key! Try Again."
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            task.wait(1.5)
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            SubmitBtn.Text = "Check Key"
        end
    end)
end


-- ====================================================================
-- 4. KHỞI TẠO CỬA SỔ CHÍNH CỦA HUB (MAIN WINDOW UI LIBRARY)
-- ====================================================================
function HubLib:CreateWindow(hubName, githubIconId)
    local ToggleHubBtn = Instance.new("ImageButton")
    ToggleHubBtn.Name = "ToggleHubBtn"
    ToggleHubBtn.Parent = ScreenGui
    ToggleHubBtn.Size = UDim2.new(0, 48, 0, 48)
    ToggleHubBtn.Position = UDim2.new(0, 20, 0, 20)
    ToggleHubBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ToggleHubBtn.Image = "rbxassetid://" .. (githubIconId or "0")
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleHubBtn

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(255, 0, 0)
    ToggleStroke.Thickness = 2
    ToggleStroke.Parent = ToggleHubBtn

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 560, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    MainFrame.ClipsDescendants = true

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 40, 40)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    local isOpen = true
    ToggleHubBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(0, 560, 0, 360) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    end)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(26, 26, 26)

        -- ================================================================
    -- ĐOẠN SỬA: PHÂN CHIA LẠI VỊ TRÍ VÀ THÊM MÀU ĐỎ/VÀNG CHO ĐẸP
    -- ================================================================
    local HubTitle = Instance.new("TextLabel")
    HubTitle.Parent = TopBar
    HubTitle.Text = hubName .. " | " .. CurrentGameName
    -- SỬA TẠI ĐÂY: Cho Title rộng hẳn ra (260 pixel) để không bị cắt chữ hay đè
    HubTitle.Size = UDim2.new(0, 260, 1, 0)
    HubTitle.Position = UDim2.new(0, 15, 0, 0)
    HubTitle.Font = Enum.Font.GothamBold
    -- SỬA TẠI ĐÂY: Đổi từ màu trắng (255,255,255) sang màu ĐỎ CHÁY (255, 50, 50) hoặc VÀNG (255, 200, 0) cho tone-sur-tone với Hub!
    HubTitle.TextColor3 = Color3.fromRGB(255, 50, 50) 
    HubTitle.TextSize = 13 -- Hạ xuống 13 một tí cho vừa vặn, đỡ thô
    HubTitle.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = TopBar
    -- SỬA TẠI ĐÂY: Đẩy vị trí bắt đầu của thanh Tab lùi ra sau (từ pixel 275) để nhường chỗ cho Title dài
    TabContainer.Size = UDim2.new(1, -285, 1, 0)
    TabContainer.Position = UDim2.new(0, 275, 0, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.CanvasSize = UDim2.new(2, 0, 0, 0)
    TabContainer.ScrollBarThickness = 0


    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.Size = UDim2.new(1, -20, 1, -65)
    ContentContainer.Position = UDim2.new(0, 10, 0, 55)
    ContentContainer.BackgroundTransparency = 1

    -- Hệ thống Drag di chuyển Hub mượt mà
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = MainFrame.Position end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local Tabs = {}
    local firstTab = true

    function Tabs:CreateTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = TabContainer
        TabButton.Size = UDim2.new(0, 95, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        TabButton.Text = tabName
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabButton.TextSize = 12

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabButton

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Parent = ContentContainer
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0, 0, 2, 0)
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(255, 40, 40)

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = TabPage
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)

        if firstTab then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            firstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, page in pairs(ContentContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then page.Visible = false end
            end
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end
            TabPage.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 0), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        local Elements = {}

        -- CREATE BUTTON
        function Elements:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 38)
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button.Text = "   " .. text
            Button.Font = Enum.Font.GothamSemibold
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 13
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = TabPage

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Button

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 25, 25), TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)
            Button.MouseButton1Click:Connect(callback)
        end

        -- CREATE TOGGLE
        function Elements:CreateToggle(text, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 38)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ToggleFrame.Parent = TabPage

            local TFCorner = Instance.new("UICorner")
            TFCorner.CornerRadius = UDim.new(0, 6)
            TFCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
            ToggleLabel.Text = text
            ToggleLabel.Font = Enum.Font.GothamSemibold
            ToggleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            ToggleLabel.TextSize = 13
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Parent = ToggleFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 42, 0, 20)
            Switch.Position = UDim2.new(1, -55, 0.5, -10)
            Switch.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
            Switch.Text = ""
            Switch.Parent = ToggleFrame

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 14, 0, 14)
            Circle.Position = UDim2.new(0, 3, 0.5, -7)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = Switch

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = Circle

            local toggled = false
            Switch.MouseButton1Click:Connect(function()
                toggled = not toggled
                local targetX = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                local targetColor = toggled and Color3.fromRGB(0, 170, 85) or Color3.fromRGB(48, 48, 48)

                TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = targetX}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                
                callback(toggled)
            end)
        end

        -- CREATE DROPDOWN
        function Elements:CreateDropdown(text, list, callback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, -10, 0, 38)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = TabPage

            local DFCorner = Instance.new("UICorner")
            DFCorner.CornerRadius = UDim.new(0, 6)
            DFCorner.Parent = DropdownFrame

            local MainBtn = Instance.new("TextButton")
            MainBtn.Size = UDim2.new(1, 0, 0, 38)
            MainBtn.BackgroundTransparency = 1
            MainBtn.Text = "   " .. text .. "  ▼"
            MainBtn.Font = Enum.Font.GothamSemibold
            MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            MainBtn.TextSize = 13
            MainBtn.TextXAlignment = Enum.TextXAlignment.Left
            MainBtn.Parent = DropdownFrame

            local OptionLayout = Instance.new("UIListLayout")
            OptionLayout.Parent = DropdownFrame
            OptionLayout.Padding = UDim.new(0, 4)

            local expanded = false
            for _, option in pairs(list) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, -20, 0, 28)
                OptBtn.Position = UDim2.new(0, 10, 0, 0)
                OptBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
                OptBtn.Text = option
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextColor3 = Color3.fromRGB(190, 190, 190)
                OptBtn.TextSize = 12
                OptBtn.Parent = DropdownFrame

                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 5)
                OptCorner.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    MainBtn.Text = "   " .. text .. " : " .. option .. "  ▼"
                    expanded = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, 38)}):Play()
                    callback(option)
                end)
            end

            MainBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                local targetHeight = expanded and (38 + (#list * 32)) or 38
                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, targetHeight)}):Play()
            end)
        end

        -- CREATE BOX
        function Elements:CreateBox(placeholder, callback)
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Size = UDim2.new(1, -10, 0, 42)
            BoxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            BoxFrame.Parent = TabPage

            local BFCorner = Instance.new("UICorner")
            BFCorner.CornerRadius = UDim.new(0, 6)
            BFCorner.Parent = BoxFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, -20, 1, -10)
            TextBox.Position = UDim2.new(0, 10, 0, 5)
            TextBox.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            TextBox.PlaceholderText = placeholder
            TextBox.Text = ""
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            TextBox.TextSize = 13
            TextBox.Parent = BoxFrame

            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(0, 5)
            TBCorner.Parent = TextBox

            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then callback(TextBox.Text) end
            end)
        end

        -- CREATE LABEL
        function Elements:CreateLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 26)
            Label.BackgroundTransparency = 1
            Label.Text = "★ " .. text
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Color3.fromRGB(255, 60, 60)
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TabPage
        end

        return Elements
    end

    return Tabs
end


-- ====================================================================
-- TIẾN TRÌNH LUỒNG ĐỒNG BỘ: CHECK GAME 5S -> LOADING -> KEY SYSTEM
-- ====================================================================
-- ====================================================================
-- TIẾN TRÌNH LUỒNG ĐỒNG BỘ: CHECK GAME 5S -> LOADING -> KEY SYSTEM
-- ====================================================================
VerifyGameSupport(function()
    StartLoadingAnimation(function()
        StartKeySystem(function()
            
            -- Biến kiểm tra ID (Đồng bộ currentId hoặc PlaceId)
            local currentId = game.PlaceId
            
            -- Khởi tạo Hub chính sau khi vượt qua các lớp bảo mật thành công
            -- Tên Hub động sẽ tự thay đổi theo từng loại game cậu chơi!
            local HubTitle = "Troll Hub M.E.G v2.0"
            if currentId == 6516141723 or currentId == 6839171747 then
                HubTitle = "Troll Hub DOORS v1.0"
            elseif currentId == 88323040672117 then
                HubTitle = "Troll Hub Divaz v1.0"
            elseif currentId == 97598239454123 then
                HubTitle = "Troll Hub Grow a Garden 2 🏡"
            elseif currentId == 7577961216 or currentId == 7577981568 then
                HubTitle = "Troll Hub Squid Game X"
            end
            
            local MyHub = HubLib:CreateWindow(HubTitle, 14241061453) 
            local InfoTab -- Khai báo biến global trong luồng để dùng cho Footer Button

            -- ===============================================================================
            -- 1. LOCATION: M.E.G GAMEPLAY MAP
            -- ===============================================================================
            if currentId == 99078474560152 then
                local MainTab = MyHub:CreateTab("🏠 Home")
                local PlayerTab = MyHub:CreateTab("⚡ Player")
                local TrollTab = MyHub:CreateTab("🖥️ Troll")
                local ElevatorTab = MyHub:CreateTab("🚪 Elevator")
                local vibeTab = MyHub:CreateTab("📺 Visuals")
                InfoTab = MyHub:CreateTab("ℹ️ Info")

                local customSpeed = 16
                local speedConnection = nil

                PlayerTab:CreateBox("WalkSpeed Value (Default: 16)", function(value)
                    if tonumber(value) then customSpeed = tonumber(value) end
                end)

                PlayerTab:CreateToggle("Enable WalkSpeed", function(state)
                    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
                    if state then
                        speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
                            local char = LocalPlayer.Character
                            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if humanoid and hrp and humanoid.MoveDirection.Magnitude > 0 then
                                local setSpeed = (customSpeed - humanoid.WalkSpeed) / 100
                                hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * setSpeed)
                            end
                        end)
                    else
                        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
                    end
                end)

                PlayerTab:CreateToggle("Enable ESP Players", function(state)
                    _G.ESP = state
                    local function addESP(player)
                        if player == LocalPlayer then return end
                        local char = player.Character or player.CharacterAdded:Wait()
                        local hrp = char:WaitForChild("HumanoidRootPart", 5)
                        if hrp and _G.ESP then
                            if not hrp:FindFirstChild("GlassESP") then
                                local box = Instance.new("BoxHandleAdornment")
                                box.Name = "GlassESP"
                                box.Size = Vector3.new(4, 6, 4)
                                box.AlwaysOnTop = true
                                box.ZIndex = 5
                                box.Color3 = Color3.fromRGB(0, 120, 255)
                                box.Transparency = 0.5
                                box.Adornee = hrp
                                box.Parent = hrp
                            end
                        end
                    end

                    if state then
                        for _, p in pairs(Players:GetPlayers()) do
                            task.spawn(function() addESP(p) end)
                            p.CharacterAdded:Connect(function()
                                if _G.ESP then task.wait(0.5); addESP(p) end
                            end)
                        end
                        _G.PlayerAddedConnection = Players.PlayerAdded:Connect(function(newPlayer)
                            newPlayer.CharacterAdded:Connect(function()
                                if _G.ESP then task.wait(0.5); addESP(newPlayer) end
                            end)
                        end)
                    else
                        if _G.PlayerAddedConnection then _G.PlayerAddedConnection:Disconnect(); _G.PlayerAddedConnection = nil end
                        for _, p in pairs(Players:GetPlayers()) do
                            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local esp = p.Character.HumanoidRootPart:FindFirstChild("GlassESP")
                                if esp then esp:Destroy() end
                            end
                        end
                    end
                end)

                local currentFlySpeed = 50
                local flyActive = false
                local flyConnection = nil

                PlayerTab:CreateBox("Fly Speed Value (Default: 50)", function(value)
                    if tonumber(value) and tonumber(value) > 0 then currentFlySpeed = tonumber(value) end
                end)

                PlayerTab:CreateToggle("Enable Fly", function(state)
                    flyActive = state
                    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if not hrp or not humanoid then return end

                    if state then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "FlyVelocity"
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Velocity = Vector3.zero
                        bv.Parent = hrp

                        flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
                            if not flyActive or not char.Parent then return end
                            local moveDir = humanoid.MoveDirection
                            if moveDir.Magnitude > 0 then
                                bv.Velocity = moveDir.Unit * currentFlySpeed
                            else
                                bv.Velocity = Vector3.new(0, 0.1, 0)
                            end
                        end)
                    else
                        local old = hrp:FindFirstChild("FlyVelocity")
                        if old then old:Destroy() end
                    end
                end)

                local Lighting = game:GetService("Lighting")
                local oldAmbient = Lighting.Ambient
                local oldColorShift = Lighting.ColorShift_Top
                local oldBrightness = Lighting.Brightness
                local oldFogEnd = Lighting.FogEnd

                PlayerTab:CreateToggle("Enable Full Bright", function(state)
                    if state then
                        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
                        Lighting.Brightness = 2
                        Lighting.FogEnd = 9e9
                    else
                        Lighting.Ambient = oldAmbient; Lighting.ColorShift_Top = oldColorShift; Lighting.Brightness = oldBrightness; Lighting.FogEnd = oldFogEnd
                    end
                end)

                local godModeActive = false
                PlayerTab:CreateToggle("Enable God Mode", function(state)
                    godModeActive = state
                    if state then
                        task.spawn(function()
                            while godModeActive do
                                task.wait(0.1)
                                local char = LocalPlayer.Character
                                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                    local currentCFrame = char.HumanoidRootPart.CFrame
                                    local clone = humanoid:Clone()
                                    clone.Parent = char
                                    humanoid:Destroy()
                                    LocalPlayer.Character = char
                                    char.HumanoidRootPart.CFrame = currentCFrame
                                    workspace.CurrentCamera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
                                end
                            end
                        end)
                    else
                        local char = LocalPlayer.Character
                        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                        if humanoid then humanoid.Health = 0 end
                    end
                end)

                vibeTab:CreateButton("📺 Vintage 2018 Graphics", function()
                    pcall(function() Lighting.Technology = Enum.Technology.Voxel end)
                    Lighting.Brightness = 3; Lighting.GlobalShadows = true
                    Lighting.Ambient = Color3.fromRGB(140, 140, 140); Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                    for _, effect in pairs(Lighting:GetChildren()) do
                        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") then
                            effect.Enabled = false
                        end
                    end
                    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
                    if atm then atm.Parent = game:GetService("TestService") end
                    Lighting.FogEnd = 100000; Lighting.FogStart = 0
                end)

                vibeTab:CreateButton("🤖 Morph into Classic Noob", function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    for _, obj in pairs(char:GetChildren()) do
                        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("CharacterMesh") then obj:Destroy() end
                    end
                    if char:FindFirstChild("Torso") and char.Torso:FindFirstChildOfClass("Decal") then char.Torso:FindFirstChildOfClass("Decal"):Destroy() end
                    local function colorPart(partName, color)
                        local part = char:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then part.BrickColor = BrickColor.new(color); part.Color = BrickColor.new(color).Color end
                    end
                    colorPart("Head", "Bright yellow"); colorPart("Left Arm", "Bright yellow"); colorPart("Right Arm", "Bright yellow")
                    colorPart("Torso", "Bright blue")
                    colorPart("Left Leg", "Bright green"); colorPart("Right Leg", "Bright green")
                end)

                TrollTab:CreateButton("🖥️ Turn Off Active Computer", function()
                    ReplicatedStorage:WaitForChild("computerOff"):FireServer()
                end)

                TrollTab:CreateButton("🖥️ Turn On Computer Again", function()
                    ReplicatedStorage:WaitForChild("computerOn"):FireServer()
                end)

                TrollTab:CreateButton("🚪 Force Open Elevator Door", function()
                    ReplicatedStorage:WaitForChild("OpenElevator"):FireServer()
                end)

                ElevatorTab:CreateButton("⚡ Teleport to Elevator", function()
                    local elevator = workspace:FindFirstChild("Elevator")
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if elevator and hrp then
                        local targetPart = elevator:IsA("Model") and (elevator.PrimaryPart or elevator:FindFirstChildWhichIsA("BasePart")) or elevator
                        if targetPart then hrp.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0) end
                    end
                end)

                ElevatorTab:CreateButton("🧭 Locate Elevator (Show Compass)", function()
                    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
                    local compass = eventsFolder and eventsFolder:FindFirstChild("CompassEvent")
                    if compass then compass:FireServer(LocalPlayer, "Elevator") end
                end)

                ElevatorTab:CreateToggle("Enable Elevator ESP", function(state)
                    local elevator = workspace:FindFirstChild("Elevator") or workspace:FindFirstChild("ThangMáy")
                    if state then
                        if elevator and not elevator:FindFirstChild("TrollHub_ESP") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "TrollHub_ESP"
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
                            highlight.Parent = elevator
                        end
                    else
                        if elevator then
                            local esp = elevator:FindFirstChild("TrollHub_ESP")
                            if esp then esp:Destroy() end
                        end
                    end
                end)

                MainTab:CreateLabel("Features are fully operational! ESP, Troll, Speed, and Fly are active.")
                MainTab:CreateLabel("Note: Set speed config to 90 before exceeding the 90 limit.")
                
                InfoTab:CreateLabel("👑 Owner: Haianh-trollhub")
                InfoTab:CreateLabel("🚀 Version: Troll Hub M.E.G v2.0")
                InfoTab:CreateLabel("📅 Last Update: 15/06/2026")

            -- ===============================================================================
            -- 2. LOCATION: M.E.G LOBBY MAP
            -- ===============================================================================
            elseif currentId == 98629859043211 then
                local MainTab = MyHub:CreateTab("🏠 Lobby")
                InfoTab = MyHub:CreateTab("ℹ️ Info")

                MainTab:CreateLabel("📌 You are currently in the Lobby. Main gameplay features are hidden!")
                InfoTab:CreateLabel("👑 Owner: Haianh-trollhub")
                InfoTab:CreateLabel("🚀 Version: Troll Hub M.E.G v2.0")
                InfoTab:CreateLabel("📅 Last Update: 15/06/2026")

            -- ===============================================================================
            -- 3. LOCATION: DOORS GAME
            -- ===============================================================================
            elseif currentId == 6516141723 or currentId == 6839171747 then
                local MainTab = MyHub:CreateTab("🚪 DOORS Main")
                InfoTab = MyHub:CreateTab("ℹ️ Info")

                local brightConnection
                local originalAmbient = game:GetService("Lighting").Ambient

                MainTab:CreateToggle("Full Bright", function(state)
                    if state then
                        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
                        game:GetService("Lighting").Brightness = 2
                        brightConnection = game:GetService("Lighting").Changed:Connect(function()
                            if state then
                                game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
                                game:GetService("Lighting").Brightness = 2
                            end
                        end)
                    else
                        if brightConnection then brightConnection:Disconnect() end
                        game:GetService("Lighting").Ambient = originalAmbient
                        game:GetService("Lighting").Brightness = 1
                    end
                end)

                -- HÀM HỖ TRỢ ESP DOORS
                local function createESP(object, color, name)
                    if object:FindFirstChild("DoorsESP") then return end
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "DoorsESP"
                    highlight.FillColor = color
                    highlight.FillOpacity = 0.4
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineOpacity = 1
                    highlight.Adornee = object
                    highlight.Parent = object
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "DoorsText"
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.AlwaysOnTop = true
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.Adornee = object
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = name
                    textLabel.TextColor3 = color
                    textLabel.TextSize = 14
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.Parent = billboard
                    billboard.Parent = object
                end

                local function removeESP(object)
                    if object:FindFirstChild("DoorsESP") then object.DoorsESP:Destroy() end
                    if object:FindFirstChild("DoorsText") then object.DoorsText:Destroy() end
                end

                local doorESPActive = false
                task.spawn(function()
                    while task.wait(1) do
                        if doorESPActive then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj.Name == "Door" and obj:FindFirstChild("ClientDoor") then
                                    createESP(obj, Color3.fromRGB(0, 255, 0), "Cửa Đi Tiếp")
                                end
                            end
                        end
                    end
                end)

                MainTab:CreateToggle("ESP Cửa", function(state)
                    doorESPActive = state
                    if not state then
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj.Name == "Door" then removeESP(obj) end
                        end
                    end
                end)

                local closetESPActive = false
                task.spawn(function()
                    while task.wait(1) do
                        if closetESPActive then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj.Name == "Wardrobe" or obj.Name == "Closet" then
                                    createESP(obj, Color3.fromRGB(0, 162, 255), "Tủ Trốn")
                                end
                            end
                        end
                    end
                end)

                MainTab:CreateToggle("ESP Tủ Trốn", function(state)
                    closetESPActive = state
                    if not state then
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj.Name == "Wardrobe" or obj.Name == "Closet" then removeESP(obj) end
                        end
                    end
                end)

                local bookESPActive = false
                task.spawn(function()
                    while task.wait(1) do
                        if bookESPActive then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj.Name == "LiveHintBook" or (obj:IsA("Model") and obj.Name == "Book") then
                                    createESP(obj, Color3.fromRGB(255, 234, 0), "Sách Mật Mã")
                                end
                            end
                        end
                    end
                end)

                MainTab:CreateToggle("ESP Sách Phòng 50", function(state)
                    bookESPActive = state
                    if not state then
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj.Name == "LiveHintBook" or obj.Name == "Book" then removeESP(obj) end
                        end
                    end
                end)

                MainTab:CreateLabel("🚪 Successfully loaded into DOORS! Features are running perfectly.")
                InfoTab:CreateLabel("👑 Owner: Haianh-trollhub")
                InfoTab:CreateLabel("🚀 Version: Troll Hub DOORS v1.0")
                InfoTab:CreateLabel("📅 Last Update: 19/06/2026")

            -- ===============================================================================
            -- 4. LOCATION: DIVAZ GAME
            -- ===============================================================================
            elseif currentId == 88323040672117 then
                local mainTab = MyHub:CreateTab("⚡ Player")
                InfoTab = MyHub:CreateTab("ℹ️ Info")
                
                local customSpeed = 16
                local speedConnection = nil

                mainTab:CreateBox("WalkSpeed Value (Default: 16)", function(value)
                    if tonumber(value) then customSpeed = tonumber(value) end
                end)

                mainTab:CreateToggle("Enable WalkSpeed", function(state)
                    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
                    if state then
                        speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
                            local char = LocalPlayer.Character
                            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if humanoid and hrp and humanoid.MoveDirection.Magnitude > 0 then
                                local setSpeed = (customSpeed - humanoid.WalkSpeed) / 100
                                hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * setSpeed)
                            end
                        end)
                    else
                        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
                    end
                end)

                mainTab:CreateToggle("Enable ESP Players", function(state)
                    _G.ESP = state
                    local function addESP(player)
                        if player == LocalPlayer then return end
                        local char = player.Character or player.CharacterAdded:Wait()
                        local hrp = char:WaitForChild("HumanoidRootPart", 5)
                        if hrp and _G.ESP then
                            if not hrp:FindFirstChild("GlassESP") then
                                local box = Instance.new("BoxHandleAdornment")
                                box.Name = "GlassESP"
                                box.Size = Vector3.new(4, 6, 4)
                                box.AlwaysOnTop = true
                                box.ZIndex = 5
                                box.Color3 = Color3.fromRGB(0, 120, 255)
                                box.Transparency = 0.5
                                box.Adornee = hrp
                                box.Parent = hrp
                            end
                        end
                    end

                    if state then
                        for _, p in pairs(Players:GetPlayers()) do
                            task.spawn(function() addESP(p) end)
                            p.CharacterAdded:Connect(function()
                                if _G.ESP then task.wait(0.5); addESP(p) end
                            end)
                        end
                        _G.PlayerAddedConnection = Players.PlayerAdded:Connect(function(newPlayer)
                            newPlayer.CharacterAdded:Connect(function()
                                if _G.ESP then task.wait(0.5); addESP(newPlayer) end
                            end)
                        end)
                    else
                        if _G.PlayerAddedConnection then _G.PlayerAddedConnection:Disconnect(); _G.PlayerAddedConnection = nil end
                        for _, p in pairs(Players:GetPlayers()) do
                            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local esp = p.Character.HumanoidRootPart:FindFirstChild("GlassESP")
                                if esp then esp:Destroy() end
                            end
                        end
                    end
                end)

                local autoTeleport = false
                local targetPlayerName = nil

                -- Lấy danh sách người chơi thực tế nạp vào bảng dữ liệu
                local playerList = {}
                for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                    if p ~= LocalPlayer then table.insert(playerList, p.Name) end
                end

                mainTab:CreateDropdown("Select Player", playerList, function(targetName)
                    targetPlayerName = targetName 
                end)

                mainTab:CreateToggle("Enable Auto Teleport", function(state)
                    autoTeleport = state
                    if autoTeleport then
                        task.spawn(function()
                            while autoTeleport do
                                task.wait(0.1)
                                if targetPlayerName then
                                    local targetPlayer = game:GetService("Players"):FindFirstChild(targetPlayerName)
                                    local targetChar = targetPlayer and targetPlayer.Character
                                    local localChar = game:GetService("Players").LocalPlayer.Character
                                    if targetChar and localChar then
                                        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                                        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
                                        if targetHRP and localHRP then
                                            localHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 3, 0)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)

                InfoTab:CreateLabel("👑 Owner: Haianh-trollhub")
                InfoTab:CreateLabel("🚀 Version: Troll Hub Divaz v1.0")
                InfoTab:CreateLabel("📅 Last Update: 20/06/2026")

            -- ===============================================================================
            -- 5. LOCATION: GROW A GARDEN 2
            -- ===============================================================================
            elseif currentId == 97598239454123 then
                local MainTab = MyHub:CreateTab("Main")
                InfoTab = MyHub:CreateTab("Info")
                
                local autoSeedActive = false
                local farmLoop

                MainTab:CreateToggle("Auto Pick Gold Seed", function(state)
                    autoSeedActive = state
                    if state and not farmLoop then
                        farmLoop = task.spawn(function()
                            while autoSeedActive do
                                local pLayer = game:GetService("Players").LocalPlayer
                                local char = pLayer.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    for _, obj in ipairs(workspace:GetDescendants()) do
                                        if obj:IsA("Model") and (string.find(string.lower(obj.Name), "seed") and string.find(string.lower(obj.Name), "gold")) or obj.Name == "Gold Seed" then
                                            local targetPart = obj:FindFirstChild("HorizontalAlignment") or obj:FindFirstChildWhichIsA("BasePart")
                                            if targetPart then
                                                local oldCFrame = char.HumanoidRootPart.CFrame
                                                char.HumanoidRootPart.CFrame = targetPart.CFrame
                                                task.wait(0.05)
                                                char.HumanoidRootPart.CFrame = oldCFrame
                                                break 
                                            end
                                        end
                                    end
                                end
                                task.wait(0.1)
                            end
                            farmLoop = nil 
                        end)
                    end
                end)

                InfoTab:CreateLabel("👑 Owner: Haianh-trollhub")
                InfoTab:CreateLabel("🚀 Version: Troll Hub Grow a Garden 2 🏡 v1.0")
                InfoTab:CreateLabel("📅 Last Update: 20/06/2026")

            -- ===============================================================================
            -- 6. LOCATION: SQUID GAME X (LOBBY)
            -- ===============================================================================
            elseif currentId == 7577961216 then
                local MainTab = MyHub:CreateTab("🏠 Lobby")
                InfoTab = MyHub:CreateTab("ℹ️ Info")

                MainTab:CreateLabel("📌 You are currently in the Lobby. Main gameplay features are hidden!")
                InfoTab:CreateLabel("👑 Owner: Haianh-Trollhub")
                InfoTab:CreateLabel("🚀 Version: TROLL HUB SQUID GAME X (LOBBY) version1.0")
                InfoTab:CreateLabel("📅 Last Update: 21/06/2026")

            -- ===============================================================================
            -- 7. LOCATION: SQUID GAME X (GAMEPLAY)
            -- ===============================================================================
            elseif currentId == 7577981568 then
                local Tab1 = MyHub:CreateTab("Main")
                InfoTab = MyHub:CreateTab("Information")
                
                local customSpeed = 16
                local speedConnection = nil

                Tab1:CreateBox("WalkSpeed Value (Default: 16)", function(value)
                    if tonumber(value) then customSpeed = tonumber(value) end
                end)

                Tab1:CreateToggle("Enable WalkSpeed", function(state)
                    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
                    if state then
                        speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
                            local char = LocalPlayer.Character
                            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if humanoid and hrp and humanoid.MoveDirection.Magnitude > 0 then
                                local setSpeed = (customSpeed - humanoid.WalkSpeed) / 100
                                hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * setSpeed)
                            end
                        end)
                    else
                        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
                    end
                end)

                Tab1:CreateToggle("Enable ESP Players", function(state)
                    _G.ESP = state
                    local function addESP(player)
                        if player == LocalPlayer then return end
                        local char = player.Character or player.CharacterAdded:Wait()
                        local hrp = char:WaitForChild("HumanoidRootPart", 5)
                        if hrp and _G.ESP then
                            if not hrp:FindFirstChild("GlassESP") then
                                local box = Instance.new("BoxHandleAdornment")
                                box.Name = "GlassESP"
                                box.Size = Vector3.new(4, 6, 4)
                                box.AlwaysOnTop = true
                                box.ZIndex = 5
                                box.Color3 = Color3.fromRGB(0, 120, 255)
                                box.Transparency = 0.5
                                box.Adornee = hrp
                                box.Parent = hrp
                            end
                        end
                    end

                    if state then
                        for _, p in pairs(Players:GetPlayers()) do
                            task.spawn(function() addESP(p) end)
                            p.CharacterAdded:Connect(function()
                                if _G.ESP then task.wait(0.5); addESP(p) end
                            end)
                        end
                        _G.PlayerAddedConnection = Players.PlayerAdded:Connect(function(newPlayer)
                            newPlayer.CharacterAdded:Connect(function()
                                if _G.ESP then task.wait(0.5); addESP(newPlayer) end
                            end)
                        end)
                    else
                        if _G.PlayerAddedConnection then _G.PlayerAddedConnection:Disconnect(); _G.PlayerAddedConnection = nil end
                        for _, p in pairs(Players:GetPlayers()) do
                            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local esp = p.Character.HumanoidRootPart:FindFirstChild("GlassESP")
                                if esp then esp:Destroy() end
                            end
                        end
                    end
                end)

                InfoTab:CreateLabel("👑 Owner: Haianh-trollhub")
                InfoTab:CreateLabel("🚀 Version: TROLL HUB SQUID GAME X version 1.0")
                InfoTab:CreateLabel("📅 Last Update: 21/06/2026")

end

            if InfoTab then
                -- Thay thế sang hàm của UI Hub mới (Ví dụ dùng CreateButton để copy link)
                InfoTab:CreateButton("🔗 Copy Discord Invite", function()
                    if setclipboard then
                        setclipboard("https://discord.gg/QfjXycjQA")
                    end
                end)
            end

        end)
    end)
end)