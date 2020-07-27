pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	plyr={
		x=8,
		y=8,
		lvl=1,
		hp=10,
		curr_hp=10,
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
	reset_plyr=plyr
	save_plyr=plyr
	save_fmap={}
	save_wave=1

	fmap={}
	wave=1
	wave_reset=true
	wave_adv=false

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
	if(plyr.dead and btnp(🅾️)) then
		_init()
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
	--sspr(104,8,8,8,15,39,34,34)
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
			print(list[l].gold,126-#tostr(list[l].gold)*4,24,8)
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
	--spr(18,117,55+36*((p-2)/#list))
	scroll_bar(117,51,40)
	--scroll arrows
	--up
	line(118,92,120,90,0)
	line(122,92,120,90,0)
	line(118,92,122,92,0)
	pset(120,91,0)

	--down
	line(118,96,120,98,0)
	line(122,96,120,98,0)
	line(118,96,122,96,0)
	pset(120,97,0)

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
		if (select and plyr.gold-list[p].gold>=0 and plyr.dmg != v) then
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
			plyr.gold-=list[p].gold
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
	--if(list_pos+list_start==list_limit) scy=y+h-10
	spr(18,x,scy)
end

-->8
--helper
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
end

function field_active()
	rect(3,24,124,113,10)
	--rect(spc*(field_pos-1)+1,8,spc*(field_pos-1)+14,21,0)
	--sspr( 106, 16, 16, 16, spc*(field_pos-1)+1,8)
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
	if(btnp(⬅️) and field_pos>0) field_pos-=1
	if(btnp(⬅️) and field_pos<1) field_pos=8
	if(btnp(➡️) and field_pos<9) field_pos+=1
	if(btnp(➡️) and field_pos==9) field_pos=1
	if(btnp(🅾️)) then
		shop=field_pos
		gamestate=3
		field_x=60
		field_y=81
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
		if(btnp(⬆️) and fpos>1) fpos-=1
		if(btnp(⬇️) and fpos<#o) fpos+=1
	elseif(blist) then
		if(btnp(⬆️)) then
				if (list_pos>list_min) then
					list_pos-=1
				end
		elseif(btnp(⬇️)) then
				if (list_pos+list_start-1<list_limit) then
					list_pos+=1
				end
		elseif(btnp(⬅️) and bpos > 1) then
			but_pos-=1
		elseif (btnp(➡️) and but_pos < 2) then
			but_pos+=1
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
			elseif(bltype=="magic") then
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
			bpos=5
		end
		if(btnp(➡️) and bpos < 5) then
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
	print("exp:",6,44,0)
	print(plyr.exp,sx2-num_size(plyr.exp),44,12)
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
			orc={creature="orc",spr=193,{}}
			hob={creature="hobgoblin",spr=195,{}}
			cap={creature="guard captain",spr=197,{}}
			ogr={creature="ogre",spr=196,{}}
			kgt={creature="knight",spr=194,{}}
			if(wave==1) rn=rnd({gbl,gbl,gbl,orc})
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
	nmap=fmap
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

	fmap=nmap

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

	fmap=nmap
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
	spc=13
	dead=0

	for m=0,4 do
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
		spr(enemy[i].spr,66,27+spc)
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
		if(enemy[i].curr_hp>0) spr(enemy[i].spr+16,(i)*bp,by+30)
	end

	if(plyr.curr_hp<=0) plyr.dead=true
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
			xp+=enemy[i].exp
			gold+=enemy[i].gold
		end
		tlog="enemies drop "..tostr(gold).." gp and "..tostr(xp).." experience. "
		level(plyr.exp)
	end
end

function battle_attack()
	if (hit(e[epos].ac,plyr.str,0)) then
		d=dmg(plyr.d,0)
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
end

function battle_list(items,type)
	pad=12
	local b1,b2=false,false
	bltype=type
	rectfill(13,13,116,116,1)
	rectfill(12,12,115,115,7)

	--scroll bar
	rectfill(102,28,108,82,6)

	--scroll icon
	scroll_bar(102,28,55)
	--scroll arrows
	--up
	line(103,87,105,85,0)
	line(107,87,105,85,0)
	line(103,87,107,87,0)
	pset(105,86,0)

	--down
	line(103,91,105,93,0)
	line(107,91,105,93,0)
	line(103,91,107,91,0)
	pset(105,92,0)


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
	if (hit(def.ac,atk.str,0)) then
		d=dmg(atk.d,0)
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
	if (hit(def.ac,atk.str,0)) then
		if(style=="spell") then
			if(spell=="fire bolt") then
				if(lvl>=17) then
					d=droll(4,10)
				elseif(lvl >= 11) then
					d=droll(3,10)
				elseif(lvl >= 5) then
					d=droll(2,10)
				else
					d=droll(1,10)
				end
			end
			if(spell=="lightning") d=droll(8,6)
			if(spell=="disintegrate") d=droll(10,6)+40
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

function hit(ac,str,bns)
	hit_result=false
	dice=ceil(rnd(20))

	if (dice+bns+bonus(str) > ac) hit_result=true

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
		if(stat<=comp) b=i
		comp+=2
	end
	if(stat>comp) b=10
	return b
end

function level(xp)
	lvl = plyr.lvl
	--max number in pico-8 is 32768
	--[[if(xp>=30 and lvl<2) lvl=2 xp-=30
	if(xp>=60 and lvl<3) lvl=3 xp-=60
	if(xp>=180 and lvl<4) lvl=4 xp-=180
	if(xp>=380 and lvl<5) lvl=5 xp-=380
	if(xp>=750 and lvl<6) lvl=6 xp-=750
	if(xp>=900 and lvl<7) lvl=7 xp-=900
	if(xp>=1100 and lvl<8) lvl=8 xp-=1100
	if(xp>=1400 and lvl<9) lvl=9 xp-=1400
	if(xp>=1600 and lvl<10) lvl=10 xp-=1600
	if(xp>=2100 and lvl<11) lvl=11 xp-=2100
	if(xp>=1500 and lvl<12) lvl=12 xp-=1500
	if(xp>=2000 and lvl<13) lvl=13 xp-=2000
	if(xp>=2000 and lvl<14) lvl=14 xp-=2000
	if(xp>=2500 and lvl<15) lvl=15 xp-=2500
	if(xp>=3000 and lvl<16) lvl=16 xp-=3000
	if(xp>=3000 and lvl<17) lvl=17 xp-=3000
	if(xp>=4000 and lvl<18) lvl=18 xp-=4000
	if(xp>=4000 and lvl<19) lvl=19 xp-=4000
	if(xp>=5000 and lvl<20) lvl=20 xp-=5000]]--
	lvl_up={0,30,60,180,380,750,900,1100,1400,1600,2100,1500,2000,2000,2500,3000,3000,4000,4000,5000}
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
	if (type=="kobold") then
		hp=droll(2,6)-2
		tbl={hp=hp,
			curr_hp=hp,
			str=7,
			dex=15,
			con=9,
			int=8,
			wis=7,
			cha=8,
			weapon="dagger",
			d=4,--1d6
			--ac=15,
			ac=12,
			type=type,
			spr=192,
			exp=3,
			gold=5,
			init=0,
			cr=0
			}
	end
	if (type=="goblin") then
		hp=droll(2,6)
		tbl={hp=hp,
			curr_hp=hp,
			str=8,
			dex=14,
			con=10,
			int=10,
			wis=8,
			cha=8,
			weapon="scimitar",
			d=6,--1d6
			armour="leather",
			--ac=15,
			ac=10,
			type=type,
			spr=192,
			exp=5,
			gold=10,
			init=0,
			cr=0
			}
	end
	if (type=="orc") then
		hp=droll(2,8)+6
		tbl={hp=hp,
			curr_hp=hp,
			str=16,
			dex=12,
			con=16,
			int=7,
			wis=11,
			cha=10,
			weapon="greataxe",
			d=12,--1d12
			armour="hide",
			ac=10,
			type=type,
			spr=193,
			exp=10,
			gold=20,
			init=0,
			cr=0
			}
	end
	if (type=="knight") then
		hp=droll(8,8)+16
		tbl={hp=hp,
			curr_hp=hp,
			str=16,
			dex=11,
			con=14,
			int=11,
			wis=11,
			cha=15,
			weapon="sword, great",
			d=6,--2d6
			armour="plate",
			ac=18,
			type=type,
			spr=194,
			exp=70,
			gold=100,
			init=0,
			cr=0
			}
	end
	if (type=="hobgoblin") then
		hp=droll(2,8)+2
		tbl={hp=hp,
			curr_hp=hp,
			str=13,
			dex=12,
			con=12,
			int=10,
			wis=10,
			cha=9,
			weapon="longsword",
			d=10,--1d10+1
			armour="chain mail",
			ac=18,
			type=type,
			spr=195,
			exp=10,
			gold=20,
			init=0,
			cr=0.5
			}
	end
	if (type=="ogre") then
		hp=droll(7,10)+21
		tbl={hp=hp,
			curr_hp=hp,
			str=19,
			dex=8,
			con=16,
			int=5,
			wis=7,
			cha=7,
			weapon="great club",
			d=16,--2d8+4
			armour="hide armour",
			ac=11,
			type=type,
			spr=196,
			exp=45,
			gold=90,
			init=0,
			cr=2
			}
	end
	if (type=="guard captain") then
		hp=droll(7,8)+14
		tbl={hp=hp,
			curr_hp=hp,
			str=13,
			dex=12,
			con=12,
			int=10,
			wis=10,
			cha=9,
			weapon="longsword",
			d=20,--2d10+2 two handed
			armour="chain mail",
			ac=17,
			type=type,
			spr=197,
			exp=20,
			gold=40,
			init=0,
			cr=1
			}
	end
	if (type=="hill giant") then
		hp=droll(10,12)+40
		tbl={hp=hp,
			curr_hp=hp,
			str=21,
			dex=8,
			con=19,
			int=5,
			wis=9,
			cha=6,
			weapon="great club",
			d=48,--2x 3d8+5
			armour="natural armour",
			ac=13,
			type=type,
			spr=198,
			exp=180,
			gold=200,
			init=0,
			cr=5
			}
	end
	if (type=="minotaur") then
		hp=droll(9,10)+27
		tbl={hp=hp,
			curr_hp=hp,
			str=18,
			dex=11,
			con=16,
			int=6,
			wis=16,
			cha=9,
			weapon="great axe",
			d=28,--2d12+4
			armour="natural armour",
			ac=14,
			type=type,
			spr=199,
			exp=70,
			gold=160,
			init=0,
			cr=3
			}
	end
	if (type=="stone giant") then
		hp=droll(10,12)+40
		tbl={hp=hp,
			curr_hp=hp,
			str=23,
			dex=15,
			con=5,
			int=10,
			wis=12,
			cha=9,
			weapon="great club",
			d=48,--2x 3d8+6
			armour="natural armour",
			ac=17,
			type=type,
			spr=200,
			exp=290,
			gold=280,
			init=0,
			cr=7
			}
	end

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
	plyr=reset_plyr
	fmap={}
	wave=1
	wave_init()
	field_pos=1
	fmenu=false
	gamestate=0
end

function save()
	save_plyr=plyr
	save_fmap=fmap
	save_wave=wave
end

function load()
	plyr=save_plyr
	fmap=save_fmap
	namp=save_fmap
	wave=save_wave
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
00000000666666666666666666666666999499940000000700000000000770000000000009000000007770000000000000000000000000000000000000000000
000000006555555555555555555555569994999400000070000cc0000077770000a8a00007777000077777000000000000000000000000000000000000000000
007007006666666666666666666666664444444400000700000c000000077000009a9000077777707057057000aa000600000000000000000000000000000000
0007700065555555555555555555555699499949000070000ccccc00000ee00000090000077777707567567000af006000000000000000000000000000000000
000770006666666666666666666666669949994900070000000c000000eeee000009000007777770077577000adc060000000000000000000000000000000000
00700700655555555555555555555556444444440a700000000cc0000eeeeee00009000009777770077d77000cccd00000000000000000000000000000000000
000000006666666666666666666666669499949904a0000000c00c0000eeee0000090000090007700076700000cc000000000000000000000000000000000000
0000000000000000000000000000000094999499400000000c00c000000ee0000000000009000000006760000c0c000000000000000000000000000000000000
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
d06ff000066660000011000000099000005116000004440009999000070007000076660000000000000000000000000000000000000000000000000000000000
5f97650000555600022116009099990905e11166004f4f0009ff9900700000700066660000000000000000000000000000000000000000000000000000000000
0f9ff5f000663360015f5000991f9199ee1722200411f100091f1f907088870005d6d66000000000000000000000000000000000000000000000000000000000
00aaf3ff066333360faf1011099ff990000ed20000ffff0009f4f990885858800666666000000000000000000000000000000000000000000000000000000000
4f3f334f0abb63560555211100955900606ed0010195591194494499088888000066670000000000000000000000000000000000000000000000000000000000
ff33333fb3bb65560d55222252999922eee11001111ff111f999999f008288000076670000000000000000000000000000000000000000000000000000000000
f03333303b36356005522112252992250000510011112111f99999ff008288880667666500000000000000000000000000000000000000000000000000000000
00033333055636001122d111222225220000010011112111f99999ff888888886666666600000000000000000000000000000000000000000000000000000000
00000000000000700011060500000000001100000000000009999000070007000076660066666766666666660000070000000000000000099000000000000000
0000000000660067022f5005009009000e6210000000006009ff99007000007000666600666676666766666600006000070000000000009aaa00000000000000
0000000000a3604000ff50050009900007e2400000044060091f1f907088870005d6d6606666676cc676666600000602206000000000ffaaaa00000000000000
000f000000336040001d1099009999000e049900010ff06009f4f9908858588006666660666666cccc6666660000002222000000000fffaaaf00000000000000
00313f00035555300121211f025992200f9440f000112d909449449908888800006667006666661cbb6666660000008211000000000fff6a6ff0000000000000
0f033000055550401015100900225200000141f000ddd000f999999f008288000076670066666111bb6666660000088811000000000ff66666f0000000000000
000310000010104000010000005225000010100000055000f99999ff00828000066766656611cc111cc66666008822888220000040ff66666660000000000000
005005000050504000201000009009000010011000505000f99999ff08888880666666666611c61116cc66660088208880220000044ff6666666000000000000
000000000000000000000000000000000000000000000000f99999ff0888880866666666666cc6c1c66c16660002209890028000004ff6666666000000000000
000000000000000000000000000000000000000000000000f44499ff080880086666666666666ccccc6116660000099999088000000fff666660000000000000
00000000000000000000000000000000000000000000000004544444080080085566665566666cccccc6666600000999999000000001f446611ff00000000000
0000000000000000000000000000000000000000000000000454544408808000007666706666661cc116666600000089988000000001144411fff00000000000
00000000000000000000000000000000000000000000000009599990080088000076566066666111c166666600000888980000000000f044410f000000000000
000000000000000000000000000000000000000000000000099999900008080000765660555511155115555555558885588555555555ff54445ff55500000000
0000000000000000000000000000000000000000000000000ff00ff00080080007656660555511555111555555558855588855555555dd5544fffd5500000000
000000000000000000000000000000000000000000000000fff0fff00880880006656670555555555511555555555555558855555555fff5555fddf500000000
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
