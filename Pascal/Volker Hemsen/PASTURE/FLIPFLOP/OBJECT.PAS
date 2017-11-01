{$M+,E+}
PROGRAM objekt_routinen;

{$i gemohne.pas}

{	kopiere C-String nach C-String	}
procedure copy_c_to_c(von,nach:String_ptr);
var	i:integer;
		c:char;
begin
	i:=0;
	repeat
		c:=von^[i];
		nach^[i]:=c;
		i:=i+1;
	until ((c=chr(0)) or (i>=255));
end;

{	Popup darstellen und verwalten	}
function do_popup(var parent:tree_ptr;child:integer;popup:tree_ptr;first:integer):integer;
var	ob,obx : integer;
	x,y,b,h : integer;
	mx,my,mb,mk,first_mb : integer;
	s:string[80];
begin
	ob:=first+1;
	wind_update(1);
	wind_update(3);
	objc_offset(parent,child,x,y);
	popup^[0].ob_x:=x;
	popup^[0].ob_y:=y-popup^[ob].ob_y;
	popup^[ob].ob_state:=(popup^[ob].ob_state|SELECTED);
	objc_offset(popup,0,x,y);
	x:=x-2;	y:=y-2;
	b:=popup^[0].ob_w+5;	h:=popup^[0].ob_h+5;
	objc_draw(popup,0,8,x,y,b,h);
	evnt_timer(150,0);
	graf_mkstate(mx,my,mb,mk);
	first_mb:=mb;
	while (mb=first_mb) do
	begin
		obx:=objc_find(popup,0,8,mx,my);
		if ((obx>0) and (obx<>ob)) then
			if ((popup^[obx].ob_flags & TOUCH_EXIT)<>0) then
			begin
				objc_change(popup,ob,0,x,y,b,h,0,true);
				objc_change(popup,obx,0,x,y,b,h,1,true);
				ob:=obx;
			end;
		graf_mkstate(mx,my,mb,mk);
	end;
	if (mb<>0) then
		obx:=evnt_button(3,1,0,mx,my,mb,mk);
	popup^[ob].ob_state:=(popup^[ob].ob_state&~SELECTED);
	if ((mb=2) or (obx<0)) then
		ob:=first
	else
		copy_c_to_c(popup^[ob].ob_spec.str,parent^[child].ob_spec.str);
	objc_draw(parent,0,8,x,y,b,h);
	wind_update(2);
	wind_update(0);
	do_popup:=ob-1;
end;


{	Popup neu setzen	}
procedure set_popup(parent:tree_ptr;child:integer;popup:tree_ptr;first:integer);
begin
	first:=first+1;
	copy_c_to_c(popup^[first].ob_spec.str,parent^[child].ob_spec.str);
	obj_redraw(parent,child);
end;


{	Dieser Aufruf ist in der Lib vergessen worden!	}
function form_button(t:tree_ptr;ob,clks:integer;var nob:integer):boolean;
type	addr_in_parms2 = array[0..1] of tree_ptr;
var	intin : int_in_parms;
		intout : int_out_parms;
		addrin : addr_in_parms2;
		addrout : addr_out_parms;
procedure aes_call2(op:integer;var intin:int_in_parms;var intout:int_out_parms;
				var addrin:addr_in_parms2;var addrout:addr_out_parms);
	external;
begin
	addrin[0]:=t;
	intin[0]:=ob;
	intin[1]:=clks;
	aes_call2(56,intin,intout,addrin,addrout);
	nob:=intout[1];
	form_button:=(intout[0]<>0);
end;

{	form_keybd() aus der Lib ist fehlerhaft!	}
function form_keybd2(t:tree_ptr;ob,nob,char:integer;var pnob,pchar:integer):boolean;
type	addr_in_parms2 = array[0..1] of tree_ptr;
var	intin : int_in_parms;
		intout : int_out_parms;
		addrin : addr_in_parms2;
		addrout : addr_out_parms;
procedure aes_call2(op:integer;var intin:int_in_parms;var intout:int_out_parms;
				var addrin:addr_in_parms2;var addrout:addr_out_parms);
	external;
begin
	addrin[0]:=t;
	intin[0]:=ob;
	intin[1]:=char;
	intin[2]:=nob;
	aes_call2(55,intin,intout,addrin,addrout);
	pnob:=intout[1];
	pchar:=intout[2];
	form_keybd2:=(intout[0]<>0);
end;


begin
end.
