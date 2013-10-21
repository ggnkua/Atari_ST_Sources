Unit Utility;
interface
Uses Gem, Tos;
{$X+}

Var
	vdi_handle, aes_handle 	: integer;
	apID    				: integer;
	work_in  				: workin_array;
	work_out 				: workout_array;
	color_planes 			: integer;
	
	char_w,char_h,
	box_w,box_h,
	desk_x,desk_y,
	desk_w,desk_h 			: integer;

procedure 	exit_gem;
function 	init_gem : Boolean;

function 	m_inside( x, y, w, h: integer): boolean;
procedure 	m_state( VAR x, y, butt, key: integer);
procedure 	m_stopp( x, y: integer);
procedure 	m_wait( button: byte);
function 	m_key : byte;
procedure 	m_show;
procedure 	m_hide;
procedure 	m_shape( shape: byte);
procedure 	m_user_shape( ptr: pointer);

procedure 	clip(clipflag, x, y, w, h: integer);
procedure 	deffill(col, typ, style: integer);
procedure 	deftext(col, style, size: integer);
procedure 	graphmode( mode: integer);

procedure 	box(x, y, w, h , col: integer);
procedure 	line(x1, y1, x2, y2 , col: integer);
procedure 	print_at(x, y : integer; str: string);
procedure 	text(x, y : integer; str: string);

procedure 	text_center(x, y, w, h: integer; str: string);
procedure 	box_normal(x, y, w, h: integer);
procedure 	box_shaddow(x, y, w, h: integer);
procedure 	box_invert(x, y, w, h: integer);
procedure 	box_text_normal(x, y, w, h: integer; str: string);
procedure 	box_text_shaddow(x, y, w, h: integer; str: string);

Procedure 	button(x, y, w, h :integer; str: string);
Procedure 	button_Invert(x, y, w, h: integer);

function 	max( x, y : longint) : longint ; external; {$L max}
function 	min( x, y : longint) : longint ; external; {$L min}
function 	add( x, y : longint) : longint ; external; {$L add}
function 	sub( x, y : longint) : longint ; external; {$L sub}

function 	getticks: longint;
function 	hi_str(wert:pointer): integer;
function 	lo_str(wert:pointer):integer;
function 	min_max( num , lo_num, Hi_num : longint) : longInt;
function 	xy_point(x, y, xaxel : longint) : longint;

function 	int_to_str(w:integer):string;
function 	str_to_Int( s: string): integer;
function 	bin_dec( s: string) : integer;
function 	dec_bin( v: word) : String;
Function 	btst( a : integer; bit : byte ): integer;

function 	space( num : byte; c : char): string;
function 	upper_str( a: string) : string;
function 	lower_str( a: string) : string;
function 	upper_char( b : char ) : char;
function 	nice_str( a: string) : string;
function 	digital( num: longInt): string;

procedure 	kryptering(Var s: string; key : word);

implementation

function getticks: longint;
var	oldsupstack:longint;
begin
	oldsupstack:=super(nil);
	getticks:=longint(pointer($4BA)^); 
	super(pointer(oldsupstack));
end;

function hi_str(wert:pointer): integer;
begin
	hi_str:=longint(wert) div 65536;
end;

function lo_str(wert:pointer):integer;
begin
	lo_str:=longint(wert) mod 65536;
end;

function digital( num: LongInt): string;
var s:	string;
	i:	Integer;
begin
	str(num,s);
	for i:=1 to length(s) do
		if (s[i]>='0') and (s[i]<='9') then
			s[i]:=chr(ord(s[i])-32);
	digital:=s;
end;

procedure kryptering(Var s: string; key : word);
var i : word;
Begin
	For i:=1 to length(s) do
		s[i]:= Chr(ord(s[i]) XOR Key);
End;

function int_to_str(w:integer):string;
var	s:	string;
begin
	str(w,s);
	int_to_str:=s;
end;

function str_to_Int( s: string): integer;
var	i,res: integer;
begin
	val(s, i, res);
	if res = 0 then
		str_to_Int:=i
	Else
		str_to_Int := 0;
end;

Function Space( num : byte; c : char): string;
var	s : string;
	i : byte;
Begin
	s:='';
	for i:= 1 to num do
		s:=s+c;
	Space := S;
End;

function bin_dec( s: string) : integer;
var i, j, k : integer;
Begin
	j:=1;
	k:=0;
	For i:= length(s) downto 1 do begin
		inc(j,j);
		if str_To_Int(s[i])=1 then 
			Inc( k, j);
	end;
	bin_dec := k DIV 2;
End;

function dec_bin( v: word) : String;
var i, k : word;
	s : string;
	j : longint;
	bin_tal : array[0..16] of longint; 
Begin
	j:=1;

	For i:= 1 to 16 do begin
		inc(j,j);
		
		bin_tal[i]:= j DIV 2;
	end;
	for i:= 1 to 16 do
		if v>=bin_tal[i] then
			s:=space(i,'0');
	j:=0;
	for i:=length(s) downto 1 do begin
		inc(j);
		if v>=bin_tal[i] then begin
			s[j]:='1';
			dec( v, bin_tal[i]);
		end;
	end;
	dec_bin := s;
End;

Function btst( a : integer; bit : byte ): integer;
Var s,d : string;
	i : integer;
Begin
	s := Dec_Bin( a );
	d:='';
	for i:= length(s) downto 1 do begin
		d:=d+s[i];
	end;
	if d[bit+1] = '1' then
		btst := -1
	Else
		btst := 0;
End;

Function Min_Max( Num , Lo_num, Hi_num : longint) : LongInt;
Begin
	Min_Max := Max( Min( Num, Hi_num), Lo_num);
End;

Function xy_point(x, y, xaxel : longint) : longint;
Begin
	xy_point:= (y*xaxel+x)-xaxel;
End;

Function Upper_Str( a: string) : String;
var i : integer;
	b : char;
Begin
	For i:= 1 to length(a) do Begin
		b:=a[i];
		if (b >= 'a') then begin 

			if b = 'Ç' then
				b:='ê';
			if b = 'Å' then
				b:='ö';
			if b = 'Ü' then
				b:='è';
			if b = 'Ñ' then
				b:='é';
			if b = 'î' then
				b:='ô';

			if b<= 'z' then
				b := chr(ord(b)-32);
			a[i]:=b;
		end;
	end;
	Upper_Str := a;
End;

Function Lower_Str( a: string) : String;
var i : integer;
	b : char;
Begin
	For i:= 1 to length(a) do Begin
		b:=a[i];
		if (b >= 'A') then begin 

			if b = 'ê' then
				b:='Ç';
			if b = 'ö' then
				b:='Å';
			if b = 'è' then
				b:='Ü';
			if b = 'é' then
				b:='Ñ';
			if b = 'ô' then
				b:='î';

			if b<= 'Z' then
				b := chr(ord(b)+32);
			a[i]:=b;
		end;
	end;
	Lower_Str := a;
End;

Function Upper_char( b : char ) : char;
Begin
		if (b >= 'a') then begin 

			if b = 'Ç' then
				b:='ê';
			if b = 'Å' then
				b:='ö';
			if b = 'Ü' then
				b:='è';
			if b = 'Ñ' then
				b:='é';
			if b = 'î' then
				b:='ô';

			if b<= 'z' then
				b := chr(ord(b)-32);
		end;
	Upper_Char := B;
End;

Function Nice_Str( a: string) : String;
var i: integer;
Begin
	a := Lower_Str( a );
	For i:= 0 to length(a) do 
	Begin
		if (a[i]=' ') OR (i=0) OR (a[i]='(') OR (a[i]='"') OR (a[i]='<') then
			a[i+1] := Upper_char(a[i+1]);
	End;
	Nice_str := a;
End;

Var Xy_Array : Array_4;

Procedure exit_gem;
begin
	v_clsvwk( vdi_Handle );
	appl_exit;
end;

Function init_gem : Boolean;
var
	i : Integer;
begin
	apID := appl_init;
	if apID >= 0 then
	begin
		aes_Handle := graf_handle( char_W, char_H, box_W, box_H );
		work_In[0] := aes_Handle;
		for i := 1 to workin_max - 1 do
			work_In[i] := 1;
		work_In[10] := 2;
		
		v_opnvwk( work_In, Vdi_Handle, work_Out );
		
		Color_Planes := Length(Dec_Bin(work_out[13]-1));

		Wind_Get(0, WF_FULLXYWH, desk_x, desk_y, desk_w, desk_h);

		if Vdi_Handle <= 0 then
		begin
			appl_exit;
			init_gem := False;
		end
		else
			init_gem := True;
	end
	else
		init_gem := False;
end;

Function m_inside( x, y, w, h : Integer): Boolean;
var xx, yy, bb, ss : integer;
Begin
	Evnt_Mouse(0, desk_X, desk_Y, desk_W, desk_H, xx, yy, bb, ss);
	m_Inside:=(xx>=x) AND (xx<=x+w) AND (yy>=y) AND (yy<=y+h);
End;

Procedure m_state( Var x, y, butt, Key : Integer);
Begin
	Evnt_Mouse(0, desk_X, desk_Y, desk_W, desk_H, x, y, butt, Key);
End;

Procedure m_stopp( x, y: Integer);
var xx, yy, bb, ss : integer;
Begin
	Repeat
		Evnt_Mouse(0, desk_X, desk_Y, desk_W, desk_H, xx, yy, bb, ss);
	Until (xx<>x) OR (yy<>y);
End;

Procedure m_wait( Button : Byte);
var xx, yy, bb, ss : integer;
Begin
	Repeat
		Evnt_Mouse(0, desk_X, desk_Y, desk_W, desk_H, xx, yy, bb, ss);
	Until bb = Button;
End;

Function m_key : Byte;
var xx, yy, bb, ss : integer;
Begin
	Evnt_Mouse(0, desk_X, desk_Y, desk_W, desk_H, xx, yy, bb, ss);
	m_Key := bb;
End;

Procedure m_show;
Begin
	Graf_Mouse(M_ON,Nil);
End;

Procedure m_hide;
Begin
	Graf_Mouse(M_OFF, Nil);
End;

Procedure m_user_shape( Ptr : Pointer);
Begin
	Graf_Mouse(255, Ptr);
End;

Procedure m_shape( Shape : Byte);
Begin
	If (Shape<=7) AND (Shape>=0) Then
		Graf_Mouse(Shape, NIL);
End;

Procedure set_xyarray( x,y,w,h : integer);
Begin
	Xy_Array[0]:=x;
	Xy_Array[1]:=y;
	Xy_Array[2]:=w+x;
	Xy_Array[3]:=h+y;
End;

Procedure clip(ClipFlag, x, y, w, h : Integer);
Begin
	Set_XyArray(x, y, w, h);
	Vs_Clip(vdi_handle, ClipFlag, Xy_Array);
End;

Procedure Deffill(Col, Typ, Style : Integer);
Begin
	vsf_interior(vdi_handle, Typ);
	vsf_style(vdi_handle, Style);
	vsf_color(vdi_handle, Col);
End;

Procedure Deftext(Col, Style, Size : Integer);
Begin
	vst_color(vdi_handle, Col);
	vst_effects(vdi_handle, Style );
	Vst_Height(vdi_handle, Size, Char_w, Char_h,Box_w,Box_h);
End;

Procedure GraphMode( Mode : Integer);
Begin
	vswr_mode(vdi_Handle, Mode);
End;

procedure box(x, y, w, h , col: Integer);
Var Line_Array : Ptsin_Array;
Begin
	Line_Array[0]:=x;	Line_Array[1]:=y;
	Line_Array[2]:=x+w; Line_Array[3]:=y;
	Line_Array[4]:=x+w;	Line_Array[5]:=y+h;
	Line_Array[6]:=x;	Line_Array[7]:=y+h;
	Line_Array[8]:=x;	Line_Array[9]:=y;
	vsl_color(vdi_handle, Col);
	v_pline(vdi_handle, 5, Line_array);
End;

procedure line(x1, y1, x2, y2 , col: Integer);
Var Line_Array : Ptsin_Array;
Begin
	Line_Array[0]:=x1;	Line_Array[1]:=y1;
	Line_Array[2]:=x2;	Line_Array[3]:=y2;
	vsl_color(vdi_handle, Col);
	v_pline(vdi_handle, 2, Line_array);
End;

Procedure print_at(x, y : Integer; Str : String);
Begin
	v_gtext(vdi_handle, x*Char_w-Char_w-2, y*Char_h+1, str);
End;

Procedure text(x, y : Integer; Str : String);
Begin
	v_gtext(vdi_handle, x-2, y+1, str);
End;

Procedure text_center(x, y, w, h : integer; Str : String);
var a,b : integer;
Begin
	a:=w DIV 2 - ( Length(Str) * Char_W ) DIV 2;
	b:=( h DIV 2 ) + Char_h DIV 2;
	v_gtext(vdi_handle, x+a-2, y+b+1, str);
End;

Procedure box_normal(x, y, w, h : Integer);
Begin 
	Set_XyArray(x,y,w,h);
	vr_recfl(vdi_handle , xy_array);
	v_bar( vdi_handle, xy_array); 
End;

Procedure box_shaddow(x, y, w, h : Integer);
Begin
	Deffill(Black,1,0); 
	Set_XyArray(x+2,y+2,w-2,h-2);
	vr_recfl (vdi_handle, XY_Array);
	Deffill(White,1,0);
	box_Normal(x, y, w-2, h-2);
	Set_XyArray(x,y,w-2,h-2);
	Deffill(Black,0,0);	
	v_bar(vdi_handle, XY_Array);
End;

Procedure box_Invert(x, y, w, h : Integer);
Begin
	m_hide;
	vswr_mode(vdi_handle,3);
	Deffill(Black,1,0); 
	Set_XyArray(x,y,w,h);
	vr_recfl(vdi_handle, XY_Array);	
	vswr_mode(vdi_handle,0);
	m_Show;
End;

Procedure box_text_normal(x, y, w, h : integer; Str : String);
Begin
	Deffill(Black,0,0);
	box_Normal(x,y,w,h);
	text_Center(x, y, w, h, Str);
End;

Procedure box_text_shaddow(x, y, w, h : integer; Str : String);
Begin
	box_Shaddow(x,y,w+2,h+2);
	text_Center(x, y, w, h, Str);
End;

Procedure button(x, y, w, h : Integer; Str : String);
Var Line_Array : Ptsin_Array;
Begin
	Line_Array[0]:=x+2+w-4;	Line_Array[1]:=y+2;
	Line_Array[2]:=x+2; 	Line_Array[3]:=y+2;
	Line_Array[4]:=x+2; 	Line_Array[5]:=y+2+h-4;
	box_text_shaddow(x, y, w, h, Str);
	vsl_color(vdi_handle, 1);
	v_pline( vdi_handle, 3, Line_array);
End;

Procedure button_Invert(x, y, w, h : Integer);
Begin
	m_Hide;
	vswr_mode(vdi_handle,3);
	Deffill(Black,1,0); 
	Set_XyArray(x+3,y+3,w-5,h-5);
	vr_recfl (vdi_handle, XY_Array);	
	vswr_mode(vdi_handle,0);
	m_Show;
End;

end.