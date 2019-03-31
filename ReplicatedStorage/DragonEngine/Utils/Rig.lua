--[[
	Rig Utilities
	
	Contains useful functions for the manipulation of character rigs.
--]]

local RigUtils={}

function RigUtils:GetAttachmentFromCharacter(Character,AttachmentName)
	local RigType=""
	local Attachments={
		["HairAttachment"]={["R6"]="Head",["R15"]="Head"},
		["HatAttachment"]={["R6"]="Head",["R15"]="Head"},
		["FaceFrontAttachment"]={["R6"]="Head",["R15"]="Head"},
		["FaceCenterAttachment"]={["R6"]="Head",["R15"]="Head"},
		["NeckAttachment"]={["R6"]="Torso",["R15"]="UpperTorso"},
		["BodyFrontAttachment"]={["R6"]="Torso",["R15"]="UpperTorso"},
		["BodyBackAttachment"]={["R6"]="Torso",["R15"]="UpperTorso"},
		["LeftCollarAttachment"]={["R6"]="Torso",["R15"]="UpperTorso"},
		["RightCollarAttachment"]={["R6"]="Torso",["R15"]="UpperTorso"},
		["WaistFrontAttachment"]={["R6"]="Torso",["R15"]="LowerTorso"},
		["WaistCenterAttachment"]={["R6"]="Torso",["R15"]="LowerTorso"},
		["WaistBackAttachment"]={["R6"]="Torso",["R15"]="LowerTorso"},
		["LeftShoulderAttachment"]={["R6"]="Left Arm",["R15"]="LeftUpperArm"},
		["LeftGripAttachment"]={["R6"]="Left Arm",["R15"]="LeftHand"},
		["RightShoulderAttachment"]={["R6"]="Right Arm",["R15"]="RightUpperArm"},
		["RightGripAttachment"]={["R6"]="Right Arm",["R15"]="RightHand"},
		["LeftFootAttachment"]={["R6"]="Left Leg",["R15"]="LeftFoot"},
		["RightFootAttachment"]={["R6"]="Right Leg",["R15"]="RightFoot"},
		["RootAttachment"]={["R6"]="HumanoidRootPart",["R15"]="None"},
		--[[R15 exclusive attachments]]--
		["RootRigAttachment"]={["R6"]="None",["R15"]="HumanoidRootPart"},
		["LeftWristRigAttachment"]={["R6"]="None",["R15"]="LeftHand"},
		["LeftElbowRigAttachment"]={["R6"]="None",["R15"]="LeftLowerArm"},
		["LeftWristRigAttachment"]={["R6"]="None",["R15"]="LeftLowerArm"},
		["LeftShoulderRigAttachment"]={["R6"]="None",["R15"]="LeftUpperArm"},
		["LeftElbowRigAttachment"]={["R6"]="None",["R15"]="LeftUpperArm"},
		["RightWristRigAttachment"]={["R6"]="None",["R15"]="RightHand"},
		["RightElbowRigAttachment"]={["R6"]="None",["R15"]="RightLowerArm"},
		["RightWristRigAttachment"]={["R6"]="None",["R15"]="RightLowerArm"},
		["RightShoulderRigAttachment"]={["R6"]="None",["R15"]="RightUpperArm"},
		["RightElbowRigAttachment"]={["R6"]="None",["R15"]="RightUpperArm"},
		["WaistRigAttachment"]={["R6"]="None",["R15"]="UpperTorso"},
		["NeckRigAttachment"]={["R6"]="None",["R15"]="UpperTorso"},
		["LeftShoulderRigAttachment"]={["R6"]="None",["R15"]="UpperTorso"},
		["RightShoulderRigAttachment"]={["R6"]="None",["R15"]="UpperTorso"},
		["LeftAnkleRigAttachment"]={["R6"]="None",["R15"]="LeftFoot"},
		["LeftKneeRigAttachment"]={["R6"]="None",["R15"]="LeftLowerLeg"},
		["LeftAnkleRigAttachment"]={["R6"]="None",["R15"]="LowerLeftLeg"},
		["LeftHipRigAttachment"]={["R6"]="None",["R15"]="LeftUpperLeg"},
		["LeftKneeRigAttachment"]={["R6"]="None",["R15"]="LeftUpperLeg"},
		["RightAnkleRigAttachment"]={["R6"]="None",["R15"]="RightFoot"},
		["RightKneeRigAttachment"]={["R6"]="None",["R15"]="RightLowerLeg"},
		["RightAnkleRigAttachment"]={["R6"]="None",["R15"]="RightLowerLeg"},
		["RightHipRigAttachment"]={["R6"]="None",["R15"]="RightUpperLeg"},
		["RightKneeRigAttachment"]={["R6"]="None",["R15"]="RightUpperLeg"},
		["RootRigAttachment"]={["R6"]="None",["R15"]="LowerTorso"},
		["WaistRigAttachment"]={["R6"]="None",["R15"]="LowerTorso"},
		["LeftHipRigAttachment"]={["R6"]="None",["R15"]="LowerTorso"},
		["RightHipRigAttachment"]={["R6"]="None",["R15"]="LowerTorso"},
		["NeckRigAttachment"]={["R6"]="None",["R15"]="Head"}
	}
	
	if Character.Humanoid.RigType==Enum.HumanoidRigType.R6 then RigType="R6" end
	if Character.Humanoid.RigType==Enum.HumanoidRigType.R15 then RigType="R15" end
	local Attachment=Character[Attachments[AttachmentName][RigType]][AttachmentName]
	return Attachment
end

return RigUtils