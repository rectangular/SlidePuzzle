import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animator"
import "CoreLibs/animation"

import "board-square.lua"
import "selection.lua"

class('Board').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local BOARD_WIDTH = 240
local BOARD_HEIGHT = 240

local SQUARE_GAP = 3

function Board:init(squaresCountX, squaresCountY)
	Board.super.init(self)
	
	self:setCenter(0, 0)
	
	self.squaresCountX = squaresCountX
	self.squaresCountY = squaresCountY
	
	self.squareWidth = self:getSquarePixelWidth(squaresCountX)
	self.squareHeight = self:getSquarePixelHeight(squaresCountY)
	
	self.boardSolution = self:createSolution(self.squaresCountX, self.squaresCountY)
	local shuffledData = self:shuffleSquares(self.boardSolution)
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

function Board:createSolution(squaresCountX, squaresCountY)
	local solution = {}
	for y=1, squaresCountY
	do
		solution[y] = {}
		for x=1, squaresCountX
		do
			-- if bottom right corner, set to nil for empty square
			-- otherwise, populate with correct data
			if x == squaresCountX and y == squaresCountY
			then
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
	
	for y=1, self.squaresCountY
	do
		squares[y] = {}
		for x=1, self.squaresCountX
		do
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
function Board:shuffleSquares(boardData)
	local shuffledData = {}
	for y=1, #boardData
	do
		shuffledData[y] = {}
		for x=1, #boardData[y]
		do
			shuffledData[y][x] = boardData[y][x]
		end
	end
	
	self:shuffle(shuffledData)
	for y=1, #shuffledData
	do
		self:shuffle(shuffledData[y])
	end
	return shuffledData
end

function Board:shuffle(x)
	for i=#x, 2, -1 
	do
		local j = math.random(i)
		x[i], x[j] = x[j], x[i]
	end
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

function Board:moveSelection(deltaSquareX, deltaSquareY)
	local newSquareX = deltaSquareX + self.selection.squareX
	local newSquareY = deltaSquareY + self.selection.squareY
	
	if newSquareX > self.squaresCountX
	then
		return
		-- newSquareX = self.squaresCountX
	end
	
	if newSquareX < 1
	then
		return
		-- newSquareX = 1
	end
	
	if newSquareY > self.squaresCountY
	then
		return
		-- newSquareY = self.squaresCountY
	end
	
	if newSquareY < 1
	then
		return
		-- newSquareY = 1
	end
	
	self.selection.squareX = newSquareX
	self.selection.squareY = newSquareY
	
	local selectionPos = self:getSelectionPosition(self.selection.squareX, self.selection.squareY)
	self.selection:animateTo(selectionPos.x, selectionPos.y)
end

function Board:drawSquareImage(data)
	return gfx.imageWithText(tostring(data), self.squareWidth, self.squareHeight)
end

function Board:moveSelectedPiece()
	print("Moving piece at", self.selection.squareX, self.selection.squareY)
	-- see if any adjacent piece is empty -1,-1 -> 1,1
	local emptySquare = self:getAdjacentEmpty(self.selection.squareX, self.selection.squareY)
	if emptySquare == nil
	then
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
	moveSquare:setPosition(emptyPosition, true)
end

-- Returns true if solved
function Board:checkIfSolved()
	local matchedSoFar = false
	for y=1, #self.boardSolution
	do
		for x=1, #self.boardSolution[y]
		do
			if self.boardSolution[y][x] == self.boardSquares[y][x].value
			then
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
	for y=1, #self.boardSquares
	do
		for x=1, #self.boardSquares[y]
		do
			local square = self.boardSquares[y][x]
			print("-- Square at", square.squareX, square.squareY, "empty?", square.isEmpty)
		end
	end
end

function Board:printSquareDataTable()
	print("Board data:")
	local board = {}
	for y=1, #self.boardSquares
	do
		board[y] = {}
		for x=1, #self.boardSquares[y]
		do
			local square = self.boardSquares[y][x]
			board[y][x] = square.value
		end
	end
	printTable(board)
end
	

-- Returns nil if nothing nearby is adjancet
-- Otherwise returns the coordinates of the nil piece
function Board:getAdjacentEmpty(squareX, squareY)
	
	local checkDelta = {
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
	-- loop from -1 to 1, skipping 0
	for key, deltaCoord in pairs(checkDelta)
	do
		local checkSquareX = squareX + deltaCoord.x
		local checkSquareY = squareY + deltaCoord.y
		-- check if in min bounds
		if checkSquareX > 0 and checkSquareY > 0
		then
			-- check if in max bounds
			if checkSquareX <= self.squaresCountX and checkSquareY <= self.squaresCountY
			then
				local square = self.boardSquares[checkSquareY][checkSquareX]
				-- check if the square is empty and movement is possible
				if square.isEmpty
				then
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