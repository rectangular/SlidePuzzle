class('Hud').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local PADDING = 16
local BOARD_WIDTH = 240 + 2
local HUD_WIDTH = 400 - BOARD_WIDTH
local HUD_HEIGHT = 240


function Hud:init(level)
	Hud.super.init(self)
	
	self.level = level
	self.isSolved = false
	
	self:setCenter(0, 0)
	
	self.hudImage = gfx.image.new(HUD_WIDTH, HUD_HEIGHT)
	gfx.pushContext(self.hudImage)
	
	gfx.setColor(gfx.kColorBlack)
	gfx.setLineWidth(3)
	gfx.fillRect(0, 0, self.hudImage.width, self.hudImage.height)
	
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawText("Loading...", PADDING, PADDING)
	gfx.popContext()
	
	self:setImage(self.hudImage)
	self:moveTo(BOARD_WIDTH, 0)
end

function Hud:update()
	self.hudImage = gfx.image.new(HUD_WIDTH, HUD_HEIGHT)
	gfx.pushContext(self.hudImage)
	
	gfx.setColor(gfx.kColorBlack)
	gfx.setLineWidth(3)
	gfx.fillRect(0, 0, self.hudImage.width, self.hudImage.height)
	
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawText("Level " .. tostring(self.level), PADDING, PADDING)
	if self.isSolved then
		gfx.drawText("You solved it!", PADDING, PADDING * 3)
	else
		gfx.drawText("Not solved yet", PADDING, PADDING * 3)
	end
	gfx.popContext()
	
	self:setImage(self.hudImage)
end