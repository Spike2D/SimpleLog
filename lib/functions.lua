local ffi = require("ffi");
ffi.cdef[[
    int32_t memcmp(const void* buff1, const void* buff2, size_t count);
]];

-- Table population for all Skills and Spells
local PopulateSkills = function()
	local t1 = {}
	local t2 = {}
	local t3 = {}
    local t4 = {}

	local index = 1
	for i = 1, 4116, 1 do
		local w_skill = AshitaCore:GetResourceManager():GetAbilityById(i)
		if w_skill and i <= 0x200 then
			t1[index] = AshitaCore:GetResourceManager():GetAbilityById(i)
			index = index + 1
		else
            break
		end
	end
	get_weapon_skill = t1

	index = 1
	for i = 0x201, 4116, 1 do
		local j_skill = AshitaCore:GetResourceManager():GetAbilityById(i)
		if j_skill and i <= 0x600 then
			t2[index] = AshitaCore:GetResourceManager():GetAbilityById(i)
			index = index + 1
		else
            break
		end
	end
	get_job_ability = t2

	index = 1
	for i = 0x601, 4116, 1 do
		local m_skill = AshitaCore:GetResourceManager():GetAbilityById(i)
		if m_skill then
			t3[index] = AshitaCore:GetResourceManager():GetAbilityById(i)
			index = index + 1
		else
            break
		end
	end
	get_mon_skill = t3

    index = 0x101
    for i = 1, 4116, 1 do
        local j_ability_en = AshitaCore:GetResourceManager():GetString('monsters.abilities', i, 2)
        local j_ability_jp = AshitaCore:GetResourceManager():GetString('monsters.abilities', i, 1)
        if j_ability_en then
            t4[index] = {Name = {1, 2}}
            t4[index].Name[1] = j_ability_en
            t4[index].Name[2] = j_ability_jp
            index = index + 1
        else
            break
        end
    end
    get_mon_ability = t4
end

local PopulateSpells = function()
	local t = {}
	local index = 1
	for i = 1, 1024, 1 do
		local spell = AshitaCore:GetResourceManager():GetSpellById(i)
		if spell then
			t[index] = AshitaCore:GetResourceManager():GetSpellById(i)
			index = index + 1
		else
            break
		end
	end
	get_spell = t
end

local PopulateItems = function ()
	local t = {}
	local index = 1
	for i = 1, 100000, 1 do
		local item = AshitaCore:GetResourceManager():GetItemById(i)
		if item then
			t[index] = AshitaCore:GetResourceManager():GetItemById(i)
			index = index + 1
		else
			break
		end
	end
	get_item = t
end

local GetEntityByServerId = function(sid)
    for x = 0, 2303 do
        local ent = GetEntity(x);
        if (ent ~= nil and ent.ServerId == sid) then
            return ent;
        end
    end
    return nil;
end

local GetPartyData = function()
	local resource = {}

	parse_party(resource, 'p', 0, AshitaCore:GetMemoryManager():GetParty():GetAlliancePartyMemberCount1())
	parse_party(resource, 'al', 6, AshitaCore:GetMemoryManager():GetParty():GetAlliancePartyMemberCount2())
	parse_party(resource, 'a2', 12, AshitaCore:GetMemoryManager():GetParty():GetAlliancePartyMemberCount3())

	return resource
end

function parse_party(resource, party, mod, count)
	if count == 0 or count > 6 then
		return
	end

	for i = 0, count - 1 do
		local index = i + mod
		local id = party .. i
		resource[id] = {}
		resource[id]['hp'] = AshitaCore:GetMemoryManager():GetParty():GetMemberHP(index)
		resource[id]['hpp'] = AshitaCore:GetMemoryManager():GetParty():GetMemberHPPercent(index)
		resource[id]['mp'] = AshitaCore:GetMemoryManager():GetParty():GetMemberMP(index)
		resource[id]['mpp'] = AshitaCore:GetMemoryManager():GetParty():GetMemberMPPercent(index)
		resource[id]['tp'] = AshitaCore:GetMemoryManager():GetParty():GetMemberTP(index)
		resource[id]['zone'] = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(index)
		resource[id]['zone2'] = AshitaCore:GetMemoryManager():GetParty():GetMemberZone2(index)
		resource[id]['name'] = AshitaCore:GetMemoryManager():GetParty():GetMemberName(index)
		resource[id]['mob'] = GetEntity(AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(index))
	end
end

local nf = function(field, subfield)
	if field ~= nil then
		return field[subfield]
	else
		return nil
	end
end

local Flip = function (p1,p1t,p2,p2t,cond)
	return p2,p2t,p1,p1t,not cond
end

local ColorIt = function (text, color)
	if not color then return text end

	local output
	local colornum = tonumber(color)

	if text and type(text) == 'string' then
		if colornum >= 256 and colornum < 509 then
			colornum = colornum - 254
			if colornum == 4 then colornum = 3 end
			output = chat.color1(colornum, text)
		elseif colornum > 0  then
			output = chat.color2(colornum, text)
		elseif colornum == 0 then
			output = chat.color1(1, text)
		else
			Error('You have a invalid color: ' .. colornum)
			output = chat.color2(1, text)
		end
	end
	return output
end

local Conjunctions = function (pre, post, target_count, current)
	if current < target_count or gProfileSettings.mode.commamode then
		pre = pre..', '
	else
		if gProfileSettings.mode.oxford and target_count > 2 then
			pre = pre..','
		end
        if gProfileSettings.lang.msg_text == 'jp' then
            pre = pre..' '..UTF8toSJIS:UTF8_to_SJIS_str_cnv('と')..' '
        else
            pre = pre..' and '
        end
	end
	return pre..post
end

local SearchField = function(message)
    local fieldarr = {}
    string.gsub(message,'{(.-)}', function(a) fieldarr[a] = true end)
    return fieldarr
end

local CheckFilter = function(actor, target, category, msg)
    -- This determines whether the message should be displayed or filtered
    -- Returns true (don't filter) or false (filter), boolean
    if not actor.filter or not target.filter then return false end

    local filtertab = (gProfileFilter[actor.filter] and gProfileFilter[actor.filter][target.filter]) or gProfileFilter[actor.filter]

    if filtertab['all']
    or category == 1 and filtertab['melee']
    or category == 2 and filtertab['ranged']
    or category == 12 and filtertab['ranged']
    or category == 5 and filtertab['items']
    or category == 9 and filtertab['uses']
    or nf(res_actmsg[msg],'color')=='D' and filtertab['damage']
    or nf(res_actmsg[msg],'color')=='M' and filtertab['misses']
    or nf(res_actmsg[msg],'color')=='H' and filtertab['healing']
    or (msg == 43 or msg == 326) and filtertab['readies']
    or (msg == 3 or msg==327) and filtertab['casting']
    then
        return false
    end

    return true
end

local ActorNoun = function (msg)
    if msg then
        msg = msg
            :gsub('${actor}', 'The ${actor}')
    end
    return msg
end

local PluralActor = function (msg, msg_id)
	if msg then
        if msg_id == 6 then
            msg = msg:gsub('${actor} defeats ', '${actor} defeat ')
        elseif msg_id == 9 then
            msg = msg:gsub('${actor} attains ', '${actor} attain ')
        elseif msg_id == 10 then
            msg = msg:gsub('${actor} loses ', '${actor} lose ')
        elseif msg_id == 11 then
            msg = msg:gsub('${actor} falls ', '${actor} fall ')
        elseif msg_id == 19 then
            msg = msg:gsub('${actor} calls ' , '${actor} call ')
        elseif msg_id == 35 then
            msg = msg:gsub('${actor} lacks ' , '${actor} lack ')
        elseif msg_id == 67 then
            msg = msg:gsub('${actor} scores ' , '${actor} score ')
        elseif msg_id == 124 then
            msg = msg:gsub('${actor} achieves ' , '${actor} achieve ')
        elseif msg_id == 129 then
            msg = msg:gsub('${actor} mugs ' , '${actor} mug ')
        elseif msg_id == 244 then
            msg = msg:gsub('${actor} fails ' , '${actor} fail ')
        elseif msg_id == 311 then
            msg = msg:gsub('${actor} covers ' , '${actor} cover ')
        elseif msg_id == 315 then
            msg = msg:gsub('${actor} already has ' , '${actor} already have ')
        elseif msg_id ==411 then
            msg = msg
                :gsub('${actor} attempts ' , '${actor} attempt ')
                :gsub(' but lacks ' , ' but lack ')
        elseif msg_id == 536 then
            msg = msg:gsub('${actor} takes ' , '${actor} take ')
        elseif msg_id == 563 then
            msg = msg:gsub('${actor} destroys ' , '${actor} destroy ')
        elseif msg_id == 772 then
            msg = msg:gsub('${actor} stands ', '${actor} stand ')
        elseif replacements_map.actor.hits:contains(msg_id) then
            msg = msg:gsub('${actor} hits ', '${actor} hit ')
        elseif replacements_map.actor.misses:contains(msg_id) then
            msg = msg:gsub('${actor} misses ' , '${actor} miss ')
        elseif replacements_map.actor.starts:contains(msg_id) then
            msg = msg:gsub('${actor} starts ', '${actor} start ')
        elseif replacements_map.actor.casts:contains(msg_id) then
            msg = msg:gsub('${actor} casts ', '${actor} cast ')
            if msg_id == 83 then
                msg = msg:gsub('${actor} successfully removes ' , '${actor} successfully remove ')
            elseif msg_id == 572 or msg_id == 642 then
                msg = msg:gsub('${actor} absorbs ' , '${actor} absorb ')
            end
        elseif replacements_map.actor.readies:contains(msg_id) then
            msg = msg:gsub('${actor} readies ' , '${actor} ready ')
        elseif replacements_map.actor.recovers:contains(msg_id) then
            msg = msg:gsub('${actor} recovers ' , '${actor} recover ')
        elseif replacements_map.actor.gains:contains(msg_id) then
            msg = msg:gsub('${actor} gains ', '${actor} gain ')
        elseif replacements_map.actor.apos:contains(msg_id) then
            msg = msg:gsub('${actor}\'s ', '${actor}\' ')
            if msg_id == 33 then
                msg = msg:gsub('${actor} takes ' , '${actor} take ')
            elseif msg_id == 606 then
                msg = msg:gsub('${actor} recovers ' , '${actor} recover ')
            elseif msg_id == 799 then
                msg = msg:gsub('${actor} is ' , '${actor} are ')
            end
        elseif replacements_map.actor.uses:contains(msg_id) then
            msg = msg:gsub('${actor} uses ' , '${actor} use ')
            if msg_id == 122 then
                msg = msg:gsub('${actor} recovers ' , '${actor} recover ')
            elseif msg_id == 123 then
                msg = msg:gsub('${actor} successfully removes ' , '${actor} successfully remove ')
            elseif msg_id == 126 or msg_id == 136 or msg_id == 528 then
                msg = msg:gsub('${actor}\'s ', '${actor}\' ')
            elseif msg_id == 137 or msg_id == 153 then
                msg = msg:gsub('${actor} fails ' , '${actor} fail ')
            elseif msg_id == 139 then
                msg = msg:gsub(' but finds nothing' , ' but find nothing')
            elseif msg_id == 140 then
                msg = msg:gsub(' and finds a ${item2}' , ' and find a ${item2}')
            elseif msg_id == 158 then
                msg = msg:gsub('${ability}, but misses' , '${ability}, but miss')
            elseif msg_id == 585 then
                msg = msg:gsub('${actor} is ' , '${actor} are ')
            elseif msg_id == 674 then
                msg = msg:gsub(' and finds ${number}' , ' and find ${number}')
            elseif msg_id == 780 then
                msg = msg:gsub('${actor} takes ' , '${actor} take ')
            elseif replacements_map.actor.steals:contains(msg_id) then
                msg = msg:gsub('${actor} steals ' , '${actor} steal ')
            elseif replacements_map.actor.butmissestarget:contains(msg_id) then
                msg = msg:gsub(' but misses ${target}' , ' but miss ${target}')
            end
        elseif replacements_map.actor.is:contains(msg_id) then
            msg = msg:gsub('${actor} is ' , '${actor} are ')
        elseif replacements_map.actor.learns:contains(msg_id) then
            msg = msg:gsub('${actor} learns ' , '${actor} learn ')
        elseif replacements_map.actor.has:contains(msg_id) then
            msg = msg:gsub('${actor} has ' , '${actor} have ')
        elseif replacements_map.actor.obtains:contains(msg_id) then
            msg = msg:gsub('${actor} obtains ' , '${actor} obtain ')
        elseif replacements_map.actor.does:contains(msg_id) then
            msg = msg:gsub('${actor} does ' , '${actor} do ')
        elseif replacements_map.actor.leads:contains(msg_id) then
            msg = msg:gsub('${actor} leads ' , '${actor} lead ')
        elseif replacements_map.actor.eats:contains(msg_id) then
            msg = msg:gsub('${actor} eats ' , '${actor} eat ')
            if msg_id == 604 then
                msg = msg:gsub(' but finds nothing' , ' but find nothing')
            end
        elseif replacements_map.actor.earns:contains(msg_id) then
            msg = msg:gsub('${actor} earns ' , '${actor} earn ')
        end
    end
    return msg
end

local PluralTarget = function (msg, msg_id)
	if msg then
        if msg_id == 282 then
            msg = msg:gsub('${target} evades', '${target} evade')
        elseif msg_id == 359 then
            msg = msg:gsub('${target} narrowly escapes ', '${target} narrowly escape ')
        elseif msg_id == 419 then
            msg = msg:gsub('${target} learns ', '${target} learn ')
        elseif msg_id == 671 then
            msg = msg:gsub('${target} now has ', '${target} now have ')
        elseif msg_id == 764 then
            msg = msg:gsub('${target} feels ', '${target} feel ')
        elseif replacements_map.target.takes:contains(msg_id) then
            msg = msg:gsub('${target} takes ', '${target} take ')
            if msg_id == 197 then
                msg = msg:gsub('${target} resists', '${target} resist')
            end
        elseif replacements_map.target.is:contains(msg_id) then
            msg = msg:gsub('${target} is ', '${target} are ')
        elseif replacements_map.target.recovers:contains(msg_id) then
            msg = msg:gsub('${target} recovers ', '${target} recover ')
        elseif replacements_map.target.apos:contains(msg_id) then --coincidence in 439 and 440
            msg = msg:gsub('${target}\'s ', targets_condensed and '${target} ' or '${target}\' ')
            if msg_id == 439 or msg_id == 440 then
                msg = msg:gsub('${target} regains ', '${target} regain ')
            end
        elseif replacements_map.target.falls:contains(msg_id) then
            msg = msg:gsub('${target} falls ', '${target} fall ')
        elseif replacements_map.target.uses:contains(msg_id) then
            msg = msg:gsub('${target} uses ', '${target} use ')
        elseif replacements_map.target.resists:contains(msg_id) then
            msg = msg:gsub('${target} resists', '${target} resist')
        elseif replacements_map.target.vanishes:contains(msg_id) then
            msg = msg:gsub('${target} vanishes', '${target} vanish')
        elseif replacements_map.target.receives:contains(msg_id) then
            msg = msg:gsub('${target} receives ', '${target} receive ')
        elseif replacements_map.target.seems:contains(msg_id) then
            msg = msg:gsub('${target} seems ${skill}', '${target} seem ${skill}')
            if msg_id ~= 174 then
                msg = msg:gsub('${lb}It seems to have ', '${lb}They seem to have ')
            end
        elseif replacements_map.target.gains:contains(msg_id) then
            msg = msg:gsub('${target} gains ', '${target} gain ')
        elseif replacements_map.target.regains:contains(msg_id) then
            msg = msg:gsub('${target} regains ', '${target} regain ')
        elseif replacements_map.target.obtains:contains(msg_id) then
            msg = msg:gsub('${target} obtains ', '${target} obtain ')
        elseif replacements_map.target.loses:contains(msg_id) then
            msg = msg:gsub('${target} loses ', '${target} lose ')
        elseif replacements_map.target.was:contains(msg_id) then
            msg = msg:gsub('${target} was ', '${target} were ')
        elseif replacements_map.target.has:contains(msg_id) then
            msg = msg:gsub('${target} has ', '${target} have ')
        elseif replacements_map.target.compresists:contains(msg_id) then
            msg = msg:gsub('${target} completely resists ', '${target} completely resist ')
        end
    end
    return msg
end

local CleanMsg = function (msg, msg_id)
	if msg then
		msg = msg
		:gsub(' The ', ' the ')
		:gsub(': the ', ': The ')
		:gsub('! the ', '! The ')
        if replacements_map.the.point:contains(msg_id) then
            msg = msg:gsub('%. the ', '. The ')
        end
    end
    return msg
end

local GrammaticalNumberFix = function (msg, number, msg_id)
    if msg then
        if number == 1 then
            if replacements_map.number.points:contains(msg_id) then
                msg = msg:gsub(' points', ' point')
            elseif msg_id == 411 then
                msg = msg:gsub('${number} Ballista Points', '${number} Ballista Point')
            elseif msg_id == 589 then
                msg = msg:gsub('healed of ${number} status ailments', 'healed of ${number} status ailment')
            elseif msg_id == 778 then
                msg = msg:gsub('magical effects from', 'magical effect from')
            end
        else
			if replacements_map.number.absorbs:contains(msg_id) then
                msg = msg:gsub(' absorbs', ' absorb')
            elseif msg_id == 133 then
                msg = msg:gsub(' Petra', ' Petras')
            elseif replacements_map.number.attributes:contains(msg_id) then
                msg = msg:gsub('attributes is', 'attributes are')
            elseif replacements_map.number.status:contains(msg_id) then
                msg = msg:gsub('status effect is', 'status effects are')
            elseif msg_id == 557 then
                msg = msg:gsub('piece', 'pieces')
            elseif msg_id == 560 then
                msg = msg:gsub('Finishing move now ', 'Finishing moves now ')
            end
            if replacements_map.number.disappears:contains(msg_id) then
                msg = msg:gsub('disappears', 'disappear')
            end
        end
    end
    return msg
end

local ItemArticleFix = function (id, id2, msg)
	if id then
		if string.gmatch(msg, ' a ${item}') then
			local article = res_igramm[id] and res_igramm[id].article -- Temporal, intention to remove dependecy
			if article == 1 then
				msg = string.gsub(msg,' a ${item}',' an ${item}')
			end
		end
	end
	if id2 then
		if string.gmatch(msg, ' a ${item2}') then
			local article = res_igramm[id2] and res_igramm[id2].article
			if article == 1 then
				msg = string.gsub(msg,' a ${item2}',' an ${item2}')
			end
		end
	end
    return msg
end

local AddItemArticle = function(item_id)
    local article = ''
	local article_type = get_item[item_id] and get_item[item_id].LogNamePlural[gProfileSettings.lang.object] or nil
    if item_id and article_type ~= nil then
		if string.find(article_type, 'pairs of ') then
			article = 'pair of '
        elseif string.find(article_type, 'suits of ') then
            article = 'suit of '
        end
    end
    return article
end

local SendDelayedMessage = function (color, msg)
	local message = msg:gsub('${count}', item_quantity.count)
    AshitaCore:GetChatManager():AddChatMessage(color, false, message)
    item_quantity.id = 0
    item_quantity.count = ''
    parse_quantity = false
end

local Error = function(text)
    print(chat.header('SimpleLog') .. chat.error(text));
end


local exports = {
	PopulateSkills = PopulateSkills,
	PopulateSpells = PopulateSpells,
	PopulateItems = PopulateItems,
	GetEntityByServerId = GetEntityByServerId,
	GetPartyData = GetPartyData,
	nf = nf,
	Flip = Flip,
	ColorIt = ColorIt,
	Conjunctions = Conjunctions,
	SearchField = SearchField,
	CheckFilter = CheckFilter,
	ActorNoun = ActorNoun,
	PluralActor = PluralActor,
	PluralTarget = PluralTarget,
	CleanMsg = CleanMsg,
	GrammaticalNumberFix = GrammaticalNumberFix,
	ItemArticleFix = ItemArticleFix,
	AddItemArticle = AddItemArticle,
	SendDelayedMessage = SendDelayedMessage,
	Error = Error,
};

return exports;