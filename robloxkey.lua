local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextBox = Instance.new("TextBox")
local UICorner_2 = Instance.new("UICorner")
local EnterButton = Instance.new("TextButton")

--Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(68, 68, 68)
Frame.BackgroundTransparency = 0.150
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 0, -3.6388208e-08, 0)
Frame.Size = UDim2.new(1, 0, 1, 0)

UICorner.Parent = Frame

TextBox.Parent = Frame
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0.237115815, 0, 0.360464334, 0)
TextBox.Size = UDim2.new(0.522251904, 0, 0.0619286932, 0)
TextBox.Font = Enum.Font.SourceSans
TextBox.PlaceholderText = "Enter your key here."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.TextSize = 14.000

UICorner_2.Parent = TextBox

EnterButton.Parent = Frame
EnterButton.BackgroundColor3 = Color3.fromRGB(60, 255, 0)
EnterButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
EnterButton.BorderSizePixel = 0
EnterButton.Position = UDim2.new(0.380673736, 0, 0.530959904, 0)
EnterButton.Size = UDim2.new(0.237828568, 0, 0.0669138432, 0)
EnterButton.Font = Enum.Font.SourceSans
EnterButton.Text = "Authorize"
EnterButton.TextColor3 = Color3.fromRGB(0, 0, 0)
EnterButton.TextScaled = true
EnterButton.TextSize = 14.000
EnterButton.TextWrapped = true

-- Script to handle button click and authorization
local HttpService = game:GetService("HttpService")

EnterButton.MouseButton1Click:Connect(function()
	local enteredKey = TextBox.Text
	local url = "https://raw.githubusercontent.com/Theobfusicatorguy/KEYS/main/SCRIPT.txt"

	-- Fetch the list of keys
	local success, result = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if success then
		print("Successfully fetched the keys")
		local keys = string.split(result, "\n")

		for _, key in ipairs(keys) do
			if enteredKey == key then
				-- Key matches, execute the embedded script directly
				print("Authorized key: " .. key)
				-- Insert your full exploit script here
				print("hihih:")
				return
			end
		end

		-- If the key does not match
		print("Invalid key")
	else
		print("Failed to fetch the keys: " .. tostring(result))
	end
end)
