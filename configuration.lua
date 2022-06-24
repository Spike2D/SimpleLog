local settings = T{
	-- TODO; Language support yet not implemented
	lang = T{
		object = 1, -- 0 = Default, 1 = English, 2 = Japanese
		internal = 2, -- 0 = Default, 1 = Japanese, 2 = English
		msg_text = 'en', -- 'en' = English, 'jp' = Japanese
	},
	mode = T{
		condensedamage = true,
		condensetargets = true,
		cancelmultimsg = true,
		oxford = true,
		commamode = false,
		targetnumber = true,
		condensetargetname = false,
		swingnumber = true,
		sumdamage = true,
		condensecrits = false,
		tpstatuses = true,
		simplify = true,
		showpetownernames = false,
		crafting = true,
		showblocks = true,
		showguards = true,
		showcritws = false,
		showrollinfo = false,
	},
	text = T{
		line_aoe		= 'AOE ${numb} '..string.char(129,168)..' ${target}',
		line_aoebuff	= '${actor} ${abil} '..string.char(129,168)..' ${target} (${status})',
		line_full		= '[${actor}] ${numb} ${abil} '..string.char(129,168)..' ${target}',
		line_itemnum	= '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${numb} ${item2})',
		line_item		= '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${item2})',
		line_steal		= '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${item})',
		line_noability	= '${numb} '..string.char(129,168)..' ${target}',
		line_noactor	= '${abil} ${numb} '..string.char(129,168)..' ${target}',
		line_nonumber	= '[${actor}] ${abil} '..string.char(129,168)..' ${target}',
		line_notarget	= '[${actor}] ${abil} '..string.char(129,168)..' ${number}',
		line_roll		= '${actor} ${abil} '..string.char(129,168)..' ${target} '..string.char(129,170)..' ${number}',
	},
};

return settings;