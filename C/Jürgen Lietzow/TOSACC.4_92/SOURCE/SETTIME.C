/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/91  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	SETTIME.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ext.h>

#include "tosglob.h"
#include "tosacc.h"

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		Mode( TOOL *tool, int type );

static	time_t	tiTime;
static	int		tiFlag = 0;
static	int		edObj = -1;

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								Save,
								Mode,
								HdlEvent,
							};

/*
*	Save()
*
*	Sichert aktuelle Einstellung
*/

#pragma warn -par

static	int		Save( TOOL *tl, FILE *fp )
{
	if ( fp )
	{
		if ( fwrite( &tiTime, sizeof (time_t), 1L, fp ) == 1L )
			if ( fwrite( &tiFlag, sizeof (int), 1L, fp ) == 1L )
				return ( 0 );
		return ( 1 );
	}
	return ( 0 );
}

#pragma warn .par


/*
*	Atodate()
*
*	transformiert einen Text in das Datum
*/

time_t	Atodate( char *dstr, time_t old )
{
	struct	tm	*temp;
	char		buf[4];

	temp = localtime( &old );

	StrnCpy( buf, dstr, 2 );
	temp->tm_mday = atoi( buf );

	StrnCpy( buf, dstr + 2, 2 );
	temp->tm_mon = atoi( buf ) - 1;

	StrnCpy( buf, dstr + 4, 2 );
	temp->tm_year = atoi( buf );

	return ( mktime( temp ) );
}

/*
*	Atotime()
*
*	transformiert einen Text in die Zeit
*/

time_t	Atotime( char *tstr, time_t old )
{
	struct	tm	*temp;
	char		buf[4];

	temp = localtime( &old );

	StrnCpy( buf, tstr, 2 );
	temp->tm_hour = atoi( buf );

	StrnCpy( buf, tstr + 2, 2 );
	temp->tm_min = atoi( buf );

	StrnCpy( buf, tstr + 4, 2 );
	temp->tm_sec = atoi( buf );

	return ( mktime( temp ) );
}

/*
*	GetTD()
*
*	schreibt das Datum und die Zeit aus <<time_t t>> in das ge”ffnete
*	Tool
*/

void	GetTD( time_t t, char *dstr, char *tstr )
{
	struct	tm	*temp;

	temp = localtime( &t );

	sprintf( dstr, "%02d%02d%02d", (int) temp->tm_mday, (int) temp->tm_mon + 1,
								(int) temp->tm_year );

	sprintf( tstr, "%02d%02d%02d", (int) temp->tm_hour, (int) temp->tm_min,
								(int) temp->tm_sec );
}

/*
*	CloseObj()
*
*	Schliežt ein Editierbares Objekt (Datum/Zeit), und transformiert
*	den Text nach <<time_t>>
*/

static	void	CloseObj( TOOL *tl, int obj )
{
	time_t		t;
	struct time	ti;
	struct date	da;
	struct tm	*temp;

	switch ( obj )
	{
		case CDATE	:	t = Atodate( ObTxt(ObPtr(SETTIME,CDATE)),
								time( NULL ) );
						temp = localtime( &t );
						da.da_year = temp->tm_year + 1900;
						da.da_mon = temp->tm_mon + 1;
						da.da_day = temp->tm_mday;
						setdate( &da );
						t = time( NULL );
						GetTD( t, ObTxt(ObPtr(SETTIME,CDATE)),
								  ObTxt(ObPtr(SETTIME,CTIME)) );
						break;
		case CTIME	:	t = Atotime( ObTxt(ObPtr(SETTIME,CTIME)),
								time( NULL ) );
						temp = localtime( &t );
						ti.ti_min = temp->tm_min;
						ti.ti_hour = temp->tm_hour;
						ti.ti_sec = temp->tm_sec;
						ti.ti_hund = 0;
						settime( &ti );
						t = time( NULL );
						GetTD( t, ObTxt(ObPtr(SETTIME,CDATE)),
								  ObTxt(ObPtr(SETTIME,CTIME)) );
						break;
		case TTIME	:	tiTime = Atotime( ObTxt(ObPtr(SETTIME,TTIME)),
								time( NULL ) );
						GetTD( tiTime, ObTxt(ObPtr(SETTIME,TDATE)),
								  ObTxt(ObPtr(SETTIME,TTIME)) );
						break;
		case TDATE	:	tiTime = Atodate( ObTxt(ObPtr(SETTIME,TDATE)),
								time( NULL ) );
						GetTD( tiTime, ObTxt(ObPtr(SETTIME,TDATE)),
								  ObTxt(ObPtr(SETTIME,TTIME)) );
						break;
		default		:	return;
	}
	if ( !IsEnabled(ObPtr(SETTIME,TIMEON)) )
	{
		Enable(ObPtr(SETTIME,TIMEON));
		RedrawWinObj( &tl->wd, TIMEON, NULL );
	}

	tl->wd.tree[obj].ob_flags &= ~EDITABLE;
	InitEdObj( &tl->wd, TrPtr(SETTIME), -1 );
	RedrawWinObj( &tl->wd, obj, NULL );
	edObj = -1;
}

/*
*	OpenObj()
*
*	Macht ein Datum- oder Zeitfeld editierbar
*/

static	void	OpenObj( TOOL *tl, int obj )
{

	switch ( obj )
	{
		case CDATE	:
		case CTIME	:	if ( edObj >= 0 )
							CloseObj( tl, edObj );
						break;
		case TTIME	:	if ( edObj >= 0 )
							CloseObj( tl, edObj );
						if ( IsSelected(ObPtr(SETTIME,TIMEON)) ||
							 IsEnabled(ObPtr(SETTIME,TIMEON)) )
						{
							Disable(ObPtr(SETTIME,TIMEON));
							Deselect(ObPtr(SETTIME,TIMEON));
							RedrawWinObj( &tl->wd, TIMEON, NULL );
							tiFlag = 0;
						}
						break;
		case TDATE	:	if ( edObj >= 0 )
							CloseObj( tl, edObj );
						if ( IsSelected(ObPtr(SETTIME,TIMEON)) ||
							 IsEnabled(ObPtr(SETTIME,TIMEON)) )
						{
							Disable(ObPtr(SETTIME,TIMEON));
							Deselect(ObPtr(SETTIME,TIMEON));
							RedrawWinObj( &tl->wd, TIMEON, NULL );
							tiFlag = 0;
						}
						break;
		default		:	return;
	}

	tl->wd.tree[obj].ob_flags |= EDITABLE;
	InitEdObj( &tl->wd, TrPtr(SETTIME), obj );
	RedrawWinObj( &tl->wd, obj, NULL );
	edObj = obj;
}

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

#pragma warn -par

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj;
	int		dummy, mstate;
	GRECT	gr;

	if ( evtype & MU_KEYBD )
	{
		switch ( ev->ev_mkreturn )
		{
			case RETURN:
			case ENTER:	if ( edObj < 0 )
							break;
						CloseObj( tl, edObj );
						break;
			default:	obj = FormEvent( &tl->wd, ev );
						if ( obj == TIMEON )
						{
							tiFlag = 1;
							break;
						}
						OpenObj( tl, obj & 0x7fff );
						break;
		}
	}
	if ( evtype & MU_BUTTON )
	{
		obj = FormEvent( &tl->wd, ev );
		do
			graf_mkstate( &dummy, &dummy, &mstate, &dummy );
		while ( mstate );
		if ( obj == TIMEON )
		{
			tiFlag ^= 1;
			
			if ( tiFlag )
				Select(ObPtr(SETTIME,TIMEON));
			else
				Deselect(ObPtr(SETTIME,TIMEON));
			AbsObj( tl->wd.tree, TIMEON, &gr );
			RedrawWinObj( &tl->wd, 0, &gr );
			/*
			if ( IsSelected(ObPtr(SETTIME,TIMEON)) )
				tiFlag = 1;
			else
				tiFlag = 0;
			*/
		}
		else
		{
			if ( edObj >= 0 && obj == edObj )
				CloseObj( tl, obj & 0x7fff );
			else
				OpenObj( tl, obj & 0x7fff );
		}
	}
	return ( 0 );
}

#pragma warn .par

/*
*	Ring()
*
*	Ring!
*/

static	void	Ring( void )
{
	int		i;
	Bell();
	for ( i = 0; i < 10; i++ )
		Vsync();
	Bell();
	for ( i = 0; i < 10; i++ )
		Vsync();
	Bell();
}

/*
*	Mode()
*
*	Wird von TOSACC.C aufgerufen. Bei jedem Timer-Ereignis, bei
*	AC_CLOSE, und bei einem Toolwechsel.
*/

static	int		Mode( TOOL *tl, int type )
{
			time_t	t;
	static	int 	cnt = 0;


	if ( type & MODE_TOPEN )
	{
		t = time( NULL );
		GetTD( t, ObTxt(ObPtr(SETTIME,CDATE)),
		ObTxt(ObPtr(SETTIME,CTIME)) );
		if ( !tiFlag )
		{
			Deselect(ObPtr(SETTIME,TIMEON));
			GetTD( t, ObTxt(ObPtr(SETTIME,TDATE)),
					  ObTxt(ObPtr(SETTIME,TTIME)) );
		}
	}
	if ( type & MODE_TIMER )
	{
		if ( ( type & MODE_TACTIV ) && mainWD.window >= 0 )
		{
			if ( edObj != CTIME && edObj != CDATE )
			{
				t = time ( NULL );

				GetTD( t, ObTxt(ObPtr(SETTIME,CDATE)),
						  ObTxt(ObPtr(SETTIME,CTIME)) );

				RedrawWinObj( &tl->wd, CDATE, NULL );
				RedrawWinObj( &tl->wd, CTIME, NULL );
			}
		}
		if ( !IsSelected(ObPtr(SETTIME,TIMEON)) )
			return ( 0 );

		t = time( NULL );
		if ( cnt )
		{
			if ( t < tiTime )
			{
				cnt = 0;
				return ( 0 );
			}
			if ( --cnt )
				return ( 0 );

			if ( tiTime + 60 >= t )
				cnt = 10;
			else
				cnt = 1;
			Ring();
		}
		else
		{
			if ( t >= tiTime )
			{
				cnt = 10;
				Ring();
			}
		}
	}
	return ( 0 );
}

/*
*	StInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*StInit( FILE *fp, int handle )
{

	ours = handle;

	if ( fp )
	{
		fread( &tiTime, sizeof (time_t), 1L, fp );
		fread( &tiFlag, sizeof (int), 1L, fp );
	}

	if ( tiFlag )
	{
		Select(ObPtr(SETTIME,TIMEON));
		GetTD( tiTime, ObTxt(ObPtr(SETTIME,TDATE)),
				  ObTxt(ObPtr(SETTIME,TTIME)) );
	}

	InitEdObj( &ourTool.wd, TrPtr(SETTIME), -1 );
	return ( &ourTool );
}
