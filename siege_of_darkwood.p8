pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	plyr={
		x=8,
		y=8,
		lvl=1,
		hp=14,
		curr_hp=14,
		gold=80,
		exp=0,
		ac=10,
		dmg="1-2",
		d=2,
		amr_ac=0,
		str=15,
		int=13,
		wis=12,
		dex=14,
		con=15,
		cha=14,
		weapon="hands",
		armour="none",
		dead=false,
		win=false,
		init=0,
		type="derek",
		stat_points=0,
		castle_hp=100,
		castle_max_hp=100,
		magic={},
		potions={},
		bs="c"
		}
	reset_plyr={}
	save_plyr=deepcopy(plyr)
	save_fmap={}
	save_wave=1

	fmap={}
	wave=1
	wave_reset=true
	wave_adv=false

	lvl_up={0,30,60,180,380,750,900,1100,1400,1600,2100,1500,2000,2000,2500,3000,3000,4000,4000,5000,9999}

	temple={
		{desc="cure light wounds",gold=2,val="4",stat="hp"},
		{desc="cure serious wounds",gold=5,val="8",stat="hp"},
		{desc="heal",gold=20,val="full",stat="hp"}
		}

	weapons={
		{desc="dagger",gold=2,val="1-4",stat="dmg"},
		{desc="mace",gold=20,val="1-5",stat="dmg"},
		{desc="sword,short",gold=25,val="1-6",stat="dmg"},
		{desc="sword,long",gold=50,val="1-8",stat="dmg"},
		{desc="sword,two handed",gold=100,val="1-10",stat="dmg"}
		}

	armour={
		--light --dex mod
		{desc="padded",gold=5,val="11",stat="ac"},
		{desc="leather",gold=10,val="11",stat="ac"},
		{desc="studded leather",gold=45,val="12",stat="ac"},
		--medium --dex mod (max 2)
		{desc="hide",gold=10,val="12",stat="ac"},
		{desc="chain shirt",gold=50,val="13",stat="ac"},
		{desc="scale mail",gold=50,val="14",stat="ac"},
		{desc="breastplate",gold=400,val="14",stat="ac"},
		{desc="half plate",gold=750,val="15",stat="ac"},
		--heavy str requirements
		{desc="ring mail",gold=30,val="14",stat="ac"},
		{desc="chain mail",gold=75,val="16",stat="ac"},--str 13
		{desc="splint",gold=200,val="17",stat="ac"},--str 15
		{desc="plate",gold=1500,val="18",stat="ac"} --str 15
		}

	alchemist={
		{desc="potion of healing",gold=2,val="4",stat="potion"},
		{desc="potion of extra healing",gold=5,val="8",stat="potion"},
		{desc="potion of heal",gold=20,val="full",stat="potion"},
		{desc="potion of fiery breath",gold=10,val="1",stat="potion"}
		}

	magic={
		{desc="protection+1",gold=1000,val="1",stat="ring"},
		{desc="protection+2",gold=2000,val="1",stat="ring"},
		{desc="fire bolt",gold=1000,val="1",stat="wand"},
		{desc="lightning",gold=3000,val="1",stat="wand"},
		{desc="disintegrate",gold=4000,val="1",stat="wand"},
		{desc="healing",gold=1200,val="1",stat="staff"}--,
		--{desc="dog",gold=777,val="5",stat="cha"}
		}

	games={
		{desc="basilisk",gold=8,val="10",stat="wins"},
		{desc="dragon eyes",gold=5,val="6",stat="wins"},
		{desc="odd man out",gold=2,val="3",stat="wins"}
		}

	list_start=1
	list_min=1
	list_pos=1
	list_len=8
	idx=1
	if (#armour<list_len) then
		list_end=#armour
		list_len=list_end
	else
		list_end=list_len
	end
	list_max=list_end

	but_num=2
	but_pos=but_num

	field_num=8
	field_pos=1

	field_x=60
	field_y=83

	--state
	select=false
	gamestate=0

	bpos=1
	bmenu=true
	blist=false
	bluse=false
	use_magic=""
	bltype=""
	fpos=1
	fmenu=false
	o={}
	spos=1
	log1=""
	log2=""
	log3=""
	log4=""
	tlog=""
end

function _update()
	if(plyr.win and btnp(ユか✽ゆ)) reset()
	if(plyr.dead and btnp(🅾️)) then
		reset()
	elseif (gamestate==0 and (btnp(🅾️) or btnp(❎)) and fmenu==false) then
			fmenu=true
	elseif (fmenu) then
		if(btnp(⬆️) and fpos>1) fpos-=1
		if(btnp(⬇️) and fpos<#o) fpos+=1
		if(btnp(🅾️)) picobar_act(o[fpos]) fpos=1
		if(btnp(❎)) fmenu=false fpos=1
	else
		if (gamestate==1) then
			control_field()
		elseif (gamestate==2) then
			control_field_active()
		elseif (gamestate==3) then
			control_shop()
		elseif (gamestate==4) then
			control_battle()
		elseif (gamestate==5) then
			control_textbox()
		elseif (gamestate==6) then
			control_textbox()
			if(gamestate==1) wave_init()
		end
	end
end

function _draw()
	cls()
	if (wave_reset) wave_init()
	if (gamestate==0) then
		title_screen()
		reset_plyr=deepcopy(plyr)
	elseif (gamestate==1) then
		cls()
		field()
		o={"save","load","quit"}
		picobar(o)
		wave_clear()
		battle_init=true
	elseif (gamestate==2) then
		field()
		field_active()
		o={"save","load","quit"}
		picobar(o)
		battle_init=true
	elseif (gamestate==3) then
		cls()
		if (shop==1) menu("temple",temple,40)
		if (shop==2) menu("weapon shop",weapons,48)
		if (shop==3) menu("armourer",armour,56)
		if (shop==4) menu("alchemist",alchemist,64)
		if (shop==5) menu("magic items",magic,72)
		if (shop==6) menu("gaming hall",games,80)
		if (shop==7) gamestate=2
		if (shop==8) derek_stats()
	elseif (gamestate==4) then
		if(battle_init) then
			e={}
			for m=1,#fmap[plyr.x][plyr.y].mobs do
				add(e,spawn_enemy(fmap[plyr.x][plyr.y].mobs[m].creature))
			end
			battle_init=false
			plyr.init=initiative(bonus(plyr.dex))
			log4=""
			log3=""
			log2=""
			log1=""
		end
		battle_screen(e)
		o={"save","load","quit"}
		picobar(o)
		if(blist) then
			if(bpos==3) then
				battle_list(plyr.potions,"potion") list_max=#plyr.potions
			elseif(bpos==4) then
				battle_list(plyr.magic,"magic") list_max=#plyr.magic
			end
		end
	elseif (gamestate==5) then
		battle_screen(e)
		o={"save","load","quit"}
		picobar(o)
		textbox(tlog,28)
	elseif (gamestate==6) then
		tlog="wave clear"
		textbox(tlog,28)
	end

	if (wave_adv) wave_attack() wave_advance()
	if (plyr.dead) gameover()
	if (plyr.win) win()
end
-->8
--menu
function menu(title,list,icon)
	list_end=#list
	list_len=#list
	list_limit=#list
	list_max=#list

	map(0,0)

	tx=centre_text(title)
	rectfill(tx-1,1,128-tx+1,6,6)
	print(title,tx+1,1,0)

	--image
	yrpt=3
	xrpt=5
	xpic=flr(50/xrpt)
	ypic=flr(87/yrpt)

	sspr(0, 64, 24, 32,5,13,50,87)
	rect(5,13,55,100,0)
	--spr(icon,27,53)
	--sspr( sx, sy, sw, sh, dx, dy, [dw,] [dh,] [flip_x,] [flip_y] )
	sspr(104,8,8,8,17,41,32,32)
	sspr(icon,8,8,8,16,40,32,32)

	--textbox
	rect(60,50,116,100,0)
	rect(116,50,124,100,0)
	rect(116,88,124,94,0)

	list_move(list_pos,8,list)

	idx=1
	for l=list_start,list_limit do
		if (idx==list_pos) then
			rectfill(61,51+6*(idx-1),115,57+6*(idx-1),12)
			print(list[l].desc,60,14,8)
			--stats
			print("cost:",60,24,0)
			g=ceil(list[l].gold*(1-bonus(plyr.cha)/10))
			print(g,126-#tostr(g)*4,24,8)
			print(list[l].stat..":",60,30,0)
			print(list[l].val,126-#list[l].val*4,30,8)
			print("curr "..list[l].stat..":",60,36,5)
			if (title=="weapon shop") then
				print(plyr.dmg,126-#plyr.dmg*4,36,5)
			elseif (title=="armourer") then
				print(plyr.amr_ac,126-#tostr(plyr.amr_ac)*4,36,5)
			end
		end
		txt=list[l].desc
		if(#txt>12) txt=sub(txt,1,12).."…"
		print(txt,62,52+6*(idx-1),0)
		if (list_pos<=list_end) then
			idx+=1
		end
	end
	--scroll bar
	rectfill(117,51,123,87,6)

	p=list_pos+list_start-1

	--scroll icon
	scroll_bar(117,51,40)

	--line under title
	line(60,20,124,20,0)

	local pad=2

	if (but_pos==1 and select) then
		gamestate=1
		select=false
		but_pos=2
		list_pos=1
		list_start=1
	elseif (but_pos==1) then
		button(63,110,"leave",true)
	else
		button(63,110,"leave",false)
	end
	if (but_pos==2) then
		button(101,110,"buy",true)
		v=list[p].val
		lg=ceil(list[p].gold*(1-bonus(plyr.cha)/10))
		if (select and plyr.gold-lg>=0 and plyr.dmg != v) then
			if (title=="weapon shop") then
				plyr.dmg=v
				plyr.d=tonum(sub(v,3))
				plyr.weapon=list[p].desc
			elseif (title=="armourer") then
				plyr.amr_ac=v
				plyr.armour=list[p].desc
			elseif (title=="alchemist") then
				add(plyr.potions,list[p])
			elseif (title=="magic items") then
				add(plyr.magic,list[p])
			elseif (title=="gaming hall") then
				if(list[p].desc=="basilisk") then
					if(droll(1,6)==1) then
						plyr.gold+=10
					elseif(droll(1,6)==1) then
						plyr.gold+=10
					end
				elseif(list[p].desc=="dragon eyes") then
					if(droll(1,6)==droll(1,6)) plyr.gold+=6
				elseif(list[p].desc=="odd man out") then
					d=droll(2,6)
					if(flr(d/2)*2==d) plyr.gold+=3
				end
			elseif (title=="temple") then
				if(v == "full")then
					plyr.curr_hp=plyr.hp
				elseif(plyr.curr_hp+v <= plyr.hp) then
					plyr.curr_hp+=v
				else
					plyr.curr_hp=plyr.hp
				end
			end
			plyr.gold-=lg
		end
	else
		button(101,110,"buy",false)
	end

	--gold
	print("gold:",5,110,8)
	print(plyr.gold,25,110,0)
end

function button(x,y,text,highlight)
	local col=0

	--button
	rect(x-2,y-2,x+22,y+6,col)
	offset=(20-#text*4)/2
	print(text,x+offset+1,y,col)

	--highlight
	if (highlight) then
		col=12
		pset(x-2,y-2,col)
		pset(x-2,y+6,col)
		pset(x+22,y+6,col)
		pset(x+22,y-2,col)

		rect(x-3,y-3,x+23,y+7,col)
		pset(x-3,y-3,7)
		pset(x-3,y+7,7)
		pset(x+23,y+7,7)
		pset(x+23,y-3,7)
	else
		pset(x-2,y-2,7)
		pset(x-2,y+6,7)
		pset(x+22,y+6,7)
		pset(x+22,y-2,7)
	end
end

function scroll_bar(x,y,h)
	scy=y+(h/list_max)*(list_start+list_pos-1)-(h/list_max)
	if(scy>y+h-10) scy=y+h-10
	spr(18,x,scy)

    palt(0,false)
    palt(14,true)
	spr(43,x+1,y+h-1)
	spr(44,x+1,y+h+5)
	palt(0,true)
    palt(14,false)
end

-->8
--helper
function animate(tbl)
	if(tbl.offset>=tbl.spd) then
		if(tbl.size=="s") then
		    rn=ceil(rnd(3))
		    if(rn==1) tbl.spr=tbl.stspr+16
		    if(rn==2) tbl.spr=tbl.stspr+17
		    if(rn==3) tbl.spr=tbl.stspr+1
		else
		    rn=ceil(rnd(4))
		    if(rn==1) tbl.spr=tbl.stspr+16
		    if(rn==2) tbl.spr=tbl.stspr+17
		    if(rn==3) tbl.spr2=tbl.stspr
		    if(rn==4) tbl.spr2=tbl.stspr+1
		end
		tbl.offset=0
	else
		tbl.offset+=1
	end
end

function centre_text(str)
	pos=((32*4)-(#str*4))/2
	return pos
end

function num_size(num)
	return (4*#tostr(num))
end

function list_move(pos,display,list)
	--if (pos==list_max) then
	if (pos==display) then
		list_start+=1
		list_end+=1
		--list_max+=1
		list_pos-=1
	end
	if (pos==list_min and list_start>1) then
		list_end-=1
		list_start-=1
		list_pos+=1
	end

	if(list_start+display-1<=#list) then
		list_limit=list_start+display-1
	else
		list_limit=#list
	end
end
function add_log(txt)
	log4=log3
	log3=log2
	log2=log1
	log1=txt
end

function textbox(text,s)
	pad=20
	chars=20
	lines=ceil(#text/chars)+1
	xtra=(lines-5)*7
	rectfill(21,21,108,71+xtra,1)
	rectfill(20,20,107,70+xtra,7)
	--rect(1+pad,1+pad,126-pad,89-pad,0)
	rectfill(25,25,33,34,0)
	spr(s,26,26)
	for t=1,lines do
		print(sub(text,(t-1)*chars,t*chars-1),25,37+(t-1)*7,0)
		--print(tlog,5+pad,5+pad+1+11)
	end

	dbutton("s",99,64+xtra,true)
end

function dbutton(type,x,y,bg)
	if(bg) then
		bprint("❎",x,y,0,0)
	end
	if(type=="s") then
		if(plyr.bs=="c") then
			spr(16,x,y)
		else
			spr(32,x,y)
		end
	end
	if(type=="x") then
		if(plyr.bs=="c") then
			spr(32,x,y)
		else
			spr(16,x,y)
		end
	end
end

function bprint(str,x,y,c1,c2)
	color(c2)
	print(str,x-1,y-1)
	print(str,x-1,y)
	print(str,x,y-1)
	print(str,x+1,y+1)
	print(str,x+1,y)
	print(str,x,y+1)

	print(str,x,y,c1)
end

function bspr(s,x,y,c)
	spr(s,x,y)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-->8
--field
function field()
	spc=16
	bpos=1
	map(32,0,4,1)
	for i=0,7 do
		spr(37,spc*i,7)
		spr(38,spc*i+8,7)
		spr(53,spc*i,15)
		spr(54,spc*i+8,15)
		spr(21+i,spc*i+5,11)
	end

	--level up symbol
	if(plyr.stat_points>0) spr(41,121,16)

	spr(39,1,116)
	spr(40,9,116)
	spr(55,1,124)
	spr(56,9,124)
	print("wave",23,116,12)
	print(wave,29,122,7)
	cp=plyr.castle_hp/plyr.castle_max_hp
	if (cp <= 0.5) then
		chp=8
	elseif (cp <= 0.25) then
		chp=9
	else
		chp=11
	end
	rectfill(17,125-8*cp,21,125,chp)
	rect(17,116,21,126,7)

	--rect(spc*(field_pos-1)+1,8,spc*(field_pos-1)+14,21,10)
	--sspr( sx, sy, sw, sh, dx, dy, [dw,] [dh,] [flip_x,] [flip_y] )
	sspr( 106, 16, 16, 16, spc*(field_pos-1)+2,7)


	bp="🅾️ "
	if(field_pos==1)t="temple"
	if(field_pos==2)t="weapon"
	if(field_pos==3)t="armour"
	if(field_pos==4)t="aclmst"
	if(field_pos==5)t="magic"
	if(field_pos==6)t="gaming"
	if(field_pos==7)t="field"
	if(field_pos==8)t="derek"
	if(gamestate!=2) bprint(bp..t,88,117,7,1)
	dbutton("s",88,117)

	--border of field yellow
	rect(3,24,124,113,9)
	--grey
	rect(2,23,125,114,5)

	for x=1,15 do
		for y=1,11 do
			if (fmap[x][y].type == "e") then
				spr(58,x*8-2,y*8+19)
			end
		end
	end
	pset(2,23,0)
	pset(2,114,0)
	pset(125,114,0)
	pset(125,23,0)
end

function field_active()
	pal(10,9)
	sspr(106,16,16,16,spc*(field_pos-1)+2,7)
	pal()
	rect(3,24,124,113,10)
	--rect(spc*(field_pos-1)+1,8,spc*(field_pos-1)+14,21,0)
	f=fmap[plyr.x][plyr.y]
	if (f.type=="e") then
		fx=#f.mobs/2-0.5
		for i=1,#f.mobs do
			p=i-1-fx
			rectfill(field_x+p*9-1,field_y-10,field_x+p*9+8,field_y-9+8,1)
			rect(field_x+p*9-1,field_y-10,field_x+p*9+8,field_y-9+8,0)
			spr(f.mobs[i].spr,field_x+p*9,field_y-9)
		end
	end

	rect(field_x,field_y,field_x+7,field_y+7,8)
	bprint("🅾️ attack",88,116,7,1) dbutton("s",88,116)
	bprint("❎ castle",88,122,7,1) dbutton("x",88,122)
end
-->8
--controls
function control_field()
	select=false
	if(btnp(⬆️)) fmenu=true
	if(btnp(⬅️) and field_pos>0) field_pos-=1 sfx(1)
	if(btnp(⬅️) and field_pos<1) field_pos=8 sfx(1)
	if(btnp(➡️) and field_pos<9) field_pos+=1 sfx(1)
	if(btnp(➡️) and field_pos==9) field_pos=1 sfx(1)
	if(btnp(🅾️)) then
		shop=field_pos
		gamestate=3
		field_x=60
		field_y=81
		sfx(3)
	end
	if(btnp(❎)) then
		wave_adv=true
	end
end

function control_field_active()
	if(btnp(⬆️) and field_y>25) field_y-=8 plyr.y-=1
	if(btnp(⬇️) and field_y<98) field_y+=8 plyr.y+=1
	if(btnp(⬅️) and field_x>11) field_x-=8 plyr.x-=1
	if(btnp(➡️) and field_x<116) field_x+=8 plyr.x+=1
	if(btnp(🅾️)) then
		shop=field_pos
		if(fmap[plyr.x][plyr.y].type=="e") gamestate=4
	end
	if(btnp(❎)) then
		gamestate=1
		plyr.x=8
		plyr.y=8
	end
end

function control_shop()
	if(shop==8) then
		if(btnp(⬆️)) then
			if (spos>1) then
				spos-=1
			end
		end
		if(btnp(⬇️)) then
			if (spos<6) then
				spos+=1
			end
		end
	else
		if(btnp(⬆️)) then
			if (list_pos>list_min) then
				list_pos-=1
			end
		end
		if(btnp(⬇️)) then
			if (list_pos+list_start-1<list_limit) then
				list_pos+=1
			end
		end
	end

	if(btnp(⬅️) and but_pos>1) but_pos-=1
	if(btnp(➡️) and but_pos<but_num) but_pos+=1
	if(btnp(🅾️)) then
		select=true
	else
		select=false
	end
end

function control_battle()
	if(fmenu) then
		if(btnp(🅾️)) then
			if(fpos==1) load()
		end
		if(btnp(❎)) then
			fmenu=false
			fpos=1
		end
		if(btnp(⬆️) and fpos>1) fpos-=1 sfx(0)
		if(btnp(⬇️) and fpos<#o) fpos+=1 sfx(0)
	elseif(blist) then
		if(btnp(⬆️)) then
				if (list_pos>list_min) then
					list_pos-=1
					sfx(2)
				end
		elseif(btnp(⬇️)) then
				if (list_pos+list_start-1<list_limit) then
					list_pos+=1
					sfx(2)
				end
		elseif(btnp(⬅️) and bpos > 1) then
			but_pos-=1
			sfx(1)
		elseif (btnp(➡️) and but_pos < 2) then
			but_pos+=1
			sfx(1)
		end
		if(btnp(❎) or (btnp(🅾️) and but_pos==1)) then
			blist=false
			but_pos=2
			list_limit=8
			list_max=8
			list_start=1
			list_pos=1
			list_min=1
		end
		if(btnp(🅾️) and but_pos==2) then
			lp=list_start+list_pos-1
			if(bltype=="potion" and #plyr.potions>0) then
				hpv=plyr.potions[lp].val
				d=plyr.potions[lp].desc
				hpc=plyr.curr_hp+hpv
				msg="potion heals derek for "..hpv
				log=true
				if(d=="potion of fiery breath") then
					r=ceil(rnd(#e))
					spell(plyr,e[r],"potion")
					log=false
				elseif(hpv=="full") then
					plyr.curr_hp=plyr.hp
				elseif(hpc <= plyr.hp) then
					plyr.curr_hp+=hpv
				elseif(plyr.curr_hp < plyr.hp) then
					plyr.curr_hp=plyr.hp
				else
					msg="potion has no effect"
				end
				del(plyr.potions,plyr.potions[lp])
				if(log) add_log(msg)
				enemy_attack()
			elseif(bltype=="magic" and #plyr.magic>0) then
				r=ceil(rnd(#e))
				use_magic=plyr.magic[lp].desc
				bmenu=false
				epos=1
			end
			blist=false
		end
	elseif(bmenu and blist==false) then
		if(btnp(⬆️)) then
			fmenu=true
		elseif(btnp(⬅️) and bpos > 1) then
			bpos-=1
		elseif (btnp(⬅️)) then
			bpos=4
		end
		if(btnp(➡️) and bpos < 4) then
			bpos+=1
		elseif (btnp(➡️)) then
			bpos=1
		end
		if(btnp(🅾️)) then
			if(bpos==2) then
				add_log(battle_run())
				enemy_attack()
				bmenu=true
			elseif(bpos==3 or bpos==4) then
				blist=true
				list_pos=1
				list_start=1
			else
				bmenu=false
				epos=1
			end
		end
		if(btnp(❎) and blist) blist=false but_pos=2
	else
		if(btnp(⬆️) and epos > 1) then
			epos-=1
		elseif (btnp(⬆️)) then
			epos=#e
		end
		if(btnp(⬇️) and epos < #e) then
			epos+=1
		elseif (btnp(⬇️)) then
			epos=1
		elseif(btnp(🅾️)) then
			if(bpos==1) then
				attack(plyr,e[epos])
				enemy_attack()
			end
			if(bpos==4) then
				spell(plyr,e[epos],"spell",use_magic)
				enemy_attack()
			end
			bmenu=true
		end
	end
	print(epos,0,10,10)
end

function control_textbox()
	if(btnp(🅾️)) gamestate=1
end

-->8
--derek
function derek_stats()
	title="stats"
	local sx2,sy2=62,62
	local cx2,cy2=123,62
	map(0,0)
	tx=centre_text(title)
	rectfill(tx-1,1,128-tx+1,6,6)
	print(title,tx+1,1,0)
	spr(28,4,12)
	print("derek",15,14,8)

	rect(4,24,sx2,sy2,0)
	print("lvl:",6,26,0)
	print(plyr.lvl,sx2-num_size(plyr.lvl),26,12)
	print("hp:",6,32,0)
	print(plyr.curr_hp.."/"..plyr.hp,sx2-(4*(#tostr(plyr.hp)+#tostr(plyr.curr_hp)+1)),32,12)
	print("gold:",6,38,0)
	print(plyr.gold,sx2-num_size(plyr.gold),38,12)
	print("xp to lvl:",6,44,0)
	nxp=lvl_up[plyr.lvl+1]-plyr.exp
	print(nxp,sx2-num_size(nxp),44,12)
	print("ac:",6,50,0)
	print(plyr.ac,sx2-num_size(plyr.ac),50,12)
	print("dmg:",6,56,0)
	print(plyr.dmg,sx2-num_size(plyr.dmg),56,12)

	rect(66,24,cx2,cy2,0)

	print("str:",68,26,0)
	print(plyr.str,cx2-num_size(plyr.str),26,8)
	print("int:",68,32,0)
	print(plyr.int,cx2-num_size(plyr.int),32,8)
	print("wis:",68,38,0)
	print(plyr.wis,cx2-num_size(plyr.wis),38,8)
	print("dex:",68,44,0)
	print(plyr.dex,cx2-num_size(plyr.dex),44,8)
	print("con:",68,50,0)
	print(plyr.con,cx2-num_size(plyr.con),50,8)
	print("cha:",68,56,0)
	print(plyr.cha,cx2-num_size(plyr.cha),56,8)

	sy=26+6*(spos-1)
	if(plyr.stat_points>0) spr(41,cx2-14,sy)

	if (but_pos==2 and select and plyr.stat_points>0) then
		if(spos==1) plyr.str+=1
		if(spos==2) plyr.int+=1
		if(spos==3) plyr.wis+=1
		if(spos==4) plyr.dex+=1
		if(spos==5) plyr.con+=1
		if(spos==6) plyr.cha+=1
		plyr.stat_points-=1
	end
	print("stat points:",68,14,0)
	print(plyr.stat_points,cx2-num_size(plyr.stat_points),14,0)
	print("weapon: "..plyr.weapon,6,70,0)
	print("armour: "..plyr.armour,6,80,0)

	if (but_pos==1 and select) then
		gamestate=1
		select=false
		but_pos=2
		list_pos=1
		list_start=1
	elseif (but_pos==1) then
		b=true
	else
		b=false
	end

	button(63,110,"leave",b)
	button(101,110,"buy",not b)
end

-->8
--waves
function wave_init()
	for x=1,15 do
		fmap[x]={}
		for y=1,11 do
			fmap[x][y]={type="o",mobs={}}
			if(fget(mget(x+31,y+2))==1) fmap[x][y].type="x"
		end
	end
	for y=1,11 do
		r=ceil(rnd(15))
		if (fmap[r][y].type!="x") then
			fmap[r][y].type="e"
			gbl={creature="goblin",spr=192,{}}
			orc={creature="orc",spr=194,{}}
			hob={creature="hobgoblin",spr=224,{}}
			cap={creature="guard captain",spr=228,{}}
			ogr={creature="ogre",spr=226,{}}
			kgt={creature="knight",spr=196,{}}
			hgiant={creature="hill giant",spr=200,{}}
			if(wave==1) rn=rnd({gbl,gbl,gbl,hob})
			if(wave==2) rn=rnd({gbl,gbl,hob,orc,{gbl,gbl}})
			if(wave==3) rn=rnd({orc,hob,{hob,gbl},hob})
			if(wave==4) rn=rnd({cap,{orc,hob},cap,hob})
			if(wave==5) rn=rnd({ogr,{cap,cap},ogr,{ogr,cap}})
			if(wave==6) rn=rnd({ogr,{cap,cap},ogr,{ogr,cap}})
			if(wave==7) rn=rnd({ogr,ogr,{ogr,cap}})
			if(wave==8) rn=rnd({ogr})
			if(wave==9) rn=rnd({ogr})
			if(wave==10) rn=gbl
			if(#rn==1) rn={rn}
			fmap[r][y].mobs=rn
		end
		save_fmap=fmap
	end
	wave_reset=false
end

function wave_advance()
	nmap=deepcopy(fmap)
	for x=15,1,-1 do
		for y=11,1,-1 do
			if (fmap[x][y].type=="e") then
				if (x<6 and y<5 and nmap[x+1][y+1].type=="o") then
					nmap[x][y].type="o"
					nmap[x+1][y+1].type="e"
					nmap[x+1][y+1].mobs=fmap[x][y].mobs
				elseif (x<6 and nmap[x+1][y].type=="o") then
					nmap[x][y].type="o"
					nmap[x+1][y].type="e"
					nmap[x+1][y].mobs=fmap[x][y].mobs
				elseif (y<5 and nmap[x][y+1].type=="o") then
					nmap[x][y].type="o"
					nmap[x][y+1].type="e"
					nmap[x][y+1].mobs=fmap[x][y].mobs
				end
			end
		end
	end

	fmap=deepcopy(nmap)

	for x=1,15 do
		for y=1,11 do
			if(fmap[x][y].type=="e") then
				if(x>10 and y>7 and nmap[x-1][y-1].type=="o") then
					nmap[x][y].type="o"
					nmap[x-1][y-1].type="e"
					nmap[x-1][y-1].mobs=fmap[x][y].mobs
				elseif(x>10 and nmap[x-1][y].type=="o") then
					nmap[x][y].type="o"
					nmap[x-1][y].type="e"
					nmap[x-1][y].mobs=fmap[x][y].mobs
				elseif(y>7 and nmap[x][y-1].type=="o") then
					nmap[x][y].type="o"
					nmap[x][y-1].type="e"
					nmap[x][y-1].mobs=fmap[x][y].mobs
				elseif(y>7 and nmap[x-1][y].type=="o") then
						nmap[x][y].type="o"
						nmap[x-1][y].type="e"
						nmap[x-1][y].mobs=fmap[x][y].mobs
				end
			end
		end
	end

	fmap=deepcopy(nmap)
	wave_adv=false
end

function wave_attack()
	for x=7,10 do
		for y=5,7 do
			if(fmap[x][y].type=="e")then
				for e=1,#fmap[x][y].mobs do
					if(plyr.castle_hp-wave>=0) then
						plyr.castle_hp-=wave
					else
						plyr.castle_hp=0
						plyr.dead=true
					end
				end
			end
		end
	end
end

function wave_clear()
	wc=0
	for x=1,15 do
		for y=1,11 do
			if (fmap[x][y].type=="e") then
				wc+=1
				break
			end
		end
	end
	if (wc==0) then
		gamestate=6
		wave+=1
		if(wave>10) plyr.win=true
	end
end
-->8
--battle
function battle_screen(enemy)
	--menu
	mx=61
	my=7
--	spc=28
	spc=17
	dead=0

	for m=0,3 do
		spr(37,mx+spc*m,my+0)
		spr(38,mx+spc*m+8,my+0)
		spr(53,mx+spc*m,my+8)
		spr(54,mx+spc*m+8,my+8)
		spr(5+m,mx+5+spc*m,my+4)
	end

	--derek
	rectfill(63,24,126,37,5)
	line(64,25,73,25,7)
	line(64,25,64,34,7)
	rectfill(65,26,74,35,0)
	spr(28,66,27)
	print("derek",77,25,7)

	if (plyr.curr_hp/plyr.hp <= 0.25) then
		ehealth=8
	elseif (plyr.curr_hp/plyr.hp <= 0.5) then
		ehealth=9
	else
		ehealth=11
	end
	rectfill(77,31,77+48*(plyr.curr_hp/plyr.hp),36,ehealth)
	rect(77,31,125,36,0)

	--highlight selection
	if(bmenu) then
		--rect(mx+spc*(bpos-1)+1,my+1,mx+spc*(bpos-1)+14,my+14,10)
		sspr( 106, 16, 16, 16, mx+spc*(bpos-1)+2,my)
	else
		spc=epos*17
		rect(62,23+spc,127,38+spc,10)
	end

	for i=1,#enemy do
		spc=i*17
		rectfill(63,24+spc,126,37+spc,5)
		line(64,25+spc,73,25+spc,7)
		line(64,25+spc,64,34+spc,7)
		rectfill(65,26+spc,74,35+spc,0)
		--enemy avatar
		spr(enemy[i].stspr,66,27+spc)
		--dead
		if (enemy[i].curr_hp<=0) spr(49,66,27+spc)
		print(enemy[i].type,77,25+spc,7)
		if (enemy[i].curr_hp/enemy[i].hp <= 0.25) then
			ehealth=8
		elseif (enemy[i].curr_hp/enemy[i].hp <= 0.5) then
			ehealth=9
		else
			ehealth=11
		end
		rectfill(77,31+spc,77+48*(enemy[i].curr_hp/enemy[i].hp),36+spc,ehealth)
		rect(77,31+spc,125,36+spc,0)
		if (enemy[i].curr_hp<=0) dead+=1
	end

	--log
	--ty = 98
	rectfill(0,102,127,127,0)
	rect(1,95,126,126,7)
	print(log1,4,98,7)
	print(log2,4,105,6)
	print(log3,4,112,5)
	print(log4,4,119,5)

	--battle field
	bx=0
	by=9
	bc=bx+flr(58/2)
	bp=(bx+58)/(#enemy+1)

	map(18,3,bx+2,by,7,10)
	rect(bx+1,by,bx+58,92,7)
	spr(11,bc,74)
	for i=1,#enemy do
		if(enemy[i].curr_hp>0) then
			animate(enemy[i])
			spr(enemy[i].spr,(i)*bp,by+30)
			if(enemy[i].size=="l") spr(enemy[i].spr2,(i)*bp,by+22)
		end
	end

	if(plyr.curr_hp<=0) plyr.dead=true plyr.x=8 plyr.y=8
	--reset battle after victory
	if(dead==#enemy and gamestate==4) then
		gamestate=5
		battle_init=true
		fmap[plyr.x][plyr.y].type="o"
		field_pos=1
		plyr.x=8
		plyr.y=8
		xp=0
		gold=0
		for i=1,#enemy do
			plyr.exp+=enemy[i].exp
			plyr.gold+=enemy[i].gold
			xp+=ceil(enemy[i].exp*(1+bonus(plyr.wis)/10))
			gold+=enemy[i].gold
		end
		tlog="enemies drop "..tostr(gold).." gp and "..tostr(xp).." experience. "
		level(plyr.exp)
		wave_adv=true
	end
end

--[[function battle_attack()
	if (hit(e[epos].ac,plyr.dex)) then
		d=dmg(plyr.d,bonus(plyr.str))
		if (e[epos].curr_hp-d >= 0) then
			e[epos].curr_hp-=d
		else
			e[epos].curr_hp=0
		end
		log="derek hit "..e[epos].type.." for "..tostr(d).." dmg"
	else
		log="derek missed "..e[epos].type
	end
	return log
end]]--

function battle_list(items,type)
	pad=12
	local b1,b2=false,false
	bltype=type
	rectfill(13,13,116,116,1)
	rectfill(12,12,115,115,7)

	--scroll bar
	rectfill(102,28,108,82,6)

	--scroll icon
	scroll_bar(102,28,58)


	list_move(list_pos,11,items)

	print("use which "..type.."?",17,17,0)
	idx=1
	if(#items>0) then
		for i=list_start,list_limit do
			if (idx==list_pos) then
				rectfill(17,34+6*(idx-1),101,28+6*(idx-1),12)
			end
			if(#items[i]>19) then
				txt=sub(items[i].desc,1,19).."…"
			else
				txt=items[i].desc
			end
			print(txt,19,29+6*(idx-1),0)
			if (list_pos<=list_limit) then
				idx+=1
			end
		end
	end

	if(but_pos==1) then
		b1=true
		b2=false
	else
		b1=false
		b2=true
	end
	button(115-55,105,"close",b1)
	button(115-25,105,"ok",b2)

	--textbox
	rect(17,27,101,95,0)
	rect(101,27,109,95,0)
	rect(101,83,109,89,0)
end

function attack(atk,def)
	if (hit(def.ac,atk.dex)) then
		d=dmg(atk.d,bonus(atk.str))
		if (def.curr_hp-d >= 0) then
			def.curr_hp-=d
		else
			def.curr_hp=0
		end
		add_log(atk.type.." hit "..def.type.." for "..tostr(d).." dmg")
	else
		add_log(atk.type.." missed "..def.type)
	end
	return d
end

function enemy_attack()
	for i=1,#e do
		attack(e[i],plyr)
	end
end

function spell(atk,def,style,spell)
	if (hit(def.ac,atk.dex)) then
		if(style=="spell") then
			d=bonus(atk.int)
			if(spell=="fire bolt") then
				if(lvl>=17) then
					d+=droll(4,10)
				elseif(lvl >= 11) then
					d+=droll(3,10)
				elseif(lvl >= 5) then
					d+=droll(2,10)
				else
					d+=droll(1,10)
				end
			end
			if(spell=="lightning") d+=droll(8,6)
			if(spell=="disintegrate") d+=droll(10,6)+40
		else
			d=dmg(atk.d,0)
		end
		if (def.curr_hp-d >= 0) then
			def.curr_hp-=d
		else
			def.curr_hp=0
		end
		add_log(spell.." hit "..def.type.." for "..tostr(d).." dmg")
	else
		add_log(spell.." missed "..def.type)
	end

	return d
end

function battle_run()
	if(rnd(20) > 10) then
		tlog="derek runs away"
		textbox(tlog,28)
		gamestate=5
		battle_init=true
		field_pos=1
		plyr.x=8
		plyr.y=8
	else
		log="derek tried to run"
	end

	return log
end

function hit(ac,bns)
	hit_result=false
	dice=ceil(rnd(20))

	if (dice+bonus(bns) > ac) hit_result=true

	return hit_result
end

function droll(dice,sides)
	result=0
	for d=1,dice do
		result+=ceil(rnd(sides))
	end

	return result
end

function dmg(d,bonus)
	return ceil(rnd(d))+bonus
end

function initiative(bonus)
	result=droll(1,20)+bonus
	return result
end

function sortByInit(a)
   for i=1,#a do
       local j = i
       while j > 1 and a[j-1].init > a[j].init do
           a[j],a[j-1] = a[j-1],a[j]
           j = j - 1
       end
   end
end

function bonus(stat)
	b=0
	comp=1
	for i=-5,10 do
		if(stat<=comp) then
			b=i
			break
		end
		comp+=2
	end
	if(stat>comp) b=10
	return b
end

function level(xp)
	lvl = plyr.lvl

	for i=1,20 do
		if(lvl<i and xp>=lvl_up[i]) then
			lvl=i
			xp-=lvl_up[i]
		end
	end

	if(lvl>plyr.lvl) then
		tlog = tlog.."derek leveled up to "..tostr(lvl).."!"
		plyr.stat_points+=1
		plyr.hp+=droll(1,6)+bonus(plyr.con)
	end
	plyr.lvl = lvl
end

function spawn_enemy(type)
	tbl={}
	--[[if (type=="goblin") then
		tbl={
			spr=192,
			type=type,
			d=4,--1d6
			cr=0.125,ac=12,hp=5,str=7,dex=15,con=9,int=8,wis=7,cha=8,curr_hp=5,
			exp=3,
			gold=5,
			init=0
			}
	end]]--
	if (type=="goblin") then
		tbl={
			stspr=192,spr=208,
			offset=0,spd=0,
			type=type,
			d=4,--1d6
			cr=0.25,ac=12,hp=7,str=8,dex=14,con=10,int=10,wis=8,cha=8,curr_hp=7,
			exp=6,
			gold=10,
			init=0,
			size="s"
			}
	end
	if (type=="hobgoblin") then
		tbl={
			stspr=224,spr=240,
			offset=0,spd=0,
			type=type,
			d=6,--1d10+1
			cr=0.5,ac=18,hp=11,str=13,dex=12,con=12,int=10,wis=10,cha=9,curr_hp=11,
			exp=10,
			gold=20,
			init=0,
			size="s"
			}
	end
	if (type=="orc") then
		tbl={
			stspr=194,spr=210,
			offset=0,spd=0,
			type=type,
			d=6,--1d12
			cr=0.5,ac=13,hp=15,str=16,dex=12,con=16,int=7,wis=11,cha=10,curr_hp=15,
			exp=10,
			gold=20,
			init=0,
			size="s"
			}
	end
	if (type=="knight") then
		tbl={
			stspr=196,spr=212,
			offset=0,spd=0,
			type=type,
			d=6,--2d6
			cr=3,ac=18,hp=52,str=16,dex=11,con=14,int=11,wis=11,cha=15,curr_hp=52,
			exp=70,
			gold=100,
			init=0,
			size="s"
			}
	end
	if (type=="ogre") then
		tbl={
			stspr=226,spr=242,
			offset=0,spd=0,
			type=type,
			d=16,--2d8+4
			cr=2,ac=11,hp=59,str=19,dex=8,con=16,int=5,wis=7,cha=7,curr_hp=59,
			exp=45,
			gold=90,
			init=0,
			size="s"
			}
	end
	if (type=="guard captain") then
		tbl={
			stspr=228,spr=244,
			offset=0,spd=0,
			type=type,
			d=20,--2d10+2 two handed
			cr=2,ac=15,hp=65,str=15,dex=16,con=14,int=14,wis=11,cha=14,curr_hp=65,
			exp=20,
			gold=40,
			init=0,
			size="s"
			}
	end
	if (type=="hill giant") then
		tbl={
			stspr=200,spr=216,spr2=200,
			offset=0,spd=0,
			type=type,
			d=48,--2x 3d8+5
			cr=5,ac=13,hp=105,str=21,dex=8,con=19,int=5,wis=9,cha=6,curr_hp=105,
			exp=180,
			gold=200,
			init=0,
			size="l"
			}
	end
	if (type=="minotaur") then
		tbl={
			stspr=202,spr=218,spr2=202,
			offset=0,spd=0,
			type=type,
			d=28,--2d12+4
			cr=3,ac=14,hp=76,str=18,dex=11,con=16,int=6,wis=16,cha=9,curr_hp=76,
			exp=70,
			gold=160,
			init=0,
			size="l"
			}
	end
	if (type=="stone giant") then
		tbl={
			stspr=204,spr=220,spr2=204,
			offset=0,spd=0,
			type=type,
			d=48,--2x 3d8+6
			cr=7,ac=17,hp=126,str=23,dex=15,con=20,int=10,wis=12,cha=9,curr_hp=126,
			exp=290,
			gold=280,
			init=0,
			size="l"
			}
	end
	tbl.spd=10+ceil(rnd(3))
	tbl.init=initiative(bonus(tbl.dex))
	return tbl
end

function title_screen()
	rectfill(0,8,127,127,13)
	rectfill(26,46,102,60,1)
	rectfill(25,45,101,59,5)
	rect(26,46,100,58,10)
	bprint("siege of darkwood",30,50,10,0)
	print("❎/🅾️ to start",37,68,7)
	bprint("❎",37,68,0,0)
	dbutton("x",37,68)
	bprint("🅾️",49,68,0,0)
	dbutton("s",49,68)
	o={"new","load"}
	picobar(o)
end

function picobar(opts)
	shadow=1
	rectfill(0,0,127,6,6)
	line(0,7,127,7,shadow)
	spr(48,1,1)
	if(fmenu) then
		rectfill(8,8,54,9+7*#opts,shadow)
		--grey box
		rectfill(7,7,53,7+7*#opts,6)
		--box edge
		rect(7,7,53,8+7*#opts,5)
		--file background
		rectfill(7,0,25,7,5)
		--highlight option
		rectfill(8,8+7*(fpos-1),52,14+7*(fpos-1),12)
		print("file",9,1,7)
		for i=1,#opts do
			print(opts[i],9,9+7*(i-1),0)
		end
	else
		print("file",9,1,0)
	end
end

function picobar_act(act)
	if(act=="save") save() fmenu=false
	if(act=="load") load() fmenu=false
	if(act=="new")then
		gamestate=1
		fmenu=false
	end
	if(act=="quit") reset()
end

function reset()
	plyr=deepcopy(reset_plyr)
	fmap={}
	wave=1
	wave_init()
	field_pos=1
	fmenu=false
	gamestate=0
end

function save()
	save_plyr=deepcopy(plyr)
	save_fmap=deepcopy(fmap)
	save_wave=wave
	rectfill(0,0,127,127,11)
end

function load()
	--plyr=save_plyr
	plyr=deepcopy(save_plyr)
	fmap=deepcopy(save_fmap)
	nmap=deepcopy(save_fmap)
	wave=save_wave
	if(gamestate>0) then
		plyr.x=8
		plyr.y=8
	end
	gamestate=1
	bpos=1
end

function gameover()
	textbox("sorry. you have been killed. the city will now surely fall into the hands of torque. please try again.",10)
end

function win()
	textbox("congratulations. you have valiantly fought off torques horde. darkwood will be forever greatful.",42)
end
__gfx__
000000006666666666666666666666669994999400000007000000000007700000000000090000000077700000000000fff00777000000000000000000000000
000000006555555555555555555555569994999400000070000cc0000077770000a8a000077770000777770000000000fff07007000000000000000000000000
007007006666666666666666666666664444444400000700000c000000077000009a9000077777707057057000aa0006fff07007000000000000000000000000
0007700065555555555555555555555699499949000070000ccccc00000ee00000090000077777707567567000af0060fff07007000000000000000000000000
000770006666666666666666666666669949994900070000000c000000eeee000009000007777770077577000adc0600fff07007000000000000000000000000
00700700655555555555555555555556444444440a700000000cc0000eeeeee00009000009777770077d77000cccd000ff007770000000000000000000000000
000000006666666666666666666666669499949904a0000000c00c0000eeee0000090000090007700076700000cc0000ff070000000000000000000000000000
0000000000000000000000000000000094999499400000000c00c000000ee0000000000009000000006760000c0c0000ff000000000000000000000000000000
07777b0077777777555555507777777744444444044444000444440004444400044444000444440004444400c0000001009aaa00011111000000000000000000
77000bb077777777555555507777777799499949444a444044444440446664404477744044a8a440488844400c00001009a6ff00111111100000000000000000
7b0b0b307777777755777550777777779949994944aaa440444446404460044044474440449a94404878444000c0010009fddf00111111100000000000000000
bb00033077777777555555507777777744444444444a44404494644044666440447e7440444944404888e740000c1000996fff00111111100000000000000000
0333330077777777557775507777777794999499444a4440444944404466644044eee44044494440444eee400001c000aaf6ff00111111100000000000000000
0000000077777777555555507777777794999499044a4400041494000666660004eee400044944000447e7000a100c9019aff000011111000000000000000000
00000000777777775555555077777777444444440444440004444400044444000444440004494400044444000da00920c1a55c00011111000000000000000000
0000000077777777000000000000000049994999004440000044400000444000004440000044400000444000d0000002c1aa5cc0001110000000000000000000
0999980070707070000000000000000049994999000000000000000000000007500000000555000000202000ee0eeeee00000eee000000000000000000000000
99080880070707070000000000000000444444440000000000000000007500755500750055b5500002828200e000eeeee000eeee000000000000000000000000
9880882070707070000000000000000099949994000000000000000007555007500755505bbb50002888882000000eeeee0eeeee0000aaaaaaaaa00000000000
88080220070707070000000000000000999499940000555555555000007500755500750055b5500028888820eeeeeeeeeeeeeeee000a000000000a0000000000
0222220070707070000000000000000044444444000555555555550000750075550075000555000002888200eeeeeeeeeeeeeeee00a00000000000a000000000
0000000007070707000000000000000099499949001555555555550007555555555555500000000000282000eeeeeeeeeeeeeeee00a00000000000a000000000
0000000070707070000000055555555599499949001555555555550007555555555555500000000000020000eeeeeeeeeeeeeeee00a00000000000a000000000
0000000007070707000000500000000044444444001555555555550007555555555555500000000000000000eeeeeeeeeeeeeeee00a00000000000a000000000
0080000050505050000000500000005000000000001555555555550007555555555555500000000001100000011000000000000000a00000000000a000000000
097f000005050505000000500000000500000000001555555555550007555550075555500000000019910000188100000000000000a00000000000a000000000
a777e00050505050000000500000000000000000001555555555550007555550075555500000000019910000188100000000000000a00000000000a000000000
0b7d000005050505000000500000000000000000001555555555550000000000000000000000000001100000011000000000000000a00000000000a000000000
00c00000505050500000005000000000000000000001555555555000000000000000000000000000000000000000000000000000000a000000000a0000000000
000000000505050500000050000000000000000000001111111100000000000000000000000000000000000000000000000000000000aaaaaaaaa00000000000
00000000505050500000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000050505050000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333339999999933333333333333333333333300000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454533555333333333333335553333333333cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454535000533333333333350005300000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454535000555555555555550005333333333cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454535000500000000000050005300000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454533555033333333333335550333333333cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454533350333333333333333503300000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333331111111133350333333333333333503333333333cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
66666666444444443335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc444444443335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc444444443335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc444444443335033333333333333350333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc444444443335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc444444443335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc444444443335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666444444443335033333333333333350333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc63333333333333335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc6333333333333335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccc633333333333355533333333333333555330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc63333333333500053333333333335000530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccc6333333333500055555555555555000530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ccccccc633333333500050000000000005000530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
36ccccccc63333333355503344444444333555030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
336ccccccc6333333330033344444444333300330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3336ccccccc666666666666916666666666633330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33336cccccccccccccccccc91ccccccccccc63330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333336ccccccccccccccccc91cccccccccccc6330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333336cccccccccccccccc91ccccccccccccc630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333336ccccccccccccccc91cccccccccccccc60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333336cccccccccccccc91ccccccc6ccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333336ccccccccccccc91ccccccc36cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333336666666666666916666666336ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99949994999499949994999499949994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99949994999499949994999499949994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99499949994999499949994999499949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99499949994999499949994999499949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94999499949994999499949994999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94999499949994999499949994999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99499949994999499949994999499949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99499949994999499949994999499949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94999499949994999499949994999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94999499949994999499949994999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
49994999499949994999499949994999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
49994999499949994999499949994999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99949994999499949994999499949994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99949994999499949994999499949994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99499949994999499949994999499949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99499949994999499949994999499949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99949994999499949994999499949994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99949994999499949994999499949994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99499949994999499949994999499949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99499949994999499949994999499949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94999499949994999499949994999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94999499949994999499949994999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d06ff000000000000666600000000070001100000011600000000000000000000999900000999900070007000000000000766600007666000000070000000000
5f9765000000000000555600000660670221160000225005000000000000000009ff9900091f1f90700000700000000000666600006666000000600007000000
0f9ff5f00000000000663360006aa040015f500000ff50050000000000000000091f1f9009f4f990708887000000000005d6d660056d6d600000060220600000
00aaf3ff000f000006633336006330400faf1011001d1005000000000000000009f4f99004494490885858800000000006666660066666600000002222000000
4f3f334f003130000abb635605555530055521110121219900000000000000009449449999999999088888000000000000666700007666000000008211000000
ff33333f0f033f00b3bb6556035550400d5522221015101f0000000000000000f999999ff999999f008288000000000000766700007666000000088811000000
f0333330000310003b3635600010104005522112000100090000000000000000f99999fff99999ff008288880000000006676665066667650088228882200000
000333330050050005563600005050001122d111002010000000000000000000f99999fff99999ff888888880000000066666666666666660088208880220000
0000000000000000000000700000000000110605001106000000000000000000f99999fff44499ff666666560000000066666666666666660002209890028000
00000000000000000066006700660070022f5005022f50050000000000000000f44499fff4544444566666560000000066666666666666660000099999088000
000000000000000000a3604000a3606700ff500500ff500500000000000000000454444404545444671117660000000055666655556666550000099999900000
000f00000000f0000033604000336040001d1099001d100500000000000000000454544409599990661116660000000000766670007666700000008998800000
00313f0000331f0003555530035550400121211f012121990000000000000000095999900999999066c1c6660000000000765660007656600000088898000000
0f0330000f0330000555504005555530101510091015101f0000000000000000099999900999999061ccc1660000000000765660007656605555888558855555
00031000000310000010104000101040000100000001000900000000000000000ff00ff00ff00ff061ccc6160000000007656660076566605555885558885555
0050050000500500005050000050504000201000002010000000000000000000fff0fff0fff0fff061ccc6160000000006656670066566705555555555885555
00099000000000000051160000110000000444000000000000000000000000000000000000000000116c6d160000000000000000000000000000000990000000
909999090009009005e111660e621000004f4f000000000000000000000000000000000000000000666661160000000000000000000000000000009aaa000000
991f919900009900ee1722200ee240000411f1000004406000000000000000000000000000000000666666660000000000000000000000000000ffaaaa000000
099ff99000099990000ed2000004900000ffff00001ff0600000000000000000000000000000000066666666000000000000000000000000000fffaaaf000000
0095590000559900606ed001009449000195591101d120600000000000000000000000000000000066666666000000000000000000000000000fff6a6ff00000
5299992202225220eee110010f01f100111ff111000ddd900000000000000000000000000000000066666666000000000000000000000000000ff66666f00000
252992250052250000005100001010001111211100055000000000000000000000000000000000005555555500000000000000000000000040ff666666600000
2222252200900900000001000010010011112111005050000000000000000000000000000000000055555555000000000000000000000000044ff66666660000
0000000000000000001100000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000004ff66666660000
00900900000000000e6210000066100000000060000000600000000000000000000000000000000000000000000000000000000000000000000fff6666600000
000990000090090007e2400000ee4000000440600004406000000000000000000000000000000000000000000000000000000000000000000001f446611ff000
00999900000990000e04990000049000010ff060001ff06000000000000000000000000000000000000000000000000000000000000000000001144411fff000
02599220029999200f9440f00094490000112d9001012d9000000000000000000000000000000000000000000000000000000000000000000000f044410f0000
0022520000299200000141000f011f0000ddd00000ddd00000000000000000000000000000000000000000000000000000000000000000005555ff54445ff555
00522500005225000010100000101000000550000005500000000000000000000000000000000000000000000000000000000000000000005555dd5544fffd55
00900900009009000010010000101000005050000050500000000000000000000000000000000000000000000000000000000000000000005555fff5555fddf5
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010001000000000000000000010001010100000000000000000000000100010101000000000000000000000000010101010000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0102020202020202020202020202020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100464646464646464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100464646464646464600000000000000404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100464646464646464600000000000000404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100454545454545454500000000000000404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100555555555555555500000000000000404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000404040404040424344404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000404040404040525354404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000746140404040626364404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000706061404040405140404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000407071505050724173505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000404040404040405140404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000404040404040405140404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
