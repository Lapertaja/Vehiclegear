fx_version 'cerulean'
game 'gta5'
lua54 'true'

author 'Lapertaja'
description 'Take equipment out of a police car trunk'
version '1.0'

client_script 'client.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}