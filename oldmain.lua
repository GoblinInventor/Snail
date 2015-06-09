HC = require "hardoncollider"
vector = require "vector"
anim8 = require 'anim8'
local loader = require "AdvTiledLoader/Loader"
loader.path = "maps/"

--[[
The jumping and platform elements are based on 
http://www.headchant.com/2012/01/06/tutorial-creating-a-platformer-with-love-part-1/
and use the hardoncollider

The anim8 tutorial on github
(https://github.com/kikito/anim8)
is what I have based my sprite sheet use on

The hardoncollider code is heavily influenced by the
tutorial the original coder wrote at
http://vrld.github.io/HardonCollider/tutorial.html

--]]
--[[
function on_hero_collide(dt,shape_a,shape_b)
  local other
  if shape_a == heroBox then
    other = shape_b
  elseif shape_b == heroBox then
    other = shape_a
  else
    return
  end
    if (other == groundWall) then
      Hero.vel.y = 0
    end
    if (other == wallLeft) then
      Hero.vel.x = -1*Hero.vel.x
    end
    if (other == wallRight) then
      Hero.vel.x = -1*Hero.vel.x
    end
    if (other == snailBox) then
      Hero.vel.x = Hero.vel.x*-1
    end
  end
--]]



    
--[[
function on_collide(dt,shape_a,shape_b)
  local other
  Hero:collide(dt,shape_a,shape_b)
  Snail:collide(dt,shape_a,shape_b)
end
--]]
function love.load()
  
  map = loader.load("map1.tmx")
  
  
  --[[
  gravityoff = 0
  Entities = {} 
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
  Hero = createHero()
  Snail = createSnail()
  -- placeholders
  theHeroCounter = 0
  theSnailCounter = 0
  gravity = vector(0,200)
  
  Collider = HC(100,on_collide)
  Platforms = {}
  wallCreator = createWallCreator()
  wallCreator:addWall(100,300,100,100)
  wallCreator:addWall(200,300,100,100)

  heroBox = Collider:addRectangle(Hero.pos.x-30, Hero.pos.y-30, 30,38)
  --wallLeft = Collider:addRectangle(-100,0,100,600)
  --wallRight = Collider:addRectangle(800,0,100,600)
  wallLeft = Collider:addRectangle(0,0,50,600)
  wallRight = Collider:addRectangle(750,0,50,600)
  groundWall = Collider:addRectangle(0,550,800,50)
  snailBox = Collider:addRectangle(Snail.pos.x-30,Snail.pos.y-40,32,32)
  image = love.graphics.newImage('anim/newdudehero.png')
  image2 = love.graphics.newImage('anim/slugmonster5.png')
  local g = anim8.newGrid(30,38,image:getWidth(),image:getHeight())
  local g2 = anim8.newGrid(32,32,image2:getWidth(),image2:getHeight())
  animation = anim8.newAnimation(g('1-6',1),0.1)
  animation2 = anim8.newAnimation(g2('1-12',1),0.1)
  --]]
end
--[[
function createWallCreator()
  local wallCreator = {}
  wallCreator.walls = {}
  function wallCreator:addWall(x,y,width,height)
      local wall = Collider:addRectangle(x,y,width,height)
      self.walls[#self.walls+1] = wall
  end
  --    wallLeft:draw('line')

  function wallCreator:draw()
    for i, v in ipairs(self.walls) do
      v:draw('line')
    end
  end
    
return wallCreator
end
--]]
function love.draw()
  map:draw()
    --love.graphics.circle("fill",screenWidth/2,20,30,100)
 --[[       heroBox:draw('line')

    Hero:draw()
    Snail:draw()
    wallCreator:draw()
    snailBox:draw('line')
    groundWall:draw('line')
    wallLeft:draw('line')
    wallRight:draw('line')
    animation:draw(image,Hero.pos.x,Hero.pos.y,2*math.pi,1,1,32,32)
    animation2:draw(image2,Snail.pos.x, Snail.pos.y, 2*math.pi, 1,1,32,32)
    --]]
end

function love.update(dt)
--[[  Hero:update(dt)
Collider:update(dt)
  
  Snail:update(dt)
  animation:update(dt)  
  animation2:update(dt)
  --heroBox:move(Hero.vel.x*dt,Hero.vel.y*dt)
  --ollider:update(dt)
--]]
end
--[[
function love.keypressed(key)
  if key == " " then
    if Hero.vel.y == 0 then
      Hero.vel.y = Hero.jumpImpulse
    end
  end
  if (key == "a") then
      if (Hero.vel:len2() < Hero.velMax) then
        Hero.vel.x = Hero.vel.x-100*dt
      else
        Hero.vel = Hero.vel:normalized()*Hero.velMax
      end
  elseif (key == "d") then
    if (Hero.vel:len2() < Hero.velMax) then
        Hero.vel.x = Hero.vel.x+100*dt
    else
        Hero.vel = Hero.vel:normalized()*self.velMax
    end
  end
end
--]]


--[[
function createHero()
  local Hero = {}
  Hero.vel = vector(0,0)
  Hero.pos = vector(100,400)
  Hero.jumpImpulse = -3000
  Hero.movementMagnitude = 50
  Hero.left = vector(-1,0)
  Hero.right = vector(1,0)
  Hero.acc = vector(0.0,0.0)
  Hero.maxacc = 10
  Hero.velMax = 600
  function Hero:collide(dt,shape_a,shape_b)
  local other
  if shape_a == heroBox then
    other = shape_b
  elseif shape_b == heroBox then
    other = shape_a
  else
    return
  end
    if (other == groundWall) then
      Hero.vel.y = 0
    end
    if (other == wallLeft) then
      Hero.vel.x = -1*Hero.vel.x
    end
    if (other == wallRight) then
      Hero.vel.x = -1*Hero.vel.x
    end
    if (other == snailBox) then
      Hero.vel.x = Hero.vel.x*-1
    end
    for i, v in ipairs(wallCreator.walls) do
      if (other == v) then
        
        Hero.vel.y = 0
      end
    end
  end
  function Hero:update(dt)
        
    if (love.keyboard.isDown(" ")) then
        Hero:jump()
    end
  
    if love.keyboard.isDown("a") then 
      if (self.vel:len() < self.velMax) then
        self.vel.x = self.vel.x-400*dt
      else
        self.vel = self.vel:normalized()*self.velMax*.9
      end
    --self.pos = self.pos + self.movementMagnitude*self.left*self.vel*dt
    elseif love.keyboard.isDown("d") then
      if (self.vel:len() < self.velMax) then
        self.vel.x = self.vel.x+400*dt
      else
        self.vel = self.vel:normalized()*self.velMax*.9
      --self.vel = self.vel + self.left*self.movementMagnitude*dt
      --self.pos = self.pos + self.movementMagnitude*self.right*dt
      end
    else
      self.vel = self.vel*.9
    end
    
    --if self.vel.y ~= 0 then
      
      --self.pos = self.pos + self.vel*dt
      --self.vel = self.vel+gravity*10*dt
      --if (self.pos.y > screenHeight-100) then
        --self.pos.y = screenHeight-100
        --heroBox:moveTo(Hero.pos.x,Hero.pos.y)
        --self.vel.y = 0
        
      --end
    --end
    if gravityoff == 0 then
      self.vel = self.vel-gravity*10*dt
      gravityoff = 1
    end
    if self.vel.y ~= 0 then
      self.vel = self.vel+gravity*10*dt
    end
      
    
    self.pos = self.pos + self.vel*dt
    heroBox:move(self.vel.x*dt,self.vel.y*dt)

  end
  function Hero:jump()
    if self.vel.y == 0 then
      self.vel.y = self.jumpImpulse
    end
  end
  --end
  --[[function Hero:accLeft()
    if self.vel.x > 0 then
     -- self.vel.x = self.vel.x - 400
    end
  end
  function Hero:accRight()
    if self.vel.x < 0 then
     -- self.vel.x = self.vel.x + 400
    end
  end--]]
  function Hero:draw()
    animation:draw(image,Hero.pos.x, Hero.pos.y)
    --love.graphics.circle("fill",Hero.pos.x,Hero.pos.y,50,100)
  end
  
  return Hero
end
--]]

--[[
function createSnail()
  local Snail = {}
  Snail.counter = 0
  Snail.pos = vector(100,500)
  Snail.vel = vector(100,0.0)
  
  function Snail:collide(dt,shape_a,shape_b)
  local other
  if shape_a == snailBox then
    other = shape_b
  elseif shape_b == snailBox then
    other = shape_a
  else
    return
  end
    if (other == groundWall) then
      Snail.vel.y = 0
    end
    if (other == wallLeft) then
      Snail.vel.x = -1*Snail.vel.x
    end
    if (other == wallRight) then
      Snail.vel.x = -1*Snail.vel.x
    end
    if (other == heroBox) then
      Snail.vel.x = Snail.vel.x*-1
    end
  end
  function Snail:update(dt)
     -- if (self.pos.x > 600) then
     --   self.vel.x = -1*self.vel.x
     -- elseif (self.pos.x < 0) then
      --  self.vel.x = -1*self.vel.x
      --end
      self.pos = self.pos + self.vel*dt 
      snailBox:move(self.vel.x*dt,self.vel.y*dt)
      --self.counter = self.counter + 1
  end
  function Snail:draw()
  --  love.graphics.circle("fill",0,0,100,100)
  end
  return Snail
end
--]]
--[[
function love.keypressed(key)
  if (key == " ") then
    Hero:jump()
  elseif (key == 'a') then
    Hero:accLeft()
  elseif (key == 'd') then
    Hero:accRight()
  end
end
--]]