-- Helpers
skillchain_arr = { en = {'Light:','Darkness:','Gravitation:','Fragmentation:','Distortion:','Fusion:','Compression:','Liquefaction:','Induration:','Reverberation:','Transfixion:','Scission:','Detonation:','Impaction:','Radiance:','Umbra:'}, jp = {'光:','闇:','重力:','分解:','湾曲:','核熱:','収縮:','溶解:','硬化:','振動:','貫通:','切断:','炸裂:','衝撃:','極光:','黒闇:'}}
ratings_arr = {'TW','IEP','EP','DC','EM','T','VT','IT'}
parse_quantity = false
targets_condensed = false
common_nouns = T{}
plural_entities = T{}
item_quantity = {id = 0, count = ''}
multi_targs = {}
multi_actor = {}
multi_msg = {}
static_config = false
initial_load = true


-- Blocked Messages
block_modes = T{20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,40,41,42,43,56,57,59,60,61,63,104,109,114,162,163,164,165,181,185,186,187,188}

block_messages = T{12}

-- Non-Blocked messages
non_block_messages = T{1,2,7,14,15,24,25,26,30,31,32,33,44,63,67,69,70,77,102,103,110,122,132,152,157,158,161,162,163,165,167,185,187,188,196,197,223,224,225,226,227,228,229,238,245,252,263,264,265,274,275,276,281,282,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,306,317,318,324,352,353,354,357,358,366,367,373,379,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,409,413,451,452,454,522,535,536,537,539,576,577,587,588,592,603,606,648,650,651,658,732,736,746,747,748,749,750,751,752,753,767,768,769,770,781}

passed_messages = T{4,5,6,16,17,18,20,34,35,36,38,40,47,48,49,53,62,64,72,78,87,88,89,90,94,97,112,116,154,170,171,172,173,174,175,176,177,178,191,192,198,204,206,215,217,218,219,234,246,249,251,307,308,313,315,328,336,350,523,530,531,558,561,563,575,584,601,609,562,610,611,612,613,614,615,616,617,618,619,620,625,626,627,628,629,630,631,632,633,634,635,636,643,660,661,662,679}

agg_messages = T{85,653,655,75,156,189,248,323,355,408,422,425,82,93,116,127,131,134,151,144,146,148,150,166,186,194,230,236,237,242,243,268,271,319,320,364,375,412,414,416,420,424,426,432,433,441,602,645,668,435,437,439}

-- Helpers for Messages
dmg_drain_msg = T{132,161,187,227,274,281,736,748,749,802,803}

grammar_numb_msg = T{14,31,133,231,369,370,382,385,386,387,388,389,390,391,392,393,394,395,396,397,398,400,401,403,404,405,411,417,535,536,557,570,571,589,607,651,757,769,770,778,792}

log_form_messages = T{64,73,82,127,128,130,141,203,204,236,242,270,271,272,277,279,350,374,531,645,754}


-- Message Color Management
black_colors = T{}--352,354,356,388,390,400,402,430,432,442,444,472,474,484,486}

color_redundant = T{26,33,41,71,72,89,94,109,114,164,173,181,184,186,70,84,104,127,128,129,130,131,132,133,134,135,136,137,138,139,140,64,86,91,106,111,175,178,183,81,101,16,65,87,92,107,112,174,176,182,82,102,67,68,69,170,189,15,208,18,25,32,40,163,185,23,24,27,34,35,42,43,162,165,187,188,30,31,14,205,144,145,146,147,148,149,150,151,152,153,190,13,9,253,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,284,285,286,287,292,293,294,295,300,301,301,303,308,309,310,311,316,317,318,319,324,325,326,327,332,333,334,335,340,341,342,343,344,345,346,347,348,349,350,351,355,357,358,360,361,363,366,369,372,374,375,378,381,384,395,406,409,412,415,416,418,421,424,437,450,453,456,458,459,462,479,490,493,496,499,500,502,505,507,508,10,51,52,55,58,62,66,80,83,85,88,90,93,100,103,105,108,110,113,122,168,169,171,172,177,179,180,12,11,37,291} -- 37 and 291 might be unique colors, but they are not gsubbable.

-- Message map
message_map = {}
for n=1,700,1 do
    message_map[n] = T{}
end

message_map[85] = T{284} -- resist
message_map[653] = T{654} -- immunobreak
message_map[655] = T{656} -- complete resist
message_map[93] = T{273} -- vanishes
--    message_map[75] =  -- no effect spell
message_map[156] = T{156,323,422,425} -- no effect ability
message_map[75] = T{283} -- No Effect: Spell, Target
--    message_map[189] = -- no effect ws
--    message_map[408] = -- no effect item
message_map[248] = T{355} -- no ability of any kind
message_map['No effect'] = T{283,423,659} -- generic "no effect" messages for sorting by category
message_map[432] = T{433} -- Receives: Spell, Target
message_map[82] = T{230,236,237,267,268,271} -- Receives: Spell, Target, Status
message_map[230] = T{266} -- Receives: Spell, Target, Status
message_map[319] = T{266} -- Receives: Spell, Target, Status (Generic for avatar buff BPs)
message_map[134] = T{287} -- Receives: Spell, Target, Status
message_map[116] = T{131,134,144,146,148,150,364,414,416,441,602,668,285,145,147,149,151,286,287,365,415,421} -- Receives: Ability, Target
message_map[127]=T{319,320,645} -- Receives: Ability, Target, Status
message_map[420]=T{424} -- Receives: Ability, Target, Status, Number
message_map[375] = T{412}-- Receives: Item, Target, Status
--    message_map[166] =  -- receives additional effect
message_map[186] = T{194,242,243}-- Receives: Weapon skill, Target, Status
message_map.Receives = T{203,205,270,272,277,279,280,266,267,269,278}
message_map[426] = T{427} -- Loses
message_map[320] = T{267}
message_map[414] = T{415} -- Dream Shroud
message_map[7] = T{263}
message_map[148] = T{149}
message_map[441] = T{421}
message_map[131] = T{286}
message_map[150] = T{151}
message_map[420] = T{421}
message_map[424] = T{421}
message_map[437] = T{438}
message_map[126] = T{676}
message_map[268] = T{269}
message_map[271] = T{272}
message_map[252] = T{265}
message_map[360] = T{361}
message_map[362] = T{363}
message_map[318] = T{263} -- Whispering Wind
message_map[323] = T{283} -- No effect Soothing Ruby
message_map[364] = T{365} -- Ecliptic Growl
message_map[146] = T{147} -- Ecliptic Howl
message_map[236] = T{270}
message_map[194] = T{280}
message_map[185] = T{264}
message_map[243] = T{278}
message_map[2] = T{264}
message_map[668] = T{669} -- Valiance
message_map[762] = T{365} -- Mix: Samson's Strength
message_map[242] = T{277}
message_map[238] = T{367} -- Phototrophic Blessing
message_map[188] = T{282} -- Misses
message_map[342] = T{344} -- Dispelga
message_map[369] = T{403} -- Ultimate Terror

replacements_map = {
    actor = {
        hits = T{1,373},
        casts = T{2,7,42,82,83,85,86,93,113,114,227,228,230,236,237,252,268,271,274,275,309,329,330,331,332,333,334,335,341,342,430,431,432,433,454,533,534,570,572,642,647,653,655},
        starts = T{3,327,716},
        gains = T{8,54,105,166,253,371,372,718,735},
        apos = T{14,16,33,69,70,75,248,310,312,352,353,354,355,382,493,535,574,575,576,577,592,606,798,799},
        misses = T{15,63},
        learns = T{23,45,442},
        uses = T{28,77,100,101,102,103,108,109,110,115,116,117,118,119,120,121,122,123,125,126,127,129,131,133,134,135,136,137,138,139,140,141,142,143,144,146,148,150,153,156,157,158,159,185,186,187,188,189,194,197,221,224,225,226,231,238,242,243,245,303,304,305,306,317,318,319,320,321,322,323,324,360,362,364,369,370,375,376,377,378,379,399,400,401,402,405,406,407,408,409,412,413,414,416,417,418,420,422,424,425,426,435,
        437,439,441,451,452,453,519,520,521,522,526,527,528,529,532,539,560,585,591,593,594,595,596,597,598,599,602,607,608,644,645,646,657,658,663,664,667,668,670,671,672,674,730,734,736,737,738,743,746,747,748,750,752,754,755,758,762,763,764,765,766,778,779,780,792,802,803,804,805,1023},
        is = T{29,49,84,106,191},
        does = T{34,91,192},
        readies = T{43,326,675},
        earns = T{50,368,719},
        steals = T{125,133,453,593,594,595,596,597,598,599},
        recovers = T{152,167},
        butmissestarget = T{188,245,324,658},
        eats = T{600,604},
        leads = T{648,650,651},
        has = T{515,661,665,688},
        obtains = T{582,673},
    },
    target = {
        takes = T{2,67,77,110,157,185,196,197,229,252,264,265,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,317,353,379,413,522,648,650,732,747,767,768,800},
        is = T{4,13,64,78,82,86,107,127,128,130,131,134,136,141,148,149,150,151,154,198,203,204,232,236,242,246,270,271,272,277,279,286,287,313,328,350,519,520,521,529,531,586,591,593,594,595,596,597,598,599,645,754,776},
        recovers = T{7,24,25,26,74,102,103,224,238,263,276,306,318,367,373,382,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,651,769,770},
        apos = T{31,38,44,53,73,83,106,112,116,120,121,123,132,159,168,206,221,231,249,285,308,314,321,322,329,330,331,332,333,334,335,341,342,343,344,351,360,361,362,363,364,365,369,374,378,383,399,400,401,402,403,405,407,409,417,418,430,431,435,436,437,438,439,440,459,530,533,534,537,570,571,572,585,606,607,641,642,644,647,676,730,743,756,757,762,792,805,806,1023},
        falls = T{20,113,406,605,646},
        uses = T{79,80},
        resists = T{85,197,284,653,654},
        vanishes = T{93,273},
        receives = T{142,144,145,146,147,237,243,267,268,269,278,320,375,412,414,415,416,420,421,424,432,433,441,532,557,602,668,672,739,755,804},
        seems = T{170,171,172,173,174,175,176,177,178},
        gains = T{186,194,205,230,266,280,319},
        regains = T{357,358,439,440,451,452,539,587,588},
        obtains = T{376,377,565,566,765,766},
        loses = T{426,427,652},
        was = T{97,564},
        has = T{589,684,763},
        compresists = T{655,656},
    },
    number = {
        points = T{1,2,8,10,33,38,44,54,67,77,105,110,157,163,185,196,197,223,229,252,253,264,265,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,310,317,352,353,371,372,373,379,382,385,386,387,388,389,390,391,392,393,394,395,396,397,398,413,522,536,576,577,648,650,651,718,721,722,723,724,725,726,727,728,729,732,735,747,767,768,769,770,800},
        absorbs = T{14,31,535},
        disappears = T{14,31,231,400,401,405,535,570,571,607,757,792,},
        attributes = T{369,403,417},
        status = T{370,404},
        
    },
    the = {
        point = T{33,308,536,800},
    }
}

corsair_rolls = {
	en = {
		[98] = {[5] = ' (Lucky Roll!)', [9] = ' (Unlucky Roll!)'},      -- Fighter's Roll
		[99] = {[3] = ' (Lucky Roll!)', [7] = ' (Unlucky Roll!)'},      -- Monk's Roll
		[100] = {[3] = ' (Lucky Roll!)', [7] = ' (Unlucky Roll!)'},     -- Healer's Roll
		[101] = {[5] = ' (Lucky Roll!)', [9] = ' (Unlucky Roll!)'},     -- Wizard's Roll
		[102] = {[4] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Warlock's Roll
		[103] = {[5] = ' (Lucky Roll!)', [9] = ' (Unlucky Roll!)'},     -- Rogue's Roll
		[104] = {[3] = ' (Lucky Roll!)', [7] = ' (Unlucky Roll!)'},     -- Gallant's Roll
		[105] = {[4] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Chaos Roll
		[106] = {[4] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Beast Roll
		[107] = {[2] = ' (Lucky Roll!)', [6] = ' (Unlucky Roll!)'},     -- Choral Roll
		[108] = {[4] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Hunter's Roll
		[109] = {[2] = ' (Lucky Roll!)', [6] = ' (Unlucky Roll!)'},     -- Samurai Roll
		[110] = {[4] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Ninja Roll
		[111] = {[4] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Drachen Roll
		[112] = {[5] = ' (Lucky Roll!)', [9] = ' (Unlucky Roll!)'},     -- Evoker's Roll
		[113] = {[2] = ' (Lucky Roll!)', [6] = ' (Unlucky Roll!)'},     -- Magus's Roll
		[114] = {[5] = ' (Lucky Roll!)', [9] = ' (Unlucky Roll!)'},     -- Corsair's Roll
		[115] = {[3] = ' (Lucky Roll!)', [7] = ' (Unlucky Roll!)'},     -- Puppet Roll
		[116] = {[3] = ' (Lucky Roll!)', [7] = ' (Unlucky Roll!)'},     -- Dancer's Roll
		[117] = {[2] = ' (Lucky Roll!)', [6] = ' (Unlucky Roll!)'},     -- Scholar's Roll
		[118] = {[3] = ' (Lucky Roll!)', [9] = ' (Unlucky Roll!)'},     -- Bolter's Roll
		[119] = {[2] = ' (Lucky Roll!)', [7] = ' (Unlucky Roll!)'},     -- Caster's Roll
		[120] = {[3] = ' (Lucky Roll!)', [9] = ' (Unlucky Roll!)'},     -- Courser's Roll
		[121] = {[4] = ' (Lucky Roll!)', [9] = ' (Unlucky Roll!)'},     -- Blitzer's Roll
		[122] = {[5] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Tactician's Roll
		[302] = {[3] = ' (Lucky Roll!)', [10] = ' (Unlucky Roll!)'},    -- Allies' Roll
		[303] = {[5] = ' (Lucky Roll!)', [7] = ' (Unlucky Roll!)'},     -- Miser's Roll
		[304] = {[2] = ' (Lucky Roll!)', [10] = ' (Unlucky Roll!)'},    -- Companion's Roll
		[305] = {[4] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Avenger's Roll
		[390] = {[3] = ' (Lucky Roll!)', [7] = ' (Unlucky Roll!)'},     -- Naturalit's Roll
		[391] = {[4] = ' (Lucky Roll!)', [8] = ' (Unlucky Roll!)'},     -- Runeist's Roll
	},
	jp = {
		[98] = {[5] = ' (運のよい転がし!)', [9] = ' (不運い転がし!)'},      -- Fighter's Roll
		[99] = {[3] = ' (運のよい転がし!)', [7] = ' (不運い転がし!)'},      -- Monk's Roll
		[100] = {[3] = ' (運のよい転がし!)', [7] = ' (不運い転がし!)'},     -- Healer's Roll
		[101] = {[5] = ' (運のよい転がし!)', [9] = ' (不運い転がし!)'},     -- Wizard's Roll
		[102] = {[4] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Warlock's Roll
		[103] = {[5] = ' (運のよい転がし!)', [9] = ' (不運い転がし!)'},     -- Rogue's Roll
		[104] = {[3] = ' (運のよい転がし!)', [7] = ' (不運い転がし!)'},     -- Gallant's Roll
		[105] = {[4] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Chaos Roll
		[106] = {[4] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Beast Roll
		[107] = {[2] = ' (運のよい転がし!)', [6] = ' (不運い転がし!)'},     -- Choral Roll
		[108] = {[4] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Hunter's Roll
		[109] = {[2] = ' (運のよい転がし!)', [6] = ' (不運い転がし!)'},     -- Samurai Roll
		[110] = {[4] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Ninja Roll
		[111] = {[4] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Drachen Roll
		[112] = {[5] = ' (運のよい転がし!)', [9] = ' (不運い転がし!)'},     -- Evoker's Roll
		[113] = {[2] = ' (運のよい転がし!)', [6] = ' (不運い転がし!)'},     -- Magus's Roll
		[114] = {[5] = ' (運のよい転がし!)', [9] = ' (不運い転がし!)'},     -- Corsair's Roll
		[115] = {[3] = ' (運のよい転がし!)', [7] = ' (不運い転がし!)'},     -- Puppet Roll
		[116] = {[3] = ' (運のよい転がし!)', [7] = ' (不運い転がし!)'},     -- Dancer's Roll
		[117] = {[2] = ' (運のよい転がし!)', [6] = ' (不運い転がし!)'},     -- Scholar's Roll
		[118] = {[3] = ' (運のよい転がし!)', [9] = ' (不運い転がし!)'},     -- Bolter's Roll
		[119] = {[2] = ' (運のよい転がし!)', [7] = ' (不運い転がし!)'},     -- Caster's Roll
		[120] = {[3] = ' (運のよい転がし!)', [9] = ' (不運い転がし!)'},     -- Courser's Roll
		[121] = {[4] = ' (運のよい転がし!)', [9] = ' (不運い転がし!)'},     -- Blitzer's Roll
		[122] = {[5] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Tactician's Roll
		[302] = {[3] = ' (運のよい転がし!)', [10] = ' (不運い転がし!)'},    -- Allies' Roll
		[303] = {[5] = ' (運のよい転がし!)', [7] = ' (不運い転がし!)'},     -- Miser's Roll
		[304] = {[2] = ' (運のよい転がし!)', [10] = ' (不運い転がし!)'},    -- Companion's Roll
		[305] = {[4] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Avenger's Roll
		[390] = {[3] = ' (運のよい転がし!)', [7] = ' (不運い転がし!)'},     -- Naturalit's Roll
		[391] = {[4] = ' (運のよい転がし!)', [8] = ' (不運い転がし!)'},     -- Runeist's Roll
	}
}

reaction_offsets = {
    [1] = 8,
    [3] = 24,
    [4] = 0,
    [6] = 16,
    [11] = 24,
    [13] = 24,
    [14] = 16,
    [15] = 24,
}

spike_effect_valid = {true,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
add_effect_valid = {true,true,true,true,false,false,false,false,false,false,true,false,true,false,false}

stat_ignore = T{66,69,70,71,444,445,446}
enfeebling = T{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,155,156,157,158,159,167,168,174,175,177,186,189,192,193,194,223,259,260,261,262,263,264,298,378,379,380,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,404,448,449,450,451,452,473,540,557,558,559,560,561,562,563,564,565,566,567}

-- Buffs
domain_buffs = T{
    250, -- EF Badge
    257, -- Besieged
    267, -- Allied Tags
    --292, -- Pennant?
    --475, -- Voidwatcher
    511, -- Reive Mark
    603, -- Elvorseal
} -- EF BadElvorseal, Allied Tags, EF Badge?

-- Races
female_races = T{2,4,6,7}
male_races = T{1,3,5,8}

-- Static settings
static_colors = T{
	mob = 69,
	other = 8,
	
	p0 = 501,
	p1 = 204,
	p2 = 410,
	p3 = 492,
	p4 = 259,
	p5 = 260,
	
	al0 = 205,
	al1 = 359,
	al2 = 167,
	al3 = 038,
	al4 = 125,
	al5 = 185,
	
	a20 = 429,
	a21 = 257,
	a22 = 200,
	a23 = 481,
	a24 = 283,
	a25 = 208,
	
	mobdmg = 0,
	mydmg = 0,
	partydmg = 0,
	allydmg = 0,
	otherdmg = 0,
	
	spellcol = 0,
	mobspellcol = 0,
	abilcol = 0,
	wscol = 0,
	mobwscol = 0,
	statuscol = 0,
	enfeebcol = 501,
	itemcol = 256,
}

static_settings = T{
	-- TODO; Language support yet not implemented
	lang = T{
		object = 1, -- 0 = Default, 1 = English, 2 = Japanese
		internal = 0, -- 0 = Default, 1 = Japanese, 2 = English
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
}

static_filters = T{
	me = { -- You're doing something
		melee = false,		-- Prevents your melee ("white") damage from appearing
		ranged = false,		-- Prevents your ranged damage from appearing
		damage = false,		-- Prevents your damage from appearing
		healing = false,	-- Prevents your healing from appearing
		misses = false,		-- Prevents your misses from appearing
		items = false,		-- Prevents your "Jim used an item. Jim gains the effect of Reraise." messages from appearing
		uses = false,		-- Prevents your "Jim uses an item." messages from appearing
		readies = false,	-- Prevents your "Jim readies ____" messages from appearing
		casting = false,	-- Prevents your "Jim begins casting ____" messages from appearing
		all = false,		-- Prevents all of your messages from appearing
		target = true,		-- true = SHOW all actions where I am the target.
	},
	
	party = { -- A party member is doing something
		melee = false,
		ranged = false,
		damage = false,
		healing = false,
		misses = false,
		items = false,
		uses = false,
		readies = false,
		casting = false,
		all = false,
	},
	
	alliance = { -- A alliance member is doing something
		melee = false,
		ranged = false,
		damage = false,
		healing = false,
		misses = false,
		items = false,
		uses = false,
		readies = false,
		casting = false,
		all = false,
	},

	others = { -- Some guy nearby is doing something
		melee = false,
		ranged = false,
		damage = false,
		healing = false,
		misses = false,
		items = false,
		uses = false,
		readies = false,
		casting = false,
		all = false,
	},
	
	my_pet = { -- Your pet is doing something
		melee = false,
		ranged = false,
		damage = false,
		healing = false,
		misses = false,
		items = false,
		uses = false,
		readies = false,
		casting = false,
		all = false,
	},
	
	my_fellow = { -- Your adventuring fellow is doing something
		melee = false,
		ranged = false,
		damage = false,
		healing = false,
		misses = false,
		items = false,
		uses = false,
		readies = false,
		casting = false,
		all = false,
	},
	
	other_pets = { -- Someone else's pet is doing something
		melee = false,
		ranged = false,
		damage = false,
		healing = false,
		misses = false,
		items = false,
		uses = false,
		readies = false,
		casting = false,
		all = false,
	},

	enemies = { -- Monster that your party has claimed doing something with one of the below targets
		me = { -- He's targeting you!
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		party = { -- He's targeting a party member
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		alliance = { -- He's targeting an alliance member
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		others = { -- He's targeting some guy nearby
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		my_pet = { -- He's targeting your pet
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		my_fellow = { -- He's targeting your adventuring fellow
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		other_pets = { -- He's targeting someone else's pet
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		enemies = { -- He's targeting himself or another monster your party has claimed
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		monsters = { -- He's targeting another monster
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
	},
	
	monsters = { -- NPC not claimed to your party is doing something with one of the below targets
		me = { -- He's targeting you!
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		party = { -- He's targeting a party member
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		alliance = { -- He's targeting an alliance member
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		others = { -- He's targeting some guy nearby
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		my_pet = { -- He's targeting your pet
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		my_fellow = { -- He's targeting your adventuring fellow
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		other_pets = { -- He's targeting someone else's pet
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		enemies = { -- He's targeting a monster your party has claimed
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
		
		monsters = { -- He's targeting himself or another monster
			melee = false,
			ranged = false,
			damage = false,
			healing = false,
			misses = false,
			items = false,
			uses = false,
			readies = false,
			casting = false,
			all = false,
		},
	},
}

get_weapon_skill = nil
get_job_ability = nil
get_mon_skill = nil
get_mon_ability = nil
get_spell = nil
get_item = nil
debug = false

