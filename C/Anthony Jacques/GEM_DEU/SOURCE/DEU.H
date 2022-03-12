/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   DEU.H - Main doom defines.
*/

/* the includes */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <alloc.h>
#include <dos.h>
/* #include <bios.h> */

#include <aesbind.h>
#include <vdibind.h>

#include "gem-deu.h"

/*
   the version information
*/

#define DEU_VERSION	"5.21"	/* the version number */



/*
   the directory structure is the structre used by DOOM to order the
   data in it's WAD files
*/

typedef struct Directory huge *DirPtr;
struct Directory
{
   long start;			/* offset to start of data */
   long size;			/* byte size of data */
   char name[ 8];		/* name of data block */
};



/*
   The wad file pointer structure is used for holding the information
   on the wad files in a linked list.

   The first wad file is the main wad file. The rest are patches.
*/

typedef struct WadFileInfo huge *WadPtr;
struct WadFileInfo
{
   WadPtr next;			/* next file in linked list */
   char *filename;		/* name of the wad file */
   FILE *fileinfo;		/* C file stream information */
   char type[ 4];		/* type of wad file (IWAD or PWAD) */
   long dirsize;		/* directory size of WAD */
   long dirstart;		/* offset to start of directory */
   DirPtr directory;		/* array of directory information */
};



/*
   the master directory structure is used to build a complete directory
   of all the data blocks from all the various wad files
*/

typedef struct MasterDirectory huge *MDirPtr;
struct MasterDirectory
{
   MDirPtr next;		/* next in list */
   WadPtr wadfile;		/* file of origin */
   struct Directory dir;	/* directory data */
};



/*
   the selection list is used when more than one object is selected
*/

typedef struct SelectionList *SelPtr;
struct SelectionList
{
   SelPtr next;			/* next in list */
   short objnum;		/* object number */
};


/*
   syntactic sugar
*/
typedef short Bool;               /* Boolean data: true or false */


/*
   description of the command line arguments and config file keywords
*/

typedef struct
{
   char *short_name;		/* abbreviated command line argument */
   char *long_name;		/* command line arg. or keyword */
   enum				/* type of this option */
   {
      OPT_BOOLEAN,			/* boolean (toggle) */
      OPT_INTEGER,			/* integer number */
      OPT_STRING,			/* character string */
      OPT_STRINGACC,			/* character string, but store in a list */
      OPT_STRINGLIST,			/* list of character strings */
      OPT_END				/* end of the options description */
   } opt_type;
   char *msg_if_true;		/* message printed if option is true */
   char *msg_if_false;		/* message printed if option is false */
   void *data_ptr;              /* pointer to the data */
} OptDesc;


/*
   the macros and constants
*/

/* name of the configuration file */
#define DEU_CONFIG_FILE		"DEU.INI"

/* name of the log file (debug mode) */
#define DEU_LOG_FILE		"DEU.LOG"

/* convert screen coordinates to map coordinates */
#define MAPX(x)			(OrigX + (short) (((x) - ScrCenterX) / Scale) - vdi_rect[0])
#define MAPY(y)			(OrigY + (short) ((ScrCenterY - (y)) / Scale) - vdi_rect[1])

/* convert map coordinates to screen coordinates */
#define SCREENX(x)		(ScrCenterX + (short) (((x) - OrigX) * Scale) +vdi_rect[0])
#define SCREENY(y)		(ScrCenterY + (short) ((OrigY - (y)) * Scale) +vdi_rect[1])

/* object types */
#define OBJ_THINGS		1
#define OBJ_LINEDEFS		2
#define OBJ_SIDEDEFS		3
#define OBJ_VERTEXES		4
#define OBJ_SEGS		5
#define OBJ_SSECTORS		6
#define OBJ_NODES		7
#define OBJ_SECTORS		8
#define OBJ_REJECT		9
#define OBJ_BLOCKMAP		10

/* boolean constants */
#define TRUE			1
#define FALSE			0

/* half the size of an object (Thing or Vertex) in map coords */
#define OBJSIZE			7


/*
   the interfile global variables
*/

/* from deu.c */
extern Bool  Registered;	/* registered or shareware WAD file? */
extern Bool  NoRegisteredChecks; /* Dont set this one to TRUE! ID will not like you... */
extern Bool  Debug;		/* are we debugging? */
extern Bool  SwapButtons;	/* swap right and middle mouse buttons */
extern Bool  Quiet;		/* don't play a sound when an object is selected */
extern Bool  Quieter;		/* don't play any sound, even when an error occurs */
extern Bool  Expert;		/* don't ask for confirmation for some operations */
extern short InitialScale;	/* initial zoom factor for map */
extern short VideoMode;		/* default video mode for VESA cards */
extern char *BGIDriver;		/* default extended BGI driver */
extern Bool  FakeCursor;	/* use a "fake" mouse cursor */
extern Bool  CirrusCursor;	/* use hardware cursor on Cirrus Logic VGA cards */
extern Bool  Colour2;		/* use the alternate set for things colors */
extern Bool  AdditiveSelBox;	/* additive selection box or select in box only? */
extern short SplitFactor;	/* factor used by the Nodes builder */
extern Bool  Select0;		/* select object 0 by default when switching modes */
extern char *MainWad;		/* name of the main wad file */
extern FILE *logfile;		/* filepointer to the error log */

extern short msgbuf[20];
extern short workstation;
extern short apid;
extern short work_in[11];
extern short work_out[57];
extern OBJECT *menu;

/* from wads.c */
extern WadPtr  WadFileList;	/* list of wad files */
extern MDirPtr MasterDir;	/* the master directory */

/* from edit.c */
extern Bool InfoShown;          /* is the bottom line displayed? */
extern short vdi_rect[4];


/* from gfx.c */
extern short GfxMode;		/* current graphics mode, or 0 for text */
extern float Scale;		/* scale to draw map 20 to 1 */
extern short OrigX;		/* the X origin */
extern short OrigY;		/* the Y origin */
extern short PointerX;		/* X position of pointer */
extern short PointerY;		/* Y position of pointer */
extern short ScrMaxX;		/* maximum X screen coord */
extern short ScrMaxY;		/* maximum Y screen coord */
extern short ScrCenterX;	/* X coord of screen center */
extern short ScrCenterY;	/* Y coord of screen center */

/* from mouse.c */
extern Bool UseMouse;		/* is there a mouse driver? */



/*
   the function prototypes
*/

/* from deu.c */
int main( int, char *[]);
void ParseCommandLineOptions( int, char *[]);
void ParseConfigFileOptions( char *);
void Usage( FILE *);
void Credits( FILE *);
void FunnyMessage( FILE *);
void Beep( void);
void PlaySound( int, int);
void ProgError( char *, ...);
void LogMessage( char *, ...);
void MainLoop( void);

/* from memory.c */
void *GetMemory( size_t);
void *ResizeMemory( void *, size_t);
void FreeMemory( void *);
void huge *GetFarMemory( unsigned long size);
void huge *ResizeFarMemory( void huge *old, unsigned long size);
void FreeFarMemory( void huge *);

/* from wads.c */
void OpenMainWad( char *);
void OpenPatchWad( char *);
void CloseWadFiles( void);
void CloseUnusedWadFiles( void);
WadPtr BasicWadOpen( char *);
void BasicWadRead( WadPtr, void huge *, long);
void BasicWadSeek( WadPtr, long);
MDirPtr FindMasterDir( MDirPtr, char *);
void ListMasterDirectory( FILE *);
void ListFileDirectory( FILE *, WadPtr);
void BuildNewMainWad( char *, Bool);
void WriteBytes( FILE *, void huge *, long);
void CopyBytes( FILE *, FILE *, long);
short Exists( char *);
void DumpDirectoryEntry( FILE *, char *);
void SaveDirectoryEntry( FILE *, char *);
void SaveEntryToRawFile( FILE *, char *);
void SaveEntryFromRawFile( FILE *, FILE *, char *);

/* from levels.c */
void ReadLevelData( short, short); /* SWAP! */
void ForgetLevelData( void); /* SWAP! */
void SaveLevelData( char *); /* SWAP! */
void ReadWTextureNames( void);
void ForgetFTextureNames( void);
void ReadFTextureNames( void);
void ForgetWTextureNames( void);

/* from edit.c */
void EditLevel( short, short, Bool);
void SelectLevel( short *, short *);
void EditorLoop( short, short); /* SWAP! */
void DrawMap( short, short, Bool, short); /* SWAP! */
void CenterMapAroundCoords( short, short);
void GoToObject( short, short); /* SWAP! */

/* from gfx.c */
void InitGfx( void);
Bool SwitchToVGA256( void);
Bool SwitchToVGA16( void);
void TermGfx( void);
void ClearScreen( void);
void SetColor( short);
void DrawMapLine( short, short, short, short);
void DrawMapCircle( short, short, short);
void DrawMapVector( short, short, short , short);
void DrawMapArrow( short, short, unsigned);
void DrawScreenLine( short, short, short, short);
void DrawScreenBox( short, short, short, short);
void DrawScreenBox3D( short, short, short, short);
void DrawScreenBoxHollow( short, short, short, short);
void DrawScreenMeter( short, short, short, short, float);
void DrawScreenText( short, short, char *, ...);
void DrawPointer( Bool);
void SetDoomPalette( short);
short TranslateToDoomColor( short);
unsigned ComputeAngle( short, short);
unsigned ComputeDist( short, short);
void InsertPolygonVertices( short, short, short, short);
void RotateAndScaleCoords( short *, short *, double, double);
#ifdef CIRRUS_PATCH
void SetHWCursorPos( unsigned, unsigned);
void SetHWCursorCol( long, long);
void SetHWCursorMap( char *);
#endif /* CIRRUS_PATCH */

/* from things.c */
short GetThingColour( short);
char *GetThingName( short);
short GetThingRadius( short);
char *GetAngleName( short);
char *GetWhenName( short);

/* from names.c */
char *GetObjectTypeName( short);
char *GetEditModeName( short);
char *GetLineDefTypeName( short);
char *GetLineDefTypeLongName( short);
char *GetLineDefFlagsName( short);
char *GetLineDefFlagsLongName( short);
char *GetSectorTypeName( short);
char *GetSectorTypeLongName( short);

/* from mouse.c */
void CheckMouseDriver( void);
void ShowMousePointer( void);
void HideMousePointer( void);
void GetMouseCoords( short *, short *, short *);
void SetMouseCoords( short, short);
void SetMouseLimits( short, short, short, short);
void ResetMouseLimits( void);
void MouseCallBackFunction( void);

/* from menus.c */
short DisplayMenuArray( short, short, char *, short, short *, char *[ 30], short [30]);
short DisplayMenu( short, short, char *, ...);
short PullDownMenu( short, short, ...);
short InputInteger( short, short, short *, short, short);
short InputIntegerValue( short, short, short, short, short);
void InputNameFromListWithFunc( short, short, char *, short, char **, short, char *, short, short, void (*hookfunc)(short, short, short, short, char *));
void InputNameFromList( short, short, char *, short, char **, char *);
void InputFileName( short, short, char *, short, char *);
Bool Confirm( short, short, char *, char *);
void Notify( short, short, char *, char *);
void DisplayMessage( short, short, char *, ...);
void NotImplemented( void);

/* from objects.c */
void HighlightSelection( short, SelPtr); /* SWAP! */
Bool IsSelected( SelPtr, short);
void SelectObject( SelPtr *, short);
void UnSelectObject( SelPtr *, short);
void ForgetSelection( SelPtr *);
short GetMaxObjectNum( short);
short GetCurObject( short, short, short, short, short); /* SWAP! */
SelPtr SelectObjectsInBox( short, short, short, short, short); /* SWAP! */
void HighlightObject( short, short, short); /* SWAP! */
void DeleteObject( short, short); /* SWAP! */
void DeleteObjects( short, SelPtr *); /* SWAP! */
void InsertObject( short, short, short, short); /* SWAP! */
Bool IsLineDefInside( short, short, short, short, short); /* SWAP - needs Vertexes & LineDefs */
short GetOppositeSector( short, Bool); /* SWAP! */
void CopyObjects( short, SelPtr); /* SWAP! */
Bool MoveObjectsToCoords( short, SelPtr, short, short, short); /* SWAP! */
void GetObjectCoords( short, short, short *, short *); /* SWAP! */
void RotateAndScaleObjects( short, SelPtr, double, double); /* SWAP! */
short FindFreeTag( void); /* SWAP! */
void FlipLineDefs( SelPtr, Bool); /* SWAP! */
void DeleteVerticesJoinLineDefs( SelPtr ); /* SWAP! */
void MergeVertices( SelPtr *); /* SWAP! */
Bool AutoMergeVertices( SelPtr *); /* SWAP! */
void SplitLineDefs( SelPtr); /* SWAP! */
void SplitSector( short, short); /* SWAP! */
void SplitLineDefsAndSector( short, short); /* SWAP! */
void MergeSectors( SelPtr *); /* SWAP! */
void DeleteLineDefsJoinSectors( SelPtr *); /* SWAP! */
void MakeDoorFromSector( short); /* SWAP! */
void MakeLiftFromSector( short); /* SWAP! */
void AlignTexturesY( SelPtr *); /* SWAP! */
void AlignTexturesX( SelPtr *); /* SWAP! */
void DistributeSectorFloors( SelPtr); /* SWAP! */
void DistributeSectorCeilings( SelPtr); /* SWAP! */

/* from editobj.c */
void DisplayObjectInfo( short, short); /* SWAP! */
short DisplayThingsMenu( short, short, char *, ...);
short DisplayLineDefTypeMenu( short, short, char *, ...);
short InputObjectNumber( short, short, short, short);
short InputObjectXRef( short, short, short, Bool, short);
Bool Input2VertexNumbers( short, short, char *, short *, short *);
void EditObjectsInfo( short, short, short, SelPtr);
void CheckLevel( short, short); /* SWAP! */
Bool CheckStartingPos( void); /* SWAP! */
void InsertStandardObject( short, short, short, short); /* SWAP! */
void MiscOperations( short, short, short, SelPtr *); /* SWAP! */
void Preferences( short, short);

/* from nodes.c */
void ShowProgress( short);

/* from textures.c */
void ChooseFloorTexture( short, short, char *, short, char **, char *);
void ChooseWallTexture( short, short, char *, short, char **, char *);
void ChooseSprite( short, short, char *, char *);
void GetWallTextureSize( short *, short *, char *);

/* from swapmem.c */
void InitSwap( void);
void FreeSomeMemory( void);
void ObjectsNeeded( short, ...);


/* end of file */
