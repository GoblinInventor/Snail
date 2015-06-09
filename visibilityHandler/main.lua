HC = require('hardoncollider')

local text = {}


function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    if shape_a == circle_vision then
      color = 1
    end
    text[#text+1] = string.format("Colliding. mtv = (%s,%s)", 
                                    mtv_x, mtv_y)
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
  if shape_a == circle_vision then
    color = 2
   end
   text[#text+1] = "Stopped colliding"
end

function love.load()
  color = 1
  Collider = HC(100,on_collision,collision_stop)
  circle_vision = Collider:addCircle(400,300,200)
  mouse = Collider:addCircle(100,300,20)
  mouse:moveTo(love.mouse.getPosition())
end

function love.update(dt)

mouse:moveTo(love.mouse.getPosition())
circle_vision:rotate(dt)
Collider:update(dt)

while #text > 40 do
        table.remove(text, 1)
    end
end

function love.draw()
    -- print messages
    for i = 1,#text do
        love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        love.graphics.print(text[#text - (i-1)], 10, i * 15)
    end

    -- shapes can be drawn to the screen
    --love.graphics.setColor(255,255,255)
    if color == 1 then
      love.graphics.setColor(255,0,0)
    elseif color == 2 then
      love.graphics.setColor(0,255,0)
    end
    circle_vision:draw('fill')
    mouse:draw('fill')
end

  




