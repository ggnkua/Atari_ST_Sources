/* C-Source Dialog-Handler: MAIN_DIAL;
  Erzeugt durch DIAL_GEN V 1.01 (C) Uwe Kornnagel */

	#include	"L:\DI_GEN_C\MAIN_DIA.H"
	#include	"L:\DI_GEN_C\TEST.H"

/* Diese Variablen sind nur diesem Modul bekannt und kînnen
  nicht von anderen Programmteilen gelesen oder beschrieben werden */
	static int DialDone;  /* != 0 wenn der Dialog verlassen werden soll */
	static int DialExit;  /* RÅckgabewert mit dem der Dialog beendet wurde */
	#define RsRcName  "L:\DI_GEN_C\TEST.RSC" /* Resource-Filename */
	static OBJECT *DialRsc = NULL; /* eigener ResourcePounter */
	static OBJECT *DialTree = NULL; /* Das Dialogibject Selbst */

/* Die folgende Dummyfunktion beendet formal den Dialog */
	static void FinDial( PtrDialpara dp, int DiaWinClosed )
	{
		dp->action += aClose; DialDone = ~0;
		DialExit = dp->objc;
		if( DiaWinClosed ) DialExit = -1;
	}

/* Folgende Funktionen beschreiben die Einzelaktionen
  Hier mÅssen Sie Ihren Code vervollstÑndigen */
	/* Dialog-ExitCode : DIAL_OK  */
	void DoDIAL_OK( PtrDialpara dp )
	{


		dp->action = aDeselect | aDraw;
	}

/* Folgende Funktionen beschreibt den Default-Dialoghandler
  Hier mÅssen Sie ggf. Ihren Code vervollstÑndigen */
	static DialHandler HandleDialog( PtrDialpara dp )
	{
		dp->action = 0;
		switch( dp->message )
		{
			case WinClosed:
				FinDial( dp, 1);
			break;

			case OutsideClick:
			break;

			case ObjcGotCursor:
			break;

			case ObjcLostCursor:
			break;

			case ObjcEditkey:
			break;

			case ObjcEdited:
			break;

			case ObjcSlided:
			break;

			case ObjcPgLeft:
			break;

			case ObjcPgRight:
			break;

			case ObjcArLeft:
			break;

			case ObjcArRight:
			break;

			case ObjcMousemove:
			break;

			case ObjcTimer:
			break;

			case ObjcSelect:
			break;

			case ObjcDblSelect:
			break;

			case ObjcDroped:
			break;

			case ObjcClicked:
			case ObjcDblClicked:
				switch( dp->objc )
				{
				case DIAL_ABBRUCH:
					FinDial( dp, 0 );
				break;

				case DIAL_OK:
					DoDIAL_OK( dp );
				break;

				}
			break;

		}
		return 0;
	}

/* Diese Function schreibt die Infozeile des Dialogs neu,
   falls der Dialog erîffnet ist. */
void MAIN_DIAL_Info( char *newinfo )
{ int win; Dialmode mode; BOOLEAN isopen;
	if( !DialTree ) return;

	DialInfo( DialTree, &mode, &win, &isopen );
	if( isopen && ( win > -1 ))
	{
		SetWinInfo( win, newinfo);
	}
}

/* Diese Function lÑdt bzw. reloziert die Resourcen des Dialogs */
static int InitDialRsc( void )
{ BOOLEAN ok;
	ok = LoadRsc( RsRcName, ( void ** ) &DialRsc );
	if( ok ) return 1; else return 0;
}

/* Diese Function meldet den Dialog bei Magic an */
int InitMAIN_DIAL( void )
{ BOOLEAN ok;
	/* Wenn Dialog schon angemeldet, dann fertig */
	if( DialTree ) return 1;

	if( !DialRsc )
	{
		if( !InitDialRsc() ) return 0;
	}

	DialTree = GaddrRsc( DialRsc, 0, MAIN_DIAL);
	if( !DialTree ) return 0;

	ok = NewDial( DialTree, (DialHandler) HandleDialog );
	if( !ok ) { DialTree = NULL; return 0; }

	return 1;
}

/* Mit dieser Function geben Sie den Dialog und seine Resourcen frei */
void DoneMAIN_DIAL( void )
{
	if( DialRsc )
	{
		if( DialTree )
		{
			DisposeDial( DialTree );
		}
		FreeRsc((void *) DialRsc );
	}
	(void *)DialRsc = (void *)DialTree = NULL;
}

/* Folgende Funktion fÅhrt den kompletten Dialog aus */
int RunMAIN_DIAL( void )
{
	/* falls noch nicht initialsiert dann ... tue es */
	if( !DialTree )
	{
		if( !InitMAIN_DIAL()) return 0;
	}

	OpenDial( DialTree, dNonmodal,
		dInfo,
		DIAL_TITEL,
		-1,
		-1, -1,
		-1, -1,
		"" );

	DialDone = 0;
	while( !DialDone ) CentralDispatcher();

	/* DoneMAIN_DIAL(); */  /* ggf. Dialog u. Rsc freigeben */

	return DialExit;
}

