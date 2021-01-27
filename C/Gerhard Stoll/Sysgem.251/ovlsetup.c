/* -------------------------------------------------------------------- *
 * Module Version       : 2.00                                          *
 * Author               : Gerhard Stoll                                 *
 * Programming Language : Pure-C                                        *
 * Copyright            : (c) 2000, Gerhard Stoll, 67547 Worms          *
 * -------------------------------------------------------------------- */

#include "kernel.h"
#include <portab.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>
#include "ovl.h"
#include "rsm\sgemovl.h"

#include <types2b.h>

VOID init_SysGem(VOID);

/* -------------------------------------------------------------------- */
/* Externe Variablen																										*/

EXTERN BYTE file[300];
EXTERN OBJECT *SetUp_Tree;

/* -------------------------------------------------------------------- */
/* Interne Variablen																										*/

DIALOG *fenster;
WORD Zeichen3D;
WORD RundeKnoepfe;
WORD EigeneEditfelder;
WORD RahmenEditfelder;
WORD Thorsten;
WORD RahmenTextFarbe;
WORD ShortTextFarbe;

/* -------------------------------------------------------------------- */
/* Interne Funktionen																										*/

LOCAL short cdecl handle_exit( DIALOG *dialog, EVNT *events, WORD obj,WORD clicks, void *data );
LOCAL WORD cdecl Handler(EVNT *Evnt);
LOCAL VOID init_dialog(OBJECT *tree);
LOCAL VOID get_dialog(OBJECT *tree);
LOCAL VOID init_default(VOID);
LOCAL VOID Set(BYTE *name, BYTE *val);
LOCAL VOID do_line(BYTE *line);
LOCAL VOID SaveConfigAscii(VOID);

/* -------------------------------------------------------------------- */
/* Defines 																															*/

#define BUF 512
#define LINE 256

/* -------------------------------------------------------------------- */

short cdecl SetUp(INITEVENTHANDLER InitEventHandler)
{
	fenster=wdlg_create(handle_exit,SetUp_Tree,NULL,0,NULL, /* WDLG_BKGD*/ 1 );
	if( fenster )
	{
		if(wdlg_open( fenster, " SysGem Overlay ", NAME + CLOSER + MOVER + BACKDROP, -1, -1, 0, 0L ))
		{
			init_dialog(SetUp_Tree);
			InitEventHandler(Handler);
		}
		else
		{
			wdlg_delete(fenster);
			return 1;
		}
	}

	return 0;
}

/*----------------------------------------------------------------------*/ 
/* Service-Routine fÅr Fensterdialog 																		*/
/* Funktionsergebnis:	0: Dialog schlieûen 1: weitermachen								*/
/*	dialog:					Zeiger auf die Dialog-Struktur											*/
/*	events:					Zeiger auf EVNT-Struktur oder 0L										*/
/*	obj:						Nummer des Objekts oder Ereignisnummer							*/
/*	clicks:					Anzahl der Mausklicks																*/
/*	data:						Zeiger auf zusÑtzliche Daten												*/
/*----------------------------------------------------------------------*/ 

short cdecl handle_exit( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data )
{
	OBJECT	*tree;
	GRECT		rect;

	wdlg_get_tree( dialog, &tree, &rect );	/* Adresse des Baums erfragen */

  if ( obj < 0 )         			/* Ereignis oder Objektnummer? 						*/
  {
     if ( obj == /* HNDL_CLSD */ -3 ) 	/* Closer betÑtigt? 											*/
        return 0;	         		/* beenden 																*/
  }
  else                       	/* ein Objekt ist angewÑhlt worden 				*/
  {
     switch ( obj )          	/* Aktionen einleiten (falls nîtig) 			*/
     {
     		case SETUPOK:					/* Setup Åbernehmen												*/
     			DelState(tree,obj,SELECTED);
     			get_dialog(tree);
     			init_SysGem();
        	return 0;
				case SETUPSPEICHERN:	/* Steup speichern												*/
					get_dialog(tree);
					SaveConfigAscii();
     			init_SysGem();
     			DelState(tree,obj,SELECTED);
     			wdlg_redraw(dialog,&rect,obj,MAX_DEPTH);
				break;
        case SETUPABBRUCH:		/* Setup abbrechen												*/
     			DelState(tree,obj,SELECTED);
        	return 0;
     }
  }
  return 1;	                	/* weitermachen 													*/
}

/*----------------------------------------------------------------------*/ 
/* EvntHandler																													*/

WORD cdecl Handler(EVNT *Evnt)
{
	WORD handle,dummy;
	
	dummy=0;
	switch(Evnt->mwhich)
	{
		case MU_MESAG:
			switch(Evnt->msg[0])
			{
				case WM_TOPPED:
					handle=wdlg_get_handle(fenster);
					wind_set(handle,WF_TOP,dummy,dummy,dummy,dummy);
					Evnt->mwhich &= ~MU_MESAG;
				break;
				case WM_BOTTOMED:
					handle=wdlg_get_handle(fenster);
					wind_set(handle,WF_BOTTOM,dummy,dummy,dummy,dummy);
					Evnt->mwhich &= ~MU_MESAG;
				break;
			}
		break;
	}
	if(wdlg_evnt( fenster, Evnt )==0)
	{
		wdlg_close( fenster, 0, 0 );
		wdlg_delete( fenster );
		return 0;
	}
	return 2;
}

/* -------------------------------------------------------------------- */
/* Dialog  vorbelegen																										*/

VOID init_dialog(OBJECT *tree)
{
	BYTE Zahl[5];
	
	if(Zeichen3D)
		SetState(tree,DDD_DARSTELLUNG,SELECTED);
	else
		DelState(tree,DDD_DARSTELLUNG,SELECTED);
	if(RundeKnoepfe)
		SetState(tree,RUNDEBUTTON,SELECTED);
	else
		DelState(tree,RUNDEBUTTON,SELECTED);
	if(EigeneEditfelder)
		SetState(tree,EIGENEEDIT,SELECTED);
	else
		DelState(tree,EIGENEEDIT,SELECTED);
	if(RahmenEditfelder)
		SetState(tree,RAHMEN,SELECTED);
	else
		DelState(tree,RAHMEN,SELECTED);
	itoa(RahmenTextFarbe,Zahl,10);
	strcpy(tree[FRAMETEXTCOLOR].ob_spec.tedinfo->te_ptext,Zahl);
	itoa(ShortTextFarbe,Zahl,10);
	strcpy(tree[SHORTCUTCOLOR].ob_spec.tedinfo->te_ptext,Zahl);
}

/* -------------------------------------------------------------------- */
/* Dialog Einstellungen auslesen 																				*/

VOID get_dialog(OBJECT *tree)
{
	BYTE Zahl[5];
	
	if(GetState(tree,DDD_DARSTELLUNG,SELECTED))
		Zeichen3D=TRUE;
	else
		Zeichen3D=FALSE;
	if(GetState(tree,RUNDEBUTTON,SELECTED))
		RundeKnoepfe=TRUE;
	else
		RundeKnoepfe=FALSE;
	if(GetState(tree,EIGENEEDIT,SELECTED))
		EigeneEditfelder=TRUE;
	else
		EigeneEditfelder=FALSE;
	if(GetState(tree,RAHMEN,SELECTED))
		RahmenEditfelder=TRUE;
	else
		RahmenEditfelder=FALSE;
	strcpy(Zahl,tree[FRAMETEXTCOLOR].ob_spec.tedinfo->te_ptext);
	RahmenTextFarbe=atoi(Zahl);
	if(RahmenTextFarbe<1 || RahmenTextFarbe>15)
		RahmenTextFarbe=2;
	strcpy(Zahl,tree[SHORTCUTCOLOR].ob_spec.tedinfo->te_ptext);
	ShortTextFarbe=atoi(Zahl);
	if(ShortTextFarbe<1 || ShortTextFarbe>15)
		ShortTextFarbe=2;
}

/* -------------------------------------------------------------------- */
/* Default Einstellungen																								*/

VOID init_default(VOID)
{
	Zeichen3D=1;
	RundeKnoepfe=1;
	RahmenTextFarbe=2;
	ShortTextFarbe=2;
	EigeneEditfelder=0;
	RahmenEditfelder=0;
	Thorsten=0;
	
}

/* -------------------------------------------------------------------- */
/* SysGem Eigenschaften einstellen																			*/

VOID init_SysGem(VOID)
{
	if(Zeichen3D)													/* 3D-Darstellung								*/
		Enable3D();
	else
		Disable3D();
	UseRoundButtons(RundeKnoepfe);
	FrameTextColor(RahmenTextFarbe);
	ShortCutColor(ShortTextFarbe);
	if(EigeneEditfelder)	
		UseOwnEditFields();
	SetMonoEditFrame(RahmenEditfelder);
	if(Thorsten)
		IchBinThorsten();
}

/* -------------------------------------------------------------------- */
/* Kommando auswerten																										*/

VOID Set(BYTE *name, BYTE *val)
{
	INT Wert;

	strupr(name);
	if (!strcmp(name, "ENABLE3D"))					/* 3D-Darstellung							*/
	{
		if (*val == '1')
			Zeichen3D=TRUE;
		else
			Zeichen3D=FALSE;
		return;
	}
	if (!strcmp(name, "USEROUNDBUTTONS"))		/* Runde Ecken								*/
	{
		if (*val == '1')
			RundeKnoepfe=1;
		else
			RundeKnoepfe=0;
		return;
	}
	if (!strcmp(name, "FRAMETEXTCOLOR"))		/* Rahmen Textfarben					*/
	{
		Wert = *val - '0';
		if( *(val+1) >= '0' && *(val+1) <= '9')
		{
			Wert +=10 + ( *(val+1) - '0' );
			if(Wert > 15)
				Wert = 2;
		}
		RahmenTextFarbe=Wert;
		return;
	}
	if (!strcmp(name, "SHORTCUTCOLOR"))			/* Shortcut Farbe							*/
	{
		Wert = *val - '0';
		if( *(val+1) >= '0' && *(val+1) <= '9')
		{
			Wert +=10 + ( *(val+1) - '0' );
			if(Wert > 15)
				Wert = 2;
		}
		ShortTextFarbe=Wert;
		return;
	}
	if (!strcmp(name, "USEOWNEDITFIELDS"))		/* Eigene Eingabefelder 		*/
	{
		if (*val == '1')
			EigeneEditfelder=1;
		else
			EigeneEditfelder=0;
		return;
	}
	if (!strcmp(name, "SETMONOEDITFRAME"))		/* Rahmen um Eingabefelder	*/
	{
		if (*val == '1')
			RahmenEditfelder=1;
		else
			RahmenEditfelder=0;
		return;
	}
	if (!strcmp(name, "ICHBINTHORSTEN"))		/* Thorsten Bergner						*/
	{
		if (*val == '1')
			Thorsten=1;
		else
			Thorsten=0;
		return;
	}
	return;
}

/* -------------------------------------------------------------------- */
/* Zeile der Config-Datei auswerten																			*/
/* Eine Zeile hat folgendes Format z.B. Kommado=Wert										*/

VOID do_line(BYTE *line)
{
	BYTE *cmd;
	BYTE *t;

	while (*line == ' ')										/* Leerzeichen am Anfang Åber-*/
		line++;																/* springen									  */
	if (*line == '#')												/* Kommentar ignorieren				*/
		return;
	if (!*line)															/* Leerzeilen ignorieren			*/
		return;															

	cmd = line;
	for (t = cmd; *t && *t != ' '; t++)			/* '=' Suchen									*/
	{
		if (*t == '=')
		{
			*t++ = 0;
			Set(cmd, t);
			return;
		}
	}
}

/* -------------------------------------------------------------------- */

VOID LoadConfigAscii (const  BYTE *file_name )
{
	BYTE buf[BUF+1], c;
	BYTE line[LINE+1];
	BYTE *from;
	INT count;
  INT  h;
	LONG r;
  LONG fh;

	from=strrchr(file_name,'\\');
	strcpy(from+1,"sgemovl.cnf");
  fh = Fopen ( file_name, FO_READ );
  if ( fh < 0L )
  	return;
  h = (INT)( fh );

	count = 0;
 	buf[BUF] = 0;
	from = &buf[BUF];
	line[LINE] = 0;

	for(;;)
	{
		c = *from++;
		if (!c)
		{
			r = Fread(h, (LONG)BUF, buf);
			if (r <= 0)
				break;
			buf[r] = 0;
			from = buf;
		}
		else
		{
			if (c == '\r')
				continue;
			else
			{
				if (c == '\n')
				{
					line[count] = 0;
					do_line(line);
					count = 0;
				}
				else
				{
					if (count < LINE)
						line[count++] = c;
				}
			}
		}
	}
	if (count)
	{
		line[count] = 0;
		do_line(line);
	}
  Fclose ( h );
  return;
}

/* -------------------------------------------------------------------- */
/* Speichert die Konfigdaten																						*/

VOID SaveConfigAscii(VOID)
{
	BYTE *from;
	BYTE buffer[256];
	WORD h;
	LONG fh;
		
	from=strrchr(file,'\\');
	strcpy(from+1,"sgemovl.cnf");
	fh=Fcreate(file,0);
  if ( fh < 0L )
  	return;
  h = (INT)( fh );
	
	sprintf(buffer,"Enable3D=%i\r\n",Zeichen3D);
	fh=Fwrite(h,strlen(buffer),buffer);

	sprintf(buffer,"UseRoundButtons=%i\r\n",RundeKnoepfe);
	fh=Fwrite(h,strlen(buffer),buffer);

	sprintf(buffer,"UseOwnEditFields=%i\r\n",EigeneEditfelder);
	fh=Fwrite(h,strlen(buffer),buffer);

	sprintf(buffer,"SetMonoEditFrame=%i\r\n",RahmenEditfelder);
	fh=Fwrite(h,strlen(buffer),buffer);

	sprintf(buffer,"IchbinThorsten=%i\r\n",Thorsten);
	fh=Fwrite(h,strlen(buffer),buffer);

	sprintf(buffer,"FrameTextColor=%i\r\n",RahmenTextFarbe);
	fh=Fwrite(h,strlen(buffer),buffer);

	sprintf(buffer,"ShortCutColor=%i\r\n",ShortTextFarbe);
	fh=Fwrite(h,strlen(buffer),buffer);

	Fclose(h);
}