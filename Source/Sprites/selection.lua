class('Selection').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

function Selection:init(squareWidth, squareHeight)
	Selection.super.init(self)
	
	self:setCenter(0, 0)
	
	self.squareX = 1
	self.squareY = 1
	
	self.selectionImage = gfx.image.new(squareWidth + 4, squareHeight + 4)
	gfx.pushContext(self.selectionImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.setLineWidth(3)
	gfx.drawRect(0, 0, self.selectionImage.width, self.selectionImage.height)
	gfx.popContext()
	
	self:setImage(self.selectionImage)
	
	-- self.animator.repeats = true
	-- self.animator.reverses = true
	
end

function Selection:animateTo(x, y)
	local ls = playdate.geometry.lineSegment.new(self.x, self.y, x, y)
	self.animator = gfx.animator.new(200, ls, playdate.easingFunctions.outEase)
end

function Selection:update()
	if self.animator ~= nil then
		self:setAnimator(self.animator)
		if self.animator:ended() then
			self.animator = nil
		end
	end
end