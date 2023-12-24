local oldStashes = {}
local alreadyRegistered = {}

local formatString = function(template, variables)
  return (template:gsub("%${([%w_]+)}", function(match)
      local variable = match
      return variables[variable] or match
  end))
end


local typeOf = type
local extractItems = function(stashID, itemData)

  if not itemData or not itemData[1] then return false, string.format("We cannot find a stash with the ID: %s are you sure it is meant to exist anymore?", stashID); end 
  local items = json.decode(itemData[1].items)
  if not items then return false, string.format("We cannot find a stash with the ID: %s are you sure it is meant to exist anymore?", stashID); end 
  local retData = {}
  for k,v in pairs(items) do 
    retData[#retData + 1] =  {name = v.name, count = v.amount, metadata = v.info} 
  end
  return retData, string.format("Successfully extracted items from stash with ID: %s", stashID)
end


local getOldData = function(tableName, citizenIdColumn, stashIDFormat)
  local SQLRet = MySQL.Sync.fetchAll(string.format("SELECT * FROM `%s`", tableName))
  if SQLRet and SQLRet[1] then
    for k,v in pairs(SQLRet) do 
      local citizenID = v[citizenIdColumn]
      if not oldStashes[citizenID] then oldStashes[citizenID] = {}; end
      local recompStation = getLockerById("recompStation")
      if not alreadyRegistered[citizenID] then 
        recompStation.registerStash(citizenID)
        recompStation.updateStash(citizenID, Config.lockers['recompStation'].size)
        recompStation.clearStash(citizenID)
        alreadyRegistered[citizenID] = true
      end
      local stashID = formatString(stashIDFormat, v)
      local getStashFromSQL      = MySQL.Sync.fetchAll("SELECT items FROM `stashitems` WHERE `stash` = @stash", {['@stash'] = stashID})
      local stashItems, msg      = extractItems(stashID, getStashFromSQL)
      if not stashItems then 
        if Config.recompPrints.error and Config.recompPrints.individuals then print(msg); end
      else
        if Config.recompPrints.success  and Config.recompPrints.individuals then print(msg); end
        for _,item in pairs(stashItems) do 
          oldStashes[citizenID][#oldStashes[citizenID] + 1]    = itemData
          recompStation.addToLocker(citizenID, item)
        end
      end
    end
    return true, string.format("Successfully recomped data from table: %s", tableName)
  else
    return false, string.format("Could not find any data in the table: %s", tableName)
  end
end 

onReady(function()
  if Config.recomp then 
    for tableName, tableData in pairs(Config.recompTables) do 
      local success, msg = getOldData(tableData.initialTable, tableData.charID, tableData.stashIDFormat)
      if success then if Config.recompPrints.success then print(msg); end else if Config.recompPrints.error then print(msg); end end
    end
  end
end)