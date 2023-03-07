import "board-square.lua"
import "selection.lua"

class('Board').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local BOARD_WIDTH = 240
local BOARD_HEIGHT = 240

local SHUFFLE_COUNT = 200

local SQUARE_GAP = 3

local ADJACENT_SQUARES = {
	{
		["x"] = 0, 
		["y"] = -1,
	},
	{
		["x"] = -1, 
		["y"] = 0
	}, 
	{
		["x"] = 0, 
		["y"] = 1
	},
	{
		["x"] = 1, 
		["y"] = 0
	}
}

function Board:init(squaresCountX, squaresCountY)
	Board.super.init(self)
	
	self:setCenter(0, 0)
	
	self.squaresCountX = squaresCountX
	self.squaresCountY = squaresCountY
	
	self.squareWidth = self:getSquarePixelWidth(squaresCountX)
	self.squareHeight = self:getSquarePixelHeight(squaresCountY)
	
	self.boardSolution = self:createSolution(self.squaresCountX, self.squaresCountY)
	local shuffledData = self:createShuffledData(self.boardSolution)
	self.boardSquares = self:createBoardSquares(shuffledData)
	
	local boardImage = gfx.image.new(BOARD_WIDTH, BOARD_HEIGHT)
	gfx.pushContext(boardImage)
	-- Debug board bounds
	-- gfx.setColor(gfx.kColorBlack)
	-- gfx.drawRect(0, 0, boardImage.width, boardImage.height)
	gfx.popContext()
	
	self:setImage(boardImage)
	self:moveTo(0, 0)
	-- boardSprite:add()
	
	self.selection = Selection(
		self:getSquarePixelWidth(self.squaresCountX), 
		self:getSquarePixelHeight(self.squaresCountY)
	)
	
	local selectionPos = self:getSelectionPosition(self.selection.squareX, self.selection.squareY)
	self.selection:moveTo(selectionPos.x, selectionPos.y)
	self.selection:add()
end

function Board:reset()
	-- remove old sprites
	self:removeChildren()
	
	-- create new board game
	self.boardSolution = self:createSolution(self.squaresCountX, self.squaresCountY)
	local shuffledData = self:createShuffledData(self.boardSolution)
	self.boardSquares = self:createBoardSquares(shuffledData)
end

function Board:removeChildren()
	for y=1, #self.boardSquares do
		for x=1, #self.boardSquares[y] do
			self.boardSquares[y][x]:remove()
		end
	end
end

function Board:createSolution(squaresCountX, squaresCountY)
	local solution = {}
	for y=1, squaresCountY do
		solution[y] = {}
		for x=1, squaresCountX do
			-- if bottom right corner, set to nil for empty square
			-- otherwise, populate with correct data
			if x == squaresCountX and y == squaresCountY then
				solution[y][x] = nil
			else
				solution[y][x] = x + ((y - 1) * squaresCountX)
			end
		end
	end
	return solution
end

-- Creates and returns a solved board
function Board:createBoardSquares(boardData)
	local squares = {}
	
	for y=1, self.squaresCountY do
		squares[y] = {}
		for x=1, self.squaresCountX do
			local squarePos = self:getSquarePosition(x, y)
			local value = boardData[y][x]
			local squareImage = self:drawSquareImage(boardData[y][x])
			local isEmpty = value == nil
			local square = BoardSquare(self.squareWidth, self.squareHeight, x, y, squarePos.x, squarePos.y, isEmpty, squareImage, value)
			square:add()
			squares[y][x] = square
		end
	end
	return squares
end

-- returns a new shuffled table of board data
function Board:createShuffledData(boardData)
	local shuffledData = {}
	for y=1, #boardData do
		shuffledData[y] = {}
		for x=1, #boardData[y] do
			shuffledData[y][x] = boardData[y][x]
		end
	end
	return shuffledData
end

function Board:shuffleBoard()
	for i=1, SHUFFLE_COUNT do
		print("Shuffle step", i)
		-- find the empty square coordinates
		local emptyCoords = self:findEmptySquareCoords()
		-- pick a random adjacent square
		local adjacentSquare = self:getRandomAdjacentSquare(emptyCoords.x, emptyCoords.y)
		-- move selection
		self.selection.squareX = adjacentSquare.squareX
		self.selection.squareY = adjacentSquare.squareY
		
		local selectionPos = self:getSelectionPosition(self.selection.squareX, self.selection.squareY)
		self.selection:moveTo(selectionPos.x, selectionPos.y)
		-- move square
		-- I need to make a long queue of moves to animate through
		self:moveSelectedPiece(false)
	end
	self:printSquareData()
end

function Board:findEmptySquareCoords()
	for y=1, self.squaresCountY do
		for x=1, self.squaresCountX do
			local square = self.boardSquares[y][x]
			if square.isEmpty then
				return {
					["x"] = x,
					["y"] = y,
				}
			end
		end
	end
	print("Error: couldn't find empty square")
end

function Board:randomAdjancentCoords(x, y)
	local delta = nil
	local i = 1
	while(delta == nil) do
		print("-- random adjacent iteration", i)
		local d = ADJACENT_SQUARES[math.random(1, 4)]
		local newX = x + d.x
		local newY = y + d.y
		print("---- newX", newX, "new Y", newY)
		if self:checkInBounds(newX, newY) == true then
			print("---- in bounds")
			delta = d
		else
			print("---- not in bounds")
			i += 1
		end
	end
	
	return {
		["x"] = x + delta.x,
		["y"] = y + delta.y
	}
end

function Board:getRandomAdjacentSquare(emptyX, emptyY)
	local coords = self:randomAdjancentCoords(emptyX, emptyY)
	return self.boardSquares[coords.y][coords.x]
end

function Board:getSquarePixelWidth(squaresCountX)
	local squarePixelWidth = BOARD_WIDTH / squaresCountX
	squarePixelWidth = squarePixelWidth - 4
	return squarePixelWidth
end

function Board:getSquarePixelHeight(squaresCountY)
	local squarePixelHeight = BOARD_WIDTH / squaresCountY
	squarePixelHeight = squarePixelHeight - 4
	return squarePixelHeight
end

function Board:getSquarePosition(squareX, squareY)
	local posX = (squareX - 1) * self.squareWidth + (SQUARE_GAP * squareX)
	local posY = (squareY - 1) * self.squareHeight + (SQUARE_GAP * squareY)
	return {
		["x"] = posX,
		["y"] = posY,
	}
end

function Board:getSelectionPosition()
	local position = self:getSquarePosition(self.selection.squareX, self.selection.squareY)
	position.x -= 2
	position.y -= 2
	return position
end

function Board:checkInBounds(x, y)
	if x > self.squaresCountX then
		return false
	end
	
	if x < 1 then
		return false
	end
	
	if y > self.squaresCountY then
		return false
	end
	
	if y < 1 then
		return false
	end
	
	return true
end

function Board:moveSelection(deltaSquareX, deltaSquareY)
	local newSquareX = deltaSquareX + self.selection.squareX
	local newSquareY = deltaSquareY + self.selection.squareY
	
	if self:checkInBounds(newSquareX, newSquareY) == false then
		return
	end
	
	self.selection.squareX = newSquareX
	self.selection.squareY = newSquareY
	
	local selectionPos = self:getSelectionPosition(self.selection.squareX, self.selection.squareY)
	self.selection:animateTo(selectionPos.x, selectionPos.y)
end

function Board:drawSquareImage(data)
	return gfx.imageWithText(tostring(data), self.squareWidth, self.squareHeight)
end

function Board:moveSelectedPiece(animated)
	print("Moving piece at", self.selection.squareX, self.selection.squareY)
	-- see if any adjacent piece is empty -1,-1 -> 1,1
	local emptySquare = self:getAdjacentEmpty(self.selection.squareX, self.selection.squareY)
	
	if emptySquare == nil then
		print("-- no nearby empty piece")
		return
	end
	
	local emptyPosition = emptySquare:getPosition()
	print("-- Empty square", emptySquare, emptyPosition.squareX, emptyPosition.squareY)
	-- move piece in data
	local moveSquare = self.boardSquares[self.selection.squareY][self.selection.squareX]
	local movePosition = moveSquare:getPosition()
	self.boardSquares[moveSquare.squareY][moveSquare.squareX] = emptySquare
	self.boardSquares[emptySquare.squareY][emptySquare.squareX] = moveSquare
	-- update data on squares
	emptySquare:setPosition(movePosition, false)
	moveSquare:setPosition(emptyPosition, animated)
end

-- Returns true if solved
function Board:checkIfSolved()
	local matchedSoFar = false
	
	for y=1, #self.boardSolution do
		for x=1, #self.boardSolution[y] do
			if self.boardSolution[y][x] == self.boardSquares[y][x].value then
				matchedSoFar = true
			else
				-- early return, doesn't match
				return false
			end
		end
	end
	return matchedSoFar
end

function Board:printSquareData()
	print("Board data:")
	for y=1, #self.boardSquares do
		for x=1, #self.boardSquares[y] do
			local square = self.boardSquares[y][x]
			print("-- Square at", square.squareX, square.squareY, "empty?", square.isEmpty)
		end
	end
end

function Board:printSquareDataTable()
	print("Board data:")
	local board = {}
	for y=1, #self.boardSquares do
		board[y] = {}
		for x=1, #self.boardSquares[y] do
			local square = self.boardSquares[y][x]
			board[y][x] = square.value
		end
	end
	printTable(board)
end
	
-- Returns nil if nothing nearby is adjancet
-- Otherwise returns the coordinates of the nil piece
function Board:getAdjacentEmpty(squareX, squareY)
	local checkDelta = ADJACENT_SQUARES
	
	-- loop from -1 to 1, skipping 0
	for key, deltaCoord in pairs(checkDelta) do
		local checkSquareX = squareX + deltaCoord.x
		local checkSquareY = squareY + deltaCoord.y
		-- check if in min bounds
		if checkSquareX > 0 and checkSquareY > 0 then
			-- check if in max bounds
			if checkSquareX <= self.squaresCountX and checkSquareY <= self.squaresCountY then
				local square = self.boardSquares[checkSquareY][checkSquareX]
				-- check if the square is empty and movement is possible
				if square.isEmpty then
					return square
				end
			end
		end
	end
	-- no adjacent squares are empty
	return nil
end	

function Board:update()
end