--[[
This is based on Buckland's implementation of state machines in Chapter 2: State Driven Agent Design from
the book:
  Programming Game AI by Example
Any errors are to be attributed solely to myself and not Buckland or his book
--]]
global_states = require('states')
--[[
function createAI()
  local AI = {}
  function AI:createState(index)
    local state = {}
    state.setTransfers = {}
    state.execute = false
    return state 
  end
  return AI
end
--]]
  

function createTestAI()
  local testAI = global_states:createAI()
  testAI.sum = 0
  testAI.currentState = {}
  testAI.green_state = global_states:createState(1)
  testAI.green_state.execute = function()
    love.graphics.setColor(0,255,0)
    love.graphics.circle('fill',150,150,20)
    testAI.sum = testAI.sum+0.05
  end
  testAI.red_state = global_states:createState(2)
  testAI.red_state.execute = function()
    love.graphics.setColor(250,0,0)
    love.graphics.circle('fill',150,150,20)
    testAI.sum = testAI.sum-0.05
  end
  function testAI:update(dt)
    if testAI.sum > 10 then
      self.currentState = self.red_state
    end
    if testAI.sum < 0 then
      self.currentState = self.green_state
    end
  end
  testAI.currentState = testAI.green_state
  return testAI
end
  




function love.load()
  AI = createTestAI()

end

function love.draw()
  AI.currentState.execute()
end

function love.update(dt)
  AI:update(dt)
end


    
  




  
  


