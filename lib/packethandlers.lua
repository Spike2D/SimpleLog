local ffi = require("ffi");
local chat = require("chat");

ffi.cdef[[
    int32_t memcmp(const void* buff1, const void* buff2, size_t count);
]];

local packethandlers = {};

-- trying to identify possible dupes
local last_chunk_buffer;
local reference_buffer = T{};
function check_duplicates(e)
    if ffi.C.memcmp(e.data_raw, e.chunk_data_raw, e.size) == 0 then
        if #reference_buffer > 2 then
            reference_buffer[#reference_buffer] = nil
        end

        if last_chunk_buffer then
            table.insert(reference_buffer, 1, last_chunk_buffer)
        end

        last_chunk_buffer = T{};
        local offset = 0;
    
        while (offset < e.chunk_size) do
            local size = ashita.bits.unpack_be(e.chunk_data_raw, offset, 9, 7) * 4;
            local chunk_packet = struct.unpack('c' .. size, e.chunk_data, offset + 1);
            last_chunk_buffer:append(chunk_packet)
            offset = offset + size;
        end
    end

    local packet = struct.unpack('c' .. e.size, e.data, 1)
    for _, chunk in ipairs(reference_buffer) do
        for _, bufferEntry in ipairs(chunk) do
            if packet == bufferEntry then
                e.blocked = true
                return true
            end
        end
    end
    return false
end

packethandlers.HandleIncoming0x00A = function(e)
    local id = struct.unpack('L', e.data, 0x04 + 1);
    local name = struct.unpack('c16', e.data, 0x84 + 1);
    local i,j = string.find(name, '\0');
    if (i ~= nil) then
        name = string.sub(name, 1, i - 1);
    end
    local job = struct.unpack('B', e.data, 0xB4 + 1);
    if (gStatus.PlayerJob ~= job) or (gStatus.PlayerId ~= id) or (gStatus.PlayerName ~= name) then
        gStatus.PlayerId = id;
        gStatus.PlayerName = name;
        gStatus.PlayerJob = job;
		gStatus.SettingsFolder = ('%sconfig\\addons\\simplelog\\%s_%u\\'):fmt(AshitaCore:GetInstallPath(), gStatus.PlayerName, gStatus.PlayerId);
        gStatus.AutoLoadProfile();
        if (AshitaCore:GetMemoryManager():GetParty():GetMemberIsActive(0) == 1) or initial_load then
            if GetPlayerEntity() then
                Self = GetPlayerEntity()
            else
                gPacketHandlers.DelayedSelfAssign:once(1)
            end
            SelfPlayer = AshitaCore:GetMemoryManager():GetPlayer()
            initial_load = false
        end
    end
    if (get_weapon_skill == nil or get_spell == nil or get_item == nil) then
        gFuncs.PopulateSkills();
        gFuncs.PopulateSpells();
        gFuncs.PopulateItems();
    end
end

packethandlers.DelayedSelfAssign = function ()
    Self = GetPlayerEntity()
end

packethandlers.HandleIncoming0x28 = function(e)
	local act_org = gActionHandlers.StringToAct(e.data)
	act_org.size = e.data:byte(5)
	local act_mod = gActionHandlers.StringToAct(e.data_modified)
	act_mod.size = e.data_modified:byte(5)

	return gActionHandlers.ActToString(e.data, gActionHandlers.parse_action_packet(act_org, act_mod))
end

packethandlers.HandleIncomingPacket = function(e)
	if (e.id == 0x00A) then
		gPacketHandlers.HandleIncoming0x00A(e);
    elseif (e.id == 0x28) then
        if check_duplicates(e) then return end
        e.data_modified = gPacketHandlers.HandleIncoming0x28(e);
    end

------- ITEM QUANTITY -------
    if (e.id == 0x020 and parse_quantity) then
        local item = struct.unpack('H', e.data, 0x0D)
        local count = struct.unpack('I', e.data, 0x05)
        if item == 0 then
            return
        end
        if item_quantity.id == item then
            item_quantity.count = count..' '
        end

------- NOUNS AND PLURAL ENTITIES ------- 
    elseif e.id == 0x00E then
        local mob_id = struct.unpack('I', e.data, 0x05)
        local mask = struct.unpack('B', e.data, 0x0B)
        local chat_info = struct.unpack('B', e.data, 0x28)
        if bit.band(mask,4) == 4 then
            if bit.band(chat_info,32) == 0 and not common_nouns:contains(mob_id) then
                table.insert(common_nouns, mob_id)
            elseif bit.band(chat_info,64) == 64 and not plural_entities:contains(mob_id) then
                table.insert(plural_entities, mob_id)
            elseif bit.band(chat_info,64) == 0 and plural_entities:contains(mob_id) then --Gears can change their grammatical number when they lose 2 gear?
                for i, v in pairs(plural_entities) do
                    if v == mob_id then
                        table.remove(plural_entities, i)
                        break
                    end
                end
            end
        end
    elseif e.id == 0x00B then -- Reset tables on Zoning
        common_nouns = T{}
        plural_entities = T{}

------- ACTION MESSAGE -------
    elseif e.id == 0x29 then
        if check_duplicates(e) then return end

        local am = {}
        am.actor_id = struct.unpack('I', e.data, 0x05)
        am.target_id = struct.unpack('I', e.data, 0x09)
        am.param_1 = struct.unpack('I', e.data, 0x0D)
        am.param_2 = struct.unpack('H', e.data, 0x11)%2^9 -- First 7 bits
        am.param_3 = math.floor(struct.unpack('I', e.data, 0x11)/2^5) -- Rest
        am.actor_index = struct.unpack('H', e.data, 0x15)
        am.target_index = struct.unpack('H', e.data, 0x17)
        am.message_id = struct.unpack('H', e.data, 0x19)%2^15 -- Cut off the most significant bit

        local actor = gActionHandlers.ActorParse(am.actor_id)
        local target = gActionHandlers.ActorParse(am.target_id)
        local actor_article = ''
        if gProfileSettings.lang.msg_text ~= 'jp' then
            actor_article = common_nouns:contains(am.actor_id) and 'The ' or ''
        end
        local target_article = ''
        if gProfileSettings.lang.msg_text ~= 'jp' then
            target_article = common_nouns:contains(am.target_id) and 'The ' or ''
        end
        targets_condensed = false

        -- Filter these messages
        if not gFuncs.CheckFilter(actor, target, 0, am.message_id) then e.blocked = true end

        if not actor or not target then -- If the actor or target table is nil, ignore the packet
        elseif am.message_id == 800 then -- Spirit bond message
            local status = gFuncs.ColorIt(AshitaCore:GetResourceManager():GetString('buffs.names', am.param_1, gProfileSettings.lang.internal), gProfileColor.statuscol)
            local targ = gFuncs.ColorIt(target.name or '', gProfileColor[target.owner or target.type])
            local number = am.param_2
            local color = gActionHandlers.ColorFilt(res_actmsg[am.message_id].color, am.target_id==Self.ServerId)
            if gProfileSettings.mode.simplify then
                local msg = gProfileSettings.text.line_noactor
                :gsub('${abil}',status or '')
                :gsub('${target}',targ)
                :gsub('${numb}',number or '')
                AshitaCore:GetChatManager():AddChatMessage(color, false, msg)
            else
                local msg = nil
                if gProfileSettings.lang.msg_text == 'jp' then
                    msg = res_actmsg[am.message_id]['jp']
                    msg = UTF8toSJIS:UTF8_to_SJIS_str_cnv(msg)
                else
                    msg = res_actmsg[am.message_id]['en']
                    msg = gFuncs.GrammaticalNumberFix(msg, number, am.message_id)
                    if plural_entities:contains(am.actor_id) then
                        msg = gFuncs.PluralActor(msg, am.message_id)
                    end
                    if plural_entities:contains(am.target_id) then
                        msg = gFuncs.PluralTarget(msg, am.message_id)
                    end
                end
                local msg = gFuncs.CleanMsg(msg
                :gsub('${status}',status or '')
                :gsub('${target}',target_article..targ)
                :gsub('${number}',number or ''), am.message_id)
                AshitaCore:GetChatManager():AddChatMessage(color, false, msg)
            end
        elseif am.message_id == 206 and gProfileSettings.mode.condensetargets then -- Wears off messages
            -- Condenses across multiple packets
            local status

            if enfeebling:contains(am.param_1) and AshitaCore:GetResourceManager():GetString('buffs.names', am.param_1) then
                status = gFuncs.ColorIt(AshitaCore:GetResourceManager():GetString('buffs.names', am.param_1, gProfileSettings.lang.internal), gProfileColor.enfeebcol)
            elseif gProfileColor.statuscol == 0 then
                status = gFuncs.ColorIt(AshitaCore:GetResourceManager():GetString('buffs.names', am.param_1, gProfileSettings.lang.internal), 0)
            else
                status = gFuncs.ColorIt(AshitaCore:GetResourceManager():GetString('buffs.names', am.param_1, gProfileSettings.lang.internal), gProfileColor.statuscol)
            end

            if not multi_actor[status] then multi_actor[status] = gActionHandlers.ActorParse(am.actor_id) end
            if not multi_msg[status] then multi_msg[status] = am.message_id end

            if not multi_targs[status] and not stat_ignore:contains(am.param_1) then
                multi_targs[status] = {}
                multi_targs[status][1] = target
                gPacketHandlers.multi_packet:bind1(status):once(0.5)
            elseif not (stat_ignore:contains(am.param_1)) then
                multi_targs[status][#multi_targs[status]+1] = target
            else
                -- This handles the stat_ignore values, which are things like Utsusemi,
                -- Sneak, Invis, etc. that you don't want to see on a delay
                multi_targs[status] = {}
                multi_targs[status][1] = target
                gPacketHandlers.multi_packet(status)
            end
            am.message_id = false
        elseif passed_messages:contains(am.message_id) then
            local item, status, spell, skill, number, number2
            local outstr = nil
            if gProfileSettings.lang.msg_text == 'jp' then
                outstr = res_actmsg[am.message_id]['jp']
                outstr = UTF8toSJIS:UTF8_to_SJIS_str_cnv(outstr)
            else
                outstr = res_actmsg[am.message_id][gProfileSettings.lang.msg_text]
                if plural_entities:contains(am.actor_id) then
                    outstr = gFuncs.PluralActor(outstr, am.message_id)
                end
                if plural_entities:contains(am.target_id) then
                    outstr = gFuncs.PluralTarget(outstr, am.message_id)
                end
            end

            local fields = gFuncs.SearchField(outstr)

            if fields.status then
                if log_form_messages:contains(am.message_id) then
                    status =  AshitaCore:GetResourceManager():GetString('buffs.names_log', am.param_1, 2)
                else
                    status = AshitaCore:GetResourceManager():GetString('buffs.names', am.param_1, gProfileSettings.lang.internal)
                end
                if enfeebling:contains(am.param_1) then
                    status = gFuncs.ColorIt(status, gProfileColor.enfeebcol)
                else
                    status = gFuncs.ColorIt(status, gProfileColor.statuscol)
                end
            end

            if fields.spell then
                if not get_spell[am.param_1] then
                    e.blocked = false
                end
                spell = get_spell[am.param_1].Name[gProfileSettings.lang.object]
            end

            if fields.item then
                if not get_item[am.param_1] then
                    e.blocked = false
                end
                item = get_item[am.param_1].LogNameSingular[gProfileSettings.lang.object] and get_item[am.param_1].LogNameSingular[gProfileSettings.lang.object] or get_item[am.param_1].Name[gProfileSettings.lang.object]
            end

            if fields.number then
                number = am.param_1
            end

            if fields.number2 then
                number2 = am.param_2
            end

            if fields.skill and res_skills[am.param_1] then
                if gProfileSettings.lang.msg_text == 'jp' then
                    skill = res_skills[am.param_1][gProfileSettings.lang.msg_text]
                    skill = UTF8toSJIS:UTF8_to_SJIS_str_cnv(skill)
                else
                    skill = res_skills[am.param_1][gProfileSettings.lang.msg_text]:lower()
                end
            end

            if am.message_id > 169 and am.message_id < 179 then
                if am.param_1 > 2147483647 then
                    skill = 'to be level -1 ('..ratings_arr[am.param_2-63]..')'
                else
                    skill = 'to be level '..am.param_1..' ('..ratings_arr[am.param_2-63]..')'
                end
            end
            outstr = (gFuncs.CleanMsg(outstr
            :gsub('${actor}\'s',actor_article..gFuncs.ColorIt(actor.name or '',gProfileColor[actor.owner or actor.type])..'\'s'..actor.owner_name)
            :gsub('${actor}',actor_article..gFuncs.ColorIt(actor.name or '',gProfileColor[actor.owner or actor.type])..actor.owner_name)
            :gsub('${status}',status or '')
            :gsub('${item}',gFuncs.ColorIt(item or '',gProfileColor.itemcol))
            :gsub('${target}\'s',target_article..gFuncs.ColorIt(target.name or '',gProfileColor[target.owner or target.type])..'\'s'..target.owner_name)
            :gsub('${target}',target_article..gFuncs.ColorIt(target.name or '',gProfileColor[target.owner or target.type])..target.owner_name)
            :gsub('${spell}',gFuncs.ColorIt(spell or '',gProfileColor.spellcol))
            :gsub('${skill}',gFuncs.ColorIt(skill or '',gProfileColor.abilcol))
            :gsub('${number}',number or '')
            :gsub('${number2}',number2 or '')
            :gsub('${skill}',skill or '')
            :gsub('${lb}','\7'), am.message_id))
            AshitaCore:GetChatManager():AddChatMessage(res_actmsg[am.message_id]['color'], false, outstr)
            am.message_id = false
        end
        if not am.message_id then
            e.blocked = true
        end

------------ SYNTHESIS ANIMATION --------------
    elseif e.id == 0x030 and gProfileSettings.mode.crafting then
        local target = GetEntity(AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0))
        local target_id = AshitaCore:GetMemoryManager():GetTarget():GetServerId(0)

        if Self.ServerId == struct.unpack('I', e.data, 5) or target_id == struct.unpack('I', e.data, 5) then
            local crafter_name = (Self.ServerId == struct.unpack('I', e.data, 5) and Self.Name) or target.Name
            local result = e.data:byte(13)
            if result == 0 then
                AshitaCore:GetChatManager():AddChatMessage(8, false, ' ------------- NQ Synthesis ('..crafter_name..') -------------')
            elseif result == 1 then
                AshitaCore:GetChatManager():AddChatMessage(8, false, ' ---------------- Break ('..crafter_name..') -----------------')
            elseif result == 2 then
                AshitaCore:GetChatManager():AddChatMessage(8, false, ' ------------- HQ Synthesis ('..crafter_name..') -------------')
            else
                AshitaCore:GetChatManager():AddChatMessage(8, false, 'Craftmod: Unhandled result '..tostring(result))
            end
        end
    elseif e.id == 0x06F and gProfileSettings.mode.crafting then
        if e.data:byte(5) == 0 or e.data:byte(5) == 12 then
            local result = e.data:byte(6)
            if result == 1 then
                AshitaCore:GetChatManager():AddChatMessage(8, false, ' -------------- HQ Tier 1! --------------')
            elseif result == 2 then
                AshitaCore:GetChatManager():AddChatMessage(8, false, ' -------------- HQ Tier 2! --------------')
            elseif result == 3 then
                AshitaCore:GetChatManager():AddChatMessage(8, false, ' -------------- HQ Tier 3! --------------')
            end
        end

    ------------- JOB INFO ----------------
    elseif e.id == 0x01B then
        local new_job = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", e.data:byte(9))
        local old_job = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob)
        if new_job ~= old_job then
            gStatus.PlayerJob = e.data:byte(9)
            local jobFiltersFile = (gStatus.SettingsFolder .. '%s.lua'):fmt(new_job)
            gStatus.LoadProfile(jobFiltersFile, 'filters')
        end
    end
end

packethandlers.multi_packet = function(...)
    local ind = table.concat({...}, ' ')
    -- Check for duplicated packets
    local isDupe = {}
    for i,v in pairs(multi_targs[ind]) do
        local id = multi_targs[ind][i].id
        if isDupe[id] then
            table.remove(multi_targs[ind], i)
        end
        isDupe[id] = i
    end
    local targets = gActionHandlers.AssembleTargets(multi_actor[ind], multi_targs[ind], 0, multi_msg[ind])
    local msg = nil
    if gProfileSettings.lang.msg_text == 'jp' then
        msg = res_actmsg[multi_msg[ind]]['jp']
        msg = UTF8toSJIS:UTF8_to_SJIS_str_cnv(msg)
    else
        msg = res_actmsg[multi_msg[ind]]['en']
    end
    local outstr = targets_condensed and gProfileSettings.lang.msg_text ~= 'jp' and gFuncs.PluralTarget(msg, multi_msg[ind]) or msg
    outstr = gFuncs.CleanMsg(outstr
    :gsub('${target}\'s',targets)
    :gsub('${target}',targets)
    :gsub('${status}',ind), multi_msg[ind])
    AshitaCore:GetChatManager():AddChatMessage(res_actmsg[multi_msg[ind]].color, false, outstr)
    multi_targs[ind] = nil
    multi_msg[ind] = nil
    multi_actor[ind] = nil
end

packethandlers.HandleOutgoingPacket = function(e)
end

return packethandlers;