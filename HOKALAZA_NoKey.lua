-- idk what i add in this new commit but i think i added plenty of it
-- i'm too cheap to buy an good obfuscator 
-- and most of the features is not completed yet soo
-- looks shit ik but idc atleast it work

getgenv().isfunctionhooked = isfunctionhooked or ishooked -- delta should be supported now

local eleriumremake = {}
function eleriumremake:DraggingEnabled(frame, parent)
	parent = parent or frame

	local gui = parent
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		game:GetService("TweenService"):Create(gui,TweenInfo.new(0.15), {
			Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		}):Play()
		--gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end
function eleriumremake.SetupUI(name, savecallback)

	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local MainCorner = Instance.new("UICorner")
	local TopBar = Instance.new("Frame")
	local TopbarCorner = Instance.new("UICorner")
	local TopbarCornerHide = Instance.new("Frame")
	local TopbarText = Instance.new("TextLabel")
	local TopbarHideButton = Instance.new("ImageButton")
	local TopbarSaveButton = Instance.new("ImageButton")
	local PageListLine = Instance.new("Frame")
	local PageList = Instance.new("Frame")
	local PageListScroll = Instance.new("ScrollingFrame")
	local PageListScrollLayout = Instance.new("UIListLayout")
	local PageContainer = Instance.new("Frame")


	ScreenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(21, 23, 22)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.ClipsDescendants = true
	Frame.Position = UDim2.new(0.222632244, 0, 0.171314746, 0)
	Frame.Size = UDim2.new(0, 440, 0, 310)

	MainCorner.Name = "MainCorner"
	MainCorner.Parent = Frame

	TopBar.Name = "TopBar"
	TopBar.Parent = Frame
	TopBar.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
	TopBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TopBar.BorderSizePixel = 0
	TopBar.Size = UDim2.new(0, 440, 0, 25)

	TopbarCorner.Name = "TopbarCorner"
	TopbarCorner.Parent = TopBar

	TopbarCornerHide.Name = "TopbarCornerHide"
	TopbarCornerHide.Parent = TopBar
	TopbarCornerHide.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
	TopbarCornerHide.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TopbarCornerHide.BorderSizePixel = 0
	TopbarCornerHide.Position = UDim2.new(0, 0, 0.75999999, 0)
	TopbarCornerHide.Size = UDim2.new(0, 450, 0, 6)

	TopbarText.Name = "TopbarText"
	TopbarText.Parent = TopBar
	TopbarText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TopbarText.BackgroundTransparency = 1.000
	TopbarText.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TopbarText.BorderSizePixel = 0
	TopbarText.Position = UDim2.new(0.0688888878, 0, 0.280000001, 0)
	TopbarText.Size = UDim2.new(0, 303, 0, 10)
	TopbarText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
	TopbarText.TextColor3 = Color3.fromRGB(255, 255, 255)
	TopbarText.TextSize = 14.000
	TopbarText.TextXAlignment = Enum.TextXAlignment.Left
	TopbarText.Text = name
    eleriumremake:DraggingEnabled(TopbarText, Frame)


	TopbarHideButton.Name = "TopbarHideButton"
	TopbarHideButton.Parent = TopBar
	TopbarHideButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TopbarHideButton.BackgroundTransparency = 1.000
	TopbarHideButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TopbarHideButton.BorderSizePixel = 0
	TopbarHideButton.Position = UDim2.new(0, 5, 0.0799999982, 0)
	TopbarHideButton.Rotation = 90.000
	TopbarHideButton.Size = UDim2.new(0, 20, 0, 20)
	TopbarHideButton.Image = "http://www.roblox.com/asset/?id=4731371527"

	TopbarSaveButton.Name = "TopbarSaveButton"
	TopbarSaveButton.Position = UDim2.new(0.948, 0,0.2, 0)
	TopbarSaveButton.BackgroundTransparency = 1
	TopbarSaveButton.Image = "rbxassetid://10734941499"
	TopbarSaveButton.Size = UDim2.fromOffset(15, 15)
	TopbarSaveButton.Parent = TopBar
	TopbarSaveButton.MouseButton1Click:Connect(function()
		savecallback()
	end)

	PageList.Name = "PageList"
	PageList.Parent = Frame
	PageList.BackgroundColor3 = Color3.fromRGB(37, 38, 40)
	PageList.BorderColor3 = Color3.fromRGB(0, 0, 0)
	PageList.BorderSizePixel = 0
	PageList.Position = UDim2.new(0.0219697431, 0, 0, 30)
	PageList.Size = UDim2.new(0, 420, 0, 30)

	PageListScroll.Name = "PageListScroll"
	PageListScroll.Parent = PageList
	PageListScroll.Active = true
	PageListScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	PageListScroll.BackgroundTransparency = 1.000
	PageListScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
	PageListScroll.BorderSizePixel = 0
	PageListScroll.Size = UDim2.new(0, 420, 0, 25)
	PageListScroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	PageListScroll.CanvasSize = UDim2.new(2, 0, 0, 0)
	PageListScroll.ScrollBarThickness = 0
	PageListScroll.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"

	PageListScrollLayout.Name = "PageListScrollLayout"
	PageListScrollLayout.Parent = PageListScroll
	PageListScrollLayout.FillDirection = Enum.FillDirection.Horizontal
	PageListScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
	PageListScrollLayout.Padding = UDim.new(0, 1)

	PageListLine.Name = "PageListLine"
	PageListLine.Parent = PageList
	PageListLine.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
	PageListLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
	PageListLine.BorderSizePixel = 0
	PageListLine.Position = UDim2.new(0, 0, 1, 0)
	PageListLine.Size = UDim2.new(0, 420, 0, 3)

	PageContainer.Name = "PageContainer"
	PageContainer.Parent = Frame
	PageContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	PageContainer.BackgroundTransparency = 1.000
	PageContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	PageContainer.BorderSizePixel = 0
	PageContainer.Position = UDim2.new(0.0204545446, 0, 0.225806445, 0)
	PageContainer.Size = UDim2.new(0, 420, 0, 240)

	local tweeninfong = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
	local minimized = false
	TopbarHideButton.MouseButton1Click:Connect(function()
		if minimized == false then
			minimized = true
			game:GetService("TweenService"):Create(Frame, tweeninfong, {Size = UDim2.fromOffset(440,25)}):Play()
			PageList.Visible = false
			PageContainer.Visible = false
		else
			minimized = false
			game:GetService("TweenService"):Create(Frame, tweeninfong, {Size = UDim2.fromOffset(440,310)}):Play()
			PageList.Visible = true
			PageContainer.Visible = true
		end
	end)

	local pages = {}
	function pages.NewPage(name)

		local PageButtonCorner = Instance.new("UICorner")
		local Main = Instance.new("TextButton")
		local Main_2 = Instance.new("ScrollingFrame")
		local PageListLayout = Instance.new("UIListLayout")

		Main.Name = name
		Main.Parent = PageListScroll
		Main.BackgroundColor3 = Color3.fromRGB(73, 75, 79)
		Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Main.BorderSizePixel = 0
		Main.Size = UDim2.new(0, 0, 0, 0)
		Main.AutoButtonColor = false
		Main.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
		Main.Text = name
		Main.TextColor3 = Color3.fromRGB(255, 255, 255)
		Main.TextSize = 14.000

		PageButtonCorner.CornerRadius = UDim.new(0, 3)
		PageButtonCorner.Name = "PageButtonCorner"
		PageButtonCorner.Parent = Main

		Main_2.Name = name
		Main_2.Parent = PageContainer
		Main_2.Active = true
		Main_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Main_2.BackgroundTransparency = 1.000
		Main_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Main_2.BorderSizePixel = 0
		Main_2.Size = UDim2.new(0, 420, 0, 240)
		Main_2.ScrollBarThickness = 0

		PageListLayout.Name = "PageListLayout"
		PageListLayout.Parent = Main_2
		PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageListLayout.Padding = UDim.new(0, 1)

		Main.Size = UDim2.fromOffset(Main.TextBounds.X + 15, 25)

        game:GetService("RunService").RenderStepped:Connect(function()
			Main_2.CanvasSize = UDim2.new(0,0,0,PageListLayout.AbsoluteContentSize.Y)
		end)

		local tabc = PageContainer
		local tabl = PageListScroll
		for i, v in next, tabl:GetChildren() do
			if v.ClassName == "TextButton" then
				v.MouseButton1Click:Connect(function()
					for i, v2 in next, tabc:GetChildren() do
						if v2.Name == v.Name then
							v2.Visible = true
							--v.BackgroundColor3 = Color3.fromRGB(62,62,62)
							--game:GetService("TweenService"):Create(v, TweenInfo.new(0.25,Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(v.AbsoluteSize.X, 30)})
						else
							v2.Visible = false

							--game:GetService("TweenService"):Create(v, TweenInfo.new(0.25,Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(v.AbsoluteSize.X, 25)})
							--v.BackrgoundColor3 = Color3.fromRGB(42,42,42)
						end
					end
				end)
			end
		end

		local sections = {}

		function sections.NewSection(name)

			local Section = Instance.new("Frame")
			local SectionShow = Instance.new("Frame")
			local SectionShowCorner = Instance.new("UICorner")
			local SectionShowMinimize = Instance.new("ImageButton")
			local SectionShowText = Instance.new("TextLabel")
			local SectionContent = Instance.new("Frame")
			local SectionContentLayout = Instance.new("UIListLayout")

			Section.Name = "Section"
			Section.Parent = Main_2
			Section.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
			Section.BackgroundTransparency = 1.000
			Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Section.BorderSizePixel = 0
			Section.Position = UDim2.new(3.63304515e-08, 0, 0, 0)
			Section.Size = UDim2.new(0, 420, 0, 25)

			SectionShow.Name = "SectionShow"
			SectionShow.Parent = Section
			SectionShow.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
			SectionShow.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionShow.BorderSizePixel = 0
			SectionShow.Size = UDim2.new(0, 420, 0, 25)

			SectionShowCorner.CornerRadius = UDim.new(0, 3)
			SectionShowCorner.Name = "SectionShowCorner"
			SectionShowCorner.Parent = SectionShow

			SectionShowMinimize.Name = "SectionShowMinimize"
			SectionShowMinimize.Parent = SectionShow
			SectionShowMinimize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionShowMinimize.BackgroundTransparency = 1.000
			SectionShowMinimize.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionShowMinimize.BorderSizePixel = 0
			SectionShowMinimize.Position = UDim2.new(0.938095212, 0, 0.0799999982, 0)
			SectionShowMinimize.Rotation = 90.000
			SectionShowMinimize.Size = UDim2.new(0, 20, 0, 20)
			SectionShowMinimize.Image = "http://www.roblox.com/asset/?id=4731371527"

			SectionShowText.Name = "SectionShowText"
			SectionShowText.Parent = SectionShow
			SectionShowText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionShowText.BackgroundTransparency = 1.000
			SectionShowText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionShowText.BorderSizePixel = 0
			SectionShowText.Position = UDim2.new(0.0190476198, 0, 0, 0)
			SectionShowText.Size = UDim2.new(0, 200, 0, 25)
			SectionShowText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			SectionShowText.Text = name
			SectionShowText.TextColor3 = Color3.fromRGB(255, 255, 255)
			SectionShowText.TextSize = 14.000
			SectionShowText.TextXAlignment = Enum.TextXAlignment.Left

			SectionContent.Name = "SectionContent"
			SectionContent.Parent = SectionShow
			SectionContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionContent.BackgroundTransparency = 0.990
			SectionContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionContent.BorderSizePixel = 0
			SectionContent.ClipsDescendants = true
			SectionContent.Position = UDim2.new(0, 8, 0, 28)
			SectionContent.Size = UDim2.new(0, 412, 0, 250)

			SectionContentLayout.Name = "SectionContentLayout"
			SectionContentLayout.Parent = SectionContent
			SectionContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SectionContentLayout.Padding = UDim.new(0, 2)

			game:GetService("TweenService"):Create(Section, tweeninfong, {Size = UDim2.fromOffset(420,25)}):Play()
			game:GetService("TweenService"):Create(SectionShow.SectionContent, tweeninfong, {Size = UDim2.fromOffset(420,0)}):Play()
			game:GetService("TweenService"):Create(SectionShow.SectionShowMinimize, tweeninfong, {Rotation = 0}):Play()

			local tweeninfong = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
			local opened = false
			SectionShow.SectionShowMinimize.MouseButton1Click:Connect(function()
				if opened == false then
					opened = true
					game:GetService("TweenService"):Create(Section, tweeninfong, {Size = UDim2.fromOffset(420,SectionContentLayout.AbsoluteContentSize.Y+30)}):Play()
					game:GetService("TweenService"):Create(SectionShow.SectionContent, tweeninfong, {Size = UDim2.fromOffset(420,SectionContentLayout.AbsoluteContentSize.Y)}):Play()
					game:GetService("TweenService"):Create(SectionShow.SectionShowMinimize, tweeninfong, {Rotation = 90}):Play()
				else
					opened = false
					game:GetService("TweenService"):Create(Section, tweeninfong, {Size = UDim2.fromOffset(420,25)}):Play()
					game:GetService("TweenService"):Create(SectionShow.SectionContent, tweeninfong, {Size = UDim2.fromOffset(420,0)}):Play()
					game:GetService("TweenService"):Create(SectionShow.SectionShowMinimize, tweeninfong, {Rotation = 0}):Play()
				end
			end)

			SectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if opened == true then
					game:GetService("TweenService"):Create(Section, tweeninfong, {Size = UDim2.fromOffset(420,SectionContentLayout.AbsoluteContentSize.Y+30)}):Play()
					game:GetService("TweenService"):Create(SectionShow.SectionContent, tweeninfong, {Size = UDim2.fromOffset(420,SectionContentLayout.AbsoluteContentSize.Y)}):Play()
				end
			end)

			local elemet= {}

			function elemet.NewToggle(name, callback, default)
				local default = default or false
				local Toggle = Instance.new("Frame")
				local ToggleTrigger = Instance.new("TextButton")
				local ButtonCorner = Instance.new("UICorner")
				local TextLabel = Instance.new("TextLabel")

				Toggle.Name = "Toggle"
				Toggle.Parent = SectionContent
				Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Toggle.BackgroundTransparency = 1.000
				Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Toggle.BorderSizePixel = 0
				Toggle.Position = UDim2.new(0.0294117648, 0, 0, 0)
				Toggle.Size = UDim2.new(0, 330, 0, 20)

				ToggleTrigger.Name = "ToggleTrigger"
				ToggleTrigger.Parent = Toggle
				ToggleTrigger.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
				ToggleTrigger.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ToggleTrigger.BorderSizePixel = 0
				ToggleTrigger.Position = UDim2.new(0, 0, -0.0199996941, 0)
				ToggleTrigger.Size = UDim2.new(0, 20, 0, 20)
				ToggleTrigger.AutoButtonColor = false
				ToggleTrigger.Font = Enum.Font.SourceSansSemibold
				ToggleTrigger.Text = ""
				ToggleTrigger.TextColor3 = Color3.fromRGB(255, 255, 255)
				ToggleTrigger.TextSize = 16.000

				ButtonCorner.CornerRadius = UDim.new(0, 4)
				ButtonCorner.Name = "ButtonCorner"
				ButtonCorner.Parent = ToggleTrigger

				TextLabel.Parent = Toggle
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.BackgroundTransparency = 0.990
				TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel.BorderSizePixel = 0
				TextLabel.Position = UDim2.new(0.0787878782, 0, -0.0199996941, 0)
				TextLabel.Size = UDim2.new(0, 100, 0, 20)
				TextLabel.Font = Enum.Font.SourceSans
				TextLabel.Text = name
				TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.TextSize = 14.00
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left

				local toggled = false

				if default == true then
					toggled = true
					ToggleTrigger.Text = utf8.char(10003)
					callback(toggled)
				else
					toggled = false
					ToggleTrigger.Text = ""
					callback(toggled)
				end

				ToggleTrigger.MouseButton1Click:Connect(function()
					if toggled == false then
						toggled = true
						ToggleTrigger.Text = utf8.char(10003)
						callback(toggled)
					else
						toggled = false
						ToggleTrigger.Text = ""
						callback(toggled)
					end
				end)

				local tog = {}
				function tog.SetState(boolean)
					if boolean == true then
						toggled = true
						ToggleTrigger.Text = utf8.char(10003)
						callback(toggled)
					else
						toggled = false
						ToggleTrigger.Text = ""
						callback(toggled)
					end
				end

				return tog

			end

			function elemet.NewButton(name,callback)
				local Button = Instance.new("Frame")
				local ButtonText = Instance.new("TextButton")
				local ButtonCorner_2 = Instance.new("UICorner")

				Button.Name = "Button"
				Button.Parent = SectionContent
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Button.BackgroundTransparency = 0.990
				Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Button.BorderSizePixel = 0
				Button.Position = UDim2.new(0.0294117648, 0, 0, 0)
				Button.Size = UDim2.new(0, 330, 0, 25)

				ButtonText.Name = "ButtonText"
				ButtonText.Parent = Button
				ButtonText.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
				ButtonText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ButtonText.BorderSizePixel = 0
				ButtonText.Position = UDim2.new(0, 0, 0.0799999982, 0)
				ButtonText.Size = UDim2.new(0, 58, 0, 20)
				ButtonText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
				ButtonText.Text = name
				ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
				ButtonText.TextSize = 12.000
				ButtonText.AutoButtonColor = false

				ButtonCorner_2.CornerRadius = UDim.new(0, 4)
				ButtonCorner_2.Name = "ButtonCorner"
				ButtonCorner_2.Parent = ButtonText



				game:GetService("RunService").RenderStepped:Connect(function()
					ButtonText.Size = UDim2.fromOffset(ButtonText.TextBounds.X + 10, 20)
				end)
				ButtonText.MouseButton1Click:Connect(function()
					callback()
				end)

			end

			function elemet.NewSlider(name, min, max, default, precise, callback)
				local precise = precise or false
				local Slider = Instance.new("Frame")
				local SliderMain = Instance.new("TextButton")
				local SliderMainCorner = Instance.new("UICorner")
				local SliderFill = Instance.new("Frame")
				local SliderFillCorner = Instance.new("UICorner")
				local SliderText = Instance.new("TextLabel")
				local SliderValue = Instance.new("TextLabel")

				Slider.Name = "Slider"
				Slider.Parent = SectionContent
				Slider.AnchorPoint = Vector2.new(0.5, 0.5)
				Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Slider.BackgroundTransparency = 0.990
				Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Slider.BorderSizePixel = 0
				Slider.Position = UDim2.new(0.485436887, 0, 0.51592356, 0)
				Slider.Size = UDim2.new(0, 400, 0, 20)

				SliderMain.Name = "SliderMain"
				SliderMain.Parent = Slider
				SliderMain.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
				SliderMain.BorderColor3 = Color3.fromRGB(0, 0, 0)
				SliderMain.BorderSizePixel = 0
				SliderMain.ClipsDescendants = true
				SliderMain.Position = UDim2.new(0, 0, -0.00198059087, 0)
				SliderMain.Size = UDim2.new(0, 400, 0, 20)
				SliderMain.AutoButtonColor = false
				SliderMain.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
				SliderMain.Text = ""
				SliderMain.TextColor3 = Color3.fromRGB(255, 255, 255)
				SliderMain.TextSize = 12.000

				SliderMainCorner.CornerRadius = UDim.new(0, 4)
				SliderMainCorner.Name = "SliderMainCorner"
				SliderMainCorner.Parent = SliderMain

				SliderFill.Name = "SliderFill"
				SliderFill.Parent = SliderMain
				SliderFill.BackgroundColor3 = Color3.fromRGB(76, 76, 76)
				SliderFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
				SliderFill.BorderSizePixel = 0
				SliderFill.Position = UDim2.new(-2.7743252e-07, 0, 0, 0)
				SliderFill.Size = UDim2.new(0, 0, 0, 20)

				SliderFillCorner.CornerRadius = UDim.new(0, 4)
				SliderFillCorner.Name = "SliderFillCorner"
				SliderFillCorner.Parent = SliderFill

				SliderText.Name = "SliderText"
				SliderText.Parent = SliderMain
				SliderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SliderText.BackgroundTransparency = 1.000
				SliderText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				SliderText.BorderSizePixel = 0
				SliderText.Position = UDim2.new(3.81469718e-08, 0, 0, 0)
				SliderText.Size = UDim2.new(0, 400, 0, 20)
				SliderText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
				SliderText.Text = name
				SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
				SliderText.TextSize = 12.000

				SliderValue.Name = "SliderValue"
				SliderValue.Parent = SliderText
				SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SliderValue.BackgroundTransparency = 1.000
				SliderValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
				SliderValue.BorderSizePixel = 0
				SliderValue.Position = UDim2.new(0.934546947, 0, 0, 0)
				SliderValue.Size = UDim2.new(0, 20, 0, 20)
				SliderValue.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
				SliderValue.Text = "100"
				SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
				SliderValue.TextSize = 12.000
				SliderValue.TextXAlignment = Enum.TextXAlignment.Right

				local mouse = game:GetService("Players").LocalPlayer:GetMouse()
				local uis = game:GetService("UserInputService")
				local Min_Value = min
				local Max_Value = max
				local Precise = precise
				local Bar = SliderMain.SliderFill
				local Sliderbox = SliderMain.SliderText.SliderValue
				local Trigger = SliderMain
				local SizeChia = 400
				local DefaultValue = default

				if DefaultValue then 
					if DefaultValue <= Min_Value then DefaultValue = Min_Value elseif DefaultValue >= Max_Value then DefaultValue = Max_Value end
					Bar.Size = UDim2.new(1 - ((Max_Value - DefaultValue) / (Max_Value - Min_Value)),0, 0, 20)
					Sliderbox.Text = DefaultValue
					callback(DefaultValue)
				end

				Trigger.MouseButton1Down:Connect(function()
					isSliding = true
					local value = Precise and  tonumber(string.format("%.1f",(((tonumber(Max_Value) - tonumber(Min_Value)) / SizeChia) * Bar.AbsoluteSize.X) + tonumber(Min_Value))) or math.floor((((tonumber(Max_Value) - tonumber(Min_Value)) / SizeChia) * Bar.AbsoluteSize.X) + tonumber(Min_Value))

					pcall(function()
						callback(value)
						Sliderbox.Text = value
					end)
					Bar.Size = UDim2.new(0, math.clamp(mouse.X - Bar.AbsolutePosition.X, 0, SizeChia), 0, 20)
					moveconnection = mouse.Move:Connect(function()   
						local value = Precise and  tonumber(string.format("%.1f",(((tonumber(Max_Value) - tonumber(Min_Value)) / SizeChia) * Bar.AbsoluteSize.X) + tonumber(Min_Value))) or math.floor((((tonumber(Max_Value) - tonumber(Min_Value)) / SizeChia) * Bar.AbsoluteSize.X) + tonumber(Min_Value))
						pcall(function()
							callback(value)
							Sliderbox.Text = value
						end)
						Bar.Size = UDim2.new(0, math.clamp(mouse.X - Bar.AbsolutePosition.X, 0, SizeChia), 0, 20)
					end)
					releaseconnection = uis.InputEnded:Connect(function(Mouse)
						if Mouse.UserInputType == Enum.UserInputType.MouseButton1 or Mouse.UserInputType == Enum.UserInputType.Touch then
							local value = Precise and  tonumber(string.format("%.1f",(((tonumber(Max_Value) - tonumber(Min_Value)) / SizeChia) * Bar.AbsoluteSize.X) + tonumber(Min_Value))) or math.floor((((tonumber(Max_Value) - tonumber(Min_Value)) / SizeChia) * Bar.AbsoluteSize.X) + tonumber(Min_Value))

							pcall(function()
								callback(value)
								Sliderbox.Text = value
							end)
							Bar.Size = UDim2.new(0, math.clamp(mouse.X - Bar.AbsolutePosition.X, 0, SizeChia), 0, 20)
						end
					end)
					uis.InputEnded:Connect(function(Mouse)
						if Mouse.UserInputType == Enum.UserInputType.MouseButton1 or Mouse.UserInputType == Enum.UserInputType.Touch then
							moveconnection:Disconnect()
							releaseconnection:Disconnect()
							isSliding = false
						end
					end)
				end)
			end

			function elemet.NewInformation(name,description)
				local Information = Instance.new("Frame")
				local InformationCorner = Instance.new("UICorner")
				local InformationImage = Instance.new("ImageLabel")
				local InformationText = Instance.new("TextLabel")
				local InformationDescription = Instance.new("TextLabel")
				local InformationFunctions = Instance.new("Frame")
				local InformationListLayout = Instance.new("UIListLayout")


				Information.Name = "Information"
				Information.Parent = SectionContent
				Information.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
				Information.BackgroundTransparency = 0.500
				Information.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Information.BorderSizePixel = 0
				Information.Position = UDim2.new(0, 0, 0.508000016, 0)
				Information.Size = UDim2.new(0, 280, 0, 70)

				InformationCorner.CornerRadius = UDim.new(0, 4)
				InformationCorner.Name = "InformationCorner"
				InformationCorner.Parent = Information

				InformationImage.Name = "InformationImage"
				InformationImage.Parent = Information
				InformationImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				InformationImage.BackgroundTransparency = 0.990
				InformationImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
				InformationImage.BorderSizePixel = 0
				InformationImage.Position = UDim2.new(0.0199999996, 0, 0.0833333358, 0)
				InformationImage.Size = UDim2.new(0, 50, 0, 50)
				InformationImage.Image = "https://www.roblox.com/bust-thumbnail/image?userId=5031712282&width=420&height=420&format=png"

				InformationText.Name = "InformationText"
				InformationText.Parent = Information
				InformationText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				InformationText.BackgroundTransparency = 1.000
				InformationText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				InformationText.BorderSizePixel = 0
				InformationText.Position = UDim2.new(0.22857143, 0, 0.0666666701, 0)
				InformationText.Size = UDim2.new(0, 206, 0, 15)
				InformationText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
				InformationText.Text = name
				InformationText.TextColor3 = Color3.fromRGB(255, 255, 255)
				InformationText.TextSize = 14.000
				InformationText.TextXAlignment = Enum.TextXAlignment.Left

				InformationDescription.Name = "InformationDescription"
				InformationDescription.Parent = Information
				InformationDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				InformationDescription.BackgroundTransparency = 1.000
				InformationDescription.BorderColor3 = Color3.fromRGB(0, 0, 0)
				InformationDescription.BorderSizePixel = 0
				InformationDescription.Position = UDim2.new(0.22857143, 0, 0.316666514, 0)
				InformationDescription.Size = UDim2.new(0, 150, 0, 26)
				InformationDescription.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
				InformationDescription.Text = description
				InformationDescription.TextColor3 = Color3.fromRGB(201, 201, 201)
				InformationDescription.TextSize = 12.000
				InformationDescription.TextXAlignment = Enum.TextXAlignment.Left
				InformationDescription.TextYAlignment = Enum.TextYAlignment.Top

				InformationFunctions.Name = "InformationFunctions"
				InformationFunctions.Parent = Information
				InformationFunctions.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				InformationFunctions.BackgroundTransparency = 1.000
				InformationFunctions.BorderColor3 = Color3.fromRGB(0, 0, 0)
				InformationFunctions.BorderSizePixel = 0
				InformationFunctions.Position = UDim2.new(0.22857143, 0, 0.685714304, 0)
				InformationFunctions.Size = UDim2.new(0, 206, 0, 20)

				InformationListLayout.Name = "InformationListLayout"
				InformationListLayout.Parent = InformationFunctions
				InformationListLayout.FillDirection = Enum.FillDirection.Horizontal
				InformationListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				InformationListLayout.Padding = UDim.new(0, 1)
			end

			function elemet.NewLabel(txt)
				local Label = Instance.new("Frame")
				local LabelText_2 = Instance.new("TextButton")

				Label.Name = "Label"
				Label.Parent = SectionContent
				Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Label.BackgroundTransparency = 1.000
				Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Label.BorderSizePixel = 0
				Label.Position = UDim2.new(0, 0, 0.732484102, 0)
				Label.Size = UDim2.new(0, 400, 0, 15)

				LabelText_2.Name = "LabelText"
				LabelText_2.Parent = Label
				LabelText_2.BackgroundColor3 = Color3.fromRGB(41, 74, 122)
				LabelText_2.BackgroundTransparency = 1.000
				LabelText_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				LabelText_2.BorderSizePixel = 0
				LabelText_2.Position = UDim2.new(0, 2, 0.0329999998, 0)
				LabelText_2.Size = UDim2.new(0, 58, 0, 15)
				LabelText_2.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
				LabelText_2.Text = txt
				LabelText_2.TextColor3 = Color3.fromRGB(255, 255, 255)
				LabelText_2.TextSize = 13.000
				LabelText_2.TextXAlignment = Enum.TextXAlignment.Left

			end

			return elemet

		end
		return sections
	end
	return pages
end

--[[
ui example:


local page = ui.NewPage("awo")
local section = page.NewSection("sections")
sec.NewToggle("ahahaha", function(a)
	print(a)
end, false)
toggle.SetState(true)

section.NewButton("Buttopntest", function()
	print("aaoijudfskdsf")
end)

sec.NewSlider("isdfdfsf", 0, 10, 5, true, function(a)
	print(a)
end)
local section = page.NewSection("sections")
local toggle = section.NewToggle("ahahaha", function(a)
	print(a)
end)
--]]
--game:GetService("ReplicatedStorage"):WaitForChild("SpawnSelectionUpdateSpawnData"):FireServer()
getgenv().debugOutput = false
local key, jbremote = loadstring(game:HttpGet('https://raw.githubusercontent.com/Introvert1337/RobloxReleases/refs/heads/main/Scripts/Jailbreak/KeyFetcher.lua'))() -- credits to introvert1337 for realesing this epic key fetcher!!!
local oldjbremote = getupvalue(network.FireServer, 1)
configs = {
    player = {
		walktog = false;
		walkval = 0;
		infjump = false;
		autoescape = false;
		nofall = false;
		norag = false;
		noislow = false;
		nosky = false;
		nostun = false;
		norwait = false;
		nocslow = false;
		nocircwait = false;
		nopwait = false;
		bypasskd = false;
		alwayssilentp = false;
		alwaysp = false;
		juiced = false;
		crawlequip = false;
		backbone = false;
	};
    vehicle = {
		fspeed = 10;
		ftog = false;
		fx = 0;
		fy = 0;
		fz = 0; 
		engine = false;
		enginesp = 0;
		brake = false;
		brakesp = 0;
		suspension = false;
		suspensionhe = 0;
		turnsp = 0;
		turn = false;
		tirepop = false;
		infnitro = false;
		rinfnitro = false;
		autoflip = false;
		helibreak = false;
		helienginesp = 0;
		heliengine = false;
		heliheight = false;
		instanttow = false;
		driveonwater = false;
	};
    combat = {
		hitboxradius = 3;
		noequipt = false;
		nospread = false;
		norecoil = false;
		nobulletg = false;
		alwaysauto = false;
		alwaysheadshot = false;
		pistolswat = false;
		snipernoblur = false;
		snipernogui = false;
		wallbang = false;
		nogrenadesmoke = false;
		tasermodz = false;
		instantrocketseek = false;
		forcefieldnomiss = false;
		increasetakedowndamage = false;
		increaseforcedamage = false;
		silentaim = {
			enabled = false;
			includetaser = false;
			includeplasma = false;
			radius = 250;
			wallcheck = false;
			fovcirc = false;
			fovthick = 5;
			fovtransp = 0;
		};
		arrestaura = {
			enabled = false;
		};
		batonsword = {
			noreloadtime = false;
			spamlunge = false;
			spamswoosh = false;
		};
	};
    teleportation = {}; -- soon not yet lmfao
    robberies = {
		guardnodmg = false;
	};
    nametags = {};
}
local client = {
	ropedata = {};
	lastvehiclestats = {
		GarageEngineSpeed = nil;
		Height = nil;
		TurnSpeed = nil;
	};
	lastvehiclemodel = nil;
	vehicleEntered = false;
	originalequippeddata = {};
	doorAddedFunction = getconnections(game:GetService"CollectionService":GetInstanceAddedSignal("Door"))[1].Function;
	remoteid = {
		punch = key.Punch;
		taser = key.Taze; 
	};
	activeaction = {};
	ori = {
		updateseeking = require(game:GetService("ReplicatedStorage").VehicleLink.VehicleLinkBinder)._constructor._updateSeeking;
		hittargetwithspeed = require(game:GetService("ReplicatedStorage").Module.SimulatedPhysicsProjectile).HitTargetWithSpeed;
		isflying = require(game:GetService("ReplicatedStorage").Game.Paraglide).IsFlying;
		tase = require(game:GetService("ReplicatedStorage").Game.Item.Taser).Tase;
		doesplayerowncached = require(game:GetService("ReplicatedStorage").Game.Gamepass.GamepassSystem).doesPlayerOwnCached;
		update = require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Update;
		getequiptime = require(game:GetService("ReplicatedStorage").Game.GunShop.GunUtils).getEquipTime;
		rayignorenon = require(game:GetService("ReplicatedStorage").Module.RayCast).RayIgnoreNonCollide;
		plasmashootother = require(game:GetService("ReplicatedStorage").Game.Item.PlasmaGun).ShootOther;
		pistolsetupmodel = require(game:GetService("ReplicatedStorage").Game.Item.Pistol).SetupModel;
		rayignore = require(game:GetService("ReplicatedStorage").Module.RayCast).RayIgnoreNonCollideWithIgnoreList;
		shoot = require(game:GetService("ReplicatedStorage").Game.Item.Gun).Shoot;
		attemptToggleCrawling = getupvalue(require(game:GetService("ReplicatedStorage").Game.DefaultActions).crawlButton.onPressed,1).attemptToggleCrawling;
	};
	guardnpcbinder = require(game:GetService("ReplicatedStorage").GuardNPC.GuardNPCBinder);
	combatconst = require(game:GetService("ReplicatedStorage").Combat.CombatConsts);
	combatutils = require(game:GetService("ReplicatedStorage").Combat.CombatUtils);
	playerutil = require(game:GetService("ReplicatedStorage").Game.PlayerUtils);
	actionbuttonservice = require(game:GetService("ReplicatedStorage").ActionButton.ActionButtonService);
	settingss = require(game:GetService("ReplicatedStorage").Resource.Settings);
	characterutil = require(game:GetService("ReplicatedStorage").Game.CharacterUtil);
	paraglide = require(game:GetService("ReplicatedStorage").Game.Paraglide);
	alexchassis = require(game:GetService("ReplicatedStorage").Module.AlexChassis);
	itemgun = require(game:GetService("ReplicatedStorage").Game.Item.Gun);
	itemsys = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem);
	gunutil = require(game:GetService("ReplicatedStorage").Game.GunShop.GunUtils);
	gamepasssystem = require(game:GetService("ReplicatedStorage").Game.Gamepass.GamepassSystem);
	pistolitem = require(game:GetService("ReplicatedStorage").Game.Item.Pistol);
	smokegrenadeitem = require(game:GetService("ReplicatedStorage").Game.SmokeGrenade.SmokeGrenade);
	circleac = require(game:GetService("ReplicatedStorage").Module.UI).CircleAction;
	tase = require(game:GetService("ReplicatedStorage").Game.Item.Taser);
	plasmagun = require(game:GetService("ReplicatedStorage").Game.Item.PlasmaGun);
	duck = require(game:GetService("ReplicatedStorage").Game.Robbery.TombRobbery.TombRobberySystem).duck;
	onvehicleentered = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).OnVehicleEntered;
	onvehicleexited = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).OnVehicleExited;
	onlocalitemequipped = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem).OnLocalItemEquipped;
	onlocalitemunequipped = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem).OnLocalItemUnequipped;
	bulletonlocalhitplayer = require(game:GetService("ReplicatedStorage").Game.Item.Gun).BulletEmitterOnLocalHitPlayer;
	vehiclelinkbinder = require(game:GetService("ReplicatedStorage").VehicleLink.VehicleLinkBinder);
	raycast = require(game:GetService("ReplicatedStorage").Module.RayCast);
}
client.door = {
	openDoor = getupvalue(getproto(getupvalue(client.doorAddedFunction, 2), 1, true)[1], 7);
	doors = getupvalue(client.doorAddedFunction, 1);
}
client.hittargetwithspeed = require(game:GetService("ReplicatedStorage").Module.SimulatedPhysicsProjectile).HitTargetWithSpeed


local itemConfigClone = game:GetService("ReplicatedStorage").Game.ItemConfig:Clone()
itemConfigClone.Name = "ItemConfigBackup"

getgenv().Circle = Drawing.new("Circle")
Circle.Color = Color3.new(1,1,1)
Circle.Thickness = configs.combat.silentaim.fovthick
Circle.Radius = configs.combat.silentaim.radius
Circle.Visible = configs.combat.silentaim.fovcirc
Circle.NumSides = 100
Circle.Filled = false
Circle.Transparency = configs.combat.silentaim.fovtransp
--Circle.Visible = true

for i,v in next, getgc() do 
	if type(v) == "function" and islclosure(v) then
		if tostring(getfenv(v).script) == "LocalScript" then
			local infoname = tostring(getinfo(v).name) 
			if getconstants(v)[3] == "StartRagdolling" then
				client.stunnedragdoll = v
			end
			if infoname == "AttemptArrest" then 
				client.attemptarrest = v
			end
			if infoname == "StartNitro" then
				client.startnitro = v
				client.nitro = getupvalue(v, 8)
			end
			if infoname == "StopNitro" then
				client.stopnitro = v
			end
			if infoname:find("CheatCheck") then -- shit didn't work
				hookfunction(v, function()  end)
			end
		end
	end
end

for i,v in next, getconnections(game:GetService("RunService").Heartbeat) do
    if v.Function and islclosure(v.Function) then
        if getconstants(v.Function)[13] == "Time/UI" then
            client.walkspeedfun = getupvalue(v.Function,6)
        end
		if getconstants(v.Function)[3] == "Vehicle Heartbeat" then
			client.heli = getupvalue(v.Function,1).Heli
			client.ori.heliupdate = client.heli.Update
		end
    end
end

for i,v in next, client.actionbuttonservice.active do
	if table.find(v.keyCodes, Enum.KeyCode.V) then
		client.activeaction.flip = v
	end
	if table.find(v.keyCodes, Enum.KeyCode.LeftControl) then
		client.activeaction.roll = v
	end
end

client.punchCorrection = (function() -- useless tbh since punching very fast can get you detected
	--getupvalues(getupvalue(require(game:GetService("ReplicatedStorage").Game.DefaultActions).punchButton.onPressed,1).attemptPunch)[6]:FireServer((getconstant(getupvalue(require(game:GetService("ReplicatedStorage").Game.DefaultActions).punchButton.onPressed,1).attemptPunch, 16)))
	repeat 
		if configs.player.alwayssilentp == true then
			task.wait(0.5)
			getupvalue(require(game:GetService("ReplicatedStorage").Game.DefaultActions).punchButton.onPressed,1).attemptPunch()
		else
			task.wait(0.3)
			jbremote:FireServer(client.remoteid.punch)
		end
	until configs.player.alwaysp == false
end)
client.duckCorrection = (function()
	repeat 
		client.duck()
		task.wait(2)
	until configs.player.backbone == false
end)
-- client.heliSpeedCorrection = (function(vehiclepacket) 
-- 	repeat task.wait()
-- 		if vehiclepacket and vehiclepacket.Velocity then
-- 			vehiclepacket.Velocity.Velocity = vehiclepacket.Velocity.Velocity * configs.vehicle.helienginesp
-- 		end
-- 	until configs.vehicle.heliengine == false 
-- end)
client.flipCorrection = (function()
	repeat task.wait(.1)
		pcall(function()
			for i,v in next, client.actionbuttonservice.active do
				if table.find(v.keyCodes, Enum.KeyCode.V) then
					v.onPressed(true)
				end
			end
		end)
	until configs.vehicle.autoflip == false
end)
-- lowkey i hate how hookfunction looks
client.hasKeyCorrection = (function(boolean)
	if boolean then
		hookfunction(client.playerutil.hasKey, function()
			return true
		end)
	else
		if isfunctionhooked(client.playerutil.hasKey) then restorefunction(client.playerutil.hasKey) end
	end
end)
client.headshotCorrection = (function(boolean)
	if boolean then
		epichook = hookfunction(client.bulletonlocalhitplayer, function(...)
			local bulletshot = {...}
			bulletshot[15].isWallbang = false
			bulletshot[15].isHeadshot = true
			return epichook(...)
		end)
	else
		if isfunctionhooked(client.bulletonlocalhitplayer) then restorefunction(client.bulletonlocalhitplayer) end
	end
end)
client.smokeGrenadeHook = (function(boolean)
	if boolean then
		hookfunction(client.smokegrenadeitem._playExplosionFx, function() end)
	else
		if isfunctionhooked(client.smokegrenadeitem._playExplosionFx) then restorefunction(client.smokegrenadeitem._playExplosionFx) end
	end
end)
client.isCrawlingCorrection = (function()
	repeat task.wait(.1)
		client.characterutil.IsCrawling = false
	until configs.player.crawlequip == false
end)

client.nitroCorrection = (function()
	repeat task.wait()
		client.nitro.NitroLastMax = 250
		client.nitro.Nitro = configs.vehicle.rinfnitro and math.random(10, 249) or 249
		client.nitro.NitroForceUIUpdate = true
	until configs.vehicle.infnitro == false
end)
client.launchVehicleFlight = (function()
	local BodyGyro = Instance.new("BodyGyro", game:GetService("Players").LocalPlayer.Character.HumanoidRootPart)
	local BodyVelocity = Instance.new("BodyVelocity", game:GetService("Players").LocalPlayer.Character.HumanoidRootPart)
	local UIS = game:GetService("UserInputService")
	local Camera = workspace.CurrentCamera
	BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.D = 50000
	BodyGyro.P = 1500000000
	-- game:GetService("RunService").Heartbeat:Connect(function()
	-- 	BodyGyro.CFrame = Camera.CFrame * CFrame.Angles(math.rad(configs.vehicle.fx), math.rad(configs.vehicle.fy), math.rad(configs.vehicle.fz))
	-- end)
	repeat task.wait()
		BodyGyro.CFrame = Camera.CFrame * CFrame.Angles(math.rad(configs.vehicle.fx), math.rad(configs.vehicle.fy), math.rad(configs.vehicle.fz))
		workspace.CurrentCamera.CameraType = Enum.CameraType.Track
		BodyVelocity.Velocity = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then
			BodyVelocity.Velocity = BodyVelocity.Velocity + Camera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.A) then
			BodyVelocity.Velocity = BodyVelocity.Velocity - Camera.CFrame.RightVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.S) then
			BodyVelocity.Velocity = BodyVelocity.Velocity - Camera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.D) then
			BodyVelocity.Velocity = BodyVelocity.Velocity + Camera.CFrame.RightVector
		end
		BodyVelocity.Velocity = BodyVelocity.Velocity * configs.vehicle.fspeed
	until client.vehicleEntered == false or configs.vehicle.ftog == false
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	BodyGyro:Destroy()
	BodyVelocity:Destroy()
end)
client.getOldWeaponData = (function(name, dataname)
	return rawget(require(itemConfigClone[name]), dataname)
end)
client.setBatonSwordTime = (function(bool)
	local baton = require(game:GetService("ReplicatedStorage").Game.Item.Baton)
	local sword = require(game:GetService("ReplicatedStorage").Game.Item.Sword)
	getupvalue(baton.new,2).ReloadTime = bool and 0 or 0.5
	getupvalue(sword.new,2).ReloadTime = bool and 0 or 0.5
end)
client.spamBatonSwordSwoosh = (function()
	repeat task.wait()
		local a = client.itemsys.GetLocalEquipped()
		if a and (a.__ClassName == "Sword" or a.__ClassName == "Baton") then
			require(game:GetService("ReplicatedStorage").Game.Item[a.__ClassName]).SwingSwoosh(a)
		end
	until configs.combat.batonsword.spamswoosh == false
end)
client.spamBatonSwordLunge = (function()
	repeat task.wait()
		local a = client.itemsys.GetLocalEquipped()
		if a and (a.__ClassName == "Sword" or a.__ClassName == "Baton") then
			require(game:GetService("ReplicatedStorage").Game.Item[a.__ClassName]).SwingLunge(a)
		end
	until configs.combat.batonsword.spamlunge == false
end)

client.notInWall = (function(i,v,wallCheck)
	if wallCheck then
        local ray = Ray.new(game:GetService("Workspace").CurrentCamera.CFrame.p, i - game:GetService("Workspace").CurrentCamera.CFrame.p)
        local result = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(ray, v)
        return result == nil
    else
        return true
    end
end)

client.isEnemies = (function(a,b)
    local a, b = tostring(a), tostring(b)
    if a == "Criminal" and b == "Police" then
        return true
    elseif a == "Criminal" and b == "Prisoner" then
        return false
    elseif a == "Police" and b == "Criminal" then
        return true
    elseif a == "Police" and b == "Prisoner" then
        return false
    elseif a == "Prisoner" and b == "Police" then
        return true
    elseif a == "Prisoner" and b == "Criminal" then
        return false
    end
end)
-- client.setPlayerHitboxRadius = (function(rad)
-- 	for i,v in next, game:GetService("Players"):GetPlayers() do
-- 		if isEnemies(game:GetService("Players").LocalPlayer.Team, v.Team) and v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
-- 			client.combatutils.setRootPartHitRadius(v.Character.HumanoidRootPart, rad)
-- 		end
-- 	end
-- end)
client.getNearestToCursor = (function() -- unoptimized
    local Target = nil
	local notInWall = client.notInWall
	local isEnemies = client.isEnemies
    for i,v in next, game:GetService("Players"):GetPlayers() do
        if isEnemies(game:GetService("Players").LocalPlayer.Team, v.Team) and v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 then
			local magnitude = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
			if magnitude < 9e9 then
				local Point, OnScreen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
				if OnScreen and notInWall(v.Character.HumanoidRootPart.Position,{game:GetService("Players").LocalPlayer.Character, v.Character}, configs.combat.silentaim.wallcheck) then
					local Distance =(Vector2.new(Point.X, Point.Y) - Vector2.new(game:GetService("Players").LocalPlayer:GetMouse().X, game:GetService("Players").LocalPlayer:GetMouse().Y)).magnitude
					if Distance < configs.combat.silentaim.radius then
						Target = v
					end
				end
			end
        end
    end
    return Target
end)
client.getPlayerVehicle = (function(plrname)
	local uh = nil
	for i,v in next, game:GetService("CollectionService"):GetTagged("Vehicle") do
		for i2,v2 in next, v:GetChildren() do
			if v2.Name == "Seat" or v2.Name == "Passenger" then
				local whateverSeatName = v2:FindFirstChild("PlayerName")
				if whateverSeatName and whateverSeatName.Value == plrname then
					return uh
				end
			end
		end
	end
	return uh
end)

client.getNearestVehicle = (function()
	local char = game:GetService("Players").LocalPlayer.Character
	local target, distance = nil, 100
	for i,v in next, game:GetService("CollectionService"):GetTagged("Vehicle") do
		if v:FindFirstChild("Seat") or v:FindFirstChild("Passenger") then
			
			local targetDistance = (char:FindFirstChild("HumanoidRootPart").Position-v:GetModelCFrame().Position).magnitude
			if targetDistance < distance then
				distance = targetDistance
				target = v
			end
		end
	end
	return target
end)

client.getNearestPlayerNoCuffed = (function() -- from my arrestaura script on my github cuz i'm too lazy :>
    local maxdistance = 18
    local player = nil;
    for i,v in next, game:GetService("Players"):GetPlayers() do
        if tostring(v.Team) == "Criminal" then
            local character = v.Character or nil
            if character ~= nil and not v.Character:GetAttribute("Handcuffs") then
                local hrp = character:FindFirstChild("Head") or nil
                local hum = character:FindFirstChild("Humanoid") or nil
                if hrp ~= nil and hum ~= nil then
                    local mag = (game:GetService("Players").LocalPlayer.Character:GetModelCFrame().Position - hrp.Position).magnitude
                    if mag < maxdistance then
                        player = v
                        if player ~= nil then
                            return player
                        end
                    end
                end
            end
        end
    end
	return false
end)
client.launchArrestAura = (function()
	local getNearestPlayerNoCuffed = client.getNearestPlayerNoCuffed
	repeat task.wait(0.15)
		local plr = getNearestPlayerNoCuffed()
		if plr then
			client.attemptarrest(game:GetService("Players"):FindFirstChild(tostring(plr)))			
		end
	until configs.combat.arrestaura.enabled == false
end)

client.updateToOriginalChassisStats = (function()
	local gvp = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).GetLocalVehiclePacket() 
	if gvp ~= nil and client.lastvehiclestats ~= nil and client.lastvehiclemodel ~= nil and gvp.Model ~= gvp.lastvehiclemodel then
		local stats = client.lastvehiclestats
		if configs.vehicle.engine == false then
			gvp.GarageEngineSpeed = stats.GarageEngineSpeed
		end
		-- if configs.vehicle.brake == false then
		-- 	gvp.GarageBrakes = stats.GarageBrakes
		-- end
		if configs.vehicle.suspension == false then
			gvp.Height = stats.Height
		end
		if configs.vehicle.turn == false then
			gvp.TurnSpeed = stats.TurnSpeed
		end
	end

end)

client.changeHitboxRadius = (function(radius)
	setreadonly(client.combatconst, isreadonly(client.combatconst) and false)
	client.combatconst.DEFAULT_ROOT_PART_HIT_RADIUS = radius
end)

client.hookNearestObj = (function()
	local cframe = client.ropedata.nearestObj.PrimaryPart.CFrame:PointToObjectSpace(require(game:GetService("ReplicatedStorage"):WaitForChild("Std"):WaitForChild("GeomUtils")).closestPointInPart(client.ropedata.nearestObj.PrimaryPart, client.ropedata.obj.Position))
	client.ropedata.manifest.reqLinkRemote:FireServer(client.ropedata.nearestObj, cframe)
end)

client.onHitSurfaceHook = (function()
	if configs.combat.increasetakedowndamage then
		local a = client.itemsys.GetLocalEquipped()
		if a.FakeName ~= "Sniper" then
			a.FakeName = "Sniper"
		end
		repeat wait() until a.BulletEmitter ~= nil
		setconstant(a.BulletEmitter.OnHitSurface._handlerListHead._fn, 75, "FakeName")
	end
end)

task.spawn(function()
	-- Hooking
	setupvalue(jbremote.FireServer, 1, function(key,...) -- anti cheat bipasss
		local args = {...}
		if #args == 2 and debug.traceback():find("LocalScript:1343") then return end
		return oldjbremote(key, ...)
	end)

	client.hittargetwithspeed = (function(...)
		local args = {...}
		if configs.combat.forcefieldnomiss then
			args[3] = 0
		end
		return client.ori.hittargetwithspeed(unpack(args))
	end)	

	old2 = hookfunction(client.bulletonlocalhitplayer, function(...)
		local args = {...}
		if configs.combat.alwaysheadshot then
			args[15].isHeadshot = true
			args[15].isWallbang = false
		end
		return old2(unpack(args))
	end)

	client.itemgun.Shoot = (function(self,a)
		if configs.combat.silentaim.enabled then
			local character = client.getNearestToCursor() and client.getNearestToCursor().Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				self.TipDirection = (hrp.Position - self.Tip.Position).Unit
			end
		end
		client.ori.shoot(self, a)
	end)

	client.plasmagun.ShootOther = (function(self,a)
		if configs.combat.silentaim.enabled and configs.combat.silentaim.includeplasma then
			local character = client.getNearestToCursor() and client.getNearestToCursor().Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				self.TipDirection = (hrp.Position - self.Tip.Position).Unit
			end
		end
		client.ori.plasmashootother(self,a)
	end)

	client.tase.Tase = (function(self,...)
		if configs.combat.tasermodz then 
			self._lastDraw = 0 
		end
		return client.ori.tase(self,...)
	end)

	client.raycast.RayIgnoreNonCollideWithIgnoreList = (function(...)
		-- yes this is actually from min & brizzy silent aim script cuz i'm starting to get lazy soo yea credits to him!
		-- maybe if i'm not lazy then i will start to make my own
		if debug.traceback():find("Taser") and configs.combat.silentaim.enabled and configs.combat.silentaim.includetaser then
			local character = client.getNearestToCursor() and client.getNearestToCursor().Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				return hrp, hrp.Position, hrp.Position, ... -- not doing args table thing cuz that didn't work for some reason (skill issue tbh)
			end
		end
		return client.ori.rayignore(...)
	end)

	client.raycast.RayIgnoreNonCollide = (function(...)
		local args = {...}
		if configs.vehicle.driveonwater and debug.traceback():find("AlexChassis") then
			args[6] = true
		end
		return client.ori.rayignorenon(unpack(args))
	end)

	client.gamepasssystem.doesPlayerOwnCached = (function(...)
		local args = {...}
		if configs.combat.pistolswat and tostring(args[1]) == game:GetService("Players").LocalPlayer.Name and debug.traceback():find("tem.Pistol") then
			return true
		end
		return client.ori.doesplayerowncached(...)
	end)

	client.gunutil.getEquipTime = (function(...)
		return configs.combat.noequipt and 0 or client.ori.getequiptime(...)
	end)

	client.circleac.Update = (function(...) -- who knows if this is better
		local mymom = ...
		pcall(function()
			client.ori.update(mymom)
			if configs.player.nocircwait then
				client.circleac.Spec.PressedAt = 0.01
			end
		end)
	end)

	client.paraglide.IsFlying = (function(...)
		return configs.player.nosky and debug.traceback():find("Falling") and true or client.ori.isflying(...)
	end)

	client.vehiclelinkbinder._constructor._updateSeeking = (function(ropedata)
		client.ropedata = ropedata
		return client.ori.updateseeking(ropedata)
	end)

	game:GetService("Players").LocalPlayer:GetMouse().Move:Connect(function()
		local Mouse = game:GetService"UserInputService":GetMouseLocation()
		Circle.Position = Vector2.new(Mouse.X, Mouse.Y)
	end)
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        local hrp = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        if hrp then
            if configs.player.nofall then 
                hrp:AddTag("NoFallDamage")
			end
            if configs.player.norag then
                hrp:AddTag("NoRagdoll")
            end
        end
    end)
	game:GetService("UserInputService").JumpRequest:Connect(function()
		if configs.player.infjump then
			game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
		end
	end)
	game:GetService("Players").LocalPlayer.PlayerGui.ChildAdded:Connect(function(mama)
		if mama.Name == "LoadingBarGui" then
			if client.ropedata.nearestObj ~= nil then
				if configs.vehicle.instanttow and client.ropedata.obj.Name == "MetalHook" then
					client.hookNearestObj()
				elseif configs.vehicle.helipick and client.ropedata.obj.Name == "RopePull" then
					client.hookNearestObj()
				end
			end
			print("wow mama is exist in playergui!@!!!!") -- idk what happened here 
		end
	end)
	game.Lighting.ChildAdded:connect(function(mama)
		if configs.combat.snipernoblur and mama.Name == "Blur" then
			mama:GetPropertyChangedSignal("Size"):connect(function()
				mama.Enabled = false
			end)
		end
	end)
	client.onvehicleentered:Connect(function(arg1)
		client.vehicleEntered = true
		if arg1.Model ~= client.lastvehiclemodel and arg1.Type == "Chassis" then
			client.lastvehiclemodel = arg1.Model
			--table.clear(client.lastvehiclestats)
			client.lastvehiclestats.GarageEngineSpeed = arg1.GarageEngineSpeed
			client.lastvehiclestats.TurnSpeed = arg1.TurnSpeed
			client.lastvehiclestats.Height = arg1.Height
			print("changed")
		end
		if configs.vehicle.ftog then
			client.launchVehicleFlight()
		end
		if arg1.Type == "Heli" then
			arg1.MaxHeight = configs.vehicle.heliheight and 9e9 or 400
			arg1.FallOutOfSkyDuration = configs.vehicle.helibreak and 0 or 10
			arg1.DisableDuration = configs.vehicle.helibreak and 0 or 10
		elseif arg1.Type == "Chassis" then
			arg1.TirePopDuration = configs.vehicle.nopop and 0 or 7.5
			arg1.DisableDuration = configs.vehicle.nopop and 0 or 7.5
			arg1.TirePopProportion = configs.vehicle.nopop and 0 or 0.5
		end
	end)
	client.onvehicleexited:Connect(function()
		client.vehicleEntered = false
	end)
	client.onlocalitemequipped:Connect(function(equippeddata) 
		--client.originalequippeddata = equippeddata
		local getdata = client.getOldWeaponData
		local a = client.itemsys.GetLocalEquipped()
		if a.FakeName ~= "Sniper" then
			a.FakeName = "Sniper"
		end
		task.spawn(function()
			client.onHitSurfaceHook()
		end)
		if getdata(a.__ClassName, "EquipTime") ~= nil then -- just realized that this shit didn't do anything 😑
			a.Config.EquipTime = configs.combat.noequipt and 0 or getdata(a.__ClassName, "EquipTime")
		end
		if getdata(a.__ClassName, "FireAuto") ~= nil then
			a.Config.FireAuto = configs.combat.alwaysauto and true or getdata(a.__ClassName, "FireAuto") 
		end
		if getdata(a.__ClassName, "BulletSpread") ~= nil then
			a.Config.BulletSpread = configs.combat.nospread and 0 or getdata(a.__ClassName, "BulletSpread")
		end
		if getdata(a.__ClassName, "CamShakeMagnitude") ~= nil then
			a.Config.CamShakeMagnitude = configs.combat.norecoil and 0 or getdata(a.__ClassName, "CamShakeMagnitude")
		end
		if a.__ClassName == "Taser" and getdata(a.__ClassName, "ReloadTimeHit") ~= nil and getdata(a.__ClassName, "ReloadTime") ~= nil then
			a.Config.ReloadTimeHit = configs.combat.tasermodz and 0 or getdata(a.__ClassName, "ReloadTimeHit")
			a.Config.ReloadTime = configs.combat.tasermodz and 0 or getdata(a.__ClassName, "ReloadTime")
		end
		if a and a.BulletEmitter and a.BulletEmitter.GravityVector then
			a.BulletEmitter.GravityVector = configs.combat.nobulletg and nil or Vector3.new(0, -workspace.Gravity / 10, 0)
		end
	end)

	task.spawn(function()
		while true do task.wait()
			pcall(function()
				local humanoid = game:GetService("Players").LocalPlayer.Character.Humanoid or nil
				local gvp = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).GetLocalVehiclePacket() or nil
				if humanoid ~= nil and gvp ~= nil and client.vehicleEntered then
					if gvp.Type == "Chassis" then
						if configs.vehicle.engine then
							gvp.GarageEngineSpeed = configs.vehicle.enginesp
						end
						-- if configs.vehicle.brake then
						-- 	gvp.GarageBrakes = configs.vehicle.brakesp
						-- end
						if configs.vehicle.suspension then
							gvp.Height = configs.vehicle.suspensionhe
						end
						if configs.vehicle.turn then
							gvp.TurnSpeed = configs.vehicle.turnsp
						end
					end
				end
			end)
		end
	end)
end)


local FolderName = "Jailbreak secret dev tool"
local FileName = FolderName.."\\configs.json"


local ui =eleriumremake.SetupUI("bru what", function() end)

local page = ui.NewPage("Players")

-- // Character
local sec = page.NewSection("Character")
sec.NewSlider("Walkspeed", 0, 10, 5, configs.player.walkval, function(a)
	configs.player.walkval = a
end)
sec.NewToggle("Enable Walkspeed", function(a)
	configs.player.walktog = a
end, configs.player.walktog)
sec.NewToggle("Inf Jump", function(a)
	configs.player.infjump = a
end, configs.player.infjump)

-- // Utilities
local sec = page.NewSection("Utilities")
sec.NewToggle("Automatic Escape(BETA)", function(a)
	configs.player.autoescape = a
end, configs.player.autoescape)
sec.NewToggle("No Ragdoll", function(a)
	configs.player.norag = a
	local hrp = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart") or nil
	if configs.player.norag == false and hrp ~= nil then
		hrp:RemoveTag("NoRagdoll")
	elseif configs.player.norag == true and hrp ~= nil then
		hrp:AddTag("NoRagdoll")
	end
end, configs.player.norag)
sec.NewToggle("No Fall Injury", function(a)
	configs.player.nofall = a
	local hrp = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart") or nil
	if configs.player.nofall == false and hrp ~= nil then
		hrp:RemoveTag("NoFallDamage")
	elseif configs.player.nofall == true and hrp ~= nil then
		hrp:AddTag("NoFallDamage")
	end
end, configs.player.nofall)
sec.NewToggle("No Skydive", function(a)
	configs.player.nosky = a
end, configs.player.nosky)
sec.NewToggle("No Ragdoll Stun", function(a)
	configs.player.nostun = a
	client.settingss.Time.Stunned = configs.player.nostun and 0 or 5
	setupvalue(client.stunnedragdoll, 1, configs.player.nostun and nil)
end, configs.player.nostun)

-- sec.NewToggle("No Punch Wait", function(a) 
-- 	configs.player.nopwait = a
-- end, false)
sec.NewToggle("No Roll Wait", function(a)
	configs.player.norwait = a
	client.activeaction.roll.useEvery = configs.player.norwait and 0 or 5
end, configs.player.norwait)
sec.NewToggle("No Crawling Slow", function(a)
	configs.player.nocslow = a
	setconstant(client.walkspeedfun, 16, configs.player.nocslow and 1 or 0.4)
end, configs.player.nocslow)
sec.NewToggle("No Circle Hold", function(a)
	configs.player.nocircwait = a
	--setconstant(client.circleac.Press, 3, a and "yousuck" or "Timed")
end, configs.player.nocircwait)
sec.NewToggle("No Injury Slow", function(a)
	configs.player.noislow = a
	setconstant(client.walkspeedfun, 8, configs.player.noislow and 1 or 0.5)
end, configs.player.noislow)
sec.NewToggle("No Spotlight Slow", function(a)
	configs.player.nospslow = a
	setconstant(client.walkspeedfun, 35, configs.player.nospslow and 1 or 0.8)
end, configs.player.nospslow)
-- sec.NewToggle("No Shield Swat Slow", function(a)
-- 	configs.player.noswatslow = a
-- end, configs.player.noswatslow)
-- sec.NewToggle("Always Punch", function(a)
-- 	configs.player.alwaysp = a
-- 	if configs.player.alwaysp == true then
-- 		client.punchCorrection()
-- 	end
-- end, false)
-- sec.NewToggle("Always Silent Punch", function(a)
-- 	configs.player.alwayssilentp = a
-- end, false)
sec.NewToggle("Always Keycard", function(a)
	configs.player.bypasskd = a
	client.hasKeyCorrection(configs.player.bypasskd)
end, configs.player.bypasskd)
sec.NewToggle("Allow Equip While Crawling", function(a)
	configs.player.crawlequip = a
	if configs.player.crawlequip then
		client.isCrawlingCorrection()
	end
end, configs.player.crawlequip)
sec.NewToggle("Allow Walk When Arrested", function(a)
	configs.player.allowwalkcuffed = a
end, configs.player.allowwalkcuffed)
sec.NewToggle("Break Your Back Bone", function(a)
	configs.player.backbone = a
	if configs.player.backbone then
		client.duckCorrection()
	end
end, configs.player.backbone)
sec.NewToggle("Get Avatar Outfit On Respawn", function(a)
	configs.player.getclothes = a
end, configs.player.getclothes)
sec.NewButton("Get Avatar Outfit", function()

end)
sec.NewButton("Get Police Outfit", function()

end)
sec.NewLabel("NOTE: No Circle Hold might broke/not working on some actions")

-- --// Projectiles
-- local sec = page.NewSection("Projectiles")
-- sec.NewToggle("Disable Military Turret", function(a)
	
-- end, false)
-- sec.NewToggle("Disable House Turret", function(a)
	
-- end, false)


-- // Vehicle Page
local page = ui.NewPage("Vehicle")

-- // Utilities
local sec = page.NewSection("Utilities")
sec.NewSlider("Flight Speed", 10, 1000, configs.vehicle.fspeed, true, function(a)
	configs.vehicle.fspeed = a
end)
sec.NewSlider("Flight Rotation X", 0, 360, configs.vehicle.fx, false, function(a)
	configs.vehicle.fx = a
end)
sec.NewSlider("Flight Rotation Y", 0, 360, configs.vehicle.fy, false, function(a)
	configs.vehicle.fy = a
end)
sec.NewSlider("Flight Rotation Z", 0, 360, configs.vehicle.fz, false, function(a)
	configs.vehicle.fz = a
end)
sec.NewToggle("Vehicle Flight", function(a)
	configs.vehicle.ftog = a
	if configs.vehicle.ftog and client.vehicleEntered == true then
		client.launchVehicleFlight()
	end
end, configs.vehicle.ftog)
sec.NewToggle("Infinite Nitro", function(a)
	configs.vehicle.infnitro = a
	if configs.vehicle.infnitro then
		client.nitroCorrection()
	end
end, configs.vehicle.infnitro)
sec.NewToggle("Random Infinite Nitro", function(a)
	configs.vehicle.rinfnitro = a
end, configs.vehicle.rinfnitro)
sec.NewToggle("Always Nitro", function(a)
	configs.vehicle.alwaysnit = a	
end, configs.vehicle.alwaysnit)
sec.NewToggle("No Hijack Vehicle", function(a)
	configs.vehicle.alwayshij = a
end, configs.vehicle.alwayshij)

-- sec.NewToggle("Automatic Lock Vehicle", function(a)
-- 	configs.vehicle.autolock = a
-- end, false)

-- // Car Modification
local sec = page.NewSection("Car Mods")
sec.NewSlider("Engine Speed", 1, 200, configs.vehicle.enginesp, false, function(a)
	configs.vehicle.enginesp = a
end)
sec.NewToggle("Apply Engine Speed", function(a)
	configs.vehicle.engine = a
	if configs.vehicle.engine == false then
		client.updateToOriginalChassisStats()
	end
end, configs.vehicle.engine)
-- sec.NewSlider("Brake Speed", 1, 5, configs.vehicle.brakesp, true, function(a)
-- 	configs.vehicle.brakesp = a
-- end)
-- sec.NewToggle("Apply Brake Speed", function(a)
-- 	configs.vehicle.brake = a
-- end, configs.vehicle.brake)
sec.NewSlider("Suspension Height", 1, 150, configs.vehicle.suspensionhe, false, function(a)
	configs.vehicle.suspensionhe = a
end)
sec.NewToggle("Apply Suspension Height", function(a)
	configs.vehicle.suspension = a
	if configs.vehicle.suspension == false then
		client.updateToOriginalChassisStats()
	end
end, configs.vehicle.suspension)
sec.NewSlider("Turn Speed", 1, 5, configs.vehicle.turnsp, true, function(a)
	configs.vehicle.turnsp = a
end)
sec.NewToggle("Apply Turn Speed", function(a)
	configs.vehicle.turn = a
	if configs.vehicle.suspension == false then
		client.updateToOriginalChassisStats()
	end
end, configs.vehicle.turn)
sec.NewToggle("Anti Tire Pop", function(a)
	configs.vehicle.nopop = a
	-- if configs.vehicle.nopop then
	-- 	client.popCorrection()
	-- end
end, configs.vehicle.nopop)
sec.NewToggle("Automatic Flip", function(a)
	configs.vehicle.autoflip = a
	if configs.vehicle.autoflip then
		client.flipCorrection()
	end
end, configs.vehicle.autoflip)
sec.NewToggle("Instant Tow", function(a)
	configs.vehicle.instanttow = a
end, configs.vehicle.instanttow)
sec.NewToggle("Drive On Water", function(a)
	configs.vehicle.driveonwater = a
	setconstant(client.alexchassis.UpdateEngine, 280, configs.vehicle.driveonwater and 1 or 0.625)
end, configs.vehicle.driveonwater)

--// Helicopter Mods
local sec = page.NewSection("Heli Mods")
sec.NewSlider("Engine Speed", 1, 100, configs.vehicle.helienginesp, false, function(a)
	configs.vehicle.helienginesp = a / 1000
end)
-- sec.NewToggle("Apply Engine Speed", function(a)
-- 	configs.vehicle.heliengine = a
-- end, false)
sec.NewToggle("Infinite Height", function(a)
	configs.vehicle.heliheight = a
end, configs.vehicle.heliheight)
sec.NewToggle("Anti Heli Break", function(a)
	configs.vehicle.helibreak = a
	if configs.vehicle.helibreak then
		client.heliBreakCorrection()
	end
end, configs.vehicle.helibreak)
sec.NewToggle("Instant Pickup", function(a)
	configs.vehicle.helipick = a
end, configs.vehicle.helipick)


-- // Combat Page

local page = ui.NewPage("Combats")

-- // Weapons
local sec = page.NewSection("Weapons")
sec.NewToggle("Always Auto", function(a)
	configs.combat.alwaysauto = a
end, configs.combat.alwaysauto)
sec.NewToggle("No Recoil", function(a)
	configs.combat.norecoil = a
end, configs.combat.norecoil)
sec.NewToggle("No Spread", function(a)
	configs.combat.nospread = a
end, configs.combat.nospread)
sec.NewToggle("No Bullet Gravity", function(a)
	configs.combat.nobulletg = a
end, configs.combat.nobulletg)  
sec.NewToggle("No Equip Time", function(a)
	configs.combat.noequipt = a
end, configs.combat.noequipt)
sec.NewToggle("Wallbang", function(a)
	configs.combat.wallbang = a
end, configs.combat.wallbang)
sec.NewToggle("Headshot Only", function(a)
	configs.combat.alwaysheadshot =a
	--client.headshotCorrection(configs.combat.alwaysheadshot)
end, configs.combat.alwaysheadshot)
sec.NewToggle("Increase Takedown Damage", function(a)
	configs.combat.increasetakedowndamage =a
end, configs.combat.increasetakedowndamage)
sec.NewToggle("Free Pistol Swat", function(a)
	configs.combat.pistolswat = a
end, configs.combat.pistolswat)
sec.NewToggle("Fast Taser", function(a)
	configs.combat.tasermodz = a
end, configs.combat.tasermodz)
sec.NewToggle("Forcefield Anti Misses", function(a) -- if you don't know what this does, it basically makes your forcefield ball/bullet always hitting yourself
	configs.combat.forcefieldnomiss = a
end, configs.combat.forcefieldnomiss)
sec.NewToggle("No Sniper Scope Gui", function(a)
	configs.combat.snipernogui = a
end, false)
sec.NewToggle("No Sniper Scope Blur", function(a)
	configs.combat.snipernoblur = a
end, false)
sec.NewToggle("No Grenade Smoke", function(a)
	configs.combat.nogrenadesmoke = a
	client.smokeGrenadeHook(configs.combat.nogrenadesmoke)
end, configs.combat.nogrenadesmoke)
-- sec.NewToggle("Increase Vehicle & Forcefield Bullet Damage", function(a)

-- end, false)
sec.NewButton("Open Gunstore Ui", function()
	set_thread_identity(2) 
	require(game:GetService("ReplicatedStorage").Game.GunShop.GunShopUI).open()
	set_thread_identity(10)
end)


--// Sword & Baton
local sec = page.NewSection("Melee")
sec.NewToggle("No Reload Time", function(a)
	configs.combat.batonsword.noreloadtime = a
	if configs.combat.batonsword.noreloadtime then
		client.setBatonSwordTime(configs.combat.batonsword.noreloadtime)
	end
end, configs.combat.batonsword.noreloadtime)

sec.NewToggle("Always Swoosh", function(a)
	configs.combat.batonsword.spamswoosh = a
	if configs.combat.batonsword.spamswoosh then
		client.spamBatonSwordSwoosh()
	end
end, configs.combat.batonsword.spamswoosh)
sec.NewToggle("Always Lunge", function(a)
	configs.combat.batonsword.spamlunge = a
	if configs.combat.batonsword.spamlunge then
		client.spamBatonSwordLunge()
	end
end, configs.combat.batonsword.spamlunge)

--// Silent Aim [please don't use this cuz it sucks trust me]
local sec = page.NewSection("Silent Aim [Unoptimized]")

sec.NewToggle("Enabled", function(a)
	configs.combat.silentaim.enabled = a
end, false)
sec.NewToggle("Include Taser", function(a)
	configs.combat.silentaim.includetaser = a
end, false)
sec.NewToggle("Include Plasma Gun", function(a)
	configs.combat.silentaim.includetaser = a
end, false)
sec.NewSlider("Radius", 10, 1000, 250, false, function(a)
	configs.combat.silentaim.radius = a
	Circle.Radius = a
end)
sec.NewToggle("Wallcheck", function(a)
	configs.combat.silentaim.wallcheck = a
end, false)
sec.NewToggle("FOV Circle", function(a)
	configs.combat.silentaim.fovcirc = a
	Circle.Visible = a
end, false)
sec.NewSlider("Circle Thickness", 0, 10, 0, true, function(a)
	configs.combat.silentaim.fovthick = a
	Circle.Thickness = a
end)
sec.NewSlider("Circle Transparency", 1, 0, 0, true, function(a)
	configs.combat.silentaim.fovtransp = a
	Circle.Transparency = a
end)
local sec = page.NewSection("Arrest Aura")
-- sec.NewLabel("NOTE: this features is not optimized well and rushed")
-- sec.NewLabel("soo expect some bugs occuring")
sec.NewToggle("Enabled", function(a)
	configs.combat.arrestaura.enabled = a
	if configs.combat.arrestaura.enabled then
		client.launchArrestAura()
	end	
end, configs.combat.arrestaura.enabled)


-- local sec = page.NewSection("Tase Aura")
-- sec.NewLabel("not done yet lmao")
-- sec.NewSlider("Tase Distance", 10, 85, 25, false, function(a)
	
-- end)
-- sec.NewToggle("Enabled", function(a)
	
-- end, false)


local sec = page.NewSection("Others")
sec.NewSlider("Hitbox Radius", 3, 50, configs.combat.hitboxradius, true, function(a)
	configs.combat.hitboxradius = a
	client.changeHitboxRadius(configs.combat.hitboxradius)
end)
