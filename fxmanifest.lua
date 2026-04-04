fx_version 'cerulean'
game 'gta5'
lua54 'true'

author 'Lapertaja'
description 'Take equipment out of a police car trunk'
version '1.1.4'

client_script 'client.lua'

server_script 'server.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

dependencies {
    'ox_lib',
    'ox_target'
}
