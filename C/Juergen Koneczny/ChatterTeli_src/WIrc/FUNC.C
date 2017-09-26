#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.h>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"IConnect.h"
#include	"Irc.h"
#include	"Popup.h"
#include	"Window.h"
#include	"WIrc\Func.h"


/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern OBJECT	**TreeAddr;
extern WORD	Global[15];
extern WORD	IrcFlags;
extern GRECT	ScreenRect;


/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	ColourTableObj[], ColourTableIdx[], ColourTableRef[];

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/

typedef	struct __free_item__
{
	struct __free_item__	*next;
	GRECT	Pos;
}	FREE_ITEM;
static void	GetFree( FREE_ITEM *FreeItem, GRECT *Curr );
#define	min( a, b )	( a < b ) ? a : b;
#define	max( a, b )	( a > b ) ? a : b;
static WORD	Schnitt( GRECT *p1, GRECT *p2 );

/*-----------------------------------------------------------------------------*/
/* ColourTablePopup                                                            */
/*-----------------------------------------------------------------------------*/
WORD	ColourTablePopup( WORD ColourTable[COLOUR_MAX], WORD Global[15] )
{
	WORD	Ret;
	EVNTDATA	Ev;
	MT_graf_mkstate( &Ev, Global );
	if(( Ret = Popup( TreeAddr[POPUP_COLOURTABLE], 0, Ev.x, Ev.y, Global )) > 0 )
	{
		WORD	i = -1, Colour;
		while( ColourTableObj[++i] != Ret );
		MT_graf_mkstate( &Ev, Global );
		if(( Colour = ColorPopup( ColourTable[ColourTableIdx[i]], 0, Ev.x, Ev.y, Global )) != -1 )
		{
			ColourTable[ColourTableIdx[i]] = Colour;
			return( E_OK );
		}
	}
	return( ERROR );
}

/*-----------------------------------------------------------------------------*/
/* GetFilename                                                                 */
/*-----------------------------------------------------------------------------*/
void	GetFilename( BYTE *Dirname, BYTE *Filename, BYTE **PathR, BYTE **HomePathR, BYTE **DefaultPathR )
{
	BYTE	*Home, *Path, *HomePath = NULL, *DefaultPath = NULL;
	BYTE	DirnameK[256], FilenameK[256];
	LONG	Len, Id, Handle;
	WORD	Flag = 0;
	XATTR	Xattr;
	
	*PathR = NULL;
	*HomePathR = NULL;
	*DefaultPathR = NULL;

	Path = malloc( strlen( "Chatter" ) + 1 + strlen( Dirname ) + 1 + strlen( Filename ) + 1 );
	if( !Path )
		return;
	strcpy( Path, "Chatter" );
	
	Home = getenv( "HOME" );
	if( Home )
	{
		HomePath = malloc( strlen( Home ) + 1 + strlen( Path ) + 1 + strlen( Dirname ) + 1 + strlen( Filename ) + 1 );
		if( !HomePath )
			return;
		strcpy( HomePath, Home );
		if( HomePath[ strlen( HomePath ) -1 ] != '\\' )
			strcat( HomePath, "\\" );

		DefaultPath = malloc( strlen( HomePath ) + strlen( Path ) + 1 + strlen( "defaults" ) + 1 + strlen( Dirname ) + 1 + strlen( Filename ) + 1 );
		if( !DefaultPath )
			return;
		strcpy( DefaultPath, HomePath );
		strcat( DefaultPath, "defaults" );

		if((( Handle = Dopendir( DefaultPath, 0 )) & 0xff000000L ) != 0xff000000L )
		{
			Dclosedir( Handle );
			strcat( DefaultPath, "\\" );
			strcat( DefaultPath, Path );

			if((( Handle = Dopendir( DefaultPath, 0 )) & 0xff000000L ) == 0xff000000L )
				Dcreate( DefaultPath );
			else
				Dclosedir( Handle );

			Len = Dpathconf( DefaultPath, 3 );
			Id = Dpathconf( DefaultPath, 5 );
			strcpy( DirnameK, Dirname );
			strcpy( FilenameK, Filename );
			if( strlen( DirnameK ) > Len || Id == 2 )
				ShortFilename( DirnameK );
			if( strlen( FilenameK ) > Len || Id == 2 )
				ShortFilename( FilenameK );

			strcat( DefaultPath, "\\" );
			strcat( DefaultPath, DirnameK );

			if((( Handle = Dopendir( DefaultPath, 0 )) & 0xff000000L ) == 0xff000000L )
				Dcreate( DefaultPath );
			else
				Dclosedir( Handle );

			strcat( DefaultPath, "\\" );
			strcat( DefaultPath, FilenameK );

			if( Fxattr( 0, DefaultPath, &Xattr ) == E_OK )
			{
				free( HomePath );
				HomePath = NULL;
				free( Path );
				Path = NULL;
				Flag = 1;
			}
		}
		else
		{
			free( DefaultPath );
			DefaultPath = NULL;
		}
		if( Flag == 0 )
		{
			strcat( HomePath, Path );
			if((( Handle = Dopendir( HomePath, 0 )) & 0xff000000L ) == 0xff000000L )
				Dcreate( HomePath );
			else
				Dclosedir( Handle );

			Len = Dpathconf( HomePath, 3 );
			Id = Dpathconf( HomePath, 5 );

			strcpy( DirnameK, Dirname );
			strcpy( FilenameK, Filename );
			if( strlen( DirnameK ) > Len || Id == 2 )
				ShortFilename( DirnameK );
			if( strlen( FilenameK ) > Len || Id == 2 )
				ShortFilename( FilenameK );

			strcat( HomePath, "\\" );
			strcat( HomePath, DirnameK );
			if((( Handle = Dopendir( HomePath, 0 )) & 0xff000000L ) == 0xff000000L )
				Dcreate( HomePath );
			else
				Dclosedir( Handle );

			strcat( HomePath, "\\" );
			strcat( HomePath, FilenameK );

			if( Fxattr( 0, HomePath, &Xattr ) == E_OK )
			{
				free( Path );
				Path = NULL;
				Flag = 1;
			}
		}
	}
	if( Flag == 0 )
	{
		BYTE	ActP[256];
		Dgetpath( ActP, 0 );
		if((( Handle = Dopendir( Path, 0 )) & 0xff000000L ) == 0xff000000L )
			Dcreate( Path );
		else
			Dclosedir( Handle );

		Len = Dpathconf( ActP, 3 );
		Id = Dpathconf( ActP, 5 );

		strcpy( DirnameK, Dirname );
		strcpy( FilenameK, Filename );
		if( strlen( DirnameK ) > Len || Id == 2 )
			ShortFilename( DirnameK );
		if( strlen( FilenameK ) > Len || Id == 2 )
			ShortFilename( FilenameK );

		strcat( Path, "\\" );
		strcat( Path, DirnameK );
		if((( Handle = Dopendir( Path, 0 )) & 0xff000000L ) == 0xff000000L )
			Dcreate( Path );
		else
			Dclosedir( Handle );

		strcat( Path, "\\" );
		strcat( Path, FilenameK );
	}
	*PathR = Path;
	*HomePathR = HomePath;
	*DefaultPathR = DefaultPath;
}

void	GetFilenameX( BYTE *Dirname, BYTE *Filename, BYTE **PathR, BYTE **HomePathR, BYTE **DefaultPathR )
{
	BYTE	*Home, *Path = NULL, *HomePath = NULL, *DefaultPath = NULL;
	BYTE	DirnameK[256], FilenameK[256];
	LONG	Len, Id, Res;
	XATTR	Xattr;
	
	strcpy( DirnameK, Dirname );
	strcpy( FilenameK, Filename );

	Path = malloc( strlen( "Chatter" ) + 1 + strlen( Dirname ) + 1 + strlen( Filename ) + 1 );
	strcpy( Path, "Chatter" );
	Home = getenv( "HOME" );
	if( Home )
	{
		HomePath = malloc( strlen( Home ) + 1 + strlen( Path ) + 1 + strlen( Dirname ) + 1 + strlen( Filename ) + 1 );
		if( !HomePath )
			return;

		strcpy( HomePath, Home );
		if( HomePath[ strlen( HomePath ) -1 ] != '\\' )
			strcat( HomePath, "\\" );
		DefaultPath = malloc( strlen( HomePath ) + 1 + strlen( Path ) + 1 + strlen( "defaults\\" ) + strlen( Dirname ) + 1 + strlen( Filename ) + 1 );
		strcpy( DefaultPath, HomePath );
		strcat( DefaultPath, "defaults" );
		if((( Res = Dopendir( DefaultPath, 0 )) & 0xff000000L ) != 0xff000000L )
		{
			Dclosedir( Res );
			strcat( DefaultPath, "\\" );
			strcat( DefaultPath, Path );
			if((( Res = Dopendir( DefaultPath, 0 )) & 0xff000000L ) == 0xff000000L )
				Dcreate( DefaultPath );
			else
				Dclosedir( Res );
			Len = Dpathconf( DefaultPath, 3 );
			Id = Dpathconf( DefaultPath, 5 );
			if( strlen( DirnameK ) > Len || Id == 2 )
				ShortFilename( DirnameK );
			if( strlen( FilenameK ) > Len || Id == 2 )
				ShortFilename( FilenameK );
			strcat( DefaultPath, "\\" );
			strcat( DefaultPath, DirnameK );
			if( Fxattr( 0, DefaultPath, &Xattr ) != E_OK )
				Dcreate( DefaultPath );
			strcat( DefaultPath, "\\" );
			strcat( DefaultPath, FilenameK );
		}
		else
		{
			free( DefaultPath );
			DefaultPath = NULL;

			strcpy( DirnameK, Dirname );
			strcpy( FilenameK, Filename );
			strcat( HomePath, Path );
			if((( Res = Dopendir( HomePath, 0 )) & 0xff000000L ) == 0xff000000L )
				Dcreate( HomePath );
			else
				Dclosedir( Res );
			Len = Dpathconf( HomePath, 3 );
			Id = Dpathconf( HomePath, 5 );
			if( strlen( DirnameK ) > Len || Id == 2 )
				ShortFilename( DirnameK );
			if( strlen( FilenameK ) > Len || Id == 2 )
				ShortFilename( FilenameK );
			strcat( HomePath, "\\" );
			strcat( HomePath, DirnameK );
			if( Fxattr( 0, HomePath, &Xattr ) != E_OK )
				Dcreate( HomePath );
			strcat( HomePath, "\\" );
			strcat( HomePath, FilenameK );
		}
	}
	else
	{
		BYTE	ActP[256];
		Dgetpath( ActP, 0 );
		strcpy( DirnameK, Dirname );
		strcpy( FilenameK, Filename );
		if((( Res = Dopendir( Path, 0 )) & 0xff000000L ) == 0xff000000L )
			Dcreate( Path );
		else
			Dclosedir( Res );
		Len = Dpathconf( ActP, 3 );
		Id = Dpathconf( ActP, 5 );
		if( strlen( DirnameK ) > Len || Id == 2 )
			ShortFilename( DirnameK );
		if( strlen( FilenameK ) > Len || Id == 2 )
			ShortFilename( FilenameK );
		strcat( Path, "\\" );
		strcat( Path, DirnameK );
		if( Fxattr( 0, Path, &Xattr ) != E_OK )
			Dcreate( Path );
		strcat( Path, "\\" );
		strcat( Path, FilenameK );
		if( HomePath )
			free( HomePath );
		if( DefaultPath )
			free( DefaultPath );
	}

	*PathR = Path;
	*HomePathR = HomePath;
	*DefaultPathR = DefaultPath;
}

void	ShortFilename( BYTE *Filename )
{
	LONG	v = 0;
	WORD	i;

	if( strlen( Filename ) <= 8 )
	{
		WORD	Flag = 0;
		for( i = 0; i < strlen( Filename ); i++ )
		{
			if( Filename[i] == '.' )
			{
				if( Flag == 0 )
					Flag = 1;
				else
					Flag = 2;
			}
		}
		if( Flag != 2 )
			return;
	}
	for( i = 0; i < strlen( Filename ); i++ )
		v += ( i + 1 ) * ( Filename[i] + 128 );
	sprintf( Filename, "%8.8lx", v );
}

void	ShortFileStrCpy( BYTE *Dest, BYTE *Source, WORD Len )
{
	if( strlen( Source ) <= Len )
		strcpy( Dest, Source );
	else
	{
		BYTE	*FilenamePos, *Pos;
		BYTE	*Filename = malloc( Len );
		BYTE	*Save = malloc( strlen( Source ) + 1 );

		if( !Save || !Filename )
		{
			strcpy( Dest, "" );
			return;
		}
		strcpy( Save, Source );
		
		strncpy( Dest, Source, 3 );
		strcpy( Dest + 3, "" );
		strcat( Dest, "...");

		Pos = Source + strlen( Source );
		FilenamePos = Pos;
		while( Pos > Source )
		{
			if( strlen( Pos ) > Len - strlen( Dest ))
				break;
			if( *Pos == '\\' || *Pos == '/' )
				FilenamePos = Pos;
			Pos--;
		}
		strcat( Dest, FilenamePos );
		free( Filename );
	}
}

void	PlaceIntelligent( GRECT *Pos )
{
	if( !( IrcFlags & WINDOW_INTELLIGENT ))
		return;
	else
	{
		WORD	w = GetFirstWindow(), wNext, Type, WinId, Max = 0;
		GRECT	Curr, Screen;
		GRECT	Free[1024];
		FREE_ITEM	*FreeItem = malloc( sizeof( FREE_ITEM )), *Tmp;
		BYTE	*ScreenBorder = getenv( "SCREENBORDER" );

		if( !FreeItem )
			return;
		FreeItem->next = NULL;
		if( ScreenBorder )
		{
			sscanf( ScreenBorder, "%i,%i,%i,%i", &( FreeItem->Pos.g_x ), &( FreeItem->Pos.g_y ), &( FreeItem->Pos.g_w ), &( FreeItem->Pos.g_h ));
			FreeItem->Pos.g_w = ScreenRect.g_w - FreeItem->Pos.g_w - FreeItem->Pos.g_x;
			FreeItem->Pos.g_h = ScreenRect.g_h - FreeItem->Pos.g_h - FreeItem->Pos.g_y;
			FreeItem->Pos.g_x += ScreenRect.g_x;
			FreeItem->Pos.g_y += ScreenRect.g_y;
		}
		else
		{
			FreeItem->Pos.g_x = ScreenRect.g_x;
			FreeItem->Pos.g_y = ScreenRect.g_y;
			FreeItem->Pos.g_w = ScreenRect.g_w;
			FreeItem->Pos.g_h = ScreenRect.g_h;
		}
		Screen.g_x = FreeItem->Pos.g_x;
		Screen.g_y = FreeItem->Pos.g_y;
		Screen.g_w = FreeItem->Pos.g_w;
		Screen.g_h = FreeItem->Pos.g_h;
		while( w != -1 )
		{
			Type = GetTypeWindow( w );
			wNext = GetNextWindow( w );
			if( Type == WIN_CHAT_IRC_CONSOLE || Type == WIN_CHAT_IRC_CHANNEL || Type == WIN_CHAT_IRC_USER || Type == WIN_CHAT_DCC || Type == WIN_CHANNEL_IRC || Type == WIN_NAMES_IRC || Type == WIN_DATA_DCC )
			{
				MT_wind_get_grect( w, WF_CURRXYWH, &Curr, Global );
				GetFree( FreeItem, &Curr );
			}
			w = wNext;
		}
		if( FreeItem && ( IrcFlags & WINDOW_ONLY ))
		{
			Tmp = FreeItem;
			while( Tmp )
			{
				if( Schnitt( &( Tmp->Pos ), Pos ))
				{
					if( Tmp->Pos.g_x < Pos->g_x && Tmp->Pos.g_y < Pos->g_y && Tmp->Pos.g_x + Tmp->Pos.g_w > Pos->g_x + Pos->g_w && Tmp->Pos.g_y + Tmp->Pos.g_h > Pos->g_y + Pos->g_h )
					{
						if( Pos->g_x + Pos->g_w > Screen.g_x + Screen.g_w )
							Pos->g_x = Screen.g_x + Screen.g_w - Pos->g_w - 1;
						if( Pos->g_y + Pos->g_h > Screen.g_y + Screen.g_h )
							Pos->g_y = Screen.g_y + Screen.g_h - Pos->g_h - 1;

						if( Pos->g_x < Screen.g_x )
 							Pos->g_x = Screen.g_x;
						if( Pos->g_y < Screen.g_y )
							Pos->g_y = Screen.g_y;

						while( FreeItem )
						{
							Tmp = FreeItem;
							FreeItem = FreeItem->next;
							free( Tmp );
						}
						return;
					}
				}
				Tmp = Tmp->next;
			}
		}
		if( FreeItem )
		{
			double	Max = 0, Width, Height;
			Tmp = FreeItem;
			while( Tmp )
			{
				if( Tmp->Pos.g_w && Tmp->Pos.g_h )
				{
					Width = (( double ) Tmp->Pos.g_w ) / (( double ) Pos->g_w );
					Height = (( double ) Tmp->Pos.g_h ) / (( double ) Pos->g_h );
					if( Width * Height > Max && Tmp->Pos.g_x + Pos->g_w < Screen.g_x + ScreenRect.g_w && Tmp->Pos.g_y + Pos->g_h < Screen.g_y + ScreenRect.g_h )
					{
						Max = Width * Height;
						if( FreeItem->next )
						{
							if( IrcFlags & WINDOW_TOPLEFT )
							{
								Pos->g_x = Tmp->Pos.g_x;
								Pos->g_y = Tmp->Pos.g_y;
							}
							else
							{
								Pos->g_x = Tmp->Pos.g_x + ( Tmp->Pos.g_w - Pos->g_w ) / 2;
								Pos->g_y = Tmp->Pos.g_y + ( Tmp->Pos.g_h - Pos->g_h ) / 2;
							}
						}
						if( Pos->g_x + Pos->g_w > Screen.g_x + Screen.g_w )
							Pos->g_x = Screen.g_x + Screen.g_w - Pos->g_w - 1;
						if( Pos->g_y + Pos->g_h > Screen.g_y + Screen.g_h )
							Pos->g_y = Screen.g_y + Screen.g_h - Pos->g_h - 1;

						if( Pos->g_x < Screen.g_x )
 							Pos->g_x = Screen.g_x;
						if( Pos->g_y < Screen.g_y )
							Pos->g_y = Screen.g_y;
					}
				}
				Tmp = Tmp->next;
			}
		}
		while( FreeItem )
		{
			Tmp = FreeItem;
			FreeItem = FreeItem->next;
			free( Tmp );
		}
	}
}

static void	GetFree( FREE_ITEM *FreeItem, GRECT *Curr )
{
	FREE_ITEM	*Tmp = FreeItem;
	GRECT	Act;
	while( Tmp )
	{
		if( Schnitt( &( Tmp->Pos ), Curr ))
		{
			FREE_ITEM	*Tmp0 = Tmp;
			Act.g_x = Tmp->Pos.g_x;
			Act.g_y = Tmp->Pos.g_y;
			Act.g_w = Tmp->Pos.g_w;
			Act.g_h = Tmp->Pos.g_h;
/*			if( Tmp->Pos.g_x < Curr->g_x && Tmp->Pos.g_y < Curr->g_y && Tmp->Pos.g_x + Tmp->Pos.g_w > Curr->g_x + Curr->g_w && Tmp->Pos.g_y + Tmp->Pos.g_h > Curr->g_y + Curr->g_h )
*/			{

				FREE_ITEM	*Tmp1 = malloc( sizeof( FREE_ITEM )), *Tmp2 = malloc( sizeof( FREE_ITEM )), *Tmp3 = malloc( sizeof( FREE_ITEM ));
				FREE_ITEM	*Tmp4 = malloc( sizeof( FREE_ITEM )), *Tmp5 = malloc( sizeof( FREE_ITEM )), *Tmp6 = malloc( sizeof( FREE_ITEM )), *Tmp7 = malloc( sizeof( FREE_ITEM ));
				if( !Tmp1 || !Tmp2 || !Tmp3 || !Tmp4 || !Tmp5 || !Tmp6 || !Tmp7 )
					return;
				Tmp7->next = Tmp->next;
				Tmp = Tmp->next;
				Tmp0->next = Tmp1;
				Tmp1->next = Tmp2;
				Tmp2->next = Tmp3;
				Tmp3->next = Tmp4;
				Tmp4->next = Tmp5;
				Tmp5->next = Tmp6;
				Tmp6->next = Tmp7;
				
				Tmp0->Pos.g_x = Act.g_x;
				Tmp0->Pos.g_y = Act.g_y;
				Tmp0->Pos.g_w = Curr->g_x - Act.g_x;
				Tmp0->Pos.g_h = Curr->g_y - Act.g_y;
				Tmp1->Pos.g_x = Curr->g_x;
				Tmp1->Pos.g_y = Act.g_y;
				Tmp1->Pos.g_w = Curr->g_w;
				Tmp1->Pos.g_h = Curr->g_y - Act.g_y;
				Tmp2->Pos.g_x = Curr->g_x + Curr->g_w;
				Tmp2->Pos.g_y = Act.g_y;
				Tmp2->Pos.g_w = Act.g_w - ( Curr->g_x - Act.g_x ) - Curr->g_w;
				Tmp2->Pos.g_h = Curr->g_y - Act.g_y;

				Tmp3->Pos.g_x = Act.g_x;
				Tmp3->Pos.g_y = Curr->g_y;
				Tmp3->Pos.g_w = Curr->g_x - Act.g_x;
				Tmp3->Pos.g_h = Curr->g_h;
				Tmp4->Pos.g_x = Curr->g_x + Curr->g_w;
				Tmp4->Pos.g_y = Curr->g_y;
				Tmp4->Pos.g_w = Act.g_w - ( Curr->g_x - Act.g_x ) - Curr->g_w;
				Tmp4->Pos.g_h = Curr->g_h;

				Tmp5->Pos.g_x = Act.g_x;
				Tmp5->Pos.g_y = Curr->g_y + Curr->g_h;
				Tmp5->Pos.g_w = Curr->g_x - Act.g_x;
				Tmp5->Pos.g_h = Act.g_h - ( Curr->g_y - Act.g_y ) - Curr->g_h;
				Tmp6->Pos.g_x = Curr->g_x;
				Tmp6->Pos.g_y = Curr->g_y + Curr->g_h;
				Tmp6->Pos.g_w = Curr->g_w;
				Tmp6->Pos.g_h = Act.g_h - ( Curr->g_y - Act.g_y ) - Curr->g_h;
				Tmp7->Pos.g_x = Curr->g_x + Curr->g_w;
				Tmp7->Pos.g_y = Curr->g_y + Curr->g_h;
				Tmp7->Pos.g_w = Act.g_w - ( Curr->g_x - Act.g_x ) - Curr->g_w;
				Tmp7->Pos.g_h = Act.g_h - ( Curr->g_y - Act.g_y ) - Curr->g_h;

				{
					FREE_ITEM	*a = Tmp0;
					WORD	i;
					for( i = 0; i <= 7; i++ )
					{
						if( a->Pos.g_w < 0 )
							a->Pos.g_w = 0;
						if( a->Pos.g_h < 0 )
							a->Pos.g_h = 0;
						if( a->Pos.g_x > ScreenRect.g_w )
							a->Pos.g_w = 0;
						if( a->Pos.g_y > ScreenRect.g_h )
							a->Pos.g_h = 0;
						a = a->next;
					}					
				}

				if( Tmp1->Pos.g_w && Tmp1->Pos.g_h )
				{
					if( Tmp2->Pos.g_w && Tmp2->Pos.g_h )
					{
						Tmp1->Pos.g_w += Tmp2->Pos.g_w;
					}
					if( Tmp0->Pos.g_w && Tmp0->Pos.g_h )
					{
						Tmp1->Pos.g_x = Tmp0->Pos.g_x;
						Tmp1->Pos.g_w += Tmp0->Pos.g_w;
					}
				}
				
				if( Tmp3->Pos.g_w && Tmp3->Pos.g_h )
				{
					if( Tmp5->Pos.g_w && Tmp5->Pos.g_h )
					{
						Tmp3->Pos.g_h += Tmp5->Pos.g_h;
					}
					if( Tmp0->Pos.g_w && Tmp0->Pos.g_h )
					{
						Tmp3->Pos.g_y = Tmp0->Pos.g_y;
						Tmp3->Pos.g_h += Tmp0->Pos.g_h;
					}
				}
				if( Tmp4->Pos.g_w && Tmp4->Pos.g_h )
				{
					if( Tmp7->Pos.g_w && Tmp7->Pos.g_h )
					{
						Tmp4->Pos.g_h += Tmp4->Pos.g_h;
					}
					if( Tmp2->Pos.g_w && Tmp2->Pos.g_h )
					{
						Tmp4->Pos.g_y = Tmp2->Pos.g_y;
						Tmp4->Pos.g_h += Tmp2->Pos.g_h;
					}
				}
				if( Tmp6->Pos.g_w && Tmp6->Pos.g_h )
				{
					if( Tmp7->Pos.g_w && Tmp7->Pos.g_h )
					{
						Tmp6->Pos.g_w += Tmp7->Pos.g_w;
					}
					if( Tmp5->Pos.g_w && Tmp5->Pos.g_h )
					{
						Tmp6->Pos.g_x = Tmp5->Pos.g_x;
						Tmp6->Pos.g_w += Tmp5->Pos.g_w;
					}
				}

/*				FREE_ITEM	*Tmp1 = malloc( sizeof( FREE_ITEM )), *Tmp2 = malloc( sizeof( FREE_ITEM )), *Tmp3 = malloc( sizeof( FREE_ITEM ));
				if( !Tmp1 || !Tmp2 || !Tmp3 )
					return;
				Tmp3->next = Tmp->next;
				Tmp = Tmp->next;
				Tmp0->next = Tmp1;
				Tmp1->next = Tmp2;
				Tmp2->next = Tmp3;

				Tmp0->Pos.g_x = Act.g_x;
				Tmp0->Pos.g_y = Act.g_y;
				Tmp0->Pos.g_w = Act.g_w;
				Tmp0->Pos.g_h = Curr->g_y - Act.g_y;
				Tmp1->Pos.g_x = Curr->g_x + Curr->g_w;
				Tmp1->Pos.g_y = Act.g_y;
				Tmp1->Pos.g_w = Act.g_x <= Curr->g_x ? Act.g_w - ( Curr->g_x - Act.g_x + Curr->g_w ) : Act.g_w - ( Act.g_x - Curr->g_x + Curr->g_w );
				Tmp1->Pos.g_h = Act.g_h;
				Tmp2->Pos.g_x = Act.g_x;
				Tmp2->Pos.g_y = Curr->g_y + Curr->g_h;
				Tmp2->Pos.g_w = Act.g_w;
				Tmp2->Pos.g_h = Act.g_y <= Curr->g_y ? Act.g_h - ( Curr->g_y - Act.g_y + Curr->g_h ) : Act.g_h - ( Act.g_y - Curr->g_y + Curr->g_h );
				Tmp3->Pos.g_x = Act.g_x;
				Tmp3->Pos.g_y = Act.g_y;
				Tmp3->Pos.g_w = Curr->g_x - Act.g_x;
				Tmp3->Pos.g_h = Act.g_h;
*/				
			}
		}
		else
			Tmp = Tmp->next;
	}
}

static WORD	Schnitt( GRECT *p1, GRECT *p2 )
{
	WORD	tx, ty, tw, th;
	tw = min( p2->g_x + p2->g_w, p1->g_x + p1->g_w );
	th = min( p2->g_y + p2->g_h, p1->g_y + p1->g_h );
	tx = max( p2->g_x, p1->g_x );
	ty = max( p2->g_y, p1->g_y );
	return(( tw > tx ) && ( th > ty ));
}

