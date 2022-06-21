--[[
* Filters are customizable based on the action user. So if you filter other pets, you're going
 to eliminate all messages initiated by everyone's pet but your own.
 
* True means "filter this"
* False means "don't filter this"

* Generally, the outer tag is the actor and the inner tag is the action.
 If the monster is the actor, then the inner tag is the target and the tag beyond that is the action.
--]]

local filters = T{
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
};

return filters;
