HC = require 'hardoncollider'
vector = require 'vector'
anim8 = require 'anim8'
camera = require 'camera'
world = require 'world'
global_states = require 'states'
weapon_steering = require 'steering'
--local loader = require "AdvTiledLoader/Loader"
--loader.path = "maps/"

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


    

function on_collide(dt,shape_a,shape_b)
  local other
  Hero:collide(dt,shape_a,shape_b)
  for i, v in pairs(Snails) do
    v:collide(dt,shape_a,shape_b)
    if (v.dead == true) then
      table.remove(Snails,i)
    end
  end
  --[[
  for i,v in pairs(powerups) do
    if shape_a == v.box and shape_b == Hero.box then
      v.execute(Hero)
      table.remove(powerups,i)
    elseif shape_a == Hero.box and shape_b == v.box then
      v.execute(Hero)
      table.remove(powerups,i)
    end
  end
  --]]  
  
  for i, v in pairs(uncleTeds) do

    v:collide(dt,shape_a,shape_b)
    if v.dead == true then
      sounds["killUncleTed"]:play()
      table.remove(uncleTeds,i)
    end

      
  end
  for i, v in pairs(senatorDredds) do
    v:collide(dt,shape_a,shape_b)
    if v.dead == true then
      sounds["killSenatorDredd"]:play()
      table.remove(senatorDredds,i)
    end
  end
  senatorDreddBoss:collide(dt,shape_a,shape_b)
  for i,v in pairs(projectiles) do
    v:collide(dt,shape_a,shape_b)
  end
end

function on_stop(dt,shape_a,shape_b)
 
  
  for i,v in pairs(uncleTeds) do
    v:on_stop(dt,shape_a,shape_b)
  end
  for i,v in pairs(senatorDredds) do
    v:on_stop(dt,shape_a,shape_b)
  end
  senatorDreddBoss:on_stop(dt,shape_a,shape_b)
end

function createProjectile(entity, target)
  local projectile = {}
  projectile.animations = {}
  projectile.images = {}
  projectile.target = target
  print("creating projectile at: ")
  print(tostring(entity.pos.x))
  print(tostring(entity.pos.y))
  projectile.steering_strategy = weapon_steering:createVehicle(entity.pos.x,entity.pos.y,entity.index)
  projectile.steering_strategy.maxSpeed = 300.0
  projectile.steering_strategy.vel = vector(200.0,100.0)
  --projectile.steering_strategy.pos = entity.pos
  projectile.box = Collider:addRectangle(entity.pos.x+32, entity.pos.y+32,32,32)
  local projectileImage = love.graphics.newImage('anim/Fireball.png')
  local projectileGrid = anim8.newGrid(32,32,projectileImage:getWidth(),projectileImage:getHeight())
  local projectileAnimation = anim8.newAnimation(projectileGrid('1-9',1),0.1)
  projectile.animations["default"] = projectileAnimation
  projectile.images["default"] = projectileImage
  --projectile.steering_strategy.pos = vector(entity.pos.x,entity.pos.y)
  --projectile.steering_strategy.vel = vector(1.0,0.0)
 -- projectile.steering_strategy.heading = vector(1.0,0.0)
 -- projectile.steering_strategy.seekRadius = 100.0
  --print("projectile created")
  function projectile:update(dt)
    print("projectile updating")
    --projectile.target.heading = projectile.target.vel:normalized()
    --projectile.target.speed = projectile.target.vel:len()
    
    self.steering_strategy.vel = self.steering_strategy.steeringBehaviors:pursuit(Hero)
    --print("projectile speed")
    --print(tostring(self.steering_strategy.vel:len()))
    self.steering_strategy:update(dt)
    --[[print("self.steering_strategy.pos x and y")
    print(tostring(self.steering_strategy.pos.x))
    print(tostring(self.steering_strategy.pos.y))
    print(tostring(self.steering_strategy.vel.x*dt))
    print(tostring(self.steering_strategy.vel.y*dt))
    print("self.target.pos x,y")
    print(tostring(self.target.pos.x))
    print(tostring(self.target.pos.y))
    print(tostring(self.target.vel.x*dt))
    print(tostring(self.target.vel.y*dt))--]]
    
    --self.steering_strategy.heading = self.steering_strategy.vel:normalized()
    --self.steering_strategy.speed = self.steering_strategy.vel:len()
    --print("speed of projectile")
    --print(tostring(self.steering_strategy.vel:len()))
    --self.steering_strategy.pos = self.steering_strategy.pos + self.steering_strategy.vel*dt
    self.box:moveTo(self.steering_strategy.pos.x+32,self.steering_strategy.pos.y+32)
    projectile.animations["default"]:update(dt)
   -- print("projectile updated")
  end
  function projectile:draw()
      local r,g,b = love.graphics.getColor()
      love.graphics.setColor(0,0,0)
      if debug then
        self.box:draw('line')
      end
      love.graphics.setColor(r,g,b)
      --love.graphics.circle('fill', self.steering_strategy.pos.x, self.steering_strategy.pos.y,100,100)
      self.animations["default"]:draw(self.images["default"],self.steering_strategy.pos.x, self.steering_strategy.pos.y,0,1,1)
      --print("projectile drawn")
  end
    function projectile:collide(dt,shape_a,shape_b)
    --rint("projectile collide")
   local other
    if shape_a == self.box then
       other = shape_b
    elseif shape_b == self.box then
      other = shape_a
    else
      return
    end
    if other == Hero.box then
      print("hit hero")
      sounds["heroHitHard"]:play()
      --if (not invincibility) then
      Hero.health = Hero.health - 50
      --end
    end
  end
    
    
  return projectile
end
function love.load()
  debug = false
  invincibility = false
  lost = false
  complete = false
  level = {}
  sounds = {}
  local sound1 = love.audio.newSource("sounds/win.wav")
  local sound2 = love.audio.newSource("sounds/ding.wav")
  local sound3 = love.audio.newSource("sounds/gameover.wav")
  local sound4 = love.audio.newSource("sounds/jump.wav")
  local sound5 = love.audio.newSource("sounds/uncleTedHit.wav")
  local sound6 = love.audio.newSource("sounds/heroHit.wav")
  local sound7 = love.audio.newSource("sounds/grabsSnail.wav")
  local sound8 = love.audio.newSource("sounds/throwsSnail.wav")
  local sound9 = love.audio.newSource("sounds/heroDies.wav")
  local sound10 = love.audio.newSource("sounds/killsUncleTed.wav")
  local sound11 = love.audio.newSource("sounds/killsSenatorDredd.wav")
  local sound12 = love.audio.newSource("sounds/senatorDreddHit.wav")
  local sound13 = love.audio.newSource("sounds/heroHitHard.wav")
  sound6:setLooping(false)
  sound3:setLooping(false)
  sounds["win"] = sound1
  sounds["ding"] = sound2
  sounds["gameover"] = sound3
  sounds["jump"] = sound4
  sounds["uncleTedHit"] = sound5
  sounds["heroHit"] = sound6
  
  sounds["grabSnail"] = sound7
  sounds["throwSnail"] = sound8
  sounds["heroDies"] = sound9
  sounds["killUncleTed"] = sound10
  sounds["killSenatorDredd"] = sound11
  sounds["senatorDreddHit"] = sound12
  sounds["heroHitHard"] = sound13
  level.maxX = 5000
  level.maxY = love.window.getHeight()
  screenheight = 1280
  screenwidth = 960
  blockHeight = 20
  success = love.window.setMode(screenheight,screenwidth)
  numSnails = 20 
  --numTeds = 5
  numDredds = 1
  Snails = {}
  uncleTeds = {}
  snailBoxes = {}
  senatorDredds = {}
  projectiles = {}
  powerups = {}
  gravityoff = 0
  Entities = {} 
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
 
    Collider = HC(100,on_collide,on_stop)
     Hero = createHero()
     --uncleTed = createUncleTed()
  heroBox = Collider:addRectangle(Hero.pos.x, Hero.pos.y, 30,38)
  playercam = camera.new()
  playercam.pos = vector(Hero.pos.x, Hero.pos.y - 400)
 
  
  --[[for i = 1, numSnails do
  xp = math.random(50)
  yp = math.random(50)
  Snails[i] = createSnail(xp*50,yp*50,i)
  Snails[i].box = Collider:addRectangle(Snails[i].pos.x,Snails[i].pos.y,32,32)
 end--]]
 --for i = 1, numTeds do
 --  xp = math.random(numTeds)
  -- yp = math.random(numTeds)
  -- uncleTeds[i] = createUncleTed(xp*50,yp*50,i)
  --end
  gravity = vector(0,200)
  
  for i = 1, numDredds do
    xp = 200
    yp = 200
    senatorDredds[i] = createSenatorDredd(xp,yp,i,false)
  end
    
  
  Platforms = {}
  wallCreator = createWallCreator()
  wallCreator:addWall(100,500,100)
  wallCreator:addWall(200,300,100)
  wallCreator:addWallWithHeight(500,540,30,60)
  wallCreator:addWall(0,level.maxY,level.maxX) 
  --wallCreator:createSteps(100,500,100,5,1)
 -- wallCreator:createSteps(800,10,100,5,-1)
 -- wallCreator:createSteps(1000,10,100,10,1)
  for i = 1,20 do
    wallCreator:addWall(200*i,300,100)
    if (i%2 == 0) then
      wallCreator:addWall(200*i,530,100)
    end

  end
  wallLeft = Collider:addRectangle(-50,0,50,1280)
  wallRight = Collider:addRectangle(level.maxX,0,50,level.maxY)
  senatorDreddBoss = createSenatorDredd(200*22,200,#senatorDredds+1,true)
  wallCreator:addEnemyPlatform(200*21,200,800,senatorDreddBoss)
  
  --bigPlatform = Collider:addRectangle(100,100,100,50)
  
end

function coinFlip()
  local coinResult = love.math.random( )
  local resultVector = false
  if coinResult >= 0.5 then
    resultVector = vector(1.0,0.0)
  else
    resultVector = vector(-1.0,0.0)
  end
  return resultVector
end
  

  
function createPowerUp(x,y,powerUpType) 
  local powerup = {}
  powerup.box = Collider:addRectangle(x,y,64,64)
  if powerUpType == "health10" then
    powerup.execute = function(entity)
      entity.health = entity.health+10
       sounds["ding"]:play()
    end
    powerup.image = "anim/health10.png"
    powerup.draw = function() 
    
      local im = love.graphics.newImage(powerup.image)
      local r,g,b = love.graphics.getColor()
      love.graphics.setColor(255,255,255)
      love.graphics.draw(im,x,y)
      if debug then
        love.graphics.setColor(0,0,0)
        powerup.box:draw('line')
       
      end
      love.graphics.setColor(r,g,b)
    end
  elseif powerUpType == "health20" then
    powerup.execute = function(entity)
      entity.health = entity.health+20
      sounds["ding"]:play()
    end
    powerup.image = "anim/health20.png"
    powerup.draw = function()
      local im = love.graphics.newImage(powerup.image)
      local r,g,b = love.graphics.getColor()
      love.graphics.setColor(255,255,255)
      love.graphics.draw(im,x,y)
      if debug then
        love.graphics.setColor(0,0,0)
        powerup.box:draw('line')
      end
      love.graphics.setColor(r,g,b)
    end
  end
  
  --  senatorDredd.box = Collider:addRectangle(senatorDredd.pos.x+32*5/2, senatorDredd.pos.y+32*5/2,32*5,32*5)
  powerups[#powerups+1] = powerup
end

  
  
function createSenatorDredd(xp,yp,i,bossBool)
  local senatorDredd = {}
  senatorDredd.bound = false
  senatorDredd.boundLeft = false
  senatorDredd.boundRight = false
  senatorDredd.currentState = false
  senatorDredd.boss = bossBool
  senatorDredd.maxSpeed = 50
  senatorDredd.pos = vector(xp,yp)
  senatorDredd.vel = vector(senatorDredd.maxSpeed,0.0)
  senatorDredd.animations = {}
  senatorDredd.images = {}
  senatorDredd.health = 200
  senatorDredd.dead = false
  senatorDredd.box = true
  senatorDredd.id = i
  senatorDredd.bombs = 1
  senatorDredd.steering="wander"
  senatorDredd.wanderWaitTime=2
  senatorDredd.sleepStartTime = love.timer.getTime()
  senatorDredd.defaultState = global_states.createState()
  senatorDredd.heading = vector(0.0,0.0)
  
  senatorDredd.defaultState.execute = function()
    senatorDredd.steering = "wander"
    if senatorDredd.wanderWait then
      local etime = love.timer.getTime()
      if etime - senatorDredd.sleepStartTime > senatorDredd.wanderWaitTime then
        senatorDredd.wanderWait = false
        senatorDredd.vel = senatorDredd.vel:normalized() * senatorDredd.maxSpeed/2.0 * -1
      end
    else
      senatorDredd.wanderWait = true
      senatorDredd.sleepStartTime = love.timer.getTime()
    end
  end
  senatorDredd.currentState = senatorDredd.defaultState
  senatorDredd.HeroVisibleState = global_states:createState()
  senatorDredd.HeroVisibleState.execute = function()
    senatorDredd.steering = "hero_visible"
    local toHero = vector(0.0,0.0)
    toHero.x =  Hero.pos.x - senatorDredd.pos.x
    if (toHero.x > 0) then
      toHero.x = 1.0
    else
      toHero.x = -1.0
    end
    senatorDredd.vel = senatorDredd.maxSpeed*toHero
  end
  local senatorDreddWanderImage = love.graphics.newImage('anim/senatorDreddWanderImage.png')
  local senatorDreddWanderGrid = anim8.newGrid(32,32,senatorDreddWanderImage:getWidth(),senatorDreddWanderImage:getHeight())
  local senatorDreddWanderAnimation = anim8.newAnimation(senatorDreddWanderGrid('1-13',1),0.1)
  
  local senatorDreddHeroVisibleImage = love.graphics.newImage('anim/SenatorDreddWanderImage.png')
  local senatorDreddHeroVisibleGrid = anim8.newGrid(32,32,senatorDreddWanderImage:getWidth(),senatorDreddWanderImage:getHeight())
  local senatorDreddHeroVisibleAnimation = anim8.newAnimation(senatorDreddWanderGrid('1-13',1),0.02)
  
  senatorDredd.animations["wander"] = senatorDreddWanderAnimation
  senatorDredd.images["wander"] = senatorDreddWanderImage
  senatorDredd.animations["hero_visible"] = senatorDreddHeroVisibleAnimation
  senatorDredd.images["hero_visible"] = senatorDreddHeroVisibleImage
  senatorDredd.box = Collider:addRectangle(senatorDredd.pos.x+32*5/2, senatorDredd.pos.y+32*5/2,32*5,32*5)
  senatorDredd.vision_circle = Collider:addCircle(senatorDredd.pos.x,senatorDredd.pos.y,400)
  function senatorDredd:update(dt)
    if (senatorDredd.dead) then
        
    end
    self.animations[self.steering]:update(dt)
    self.currentState.execute()
    local onPlatform = checkPlatformCollision(senatorDredd.box)
    
    
    if (onPlatform == 0) then
      self.vel = self.vel+gravity*10*dt
    else 
      self.vel.y = 0
    end
    if self.bound then
      local hitsBound = checkBoundCollision(senatorDredd,senatorDredd.box)
      if hitsBound == -1 or hitsBound == 1 then
        self.vel.x = self.vel.x*-1
        self.vel.y = 0
      end
    end
    self.heading = self.vel:normalized()
    self.pos = self.pos + self.vel*dt
    self.box:moveTo(self.pos.x+32*5/2,self.pos.y+32*5/2)
    self.vision_circle:moveTo(self.pos.x+32*5/2, self.pos.y+32*5/2)
  end
   function senatorDredd:fire()
    if #projectiles < self.bombs then
    -- print ("fired")
     local fireball = createProjectile(senatorDredd,Hero)
     --fireball.target = Hero
     projectiles[#projectiles+1]= fireball
    end
    end
     
   function senatorDredd:draw()
    local senatorDreddHealth = tostring(senatorDredd.health)
    local r,g,b = love.graphics.getColor()
    love.graphics.setColor(0,0,0)
    love.graphics.print(senatorDreddHealth,senatorDredd.pos.x,senatorDredd.pos.y-10,0,2,2)
    love.graphics.setColor(r,g,b)
    self.animations[self.steering]:draw(self.images[self.steering],self.pos.x, self.pos.y,0,5,5)
    if debug then
    self.box:draw('line')
    end
    if (self.steering == "hero_visible") then
      love.graphics.setColor(255,0,0)
    end
    if debug then
    self.vision_circle:draw('line')
    end
    love.graphics.setColor(255,255,255)
  end
  function senatorDredd:collide(dt,shape_a,shape_b)
   local other
    if shape_a == self.box then
       other = shape_b
    elseif shape_b == self.box then
      other = shape_a
    end
    if shape_a == self.vision_circle and shape_b == Hero.box or shape_b == self.vision_circle and shape_a == Hero.box then
      --print("uncleTed vision_circle collide")
      self.currentState = self.HeroVisibleState
     -- print("projectiles present:")
     -- print(tostring(#projectiles))
      if #projectiles < 1 then
        self:fire()
      end
    end
    if (other == wallLeft) then
      self.vel.x = -1*self.vel.x
      self.animations[self.steering]:flipH()
    end
    if (other == wallRight) then
      self.vel.x = -1*self.vel.x
      self.vel.y = -1*self.vel.y
      self.animations[self.steering]:flipH()
    end
    if self.bound then
      if other == self.boundLeft then
        self.vel.x = -1*self.vel.x
      end
      if other == self.boundRight then
        self.vel.x = -1*self.vel.x
      end
    end
    for i, v in pairs(Snails) do
      if (other == v.box and v.thrown) then
        self.health = self.health - 50
        sounds["senatorDreddHit"]:play()
        self.bombs = self.bombs + 1
        self.vel = -1*self.vel
        --table.remove(Snails,i)
        v.dead = true
        if (self.health <= 0) then
          if self.boss then
            complete = true
            sounds["win"]:play()
            --self.bombs = self.bombs + 1
          end
          sounds["killSenatorDredd"]:play()
          self.dead = true
        end
      end
    end
  end
  function senatorDredd:on_stop(dt,shape_a,shape_b)
    local other
    if shape_a == self.vision_circle then
      shape_b = other
    elseif shape_b == self.vision_circle then
      shape_a = other
    else
      return
    end
    if other==Hero.box then
      senatorDredd.currentState = senatorDredd.defaultState
    end
  end
  --print("uncleTed vision_circle stop")
  return senatorDredd
end
  
function createUncleTed(xp,yp,i)
  local uncleTed = {}
  uncleTed.currentState = false
  uncleTed.maxSpeed = 200.0
  uncleTed.pos = vector(xp,yp)
  uncleTed.vel = vector(uncleTed.maxSpeed/2,0.0)
  uncleTed.animations = {}
  uncleTed.images = {}
  uncleTed.health = 100
  uncleTed.dead = false
  uncleTed.box = true
  uncleTed.id = i
    uncleTed.steering="wander"
  uncleTed.wanderWaitTime = 2
  uncleTed.wanderWait = false
  uncleTed.sleepStartTime = love.timer.getTime()
  uncleTed.defaultState = global_states:createState()
  uncleTed.defaultState.execute = function() 
    uncleTed.steering = "wander"
    --uncleTed.vel.x = uncleTed.maxSpeed/2.0
    if uncleTed.wanderWait then
          local etime = love.timer.getTime()
          if etime - uncleTed.sleepStartTime > uncleTed.wanderWaitTime then
            uncleTed.wanderWait = false  
          uncleTed.vel = uncleTed.vel:normalized() * uncleTed.maxSpeed/2.0 * -1
            end
    else
         uncleTed.wanderWait = true
        uncleTed.sleepStartTime = love.timer.getTime( )
    end
   
  end
  uncleTed.currentState = uncleTed.defaultState
  uncleTed.HeroVisibleState = global_states:createState()
  uncleTed.HeroVisibleState.execute = function()
    uncleTed.steering = "hero_visible"
    local toHero = vector(0.0,0.0)
    toHero.x =  Hero.pos.x - uncleTed.pos.x
    if (toHero.x > 0) then
      toHero.x = 1.0
    else
      toHero.x = -1.0
    end
    uncleTed.vel = uncleTed.maxSpeed*toHero
  end
  
  
  local uncleTedWanderImage = love.graphics.newImage('anim/uncleTedWanderImage.png')
  local uncleTedWanderGrid = anim8.newGrid(64,64,uncleTedWanderImage:getWidth(),uncleTedWanderImage:getHeight())
  local uncleTedWanderAnimation = anim8.newAnimation(uncleTedWanderGrid('1-3',1),0.1)
    
  local uncleTedDeadImage = love.graphics.newImage('anim/uncleTedDeadImage.png')
  local uncleTedDeadGrid = anim8.newGrid(64,64,uncleTedDeadImage:getWidth(),uncleTedDeadImage:getHeight())
  local uncleTedDeadAnimation = anim8.newAnimation(uncleTedDeadGrid('1-16',1),0.1)
    
    local uncleTedHeroVisibleImage = love.graphics.newImage('anim/uncleTedWanderImage.png')
  local uncleTedHeroVisibleGrid = anim8.newGrid(64,64,uncleTedWanderImage:getWidth(),uncleTedWanderImage:getHeight())
  local uncleTedHeroVisibleAnimation = anim8.newAnimation(uncleTedWanderGrid('1-3',1),0.025)  
  
  uncleTed.animations["wander"] = uncleTedWanderAnimation
  uncleTed.images["wander"] = uncleTedWanderImage
  --uncleTedHeroVisibleAnimation = uncleTedWanderAnimation
  --uncleTedHeroVisibleImage = uncleTedWanderImage
  uncleTed.animations["hero_visible"] = uncleTedHeroVisibleAnimation
  uncleTed.images["hero_visible"] = uncleTedHeroVisibleImage
  uncleTed.box = Collider:addRectangle(uncleTed.pos.x+32, uncleTed.pos.y+32,64,64)
  uncleTed.vision_circle = Collider:addCircle(uncleTed.pos.x,uncleTed.pos.y,400)
  function uncleTed:update(dt)
    if (uncleTed.dead) then
        
    end
    self.animations[self.steering]:update(dt)
    self.currentState.execute()
    local onPlatform = checkPlatformCollision(uncleTed.box)

    if (onPlatform == 0) then
      self.vel = self.vel+gravity*10*dt
    else 
      self.vel.y = 0
    end
    
    
    self.pos = self.pos + self.vel*dt
    self.box:moveTo(self.pos.x+32,self.pos.y+32)
    self.vision_circle:moveTo(self.pos.x+32, self.pos.y+32)
  end
  function uncleTed:draw()
    local uncleTedHealth = tostring(uncleTed.health)
    local r,g,b = love.graphics.getColor()
    love.graphics.setColor(0,0,0)
    love.graphics.print(uncleTedHealth,uncleTed.pos.x,uncleTed.pos.y-30,0,2,2)
    love.graphics.setColor(r,g,b)
    self.animations[self.steering]:draw(self.images[self.steering],self.pos.x, self.pos.y)
    if debug then
    self.box:draw('line')
    end
    if (self.steering == "hero_visible") then
      love.graphics.setColor(255,0,0)
    end
    if debug then
    self.vision_circle:draw('line')
    end
    love.graphics.setColor(255,255,255)
  end
  function uncleTed:collide(dt,shape_a,shape_b)
   local other
    if shape_a == self.box then
       other = shape_b
    elseif shape_b == self.box then
      other = shape_a
    elseif shape_a == self.vision_circle and shape_b == Hero.box or shape_b == self.vision_circle and shape_a == Hero.box then
      --print("uncleTed vision_circle collide")
      uncleTed.currentState = uncleTed.HeroVisibleState
    end
     
    
    if (other == wallLeft) then
      self.vel.x = -1*self.vel.x
      self.animations[self.steering]:flipH()
    end
    if (other == wallRight) then
      self.vel.x = -1*self.vel.x
      self.vel.y = -1*self.vel.y
      self.animations[self.steering]:flipH()
    end
    for i, v in pairs(Snails) do
      if (other == v.box and v.thrown) then
        self.health = self.health - 50
        self.vel = -1*self.vel
        --table.remove(Snails,i)
        v.dead = true
        if (self.health <= 0) then
          self.dead = true
          sounds["killUncleTed"]:play()
        end
      end
    end
  end
  function uncleTed:on_stop(dt,shape_a,shape_b)
    local other
    if shape_a == self.vision_circle then
      shape_b = other
    elseif shape_b == self.vision_circle then
      shape_a = other
    else
      return
    end
    if other==Hero.box then
      uncleTed.currentState = uncleTed.defaultState
    end
  end
  --print("uncleTed vision_circle stop")
  return uncleTed 
end



function createWallCreator()
  local wallCreator = {}
  wallCreator.standardHeight = 20
  wallCreator.boundHeight = 100
  wallCreator.walls = {}
  wallCreator.walloutlines = {}
  function wallCreator:addWall(x,y,width)
      local prob = love.math.random(10)
       if prob == 1 then
        uncleTeds[#uncleTeds+1] = createUncleTed(x+1/2*width,y-10,#uncleTeds+1)
        
      end
      if prob > 2 and prob < 6 then
        Snails[#Snails+1] = createSnail(x+1/2*width,y-10,#Snails+1)
      end
      if prob > 7 and prob < 10 then
        createPowerUp(x+1/2*width,y-10,"health10")
      end
      if prob == 10 then
        createPowerUp(x+1/2*width,y-10,"health20")
      end
          --function createUncleTed(xp,yp,i)
      local wall = Collider:addRectangle(x,y,width,self.standardHeight)
      local walloutline = {x,y,width,self.standardHeight}
      local index = #self.walls+1
      self.walls[index] = wall
      self.walloutlines[index] = walloutline
  end
  function wallCreator:addEnemyPlatform(x,y,width,enemy)
    local wall = Collider:addRectangle(x,y,width,self.standardHeight)
    local boundLeft = Collider:addRectangle(x,y,width,self.boundHeight)
    local boundRight = Collider:addRectangle(x+width,y,width,self.boundHeight)
    enemy.bound = true
    enemy.boundLeft = boundLeft
    enemy.boundRight = boundRight
    local walloutline = {x,y,width,self.standardHeight}
    local index = #self.walls+1
    self.walls[index] = wall
    self.walloutlines[index] = walloutline
  end
  function wallCreator:addWallWithHeight(x,y,width,height)
    local wall = Collider:addRectangle(x,y,width,height)
    local walloutline = {x,y,width,height}
    local index = #self.walls+1
    self.walloutlines[index] = walloutline
    self.walls[index] = wall
  end
  
  function wallCreator:createSteps(x,y,width,numSteps,dir)
    newx = x
    newy = y
    if dir == 1 then
    for i=1,numSteps do
        local wall = Collider:addRectangle(newx, newy, width, self.standardHeight)
        local walloutline = {newx, newy, width, self.standardHeight}
        local index = #self.walls+1
        self.walls[index] = wall
        self.walloutlines[index] = walloutline
        newx = newx + 1.5*width
        newy = newy - 2*self.standardHeight
    end
    elseif dir == -1 then
      for i=1,numSteps do
        local wall = Collider:addRectangle(newx-width,newy,width,self.standardHeight)
        local walloutline = {newx-width,newy,width,self.standardHeight}
        local index = #self.walls+1
        self.walls[index] = wall 
        self.walloutlines[index] = walloutline
        newx = newx - 1.5*width
        newy = newy - 2*self.standardHeight
      end
    end
  end
  
  function wallCreator:draw()
    for i, v in pairs(self.walls) do
      love.graphics.setColor(255,255,255)
      v:draw('fill')
      love.graphics.setColor(0,0,0)
      local voutline = self.walloutlines[i]
      love.graphics.rectangle('line',voutline[1],voutline[2],voutline[3],voutline[4])
    end
  end
    
return wallCreator
end
--[[ from 4849/Code/Love/camdemo/main.lua --]]
function draw()

	-- draw playfield
	love.graphics.setColor ( 255,255,255 )
	love.graphics.line ( 0, level.maxY, level.maxX, level.maxY)

	-- draw obstacles
	love.graphics.setColor ( 255,0,0 )

	-- draw player
	love.graphics.setColor ( 0,255, 0 )
	--love.graphics.circle("fill", player.pos.x, player.pos.y-player.radius, player.radius )
end
--[[ end from --]]
function love.draw()
  playercam:attach()
  if (lost) then
    local deadrot = 0
    local xval = Hero.pos.x
    local yval = Hero.pos.y-400
    
    for i=1,8 do
      love.graphics.setColor(0,0,0)
      love.graphics.print("DEAD!",xval,yval,deadrot+(i*math.pi/4),10,10)
    end
    
  elseif (complete) then
       local completerotate = 0
    local xval = Hero.pos.x
    local yval = Hero.pos.y-400
    
    for i=1,8 do
      love.graphics.setColor(0,0,0)
      love.graphics.print("COMPLETE!",xval,yval,completerotate+(i*math.pi/4),10,10)
    end
  else
    
    love.graphics.setBackgroundColor(0,255,255,100)
  --[[ from camdemo/main.lua --]]
  --playercam:attach()
  wallCreator:draw()
  wallLeft:draw('line')
  wallRight:draw('line')
  local r,g,b = love.graphics.getColor()
  love.graphics.setColor(0,0,0)
  love.graphics.print(tostring(Hero.health),Hero.pos.x-600,Hero.pos.y-800,0,10,10)
  love.graphics.setColor(r,g,b)
  if debug then
  
  heroBox:draw('line')
end
for i,v in pairs(powerups) do
  v:draw()
end
love.graphics.setColor(0,255,255)
  Hero:draw()
  for i, v in pairs(uncleTeds) do
    love.graphics.setColor(0,255,255)
   v:draw()
  end
  for i, v in pairs(Snails) do
    love.graphics.setColor(0,255,255)
    v:draw()
    if debug then
    v.box:draw('line')
    end
  end
  for i,v in pairs(senatorDredds) do
    love.graphics.setColor(0,255,255)
    v:draw()
    if debug then
      v.box:draw('line')
    end
  end
  senatorDreddBoss:draw()
  if debug then
    senatorDreddBoss.box:draw('line')
  end
  for i,v in pairs(projectiles) do
    love.graphics.setColor(0,255,255)
    v:draw()
    if debug then
      v.box:draw('line')
    end
  end
  
    
        
  end
  playercam:detach()
  end
  
    
    


function love.update(dt)
  --print("uncle teds")
  --print(tostring(#uncleTeds))
  if Hero.health > 0 then
  Hero:update(dt)
  for i, v in pairs(uncleTeds) do
  v:update(dt)
end
  for i,v in pairs(Snails) do
  v:update(dt)
end

  for i,v in pairs(senatorDredds) do
    v:update(dt)
  end
  senatorDreddBoss:update(dt)
  for i,v in pairs(projectiles) do
    v:update(dt)
    --print(v.speed)
  end
else
  sounds["gameover"]:play()
  lost = true
  end 
 
 
 --[[
 from 4849\Code\Love\camdemo\main.lua
 --]]
 	--[[local t = love.timer.getTime()
	love.graphics.setBackgroundColor ( 	127 + 64 * (math.sin(t)+1),
										127 + 64 * (math.sin(1.6*t)+1),
										127 + 64 * (math.sin(3.14159*t)+1)) 
  --[[
  end of code from 4849\Love\camdemo\main.lua
  --]]
 --]]
 Collider:update(dt)

end

--[[ from 4849\Code\Love\camdemo\main.lua --]]
function drawBackground(seed)
	-- draw background
	love.math.setRandomSeed ( seed )
	for i=1,300 do
		love.graphics.setColor ( love.math.random(100,255),
								love.math.random(100,255),
								love.math.random(100,255))
		love.graphics.circle ( "fill", love.math.random(-300,level.maxX),
										love.math.random(-love.window.getHeight(),love.window.getHeight()*2),
										200 )
	end
end
--[[ end from 4849\Code\Love\camdemo\main.lua --]]

function checkBoundCollision(entity,entitybox)
  local hitsBound = 0
  if entitybox:collidesWith(entity.boundLeft) then
    hitsBound = -1
  elseif entitybox:collidesWith(entity.boundRight) then
    hitsBound = 1
  end
  return hitsBound
end

function checkPlatformCollision(entitybox)
    local onPlatform = 0
      for i,v in ipairs(wallCreator.walls) do
        local x,y = v:center()
        local ex, ey = entitybox:center()
        if entitybox:collidesWith(v) and y > ey then
          onPlatform = i
          break
        end
      end
 
    return onPlatform
end
function createHero()
  local Hero = {}
  Hero.images = {}
  Hero.animations = {}
  Hero.health = 100
  Hero.currentState = "wander"
  Hero.vel = vector(0,0)
  Hero.pos = vector(love.window.getWidth()/2, level.maxY-100)
  Hero.caughtSnail = false
  Hero.jumpImpulse = -1800
  Hero.movementMagnitude = 50
  Hero.left = vector(-1,0)
  Hero.right = vector(1,0)
  Hero.acc = vector(0.0,0.0)
  Hero.maxacc = 10
  Hero.velMax = 600
  Hero.maxSpeed = 600
  Hero.heading = vector(0.0,0.0)
  Hero.speed = Hero.vel:len()
  Hero.catchSnail = false
  Hero.throwSnail = false
  local heroWanderImage = love.graphics.newImage('anim/heroWanderImage.png')
  local heroWanderGrid = anim8.newGrid(30,38,heroWanderImage:getWidth(),heroWanderImage:getHeight())
  local heroWanderAnimation = anim8.newAnimation(heroWanderGrid('1-6',1),0.1)
  Hero.animations["wander"] = heroWanderAnimation
  Hero.images["wander"] = heroWanderImage
  function Hero:collide(dt,shape_a,shape_b)
  local other
  if shape_a == heroBox then
    other = shape_b
  elseif shape_b == heroBox then
    other = shape_a
  else
    return
  end
   
    if (other == wallLeft) then
      Hero.vel.x = -1*Hero.vel.x
      self.animations[self.currentState]:flipH()
    end
    if (other == wallRight) then
      Hero.vel.x = -1*Hero.vel.x
      self.animations[self.currentState]:flipH()
    end
    for i, v in pairs(uncleTeds) do
      if other == v.box then
        Hero.vel.x = v.vel.x*10
        Hero.vel.y = -1*v.vel.x*5
        if (not invincibility) then
          sounds["heroHit"]:play()
      Hero.health = Hero.health - 10
      end
    elseif other == v.vision_circle then
      v.currentState = v.HeroVisibleState
    end
  end
    if other == senatorDreddBoss.box then
        Hero.vel.x = senatorDreddBoss.vel.x*10
        Hero.vel.y = -1*senatorDreddBoss.vel.x*5
        --if (not invincibility) then
      Hero.health = Hero.health - 10
      --end
    end
    if other == senatorDreddBoss.vision_circle then
      senatorDreddBoss.currentState = senatorDreddBoss.HeroVisibleState
      if #projectiles < senatorDreddBoss.bombs then
      senatorDreddBoss:fire()
    end
    
    end
  for i,v in pairs(projectiles) do
    if other == v.box then
      Hero.health = Hero.health-50
      sounds["heroHitHard"]:play()
      table.remove(projectiles,i)
    end
  end
  for i,v in pairs(powerups) do
    if other == v.box then
      v.execute(Hero)
      table.remove(powerups,i)
    end
  end
      for i, v in pairs(senatorDredds) do
      if other == v.box then
        Hero.vel.x = v.vel.x*10
        Hero.vel.y = -1*v.vel.x*5
        if (not invincibility) then
      Hero.health = Hero.health - 10
      sounds["heroHit"]:play()
      end
    elseif other == v.vision_circle then
      v.currentState = v.HeroVisibleState
    end
  end
    for i, v in pairs(Snails) do
    
    if (other == v.box) then
      if (not self.catchSnail) then
      v:changeState("runaway")
      elseif (not self.caughtSnail) then
        v:changeState("caught")
        v.caught = true
        sounds["grabSnail"]:play()
        self.caughtSnail = v
        break
      
    end
  end
  
      
    
    
    for i, v in ipairs(wallCreator.walls) do
      if (other == v) then
        
        Hero.vel.y = 0
      end
    end
  end
  end
  function Hero:update(dt)
    if self.caughtSnail == 0 then
    self.catchSnail = false
    end
    self.throwSnail = false
    self.animations[self.currentState]:update(dt)  
    if (love.keyboard.isDown(" ")) then
        if (self.vel.y == 0) then
          self:jump()
        end
    end
    if (love.keyboard.isDown('lctrl') and (not self.throwSnail) and (not self.catchSnail)) then
      self.catchSnail = true
    end
    if (love.keyboard.isDown('rctrl') and self.catchSnail) then
      self.throwSnail = true
      sounds["throwSnail"]:play()
      self.catchSnail = false
    end
    if love.keyboard.isDown("a") then 
      if (self.vel:len() < self.velMax) then
        self.vel.x = self.vel.x-400*dt
        self.speed = self.vel:len()
        self.heading = self.vel:normalized()
      else
        self.vel = self.vel:normalized()*self.velMax*.9
        self.speed = self.vel:len()
        self.heading = self.vel:normalized()
      end
    elseif love.keyboard.isDown("d") then
      if (self.vel:len() < self.velMax) then
        self.vel.x = self.vel.x+400*dt
        self.speed = self.vel:len()
        self.heading = self.vel:normalized()
      else
        self.vel = self.vel:normalized()*self.velMax*.9
        self.speed = self.vel:len()
        self.heading = self.vel:normalized()
      end
    else 
      self.vel = self.vel*.9
      self.speed = self.vel:len()
      self.heading = self.vel:normalized()
    end
    
 if love.keyboard.isDown('f1') then
    debug = true
 elseif love.keyboard.isDown('f2') then
   debug = false
   invincibility = false
elseif love.keyboard.isDown('f3') then
  invincibility = true
  
  end
    
  
 if (love.keyboard.isDown('right') and self.catchSnail and self.caughtSnail) then
    self.caughtSnail.theta = self.caughtSnail.theta+math.pi/2*dt
    self.caughtSnail.addToCaught = vector(-32*math.sin(self.caughtSnail.theta), 32*math.cos(self.caughtSnail.theta))
  
  
elseif (love.keyboard.isDown('left') and self.catchSnail and self.caughtSnail) then
    self.caughtSnail.theta = self.caughtSnail.theta-math.pi/2*dt
    self.caughtSnail.addToCaught = vector(-32*math.sin(self.caughtSnail.theta), 32*math.cos(self.caughtSnail.theta))
  
 end
  
    local onPlatform = checkPlatformCollision(heroBox)
 
  
  if (onPlatform == 0) then
      self.vel = self.vel+gravity*10*dt
  end
    
    self.heading = self.vel:normalized()
    self.speed = self.vel:len()
    self.pos = self.pos + self.vel*dt
    heroBox:move(self.vel.x*dt,self.vel.y*dt)
    --playercam.pos = self.pos
  --  playercam:move(dt*5, dt*5)
    --playercam:lookAt(self.pos.x,self.pos.y)
    playercam:move(self.vel.x*dt,self.vel.y*dt)
  --backgroundcam.pos.x = Hero.pos.x
  --backgroundcam2.pos.x = Hero.pos.x
      

  end
  function Hero:jump()
    if self.vel.y == 0 then
      self.vel.y = self.jumpImpulse
      sounds["jump"]:play()
    end
  end
  
  function Hero:draw()
    self.animations[self.currentState]:draw(self.images[self.currentState],Hero.pos.x, Hero.pos.y)
    xypos = tostring(math.floor(Hero.pos.x)) .. "," .. tostring(math.floor(Hero.pos.y))
    love.graphics.setColor(0,0,0)
    love.graphics.print(xypos,Hero.pos.x,Hero.pos.y-20)
    --playercam:draw(draw)
 --    backgroundcam:draw(function() drawBackground(57) end)
 -- backgroundcam2:draw(function() drawBackground(99) end)
  --playercam:draw(draw)
  end
  
  return Hero
end



function createSnail(x,y,i)
  local Snail = {}
  Snail.box = Collider:addRectangle(x,y,32,32)
  Snail.id = i
  Snail.addToCaught = vector(0.0,0.0)
  Snail.pos = vector(x,y)
  Snail.vel = vector(100,0.0)

  Snail.theta = -1/2*math.pi
  Snail.images = {}
  Snail.animations = {}
  Snail.currentState = "wander"
  Snail.caught = false
 Snail.thrown = false
  local snailRunawayImage = love.graphics.newImage('anim/snailRunawayImage.png')
  local snailRunawayGrid = anim8.newGrid(32,32,snailRunawayImage:getWidth(),snailRunawayImage:getHeight())
  local snailRunawayAnimation = anim8.newAnimation(snailRunawayGrid('1-18',1),0.1)
  Snail.images["runaway"] = snailRunawayImage
  Snail.animations["runaway"] = snailRunawayAnimation
  
  local snailCaughtImage = love.graphics.newImage('anim/snailCaughtImage.png')
  local snailCaughtGrid = anim8.newGrid(32,32,snailCaughtImage:getWidth(),snailCaughtImage:getHeight())
  local snailCaughtAnimation = anim8.newAnimation(snailCaughtGrid('1-9',1),0.1)
  Snail.images["caught"] = snailCaughtImage
  Snail.animations["caught"] = snailCaughtAnimation
  
  local snailThrownImage = love.graphics.newImage('anim/snailThrownImage.png')
  local snailThrownGrid = anim8.newGrid(32,32,snailThrownImage:getWidth(),snailThrownImage:getWidth())
  local snailThrownAnimation = anim8.newAnimation(snailThrownGrid('1-12',1),0.1)
  Snail.images["thrown"] = snailThrownImage
  Snail.animations["thrown"] = snailThrownAnimation
  
  
  Snail.images["dying"] = snailDyingImage
  Snail.animations["dying"] = snailDyingAnimation
  snailWanderImage = love.graphics.newImage('anim/snailWanderImage.png')
  Snail.images["wander"] = snailWanderImage
  local snailWanderGrid = anim8.newGrid(32,32,snailWanderImage:getWidth(),snailWanderImage:getHeight())
  local snailWanderAnimation = anim8.newAnimation(snailWanderGrid('1-12',1),0.1)
  snailWanderAnimation:flipH()
  Snail.animations["wander"] = snailWanderAnimation


  snailPanicImage = love.graphics.newImage('anim/snailPanicImage.png')
  local snailPanicGrid = anim8.newGrid(32,32,snailPanicImage:getWidth(),snailPanicImage:getHeight())
  snailPanicAnimation = anim8.newAnimation(snailPanicGrid('1-12',1),0.1)
  Snail.images["panic"] = snailPanicImage
  Snail.animations["panic"] = snailPanicAnimation
  function Snail:collide(dt,shape_a,shape_b)
  local other

  if shape_a == self.box then
    other = shape_b
  elseif shape_b == self.box then
    other = shape_a
  else
    return
  end
    for i,v in pairs(uncleTeds) do
    if other == v.box then
      if self.thrown then
      v.health = v.health - 50 -- uncleTed should have 100 health
      sounds["uncleTedHit"]:play()
      if v.health <= 0 then
        sounds["killUncleTed"]:play()
        table.remove(uncleTeds,i)
        
      end
        self.thrown = false
      else
        self.vel = -1*self.vel
      end
    end 
   end
   for i,v in pairs(projectiles) do
     if other == v.box then
       if self.thrown then
         table.remove(projectiles,i)
        end
      end
    end
    --[[for i, v in pairs(Snails) do
    
      
    if other == v.box and Hero.caughtSnail ~= v then
    end
    end--]]
    if (other == wallLeft) then
      
      self.vel.x = -1*self.vel.x
      self.animations[self.currentState]:flipH()
    end
    if (other == wallRight) then
      self.vel.x = -1*self.vel.x
     self.animations[self.currentState]:flipH()
    end
    if (other == heroBox) then
      if (not self.caught) then
        
        self.vel.x = self.vel.x*-1
        self.animations[self.currentState]:flipH()
      end
    end
       for i, v in ipairs(wallCreator.walls) do
      if (other == v and not (self.thrown)) then
        
        self.vel.y = 0
      elseif (other == v and (self.thrown)) then
        self.vel = self.vel*-1

      end
    end
  end
  --function Snail:panic()
    
  function Snail:update(dt)
    if (Hero.throwSnail and Hero.caughtSnail == self) then
      self.vel.x = -400*math.sin(self.theta) 
      self.vel.y = 400*math.cos(self.theta) 
      self.caught = false
      Hero.throwSnail = false
      self.thrown = true
      Hero.caughtSnail = false
      
    end
    
      
      self.animations[self.currentState]:update(dt)
     
if self.caught then
  self.pos.y = Hero.pos.y+self.addToCaught.y
  self.pos.x = Hero.pos.x+self.addToCaught.x
  self.box:moveTo(self.pos.x,self.pos.y)
  
  else
      local onPlatform = checkPlatformCollision(self.box)
     if (onPlatform == 0 and (not self.thrown)) then
       self.vel = self.vel+gravity*10*dt
    elseif (onPlatform ~= 0 and not(self.thrown)) then
      self.vel.y = 0
    
    elseif (self.thrown and onPlatform == 0) then
      
    
    elseif (self.thrown and onPlatform ~= 0) then
      self.vel = self.vel*-1
    end
  end
      self.pos = self.pos + self.vel*dt 
      self.box:move(self.vel.x*dt,self.vel.y*dt)
      
  end
  
  function Snail:changeState(state)
    self.currentState = state
  end
  function Snail:draw()
    self.animations[self.currentState]:draw(self.images[self.currentState],self.pos.x, self.pos.y)
  end
  return Snail
end