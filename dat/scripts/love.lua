--[[

Love2d API in Naev!!!!!
Meant to be loaded as a library to run Love2d stuff out of the box.

Example usage would be as follows:
"""
require 'love.lua'
require 'pong.lua'
love.start()
"""

--]]
love = {}

-- defaults
love._font = font.new( 12 )
love._bgcol = colour.new( 0, 0, 0, 1 )
love._fgcol = colour.new( 1, 1, 1, 1 )

function love.conf(t) end -- dummy
function love.load() end --dummy

-- Internal function that connects to Naev
local function _update( dt )
   if love.keyboard._repeat then
      for k,v in pairs(love.keyboard._keystate) do
         if v then
            love.keypressed( k, k, true )
         end
      end
   end

   love.update(dt)
end
function love.update( dt ) end -- dummy


--[[
-- Mouse
--]]
-- Internal function that connects to Naev
love.mouse = {}
love.mouse.x = 0
love.mouse.y = 0
love.mouse.lx = 0
love.mouse.ly = 0
love.mouse.down = {}
local function _mouse( x, y, mtype, button )
   y = love.h-y-1
   love.mouse.x = x
   love.mouse.y = y
   if mtype==1 then
      love.mouse.down[button] = true
      love.mousepressed( x, y, button, false )
   elseif mtype==2 then
      love.mouse.down[button] = false
      love.mousereleased( x, y, button, false )
   elseif mtype==3 then
      local dx = x - love.mouse.lx
      local dy = y - love.mouse.ly
      love.mouse.lx = x
      love.mouse.ly = y
      love.mousemoved( x, y, dx, dy, false )
   end
   return true
end
function love.mouse.getX() return love.mouse.x end
function love.mouse.getY() return love.mouse.y end
function love.mouse.isDown( button ) return love.mouse.down[button]==true end
function love.mousemoved( x, y, dx, dy, istouch ) end -- dummy
function love.mousepressed( x, y, button, istouch ) end -- dummy
function love.mousereleased( x, y, button, istouch ) end -- dummy


--[[
-- Keyboard
--]]
love.keyboard = {}
love.keyboard._keystate = {}
love.keyboard._repeat = false
-- Internal function that connects to Naev
local function _keyboard( pressed, key, mod )
   local k = string.lower( key )
   love.keyboard._keystate[ k ] = pressed
   if pressed then
      love.keypressed( k, k, false )
   else
      love.keyreleased( k, k )
   end
   if key == "Q" then
      tk.customDone()
   end
   return true
end
function love.keypressed( key, scancode, isrepeat ) end -- dummy
function love.keyreleased( key, scancode ) end -- dummy
function love.keyboard.isDown( key )
   return (love.keyboard._keystate[ key ] == true)
end
function love.keyboard.setKeyRepeat( enable )
   love.keyboard._repeat = enable
end


--[[
-- Graphics
--]]
-- Internal function that connects to Naev
local function _draw( x, y, w, h )
   love.x = x
   love.y = y
   love.w = w
   love.h = h
   gfx.renderRect( x, y, w, h, love._bgcol )
   love.draw()
end
love.graphics = {}
love.graphics._dx = 0
love.graphics._dy = 0
local function _mode(m)
   if     m=="fill" then return false
   elseif m=="line" then return true
   else   error( string.format(_("Unknown fill mode '%s'"), mode ) )
   end
end
local function _xy( x, y, w, h )
   return love.x+love.graphics._dx+x, love.y+(love.h-y-h-love.graphics._dy)
end
function love.graphics.getWidth()
   return love.w
end
function love.graphics.getHeight()
   return love.h
end
function love.graphics.origin()
   love.graphics._dx = 0
   love.graphics._dy = 0
end
function love.graphics.translate( dx, dy )
   love.graphics._dx = love.graphics._dx + dx
   love.graphics._dy = love.graphics._dy + dy
end
local function _gcol( c )
   local r, g, b = c:rgb()
   local a = c:alpha()
   return r, g, b, a
end
local function _scol( r, g, b, a )
   if type(r)=="table" then
      a = r[4]
      b = r[3]
      g = r[2]
      r = r[1]
   end
   return colour.new( r, g, b, a or 1 )
end
function love.graphics.getBackgroundColor()
   return _gcol( self._bgcol )
end
function love.graphics.setBackgroundColor( red, green, blue, alpha )
   love._bgcol = _scol( red, green, blue, alpha )
end
function love.graphics.getColor()
   return _gcol( self._fgcol )
end
function love.graphics.setColor( red, green, blue, alpha )
   love._fgcol = _scol( red, green, blue, alpha )
end
function love.graphics.rectangle( mode, x, y, width, height )
   x,y = _xy(x,y,width,height)
   gfx.renderRect( x, y, width, height, love._fgcol, _mode(mode) )
end
function love.graphics.circle( mode, x, y, radius )
   x,y = _xy(x,y,0,0)
   gfx.renderCircle( x, y, radius, love._fgcol, _mode(mode) )   
end
function love.graphics.newImage( filename )
   return tex.open( filename )
end
function love.graphics.draw( drawable, x, y, r, sx, sy )
   local w,h = drawable:dim()
   sx = sx or 1
   sy = sy or sx
   r = r or 0
   x,y = _xy(x,y,w,h)
   w = w*sx
   h = h*sy
   y = y - (h*(1-sy)) -- correct scaling
   gfx.renderTexRaw( drawable, x, y, w, h, 1, 1, 0, 0, 1, 1, love._fgcol, r )
end
function love.graphics.print( text, x, y  )
   x,y = _xy(x,y,limit,love._font:height())
   gfx.printf( love._font, text, x, y, love._fgcol )
end
function love.graphics.printf( text, x, y, limit, align )
   x,y = _xy(x,y,limit,love._font:height())
   if align=="left" then
      gfx.printf( love._font, text, x, y, love._fgcol, limit, false )
   elseif align=="center" then
      gfx.printf( love._font, text, x, y, love._fgcol, limit, true )
   elseif align=="right" then
      local w = gfx.printDim( false, text, limit )
      local off = limit-w
      gfx.printf( love._font, text, x+off, y, love._fgcol, w, false )
   end
end
function love.graphics.newFont( file, size )
   if size==nil then
      return font.new( file )
   elseif type(file)=="userdata" then
      return file
   else
      return font.new( file, size )
   end
end
function love.graphics.setFont( fnt )
   love._font = fnt
end
function love.graphics.setNewFont( file, size )
   love._font = love.graphics.newFont( file, size )
   return love._font
end


--[[
-- Math
--]]
love.math = {}
function love.math.random( min, max )
   if min == nil then
      return rnd.rnd()
   elseif max == nil then
      return rnd.rnd( min-1 )+1
   else
      return rnd.rnd( min, max )
   end
end


--[[
-- Initialize
--]]
function love.start()
   -- Only stuff we care about atm
   local t = {}
   t.audio = {}
   t.window = {}
   t.window.title = "LÖVE" -- The window title (string)
   t.window.width = 800    -- The window width (number)
   t.window.height = 600   -- The window height (number)
   t.modules = {}

   -- Configure
   love.conf(t)

   -- Set properties
   love.title = t.window.title
   love.w = t.window.width
   love.h = t.window.height

   -- Run set up function defined in Love2d spec
   love.load()

   -- Actually run in Naev
   tk.custom( love.title, love.w, love.h, _update, _draw, _keyboard, _mouse )
end

