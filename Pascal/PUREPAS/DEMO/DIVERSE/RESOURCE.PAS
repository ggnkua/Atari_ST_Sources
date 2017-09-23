{ ------------------------------------------------------------ }
{ UNIT  RESOURCES                                              }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ this unit enables the usage of linked-in GEM resource files. }
{ therefore the .RSC-file must be converted into an object     }
{ file using BINOBJ.                                           }
{                                                              }
{                                                              }
{ 1. Execute BINOBJ to create an object file, i.e.             }
{      BINOBJ myrsc.rcs myrsc MyResource                       }
{                                                              }
{ 2. Include the object file into the primary file using the   }
{    $L-directive.                                             }
{                                                              }
{ 3. Declare the entry point for the resource file which must  }
{    be the same identifier used at 1., i.e.                   }
{      procedure  MyResource; external; (*$L myrsc *)          }
{                                                              }
{ 4. Initialize the linked-in resource file:                   }
{      resourcePool := InitResourcePool( @MyResource );        }
{                                                              }
{ 5. now the variable resourcePool can be used to inquire the  }
{    start address of an AESTree:                              }
{      menuTree := GetResource( resourcePool, MYMENU );        }
{      menu_bar( menuTree, 1 );                                }
{                                                              }
{ 6. before program termination you must call FreeResourcePool }
{      FreeResourcePool( resourcePool );                       }
{ ------------------------------------------------------------ }

unit Resources;

interface

uses Gem;

type
	TResource = AESTreePtr;
	TResourcePoolPtr = ^TResourcePool;
	TResourcePool = Pointer;


function	InitResourcePool( unfixedResource : Pointer ) : TResourcePoolPtr;
procedure	FreeResourcePool( pool : TResourcePoolPtr );
function	GetResource( pool : TResourcePoolPtr; poolIndex : Word ) : TResource;


{ ============================================================ }

implementation

{$X+}

{ ------------------------------------------------------------ }
{ these are the maximum numbers of the named data structures   }
{ a resource file can contain.                                 }
{ ------------------------------------------------------------ }

const
	MaxAESObjects = 2730;
	MaxTedinfos = 2340;
	MaxIconBlocks = 1820;
	MaxBitBlocks = 4681;

{ ------------------------------------------------------------ }
{ this variant record allows convenient accessing the resource }
{ file bytewise and also the resource header.                  }
{ ------------------------------------------------------------ }

type
	ResourceFileTypePtr = ^ResourceFileType;
	ResourceFileType = record
		case Integer of
			1:		( resourceHeader :	RSHDR );
			2:		( resourceData :	Array[0..65535] of Byte );
	end;

{ ------------------------------------------------------------ }
{ some data structures to deal with the different components   }
{ of a resource file.                                          }
{ ------------------------------------------------------------ }

	TedinfoArrayPtr = ^TedinfoArray;
	TedinfoArray = Array[0..MaxTedinfos] of TEDINFO;
	IconBlockArrayPtr = ^IconBlockArray;
	IconBlockArray = Array[0..MaxIconBlocks] of ICONBLK;
	BitBlockArrayPtr = ^BitBlockArray;
	BitBlockArray = Array[0..MaxBitBlocks] of BITBLK;
	AESTreePtrArrayPtr = ^AESTreePtrArray;
	AESTreePtrArray = Array[0..MaxAESObjects] of AESTreePtr;

{ ------------------------------------------------------------ }
{ FIXRSC means that the relative addresses of the components   }
{ of the resource file should be fixed to absolute addresses.  }
{ UNFIXRSC is the counteroperation.                            }
{ ------------------------------------------------------------ }

	FixMode = ( FIXRSC, UNFIXRSC );


{ ------------------------------------------------------------ }
{ the gem function rsrc_obfix transforms relative coordinates  }
{ to absolute ones. this procedure works the the other way     }
{ round.                                                       }
{ the low byte of a relative coordinate contains a character-  }
{ distance and the high byte a remaining pixel distance.       }
{ ------------------------------------------------------------ }

procedure	AbsToRelCoords( var coord : Integer; defCharSize : Integer );
var
	px, ch : Integer;
begin
	ch := coord div defCharSize;
	px := coord mod defCharSize;
	coord := ( px shl 8 ) + ch;
end;


{ ------------------------------------------------------------ }
{ since there seem to be some problems using rsrc_obfix we     }
{ will do it ourselves.                                        }
{ ------------------------------------------------------------ }

procedure	RelToAbsCoords( var coord : Integer; defCharSize : Integer );
var
	px, ch : Integer;
begin
	ch := ( coord and $00ff ) * defCharSize;
	px := coord shr 8;
	coord := ch + px;
end;


{ ------------------------------------------------------------ }
{ the procedure FixResourcePool handles, depending on the      }
{ parameter mode, the fixing respectively the un-fixing of the }
{ relative addresses of a resource file by adding or           }
{ substracting the start address of the resource file.         }
{ ------------------------------------------------------------ }

procedure	FixResourcePool( unfixedResource : Pointer; mode : FixMode );
var
	resourceFile : ResourceFileTypePtr;
	resourceHeader : RSHDRPtr;
	tree : AESTreePtr;
	treePool : AESTreePtrArrayPtr;
	tedinfo : TedinfoArrayPtr;
	iconblk : IconBlockArrayPtr;
	bitblk : BitBlockArrayPtr;
	obj, objCnt : Integer;
	defWidth, defHeight, dummy : Integer;
	offset : LongInt;
	objType : Byte;

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
	for obj := 0 to Integer( resourceHeader^.rsh_nted ) - 1 do
	begin
		Inc( LongInt( tedinfo^[obj].te_ptext ), offset );
		Inc( LongInt( tedinfo^[obj].te_ptmplt ), offset );
		Inc( LongInt( tedinfo^[obj].te_pvalid ), offset );
	end;

	iconblk := @resourceFile^.resourceData[resourceHeader^.rsh_iconblk];
	for obj := 0 to Integer( resourceHeader^.rsh_nib ) - 1 do
	begin
		Inc( LongInt( iconblk^[obj].ib_pmask ), offset );
		Inc( LongInt( iconblk^[obj].ib_pdata ), offset );
		Inc( LongInt( iconblk^[obj].ib_ptext ), offset );
	end;

	bitblk := @resourceFile^.resourceData[resourceHeader^.rsh_bitblk];
	for obj := 0 to Integer( resourceHeader^.rsh_nbb ) - 1 do
		Inc( LongInt( bitblk^[obj].bi_pdata ), offset );

	treePool := @resourceFile^.resourceData[resourceHeader^.rsh_trindex];
	for obj := 0 to Integer( resourceHeader^.rsh_ntree ) - 1 do
		Inc( LongInt( treePool^[obj] ), offset );
end;


{ ------------------------------------------------------------ }
{ this procedure start the un-fixing process.                  }
{ ------------------------------------------------------------ }

procedure	FreeResourcePool( pool : TResourcePoolPtr );
begin
	FixResourcePool( pool, UNFIXRSC );
end;


{ ------------------------------------------------------------ }
{ this procedure initializes the resource file and the GEM!    }
{ ------------------------------------------------------------ }

function	InitResourcePool( unfixedResource : Pointer ) : TResourcePoolPtr;
var
	resourceFile : ResourceFileTypePtr;
	resourceHeader : RSHDRPtr;
	treePool : AESTreePtrArrayPtr;
begin
	FixResourcePool( unfixedResource, FIXRSC );
	resourceFile := unfixedResource;
	resourceHeader := @resourceFile^.resourceHeader;
	treePool := @resourceFile^.resourceData[resourceHeader^.rsh_trindex];
	Gem_pb.global[5] := Integer( LongInt( treePool ) shr 16 );
	Gem_pb.global[6] := Integer( treePool );
	InitResourcePool := unfixedResource;
end;


{ ------------------------------------------------------------ }
{ this function returns the address of a specific AESTree of   }
{ the resource file.                                           }
{ ------------------------------------------------------------ }

function	GetResource( pool : TResourcePoolPtr; poolIndex : Word ) : TResource;
var
	resourceFile : ResourceFileTypePtr;
	resourceHeader : RSHDRPtr;
	treePool : AESTreePtrArrayPtr;
begin
	resourceFile := ResourceFileTypePtr( pool );
	resourceHeader := @resourceFile^.resourceHeader;
	treePool := @resourceFile^.resourceData[resourceHeader^.rsh_trindex];
	GetResource := treePool^[poolIndex];
end;


end.

{ ============================================================ }
