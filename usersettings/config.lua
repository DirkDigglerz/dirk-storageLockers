Config = {
  usingTarget  = true,
  
  
  recomp       = true,  --## Autorecomps from stashitems and vaults to this resource
  recompPrints = {success = true, error = true, individuals = true}, --## Prints to console when recomping
  recompTables = {
    ['Apartments'] = {initialTable = "apartments",            charID = "citizenid", stashIDFormat =  "${name}"},
    ['Vaults']     = {initialTable = "vaults",                charID = "citizenid", stashIDFormat =  "${storage_location}_${storagename}_${citizenid}"},
    ['Houses']     = {initialTable = "player_houses_old",     charID = "citizenid", stashIDFormat =  "${house}"},
  },  --## Tables to attempt recomp from

  lockers = {

    ['recompStation'] = {
      label     = "Recomp Station",
      modelType = "ped",
      model     = "a_f_m_bevhills_01",                                           --## Can be false will just be a spot you go to
      pos       = vector4(-75.79, -818.19, 326.18, 190.7),                 --## Position of ped or interactSpot
      size      = {weight = 90000000, slots = 500},
      blip      =  {scale = 0.65, sprite = 369, color = 2, display = 4, shortRange = true},                                                          --## Blip for the locker
      buyable   = false,                                                   --## If false everyone has one here automagically
    },

    ['adamsApple'] = {
      label     = "Adams Apple",
      modelType = "ped",
      model     = "a_f_m_bevhills_01",
      pos       = vector4(0,0,0,0),
      size      = {weight = 10000000, slots = 64},
      blip      =  {scale = 0.65, sprite = 369, color = 2, display = 4, shortRange = true},                                                          --## Blip for the locker
      buyable   = 1000, --## If false everyone has one here automagically
    },

  },
}
 
Core, Settings = exports['dirk-core']:getCore(); 
