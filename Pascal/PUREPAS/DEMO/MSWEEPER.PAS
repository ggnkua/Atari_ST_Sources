(*  PurePascalMineSweeper                                     *)
(*  Copyright 1992 by Thomas Hoffmann                         *)
(*              Application Systems Heidelberg Software GmbH  *)

{$M 32768}	(*fr Rekursion ausreichend Platz auf dem Stack reservieren*)
{$X+}		(*Funktionsaufrufe ohne Verwendung des Resultats erlaubt*)

program PurePascalMineSweeper;

uses gem,tos;

type	GRECT=	record
					g_x,g_y,g_w,g_h: integer;
				end;
		element=	record
						value: integer;
						flag: integer;
					end;
		redrawproctype=	procedure(var box:GRECT;value,what:integer);
		
{$I MSWEEPER.I }		(*Konstantendefinitionen der RSC einbinden*)

CONST	GFLAG_CLOSE		=-1;	(*Einige Konstanten*)
		GFLAG_MARKED	=11;
		GFLAG_ASK		=9;
		GVAL_MINE		=10;
		GVAL_NOMINE		=0;
		DISP_MINES		=0;
		DISP_TIME		=1;
		DISP_SMILE		=2;

		C_LEOS			=0;
		C_ANFAENGER		=1;
		C_FORTGESCHRITTENE=2;
		C_PROFIS		=3;

		RBNORM	=0;
		RBSEL	=1;
		CBNORM	=2;
		CBSEL	=3;

		DCHECKBOX	=$40;
		DRADIO		=$60;

var	work_in:	workin_array;
	work_out:	workout_array;

	handle,phys_handle,f:	integer;
	gl_hchar,gl_wchar,gl_hbox,gl_wbox:	integer;
	max_x,max_y,appl_id,menu_id,gl_apid:	integer;
	whandle,events,wx, wy:	integer;
	title:	string[20];

	icon:	array [0..8] of MFDB;
	button:	array [0..3] of MFDB;
	checkblk, radioblk:	userblk;
	dialog:	AESTreePtr;

	gamearray:	array[0..101,0..81] of element;
	zeilen,spalten,minen: integer;
	status,statusalt,time,markiert,offene_felder,actsmile: integer;

	oldtimer:	longint;

	timeflag,gameflag,colorflag:	boolean;
	ende:	integer;

function open_vwork: boolean;
var	i:	integer;
begin
	for i:=0 to 9 do work_in[i]:=1;
 	work_in[10]:=2;
	phys_handle:=graf_handle(gl_wchar,gl_hchar,gl_wbox,gl_hbox);
		work_in[0]:=phys_handle;
	handle:=phys_handle;
	v_opnvwk(work_in,handle,work_out);
	open_vwork:=TRUE;
end;

procedure initicon(i:integer; var ptr:pointer);
var mymfdbsrc:	MFDB;
	bitbl:		BITBLKPtr;
begin
	bitbl:=ptr;
	mymfdbsrc.fd_addr:=bitbl^.bi_pdata;
	mymfdbsrc.fd_w:=21;
	mymfdbsrc.fd_h:=21 div f;
	mymfdbsrc.fd_wdwidth:=2;
	mymfdbsrc.fd_stand:=1;
	mymfdbsrc.fd_nplanes:=1;
	icon[i].fd_addr:=bitbl^.bi_pdata;
	icon[i].fd_w:=21;
	icon[i].fd_h:=21 div f;
	icon[i].fd_wdwidth:=2;
	icon[i].fd_stand:=0;
	icon[i].fd_nplanes:=1;
	vr_trnfm(handle,mymfdbsrc,icon[i]);
end;	

procedure initbutton(o,i:integer; var ptr:pointer);
var mymfdbsrc:	MFDB;
	bitbl:		BITBLKPtr;
	aesptr:		AESTreePtr;
begin
	aesptr:=ptr;
	bitbl:=aesptr^[o].ob_spec.bit_blk; 
	mymfdbsrc.fd_addr:=bitbl^.bi_pdata;
	mymfdbsrc.fd_w:=16;
	mymfdbsrc.fd_h:=12 div f;
	mymfdbsrc.fd_wdwidth:=1;
	mymfdbsrc.fd_stand:=1;
	mymfdbsrc.fd_nplanes:=1;
	button[i].fd_addr:=bitbl^.bi_pdata;
	button[i].fd_w:=16;
	button[i].fd_h:=12 div f;
	button[i].fd_wdwidth:=1;
	button[i].fd_stand:=0;
	button[i].fd_nplanes:=1;
	vr_trnfm(handle,mymfdbsrc,button[i]);
end;	

procedure showbutton(bu,x,y:integer);
var mymfdbscreen:	MFDB;
	pxyarray:	ARRAY_8;
	colind:	ARRAY_2;
	h:	integer;
begin
	if f>1 then h:=7 else h:=11;
	mymfdbscreen.fd_addr:=NIL;
	pxyarray[0]:=0; pxyarray[1]:=0;
	pxyarray[2]:=15; pxyarray[3]:=h;
	pxyarray[4]:=x; pxyarray[5]:=y;
	pxyarray[6]:=x+15; pxyarray[7]:=y+h;
	colind[0]:=BLACK; colind[1]:=WHITE;
	vrt_cpyfm(handle,MD_REPLACE,pxyarray,button[bu],mymfdbscreen,colind);
end;

function DrawRadio( dummy1, dummy2 : Pointer; parm: PARMBLKPtr) : Integer;
var	pxyarray:	array_4;
begin
	pxyarray[0]:=parm^.pb_xc; pxyarray[1]:=parm^.pb_yc;
	pxyarray[2]:=parm^.pb_wc; pxyarray[3]:=parm^.pb_hc;
	vs_clip(handle,0,pxyarray);
	if (parm^.pr_currstate and SELECTED)<>0 then
		showbutton(rbsel,parm^.pb_x,parm^.pb_y)
	else
		showbutton(rbnorm,parm^.pb_x,parm^.pb_y);
	DrawRadio:=parm^.pr_currstate and NOT(SELECTED);
end;

function DrawCheck( dummy1, dummy2 : Pointer; parm: PARMBLKPtr) : Integer;
var	pxyarray:	array_4;
begin
	pxyarray[0]:=parm^.pb_xc; pxyarray[1]:=parm^.pb_yc;
	pxyarray[2]:=parm^.pb_wc; pxyarray[3]:=parm^.pb_hc;
	vs_clip(handle,0,pxyarray);
	if (parm^.pr_currstate and SELECTED)<>0 then
		showbutton(cbsel,parm^.pb_x,parm^.pb_y)
	else
		showbutton(cbnorm,parm^.pb_x,parm^.pb_y);
	DrawCheck:=parm^.pr_currstate and NOT(SELECTED);
end;

procedure setuserdef(ptr: AESTreePtr);
var	ob:	AESObjectPtr;
	obj, extype:	integer;
begin
	obj:=0;
	repeat
		inc(obj);
		ob:=@ptr^[obj];
		extype:=ob^.ob_type shr 8;
		if extype=DCHECKBOX then
		begin
			checkblk.ub_code:=@DrawCheck; 
			checkblk.ub_parm:=longint(ob^.ob_spec);
			ob^.ob_type:=G_USERDEF;
			ob^.ob_spec.user_blk:=@checkblk
		end
		else if extype=DRADIO then
		begin
			radioblk.ub_code:=@DrawRadio; 
			radioblk.ub_parm:=longint(ob^.ob_spec);
			ob^.ob_type:=G_USERDEF;
			ob^.ob_spec.user_blk:=@radioblk;
		end
	until (ob^.ob_flags AND LASTOB)<>0
end;

function rsrc_init: boolean;
var offset:	integer;
var ptr:	pointer; 
begin
	if rsrc_load('MSWEEPER.RSC')=1 then
	begin
		if f=2 then offset:=SMILE2-SMILE else offset:=0;
		rsrc_gaddr(R_IMAGEDATA,SMILE+offset,ptr); initicon(0,ptr);
		rsrc_gaddr(R_IMAGEDATA,SUN+offset,ptr); initicon(1,ptr);
		rsrc_gaddr(R_IMAGEDATA,OOH+offset,ptr); initicon(2,ptr);
		rsrc_gaddr(R_IMAGEDATA,BLUB+offset,ptr); initicon(3,ptr);
		rsrc_gaddr(R_IMAGEDATA,STEIN+offset,ptr); initicon(4,ptr);
		rsrc_gaddr(R_IMAGEDATA,MINE+offset,ptr); initicon(5,ptr);
		rsrc_gaddr(R_IMAGEDATA,FAHNE+offset,ptr); initicon(6,ptr);
		rsrc_gaddr(R_IMAGEDATA,LEER+offset,ptr); initicon(7,ptr);
		rsrc_gaddr(R_IMAGEDATA,INFO+offset,ptr); initicon(8,ptr);
		rsrc_gaddr(R_TREE,AUSWERTUNG,ptr); dialog:=ptr;
		setuserdef(dialog);
		rsrc_gaddr(R_TREE,USERIMG,ptr);
		if f=1 then
		begin
			initbutton(RBHNORM,rbnorm,ptr);
			initbutton(RBHSEL,rbsel,ptr);
			initbutton(CBHNORM,cbnorm,ptr);
			initbutton(CBHSEL,cbsel,ptr)
		end
		else
		begin
			initbutton(RBLNORM,rbnorm,ptr);
			initbutton(RBLSEL,rbsel,ptr);
			initbutton(CBLNORM,cbnorm,ptr);
			initbutton(CBLSEL,cbsel,ptr)
		end;
		rsrc_init:=TRUE
	end
	else
		rsrc_init:=FALSE
end;		

procedure close_vwork;
begin
	v_clsvwk(handle);
end;

function max(a,b:integer):integer;
begin
	if a<b then
		max:=b
	else
		max:=a;
end;

function min(a,b:integer):integer;
begin
	if a<b then
		min:=a
	else
		min:=b;
end;

function tostr(w:integer):string;
var	s:	string;
begin
	str(w,s);
	tostr:=s;
end;

function getticks:longint;
var	oldsupstack:	longint;
begin
	oldsupstack:=super(nil);
	getticks:=longint(pointer($4BA)^); 
	super(pointer(oldsupstack));
end;

function histr(wert:pointer):word;
begin
	histr:=longint(wert) div 65536;
end;

function lostr(wert:pointer):word;
begin
	lostr:=longint(wert) mod 65536;
end;

procedure open_window;
var	calc:	GRECT;
begin
	if whandle <=0 then
	begin
		whandle:=wind_create(NAME OR CLOSER OR MOVER,0,0,max_x+1,max_y+1);
		if whandle<=0 then
 			exit;
		title:=' MINESWEEPER ';
		wind_set(whandle,WF_NAME,histr(@title),lostr(@title)+1,0,0);
		if wx=-1 then
		begin
			wind_calc(WC_BORDER,CLOSER OR MOVER,100,100,spalten*21+9,(zeilen*21+56) div f,
			calc.g_x,calc.g_y,calc.g_w,calc.g_h);
			wx:=(max_x-calc.g_w) div 2;
			wy:=16+(max_y-calc.g_h) div 2;
		end;
		wind_open(whandle,wx,wy,spalten*21+9,(zeilen*21+56) div f);
	end
	else
		wind_set(whandle,WF_TOP,0,0,0,0);
end;

function rc_intersect(var r1,r2: GRECT): boolean;
var	x,y,w,h:	integer;
begin
	x:=max(r2.g_x,r1.g_x);
	y:=max(r2.g_y,r1.g_y);
	w:=min(r2.g_x+r2.g_w,r1.g_x+r1.g_w);
	h:=min(r2.g_y+r2.g_h,r1.g_y+r1.g_h);
	r2.g_x:=x;
	r2.g_y:=y;
	r2.g_w:=w-x;
	r2.g_h:=h-y;
	if (w>x) and (h>y) then
		rc_intersect:=true
	else
		rc_intersect:=false;
end;

procedure mouse_on;
begin
	graf_mouse(M_ON,NIL);
end;

procedure mouse_off;
begin
	graf_mouse(M_OFF,NIL);
end;

procedure showicon(ic,x,y,color:integer);
var mymfdbscreen:	MFDB;
	pxyarray:	ARRAY_8;
	colind:	ARRAY_2;
begin
	mymfdbscreen.fd_addr:=NIL;
	pxyarray[0]:=0; pxyarray[1]:=0;
	pxyarray[2]:=20; pxyarray[3]:=20 div f;
	pxyarray[4]:=x; pxyarray[5]:=y;
	pxyarray[6]:=x+20; pxyarray[7]:=y+20 div f;
	colind[0]:=color; colind[1]:=WHITE;
	vrt_cpyfm(handle,MD_REPLACE,pxyarray,icon[ic],mymfdbscreen,colind);
end;

procedure display(var box:GRECT;wert,what:integer);
var	xyarray:	array_4;

function digital(wert:integer):string;
var s:	string[3];
	i:	integer;
begin
	if wert<-99 then wert:=-99;
	if wert>999 then wert:=999;
	str(wert:3,s);
	for i:=1 to 3 do
		if (s[i]>='0') and (s[i]<='9') then
			s[i]:=chr(ord(s[i])-32);
	digital:=s;
end;

begin
	vsf_color(handle,BLACK);
	vsf_interior(handle,FIS_HOLLOW);
	vsf_perimeter(handle,1);
	vst_color(handle,RED);
	case what of
	DISP_MINES:	begin
			xyarray[0]:=box.g_x+4; xyarray[1]:=box.g_y+4 div f;
			xyarray[2]:=xyarray[0]+26; xyarray[3]:=xyarray[1]+20 div f;
			v_bar(handle,xyarray);
			v_gtext(handle,xyarray[0]+2,xyarray[3]-4 div f,digital(wert));
		end;
	DISP_TIME:	begin
			xyarray[0]:=box.g_x+box.g_w-5-26;
			xyarray[1]:=box.g_y+4 div f;
			xyarray[2]:=xyarray[0]+26; xyarray[3]:=xyarray[1]+20 div f;
			v_bar(handle,xyarray);
			v_gtext(handle,xyarray[0]+2,xyarray[3]-4 div f,digital(wert));
		end;
	DISP_SMILE:	begin
			showicon(wert-SMILE,box.g_x+box.g_w div 2-10,box.g_y+4 div f,BLACK);
			actsmile:=wert;
			showicon(INFO,box.g_x+box.g_w-55,box.g_y+4 div f,BLUE);
		end;
	end;
end;	

procedure initgamearray;
var	i,j,x,y:	integer;
begin
	case status of
	C_LEOS:				begin
							zeilen:=8; spalten:=8; minen:=1;
						end;
	C_ANFAENGER:		begin
							zeilen:=8; spalten:=8; minen:=10;
						end;
	C_FORTGESCHRITTENE:	begin
							zeilen:=15; spalten:=16; minen:=35;
						end;
	C_PROFIS:			begin
							zeilen:=15; spalten:=28; minen:=80;
						end;
	end;
	offene_felder:=0;
	markiert:=0; time:=0;
	for i:=0 to spalten+1 do
		for j:=0 to zeilen+1 do
		begin
 			gamearray[i,j].value:=GVAL_NOMINE;
			gamearray[i,j].flag:=GFLAG_CLOSE;
		end;
	i:=0;
	while i<minen do
	begin
		x:=system.random(spalten)+1; y:=system.random(zeilen)+1;
		if gamearray[x,y].value=GVAL_NOMINE then
		begin
			gamearray[x,y].value:=GVAL_MINE;
			inc(i);
		end;
	end;
end;

procedure drawbox(what,xpos,ypos:integer);
var	x,y:	integer;
	box:	GRECT;
	s:	string[1];
begin
	wind_get(whandle,WF_WORKXYWH,box.g_x,box.g_y,box.g_w,box.g_h);
	vst_color(handle,BLACK);
	x:=box.g_x+4+21*xpos;
	y:=box.g_y+32 div f+(21 div f)*ypos;
	case what of
		-1:	showicon(STEIN,x,y,BLACK);
		0:	showicon(LEER,x,y,BLACK);
		1,2,3,4,5,6,7,8:	begin
				str(what,s);
				showicon(LEER,x,y,BLACK);
				if colorflag then
					vst_color(handle,2+what)
				else
					vst_color(handle,BLACK);
				v_gtext(handle,x+6,y+16 div f,s);
			end;
		9:	begin
				showicon(LEER,x,y,BLACK);
				v_gtext(handle,x+6,y+16 div f,'?');
			end;
		10:	showicon(MINE,x,y,BLACK);
		11:	showicon(FAHNE,x,y,RED);
	end;
end;

procedure redrawwindow(redrawproc:redrawproctype;value,what:integer);
var	box,work:	GRECT;
	clip:	Array_4;
begin
	if whandle<=0 then
		exit;
	mouse_off;
	vswr_mode(handle,MD_REPLACE);
	wind_get(whandle,WF_WORKXYWH,work.g_x,work.g_y,work.g_w,work.g_h);
	wind_get(whandle,WF_FIRSTXYWH,box.g_x,box.g_y,box.g_w,box.g_h);
	(*work.g_w:=min(work.g_w,max_x-work.g_x+1);
	work.g_h:=min(work.g_h,max_y-work.g_y+1);*)
	while (box.g_w>0) and (box.g_h>0) do
	begin
		if rc_intersect(work,box) then
		begin
			clip[0]:=box.g_x;
			clip[1]:=box.g_y;
			clip[2]:=box.g_x+box.g_w-1;
			clip[3]:=box.g_y+box.g_h-1;
			vs_clip(handle,1,clip);
			redrawproc(work,value,what);
		end;
		wind_get(whandle,WF_NEXTXYWH,box.g_x,box.g_y,box.g_w,box.g_h);
	end;
	mouse_on;
end;

procedure drawgamearea(var work:GRECT;value,what:integer);
var	i,j:	integer;
	xyarray:	array_4;
begin
	vsf_color(handle,WHITE);
	xyarray[0]:=work.g_x;
	xyarray[1]:=work.g_y;
	xyarray[2]:=work.g_x+work.g_w-1;
	xyarray[3]:=work.g_y+work.g_h-1;
	vr_recfl(handle,xyarray);
	display(work,value,DISP_SMILE);
	for i:=0 to spalten-1 do
		for j:=0 to zeilen-1 do
			drawbox(gamearray[i+1,j+1].flag,i,j);
	display(work,what,DISP_SMILE);
end;

function showelement(x,y:integer):integer;
var	i,j,n:	integer;
begin
	if gamearray[x+1,y+1].flag=GFLAG_CLOSE then
	begin
		inc(offene_felder);
		if gamearray[x+1,y+1].value=GVAL_MINE then
		begin
			redrawwindow(display,OOH,DISP_SMILE);
			events:=MU_MESAG or MU_BUTTON;
			for i:=0 to spalten-1 do
				for j:=0 to zeilen-1 do
					if gamearray[i+1,j+1].value=GVAL_MINE then
					begin
						drawbox(10,i,j);
						gamearray[i+1,j+1].flag:=GVAL_MINE
					end;
			showelement:=0;
			gameflag:=FALSE;
			exit;
		end;
		n:=0;
		for i:=0 to 2 do
			for j:=0 to 2 do
				if gamearray[x+i,y+j].value=GVAL_MINE then
					inc(n);
		drawbox(n,x,y);
		gamearray[x+1,y+1].flag:=n;
		if n=0 then
		begin
			for i:=0 to 2 do
				for j:=0 to 2 do
					if (x-1+i>=0) and (y-1+j>=0) and (x-1+i<=spalten-1) and (y-1+j<=zeilen-1) then
						showelement(x-1+i,y-1+j);
		end;
	end;
	showelement:=1;
end;

procedure einstellungen;
var f:	text;
	n0,n1,n2,n3,s:	string;
	z0,z1,z2,z3,neu,res,status_alt:	integer;

	function get_obj_state(t:AESTREEPtr;o:integer):integer;
	begin
		get_obj_state:=t^[o].ob_state;
	end;

	procedure set_obj_state(t:AESTreePtr;o,s:integer);
	begin
		t^[o].ob_state:=s;
	end;
	
	procedure set_obj_flags(t:AESTREEPtr;o,s:integer);
	begin
		t^[o].ob_flags:=t^[o].ob_flags or s;
	end;
	
	procedure del_obj_flags(t:AESTREEPtr;o,s:integer);
	begin
		t^[o].ob_flags:=t^[o].ob_flags and (t^[o].ob_flags xor s);
	end;

	function hndl_form(obj:integer):integer;
	var answer:	integer;
	x,y,w,h:	integer;
		procedure hide_form(obj:integer);
		begin
			form_center(dialog,x,y,w,h);
			form_dial(fmd_finish,x,y,w,h,x,y,w,h);
		end;
		procedure show_form(obj:integer);
		begin
			form_center(dialog,x,y,w,h);
			form_dial(fmd_start,x,y,w,h,x,y,w,h);
			objc_draw(dialog,0,max_depth,x,y,w,h);
		end;
	begin
		mouse_off;
		show_form(auswertung);
		mouse_on;
		answer:=form_do(dialog,0);
		hide_form(auswertung);
		set_obj_state(dialog, answer, get_obj_state(dialog,answer) and (not selected));
		hndl_form:=answer;
	end;				

begin
	mouse_on;
	n0:='Unbekannt';
	n1:=n0; n2:=n0; n3:=n0;
	z0:=999; z1:=999; z2:=999; z3:=999;
	assign(f,'MSWEEPER.INF');
	{$I-}
	reset(f);
	if IOResult=0 then
	begin
		readln(f,n0); readln(f,z0);
		readln(f,n1); readln(f,z1);
		readln(f,n2); readln(f,z2);
		readln(f,n3); readln(f,z3);
		close(f)
	end;
	{$I+}
	neu:=-1;
	if ende<>3 then
	begin
		case status of
			C_LEOS:	begin
						if min(time,z0)=time then
						begin
							n0:=''; z0:=time; neu:=NAME0;
						end;
					end;
			C_ANFAENGER:	begin
								if min(time,z1)=time then
								begin
									n1:=''; z1:=time; neu:=NAME1;
								end;
							end;
			C_FORTGESCHRITTENE:	begin
									if min(time,z2)=time then
									begin
										n2:=''; z2:=time; neu:=NAME2;
									end;
								end;
			C_PROFIS:	begin
							if min(time,z3)=time then
							begin
								n3:=''; z3:=time; neu:=NAME3;
							end;
						end;
		end
	end;
	if max_x<320 then
	begin
		set_obj_state(dialog,NEXT,DISABLED);
		set_obj_state(dialog,PROFIS,DISABLED);
		set_obj_state(dialog,NEXTTEXT,DISABLED);
		set_obj_state(dialog,PROFTEXT,DISABLED);
	end;
	SetPtext(dialog,name0,n0); SetPtext(dialog,zeit0,tostr(z0));
	SetPtext(dialog,name1,n1); SetPtext(dialog,zeit1,tostr(z1));
	SetPtext(dialog,name2,n2); SetPtext(dialog,zeit2,tostr(z2));
	SetPtext(dialog,name3,n3); SetPtext(dialog,zeit3,tostr(z3));
	if neu<>-1 then
		set_obj_flags(dialog,neu,EDITABLE);
	if hndl_form(auswertung)=BESTDEL then
	begin
		n0:='Unbekannt'; n1:=n0; n2:=n0; n3:=n0;
		z0:=999; z1:=999; z2:=999; z3:=999
	end
	else begin
		GetPtext(dialog,name0,n0); GetPtext(dialog,zeit0,s);
		val(s,z0,res);
		GetPtext(dialog,name1,n1); GetPtext(dialog,zeit1,s);
		val(s,z1,res); 
		GetPtext(dialog,name2,n2); GetPtext(dialog,zeit2,s);
		val(s,z2,res); 
		GetPtext(dialog,name3,n3); GetPtext(dialog,zeit3,s);
		val(s,z3,res) 
	end;	
	if neu <>-1 then
		del_obj_flags(dialog,neu,EDITABLE);
	assign(f,'MSWEEPER.INF');
	{$I-}
	rewrite(f);
	if IOResult=0 then
	begin
		writeln(f,n0); writeln(f,z0);
		writeln(f,n1); writeln(f,z1);
		writeln(f,n2); writeln(f,z2);
		writeln(f,n3); writeln(f,z3);
		close(f);
	end;
	{$I+}
	if dialog^[COLORS].ob_state=SELECTED then colorflag:=TRUE else colorflag:=FALSE;
	status_alt:=status;
	if dialog^[BEGINNER].ob_state=SELECTED then status:=C_ANFAENGER
	else if dialog^[NEXT].ob_state=SELECTED then status:=C_FORTGESCHRITTENE
	else if dialog^[LEO].ob_state=SELECTED then status:=C_LEOS
	else status:=C_PROFIS;
	if status<>status_alt then
	begin
		wind_close(whandle); wind_delete(whandle);
		whandle:=0; initgamearray; wx:=-1;
		open_window;
		redrawwindow(display,SMILE,DISP_SMILE);
		timeflag:=FALSE; gameflag:=TRUE;
	end;
	mouse_off;
end;	

procedure fertig;
var offen,richtig,i,j:	integer;
begin
	if (offene_felder=spalten*zeilen) and (markiert=minen) then
	begin
		redrawwindow(display,SUN,DISP_SMILE);
		timeflag:=FALSE; gameflag:=FALSE;
		events:=MU_MESAG or MU_BUTTON;
		einstellungen;
	end;
end;

function mausclick(xpos,ypos,knopf:integer):integer;
var	x,y,i,j,open,wx,wy:	integer;
	box:	GRECT;
	xyarray:	array_4;
begin
	mausclick:=0;
	wind_get(whandle,WF_WORKXYWH,box.g_x,box.g_y,box.g_w,box.g_h);
	if (xpos-box.g_x-4>=0) and (ypos-box.g_y-32 div f>=0) then
	begin
		x:=(xpos-box.g_x-4) div 21;
		y:=(ypos-box.g_y-32 div f) div (21 div f);
		if (x>=0) and (x<=spalten-1) and (y>=0) and (y<=zeilen-1) and gameflag then
		begin
			if not timeflag then
			begin
				timeflag:=TRUE;
				events:=events or MU_TIMER;
				oldtimer:=getticks; 
			end;
			xyarray[0]:=0; xyarray[1]:=0; xyarray[2]:=max_x; xyarray[3]:=max_y;
			vs_clip(handle,1,xyarray);
			mouse_off;
			if knopf=1 then
			begin
				if showelement(x,y)=1 then
					fertig
			end
			else
			begin
				case gamearray[x+1,y+1].flag of
					GFLAG_MARKED:	begin
							gamearray[x+1,y+1].flag:=GFLAG_ASK;
							dec(markiert);
							dec(offene_felder);
							redrawwindow(display,minen-markiert,DISP_MINES);
							drawbox(gamearray[x+1,y+1].flag,x,y);
						end;
					GFLAG_ASK:	begin
							gamearray[x+1,y+1].flag:=GFLAG_CLOSE;
							drawbox(gamearray[x+1,y+1].flag,x,y)
						end;
					GFLAG_CLOSE:	begin
							gamearray[x+1,y+1].flag:=GFLAG_MARKED;
							inc(markiert);
							inc(offene_felder); 
							redrawwindow(display,minen-markiert,DISP_MINES);
							drawbox(gamearray[x+1,y+1].flag,x,y);
							if markiert=minen then
								fertig;
						end;
				end;
			end;
			mouse_on;
		end;
	end
	else if (xpos>box.g_x+box.g_w div 2-11) and
			(xpos<box.g_x+box.g_w div 2+11) and
			(ypos>box.g_y+4 div f) and
			(ypos<box.g_y+25 div f) then
		mausclick:=2
	else if (xpos>box.g_x+box.g_w-55) and
			(xpos<box.g_x+box.g_w-34) and
			(ypos>box.g_y+4 div f) and
			(ypos<box.g_y+25 div f) then
		mausclick:=3;
end;
			
function handle_message(var pipe:array_8):integer;
var	dummy:	integer;
begin
	case pipe[0] of
		WM_REDRAW:	begin
						redrawwindow(drawgamearea,actsmile,actsmile);
						redrawwindow(display,minen-markiert,DISP_MINES);
						redrawwindow(display,time,DISP_TIME);
					end;
		WM_TOPPED:	wind_set(whandle,WF_TOP,0,0,0,0);
		WM_CLOSED:	begin
						if pipe[3]=whandle then
						begin
							wind_get(whandle,WF_WORKXYWH,wx,wy,dummy,dummy);
							wind_close(whandle);
							wind_delete(whandle);
							whandle:=0;
						end;
						if appflag then
						begin
							handle_message:=1;
							exit;
						end
						else
							events:=MU_MESAG;
					end;
		WM_MOVED:	if pipe[3]=whandle then
						wind_set(whandle,WF_CURRXYWH,pipe[4],pipe[5],pipe[6],pipe[7]);
		WM_SIZED:	if pipe[3]=whandle then
						wind_set(whandle,WF_CURRXYWH,pipe[4],pipe[5],pipe[6],pipe[7]);
		AC_OPEN:	if pipe[4]=menu_id then
					begin
						open_window;
						events:=MU_MESAG or MU_BUTTON or MU_TIMER;
					end;
		AC_CLOSE:	if pipe[3]=menu_id then
						whandle:=0;
	end;
	handle_message:=0;
end;

function event_loop:integer;
var	event,x,y,kstate,key,clicks,state,quit:	integer;
	pipe:	array_8;
begin
	quit:=0;
	repeat
		event:=evnt_multi(events,258,3,0,0,0,0,0,0,0,0,0,0,0,
							pipe,1000,0,x,y,state,kstate,key,clicks);
		wind_update(BEG_UPDATE);
		if (event and MU_BUTTON)<>0 then
			quit:=mausclick(x,y,state);
		if (event and MU_TIMER)<>0 then
		begin
			time:=integer((getticks-oldtimer) div 200);
			redrawwindow(display,time,DISP_TIME);
		end;
		if (event and MU_MESAG)<>0 then
			quit:=handle_message(pipe);
		wind_update(END_UPDATE);
	until quit>0;
	event_loop:=quit;
end;

begin
	appl_id:=appl_init;
	if appl_id<>-1 then
	begin
		if open_vwork then
		begin
			max_x:=work_out[0]-16; max_y:=work_out[1];
			if max_y=199 then f:=2 else f:=1;
			if rsrc_init then
			begin
				wx:=-1; status:=C_ANFAENGER;
				system.randomize;
				initgamearray; colorflag:=TRUE;
				timeflag:=FALSE; gameflag:=TRUE; actsmile:=SMILE;
				if appflag=FALSE then
				begin
					menu_id:=menu_register(appl_id,'  Minesweeper ');
					events:=MU_MESAG;
				end
				else
				begin
					graf_mouse(0,nil);
					events:=MU_MESAG or MU_BUTTON;
					open_window;
				end;
				repeat
					ende:=event_loop;
					if ende>1 then
					begin
						if ende=3 then
						begin
							statusalt:=status;
							mouse_off; einstellungen; mouse_on;
							if timeflag and gameflag and (statusalt=status) then
								events:=MU_MESAG or MU_BUTTON or MU_TIMER
							else
							begin
								events:=MU_MESAG or MU_BUTTON;
								timeflag:=FALSE
							end
						end
						else
						begin
							initgamearray;
							redrawwindow(drawgamearea,BLUB,SMILE);
							redrawwindow(display,minen-markiert,DISP_MINES);
							redrawwindow(display,time,DISP_TIME);
							redrawwindow(display,SMILE,DISP_SMILE);
							events:=MU_MESAG or MU_BUTTON;
							timeflag:=FALSE; gameflag:=TRUE;
						end;
						ende:=-1;
					end;
				until ende=1;
				close_vwork;
			end;
		end;
		appl_exit;
	end;
end.						