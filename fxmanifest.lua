 
fx_version 'cerulean' 
lua54 'yes' 
games { 'rdr3', 'gta5' } 
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.' 
author 'DirkScripts' 
description 'Storage lockers script for AromaRP' 
version '1.0.0' 
 
shared_script{ 
  'usersettings/config.lua', 
  'usersettings/labels.lua', 
} 
 
client_script { 
  'src/client/init.lua', 
  'src/client/modules/*.lua', 
}   
 
server_script { 
    -- '@mysql-async/lib/MySQL.lua', -- Uncomment if not using oxmysql
    '@oxmysql/lib/MySQL.lua', -- Comment out if not using oxmysql
  'src/server/init.lua', 
  'src/server/modules/*.lua', 
} 
 
dependencies { 
  'dirk-core', 
} 
 

