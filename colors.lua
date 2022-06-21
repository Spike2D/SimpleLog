--[[ 
* Colors are customizable based on party / alliance position. Use the colortest command to view the available colors.

* If you wish for a color to be unchanged from its normal color, set it to 0.
--]]

local colors = T{
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
};

return colors;	
