local getInteractOptions = function(id)
  local self = lockers[id]
  return {
    {
      label = "Open Locker", 
      icon  = "fas fa-door-open",
      canInteract = function() 
        if not self.buyable or self.bought then return true; end 
        return false
      end,

      action = function()
        local stashID = string.format("%s_%s", self.id, myCID)
        Core.Inventory.Open(stashID, {Slots = self.size.slots, Weight = self.size.weight})
        
      end,
    },
    {
      label = string.format("Buy Locker | $%s | Weight:%s", self.buyable, self.size.weight/1000), 
      icon  = "fas fa-door-open",
      canInteract = function() 
        if not self.buyable or self.bought then return false; end
        return true 
      end,

      action = function()
        TriggerServerEvent("dirk-lockers:buyLocker", self.id)
      end,
    },
  }
end

local newLocker = function(id,data)
  local self = {}
  self.id        = id
  self.modelType = data.modelType
  self.label     = data.label
  self.model     = data.model
  self.pos       = data.pos
  self.size      = data.size
  self.buyable   = data.buyable
  self.blip      = data.blip or false

  --## get from server
  self.bought    = data.bought or false


  self.update = function(data)
    for k,v in pairs(data) do 
      self[k] = v
    end
  end

  self.createBlip = function()
    if not self.blip then return false; end 
    Core.Blips.Register(self.id, {
      Pos        = self.pos,
      Sprite     = self.blip.sprite,
      Color      = self.blip.color,
      Scale      = self.blip.scale,
      Text       = self.label, 
      Display    = self.blip.display,
      ShortRange = self.blip.shortRange,
      canSee     = function()
        if not self.buyable or self.bought then return true; end 
        return false
      end,
    })
   
  end

  self.spawnModel = function()  
    if not self.model then return false; end
    Core.Objects.Register(self.id, {
      Type         = self.modelType,
      Pos          = vector4(self.pos.x, self.pos.y, self.pos.z - 1.0, self.pos.w),
      Model        = self.model,
      InteractDist = ((not Settings.UsingTarget and 1.5) or false), 
      RenderDist   = 50.0, 
      },function(callback, entData)
      if callback == "spawn" then 
        FreezeEntityPosition(entData.entity, true)
        SetEntityInvincible(entData.entity, true)
        SetBlockingOfNonTemporaryEvents(entData.entity, true)
        SetPedCanBeTargetted(entData.entity, false)
        local options = getInteractOptions(self.id)
        Core.Target.AddEntity(entData.entity, {
          Local    = true,
          Options  = options, 
          Distance = 1.5, 
        })
      end
    end)
  end

  self.addInteractionPoint = function()
    local options = getInteractOptions(self.id)
    if not Config.usingTarget then 
      Core.Menus.Register(self.id, {
        Options  = options, 
        Pos      = self.pos,
        Distance = 1.5, 
      })
    else
      if not self.model then 
        Core.Target.AddBoxZone(self.id, {
          Position = position,
          Distance = 2.5, 
          Height   = 2.0, 
          Width    = 2.0, 
          Length   = 2.0, 
          Options  = options, 
        })
      end
    end
  end

  lockers[self.id] = self
  return self
end

RegisterNetEvent('dirk-lockers:update', function(id,data)
  local locker = lockers[id]
  if not locker then return false; end
  locker.update(data)
end)

onReady(function()
  local serverData = Core.SyncCallback('dirk-lockers:get')
  for id,data in pairs(serverData) do 
    local locker = newLocker(id,data)
    locker.spawnModel()
    locker.addInteractionPoint()
    locker.createBlip()
  end
end)



