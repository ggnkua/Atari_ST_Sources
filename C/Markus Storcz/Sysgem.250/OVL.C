/* -------------------------------------------------------------------- *
 * Module Version       : 2.00                                          *
 * Author               : Gerhard Stoll                                 *
 * Programming Language : Pure-C                                        *
 * Copyright            : (c) 1999, Gerhard Stoll, 67547 Worms          *
 * -------------------------------------------------------------------- */


#include "kernel.h"
#include <portab.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>
#include "ovl.h"
#include "rsm\sgemovl.h"


/* -------------------------------------------------------------------- */

BYTE file[300];
RSC_H RscHandle;
OVL2RSM Overlay;
RSM2OVL *Rsm;
OBJECT *SetUp_Tree;

/* -------------------------------------------------------------------- */

EXTERN WORD cdecl SetUp(INITEVENTHANDLER InitEventHandler);
EXTERN VOID init_default(VOID);
EXTERN VOID init_SysGem(VOID);
EXTERN VOID LoadConfigAscii(const  BYTE *file_name );

/* -------------------------------------------------------------------- */
/* Neue AES Funktionen																									*/

EXTERN void init_naes(VOID);

/* -------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

EXTERN VOID draw_box_Area ( OBJECT *Objc, GRECT *Area );
EXTERN VOID draw_radio_Area ( OBJECT *Objc, GRECT *Area );
EXTERN VOID draw_listbox_Area ( OBJECT *Objc, GRECT *Area );

EXTERN BOOL ValidShortcut ( BYTE ch );
EXTERN VOID MakeShortCut ( USERB *ub );

/* -------------------------------------------------------------------- */

LOCAL WORD TestObj(OBJECT *tree, LONG *Clip, LONG Flags);
LOCAL USERB *NewBlock ( OBJECT *tree, BYTE *text, INT typ );
LOCAL WORD cdecl AlertHandler(EVNT *Evnt);

/* -------------------------------------------------------------------- */
/* Nachdem Programmstart die Adresse der OVL2RSM-Struktur zurckgeben		*/

WORD start(VOID)
{
	BYTE *Pos;
	INT i;
	INT Ret=1;
	LONG Adr;

	Adr=0;
	if(_BasPag->p_cmdlin[0] == 14)	/* immer 14 Byte lang */
	{
		if(!strncmp(&_BasPag->p_cmdlin[1], "RSMOVL", 6))
		{
			Pos	= &_BasPag->p_cmdlin[7];
			for(i=0; i<8; i++)
			{
				Adr <<= 4;
				Adr |= *Pos++ - 'A';			/* 'A'=0 usw. */
			}
			*((OVL2RSM**)Adr)	= &Overlay;	/* Adresse der Struktur eintragen */
			Ret = 0;								/* alles OK zurckgeben           */
		}
	}
	return Ret;
}

/* -------------------------------------------------------------------- */
/* Overlay initalisieren																								*/

INT cdecl Init(const BYTE* FileName, UINT* Global, RSM2OVL* RsmOvl, TOOLS* Tools)
{
	BYTE *from;
	WORD i;

	Rsm=RsmOvl;													/* Struktur merken								*/
	if(InitGem ( "" , 'SGEM' , "SysGem-Dialog" ) > 0 )
	{
		for(i=0; i<15; i++)								/* Globalfeld kopieren						*/
			_GemParBlk.global[i]=*(Global+i);
		if(FileName!=NULL)
			strcpy(file,FileName);					/* FileName retten, damit er ver„n*/
		init_default();
		LoadConfigAscii(file);
		init_SysGem();
		if(Rsm->Protokoll>=1)							/* Protokollversion 1 und gr”žer	*/
		{
			init_naes();
			from=strrchr(file,'\\');
			strcpy(from+1,"sgemovl.rsc");
			RscHandle=Rsm->RscLoad(file,1);
			if(RscHandle!=0)								/* Kein Fehler unterlaufen				*/
			{
				Tools->DialToolbox=Rsm->RscGetTree(RscHandle,OBJEKTE);
				SetUp_Tree=Rsm->RscGetTree(RscHandle,SETUP);
				Rsm->ConvertTree(SetUp_Tree,0);
			}
			else
			{
				form_alert(1,"[3][SysGem Overlay:|Fehler beim Laden der Resourcedatei][OK]");
				Overlay.SetUp=NULL;
			}
		}
		return 0;
	}

	return 1;
}

/* -------------------------------------------------------------------- */
/* Overlay soll beendet werden																					*/

VOID cdecl Exit( VOID )
{
	if(Rsm->Protokoll>=1)
	{
		if(RscHandle!=0)
			Rsm->RscFree(RscHandle);
	}
	ExitGem();
}

/* -------------------------------------------------------------------- */
/* Das Overlay soll ein Objekt zeichen																	*/

WORD cdecl Draw(OBJECT* Objc, LONG* Clip, LONG Flags)
{
	WORD i;
	OBJECT tree;
	
	memcpy(&tree,Objc,sizeof(OBJECT));		/* Kopieren, da ver„nderungen erfolgen */
	i=TestObj(&tree,Clip,Flags);

	return i;
}

/* -------------------------------------------------------------------- */
/* Objekt testen																												*/

WORD TestObj(OBJECT *tree, LONG *Clip, LONG Flags)
{
  BYTE text[255];
  INT  flags;
  RECT rec;
  USERB *block;
  PARMBLK P;

	block=NULL;
  flags = tree->ob_flags;
	switch ((BYTE)( tree->ob_type ))
	{
	  case G_BUTTON     : 
	  			strcpy(text,tree->ob_spec.free_string);
			    if (( tree->ob_type >> 8 ) == 1 )
			      {
			        excl ( tree->ob_state, SELECTED );
			        block = NewBlock ( tree, text, OBJ_HELP );
			        break;
			      }
			    if (( tree->ob_type >> 8 ) == 2 )
			      {
			        excl ( tree->ob_state, SELECTED );
			        block = NewBlock ( tree, text, OBJ_HELP );
			        break;
			      }
			    if (( tree->ob_type >> 8 ) == 3 )
			      {
			        excl ( tree->ob_flags, EXIT      );
			        excl ( tree->ob_flags, TOUCHEXIT );
			        excl ( tree->ob_flags, DEFAULT   );
			        block = NewBlock ( tree, text, OBJ_REITER );
			        break;
			      }
			    if ( flags & EXIT )
			      {
			        block = NewBlock ( tree, text, OBJ_BUTTON );
			        break;
			      }
			    if ( flags & RBUTTON )
			      {
			        block = NewBlock ( tree, text, OBJ_RADIO );
			        break;
			      }
			    if ( flags & SELECTABLE )
			      {
			        block = NewBlock ( tree, text, OBJ_SELECT );
			        break;
			      }
			    if ( flags & TOUCHEXIT )
			      {
			        block = NewBlock ( tree, text, OBJ_TOUCH );
			        break;
			      }
			    block = NewBlock ( tree, text, OBJ_FRAME );
    break;
	  case G_BOX        :
					if(Rsm->Protokoll>=1 && (Flags & 0x0004))		/* Box im Dialog-Toolbox*/
							tree->ob_type |= (9 << 8);							/* Box mit Rahmen	*/
					if(Rsm->Protokoll>=1 && (Flags & 0x0002))		/* Box im Men		*/
						{
							block = NewBlock ( tree, text, OBJ_MBOX );
							break;
						}
					if (( tree->ob_type >> 8 ) == 50 )
			      {
			        block = NewBlock ( tree, NULL, OBJ_BALKEN1 );
			        break;
			      }
			    if (( tree->ob_type >> 8 ) == 51 )
			      {
			        block = NewBlock ( tree, NULL, OBJ_BALKEN2 );
			        break;
			      }
			    if (( tree->ob_type >> 8 ) == 52 )
			      {
			        block = NewBlock ( tree, NULL, OBJ_BALKEN3 );
			        break;
			      }
			    block = NewBlock ( tree, NULL, OBJ_BOX );
    break;
	  case G_BOXCHAR    : 
					if (( tree->ob_type >> 8 ) != 11 )
            {
              block = NewBlock ( tree, NULL, OBJ_CHAR );
            }
    break;
	  case G_TEXT       :
	  case G_BOXTEXT    :
	  			strcpy(text,tree->ob_spec.tedinfo->te_ptext);
          switch ( tree->ob_type >> 8 )
            {
              case  2 : block = NewBlock ( tree, text, OBJ_LISTBOX );
                        break;
              case  3 : block = NewBlock ( tree, text, OBJ_CIRCLE );
                        break;
              default : block = NewBlock ( tree, text, OBJ_TEXT );
                        break;
            }
    break;
	  case G_STRING     :
	  			strcpy(text,tree->ob_spec.free_string);
					if(Rsm->Protokoll>=1 && (Flags & 0x0002))		/* String im Men	*/
						block = NewBlock ( tree, text, OBJ_MENTRY );
	  			else
	  			{
		  			if( (tree->ob_state & DISABLED) &&
		  			    ( text [0] == '-' ) && ( text [1] == '-' ) && ( text [2] == '-' ))
		  			{
							P.x  = tree->ob_x;
							P.y  = tree->ob_y;
							P.w  = tree->ob_w;
							P.h  = tree->ob_h;
							P.xc = (INT) *Clip;
							P.yc = (INT) *( Clip + 1 );
							P.wc = (INT) *( Clip + 2 );
							P.hc = (INT) *( Clip + 3 );
							P.parm =  (LONG) NULL;
							rec.x = P.xc;
							rec.y = P.yc;
							rec.w = P.wc;
							rec.h = P.hc;
							SetClipping ( &rec );
		  				draw_mline ( &P );
		  				return ( 0 );
		  			}
	  			}
        	block = NewBlock ( tree, text, OBJ_STRING );
	  break;
	  case G_TITLE			:
	  			strcpy(text,tree->ob_spec.free_string);
        	block = NewBlock ( tree, text, OBJ_MTITLE );
	  break;
	  case G_FTEXT      :
	  case G_FBOXTEXT   :
	  			if ( sysgem.self_edit )
          {
		  			strcpy(text,tree->ob_spec.tedinfo->te_ptext);
            block = NewBlock ( tree, text, OBJ_EDIT );
          }
    break;
	  default           : break;
	}
	if(block!=NULL)
	{
		P.tree=tree;
		if(block->ob_typ==OBJ_BOX)						/* Bei Boxen sonder Behandlung*/
		{
			P.obj=1;
			if(Rsm->Protokoll>=1)
			{
				if((Flags & 0x0001)== 0x0001 &&		/* Root-Objekt ?							*/
				   (Flags & 0x0004)!= 0x0004)			/* aber keine Dialog-Toolbox	*/
					P.obj=0;
			}
		}
		else
			P.obj=0;
		P.x  = tree->ob_x;
		P.y  = tree->ob_y;
		P.w  = tree->ob_w;
		P.h  = tree->ob_h;
		P.xc = (INT) *Clip;
		P.yc = (INT) *( Clip + 1 );
		P.wc = (INT) *( Clip + 2 );
		P.hc = (INT) *( Clip + 3 );
		P.parm = (LONG) block;
		rec.x = P.xc;
		rec.y = P.yc;
		rec.w = P.wc;
		rec.h = P.hc;
		SetClipping ( &rec );
		DrawUserDef ( &P );
		Dispose ( block );
		return ( 0 );
	}
	return ( 1 );
}

/* ------------------------------------------------------------------- */

USERB *NewBlock ( OBJECT *tree, BYTE *text, INT typ )

{
  USERB         *ub;
  INT           x, y, w, h;

  if (( tree->ob_type >> 8 ) == 120 ) return ( NULL );

  excl ( tree->ob_flags, 0x0200 );
  excl ( tree->ob_flags, 0x0400 );

  ub = (USERB *) Allocate ( sizeof ( USERB ));
  if ( ub == NULL ) return ( NULL );

  x = 0;
  y = 0;
  w = 0;
  h = 0;

  ub->next          = NULL;
  ub->code          = DrawUserDef;
  ub->ubb           = ub;
  ub->text          = text;
  ub->parm          = tree->ob_spec.index;
  ub->obj           = 0;                        /* alt obj */
  ub->ob_typ        = typ;
  ub->ext           = (INT)((BYTE)( tree->ob_type >> 8 ));
  ub->typ           = (INT)((BYTE)( tree->ob_type >> 0 ));
  ub->ch            = 0;
  ub->pos           = -1;

  switch ( typ )
    {
      case OBJ_BUTTON  :
      case OBJ_FRAME   :
      case OBJ_TOUCH   :
      case OBJ_HELP    : if ( sysgem.bergner ) goto bergner;
                         x = 1;
                         y = 2 + ( sysgem.charh / 4 );
                         w = 2 + ( sysgem.charw / 4 );
                         h = 2 + ( sysgem.charh / 2 );
                         MakeShortCut ( ub );
                         break;
      case OBJ_REITER  : bergner:
                         x = 1;  y = 2;  w = 2; h = 2;
                         MakeShortCut ( ub );
                         break;
      case OBJ_RADIO   : MakeShortCut ( ub );
                         break;
      case OBJ_SELECT  : MakeShortCut ( ub );
                         break;
      case OBJ_BOX     : x = 0;  y = 0;  w = 2; h = 2;
                         if ( ub->ext == 4 )
                           {
                             w = 0; h = 0;
                           }
                         break;
      case OBJ_CHAR    : x = 0; y = 0; w = 2; h = 2;
                         if ( tree->ob_state & SHADOWED )
                           {
                             w = 4;  h = 4;
                           }
                         break;
      case OBJ_TEXT    : if ( ub->typ == G_BOXTEXT )
                           {
                             if ( tree->ob_state & SHADOWED )
                               {
                                 x = 1;
                                 y = 1;
                                 w = 2;
                                 h = 3;
                               }
                             else
                               {
                                 h = 2;
                               }
                           }
                         MakeShortCut ( ub );
                         break;
      case OBJ_STRING  : MakeShortCut ( ub );
                         break;
      case OBJ_EDIT    : x = 1; y = 2; w = 6; h = 4;
                         break;
      case OBJ_LISTBOX :
      case OBJ_CIRCLE  : x = 1; y = 2; w = ( 3 * sysgem.charw ) + ( sysgem.charw / 2 ); h = 5;
                         MakeShortCut ( ub );
                         break;
    }

  if ( tree->ob_x != 0 )
    {
      tree->ob_x -= x;
    }
  else
    {
      x = 0;
    }
  if ( tree->ob_y != 0 )
    {
      tree->ob_y -= y;
    }
  else
    {
      y = 0;
    }
  tree->ob_w    += w;
  tree->ob_h    += h;
  tree->ob_type  = G_USERDEF;
  tree->ob_spec.index = (LONG)( &ub->code );

  return ( ub );
}

/* -------------------------------------------------------------------- */

VOID cdecl GetArea(OBJECT* Objc, LONG Flags, GRECT* Area)
{
	INT flags;
	
  flags = Objc->ob_flags;
	switch ((BYTE)( Objc->ob_type ))
	{
	  case G_BUTTON     : 
	    if ( flags & RBUTTON )
				draw_radio_Area (Objc, Area );
    break;
	  case G_BOX        :
			if (( Objc->ob_type >> 8 ) == 50 )
	      {
/*	        block = NewBlock ( tree, NULL, OBJ_BALKEN1 );*/
	        break;
	      }
	    if (( Objc->ob_type >> 8 ) == 51 )
	      {
/*	        block = NewBlock ( tree, NULL, OBJ_BALKEN2 );*/
	        break;
	      }
	    if (( Objc->ob_type >> 8 ) == 52 )
	      {
/*	        block = NewBlock ( tree, NULL, OBJ_BALKEN3 );*/
	        break;
	      }
			draw_box_Area ( Objc, Area );
    break;
	  case G_BOXCHAR    : 
    break;
	  case G_TEXT       :
	  case G_BOXTEXT    :
	    switch ( Objc->ob_type >> 8 )
	      {
	        case  2 : 
	        case  3 :
	        					draw_listbox_Area (Objc, Area );
			              break;
	      }
    break;
	  case G_STRING     :
	  break;
	  case G_FTEXT      :
	  case G_FBOXTEXT   :
    break;
	  default           : break;
	}
}

/* -------------------------------------------------------------------- */
/* Testroutine fr Dialog zu Verfgung stellen													*/

WORD cdecl Test(LONG Mode, LONG Resource, LONG Idx, GETOBNAME GetObName, INITEVENTHANDLER InitEventHandler)
{
	WORD ret;
	
	ret=0;
	switch((WORD)Mode)
	{
		case -1:														/* Info-Mode										*/
			ret = 0x08;
		break;
		case 0:															/* Dialog testen								*/
		break;
		case 1:															/* Alert testen									*/
/*			InitEventHandler(AlertHandler);*/
/*			Alert(ALERT_STOP,1,(char *)Resource);*/
		break;
	}
	return ret;
}

/* -------------------------------------------------------------------- */
/* Alert Hanlder zum der selbigen																				*/

WORD cdecl AlertHandler(EVNT *Evnt)
{
	TakeEvent (Evnt->mwhich, Evnt->mx, Evnt->my, Evnt->mbutton,
					   Evnt->kstate, Evnt->key, Evnt->mclicks,
					   Evnt->msg );
	HandleEvents();
	return 1;
}


/* -------------------------------------------------------------------- */
/* Liefert den ShortCut zurck																					*/

LONG cdecl GetShortCut(OBJECT* Objc, LONG Flags, BYTE ShortCut[10])
{
  BYTE text[255];
  BYTE *p;
  LONG ret;

	if(Flags & 0x0002)										/* Falls Menzeile							*/
		return -1;													/* Nicht in funktion						*/
	
	switch ((BYTE)( Objc->ob_type ))
	{
	  case G_TEXT       :
	  case G_BOXTEXT    :
	  			strcpy(text,Objc->ob_spec.tedinfo->te_ptext);
    break;
	  case G_BUTTON     : 
	  case G_STRING     :
	  			strcpy(text,Objc->ob_spec.free_string);
	  break;
	  default           :
	  			return 0;											/* Objekt hat kein ShurtCut			*/
	}
	p = strchr ( text, '[' );
  if ( p == NULL )
  	return 0;														/* Objekt hat kein ShurtCut			*/
	p++;
	ShortCut[0] = *p;
	ShortCut[1] = 0;
	ret = (LONG) toupper ( *p );
	return ret;
}

/* -------------------------------------------------------------------- */

VOID main ( VOID )

{
	WORD Ret;
	
	Overlay.Magic='OBJC';									/* Struktur init								*/
	Overlay.Protokoll=2;
	Overlay.ID='SGEM';
	Overlay.Version=0x005;
	strcpy(Overlay.Name,"SysGem Overlay");
	strcpy(Overlay.Copyright,"\275 ");
	strcpy(Overlay.Copyright,__DATE__);
	strcat(Overlay.Copyright," Satya-Soft");
	Overlay.Init=Init;
	Overlay.Draw=Draw;
	Overlay.Exit=Exit;
	Overlay.GetMinSize=NULL;
	Overlay.GetArea=GetArea;
	Overlay.SetUp=SetUp;
	Overlay.Test=NULL;
	Overlay.GetShortCut=GetShortCut;

	Ret=start();

	exit(Ret);
}
