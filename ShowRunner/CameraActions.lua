local RunService = game:GetService("RunService")
local CameraActions = {}

-- Declarations
CameraActions.TrackedPart = nil

local camera = workspace.CurrentCamera
local plane = workspace.AFY.Engineering:WaitForChild("Plane")
local cameraPart = plane:WaitForChild("CameraPart")
local dampening = 0.1
-- Functions

function setCameraToPartCFrame()
    camera.CFrame = camera.CFrame:Lerp(CameraActions.TrackedPart.CFrame, dampening)
end


function CameraActions.SetupPlaneCamera()
    CameraActions.TrackedPart = cameraPart
    camera.CameraType = Enum.CameraType.Scriptable
    RunService:BindToRenderStep("updateCamera", 201, setCameraToPartCFrame)
end


function CameraActions.ResetCamera()
    camera.CameraType = Enum.CameraType.Custom
    RunService:UnbindFromRenderStep("updateCamera")
end


return CameraActions