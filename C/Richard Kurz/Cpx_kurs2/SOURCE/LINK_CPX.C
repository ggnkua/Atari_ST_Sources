/*  LINK_CPX.C
 *
 *  aus: Wir basteln uns ein CPX
 *       CPX-Kurs Teil 2
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *
 *  Erstellt mit Pure C
 */
 
#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <portab.h>
#include "cpx.h"
#include "link_glo.h"
#include "linkcpx.h"
#pragma warn -rpt 
#include "linkcpx.rsh"
#pragma warn +rpt 

/* Eine handvoll Prototypen */
CPXINFO * cdecl cpx_init(XCPB *Xcpb);
WORD cdecl cpx_call(GRECT *re); 

/* Globale Variablen */
GRECT   *w_rect;        /* Die Koordinaten des Fensters.        */
XCPB    *xcpb;          /* Zeiger auf die XControl-Funktionen.  */
CPXINFO cpxinfo;        /* Zeiger auf unsere Funktionen fr     */
                        /* XControl.                            */
MFORM   mzeiger;        /* Parkplatz fr den Mauszeiger.        */

int i_farbe,             /* Wert fr die Icon-Farbe			    */
    t_farbe;             /* Wert fr die Text-Farbe			    */

OBJECT  *dialog,        /* Zeiger auf unsere Dialoge.           */
		*iedit;

/* Externe Variable aus dem Assemblerteil */
extern CPXHEAD cp_head;	/* Speicherplatz fr den Default-Header	*/

CPXINFO * cdecl cpx_init(XCPB *Xcpb)
/* Diese Funktion wird w„rend der XControl-Initialisierung und  */
/* bei jeder Aktivierung unseres CPX-Moduls als erstes          */
/* gestartet. Sie erh„lt einen Zeiger auf die CPX-Funktionen    */
/* und muž einen Zeiger auf die eigenen Funktionen oder NULL    */
/* bzw. 1 zurckgeben.                                          */
{
	CPX_LIST *cpl;
    xcpb=Xcpb;


    if(xcpb->booting)
    /* Dieses Flag zeigt an, ob es der erste Aufruf (w„rend der */
    /* XControl-Initialisierung) ist.                           */
    {
        /* W„rend der Initialisierung muž eine 1 zurckgegeben  */
        /* werden, wenn das CPX-Modul nicht set_only sein soll. */
        return ((CPXINFO *)1);
    }

    if(!xcpb->SkipRshFix)
    /* In diesem Flag wird festgehalten, ob der OBJECT-Baum     */
    /* schon angepažt wurde.                                    */
    {
        /* Wir passen den OBJECT-Baum an.                       */
        (*xcpb->rsh_fix)(NUM_OBS,NUM_FRSTR,NUM_FRIMG,NUM_TREE,
                         rs_object,rs_tedinfo,rs_strings,rs_iconblk,
                         rs_bitblk,rs_frstr,rs_frimg,rs_trindex,
                         rs_imdope);
    }
    dialog=(OBJECT *)rs_trindex[DIALOG];
    iedit=(OBJECT *)rs_trindex[EDICON];
    
    /* Wenn noch kein Default-Header gesichert wurde, klauen 	*/
    /* wir uns den ersten CPX-Header aus XControl.				*/
    if(cp_head.magic!=100)
    {
	    cpl=(*xcpb->get_cpx_list)();
    	if(cpl!=NULL)
	    	memcpy(&cp_head,&cpl->header,sizeof(CPXHEAD));
	}

    /* In die CPXINFO-Struktur mssen unsere Funktionen ein-    */
    /* getragen werden.                                         */
    cpxinfo.cpx_call    =cpx_call;
    cpxinfo.cpx_draw    =NULL;
    cpxinfo.cpx_wmove   =NULL;
    cpxinfo.cpx_timer   =NULL;
    cpxinfo.cpx_key     =NULL;
    cpxinfo.cpx_button  =NULL;
    cpxinfo.cpx_m1      =NULL;
    cpxinfo.cpx_m2      =NULL;
    cpxinfo.cpx_hook    =NULL;
    cpxinfo.cpx_close   =NULL;
    
    /* Mit der Rckgabe unserer Funktionen melden wir uns beim  */
    /* XControl an.                                             */
    return(&cpxinfo);
} /* cpx_init */

WORD cdecl cpx_call(GRECT *rect)
/* Hier steht der Hauptteil, er wird von XControl bei der       */
/* Aktivierung unseres Moduls nach cpx_init aufgerufen.         */
/* In *rect stehen die Koordinaten des XControl-Fensters.       */
/* Bei einem Xform_do-CPX (wie in unserem Fall), muž immer 0    */
/* zurckgegeben werden.                                        */
{
    WORD msg[8];        /* Puffer fr Xform_do.                 */
    WORD button,        /* Welches Schweinderl „hh button.      */
         ende;          /* Flag fr's ENDE.                     */

    /* Unser Dialog muž angepažt werden.                        */
    w_rect=rect;		/* Die Koordinaten mssen global		*/
    					/* gesichert werden!					*/
    dialog[ROOT].ob_x=w_rect->g_x;
    dialog[ROOT].ob_y=w_rect->g_y;
    
    /* Initialisieren und zeichnen.                             */
    init_dialog();
    objc_draw(dialog,ROOT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    do
    { 
        /* Wir berlassen XControl die Verwaltung des Dialogs.  */
        button=(*xcpb->Xform_do)(dialog,CTEXT,msg);
        /* Nun mssen wir arbeiten.                             */
        ende=handle_dialog(button,msg);
    } while(!ende);
    
    /* Ende unseres Moduls, XControl ist wieder an der Reihe.   */
    return(FALSE);
} /* cpx_call */

WORD handle_dialog(WORD button, WORD *msg)
/* Hier behandeln wir die Objekte, die angeklickt wurden.       */
/* In button steht die Objekt-Nr. und in msg ein Zeiger auf     */
/* einen Messag-Buffer („hnlich wie evnt_mesag).                */
{
    GRECT r1;           /* Koordinaten-Feld.                    */
    WORD p,ox,oy;       /* Hilfsvariablen.                      */
    WORD mx,my,mk,kb;   /* Variablen fr das M„usekind.         */
    char *items[8];     /* Zeiger-Feld fr die PopUp-Mens.     */
    
    /* Das Ausmaskieren eines Doppel-Klicks gestaltet sich hier */
    /* etwas komplizierter als bei form_do, da Xform_do als     */
    /* Flag fr Nachrichten -1 liefert.                         */
    if((button!=-1)&&(button & 0x8000))
        button &= 0x7fff;

    switch(button)
    {
    	case CINFO:		/* Vorstellung.							*/
           	form_alert(1,"[1][CPX-Linker & Icon-Editor|1992 by Richard Kurz|Vogelherdbogen 62|7992 Tettnang|fr's TOS Magazin][ Okay ]");               
            dialog[button].ob_state &= ~SELECTED;
    		objc_draw(dialog,button,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    		break;
    		
        case SICHERN:	/* PopUp-Men zum Speichern der Header.	*/
        	items[0]="  Als Default Header   ";
            items[1]="  Nur Header sichern   ";
            items[2]="  In CPX schreiben     ";
            items[3]="  Header mit CP linken ";
            
            objc_offset(dialog,SICHERN,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[SICHERN].ob_width;
            r1.g_h=dialog[SICHERN].ob_height;
            
            p=(*xcpb->Popup)(items,4,-1,3,&r1,w_rect);
            if(p!=-1)
            {
             	upd_header();
				init_dialog();
    			objc_draw(dialog,ROOT,MAX_DEPTH,
                	w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            if(p==0)
            {
        		if(!(*xcpb->CPX_Save)(&cp_head,512))
            		(*xcpb->XGen_Alert)(FILE_ERR);
            }
            else if(p==1) write_header(&cp_head);
            else if(p==2) write_to_cpx(&cp_head);
            else if(p==3) link_cpx(&cp_head);
            break;
            
        case LHEAD:		/* PopUp zum Laden der Header.		*/
            items[0]="  Header *.HDR ";
            items[1]="  CPX    *.CPX ";
            
            objc_offset(dialog,LHEAD,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[LHEAD].ob_width;
            r1.g_h=dialog[LHEAD].ob_height;
            
            p=(*xcpb->Popup)(items,2,-1,3,&r1,w_rect);
            mk=FALSE;
            if(p==0)
                mk=read_header(&cp_head,"HDR");
            else if(p==1)
            	mk=read_header(&cp_head,"CPX");
            if(mk)
            {
				init_dialog();
   				objc_draw(dialog,ROOT,MAX_DEPTH,
                	w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
           }
            break;
            
        /* Es wird glatt, wir schlittern ein wenig (horizontal).*/
        /* XControl vereinfacht die Slider-Behandlung (toll).   */
        case IMINUS:
            (*xcpb->Sl_arrow)(dialog,IVATER,ITEXT,button,-1,0,15,&i_farbe,1,ch_ifarbe);
            break;
        case IPLUS: 
            (*xcpb->Sl_arrow)(dialog,IVATER,ITEXT,button,1,0,15,&i_farbe,1,ch_ifarbe);
            break;
        case IVATER:
            /* Wurde auf das 'Unterteil' des Sliders geklickt,  */
            /* muž noch berechnet werden, ob der User rauf oder */
            /* runter meint.                                    */
            objc_offset(dialog,ITEXT,&ox,&oy);
            graf_mkstate(&mx,&my,&mk,&kb);
            p= mx>ox ? 4: -4;
            (*xcpb->Sl_arrow)(dialog,IVATER,ITEXT,-1,p,0,15,&i_farbe,1,ch_ifarbe);
            break;
        case ITEXT:
            /* Aha, jemand m”chte mit der Hand schieben.        */
            /* Wenn die Mausform ge„ndert wird, sollte die alte */
            /* Form gespeichert und danach wieder restauriert   */
            /* werden.                                          */
            (*xcpb->MFsave)(MFSAVE, &mzeiger);
            graf_mouse(FLAT_HAND,NULL);
            (*xcpb->Sl_dragx)(dialog,IVATER,ITEXT,0,15,&i_farbe,ch_ifarbe);
            (*xcpb->MFsave)(MFRESTORE, &mzeiger);
            break;
        
        /* Noch ein Slider.                                     */
        case TMINUS:
            (*xcpb->Sl_arrow)(dialog,TVATER,TTEXT,button,-1,0,15,&t_farbe,1,ch_tfarbe);
            break;
        case TPLUS:
            (*xcpb->Sl_arrow)(dialog,TVATER,TTEXT,button,1,0,15,&t_farbe,1,ch_tfarbe);
            break;
        case TVATER:
            objc_offset(dialog,TTEXT,&ox,&oy);
            graf_mkstate(&mx,&my,&mk,&kb);
            p= mx>ox ? 4 : -4;
            (*xcpb->Sl_arrow)(dialog,TVATER,TTEXT,-1,p,0,15,&t_farbe,1,ch_tfarbe);
            break;
        case TTEXT:
            (*xcpb->MFsave)(MFSAVE, &mzeiger);
            graf_mouse(FLAT_HAND,NULL);
            (*xcpb->Sl_dragx)(dialog,TVATER,TTEXT,0,15,&t_farbe,ch_tfarbe);
            (*xcpb->MFsave)(MFRESTORE, &mzeiger);
            break;
            
        case CICON: case E_ICON: case CITEXT:
        	/* Jemand m”chte das Icon editieren.				*/
        	if(edit_icon()) return(TRUE);
    			dialog[ROOT].ob_x=w_rect->g_x;
    			dialog[ROOT].ob_y=w_rect->g_y;
   				objc_draw(dialog,ROOT,MAX_DEPTH,
                	w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
       		break;

        case OKAY:	/* Und Tschž.								*/
            dialog[button].ob_state &= ~SELECTED;
            return(TRUE);

        default:
            /* Wenn Xform_do -1 zurckliefert, ist etwas im     */
            /* Busche, bzw. im Message-Puffer. Der Aufbau des   */
            /* Puffers ist „hnlich wie bei evnt_mesag.          */
            if(button==-1)
            {
                switch(msg[0])
                {
                    case WM_CLOSED:
                    /* Wurde das Fenster geschlossen, wird das  */
                    /* wie OKAY behandelt.                      */
                    case AC_CLOSE:
                    /* Bei AC_CLOSE nichts wie raus! Wurde vom  */
                    /* Modul Speicher angefordert oder sind     */
                    /* Dateien ge”ffnet, unbedingt aufr„umen!!  */
                        return(TRUE);
                    case CT_KEY:
                    /* Jemand hat eine Sondertaste gedrckt.    */
                    /* Help, Undo, Funktions-Tasten usw.        */
                        if(msg[3]==0x6200)      /* Help         */
                        {
                            form_alert(1,"[0][Hiiiiilfe !!!! ][ Ah ja ]");
                        }
                        else if(msg[3]==0x6100) /* Undo         */
                        {
                            p=form_alert(2,"[2][Undo oder nicht Undo|ist hier die Frage][ Ja | Nein ]");                            
                            if(p==1)
                            {
                                init_dialog();
                                objc_draw(dialog,ROOT,MAX_DEPTH,
                                           w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
                            }
                        }
                    case WM_REDRAW:
                    /* Darum braucht sich ein Xform_do-Modul    */
                    /* eigentlich nicht kmmern. Wen's trotzdem	*/
                    /* interessiert, m”ge sich den Icon-Editor	*/
                    /* anschauen.								*/
                    default:
                        break;
                }
            }
            break;
    }
    return(FALSE);
} /* handle_dialog */

void init_dialog(void)
/* Hier wird der Dialog mit den aktuellen Daten aus dem Header	*/
/* versorgt.													*/
{
	dialog[CICON].ob_spec.bitblk->bi_pdata=(int *)cp_head.icon;
	dialog[CITEXT].ob_spec.tedinfo->te_ptext=cp_head.i_text;
	dialog[CTEXT].ob_spec.tedinfo->te_ptext=cp_head.text;

	memcpy(dialog[CPXID].ob_spec.tedinfo->te_ptext,&cp_head.cpx_id,4);
	sprintf(dialog[CPXVER].ob_spec.tedinfo->te_ptext,"%4X",cp_head.cpx_version);

	if(cp_head.flags.boot_init) dialog[BOOTI].ob_state |= SELECTED;
	else dialog[BOOTI].ob_state &= ~SELECTED;
	
	if(cp_head.flags.set_only) dialog[SETO].ob_state |= SELECTED;
	else dialog[SETO].ob_state &= ~SELECTED;
	
	if(cp_head.flags.ram_resident) dialog[RAMRES].ob_state |= SELECTED;
	else dialog[RAMRES].ob_state &= ~SELECTED;
	
	i_farbe=cp_head.i_info.i_color;
	t_farbe=cp_head.t_info.c_text;
	
    (*xcpb->Sl_x)(dialog,IVATER,ITEXT,i_farbe,0,15,ch_ifarbe);
    (*xcpb->Sl_x)(dialog,TVATER,TTEXT,t_farbe,0,15,ch_tfarbe);
} /* init_dialog */

void ch_ifarbe(void)
/* Aktualisiert den Text im Icon-Farben-Slider.      			*/
{
    static char s[10];
    
    sprintf(s,"%i",i_farbe);
    dialog[ITEXT].ob_spec.free_string=s; 

	dialog[CITEXT].ob_spec.tedinfo->te_color &= 0xff;
	dialog[CITEXT].ob_spec.tedinfo->te_color |= (i_farbe<<12);
	dialog[CITEXT].ob_spec.tedinfo->te_color |= (i_farbe<<8);
	dialog[CICON].ob_spec.bitblk->bi_color = i_farbe;

	objc_draw(dialog,CITEXT,MAX_DEPTH,
           	w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
	objc_draw(dialog,CICON,MAX_DEPTH,
           	w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
} /* ch_ifarbe */

void ch_tfarbe(void)
/* Aktualisiert den Text im Text-Farben-Slider. 				*/
{
    static char s[10];
    
    sprintf(s,"%i",t_farbe);
    dialog[TTEXT].ob_spec.free_string=s; 
	dialog[CTEXT].ob_spec.tedinfo->te_color &= 0xff;
	dialog[CTEXT].ob_spec.tedinfo->te_color |= (t_farbe<<12);
	dialog[CTEXT].ob_spec.tedinfo->te_color |= (t_farbe<<8);
	objc_draw(dialog,CTEXT,MAX_DEPTH,
           	w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
} /* ch_tfarbe */

void upd_header(void)
/* Die Daten aus dem Dialog werden in den Header bertragen.	*/
{
    cp_head.magic=100;          
	memcpy(&cp_head.cpx_id,dialog[CPXID].ob_spec.tedinfo->te_ptext,4);
	cp_head.cpx_version=(UWORD)strtoul(dialog[CPXVER].ob_spec.tedinfo->te_ptext,NULL,16);
	cp_head.flags.boot_init=dialog[BOOTI].ob_state & SELECTED;
	cp_head.flags.set_only=dialog[SETO].ob_state & SELECTED;
	cp_head.flags.ram_resident=dialog[RAMRES].ob_state & SELECTED;
	cp_head.i_info.i_color=i_farbe;
    cp_head.i_info.reserved=0;
    cp_head.i_info.i_char=0;
	cp_head.t_info.c_text=t_farbe;
	cp_head.t_info.c_board=t_farbe;
    cp_head.t_info.pattern=8;
    cp_head.t_info.c_back=0;
	cp_head.reserved[0]='R';
	cp_head.reserved[1]='K';
}/* upd_header */

