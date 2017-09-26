#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDIO.H>
#include	<STDLIB.H>
#include	<STRING.H>

#include	<av.h>
#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"Help.h"
#include	"Rsc.h"

typedef struct
{
	long   magic;   /* 'BGEM' */
	long   size;    /* Gr”že dieser Struktur, derzeit 18 */
	int    release; /* derzeit 6, nie kleiner als 5 */
	int    active;  /* <>0, wenn gerade eine Hilfe angezeigt wird;
                        0  sonst */
	MFORM *mhelp;   /* Zeiger auf Hilfe-Mausform */
	int    dtimer;  /* D„mon-Timer; Default 200ms; ab Release 6 */
}	BGEM;

typedef	struct	_obj_
{
	WORD				Index;
	struct	_obj_	*next;
	BYTE				*Str;
}	ObjBG;

typedef	struct	_grp_
{
	WORD	Index;
	struct	_grp_	*next;
	struct	_obj_	*first;
}	GrpBG;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static BYTE	*BG_GetStr( WORD TreeIdx, WORD ObjIdx );
static BYTE	*BG_Get( WORD TreeIdx, WORD ObjIdx );

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static WORD	BubbleGEM = 0;

static GrpBG	*Grp	= NULL;


WORD	Help_Init( void )
{
	XATTR	Xattr;
	BYTE	*Filename = HELPNAME;
	BYTE	ReadPuf[1024], Puf[1024], *R;
	WORD	GrpIdx, ObjIdx;
	WORD	Ret;
	if(( Ret = ( WORD ) Fxattr( 0, Filename, &Xattr )) == E_OK )
	{
		FILE	*File = fopen( Filename, "r" );
		fgets( ReadPuf, 1023, File );
		while( 1 )
		{
			if( ReadPuf[0] == '#' && ReadPuf[1] != ' ' )
			{
				sscanf( ReadPuf, "#%s %i", Puf, &GrpIdx );
				if( strcmp( Puf, "Dial" ) == 0 )
				{
					GrpBG	*NewGrp = malloc( sizeof( GrpBG ));
					if( !NewGrp )
						return( ENSMEM );
					NewGrp->next = Grp;
					NewGrp->Index = GrpIdx;
					NewGrp->first = NULL;
					Grp = NewGrp;
					while(( R = fgets( ReadPuf, 1023, File )) != NULL )
					{
						if( ReadPuf[0] == '#' && ReadPuf[1] != ' ' )
							break;
						if( ReadPuf[0] == '#' && ReadPuf[1] == ' ' )
						{
							ObjBG	*NewObj = malloc( sizeof( ObjBG ));
							sscanf( ReadPuf, "# %i %[^\n]", &ObjIdx, Puf );
							if( !NewObj )
								return( ENSMEM );
							NewObj->next = NewGrp->first;
							NewGrp->first = NewObj;
							NewObj->Index = ObjIdx;
							NewObj->Str = strdup( Puf );
						}
					}
					if( R )
						continue;
				}
			}
			if( fgets( ReadPuf, 1023, File ) == NULL )
				break;
		}
		fclose( File );
		BubbleGEM = 1;
		return( E_OK );
	}
	return( Ret );
}

WORD	BG_Action( OBJECT *DialogTree, WORD TreeIdx, WORD ObjIdx, WORD x, WORD y, WORD Global[15] )
{
	WORD	AppId, Msg[8];
	BYTE	*Str = NULL;
	BGEM	*Bgem;

	if( !BubbleGEM )
		return( ERROR );

	do
	{
		if( !( DialogTree[ObjIdx].ob_type & 0x0100 ))
			Str = BG_Get( TreeIdx, ObjIdx );
		if( Str )
			break;
	}	while(( ObjIdx = GetParentObject( DialogTree, ObjIdx )) != -1 );

	if( !Str )
		return( ERROR );

	if(( AppId = MT_appl_find( "BUBBLE  ", Global )) < 0 )
	{
		BYTE	*Filename = getenv( "BUBBLEGEM" );
		if( Filename )
			AppId = MT_shel_write( SHW_EXEC, 1, SHW_PARALLEL, Filename, NULL, Global );
		else
			return( ERROR );
	}
	if( AppId < 0 )
		return( ERROR );

	if(( Bgem = ( BGEM * ) SearchCookie( 'BGEM' )) != NULL )
	{
	}

	Msg[0] = BUBBLEGEM_SHOW;
	Msg[1] = Global[2];
	Msg[2] = 0;
	Msg[3] = x;
	Msg[4] = y;
	*( BYTE ** )&( Msg[5] ) = strcpy( Xmalloc( strlen( Str ) + 1, RAM_READABLE ), Str );
	Msg[7] = 0;
	MT_appl_write( AppId, 16, Msg, Global );
	MT_evnt_timer( 100L, Global );
	return( E_OK );
}

static BYTE	*BG_Get( WORD TreeIdx, WORD ObjIdx )
{
	GrpBG	*TmpGrp = Grp;
	ObjBG	*TmpObj = NULL;
	
	while( TmpGrp )
	{
		if( TmpGrp->Index == TreeIdx )
		{
			TmpObj = TmpGrp->first;
			while( TmpObj )
			{
				if( TmpObj->Index == ObjIdx )
				{
					return( strdup( TmpObj->Str ));
				}
				TmpObj = TmpObj->next;
			}
			break;
		}
		TmpGrp = TmpGrp->next;
	}
	return( NULL );
}

WORD	StGuide_Action( OBJECT *DialogTree, WORD TreeIdx, WORD Global[15] )
{
	WORD	i = 0;
	BYTE	Puf[256], *Str = NULL;

	if( !BubbleGEM )
		return( ERROR );

	if( DialogTree )
	{
		do
		{
			if( DialogTree[i].ob_type & 0x0100 )
			{
				Str = BG_Get( TreeIdx, i );
				break;
			}
		}
		while( !( DialogTree[i++].ob_flags & LASTOB ));
	}

	strcpy( Puf, ST_GUIDE );

	if( Str )
	{
		strcat( Puf, " " );
		strcat( Puf, Str );
	}
	StGuide( Puf, Global );
	return( E_OK );	
}

WORD	StGuide_ActionDirect( OBJECT *DialogTree, WORD TreeIdx, WORD Idx, WORD Global[15] )
{
	BYTE	*Str = NULL, Puf[256];

	if( !BubbleGEM )
		return( ERROR );

	Str = BG_Get( TreeIdx, Idx );	

	strcpy( Puf, ST_GUIDE );

	if( Str )
	{
		strcat( Puf, " " );
		strcat( Puf, Str );
	}
	StGuide( Puf, Global );
	return( E_OK );	
}

void	StGuide( BYTE *Puf, WORD Global[15] )
{
	WORD	AppId = -1, Msg[8];
	BYTE	*Tmp;

	if(( AppId = MT_appl_find( "ST-GUIDE", Global )) < 0 )
	{
		BYTE	*Filename = getenv( "STGUIDE" );
		if( Filename )
			AppId = MT_shel_write( SHW_EXEC, 1, SHW_PARALLEL, Filename, "", Global );
	}
	if( AppId < 0 )
	{
		Cconout( '\a' );
		return;
	}

	Tmp = Xmalloc( strlen( Puf ) + 1, RAM_READABLE );
	if( Tmp )
		strcpy( Tmp, Puf );

	Msg[0] = VA_START;
	Msg[1] = Global[2];
	Msg[2] = 0;
	*( BYTE ** )&( Msg[3] ) = Tmp;
	Msg[5] = 0;
	Msg[6] = 0;
	Msg[7] = 0;
	MT_appl_write( AppId, 16, Msg, Global );
}