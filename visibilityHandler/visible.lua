

function visibility:createEntity()
  local entity = {}
  entity.visibilityTable = {}
  function entity:createVisibilityState(state,fn)
    self.visibilityTable[state] = fn
  end
  return entity
end

function visibility:rePosition(x,y,entity)
  entity:moveTo(x,y)
end
  



  

