(*  PurePascalEyes                                            *)
(*  Copyright 1992 by Thomas Hoffmann                         *)
(*              Application Systems Heidelberg Software GmbH  *)

program PurePascalEyes;

{$X+}		(*Funktionsaufrufe ohne Verwendung des Resultats erlaubt*)

uses gem;

type	GRECT=	record
					g_x,g_y,g_w,g_h: integer;
				end;

CONST	ALL=	0;
		EYES=	1;

var	phys_handle,handle:	integer;	(*Handles fÅr GEM und VDI*)
	whandle:			integer;	(*Window-Handle fÅr Uhr*)
	gl_wchar,gl_hchar:	integer;	(*Breite bzw. Hîhe eines Zeichens*)
	gl_wbox,gl_hbox:	integer;
	max_x,max_y:		integer;	(*grîûte x bzw y Koordinate*)
	appl_id,menu_id:	integer;	(*Applikationsnummer,MenÅeintrag*)
	work_in:			workin_array;
	work_out:			workout_array;

	title:				string[19];	(*Titelzeile fÅr Fenster*)
	events:				integer;	(*Ereigniskombination fÅr evnt_multi*)
	oldx,oldy: 			integer;
	ende:				integer;
	wx,wy:				integer;

function max(a,b:integer):integer;	(*Maximum zweier Integerwerte ermitteln*)
begin
	if a>b then max:=a else max:=b
end;

function min(a,b:integer):integer;	(*Minimum zweier Integerwerte ermitteln*)
begin
	if a<b then min:=a else min:=b
end;

function hiword(wert:pointer):word;	(*Highword eines Pointers ermitteln*)
begin
	hiword:=longint(wert) div 65536;
end;

function loword(wert:pointer):word;	(*Lowword eines Pointers ermitteln*)
begin
	loword:=longint(wert) mod 65536;
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

function open_vwork: boolean;	(*virtuelle Arbeitsstation îffnen*)
var	i:	integer;
begin
	for i:=0 to 9 do work_in[i]:=1;
	work_in[10]:=2;
	phys_handle:=graf_handle(gl_wchar,gl_hchar,gl_wbox,gl_hbox);
	work_in[0]:=phys_handle;
	handle:=phys_handle;
	v_opnvwk(work_in,handle,work_out);
	open_vwork:=TRUE
end;

procedure close_vwork;	(*virtuelle Arbeitsstation schlieûen*)
begin
	v_clsvwk(handle)
end;

procedure setfillparams(color,perimeter,interior:integer);	(*Parameter fÅr gefÅllte FlÑchen setzen*)
begin
	vsf_color(handle,color);
	vsf_perimeter(handle,perimeter);
	vsf_interior(handle,interior);
end;

procedure redrawwindow(what:integer);	(*Fensterinhalt auffrischen*)
var	box,work:					GRECT;
	clip:						Array_4;
	pmx,pmy,pmstate,pkstate:	integer;
	xx,yy,zz,f,ff:				real;

	procedure pupil(mx,my,x,y:integer);
	begin
		xx:=mx-(work.g_x+x);
		yy:=my-(work.g_y+y);
		zz:=sqrt(sqr(xx)+sqr(yy));
		if zz<>0 then
		begin
			f:=9*xx/zz; ff:=19*yy/zz
		end
		else
		begin
			f:=0; ff:=0
		end;
		v_circle(handle,work.g_x+x+trunc(f),work.g_y+y+trunc(ff),10);
	end;

begin
	if whandle<=0 then
		exit;
	wind_get(whandle,WF_WORKXYWH,work.g_x,work.g_y,work.g_w,work.g_h);
	wind_get(whandle,WF_FIRSTXYWH,box.g_x,box.g_y,box.g_w,box.g_h);
	graf_mkstate(pmx,pmy,pmstate,pkstate);
	while (box.g_w>0) and (box.g_h>0) do
	begin
		if rc_intersect(work,box) then
		begin
			clip[0]:=box.g_x; clip[1]:=box.g_y;
			clip[2]:=box.g_x+box.g_w-1; clip[3]:=box.g_y+box.g_h-1;
			vs_clip(handle,1,clip);
			if what=ALL then
			begin
				mouse_off;
				setfillparams(WHITE,0,FIS_SOLID);
				vr_recfl(handle,clip);
				setfillparams(BLACK,1,FIS_HOLLOW);
				v_ellipse(handle,work.g_x+25,work.g_y+40,20,35);		
				v_ellipse(handle,work.g_x+work.g_w-25,work.g_y+40,20,35);
				mouse_on;
			end;
			if (oldx<>pmx) or (oldy<>pmy) or (what=ALL) then
			begin
				mouse_off;
				setfillparams(WHITE,0,FIS_SOLID);
				pupil(oldx,oldy,25,40);
				pupil(oldx,oldy,work.g_w-25,40);
				setfillparams(BLACK,0,FIS_SOLID);
				pupil(pmx,pmy,25,40);
				pupil(pmx,pmy,work.g_w-25,40);
				mouse_on;
			end;
		end;
		wind_get(whandle,WF_NEXTXYWH,box.g_x,box.g_y,box.g_w,box.g_h);
	end;
	oldx:=pmx; oldy:=pmy;
end;

procedure open_window;	(*Fenster îffnen*)
var	calc:	GRECT;
begin
	if whandle <=0 then
	begin
		whandle:=wind_create(NAME or CLOSER or MOVER,0,0,max_x+1,max_y+1);
		if whandle<=0 then
 			exit;
		title:=' Eyes '#0;
		wind_set(whandle,WF_NAME,hiword(@title[1]),loword(@title[1]),0,0);
		mouse_off;
		if wx=-1 then
		begin
			wind_calc(WC_BORDER,CLOSER OR MOVER,100,100,100,100,
			calc.g_x,calc.g_y,calc.g_w,calc.g_h);
			wx:=(max_x-calc.g_w) div 2;
			wy:=16+(max_y-calc.g_h) div 2;
		end;
		wind_open(whandle,wx,wy,100,100);
		mouse_on;
	end
	else
		wind_set(whandle,WF_TOP,0,0,0,0);
end;

function handle_message(var pipe:array_8):integer;	(*Messages abarbeiten*)
var dummy:	integer;
begin
	case pipe[0] of
		WM_REDRAW:	redrawwindow(ALL);
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
					begin
						wind_set(whandle,WF_CURRXYWH,pipe[4],pipe[5],pipe[6],pipe[7]);
						redrawwindow(all);
					end;
		AC_OPEN:	if pipe[4]=menu_id then
					begin
						open_window;
						events:=MU_MESAG or MU_TIMER;
					end;
		AC_CLOSE:	if pipe[3]=menu_id then
						whandle:=0;
	end;
	handle_message:=0;
end;

function event_loop:integer;	(*Ereignisschleife-das Herz des Programmes*)
var	event,x,y,kstate,key,clicks,state,quit:	integer;
	pipe:									array_8;
begin
	quit:=0;
	repeat
		event:=evnt_multi(events,0,0,0,0,0,0,0,0,0,0,0,0,0,
							pipe,100,0,x,y,state,kstate,key,clicks);
		wind_update(BEG_UPDATE);
		if (event and MU_MESAG)<>0 then
			quit:=handle_message(pipe);
		if (event and MU_TIMER)<>0 then
			redrawwindow(EYES);
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
			vswr_mode(handle,MD_REPLACE);
			max_x:=work_out[0];
			max_y:=work_out[1];
			wx:=-1; oldx:=-1; oldy:=-1;
			if appflag=FALSE then
			begin
				menu_id:=menu_register(appl_id,'  Pure Pascal Eyes ');
				events:=MU_MESAG
			end
			else
			begin
				graf_mouse(0,nil);
				events:=MU_MESAG or MU_TIMER;
				open_window
			end;
			repeat
				ende:=event_loop
			until ende=1;		
			close_vwork
		end;
		appl_exit
	end
end.