class('BoardSquare').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

function BoardSquare:init(squareWidth, squareHeight, squareX, squareY, posX, posY, isEmpty, image, value)
	BoardSquare.super.init(self)
	self:setCenter(0, 0)
	
	self.squareX = squareX
	self.squareY = squareY
	self.posX = posX
	self.posY = posY
	
	self.isEmpty = isEmpty
	self.value = value
	
	if isEmpty == false then
		-- Draw the image for the square if it's not empty
		local squareImage = gfx.image.new(squareWidth, squareHeight)
		gfx.pushContext(squareImage)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, squareImage.width, squareImage.height)
		gfx.setColor(gfx.kColorBlack)
		image:draw(squareWidth/2 - image.width/2, squareHeight/2 - image.height/2)
		gfx.drawRect(0, 0, squareImage.width, squareImage.height)
		gfx.popContext()
		
		self:setImage(squareImage)
	end
	
	self:moveTo(self.posX, self.posY)
end

function BoardSquare:getPosition()
	return {
		["posX"] = self.posX,
		["posY"] = self.posY,
		["squareX"] = self.squareX,
		["squareY"] = self.squareY,
	}
end

function BoardSquare:setPosition(positionData, animated)
	self.posX = positionData.posX
	self.posY = positionData.posY
	self.squareX = positionData.squareX
	self.squareY = positionData.squareY
	
	if animated then
		self:animateTo(self.posX, self.posY)
	else
		self:moveTo(self.posX, self.posY)
	end
end

function BoardSquare:animateTo(x, y)
	if x == self.x and y == self.y then
		return
	end
	local ls = playdate.geometry.lineSegment.new(self.x, self.y, x, y)
	self.animator = gfx.animator.new(200, ls, playdate.easingFunctions.outEase)
end

function BoardSquare:update()
	if self.animator ~= nil then
		self:setAnimator(self.animator)
		if self.animator:ended() then
			self.animator = nil
		end
	end
end