resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'S1lent Lottery'

version '1.0.5'

client_scripts ({
	'@es_extended/locale.lua',
	'locales/en.lua',
	's1lent_lottery_config.lua',
	'client/s1lent_lottery_client.lua'
})

server_scripts ({
	'@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
	'locales/en.lua',
	's1lent_lottery_config.lua',
	'server/s1lent_lottery_server.lua'
})

ui_page ('html/index.html')

files({
	'html/index.html',
	'html/script.js',
	'html/style.css',
	'html/lottoTicket.png'
})

dependencies ({
	'es_extended'
})