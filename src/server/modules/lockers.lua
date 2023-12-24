local toSync = {
  'id',
  'label',
  'modelType',
  'model',
  'pos',
  'size',
  'buyable',
  'blip',
}

local toSave = {"owners"}

local saveAll = function()
  local data = {}
  for id, locker in pairs(Config.lockers) do 
    data[id] = locker.getSaveData()
  end
  Core.Files.Save("lockers.json", data)
end


local newLocker = function(id,data)
  local self = {}
  self.id        = id
  self.label     = data.label
  self.modelType = data.modelType
  self.model     = data.model
  self.pos       = data.pos
  self.size      = data.size
  self.buyable   = data.buyable
  self.owners    = data.owners or {}
  self.blip      = data.blip or false


  self.getDataForClient = function(player)
    local id = Core.Player.Id(player)
    local retData = {}
    for k,v in pairs(toSync) do 
      retData[v] = self[v]
    end
    retData.bought = self.owners[id] and true or false
    return retData
  end

  self.getSaveData = function()
    local retData = {}
    for k,v in pairs(toSave) do 
      retData[v] = self[v]
    end
    return retData
  end

  self.isOwner = function(player)
    local id = Core.Player.Id(player)
    return self.owners[id] and true or false
  end

  self.buyLocker = function(player)
    if not self.buyable then return false, "You cannot buy this locker"; end
    local id = Core.Player.Id(player)
    if self.owners[id] then return false, "You already own this locker"; end
    local price = self.buyable and self.buyable or false
    if price and not Core.Player.HasMoneyInAccount(tonumber(player), Config.buyAccount, price) then return false, "You do not have enough money"; end
    if price then Core.Player.RemoveMoney(tonumber(player), Config.buyAccount, price); end
    self.registerStash(player)
    TriggerClientEvent('dirk-lockers:update', tonumber(player), self.id, {bought = true})
    saveAll()
    return true, "You have bought this locker"
  end


  self.addToLocker = function(player, item)
    local id = type(player) == "number" and Core.Player.Id(player) or player
    local stashID = string.format("%s_%s", self.id, id)
    local stash = Core.Inventory.GetById(stashID)
    stash.addItem(item.name, item.count, item.metadata)
  end

  self.clearStash    = function(player)
    local id = type(player) == "number" and Core.Player.Id(player) or player
    local stashID = string.format("%s_%s", self.id, id)
    local stash = Core.Inventory.GetById(stashID)
    stash.clearInventory()
  end

  self.updateStash = function(player, newSize)
    local id = type(player) == "number" and Core.Player.Id(player) or player
    local stashID =  string.format("%s_%s", self.id, id)
    exports.ox_inventory:SetSlotCount(stashID, newSize.slots)
    exports.ox_inventory:SetMaxWeight(stashID, newSize.weight)
  end

  self.registerStash = function(player)
    local id = type(player) == "number" and Core.Player.Id(player) or player
    local stashID = string.format("%s_%s", self.id, id)
    local existing = exports.ox_inventory:GetInventory(stashID, false)
    if existing then return false end
    if not Settings or not Settings.Inventory then Core,Settings = exports['dirk-core']:getCore(); end
    self.owners[id] = true
    if Settings.Inventory == "ox_inventory" then 
      exports.ox_inventory:RegisterStash(stashID, self.label, self.size.slots, self.size.weight)
      return true, "Stash registered"
    end
  end


  lockers[self.id] = self
  return self
end

getLockerById = function(id)
  return lockers[id]
end

local onConnect = function(source)
  local src = source
  local id = Core.Player.Id(src)
  for id, locker in pairs(lockers) do 
    if not locker.buyable and not locker.owners[id] then 
      local success, msg = locker.registerStash(src)
      if msg then print(msg); end
    end
  end
  return true
end

local dataLoaded = false
onReady(function()
  local rawData = Core.Files.Load("lockers.json") or {}

  for id, locker in pairs(Config.lockers) do 
    local oldData = rawData[id] or {}
    if rawData[id] then 
      for k,v in pairs(toSave) do 
        locker[v] = oldData[v]
      end
    end
    local thisLocker = newLocker(id, locker)    
  end

  dataLoaded = true

  Core.Callback("dirk-lockers:get", function(src,cb)
    while not dataLoaded do Wait(500); end
    local task = onConnect(src)
    while not task do Wait(10); end
    local data = {}
    for id, locker in pairs(lockers) do 
      data[id] = locker.getDataForClient(src)
    end
    cb(data)
  end)
end)

