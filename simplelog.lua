--[[
* Addons - Copyright (c) 2021 Ashita Development Team
* Contact: https://www.ashitaxi.com/
* Contact: https://discord.gg/Ashita
*
* This file is part of Ashita.
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.
--]]

addon.name      = 'simplelog';
addon.author    = 'Created by Byrth, Ported by Spiken';
addon.version   = '0.1.1';
addon.desc      = 'Combat log Parser';
addon.link      = 'https://github.com/Spike2D/SimpleLog';

require('common');
require('lib\\constants');
chat				= require('chat');
UTF8toSJIS			= require('lib\\shift_jis')

res_actmsg			= require('lib\\res\\action_messages')
res_igramm			= require('lib\\res\\items_grammar')
res_skills			= require('lib\\res\\skills')

gDefaultSettings    = require('configuration');
gStatus				= require('lib\\profilehandler');
gFuncs				= require('lib\\functions');
gFileTools			= require('lib\\filetools');
gCommandHandlers	= require('lib\\commandhandlers');
gTextHandlers		= require('lib\\texthandlers');
gPacketHandlers		= require('lib\\packethandlers');
gActionHandlers		= require('lib\\actionhandlers');
gConfig				= require('lib\\ui');

gProfileSettings	= nil;
gProfileFilter		= nil;
gProfileColor		= nil;


ashita.events.register('load', 'load_cb', function ()
	gStatus.Init();
end);

ashita.events.register('text_in', 'text_in_cb', function (e)
	gTextHandlers.HandleIncomingText(e);
end);

ashita.events.register('packet_in', 'packet_in_cb', function (e)
	gPacketHandlers.HandleIncomingPacket(e);
end);

ashita.events.register('packet_out', 'packet_out_cb', function (e)
	gPacketHandlers.HandleOutgoingPacket(e);
end);

ashita.events.register('command', 'command_cb', function (e)
	gCommandHandlers.HandleCommand(e);
end);

ashita.events.register('d3d_present', 'd3d_present_callback1', function ()
	gConfig.render_config(gConfig.state.toggle_menu)

	gConfig.toggle_menu(0)
end);
