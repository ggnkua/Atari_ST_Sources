Unit Resource;

Interface

Uses
	Gem;
	
type
	RES_RECT = Record
		x,y,w,h : integer;
	End;

	RES_ADR = Array[0..64] Of Pointer;

procedure	fix_resource(trees : byte; Adr: pointer; VAR a : Res_Adr); 
procedure 	free_resource;

procedure 	hide_dialog(t: AESTreePtr);
procedure 	show_dialog(t: AESTreePtr);
function 	run_dialog(t: AESTreePtr): integer;

procedure 	get_abs_xywh(t: AESTreePtr; obj: integer; VAR Rect: RES_RECT);

procedure 	set_obj_state(t: AESTreePtr; obj, stat: integer);
function 	get_obj_state(t: AESTreePtr; obj: integer): integer;

procedure 	del_obj_flags(t: AESTreePtr; obj, stat: integer);
procedure 	set_obj_flags(t: AESTreePtr; obj, stat: integer);
function 	get_obj_flags(t: AESTreePtr; obj: integer): Integer;

function 	get_obj_x(t: AESTreePtr; obj: integer): integer;
function 	get_obj_y(t: AESTreePtr; obj: integer): integer;
function 	get_obj_w(t: AESTreePtr; obj: integer): integer;
function 	get_obj_h(t: AESTreePtr; obj: integer): integer;

procedure 	set_obj_x(t: AESTreePtr; obj, x : integer);
procedure 	set_obj_y(t: AESTreePtr; obj, y : integer);
procedure 	set_obj_w(t: AESTreePtr; obj, w : integer);
procedure 	set_obj_h(t: AESTreePtr; obj, h : integer);

function get_obj_next(t: AESTreePtr; obj : Integer) : Integer;
{ ********************************************************************** }

Implementation
{$X+}

function get_obj_x(t: AESTreePtr; obj: integer): integer;
begin
	get_obj_x:=t^[obj].ob_x;
end;

function get_obj_y(t: AESTreePtr; obj: integer): integer;
begin
	get_obj_y:=t^[obj].ob_y;
end;

function get_obj_w(t: AESTreePtr; obj: integer): integer;
begin
	get_obj_w:=t^[obj].ob_width;
end;

function get_obj_h(t: AESTreePtr; obj: integer): integer;
begin
	get_obj_h:=t^[obj].ob_height;
end;

procedure set_obj_x(t: AESTreePtr; obj, x : integer);
begin
	t^[obj].ob_x := x;
end;

procedure set_obj_y(t: AESTreePtr; obj, y : integer);
begin
	t^[obj].ob_y := y;
end;

procedure set_obj_w(t: AESTreePtr; obj, w : integer);
begin
	t^[obj].ob_width := w;
end;

procedure set_obj_h(t: AESTreePtr; obj, h : integer);
begin
	t^[obj].ob_height := h;
end;
		
Procedure get_abs_xywh(t: AESTreePtr; obj: integer; VAR Rect : RES_RECT);
begin
	with rect do begin
		objc_offset( t, obj, x, y);
		w:= get_obj_w(t, obj)+x;
		h:= get_obj_h(t, obj)+y;
	end;
end;

function get_obj_state(t: AESTreePtr; obj: integer): integer;
begin
	get_obj_state:=t^[obj].ob_state;
end;

procedure set_obj_state(t: AESTreePtr; obj, stat: integer);
begin
	t^[obj].ob_state:=stat;
end;

procedure set_obj_flags(t: AESTreePtr; obj, stat: integer);
begin
	t^[obj].ob_flags:=t^[obj].ob_flags or stat;
end;

function get_obj_flags(t: AESTreePtr; obj: integer): Integer;
begin
	get_obj_flags := t^[obj].ob_flags;
end;

function get_obj_next(t: AESTreePtr; obj : Integer) : Integer;
begin
  get_obj_next := t^[obj].ob_Next;
end;

procedure del_obj_flags(t: AESTreePtr; obj, stat: integer);
begin
	t^[obj].ob_flags:=t^[obj].ob_flags and (t^[obj].ob_flags xor stat);
end;

procedure hide_dialog(t: AESTreePtr);
Var x, y, w, h : Integer;
begin
	form_center(t,x,y,w,h);
	form_dial(fmd_finish,x,y,w,h,x,y,w,h);
end;

procedure show_dialog(t: AESTreePtr);
Var x, y, w, h : Integer;
begin
	form_center(t,x,y,w,h);
	form_dial(fmd_start,x,y,w,h,x,y,w,h);
	objc_draw(t,0,max_depth,x,y,w,h);
end;

function run_dialog(t: AESTreePtr): integer;
Var Ret : integer;
Begin
	Ret := Form_Do(t, 0);
	set_obj_state(t, ret, get_obj_state(t, ret) AND (NOT SELECTED));
	run_dialog := ret;
End;

type
	TResource = AESTreePtr;
	TResourcePoolPtr = ^TResourcePool;
	TResourcePool = Pointer;

const
	MaxAESObjects = 2730;
	MaxTedinfos = 2340;
	MaxIconBlocks = 1820;
	MaxBitBlocks = 4681;

type
	ResourceHeaderTypePtr = ^ResourceHeaderType;
	ResourceHeaderType = record
		rsh_vrsn :		Word;
		rsh_object :	Word;
		rsh_tedinfo :	Word;
		rsh_iconblk :	Word;
		rsh_bitblk :	Word;
		rsh_frstr :		Word;
		rsh_string :	Word;
		rsh_imdata :	Word;
		rsh_frimg :		Word;
		rsh_trindex :	Word;
		rsh_nobs :		Word;
		rsh_ntree :		Word;
		rsh_nted :		Word;
		rsh_nib :		Word;
		rsh_nbb :		Word;
		rsh_nstring :	Word;
		rsh_nimages :	Word;
		rsh_rssize :	Word;
	end;

	ResourceFileTypePtr = ^ResourceFileType;
	ResourceFileType = record
		case Integer of
			1:		( resourceHeader :	ResourceHeaderType );
			2:		( resourceData :	Array[0..65535] of Byte );
	end;


	TedinfoArrayPtr = ^TedinfoArray;
	TedinfoArray = Array[0..MaxTedinfos] of TEDINFO;
	IconBlockArrayPtr = ^IconBlockArray;
	IconBlockArray = Array[0..MaxIconBlocks] of ICONBLK;
	BitBlockArrayPtr = ^BitBlockArray;
	BitBlockArray = Array[0..MaxBitBlocks] of BITBLK;
	AESTreePtrArrayPtr = ^AESTreePtrArray;
	AESTreePtrArray = Array[0..MaxAESObjects] of AESTreePtr;

	FixMode = ( FIXRSC, UNFIXRSC );

procedure AbsToRelCoords( var coord : Integer; defCharSize : Integer );
var
	px, ch : Integer;
begin
	ch := coord div defCharSize;
	px := coord mod defCharSize;
	coord := ( px shl 8 ) + ch;
end;

procedure RelToAbsCoords( var coord : Integer; defCharSize : Integer );
var
	px, ch : Integer;
begin
	ch := ( coord and $00ff ) * defCharSize;
	px := coord shr 8;
	coord := ch + px;
end;

procedure FixResourcePool( unfixedResource : Pointer; mode : FixMode );
var
	resourceFile : ResourceFileTypePtr;
	resourceHeader : ResourceHeaderTypePtr;
	tree : AESTreePtr;
	treePool : AESTreePtrArrayPtr;
	tedinfo : TedinfoArrayPtr;
	iconblk : IconBlockArrayPtr;
	bitblk : BitBlockArrayPtr;
	obj, objCnt, objType :	Integer;
	defWidth, defHeight, dummy : Integer;
	offset : LongInt;

begin
	offset := LongInt( unfixedResource );
	if mode = UNFIXRSC then
		offset := -offset;
	resourceFile := unfixedResource;
	resourceHeader := @resourceFile^.resourceHeader;
	graf_handle( defWidth, defHeight, dummy, dummy );

	tree := @resourceFile^.resourceData[resourceHeader^.rsh_object];
	for obj := 0 to resourceHeader^.rsh_nobs - 1 do
	begin
		if mode = FIXRSC then
		begin
			RelToAbsCoords( tree^[obj].ob_x, defWidth );
			RelToAbsCoords( tree^[obj].ob_y, defHeight );
			RelToAbsCoords( tree^[obj].ob_width, defWidth );
			RelToAbsCoords( tree^[obj].ob_height, defHeight );
		end
		else
		begin
			AbsToRelCoords( tree^[obj].ob_x, defWidth );
			AbsToRelCoords( tree^[obj].ob_y, defHeight );
			AbsToRelCoords( tree^[obj].ob_width, defWidth );
			AbsToRelCoords( tree^[obj].ob_height, defHeight );
		end;

		objType := tree^[obj].ob_type;
		if ( objType = G_TEXT ) or ( objType = G_BOXTEXT )
				or ( objType = G_FTEXT ) or ( objType = G_FBOXTEXT )
				or ( objType = G_BUTTON ) or ( objType = G_STRING )
				or ( objType = G_TITLE ) or ( objType = G_ICON )
				or ( objType = G_IMAGE ) then
		begin
			Inc( tree^[obj].ob_spec.index, offset );
		end;
	end;

	tedinfo := @resourceFile^.resourceData[resourceHeader^.rsh_tedinfo];
	for obj := 0 to resourceHeader^.rsh_nted - 1 do
	begin
		Inc( LongInt( tedinfo^[obj].te_ptext ), offset );
		Inc( LongInt( tedinfo^[obj].te_ptmplt ), offset );
		Inc( LongInt( tedinfo^[obj].te_pvalid ), offset );
	end;

	iconblk := @resourceFile^.resourceData[resourceHeader^.rsh_iconblk];
	for obj := 0 to resourceHeader^.rsh_nib - 1 do
	begin
		Inc( LongInt( iconblk^[obj].ib_pmask ), offset );
		Inc( LongInt( iconblk^[obj].ib_pdata ), offset );
		Inc( LongInt( iconblk^[obj].ib_ptext ), offset );
	end;

	bitblk := @resourceFile^.resourceData[resourceHeader^.rsh_bitblk];
	for obj := 0 to resourceHeader^.rsh_nbb - 1 do
		Inc( LongInt( bitblk^[obj].bi_pdata ), offset );

	treePool := @resourceFile^.resourceData[resourceHeader^.rsh_trindex];
	for obj := 0 to resourceHeader^.rsh_ntree - 1 do
		Inc( LongInt( treePool^[obj] ), offset );
end;

procedure FreeResourcePool( pool : TResourcePoolPtr );
begin
	FixResourcePool( pool, UNFIXRSC );
end;

function InitResourcePool( unfixedResource : Pointer ) : TResourcePoolPtr;
var
	resourceFile : ResourceFileTypePtr;
	resourceHeader : ResourceHeaderTypePtr;
	treePool : AESTreePtrArrayPtr;
begin
	FixResourcePool( unfixedResource, FIXRSC );
	resourceFile := unfixedResource;
	resourceHeader := @resourceFile^.resourceHeader;
	treePool := @resourceFile^.resourceData[resourceHeader^.rsh_trindex];
	GEM_pb.global[5] := Word( LongInt( treePool ) shr 16 );
	GEM_pb.global[6] := Word( treePool );
	InitResourcePool := unfixedResource;
end;

function GetResource( pool : TResourcePoolPtr; poolIndex : Word ) : TResource;
var
	resourceFile : ResourceFileTypePtr;
	resourceHeader : ResourceHeaderTypePtr;
	treePool : AESTreePtrArrayPtr;
begin
	resourceFile := ResourceFileTypePtr( pool );
	resourceHeader := @resourceFile^.resourceHeader;
	treePool := @resourceFile^.resourceData[resourceHeader^.rsh_trindex];
	GetResource := treePool^[poolIndex];
end;

Var
	Rsc_Adr_ptr : TResourcePool;

Procedure Free_Resource;
Begin
	FreeResourcePool( Rsc_Adr_ptr );
End;


Procedure Fix_Resource( Trees : byte; Adr: pointer; VAR a : Res_Adr); 
var	i : byte;
Begin 
	Rsc_Adr_ptr := InitResourcePool( Adr );
	For i:= 0 to Trees do
		a[i] := GetResource( Rsc_Adr_ptr , i );
End;

End.