uses gem, utility, resource;
{$X+}

type	GRECT=	record
					g_x,g_y,g_w,g_h: integer;
				end;
		element=	record
						value: integer;
						flag: integer;
					end;
		
		
CONST

	RBNORM	= 1;
	RBSEL	= 2;
	CBNORM	= 3;
	CBSEL	= 4;
	CSPINN  = 5;
	CFLYER	= 6;
		
	DRADIO		= 100;
	DCHECKBOX	= 101;
	DSPINN		= 102;
	DTITEL		= 103;
	DFLYER		= 104;
	
var	
	icon:	array [0..8] of MFDB;
	button:	array [0..10] of MFDB;
	flyerblk, titelblk, spinnblk, checkblk, radioblk : userblk;
	free_string : array[0..35] of String;
	Xy_Array : array_4;
	
Procedure Radio_off; external;
{$L radio_1}
Procedure Radio_on; external;
{$L radio_2}
Procedure Check_Off; external;
{$L check_1}
Procedure Check_On; external;
{$L check_2}
Procedure Spinner; external;
{$L Spinner}

Procedure set_xyarray( x,y,w,h : integer);
Begin
	Xy_Array[0]:=x;
	Xy_Array[1]:=y;
	Xy_Array[2]:=w+x;
	Xy_Array[3]:=h+y;
End;
	
procedure initicon(i:integer; var ptr:pointer);
var mymfdbsrc:	MFDB;
	bitbl:		BITBLKPtr;
begin
	bitbl:=ptr;
	mymfdbsrc.fd_addr:=bitbl^.bi_pdata;
	mymfdbsrc.fd_w:=21;
	mymfdbsrc.fd_h:=21 div Color_Planes;
	mymfdbsrc.fd_wdwidth:=2;
	mymfdbsrc.fd_stand:=1;
	mymfdbsrc.fd_nplanes:=1;
	icon[i].fd_addr:=bitbl^.bi_pdata;
	icon[i].fd_w:=21;
	icon[i].fd_h:=21 div Color_Planes;
	icon[i].fd_wdwidth:=2;
	icon[i].fd_stand:=0;
	icon[i].fd_nplanes:=1;
	vr_trnfm(vdi_handle,mymfdbsrc,icon[i]);
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
	mymfdbsrc.fd_h:=12 div Color_Planes;
	mymfdbsrc.fd_wdwidth:=1;
	mymfdbsrc.fd_stand:=1;
	mymfdbsrc.fd_nplanes:=1;
	
	button[i].fd_addr:=bitbl^.bi_pdata;
	button[i].fd_w:=16;
	button[i].fd_h:=12 div Color_Planes;
	button[i].fd_wdwidth:=1;
	button[i].fd_stand:=0;
	button[i].fd_nplanes:=1;
	vr_trnfm(vdi_handle,mymfdbsrc,button[i]);
end;	

Procedure Init_User_Button(i :integer);
var mymfdbsrc:	MFDB;
	p :pointer;
begin
		 if i = RBNORM then	p := @radio_off
	else if i = RBSEL  then	p := @radio_on
	else if i = CBNORM then	p := @check_off
	else if i = CBSEL  then	p := @check_on
	else if i = CSPINN then p := @spinner
	else p:= NIL;

	mymfdbsrc.fd_addr:=p;
	mymfdbsrc.fd_w:=16;
	mymfdbsrc.fd_h:=12 div color_planes;
	mymfdbsrc.fd_wdwidth:=1;
	mymfdbsrc.fd_stand:=1;
	mymfdbsrc.fd_nplanes:=color_planes;
	
	button[i].fd_addr:=p;
	button[i].fd_w:=16;
	button[i].fd_h:=12 div color_planes;
	button[i].fd_wdwidth:=1;
	button[i].fd_stand:=0;
	button[i].fd_nplanes:=color_planes;
	vr_trnfm(Vdi_handle,mymfdbsrc,button[i]);
end;	

procedure showbutton(bu,x,y:integer);
var mymfdbscreen:	MFDB;
	pxyarray:	ARRAY_8;
	colind:	ARRAY_2;
	h:	integer;
begin
	if color_planes>1 then h:=7 else h:=15;
	mymfdbscreen.fd_addr:=NIL;
	pxyarray[0]:=0; pxyarray[1]:=0;
	pxyarray[2]:=15; pxyarray[3]:=h;
	pxyarray[4]:=x; pxyarray[5]:=y;
	pxyarray[6]:=x+15; pxyarray[7]:=y+h;
	colind[0]:=BLACK; colind[1]:=WHITE;
	vrt_cpyfm(vdi_handle,MD_REPLACE,pxyarray,button[bu],mymfdbscreen,colind);
end;

function DrawRadio( d1, d2 : Pointer; parm: PARMBLKPtr) : Integer;
var	pxyarray:	array_4;
	s : string;
begin
	pxyarray[0]:=parm^.pb_xc; pxyarray[1]:=parm^.pb_yc;
	pxyarray[2]:=parm^.pb_wc; pxyarray[3]:=parm^.pb_hc;
	vs_clip(vdi_handle,0,pxyarray);
	if (parm^.pr_currstate and SELECTED)<>0 then
		showbutton(rbsel,parm^.pb_x,parm^.pb_y)
	else
		showbutton(rbnorm,parm^.pb_x,parm^.pb_y);
		
	text(parm^.pb_x+char_w*3, parm^.pb_y+12,free_string[parm^.pb_obj]);
	
	DrawRadio:=parm^.pr_currstate and NOT(SELECTED);
end;

function DrawCheck( d1, d2 : Pointer; parm: PARMBLKPtr) : Integer;
var	pxyarray:	array_4;
begin
	pxyarray[0]:=parm^.pb_xc; pxyarray[1]:=parm^.pb_yc;
	pxyarray[2]:=parm^.pb_wc; pxyarray[3]:=parm^.pb_hc;
	vs_clip(vdi_handle,0,pxyarray);
	if (parm^.pr_currstate and SELECTED)<>0 then
		showbutton(cbsel,parm^.pb_x,parm^.pb_y)
	else
		showbutton(cbnorm,parm^.pb_x,parm^.pb_y);
	text(parm^.pb_x+char_w*3, parm^.pb_y+13,free_string[parm^.pb_obj]);
	DrawCheck:=parm^.pr_currstate and NOT(SELECTED);
end;

function DrawSpinn( d1, d2 : Pointer; parm: PARMBLKPtr) : Integer;
var	pxyarray:	array_4;
begin
	pxyarray[0]:=parm^.pb_xc; pxyarray[1]:=parm^.pb_yc;
	pxyarray[2]:=parm^.pb_wc; pxyarray[3]:=parm^.pb_hc;
	vs_clip(vdi_handle,0,pxyarray);
	showbutton(cspinn,parm^.pb_x,parm^.pb_y);
	DrawSpinn:=0;
end;

function DrawTitel( d1, d2 : Pointer; parm: PARMBLKPtr) : Integer;
var	pxyarray:	array_4;
begin
	pxyarray[0]:=parm^.pb_xc; pxyarray[1]:=parm^.pb_yc;
	pxyarray[2]:=parm^.pb_wc; pxyarray[3]:=parm^.pb_hc;
	vs_clip(vdi_handle,0,pxyarray);
	text(parm^.pb_x+char_w, parm^.pb_y+13,free_string[parm^.pb_obj]);
	line(parm^.pb_x, parm^.pb_y+char_h, parm^.pb_x+parm^.pb_w, parm^.pb_y+char_h, black);
	DrawTitel:=0;
end;

function DrawFlyer( d1, d2 : Pointer; parm: PARMBLKPtr) : Integer;
var	pxyarray:	array_4;
begin
	pxyarray[0]:=parm^.pb_xc; pxyarray[1]:=parm^.pb_yc;
	pxyarray[2]:=parm^.pb_wc; pxyarray[3]:=parm^.pb_hc;
	vs_clip(vdi_handle,0,pxyarray);
	showbutton(cflyer,parm^.pb_x,parm^.pb_y);
	DrawFlyer:=0;
end;

procedure setuserdef(ptr: AESTreePtr);
var	ob:	AESOBJECTPtr;
	obj, extype:	integer;
	bitbl:		pointer;
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
			ob^.ob_spec.user_blk:=@checkblk;
		end
		
		else if extype=DRADIO then
		begin
			radioblk.ub_code:=@DrawRadio; 
			radioblk.ub_parm:=longint(ob^.ob_spec);
			ob^.ob_type:=G_USERDEF;
			ob^.ob_spec.user_blk:=@radioblk;
		end
		
		else if extype=DSPINN then
		begin
			spinnblk.ub_code:=@Drawspinn; 
			spinnblk.ub_parm:=longint(ob^.ob_spec);
			ob^.ob_type:=G_USERDEF;
			ob^.ob_spec.user_blk:=@spinnblk;
		end

		else if extype=DFLYER then
		begin
			flyerblk.ub_code:=@Drawflyer; 
			flyerblk.ub_parm:=longint(ob^.ob_spec);
			ob^.ob_type:=G_USERDEF;
			ob^.ob_spec.user_blk:=@flyerblk;
		end
		
		else if extype=DTITEL then
		begin
			titelblk.ub_code:=@Drawtitel; 
			titelblk.ub_parm:=longint(ob^.ob_spec);
			ob^.ob_type:=G_USERDEF;
			ob^.ob_spec.user_blk:=@titelblk;
		end
		
	until (ob^.ob_flags AND LASTOB)<>0
end;

procedure get_res_strings(tree : integer;ptr: AESTreePtr);
var	ob: AESOBJECTPtr;
	obj, extype	: integer;
begin
	obj:=0;
	repeat
		inc(obj);
		ob:=@ptr^[obj];
		extype:=ob^.ob_type shr 8;
		
		if (extype=DCHECKBOX) OR  (extype=DRADIO) OR (extype=DTITEL) then
			GetFreeString( ptr, obj, free_string[obj]);
		
	until (ob^.ob_flags AND LASTOB)<>0
end;

function rsrc_init: boolean;
var i:	integer;
var ptr:	pointer; 
begin
	if rsrc_load('TEST_OBJ.RSC')=1 then
	begin
		if color_planes=1 then
    	begin
    	for i:=1 to 5 do
    		init_user_button(i);
		{
			rsrc_gaddr(R_TREE,1,ptr);
			initbutton(1,rbnorm,ptr);
			initbutton(2,rbsel,ptr);
			initbutton(3,cbnorm,ptr);
			initbutton(4,cbsel,ptr);
			initbutton(5,cspinn,ptr);
			initbutton(6,cflyer,ptr);
		}
		end;
		rsrc_init:=TRUE
	end
	else
		rsrc_init:=FALSE
end;		

procedure showicon(ic,x,y,color:integer);
var mymfdbscreen:	MFDB;
	pxyarray:	ARRAY_8;
	colind:	ARRAY_2;
begin
	mymfdbscreen.fd_addr:=NIL;
	pxyarray[0]:=0; pxyarray[1]:=0;
	pxyarray[2]:=20; pxyarray[3]:=20 div color_planes;
	pxyarray[4]:=x; pxyarray[5]:=y;
	pxyarray[6]:=x+20; pxyarray[7]:=y+20 div color_planes;
	colind[0]:=color; colind[1]:=WHITE;
	vrt_cpyfm(vdi_handle,MD_REPLACE,pxyarray,icon[ic],mymfdbscreen,colind);
end;

var
	adress : pointer;
begin
	If init_gem then begin
	if rsrc_init then begin
		graf_mouse( ARROW, Nil);
		rsrc_gaddr(R_TREE,0,adress);
		get_res_strings( 0, adress);
		setuserdef(adress);
		show_dialog(adress);
		run_dialog(adress);
		hide_dialog(adress);
		rsrc_free;
	end;
	exit_gem;
	End;
end.						