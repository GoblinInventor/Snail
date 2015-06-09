local global_states = {}

function global_states:createState(index)
  local state = {}
  state.index = index
  state.enter = false
  state.exit = false
  state.execute = false
  return state
end

function global_states:createAI()
  local AI = {}
  function AI:createState(index)
    local state = {}
    state.transferUpdates = {}
    state.execute = false
    return state 
  end
  return AI
end



return global_states

