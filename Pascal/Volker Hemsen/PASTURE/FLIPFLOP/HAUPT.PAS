
{
	FlipFlop
	Programm zum Formatieren von DD und HD Disketten
	Volker Hemsen - Juli 1993
	entwickelt mit ST-Pascal plus V2.1
	und der Entwicklungsumgebung Pasture
}


PROGRAM flipflop;

{$i resource.i}
{$i gemohne.pas}		{Includedatei OHNE Kommentare}

CONST
	wind_attr = $B;      {G_NAME | G_CLOSE | G_MOVE;}

{$i vars.i}


function rsrc_adr(i:integer):tree_ptr;
	external;
procedure rsrc_init;
	external;

{$i object.i}
{$i format.i}

{	Dialogverwaltung	}
procedure dialog_format(ex:integer);
var	t,tpopup : tree_ptr;
begin
	wind_update(1);
	t:=rsrc_adr(TFORMAT);
	case ex of
		DFLAUFW:	{Laufwerk w„hlen}
			laufwerk:=do_popup(t,DFLAUFW,rsrc_adr(TPOPUPL),laufwerk);
		DFDICHTE:	{Dichte (DD/HD) w„hlen}
			begin
				dichte:=do_popup(t,DFDICHTE,rsrc_adr(TPOPUPD),dichte);
				if (dichte=0) then
					tpopup:=rsrc_adr(TPOPUPF1)
				else
					tpopup:=rsrc_adr(TPOPUPF2);
				set_popup(t,DFFORM,tpopup,format);
			end;
		DFFORM:	{Format/Speicherkapazit„t w„hlen}
			begin
				if (dichte=0) then
					tpopup:=rsrc_adr(TPOPUPF1)
				else
					tpopup:=rsrc_adr(TPOPUPF2);
				format:=do_popup(t,DFFORM,tpopup,format);
			end;
		DFAUS:	{...und raus}
			ende:=true;
		DFFORMAT:	{formatieren}
			begin
				format_init;
				with t^[DFFORMAT] do
					ob_state:=(ob_state&~SELECTED);
				obj_redraw(t,DFFORMAT);
			end;
	end;
	wind_update(0);
end;

{	Formatierbox darstellen	}
procedure working_box(t:tree_ptr;pos,max:integer);
var	x,y,b,h,dx,dy,db,dh :integer;
begin
	wind_update(1);
	pos:=max-pos;
	if (pos=0) then
		t^[DFFSLIDE].ob_flags:=0
	else if (pos=max) then
		t^[DFFSLIDE].ob_flags:=HIDE_TREE;
	t^[DFFSLIDE].ob_w:=((t^[DFFBOX].ob_w*pos) div max);
	obj_size(t,DFFBOX,dx,dy,db,dh);
	first_rect(wind_handle,x,y,b,h);
	while ((b<>0) and (h<>0)) do
	begin
		if (rect_intersect(dx,dy,db,dh,x,y,b,h)=true) then
			objc_draw(t,DFFBOX,2,x,y,b,h);
		next_rect(wind_handle,x,y,b,h);
	end;
	wind_update(0);
end;


{	Curser in der Dialogmox je nach Modus zeichnen	}
procedure dial_curser(mode:boolean;var curser_mode:boolean;t:tree_ptr;eob:integer;var idx:integer);
var	kind:integer;
begin
	if (mode<>curser_mode) then
	begin
		if (mode=true) then
			kind:=1		{ED_INIT}
		else
			kind:=3;		{ED_END}
		dummy:=objc_edit(t,eob,0,idx,kind,idx);
	end;
end;

{	Dialoginitialisierung und Ereignisverwaltung	}
procedure dialog;
var	x,y,b,h,ev : integer;
		t : tree_ptr;
		msg : message_buffer;
		mx,my,mstate,kstate,key,mcount : integer;
		windname : window_title;
		next_ob,edit_ob,dial_idx : integer;
		dial_cont,curser_mode : boolean;
begin
	wind_get(0,5,x,y,b,h);
	wind_handle:=wind_create(wind_attr,x,y,b,h);
	if (wind_handle>0) then
	begin
		t:=rsrc_adr(TFORMAT);
		t^[DFFSLIDE].ob_flags:=HIDE_TREE;
		{form_center(t,x,y,b,h); ist fehlerhaft}
		center_dialog(t);
		wind_calc(false,wind_attr,t^[0].ob_x,t^[0].ob_y,t^[0].ob_w,t^[0].ob_h,x,y,b,h);
		windname:=' FlipFlop - Formatierprogramm ';
		set_wname(wind_handle,windname);
		wind_update(1);
		dummy:=wind_open(wind_handle,x,y,b,h);
		wind_update(0);
		edit_ob:=0;
		repeat
			ev:=get_event(E_KEYBOARD|E_BUTTON|E_MESSAGE|E_TIMER,1,1,2,100,false,0,0,0,0,false,0,0,0,0,
								msg,key,mstate,mcount,mx,my,kstate);
			if ( (ev & (E_KEYBOARD|E_BUTTON))<>0) then
			begin
				if ((ev & E_KEYBOARD)<>0) then
				begin
					dial_cont:=form_keybd2(t,edit_ob,0,key,next_ob,key);
					if (key<>0) then
						dummy:=objc_edit(t,edit_ob,key,dial_idx,2,dial_idx);
				end;
				if ((ev & E_BUTTON)<>0) then
				begin
					next_ob:=objc_find(t,0,8,mx,my);
					if (next_ob<0) then
						next_ob:=0
					else
						dial_cont:=form_button(t,next_ob,mcount,next_ob);
				end;
				if ( (dial_cont=false) or ((next_ob<>0) and (edit_ob<>next_ob)) ) then
				begin
					dial_curser(false,curser_mode,t,edit_ob,dial_idx);	{Curser l”schen}
					if (dial_cont=false) then
						dialog_format(next_ob);
					if (edit_ob<>0) then
					begin
						if ((t^[next_ob].ob_flags & EDITABLE )<>0) then
							edit_ob:=next_ob;
						dial_curser(true,curser_mode,t,edit_ob,dial_idx);	{Curser setzen}
					end;
				end;
			end;
			if ((ev & E_MESSAGE)<>0) then
			begin
				case msg[0] of
					WM_REDRAW:	{Fensterbereich neuzeichnen}
						begin
							wind_update(1);
							if (front_window=wind_handle) then
								dial_curser(false,curser_mode,t,edit_ob,dial_idx);	{Curser setzen}
							first_rect(wind_handle,x,y,b,h);
							while ((b<>0) and (h<>0)) do
							begin
								if (rect_intersect(msg[4],msg[5],msg[6],msg[7],x,y,b,h)=true) then
									objc_draw(t,0,8,x,y,b,h);
								next_rect(wind_handle,x,y,b,h);
							end;
							if (front_window=wind_handle) then
								dial_curser(true,curser_mode,t,edit_ob,dial_idx);	{Curser setzen}
							wind_update(0);
						end;
					WM_TOPPED:	{Fenster nach oben bringen}
						bring_to_front(wind_handle);
					WM_CLOSED:	{Fenster schliežen -> Dialog verlassen}
						ende:=true;
					WM_MOVED:	{Fenster bewegen}
						begin
							set_wsize(wind_handle,msg[4],msg[5],msg[6],msg[7]);
							wind_calc(true,wind_attr,msg[4],msg[5],msg[6],msg[7],t^[0].ob_x,t^[0].ob_y,b,h);
						end;
				end;
			end;
			if ( ((ev&E_TIMER)<>0) and (format_prozess=true)) then
			begin
				working_box(t,track,track_anz-1);
				formatieren;
			end;
		until (ende=true);
		wind_update(1);
		wind_close(wind_handle);
		wind_delete(wind_handle);
		wind_update(0);
	end;
end;

{	Hauptprogramm	}
begin
	if (appl_init>=0) then
	begin
		set_mouse(M_ARROW);	{Maus als Pfeil}
		rsrc_init;		{eingebundene Resourcen initialisieren}
		dialog;			{Hauptroutine}
		dummy:=appl_exit;
	end;
end.
