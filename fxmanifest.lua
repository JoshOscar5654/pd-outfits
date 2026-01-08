fx_version 'cerulean'
game 'gta5'

author 'PrimeDev'
description 'Advanced Free Outfits System by PrimeDev https://pdscripts.com/'
version '1.0.0'
repository 'https://github.com/PrimeDev/pd-outfits'

shared_scripts {
    --'@ox_lib/init.lua', -- Optional: if you use ox_lib for notifications/menu
    'config.lua',
    'locales/en.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/locales.js'
}

lua54 'yes'