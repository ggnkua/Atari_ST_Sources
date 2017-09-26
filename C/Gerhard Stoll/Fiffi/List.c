#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include	<STDIO.H>
#include	<STRING.H>
#include	<CTYPE.H>
#include	<MT_AES.H>

#include <atarierr.h>

#include "main.h"
#include	"List.h"
#include	"Ftp.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern UWORD	ShowFlag;
extern FILE		*Handle;
extern ULONG	BufLen;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
volatile	WORD	SortDirList;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
int	MakeListItems( STR_ITEM *Items, STR_ITEM *StartItem );
void	SortListItems( STR_ITEM *FirstItem, STR_ITEM *LastItem );

/*----------------------------------------------------------------------------------------*/ 
/* WorkRList                                                                              */
/*----------------------------------------------------------------------------------------*/ 
int	WorkRList( FILE *MsgHandle, FILE *Handle, BYTE **DataPuf, LONG *DataPufLen, LONG *DataPufOffset, STR_ITEM **Items, WORD GemFtpAppId, WORD Flag, WORD Global[15] )
{
	if( *DataPuf )
	{
		if( *DataPufLen == 0 )
		{
			free( *DataPuf );
			return( E_OK );
		}
		else
		{
			WORD		Msg[8], Ret;
			BYTE		*Pos, *Puf, *PufOld;
			STR_ITEM	*TmpItem, *LastItem, *StartItem;
			Puf = *DataPuf;
			Puf[*DataPufLen + *DataPufOffset] = 0;
			if( MsgHandle )
				fwrite( &Puf[*DataPufOffset], sizeof( char ), strlen( &Puf[*DataPufOffset] ), MsgHandle );

			if( !*Items )
				LastItem = NULL;
			else
			{
				LastItem = *Items;
				while( LastItem->next )
					LastItem = LastItem->next;
			}
			StartItem = LastItem;
			PufOld = Puf;
			while(( Pos = strstr( Puf, "\r\n" )) != NULL )
			{
				if( strncmp( Puf, "total ", 6 ))
				{
					TmpItem = malloc( sizeof( STR_ITEM ));
					if( !TmpItem )
						return( ENSMEM );
					TmpItem->str = malloc( Pos - Puf + 1 );
					if( !TmpItem->str )
						return( ENSMEM );
					strncpy( TmpItem->str, Puf, Pos - Puf );
					(TmpItem->str)[Pos - Puf] = 0;

					if( !LastItem )
						*Items = TmpItem;
					else
						LastItem->next = TmpItem;
					LastItem = TmpItem;

					TmpItem->next = NULL;
					TmpItem->selected = 0;
				}
				PufOld = Pos + 2;
				Puf = Pos + 2;
			}
			memmove( *DataPuf, PufOld, Puf + *DataPufLen - PufOld );
			*DataPufOffset = strlen( *DataPuf );
			if( !( Flag & GEMScriptSession ))
			{
				if( !StartItem )
					StartItem = *Items;
				
				if(( Ret = MakeListItems( *Items, StartItem )) != E_OK )
					return( Ret );
			}

			Msg[0] = List_Update;
			Msg[1] = Global[2];
			Msg[2] = 0;
			while( MT_appl_write( GemFtpAppId, 16, Msg, Global ) != 1 );
/*			if( MT_appl_read( -1, 16, Msg, Global ) && 
			    Msg[0] == Abor_Cmd && Msg[1] == GemFtpAppId )
			{
				return( ABORT );
			}	*/

			*DataPufLen = BufLen;
			return( E_OK );
		}
	}
	else
	{
		*DataPuf = malloc( BufLen + 1 );
		if( !( *DataPuf ))
			return( ENSMEM );
		*DataPufLen = BufLen;
		*DataPufOffset = 0;
		return( E_OK );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* MakeListItems                                                                          */
/*----------------------------------------------------------------------------------------*/ 
int	MakeListItems( STR_ITEM *Items, STR_ITEM *StartItem )
{
	STR_ITEM	*TmpItem, *FirstFileItem, *Item;
	BYTE	*Tmp, Puf[512], TmpPuf[512];
	BYTE	T, Z[10], U[32], G[32], M[20], D[3], Y[20], F[64];
	WORD	L;
	LONG	S;
	
	TmpItem = StartItem;
	while( TmpItem )
	{
		if(( TmpItem->str )[1] != ' ' )
		{
/*			if( *( TmpItem->str ) == 'd' )
			
				*( TmpItem->str ) = '';
			if( *( TmpItem->str ) == '-' )
				*( TmpItem->str ) = ' ';	*/

			strcpy( TmpPuf, TmpItem->str );
			free( TmpItem->str );
			memset( Z, 0, 10 );
			memset( U, 0, 32 );
			memset( G, 0, 32 );
			memset( M, 0, 20 );
			memset( D, 0, 3 );
			memset( Y, 0, 20 );
			memset( F, 0, 64 );
			S = 0;
			L = 0;
			sscanf( TmpPuf, "%c%s %i %s %s %li %s %s %s %[^'\n']", &T, Z, &L, U, G, &S, M, D, Y, F );

			/* Anpassung an ftp.zyxel.com */
			if( strlen( F ) == 0 )
			{
				sscanf( TmpPuf, "%c%s %i %s %li %s %s %s %[^'\n']", &T, Z, &L, G, &S, M, D, Y, F );
				*U = 0;
			}

#ifdef	V120
			/* Anpassung an pc11.immunbio.mpg.de (FTP-Server von Windows NT) */
			if( strlen( F ) == 0 && strlen( Y ) == 0 )
			{
				int	i;
				T = '-';
				for( i = 0; i < strlen( TmpPuf ); i++ )
					if( strncmp( &( TmpPuf[i] ), "<DIR>", 5 ) == 0 )
					{
						T = 'd';
						break;
					}
				memset( Z, 0, 10 );
				memset( U, 0, 32 );
				memset( G, 0, 32 );
				memset( M, 0, 20 );
				memset( D, 0, 3 );
				memset( Y, 0, 20 );
				memset( F, 0, 64 );
				if( T == 'd' )
					sscanf( TmpPuf, "%s %s %*s %s", M, Y, F );
				else
					sscanf( TmpPuf, "%s %s %li %s", M, Y, &S, F );
			}
#endif


			sprintf( Puf, "%c %-35s  %9li  %s %2s %5s  %3i %-12s %-12s %s\0x0", T, F, S, M, D, Y, L, U, G, Z );
			TmpItem->str = strdup( Puf );
			if( !TmpItem->str )
				return( ENSMEM );
		}
		TmpItem = TmpItem->next;
	}

	SortFtpDirList( Items );
	return( E_OK );
}

void	SortFtpDirList( STR_ITEM *ItemList )
{
	STR_ITEM	*TmpItem, *FirstFileItem, *Item;
	BYTE	*Tmp;

	if(( SortDirList & SORT_DIR_LIST_ON ) && ( SortDirList & SORT_DIR_LIST_DESKTOP ))
	{
		TmpItem = ItemList;
		while( TmpItem )
		{
			if( *(TmpItem->str ) != 'd' && *(TmpItem->str ) != 'l' )
			{
				Item = TmpItem->next;
				while( Item )
				{
					if( *( Item->str ) == 'd' || *( Item->str ) == 'l' )
					{
						Tmp = Item->str;
						Item->str = TmpItem->str;
						TmpItem->str = Tmp;
						break;
					}
					Item = Item->next;
				}
			}
			TmpItem = TmpItem->next;
		}
	}

	if(( SortDirList & SORT_DIR_LIST_ON ) && ( SortDirList & SORT_DIR_LIST_BYNAME ) && ( SortDirList & SORT_DIR_LIST_BYNAME ))
	{
		FirstFileItem = ItemList;
		while( FirstFileItem )
		{
			if( *(FirstFileItem->str ) == '-' )
				break;
			FirstFileItem = FirstFileItem->next;
		}
		SortListItems( ItemList, FirstFileItem );
		SortListItems( FirstFileItem, NULL );
	}
	if(( SortDirList & SORT_DIR_LIST_ON ) && ( SortDirList & SORT_DIR_LIST_BYNAME ) && !( SortDirList & SORT_DIR_LIST_DESKTOP ))
	{
		SortListItems( ItemList, NULL );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* SortListItems                                                                          */
/*----------------------------------------------------------------------------------------*/ 
void	SortListItems( STR_ITEM *FirstItem, STR_ITEM *LastItem )
{
	STR_ITEM	*Item, *CmpItem;
	BYTE		*Str, *CmpStr, *TmpStr;
	WORD		TmpSlct;

	Item = FirstItem;

	while( Item != LastItem )
	{
		CmpItem = Item->next;
		while( CmpItem != LastItem )
		{
			Str = Item->str + 2;
			CmpStr = CmpItem->str + 2;
			while( !( *Str == ' ' && *( Str + 1) == ' ' ) &&
			       !( *CmpStr == ' ' && *( CmpStr + 1) == ' ' ))
			{
				if( tolower( *Str ) > tolower( *CmpStr ) || 
				  ( tolower( *Str ) == tolower( *CmpStr ) && islower( *Str ) && isupper( *CmpStr )))
				{
					TmpStr = Item->str;
					TmpSlct = Item->selected;
					Item->str = CmpItem->str;
					Item->selected = CmpItem->selected;
					CmpItem->str = TmpStr;
					CmpItem->selected = TmpSlct;
					break;
				}
				if( tolower( *Str ) < tolower( *CmpStr ))
					break;

				Str++;
				CmpStr++;
			}
			CmpItem = CmpItem->next;
		}
		Item = Item->next;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* GetFileName                                                                            */
/*----------------------------------------------------------------------------------------*/ 
WORD	GetFileName( STR_ITEM *Item, BYTE **RetPuf )
{
	BYTE	Puf[512], *Str, c;
	WORD	i = 0;
	Str = Item->str;
	sscanf( Str, "%c %[^'\n']", &c, Puf );

	if(( Str = strstr( Puf, " -> " )) != NULL && c == 'l' )
		*Str = 0;
		
	for( i = 34; i >= 0; i-- )
	{
		if( Puf[i] != ' ' )
			break;
		Puf[i] = 0;
	}

	*RetPuf = strdup( Puf );
	if( !( *RetPuf ))
		return( ENSMEM );
	return( E_OK );
}

/*----------------------------------------------------------------------------------------*/ 
/* GetFileSize                                                                            */
/*----------------------------------------------------------------------------------------*/ 
void	GetFileSize( STR_ITEM *Item, LONG *Puf )
{
	BYTE	*Str;
	Str = Item->str;
	sscanf( &Str[35], "%li", Puf );
}

/*----------------------------------------------------------------------------------------*/ 
/* GetFileNameList                                                                        */
/*----------------------------------------------------------------------------------------*/ 
WORD	GetFileNameList( WORD Flag, STR_ITEM *ItemList, BYTE ***Puf )
{
	STR_ITEM	*Item;
	WORD		n = 0, Ret;
	BYTE		**FileList, *Filename;
	Item = ItemList;
	while( Item )
	{
		if( Item->selected == 1 )
			if( Flag & DIR_ITEM && *( Item->str ) == 'd' || 
			    Flag & FILE_ITEM && *( Item->str ) == '-' ||
			    Flag & LINK_ITEM && *( Item->str ) == 'l' )
				n++;
		Item = Item->next;
	}
	if( n )
	{
		*Puf = malloc(( n + 1 ) * sizeof( BYTE * ));
		if( !( *Puf ))
			return( ENSMEM );
		FileList = *Puf;
		n = 0;
		Item = ItemList;
		while( Item )
		{
			if( Item->selected == 1 )
				if( Flag & DIR_ITEM && *( Item->str ) == 'd' || 
				    Flag & FILE_ITEM && *( Item->str ) == '-' ||
				    Flag & LINK_ITEM && *( Item->str ) == 'l' )
				{
					if(( Ret = GetFileName( Item, &Filename )) != E_OK )
						return( Ret );
					FileList[n] = malloc( strlen( Filename ) + 1 );
					if( !FileList[n] )
						return( ENSMEM );
					strcpy( FileList[n++], Filename );
					free( Filename );
				}
			Item = Item->next;
		}
		FileList[n] = NULL;
	}
	else
		*Puf = NULL;
	return( E_OK );
}
/*----------------------------------------------------------------------------------------*/ 
/* GetFileSizeList                                                                        */
/*----------------------------------------------------------------------------------------*/ 
WORD	GetFileSizeList( WORD Flag, STR_ITEM *ItemList, LONG **Puf )
{
	STR_ITEM	*Item;
	WORD		n = 0;
	LONG		*FileSize;
	Item = ItemList;
	while( Item )
	{
		if( Item->selected == 1 )
			if( Flag & DIR_ITEM && *( Item->str ) == 'd' ||
			    Flag & FILE_ITEM && *( Item->str ) == '-' || 
			    Flag & LINK_ITEM && *( Item->str ) == 'l' )
				n++;
		Item = Item->next;
	}
	if( n )
	{
		*Puf = malloc(( n + 1 ) * sizeof( LONG ));
		if( !( *Puf ))
			return( ENSMEM );
		FileSize = *Puf;
		n = 0;
		Item = ItemList;
		while( Item )
		{
			if( Item->selected == 1 )
				if( Flag & DIR_ITEM && *( Item->str ) == 'd' || 
				    Flag & FILE_ITEM && *( Item->str ) == '-' || 
				    Flag & LINK_ITEM && *( Item->str ) == 'l' )
				{
					if( *( Item->str ) == '-' )
						GetFileSize( Item, &(FileSize[n++]) );
					else
						FileSize[n++] = 0;
				}
			Item = Item->next;
		}
		FileSize[n] = 0;
	}
	else
		*Puf = NULL;
	return( E_OK );
}

/*----------------------------------------------------------------------------------------*/ 
/* DelFileNameList                                                                        */
/*----------------------------------------------------------------------------------------*/ 
void	DelFileNameList( BYTE ***Puf )
{
	BYTE	**FileList;
	WORD	i = 0;
	FileList = *Puf;
	while( FileList[i] )
		free( FileList[i++] );
	free( FileList );
	FileList = NULL;
}