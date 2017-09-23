(*  PurePascalClock                                           *)
(*  Copyright 1992 by Thomas Hoffmann                         *)
(*              Application Systems Heidelberg Software GmbH  *)

{$X+}		(*Funktionsaufrufe ohne Verwendung des Resultats erlaubt*)

program PurePascalClock;

uses gem,tos;

type	GRECT=	record
					g_x,g_y,g_w,g_h: integer;
				end;

CONST	ALL=	0;
		TIME=	1;

var	phys_handle,handle:	integer;	(*Handles fr GEM und VDI*)
	whandle:	integer;			(*Window-Handle fr Uhr*)
	gl_wchar,gl_hchar:	integer;	(*Breite bzw. H”he eines Zeichens*)
	gl_wbox,gl_hbox:	integer;
	max_x,max_y:	integer;		(*gr”žte x bzw y Koordinate*)
	appl_id,menu_id:	integer;	(*Applikationsnummer,Meneintrag*)
	title:	string[19];				(*Titelzeile fr Fenster*)
	events:	integer;
	stunde,minute,sekunde:	integer;
	oldsec,oldmin,oldhour:	integer;
	secdif,mindif,hourdif:	integer;

	work_in:	workin_array;
	work_out:	workout_array;

	wx,wy,ende:	integer;

	redrawflag:	boolean;

function max(a,b:integer):integer;
begin
	if a>b then
		max:=a
	else
		max:=b
end;

function min(a,b:integer):integer;
begin
	if a<b then
		min:=a
	else
		min:=b
end;

function hiword(wert:pointer):word;
begin
	hiword:=integer((longint(wert)) div 65536);
end;

function loword(wert:pointer):word;
begin
	loword:=integer((longint(wert)) mod 65536);
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

function open_vwork: boolean;
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

procedure close_vwork;
begin
	v_clsvwk(handle)
end;

procedure calcpoint(w,h,i:integer;var x,y:integer;s:integer);
begin
	x:=w div 2+trunc((w div 2-10-s)*sin(2*i*PI/60));
	y:=h div 2+trunc((h div 2-10-s)*cos(PI+2*i*PI/60))
end;

procedure gettime(var hour,min,sec:integer);
var	time:	word;
begin
	time:=Tgettime;
	hour:=(time shr 11) and $1F;
	if hour>12 then hour:=hour-12;
	min:=(time shr 5) and $3F;
	sec:=(time and $1F)*2;
end;

procedure showtime;
var	x,y:	integer;
	xyarray:	ptsin_array;
	work:	GRECT;
begin  
	wind_get(whandle,WF_WORKXYWH,work.g_x,work.g_y,work.g_w,work.g_h);
	xyarray[0]:=work.g_x+work.g_w div 2;
	xyarray[1]:=work.g_y+work.g_h div 2;
	calcpoint(work.g_w,work.g_h,oldsec,x,y,secdif);
	xyarray[2]:=work.g_x+x; xyarray[3]:=work.g_y+y;
	vsl_color(handle,WHITE);
	vsl_width(handle,1);		
	v_pline(handle,2,xyarray);
	if minute <> oldmin then
	begin
		calcpoint(work.g_w,work.g_h,oldmin,x,y,mindif);
		xyarray[2]:=work.g_x+x; xyarray[3]:=work.g_y+y;
		vsl_width(handle,3);		
		vsl_color(handle,WHITE);		
		v_pline(handle,2,xyarray);
	end;
	if (minute<>oldmin) or (minute mod 12=0) or (stunde<>oldhour) then
	begin
		vsl_width(handle,5);		
		calcpoint(work.g_w,work.g_h,oldhour*5+oldmin div 12,x,y,hourdif);
		xyarray[2]:=work.g_x+x; xyarray[3]:=work.g_y+y;
		vsl_color(handle,WHITE);		
		v_pline(handle,2,xyarray);
	end;
	calcpoint(work.g_w,work.g_h,sekunde,x,y,secdif);
	xyarray[2]:=work.g_x+x; xyarray[3]:=work.g_y+y;
	vsl_color(handle,BLACK);
	vsl_width(handle,1);		
	v_pline(handle,2,xyarray);
	calcpoint(work.g_w,work.g_h,minute,x,y,mindif);
	xyarray[2]:=work.g_x+x; xyarray[3]:=work.g_y+y;
	vsl_width(handle,3);		
	v_pline(handle,2,xyarray);
	calcpoint(work.g_w,work.g_h,stunde*5+minute div 12,x,y,hourdif);
	xyarray[2]:=work.g_x+x; xyarray[3]:=work.g_y+y;
	vsl_width(handle,5);		
	v_pline(handle,2,xyarray);
end;

procedure redrawwindow(what:integer);
var	box,work:	GRECT;
	clip:	Array_4;
	i,x,y:	integer;
	fak:	real;
begin
	if whandle<=0 then
		exit;
	mouse_off;
	vswr_mode(handle,MD_REPLACE);
	wind_get(whandle,WF_WORKXYWH,work.g_x,work.g_y,work.g_w,work.g_h);
	wind_get(whandle,WF_FIRSTXYWH,box.g_x,box.g_y,box.g_w,box.g_h);
	secdif:=min(work.g_w,work.g_h) div 2;
	mindif:=trunc(secdif/5);
	hourdif:=trunc(secdif/3);
	secdif:=trunc(secdif/6);
	gettime(stunde,minute,sekunde);
	if oldsec=sekunde then inc(sekunde);
	while (box.g_w>0) and (box.g_h>0) do
	begin
		if rc_intersect(work,box) then
		begin
			clip[0]:=box.g_x;
			clip[1]:=box.g_y;
			clip[2]:=box.g_x+box.g_w-1;
			clip[3]:=box.g_y+box.g_h-1;
			vs_clip(handle,1,clip);
			case what of
			ALL:	begin
						vsf_color(handle,WHITE);
						vsf_perimeter(handle,0);
						vsf_interior(handle,FIS_SOLID);
						vr_recfl(handle,clip);
						vsf_color(handle,BLACK);
						vsf_perimeter(handle,1);
						for i:=0 to 11 do
						begin
							calcpoint(work.g_w,work.g_h,i*5,x,y,0);
							v_circle(handle,work.g_x+x,work.g_y+y,2);
						end;
						showtime;
					end;
			TIME:	showtime;
			end
		end;
		wind_get(whandle,WF_NEXTXYWH,box.g_x,box.g_y,box.g_w,box.g_h);
	end;
	oldsec:=sekunde; oldmin:=minute; oldhour:=stunde;
	mouse_on;
end;

procedure open_window;
var calc:	GRECT;
begin
	if whandle <=0 then
	begin
		whandle:=wind_create(NAME or CLOSER or MOVER or SIZER,0,0,max_x+1,max_y+1);
		if whandle<=0 then
 			exit;
		title:=' Pure Pascal Clock ';
		wind_set(whandle,WF_NAME,hiword(@title[1]),loword(@title[1]),0,0);
		mouse_off;
		if wx=-1 then
		begin
			wind_calc(WC_BORDER,CLOSER OR MOVER,100,100,170,170,
			calc.g_x,calc.g_y,calc.g_w,calc.g_h);
			wx:=(max_x-calc.g_w) div 2;
			wy:=16+(max_y-calc.g_h) div 2;
		end;
		wind_open(whandle,wx,wy,170,170);
		mouse_on;
	end
	else
		wind_set(whandle,WF_TOP,0,0,0,0);
end;

function handle_message(var pipe:array_8):integer;
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
						wind_set(whandle,WF_CURRXYWH,pipe[4],pipe[5],pipe[6],pipe[7])
					else
						redrawflag:=TRUE;
		WM_SIZED:	if pipe[3]=whandle then
					begin
						if pipe[6]<100 then pipe[6]:=100;
						if pipe[7]<100 then pipe[7]:=100;
						wind_set(whandle,WF_CURRXYWH,pipe[4],pipe[5],pipe[6],pipe[7]);
						redrawwindow(ALL);
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

function event_loop:integer;
var	event,x,y,kstate,key,clicks,state,quit:	integer;
	pipe:	array_8;
begin
	quit:=0;
	repeat
		event:=evnt_multi(events,258,3,0,0,0,0,0,0,0,0,0,0,0,
							pipe,1000,0,x,y,state,kstate,key,clicks);
		wind_update(BEG_UPDATE);
		if (event and MU_TIMER)<>0 then
		begin
			if redrawflag then
			begin
				redrawwindow(ALL);
				redrawflag:=FALSE
			end
			else
				redrawwindow(TIME);
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
			max_x:=work_out[0];
			max_y:=work_out[1];
			redrawflag:=FALSE;
			wx:=-1;
			if appflag=FALSE then
			begin
				menu_id:=menu_register(appl_id,'  Pure Pascal Clock ');
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