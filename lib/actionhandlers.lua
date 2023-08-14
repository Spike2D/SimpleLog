local actionhandlers = {};



actionhandlers.parse_action_packet = function(act)
    if not Self then
        Self = GetPlayerEntity()
        if not Self then
            return act
        end
    end

    if not SelfPlayer then
        SelfPlayer = AshitaCore:GetMemoryManager():GetPlayer()
        if not SelfPlayer then
            return act
        end
    end

    -- Constructing table from act to work with, gathering info
	act.actor = gActionHandlers.ActorParse(act.actor_id)
    act.action = gActionHandlers.SpellParse(act)
    act.actor.name = act.actor and act.actor.name and string.gsub(act.actor.name,'[- ]', {['-'] = string.char(0x81,0x7C), [' '] = string.char(0x81,0x3F)}) --fix for ffxi chat splits on trusts with - and spaces
    targets_condensed = false

    if not act.action then
        print(chat.header('SimpleLogDebug') .. chat.message('No Action MSG'))
        return act
    end

    for i, v in ipairs(act.targets) do
        v.target = {}
        v.target[1] = gActionHandlers.ActorParse(v.server_id)
        if #v.actions > 1 then
            for n, m in ipairs(v.actions) do
                if res_actmsg[m.message] then m.fields = gFuncs.SearchField(res_actmsg[m.message][gProfileSettings.lang.msg_text]) end
                if res_actmsg[m.add_effect_message] then m.add_effect_fields = gFuncs.SearchField(res_actmsg[m.add_effect_message][gProfileSettings.lang.msg_text]) end
                if res_actmsg[m.spike_effect_message] then m.spike_effect_fields = gFuncs.SearchField(res_actmsg[m.spike_effect_message][gProfileSettings.lang.msg_text]) end

                if m.param ~= nil and type(m.param) == "number" then
                    if AshitaCore:GetResourceManager():GetString('buffs.names', m.param) ~= nil then
                        m.status = AshitaCore:GetResourceManager():GetString('buffs.names', m.param, gProfileSettings.lang.internal)
                    end
                end
                if m.add_effect_param ~= nil and type(m.add_effect_param) == "number" then
                    if AshitaCore:GetResourceManager():GetString('buffs.names', m.add_effect_param) ~= nil then
                        m.add_effect_status = AshitaCore:GetResourceManager():GetString('buffs.names', m.add_effect_param, gProfileSettings.lang.internal)
                    end
                end
                if m.spike_effect_param ~= nil and type(m.spike_effect_param) == "number" then
                    if AshitaCore:GetResourceManager():GetString('buffs.names', m.spike_effect_param) ~= nil then
                        m.spike_effects_status = AshitaCore:GetResourceManager():GetString('buffs.names', m.spike_effect_param, gProfileSettings.lang.internal)
                    end
                end
                m.number = 1
                if m.has_add_effect then
                    m.add_effect_number = 1
                end
                if m.has_spike_effect then
                    m.spike_effect_number = 1
                end
                if not gFuncs.CheckFilter(act.actor, v.target[1], act.category, m.message) then
                    m.message = 0
                    m.add_effect_message = 0
                end
                if m.spike_effect_message ~= 0 and not gFuncs.CheckFilter(v.target[1], act.actor, act.category, m.message) then
                    m.spike_effect_message = 0
                end
                if gProfileSettings.mode.condensedamage and n > 1 then -- Damage/Action condensation within one target
                    for q=1, n-1 do
                        local r = v.actions[q]

                        if r.message ~= 0 and m.message ~= 0 then
                            if m.message == r.message or (gProfileSettings.mode.condensecrits and T{1, 67}:contains(m.message) and T{1, 67}:contains(r.message)) then
                                if (m.effect == r.effect) or (T{1, 67}:contains(m.message) and T{0, 1, 2, 3}:contains(m.effect) and T{0, 1, 2, 3}:contains(r.effect)) then -- combine kicks and crits
                                    if m.reaction == r.reaction then -- combine hits and guards
                                        r.number = r.number + 1
                                        if not gProfileSettings.mode.sumdamage then
                                            if not r.cparam then
                                                r.cparam = r.param
                                                if gProfileSettings.mode.condensecrits and r.message == 67 then
                                                    r.cparam = r.cparam..'!'
                                                end
                                            end
                                            r.cparam = r.cparam..', '..m.param
                                            if gProfileSettings.mode.condensecrits and r.message == 67 then
                                                r.cparam = r.cparam..'!'
                                            end
                                        end
                                            r.param = m.param + r.param
                                            if gProfileSettings.mode.condensecrits and m.message == 67 then
                                                r.message = m.message
                                                r.effect = m.effect
                                            end
                                            m.message = 0
                                    else
                                        --gFuncs.Error('Didn\'t condense: '..m.message..':'..r.message..' - '..m.effect..':'..r.effect..' - '..m.reaction..':'..r.reaction)
                                    end
                                else
                                    --gFuncs.Error('Didn\'t condense: '..m.message..':'..r.message..' - '..m.effect..':'..r.effect..' - '..m.reaction..':'..r.reaction)
                                end
                            else
                                --gFuncs.Error('Didn\'t condense: '..m.message..':'..r.message..' - '..m.effect..':'..r.effect..' - '..m.reaction..':'..r.reaction)
                            end
                        end
                        if m.has_add_effect and r.add_effect_message ~= 0 then
                            if m.add_effect_effect == r.add_effect_effect and m.add_effect_message == r.add_effect_message and m.add_effect_message ~= 0 then
                                r.add_effect_number = r.add_effect_number + 1
                                if not gProfileSettings.mode.sumdamage then
                                    r.cadd_effect_param = (r.cadd_effect_param or r.add_effect_param)..', '..m.add_effect_param
                                end
                                r.add_effect_param = m.add_effect_param + r.add_effect_param
                                m.add_effect_message = 0
                            end
                        end
                        if m.has_spike_effect and r.spike_effect_message ~= 0 then
                            if r.spike_effect_effect == r.spike_effect_effect and m.spike_effect_message == r.spike_effect_message and m.spike_effect_message ~= 0 then
                                r.spike_effect_number = r.spike_effect_number + 1
                                if not gProfileSettings.mode.sumdamage then
                                    r.cspike_effect_param = (r.cspike_effect_param or r.spike_effect_param)..', '..m.spike_effect_param
                                end
                                r.spike_effect_param = m.spike_effect_param + r.spike_effect_param
                                m.spike_effect_message = 0
                            end
                        end
                    end
                end
            end
        else
            local tempact = v.actions[1]
            if res_actmsg[tempact.message] then tempact.fields = gFuncs.SearchField(res_actmsg[tempact.message][gProfileSettings.lang.msg_text]) end
            if res_actmsg[tempact.add_effect_message] then tempact.add_effect_fields = gFuncs.SearchField(res_actmsg[tempact.add_effect_message][gProfileSettings.lang.msg_text]) end
            if res_actmsg[tempact.spike_effect_message] then tempact.spike_effect_fields = gFuncs.SearchField(res_actmsg[tempact.spike_effect_message][gProfileSettings.lang.msg_text]) end

            if not gFuncs.CheckFilter(act.actor, v.target[1], act.category, tempact.message) then
                tempact.message = 0
                tempact.add_effect_message = 0
            end
            if tempact.spike_effect_message ~= 0 and not gFuncs.CheckFilter(v.target[1], act.actor, act.category, tempact.message) then
                tempact.spike_effect_message = 0
            end
            tempact.number = 1
            if tempact.has_add_effect and tempact.message ~= 674 then
                tempact.add_effect_number = 1
            end
            if tempact.has_spike_effect then
                tempact.spike_effect_number = 1
            end

            if tempact.param ~= nil and type(tempact.param) == "number" then
                if AshitaCore:GetResourceManager():GetString('buffs.names', tempact.param) ~= nil then
                    tempact.status = AshitaCore:GetResourceManager():GetString('buffs.names', tempact.param, gProfileSettings.lang.internal)
                end
            end
            if tempact.add_effect_param ~= nil and type(tempact.add_effect_param) == "number" then
                if AshitaCore:GetResourceManager():GetString('buffs.names', tempact.add_effect_param) ~= nil then
                    tempact.add_effect_status = AshitaCore:GetResourceManager():GetString('buffs.names', tempact.add_effect_param, gProfileSettings.lang.internal)
                end
            end
            if tempact.spike_effect_param ~= nil and type(tempact.spike_effect_param) == "number" then
                if AshitaCore:GetResourceManager():GetString('buffs.names', tempact.spike_effect_param) ~= nil then
                    tempact.spike_effect_status = AshitaCore:GetResourceManager():GetString('buffs.names', tempact.spike_effect_param, gProfileSettings.lang.internal)
                end
            end
        end
        if gProfileSettings.mode.condensetargets and i > 1 then
            for n=1, i-1 do
                local m = act.targets[n]
                if(v.actions[1].message == m.actions[1].message and v.actions[1].param == m.actions[1].param) or
                (message_map[m.actions[1].message] and message_map[m.actions[1].message]:contains(v.actions[1].message) and v.actions[1].param == m.actions[1].param) or
                (message_map[m.actions[1].message] and message_map[m.actions[1].message]:contains(v.actions[1].message) and v.actions[1].param == m.actions[1].param) then
                    m.target[#m.target+1] = v.target[1]
                    v.target[1] = nil
                    v.actions[1].message = 0
                end
            end
        end
    end

    for i, v in pairs(act.targets) do
        for n, m in pairs(v.actions) do
            if m.message ~= 0 and res_actmsg[m.message] ~= nil then
                local col = res_actmsg[m.message].color
                local targ =  gActionHandlers.AssembleTargets(act.actor, v.target, act.category, m.message)
                local color = gActionHandlers.ColorFilt(col, v.target[1].server_id == Self.ServerId)
                if gProfileSettings.lang.msg_text == 'jp' then
                    if m.reaction == 11 and act.category == 1 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('によって受け流された')
                    -- elseif m.reaction == 12 and act.category == 1 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('によってブロックされました')
                    elseif m.message == 1 and (act.category == 1 or act.category == 11) then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('の攻撃')
                    elseif m.message == 15 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('ミス')
                    elseif m.message == 29 or m.message == 84 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('麻痺している')
                    elseif m.message == 30 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('期待される')
                    elseif m.message == 31 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('吸収された')
                    elseif m.message == 32 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('ダッジ')
                    elseif m.message == 67 and (act.category == 1 or act.category == 11) then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('の攻撃クリティカル')
                    elseif m.message == 106 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('に脅迫')
                    elseif m.message == 153 then m.simp_name = act.action.name..UTF8toSJIS:UTF8_to_SJIS_str_cnv(' 失敗')
                    elseif m.message == 244 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('のかすめとるにミス')
                    elseif m.message == 282 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('によって回避')
                    elseif m.message == 373 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('つ吸収した')
                    elseif m.message == 352 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('遠撃')
                    elseif m.message == 353 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('クリティカル 遠撃')
                    elseif m.message == 354 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('ミス 遠撃')
                    elseif m.message == 576 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('遠撃 直撃')
                    elseif m.message == 577 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('遠撃 直撃')
                    elseif m.message == 157 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('の乱れ撃ち')
                    elseif m.message == 76 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('範囲内にターゲットがありません')
                    elseif m.message == 77 then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('の散華')
                    elseif m.message == 360 then m.simp_name = act.action.name..UTF8toSJIS:UTF8_to_SJIS_str_cnv(' (JA リセット)')
                    elseif m.message == 426 or m.message == 427 then m.simp_name = 'Bust! '..act.action.name
                    elseif m.message == 435 or m.message == 436 then m.simp_name = act.action.name..' (JAs)'
                    elseif m.message == 437 or m.message == 438 then m.simp_name = act.action.name..UTF8toSJIS:UTF8_to_SJIS_str_cnv(' (JAs と TP)')
                    elseif m.message == 439 or m.message == 440 then m.simp_name = act.action.name..UTF8toSJIS:UTF8_to_SJIS_str_cnv(' (SPs, JAs, TP, と MP)')
                    elseif T{252,265,268,269,271,272,274,275,379,650,747}:contains(m.message) then m.simp_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv('マジックバースト! ')..act.action.name
                    elseif not act.action then
                        m.simp_name = ''
                        act.action = {}
                    else m.simp_name = act.action.name or ''
                    end
                else
                    if m.reaction == 11 and act.category == 1 then m.simp_name = 'parried by'
                    -- elseif m.reaction == 12 and act.category == 1 then m.simp_name = 'blocked by'
                    elseif m.message == 1 and (act.category == 1 or act.category == 11) then m.simp_name = 'hit'
                    elseif m.message == 15 then m.simp_name = 'missed'
                    elseif m.message == 29 or m.message == 84 then m.simp_name = 'is paralyzed'
                    elseif m.message == 30 then m.simp_name = 'anticipated by'
                    elseif m.message == 31 then m.simp_name = 'absorbed by'
                    elseif m.message == 32 then m.simp_name = 'dodged by'
                    elseif m.message == 67 and (act.category == 1 or act.category == 11) then m.simp_name = 'critical hit'
                    elseif m.message == 106 then m.simp_name = 'intimidated by'
                    elseif m.message == 153 then m.simp_name = act.action.name..' fails'
                    elseif m.message == 244 then m.simp_name = 'Mug fails'
                    elseif m.message == 282 then m.simp_name = 'evaded by'
                    elseif m.message == 373 then m.simp_name = 'absorbed by'
                    elseif m.message == 352 then m.simp_name = 'RA'
                    elseif m.message == 353 then m.simp_name = 'critical RA'
                    elseif m.message == 354 then m.simp_name = 'missed RA'
                    elseif m.message == 576 then m.simp_name = 'RA hit squarely'
                    elseif m.message == 577 then m.simp_name = 'RA struck true'
                    elseif m.message == 157 then m.simp_name = 'Barrage'
                    elseif m.message == 76 then m.simp_name = 'No targets within range'
                    elseif m.message == 77 then m.simp_name = 'Sange'
                    elseif m.message == 360 then m.simp_name = act.action.name..' (JA reset)'
                    elseif m.message == 426 or m.message == 427 then m.simp_name = 'Bust! '..act.action.name
                    elseif m.message == 435 or m.message == 436 then m.simp_name = act.action.name..' (JAs)'
                    elseif m.message == 437 or m.message == 438 then m.simp_name = act.action.name..' (JAs and TP)'
                    elseif m.message == 439 or m.message == 440 then m.simp_name = act.action.name..' (SPs, JAs, TP, and MP)'
                    elseif T{252,265,268,269,271,272,274,275,379,650,747}:contains(m.message) then m.simp_name = 'Magic Burst! '..act.action.name
                    elseif not act.action then
                        m.simp_name = ''
                        act.action = {}
                    else m.simp_name = act.action.name or ''
                    end
                end
                
                -- Debuff Application Messages
                if gProfileSettings.mode.simplify and message_map[82]:contains(m.message) then
                    if gProfileSettings.lang.msg_text == 'jp' then
                        if m.param == 148 or m.param == 562 then
                            m.message = 237
                        end
                    else
                        if m.status == 'Evasion Down' then
                            m.message = 237
                        end
                        if m.status == 'addle' then m.status = 'addled'
                        elseif m.status == 'bind' then m.status = 'bound'
                        elseif m.status == 'blindness' then m.status = 'blinded'
                        elseif m.status == 'Inundation' then m.status = 'inundated'
                        elseif m.status == 'paralysis' then m.status = 'paralyzed'
                        elseif m.status == 'petrification' then m.status = 'petrified'
                        elseif m.status == 'poison' then m.status = 'poisoned'
                        elseif m.status == 'silence' then m.status = 'silenced'
                        elseif m.status == 'sleep' then m.status = 'asleep'
                        elseif m.status == 'slow' then m.status = 'slowed'
                        elseif m.status == 'stun' then m.status = 'stunned'
                        elseif m.status == 'weight' then m.status = 'weighed down'
                        end
                    end
                end
                
                -- Some messages uses the english log version of the buff
                if not gProfileSettings.mode.simplify and log_form_messages:contains(m.message) then
                    m.status = AshitaCore:GetResourceManager():GetString('buffs.names_log', m.param, 2)
                end

                -- if m.message == 93 or m.message == 273 then m.status = gFuncs.ColorIt('Vanish', gProfileColor['statuscol']) end

                -- Special Message Handling
                if m.message == 93 or m.message == 273 then
                    m.status = gFuncs.ColorIt('Vanish', gProfileColor['statuscol'])
                elseif m.message == 522 and gProfileSettings.mode.simplify then
                    targ = targ..' ('.. gFuncs.ColorIt('stunned', gProfileColor['statuscol'])..')'
                elseif m.message == 416 and gProfileSettings.mode.simplify then
                    targ = targ..' ('..gFuncs.ColorIt('Magic Attack Boost and Magic Defense Boost', gProfileColor['statuscol'])..')'
                elseif m.message == 1023 and gProfileSettings.mode.simplify then
                    targ = targ..' ('..gFuncs.ColorIt('attacks and defenses enhanced', gProfileColor['statuscol'])..')'
                elseif m.message == 762 and gProfileSettings.mode.simplify then
                    targ = targ..' ('..gFuncs.ColorIt('all status parameters boosted', gProfileColor['statuscol'])..')'
                elseif m.message == 779 and gProfileSettings.mode.simplify then
                    targ = 'A barrier pulsates around '..targ
                elseif m.message == 780 and gProfileSettings.mode.simplify then
                    targ = 'Takes aim on '..targ
                elseif T{158,188,245,324,592,658}:contains(m.message) and gProfileSettings.mode.simplify then
                    -- When you miss a WS or JA. Relevant for condensed battle.
                    m.status = 'Miss' --- This probably doesn't work due to the if a==nil statement below.
                elseif m.message == 653 or m.message == 654 then
                    m.status = gFuncs.ColorIt('Immunobreak', gProfileColor['statuscol'])
                elseif m.message == 655 or m.message == 656 then
                    m.status = gFuncs.ColorIt('Completely Resists', gProfileColor['statuscol'])
                elseif m.message == 85 or m.message == 284 then
                    if m.unknown == 2 then
                        m.status = gFuncs.ColorIt('Resists!', gProfileColor['statuscol'])
                    else
                        m.status = gFuncs.ColorIt('Resists', gProfileColor['statuscol'])
                    end
                elseif m.message == 351 then
                    m.status = gFuncs.ColorIt('status ailments', gProfileColor['statuscol'])
                    m.simp_name = gFuncs.ColorIt('remedy', gProfileColor['itemcol'])
                elseif T{75,114,156,189,248,283,312,323,336,355,408,422,423,425,659}:contains(m.message) then
                    m.status = gFuncs.ColorIt('No effect', gProfileColor['statuscol']) -- The status code for "No Effect" is 255, so it might actually work without this line
                end
                if m.message == 188 then
                    m.simp_name = m.simp_name..' (Miss)'
                -- elseif m.message == 189 then
                    -- m.simp_name = m.simp_name..' (No Effect)'
                elseif T{78,198,328}:contains(m.message) then
                    m.simp_name = '(Too Far)'
                end
                local msg, numb = gActionHandlers.SimplifyMessage(m.message)
                if not gProfileSettings.mode.simplify and gProfileSettings.lang.msg_text == 'jp' then
                    msg = UTF8toSJIS:UTF8_to_SJIS_str_cnv(msg)
                end
                if not gProfileColor[act.actor.owner or act.actor.type] then
                    gFuncs.Error('SimpleLog error, missing filter:'..tostring(act.actor.owner)..' '..tostring(act.actor.type))
                end
                if m.fields.status then numb = m.status else numb = gActionHandlers.PrefSuf((m.message == 674 and m.add_effect_param or m.cparam or m.param), m.message,act.actor.damage, col) end

                if msg and m.message == 70 and not gProfileSettings.mode.simplify and gProfileSettings.lang.msg_text ~= 'jp' then -- fix pronoun on parry
                    if v.target[1].race == 0 then
                        msg = msg:gsub(' his ', ' her ')
                    elseif female_races:contains(v.target[1].race) then
                        msg = msg:gsub(' his ', ' her ')
                    end
                end

                local count = ''
                if m.message == 377 and act.actor_id == Self.ServerId then
                    parse_quantity = true
                    item_quantity.id = act.action.item2_id
                    count = '${count}'
                end

                if not gProfileSettings.mode.simplify and gProfileSettings.lang.msg_text ~= 'jp' then
                    if col == 'D' or grammar_numb_msg:contains(m.message) then
                        msg = gFuncs.GrammaticalNumberFix(msg, (m.cparam or m.param), m.message)
                    end
                    if act.action.item_id or act.action.item2_id then
                        msg = gFuncs.ItemArticleFix(act.action.item_id, act.action.item2_id, msg)
                    end
                    if common_nouns:contains(act.actor.id) then
                        msg = gFuncs.ActorNoun(msg)
                    end
                    if plural_entities:contains(act.actor.id) then
                        msg = gFuncs.PluralActor(msg, m.message)
                    end
                    if targets_condensed or plural_entities:contains(v.target[1].server_id) then
                        msg = gFuncs.PluralTarget(msg, m.message)
                    end
                end

                local roll = gProfileSettings.mode.showrollinfo and act.category == 6 and UTF8toSJIS:UTF8_to_SJIS_str_cnv(corsair_rolls[gProfileSettings.lang.msg_text][act.param] and corsair_rolls[gProfileSettings.lang.msg_text][act.param][m.param] or '') or ''
                local reaction_lookup = reaction_offsets[act.category] and (m.reaction - reaction_offsets[act.category]) or 0
                local has_line_break = string.find(res_actmsg[m.message][gProfileSettings.lang.msg_text], '${lb}') and true or false
                local prefix = (not has_line_break or gProfileSettings.mode.simplify) and gActionHandlers.GetPrefix(act.category, m.effect, m.message, m.unknown, reaction_lookup) or ''
                local prefix2 = has_line_break and gActionHandlers.GetPrefix(act.category, m.effect, m.message, m.unknown, reaction_lookup) or ''
                local message = prefix..gActionHandlers.MakeCondesedamageNumber(m.number)..( gFuncs.CleanMsg((msg or tostring(m.message))
                :gsub('${spell}',act.action.spell or 'ERROR 111')
                :gsub('${ability}',gFuncs.ColorIt(act.action.ability or 'ERROR 112',gProfileColor.abilcol))
                :gsub('${item}',gFuncs.ColorIt(act.action.item or 'ERROR 113',gProfileColor.itemcol))
                :gsub('${item2}',count..gFuncs.ColorIt(act.action.item2 or 'ERROR 121',gProfileColor.itemcol))
                :gsub('${weapon_skill}',act.action.weapon_skill or 'ERROR 114')
                :gsub('${abil}',m.simp_name or 'ERROR 115')
                :gsub('${numb}',numb..roll or 'ERROR 116')
                :gsub('${actor}\'s',gFuncs.ColorIt(act.actor.name or 'ERROR 117',gProfileColor[act.actor.owner or act.actor.type])..'\'s'..act.actor.owner_name)
                :gsub('${actor}',gFuncs.ColorIt(act.actor.name or 'ERROR 117',gProfileColor[act.actor.owner or act.actor.type])..act.actor.owner_name)
                :gsub('${target}\'s',targ)
                :gsub('${target}',targ)
                :gsub('${lb}','\7'..prefix2)
                :gsub('${number}',(act.action.number or m.param)..roll)
                :gsub('${status}',m.status or 'ERROR 120')
                :gsub('${gil}',m.param..' gil'), m.message))
                if m.message == 377 and act.actor_id == Self.ServerId then
                    gFuncs.SendDelayedMessage:bind1(color):bind1(message):once(0.5)
                else
                    AshitaCore:GetChatManager():AddChatMessage(color, false, message)
                end
                if not non_block_messages:contains(m.message) then
                    m.message = 0
                end
            end
            if m.has_add_effect and m.add_effect_message ~= 0 and add_effect_valid[act.category] then
                local targ = gActionHandlers.AssembleTargets(act.actor, v.target, act.category, m.add_effect_message, m.has_add_effect)
                local col = res_actmsg[m.add_effect_message].color
                local color = gActionHandlers.ColorFilt(col, v.target[1].server_id == Self.ServerId)
                if m.add_effect_message > 287 and m.add_effect_message < 303 then m.simp_add_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv(skillchain_arr[gProfileSettings.lang.msg_text][m.add_effect_message-287])
                elseif m.add_effect_message > 384 and m.add_effect_message < 399 then m.simp_add_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv(skillchain_arr[gProfileSettings.lang.msg_text][m.add_effect_message-384])
                elseif m.add_effect_message > 766 and m.add_effect_message < 769 then m.simp_add_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv(skillchain_arr[gProfileSettings.lang.msg_text][m.add_effect_message-752])
                elseif m.add_effect_message > 768 and m.add_effect_message < 771 then m.simp_add_name = UTF8toSJIS:UTF8_to_SJIS_str_cnv(skillchain_arr[gProfileSettings.lang.msg_text][m.add_effect_message-754])
                elseif m.add_effect_message == 603 then m.simp_add_name = 'AE: TH'
                elseif m.add_effect_message == 605 then m.simp_add_name = 'AE: Death'
                elseif m.add_effect_message == 776 then m.simp_add_name = 'AE: Chainbound'
                else m.simp_add_name = 'AE'
                end
                local msg, numb = gActionHandlers.SimplifyMessage(m.add_effect_message)
                if not gProfileSettings.mode.simplify and gProfileSettings.lang.msg_text == 'jp' then
                    msg = UTF8toSJIS:UTF8_to_SJIS_str_cnv(msg)
                end

                if not gProfileSettings.mode.simplify and gProfileSettings.lang.msg_text ~= 'jp' then
                    if col == 'D' or grammar_numb_msg:contains(m.add_effect_message) then
                        msg = gFuncs.GrammaticalNumberFix(msg, (m.cparam or m.param), m.add_effect_message)
                    end
                    if common_nouns:contains(act.actor.id) then
                        msg = gFuncs.ActorNoun(msg)
                    end
                    if plural_entities:contains(act.actor.id) then
                        msg = gFuncs.PluralActor(msg, m.add_effect_message)
                    end
                    if targets_condensed or plural_entities:contains(v.target[1].server_id) then
                        msg = gFuncs.PluralTarget(msg, m.add_effect_message)
                    end
                end
                if m.add_effect_fields.status then numb = m.add_effect_status else numb = gActionHandlers.PrefSuf((m.cadd_effect_param or m.add_effect_param), m.add_effect_message, act.actor.damage, col) end
                if not act.action then
                    --AshitaCore:GetChatManager():AddChatMessage(color, false, 'act.action==nil : '..m.message..' - '..m.add_effect_message..' - '..msg)
                else
                    AshitaCore:GetChatManager():AddChatMessage(color, false, gActionHandlers.MakeCondesedamageNumber(m.add_effect_number)..(gFuncs.CleanMsg(msg
                    :gsub('${spell}',act.action.spell or 'ERROR 127')
                    :gsub('${ability}',act.action.ability or 'ERROR 128')
                    :gsub('${item}',act.action.item or 'ERROR 129')
                    :gsub('${weapon_skill}',act.action.weapon_skill or 'ERROR 130')
                    :gsub('${abil}',m.simp_add_name or act.action.name or 'ERROR 131')
                    :gsub('${numb}',numb or 'ERROR 132')
                    :gsub('${actor}\'s',gFuncs.ColorIt(act.actor.name,gProfileColor[act.actor.owner or act.actor.type])..'\'s'..act.actor.owner_name)
                    :gsub('${actor}',gFuncs.ColorIt(act.actor.name,gProfileColor[act.actor.owner or act.actor.type])..act.actor.owner_name)
                    :gsub('${target}\'s',targ)
                    :gsub('${target}',targ)
                    :gsub('${lb}','\7')
                    :gsub('${number}',m.add_effect_param)
                    :gsub('${status}',m.add_effect_status or 'ERROR 178'), m.add_effect_message)))
                    if not non_block_messages:contains(m.add_effect_message) then
                        m.add_effect_message = 0
                    end
                end
            end
            if m.has_spike_effect and m.spike_effect_message ~= 0 and spike_effect_valid[act.category] then
                local targ = gActionHandlers.AssembleTargets(act.actor, v.target, act.category, m.spike_effect_message, m.has_spike_effect)
                local col = res_actmsg[m.spike_effect_message].color
                local color = gActionHandlers.ColorFilt(col, act.actor.id == Self.ServerId)

                local actor = act.actor
                if m.spike_effect_message == 14 then
                    m.simp_spike_name = 'from counter'
                elseif T{33,606}:contains(m.spike_effect_message) then
                    m.simp_spike_name = 'counter'
                    actor = v.target[1] --Counter dmg is done by the target, fix for coloring the dmg
                elseif m.spike_effect_message == 592 then
                    m.simp_spike_name = 'missed counter'
                elseif m.spike_effect_message == 536 then
                    m.simp_spike_name = 'retaliation'
                    actor = v.target[1] --Retaliation dmg is done by the target, fix for coloring the dmg
                elseif m.spike_effect_message == 535 then
                    m.simp_spike_name = 'from retaliation'
                else
                    m.simp_spike_name = 'spikes'
                    actor = v.target[1] --Spikes dmg is done by the target, fix for coloring the dmg
                end

                local msg = gActionHandlers.SimplifyMessage(m.spike_effect_message)
                if not gProfileSettings.mode.simplify and gProfileSettings.lang.msg_text == 'jp' then
                    msg = UTF8toSJIS:UTF8_to_SJIS_str_cnv(msg)
                end
                if not gProfileSettings.mode.simplify and gProfileSettings.lang.msg_text ~= 'jp' then
                    if col == 'D' or grammar_numb_msg:contains(m.spike_effect_message) then
                        msg = gFuncs.GrammaticalNumberFix(msg, (m.cparam or m.param), m.spike_effect_message)
                    end
                    if common_nouns:contains(act.actor.id) then
                        msg = gFuncs.ActorNoun(msg)
                    end
                    if plural_entities:contains(act.actor.id) then
                        msg = gFuncs.PluralActor(msg, m.spike_effect_message)
                    end
                    if targets_condensed or plural_entities:contains(v.target[1].server_id) then
                        msg = gFuncs.PluralTarget(msg, m.spike_effect_message)
                    end
                end
                if m.spike_effect_fields.status then numb = m.spike_effect_status else numb = gActionHandlers.PrefSuf((m.cspike_effect_param or m.spike_effect_param), m.spike_effect_message, actor.damage, col) end
                AshitaCore:GetChatManager():AddChatMessage(color, false, gActionHandlers.MakeCondesedamageNumber(m.spike_effect_number)..(gFuncs.CleanMsg(msg
                :gsub('${spell}',act.action.spell or 'ERROR 142')
                :gsub('${ability}',act.action.ability or 'ERROR 143')
                :gsub('${item}',act.action.item or 'ERROR 144')
                :gsub('${weapon_skill}',act.action.weapon_skill or 'ERROR 145')
                :gsub('${abil}',m.simp_spike_name or act.action.name or 'ERROR 146')
                :gsub('${numb}',numb or 'ERROR 147')
                :gsub('${actor}\'s',gFuncs.ColorIt(act.actor.name,gProfileColor[act.actor.owner or act.actor.type])..'\'s'..act.actor.owner_name)
                :gsub((gProfileSettings.mode.simplify and '${target}' or '${actor}'),gFuncs.ColorIt(act.actor.name,gProfileColor[act.actor.owner or act.actor.type])..act.actor.owner_name)
                :gsub('${target}\'s',targ)
                :gsub((gProfileSettings.mode.simplify and '${actor}' or '${target}'),targ)
                :gsub('${lb}','\7')
                :gsub('${number}',m.spike_effect_param)
                :gsub('${status}',m.spike_effect_status or 'ERROR 150'), m.spike_effect_message)))
                if not non_block_messages:contains(m.spike_effect_message) then
                    m.spike_effect_message = 0
                end
            end
        end
    end
    return act
end

actionhandlers.ActToString = function(original,act)
    if type(act) ~= 'table' then return act end
    
    function assemble_bit_packed(init,val,initial_length,final_length)
        if not init then return init end
        
        if type(val) == 'boolean' then
            if val then val = 1 else val = 0 end
        elseif type(val) ~= 'number' then
            return false
        end
        local bits = initial_length%8
        local byte_length = math.ceil(final_length/8)
        
        local out_val = 0
        if bits > 0 then
            out_val = init:byte(#init) -- Initialize out_val to the remainder in the active byte.
            init = init:sub(1,#init-1) -- Take off the active byte
        end
        out_val = out_val + val*2^bits -- left-shift val by the appropriate amount and add it to the remainder (now the lsb-s in val)
        
        while out_val > 0 do
            init = init..string.char(out_val%256)
            out_val = math.floor(out_val/256)
        end
        while #init < byte_length do
            init = init..string.char(0)
        end
        return init
    end
    
    local react = assemble_bit_packed(tostring(original):sub(1,4),act.size,32,40)
    react = assemble_bit_packed(react,act.actor_id,40,72)
    react = assemble_bit_packed(react,act.target_count,72,82)
    react = assemble_bit_packed(react,act.category,82,86)
    react = assemble_bit_packed(react,act.param,86,102)
    react = assemble_bit_packed(react,act.unknown,102,118)
    react = assemble_bit_packed(react,act.recast,118,150)
    
    local offset = 150
    for i = 1,act.target_count do
        react = assemble_bit_packed(react,act.targets[i].server_id,offset,offset+32)
        react = assemble_bit_packed(react,act.targets[i].action_count,offset+32,offset+36)
        offset = offset + 36
        for n = 1,act.targets[i].action_count do
            react = assemble_bit_packed(react,act.targets[i].actions[n].reaction,offset,offset+5)
            react = assemble_bit_packed(react,act.targets[i].actions[n].animation,offset+5,offset+17)
            react = assemble_bit_packed(react,act.targets[i].actions[n].effect,offset+17,offset+21)
            react = assemble_bit_packed(react,act.targets[i].actions[n].stagger,offset+21,offset+24)
            react = assemble_bit_packed(react,act.targets[i].actions[n].knockback,offset+24,offset+27)
            react = assemble_bit_packed(react,act.targets[i].actions[n].param,offset+27,offset+44)
            react = assemble_bit_packed(react,act.targets[i].actions[n].message,offset+44,offset+54)
            react = assemble_bit_packed(react,act.targets[i].actions[n].unknown,offset+54,offset+85)
            
            react = assemble_bit_packed(react,act.targets[i].actions[n].has_add_effect,offset+85,offset+86)
            offset = offset + 86
            if act.targets[i].actions[n].has_add_effect then
                react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_animation,offset,offset+6)
                react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_effect,offset+6,offset+10)
                react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_param,offset+10,offset+27)
                react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_message,offset+27,offset+37)
                offset = offset + 37
            end
            react = assemble_bit_packed(react,act.targets[i].actions[n].has_spike_effect,offset,offset+1)
            offset = offset + 1
            if act.targets[i].actions[n].has_spike_effect then
                react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_animation,offset,offset+6)
                react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_effect,offset+6,offset+10)
                react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_param,offset+10,offset+24)
                react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_message,offset+24,offset+34)
                offset = offset + 34
            end
        end
    end
    if react then
        while #react < #original do
            react = react..original:sub(#react+1,#react+1)
        end
    else
		gFuncs.Error('Act to String Failed: Invalid Act table returned.')
    end
    return react
end

actionhandlers.StringToAct = function(packet)
    local act_table = {}
    if string.byte(packet) ~= 0x28 then
        return act_table
    end
    act_table['size'] = ashita.bits.unpack_be(packet:totable(), 32, 8)
    act_table['actor_id'] = ashita.bits.unpack_be(packet:totable(), 40, 32)
	act_table['actor_index'] = struct.unpack('L', packet, 0x05 + 1);
    act_table['target_count'] = ashita.bits.unpack_be(packet:totable(), 72, 10)
    act_table['category'] = ashita.bits.unpack_be(packet:totable(), 82, 4)
    act_table['param'] = ashita.bits.unpack_be(packet:totable(), 86, 16)
	act_table['msg'] = ashita.bits.unpack_be(packet:totable(), 230, 10);
    act_table['unknown'] = ashita.bits.unpack_be(packet:totable(), 102, 16)
    act_table['recast'] = ashita.bits.unpack_be(packet:totable(), 118, 32)
    act_table['targets'] = {}

    local offset = 150
    for i = 1, act_table.target_count do
        local target = {}
        target['offset_start']                   = offset
        target['server_id']                             = ashita.bits.unpack_be(packet:totable(), offset,     32)
        target['action_count']                   = ashita.bits.unpack_be(packet:totable(), offset+32,   4)
        target['actions'] = {}
        offset = offset + 36
        for n = 1, target.action_count do
            local action = {}
            action['offset_start']               = offset
            action['reaction']                   = ashita.bits.unpack_be(packet:totable(), offset,     5)
            action['animation']                  = ashita.bits.unpack_be(packet:totable(), offset+5,  12)
            action['effect']                     = ashita.bits.unpack_be(packet:totable(), offset+17,  4)
            action['stagger']                    = ashita.bits.unpack_be(packet:totable(), offset+21,  3)
            action['knockback']                  = ashita.bits.unpack_be(packet:totable(), offset+24,  3)
            action['param']                      = ashita.bits.unpack_be(packet:totable(), offset+27, 17)
            action['message']                    = ashita.bits.unpack_be(packet:totable(), offset+44, 10)
            action['unknown']                    = ashita.bits.unpack_be(packet:totable(), offset+54, 31)

            action['has_add_effect']             = ashita.bits.unpack_be(packet:totable(), offset+85,  1)
            action['has_add_effect']             = action.has_add_effect == 1
            offset = offset + 86
            if action.has_add_effect then
                action['add_effect_animation']   = ashita.bits.unpack_be(packet:totable(), offset,     6)
                action['add_effect_effect']      = ashita.bits.unpack_be(packet:totable(), offset+6,   4)
                action['add_effect_param']       = ashita.bits.unpack_be(packet:totable(), offset+10, 17)
                action['add_effect_message']     = ashita.bits.unpack_be(packet:totable(), offset+27, 10)
                offset = offset + 37
            end
            action['has_spike_effect']           = ashita.bits.unpack_be(packet:totable(), offset,     1)
            action['has_spike_effect']           = action.has_spike_effect == 1
            offset = offset + 1
            if action.has_spike_effect then
                action['spike_effect_animation'] = ashita.bits.unpack_be(packet:totable(), offset,     6)
                action['spike_effect_effect']    = ashita.bits.unpack_be(packet:totable(), offset+6,   4)
                action['spike_effect_param']     = ashita.bits.unpack_be(packet:totable(), offset+10, 14)
                action['spike_effect_message']   = ashita.bits.unpack_be(packet:totable(), offset+24, 10)
                offset = offset + 34
            end
            action['offset_end']                 = offset
            table.insert(target['actions'], action)
        end
        target['offset_end'] = offset
        table.insert(act_table['targets'], target)
    end
	
    return act_table
end

actionhandlers.PrefSuf = function (param, msg_ID, actor_dmg, col)
    local outstr = (col == 'D' or dmg_drain_msg:contains(msg_ID)) and gFuncs.ColorIt(tostring(param), gProfileColor[actor_dmg]) or tostring(param)
    local msg = res_actmsg[msg_ID] or nil
    if msg then
        if msg.prefix then
            outstr = msg.prefix..' '..outstr
        end
        if msg.suffix then
            if msg.suffix == 'shadow' and param ~= 1 then
                outstr = outstr..' shadows'
            elseif msg.suffix == 'Petra' and param ~= 1 then
                outstr = outstr..' Petras'
            elseif msg.suffix == 'effects disappears' and param ~= 1 then
                outstr = outstr..' effects disappear'
            elseif msg_ID == 641 then
                outstr = outstr..' 1 attribute drained'
            elseif msg.suffix == 'attributes drained' and param == 1 then
                outstr = outstr..' attribute drained'
            elseif msg.suffix == 'status effect drained' and param ~= 1 then
                outstr = outstr..' status effects drained'
            elseif msg.suffix == 'status ailments disappears' and param ~= 1 then
                outstr = outstr..' status ailments disappear'
            elseif msg.suffix == 'status ailments absorbed' and param == 1 then
                outstr = outstr..' status ailment absorbed'
            elseif msg.suffix == 'status ailments healed' and param == 1 then
                outstr = outstr..' status ailment healed'
            elseif msg.suffix == 'status benefits absorbed' and param == 1 then
                outstr = outstr..' status benefit absorbed'
            elseif msg.suffix == 'status effects removed' and param == 1 then
                outstr = outstr..' status effect removed'
            elseif msg.suffix == 'magic effects drained' and param == 1 then
                outstr = outstr..' magic effect drained'
            elseif msg.suffix == 'magical effects received' and param == 1 then
                outstr = outstr..' magical effect received'
            elseif msg.suffix == 'magical effects copied' and param == 1 then
                outstr = outstr..' magical effect copied'
            else
                outstr = outstr..' '..msg.suffix
            end
        end
    end
    return outstr
end


actionhandlers.SimplifyMessage = function (msg_ID)
    local msg = res_actmsg[msg_ID][gProfileSettings.lang.msg_text]
    local fields = gFuncs.SearchField(msg)

    if gProfileSettings.mode.simplify and not T{23,64,133,204,210,211,212,213,214,350,442,516,531,557,565,582}:contains(msg_ID) then
        if T{93,273,522,653,654,655,656,85,284,75,114,156,189,248,283,312,323,336,351,355,408,422,423,425,453,659,158,245,324,658}:contains(msg_ID) then
            fields.status = true
        end
        if msg_ID == 31 or msg_ID == 798 or msg_ID == 799 then
            fields.actor = true
        end
        if (msg_ID > 287 and msg_ID < 303) or (msg_ID > 384 and msg_ID < 399) or (msg_ID > 766 and msg_ID < 771) or T{129,152,161,162,163,165,229,384,453,603,652,798}:contains(msg_ID) then
            fields.ability = true
        end

        if T{125,593,594,595,596,597,598,599}:contains(msg_ID) then
            fields.ability = true
            fields.item = true
        end

        if T{129,152,153,160,161,162,163,164,165,166,167,168,229,244,652}:contains(msg_ID) then
            fields.actor  = true
            fields.target = true
        end

        if msg_ID == 139 then
            fields.number = true
        end

        local Despoil_msg = {[593] = 'Attack Down', [594] = 'Defense Down', [595] = 'Magic Atk. Down', [596] = 'Magic Def. Down', [597] = 'Evasion Down', [598] = 'Accuracy Down', [599] = 'Slow',}

        if gProfileSettings.text.line_full and fields.number and fields.target and fields.actor then
            msg = gProfileSettings.text.line_full
        elseif gProfileSettings.text.line_aoebuff and fields.status and fields.target then --and fields.actor then -- and (fields.spell or fields.ability or fields.item or fields.weapon_skill) then
            msg = gProfileSettings.text.line_aoebuff
        elseif gProfileSettings.text.line_item and fields.item2 then
            if fields.number then
                msg = gProfileSettings.text.line_itemnum
            else
                msg = gProfileSettings.text.line_item
            end
        elseif gProfileSettings.text.line_steal and fields.item and fields.ability then
            if T{593,594,595,596,597,598,599}:contains(msg_ID) then
                msg = gProfileSettings.text.line_steal..''..string.char(0x07)..'AE: '..gFuncs.ColorIt(Despoil_msg[msg_ID], gProfileColor['statuscol'])
            else
                msg = gProfileSettings.text.line_steal
            end
        elseif gProfileSettings.text.line_nonumber and not fields.number then
            msg = gProfileSettings.text.line_nonumber
        elseif gProfileSettings.text.line_aoe and T{264}:contains(msg_ID) then
            msg = gProfileSettings.text.line_aoe
        elseif gProfileSettings.text.line_noactor and not fields.actor and (fields.spell or fields.ability or fields.item or fields.weapon_skill) then
            msg = gProfileSettings.text.line_noactor
        elseif gProfileSettings.text.line_noability and not fields.actor then
            msg = gProfileSettings.text.line_noability
        elseif gProfileSettings.text.line_notarget and fields.actor and fields.number then
            if msg_ID == 798 then -- Maneuver message
                msg = gProfileSettings.text.line_notarget..'%'
            elseif msg_ID == 799 then -- Maneuver message with overload
                msg = gProfileSettings.text.line_notarget..'% (${actor} overloaded)'
            else
                msg = gProfileSettings.text.line_notarget
            end
        end
    end
    return msg
end

actionhandlers.AssembleTargets = function (actor, targs, category, msg, add_effect)
    local targets = {}
    local samename = {}
    local total = 0
    for i, v in pairs(targs) do
        -- Done in two loops so that the ands and commas don't get out of place.
        -- This loop filters out unwanted targets.
        if gFuncs.CheckFilter(actor, v, category, msg) or gFuncs.CheckFilter(v, actor, category, msg) then
            if samename[v.name] and gProfileSettings.mode.condensetargetname then
                samename[v.name] = samename[v.name] + 1
            else
                targets[#targets+1] = v
                samename[v.name] = 1
            end
            total = total + 1
        end
        if add_effect then break end
    end
    local out_str
    if gProfileSettings.mode.targetnumber and total > 1 then
        out_str =  '{'..total..'}: '
    else
        out_str = ''
    end

    for i, v in pairs(targets) do
        local name = string.gsub(v.name,' ', string.char(0x81,0x3F)) --fix for ffxi chat splits on space
        local article = ''
        if gProfileSettings.lang.msg_text ~= 'jp' then
            article = common_nouns:contains(v.id) and (not gProfileSettings.mode.simplify or msg == 206) and 'The ' or ''
        end
        local numb = gProfileSettings.mode.condensetargetname and samename[v.name] > 1 and ' {'..samename[v.name]..'}' or ''
        if i == 1 then
            name = gFuncs.ColorIt(name, gProfileColor[v.owner or v.type])..v.owner_name
            if samename[v.name] > 1 then
                targets_condensed = true
            else
                if (not gProfileSettings.mode.simplify or msg == 206) and #targets == 1 and string.find(res_actmsg[msg][gProfileSettings.lang.msg_text], '${target}\'s') then
                    name = gFuncs.ColorIt(name, gProfileColor[v.owner or v.type])..(plural_entities:contains(v.id) and '\'' or '\'s')..v.owner_name
                end
                targets_condensed = false
            end
            out_str = out_str..article..name..numb
        else
            targets_condensed = true
            name = gFuncs.ColorIt(name, gProfileColor[v.owner or v.type])..v.owner_name
            out_str = gFuncs.Conjunctions(out_str, article..name..numb, #targets, i)
        end
    end
    out_str =  string.gsub(out_str,'-', string.char(0x81,0x7C)) --fix for ffxi chat splits on trusts with -
    return out_str
end

actionhandlers.MakeCondesedamageNumber = function (number)
    if gProfileSettings.mode.swingnumber and gProfileSettings.mode.condensedamage and 1 < number then
        return '['..number..'] '
    else
        return ''
    end
end

actionhandlers.ActorParse = function (actor_id)
    local actor_table = gFuncs.GetEntityByServerId(actor_id)
    local actor_name, typ, dmg, owner, filt, owner_name

    if actor_table == nil then
        --return {name= nil, id=nil, is_npc=nil, type='debug', owner=nil, owner_name=nil, race=nil}
        return {name= ('{Debug ID: %s}'):fmt(actor_id), id= '{DebugID}', is_npc= true, type= 'debug', damage= 'otherdmg', filter= 'others', owner= 'other', owner_name= '{Owner}', race= 0}
    end

    local ActorIsNpc = bit.band(actor_table.SpawnFlags, 0x1) == 0

    for i,v in pairs(gFuncs.GetPartyData()) do
        if type(v) == 'table' and v.mob and v.mob.ServerId == actor_table.ServerId then
            typ = i
            if i == 'p0' then
                filt = 'me'
                dmg = 'mydmg'
            elseif i:sub(1, 1) == 'p' then
                filt = 'party'
                dmg = 'partydmg'
            else
                filt = 'alliance'
                dmg = 'allydmg'
            end
        end
    end

    if not filt then
        if ActorIsNpc then
            if actor_table.TargetIndex > 1791 then
                typ = 'other_pets'
                filt = 'other_pets'
                owner = 'other'
                dmg = 'otherdmg'
                for i, v in pairs(gFuncs.GetPartyData()) do
                    if type(v) == 'table' and v.mob and v.mob.PetTargetIndex and v.mob.PetTargetIndex == actor_table.TargetIndex then
                        if i == 'p0' then
                            typ = 'my_pet'
                            filt = 'my_pet'
                            dmg = 'mydmg'
                        end
                        owner = i
                        owner_name = gProfileSettings.mode.showpetownernames and ' ('..gFuncs.ColorIt(v.mob.Name, gProfileColor[owner or typ])..') '
                        break
                    elseif type(v) == 'table' and v.mob and v.mob.FellowTargetIndex and v.mob.FellowTargetIndex == actor_table.TargetIndex then
                        if i == 'p0' then
                            typ = 'my_fellow'
                            filt = 'my_fellow'
                            dmg = 'mydmg'
                        end
                        owner = i
                        owner_name = gProfileSettings.mode.showpetownernames and ' ('..gFuncs.ColorIt(v.mob.Name, gProfileColor[owner or typ])..') '
                        break
                    end
                end
            else
                typ = 'mob'
                filt = 'monsters'
                dmg = 'mobdmg'

                if gProfileFilter.enemies then
                    for i,v in pairs(SelfPlayer:GetBuffs()) do
                        if domain_buffs:contains(v) then
                            -- If you are in Domain Invasion, or a Reive, or various other places
                            -- then all monsters should be considered enemies.
                            filt = 'enemies'
                            break
                        end
                    end

                    if filt ~= 'enemies' then
                        for i,v in pairs(gFuncs.GetPartyData()) do
                            if type(v) == 'table' and gFuncs.nf(v.mob, 'ServerId') == bit.band(actor_table.ClaimStatus, 0xFFFFFFFFFF) then
                                filt = 'enemies'
                                break
                            end
                        end
                    end
                end
            end
        else
            typ = 'other'
            filt = 'others'
            dmg = 'otherdmg'
        end
    end

    if actor_table.MonstrosityName ~= ' ' then
        actor_name = actor_table.Name
    else
        actor_name = actor_table.MonstrosityName
    end

    return {name = actor_name, id = actor_id, is_npc = ActorIsNpc, type = typ, damage = dmg, filter = filt, owner = (owner or nil), owner_name = (owner_name or ''), race = actor_table.Race}
end

actionhandlers.SpellParse = function (act)
    local spell, abil_ID, effect_val = {}
    -- If the target returns nil, will return No MSG instad of crashing.
    -- This is a bandaid
    if(act.targets[1] == nil) then
        return false;
    end
    local msg_ID = act.targets[1].actions[1].message

    if T{7, 8, 9}:contains(act.category) then
        abil_ID = act.targets[1].actions[1].param
    elseif T{3, 4, 5, 6, 11, 13, 14, 15}:contains(act.category) then
        abil_ID = act.param
        effect_val = act.targets[1].actions[1].param
    end

    if act.category == 1 then
        spell.data = {Name = {1, 2}}
        spell.data.Name[1] = 'hit'
        spell.data.Name[2] = UTF8toSJIS:UTF8_to_SJIS_str_cnv('の攻撃')
    elseif act.category == 2 and act.category == 12 then
        if msg_ID == 77 then
            spell.data = get_job_ability[171] -- Sange
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
            end
        elseif msg_ID == 157 then
            spell.data = get_job_ability[60] -- Barrage
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
            end
        else
            spell.data = {Name = {1, 2}}
            spell.data.Name[1] = 'Ranged Attack'
            spell.data.Name[2] = UTF8toSJIS:UTF8_to_SJIS_str_cnv('の遠隔攻撃')
        end
    elseif msg_ID == 673 then
        spell.data = {Name = {1, 2}}
        spell.data.Name[1] = 'Mweya Plasm'
        spell.data.Name[2] = UTF8toSJIS:UTF8_to_SJIS_str_cnv('スピリットプラスム')
    elseif msg_ID == 105 then
        spell.data = {Name = {1, 2}}
        spell.data.Name[1] = 'Experience Points'
        spell.data.Name[2] = UTF8toSJIS:UTF8_to_SJIS_str_cnv('経験値を')
    else
        if not res_actmsg[msg_ID] then
            if T{4, 8}:contains(act['category']) then
                spell.data = get_spell[abil_ID]
            elseif T{6, 14, 15}:contains(act['category']) or T{7, 13}:contains(act['category']) and false then
                spell.data = get_job_ability[abil_ID] -- May have to correct for charmed pets some day, but I'm not sure there are any monsters with TP moves that give no message.
            elseif T{3, 7, 11}:contains(act['category']) then
                if abil_ID < 256 then
                    spell.data = get_weapon_skill[abil_ID] -- May have to correct for charmed pets some day, but I'm not sure there are any monsters with TP moves that give no message.
                else
                    spell.data = get_mon_ability[abil_ID]
                end
            elseif T{5, 9}:contains(act['category']) then
                spell.data = get_item[abil_ID]
            else
                spell.data = {none = tostring(msg_ID)} -- Debugging
            end
            return spell
        end

        local fields = gFuncs.SearchField(res_actmsg[msg_ID][gProfileSettings.lang.msg_text])

        if fields.spell then
            spell.data = get_spell[abil_ID]
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], act.actor.type == 'mob' and gProfileColor.mobspellcol or gProfileColor.spellcol)
                spell.spell = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], act.actor.type == 'mob' and gProfileColor.mobspellcol or gProfileColor.spellcol)
            end
        elseif fields.ability then
            spell.data = get_job_ability[abil_ID]
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
                spell.ability = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
                if msg_ID == 139 then
                    spell.number = 'Nothing'
                end
            end
        elseif fields.weapon_skill then
            if abil_ID > 256 then -- WZ_RECOVER_ALL is used by chests in Limbus
                spell.data = get_mon_ability[abil_ID]
                if not spell.data then
                    spell.data = {Name = {1, 2}}
                    spell.data.Name[1] = 'Special Attack'
                    spell.data.Name[2] = UTF8toSJIS:UTF8_to_SJIS_str_cnv('必殺技')
                end
            elseif abil_ID <= 256 then
                spell.data = get_weapon_skill[abil_ID]
            end
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], act.actor.type == 'mob' and gProfileColor.mobwscol or gProfileColor.wscol)
                spell.weapon_skill = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], act.actor.type == 'mob' and gProfileColor.mobwscol or gProfileColor.wscol)
            end
        elseif msg_ID == 303 then
            spell.data = get_job_ability[74] -- Divine Seal
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
                spell.ability = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
            end
        elseif msg_ID == 304 then
            spell.data = get_job_ability[75] -- Elemental Seal
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
                spell.ability = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
            end
        elseif msg_ID == 305 then
            spell.data = get_job_ability[76] -- Trick Attack
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
                spell.ability = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
            end
        elseif msg_ID == 311 or msg_ID == 312 then
            spell.data = get_job_ability[79] -- Cover
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
                spell.ability = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
            end
        elseif msg_ID == 240 or msg_ID == 241 then
            spell.data = get_job_ability[43] -- Hide
            if spell.data then
                spell.name = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
                spell.ability = gFuncs.ColorIt(spell.data.Name[gProfileSettings.lang.object], gProfileColor.abilcol)
            end
        end

        if fields.item then
            if T{125,593,594,595,596,597,598,599}:contains(msg_ID) then
                local item_article = not gProfileSettings.mode.simplify and gFuncs.AddItemArticle(effect_val) or ''

                spell.item = gFuncs.ColorIt(get_item[effect_val].LogNameSingular[gProfileSettings.lang.object] and item_article..get_item[effect_val].LogNameSingular[gProfileSettings.lang.object] or item_article..get_item[effect_val].Name[gProfileSettings.lang.object], gProfileColor.itemcol)
                spell.item_id = abil_ID
            else
                spell.data = get_item[abil_ID]
                local item_article = not gProfileSettings.mode.simplify and gFuncs.AddItemArticle(spell.data.Id) or ''
                if spell.data then
                    spell.name = gFuncs.ColorIt(spell.data.LogNameSingular[gProfileSettings.lang.object] and item_article..spell.data.LogNameSingular[gProfileSettings.lang.object] or item_article..spell.data.Name[gProfileSettings.lang.object], gProfileColor.itemcol)
                    spell.item = gFuncs.ColorIt(spell.data.LogNameSingular[gProfileSettings.lang.object] and item_article..spell.data.LogNameSingular[gProfileSettings.lang.object] or item_article..spell.data.Name[gProfileSettings.lang.object], gProfileColor.itemcol)
                    spell.item_id = abil_ID
                end
            end
        end

        if fields.item2 then
            local item_article = not gProfileSettings.mode.simplify and gFuncs.AddItemArticle(effect_val) or ''
            local tempspell = (msg_ID == 377 or msg_ID == 674) and get_item[effect_val] and get_item[effect_val].LogNamePlural[gProfileSettings.lang.object] and get_item[effect_val].LogNamePlural[gProfileSettings.lang.object] or get_item[effect_val].LogNameSingular[gProfileSettings.lang.object] and item_article..get_item[effect_val].LogNameSingular[gProfileSettings.lang.object] or item_article..get_item[effect_val].Name[gProfileSettings.lang.object]
            spell.item2 = gFuncs.ColorIt(tempspell, gProfileColor.itemcol)
            spell.item2_id = effect_val
            if fields.number then
                spell.number = act.targets[1].actions[1].add_effect_param
            end
        end
    end

    if spell.data and not spell.name then spell.name = spell.data.Name[gProfileSettings.lang.object] end
    return spell
end

actionhandlers.ColorFilt = function (col, is_me)
    --Used to convert situational colors from the resources into real colors
    --Depends on whether or not the target is you, the same as using in-game colors
    -- Returns a color code for chat parsing
    -- Does not currently support a Debuff/Buff distinction
    if col == 'D' then -- Damage
        if is_me then
            return 28
        else
            return 20
        end
    elseif col == 'M' then -- Misses
        if is_me then
            return 29
        else
            return 21
        end
    elseif col == 'H' then -- Healing
        if is_me then
            return 30
        else
            return 22
        end
    elseif col == 'B' then -- Beneficial effects
        if is_me then
            return 56
        else
            return 60
        end
    elseif col == 'DB' then -- Detrimental effects (I don't know how I'd split these)
        if is_me then
            return 57
        else
            return 61
        end
    elseif col == 'R' then -- Resists
        if is_me then
            return 59
        else
            return 63
        end
    else
        return col
    end
end

actionhandlers.GetPrefix = function (category, effect, message, unknown, reaction_lookup)
    local prefix = T{1,3,4,6,11,13,14,15}:contains(category) and (bit.band(unknown,1)==1 and 'Cover! ' or '')
                    ..(bit.band(unknown,4)==4 and 'Magic Burst! ' or '') --Used on Swipe/Lunge MB
                    ..(bit.band(unknown,8)==8 and 'Immunobreak! ' or '') --Unused? Displayed directly on message
                    ..(gProfileSettings.mode.showcritws and bit.band(effect,2)==2 and T{1,3,11}:contains(category) and message~=67 and 'Critical Hit! ' or '') --Unused? Crits have their own message
                    ..(gProfileSettings.mode.showblocks and reaction_lookup == 4 and 'Blocked! ' or '')
                    ..(gProfileSettings.mode.showguards and reaction_lookup == 2 and 'Guarded! ' or '')
                    ..(reaction_lookup == 3 and T{3,4,6,11,13,14,15}:contains(category) and 'Parried! ' or '') --Unused? They are send the same as missed
    return prefix
end

return actionhandlers;