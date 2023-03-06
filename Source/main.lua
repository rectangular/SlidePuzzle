-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "Sprites/board"
import "Sprites/hud"

local gfx <const> = playdate.graphics

local level = 1
local BOARD_SQUARES_WIDTH = 3
local BOARD_SQUARES_HEIGHT = 3

local board = Board(BOARD_SQUARES_WIDTH, BOARD_SQUARES_HEIGHT)
local hud = Hud(level)

local myInputHandlers = {

	AButtonDown = function()
		-- move the piece; if the game isn't already solved
		if board:checkIfSolved() == false
		then
			board:moveSelectedPiece()
		end
		-- then check if it's solved
		if board:checkIfSolved() == true
		then
			hud.isSolved = true
		end
	end,
	
	BButtonDown = function()
		print("TODO: B function")
	end,

	downButtonUp = function()
		board:moveSelection(0, 1)
	end,
	
	upButtonUp = function()
		board:moveSelection(0, -1)
	end,
	
	leftButtonUp = function()
		board:moveSelection(-1, 0)
	end,
	
	rightButtonUp = function()
		board:moveSelection(1, 0)
	end,
}

-- A function to set up our game environment.

function myGameSetUp()
	
	playdate.inputHandlers.push(myInputHandlers)
	
	local menu = playdate.getSystemMenu()
	menu:addMenuItem("Reset game", 
		function ()
			board:reset()
			hud.isSolved = false
		end
	)
	
	menu:addOptionsMenuItem("Grid size", {2, 3, 4, 5, 6, 7, 8, 9}, 2,
		function (selection)
			print("Not implemented yet")
			print("Grid size selected", selection)
		end
	)

	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			-- x,y,width,height is the updated area in sprite-local coordinates
			-- The clip rect is already set to this area, so we don't need to set it ourselves
			
			-- gfx.clear(gfx.kColorWhite)

			gfx.pushContext()
			gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
			gfx.fillRect(0, 0, 400, 240)
			gfx.popContext()
		end
	)
	
	board:add()
	hud:add()
end

myGameSetUp()

function playdate.update()
	
	gfx.sprite.update()
	playdate.timer.updateTimers()
end