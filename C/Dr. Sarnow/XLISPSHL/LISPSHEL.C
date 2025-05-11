/********************************************************************/
/*           												    	*/
/*                       XLISPshell                                 */
/*                     <c> Dr. Sarnow								*/
/*                 fÅr die PD der ST-Computer						*/
/*       		zum persînlichen Gebrauch freigegeben				*/
/*																	*/
/********************************************************************/

#include <obdefs.h>	
#include <gemdefs.h>
#include <osbind.h>
#include <stdio.h>
#include <string.h>
#include "lispshel.h"

#define TRUE (1)
#define FALSE (0)
#define DEBUG			

/*************************** idiotisches GEM Geblasel **************/            
int contrl[12],
    intin[128],
    intout[128],
    ptsin[128],
    ptsout[128] ;

int work_in[12],
    work_out[57] ;
int pxyarray[10] ;

int handle ;
OBJECT *menu_tree,*formular,*urheber,*optfiles;

int mouse ;             /* mouse ein = 1, aus = 0             */
int gl_dummy ;       /* globaler dummy */
int dix,diy,diw,dih ; /* dialog box parameter */
int x_info,y_info,w_info,h_info;
int x_opt,y_opt,w_opt,h_opt;
int obval;
int xwork,ywork,wwork,hwork;
int xfull,yfull,wfull,hfull;

int msgbuff[32] ;

char options[7][20],d[20],lspfile[20],was[30],akt[13],pf[150],*xlopt;


/* globale Variablen fÅr den Gebrauch  der Window Routinen aus der */
/* MEGAMAX Tool Diskette Nr. 4*/

static int whandle[5] ; /* window-handle fuer max. 4 fenster */
static int ax[5],ay[5],aw[5],ah[5] ;  /* koord. der arbeitsbereiche */
static int bx[5],by[5],bw[5],bh[5] ;  /* koord. der bildbereiche */
static int posx[5],posy[5] ; /* koord. des linken oberen eckpkts */
                      /*  im virtuellen fenster */
static int fulled[5] ; /* fenster fulled oder nicht */
static int wikind[5] ; /* fensterattribute */
static int wopen[5] ; /* fenster offen oder zu */
static char *speich[5] ; /* anfangsadressen der speicherbereiche */
static char *base[5] ; /* anfangsadressen der screens */
static int maxwd ;     /* nummer des hoechsten windows muss zu anfang auf 0
                   gesetzt werden */
static char *bild ;
static int mwidth,mheight,mplane ;
static int wd_handle ;

/************** ôffnet virtuelle Arbeitstation ************/

open_vwork()
{
 int i,dummy;
  appl_init();
  handle=graf_handle(&gl_dummy,&gl_dummy,&gl_dummy,&gl_dummy);
  for (i=0;i<10;work_in[i++]=1);
  work_in[10]=2;
  v_opnvwk(work_in,&handle,work_out);
  graf_mouse(0,&gl_dummy) ;
}

/******************* Schlieût dieselbe  *********************/

close_vwork()
{
 v_clsvwk(handle);
 appl_exit();
 Pterm0();
}

/********************** Maus an *****************************/

show_mouse()
{ if (!mouse)
  { graf_mouse(257,&gl_dummy) ;
    mouse = TRUE ;
  }
}

/*************** Und wieder aus ********************************/

hide_mouse()
{ if (mouse)
  { graf_mouse(256,&gl_dummy) ;
    mouse = FALSE ;
  }
}

/*************************************************************/
/*    hauptprogramm                                          */
/*************************************************************/

main()
{
  int reso ;
  open_vwork() ;
  if (!rsrc_load("lispshel.rsc"))
  {
    form_alert(1,"[3][Ich kann LISPSHEL.RSC nicht finden !][Abbruch]");
    close_vwork();
  }
  if (!rsrc_gaddr(0,LEISTE,&menu_tree))
  {
    form_alert(1,"[3][Resource File nicht ok !][Abbruch]");
    close_vwork();
  }

  if (!Getrez()==2)
  {
     form_alert(1,"[3]['tschuldigung,|funktioniert nur|mit hoher|Auflîsung.][ Meinetwegen ]");
     exit(0);
  }

  /* variablen setzen */

  mouse = TRUE ; /*Maus an*/
  xlopt=malloc(310); /*Speicherplatz fÅr Hilfsstring bereitstellen*/
  strcpy(pf,"A:\\*.*"); /*Setze Pfad String auf das*/
  *pf=Dgetdrv()+65;     /*aktuelle Laufwerk*/
  menu_bar(menu_tree,TRUE) ;  /*MenÅleiste anzeigen*/
  rsrc_gaddr(R_TREE,KNOEPFE,&formular); /* Adresse des Formulars holen*/
  strcpy(lspfile,"TEST.LSP"); /*Setze Default Lisp File*/
  (((TEDINFO *)(formular[LISPFILE].ob_spec))->te_ptext)=lspfile; /*Objektkomponenete->te_ptext zeigt auf 
  																/* den String lispfile*/
  form_center(formular,&dix,&diy,&diw,&dih);/*Zentriere das Formular*/
  rsrc_gaddr(R_TREE,AUTOR,&urheber);/*Hol die Adresse der Infoschablone*/
  form_center(urheber,&x_info,&y_info,&w_info,&h_info);   /*und zentriere sie*/
  rsrc_gaddr(R_TREE,OPTFILES,&optfiles);/*Hol die Adresse der Hilfsfileschablone*/
  (((TEDINFO *)(optfiles[NAME1].ob_spec))->te_ptext)=options[0];/*und verbiege alle Stringpointer*/
  (((TEDINFO *)(optfiles[NAME2].ob_spec))->te_ptext)=options[1];/*sodaû sie auf die Strings fÅr die*/
  (((TEDINFO *)(optfiles[NAME3].ob_spec))->te_ptext)=options[2];/*Files zeigen*/
  (((TEDINFO *)(optfiles[NAME4].ob_spec))->te_ptext)=options[3];
  (((TEDINFO *)(optfiles[NAME5].ob_spec))->te_ptext)=options[4];
  (((TEDINFO *)(optfiles[NAME6].ob_spec))->te_ptext)=options[5];
  (((TEDINFO *)(optfiles[NAME7].ob_spec))->te_ptext)=options[6];
  form_center(optfiles,&x_opt,&y_opt,&w_opt,&h_opt);/*Zentriere das Formular*/
  wind_get(0,WF_WORKXYWH,&xfull,&yfull,&wfull,&hfull);/*Hol die Fensterkoordinaten*/
  wikind[1]=NAME | INFO;/*FEnsterelemente festlegen*/
  wind_calc(WC_WORK,wikind[1],xfull,yfull,wfull,hfull,&xwork,&ywork,&wwork,&hwork);/*Berechne Koordinaten*/
  															/*fÅr den Arbeitsbereich*/
  maxwd=0;/* Ist angeblich fÅr die FEnsterroutinen erforderlich*/
  wd_init(handle);/*Initialisiere die Fensterroutinen der MM-Window_routinen*/
  whandle[1]=wd_open(wikind[1],xwork,ywork,wwork,hwork);/*ôffne das Fenster*/
  wd_title(whandle[1],"XLISPshell");/*Text fÅr Titelzeile ausgeben*/
  wd_info(whandle[1],"                                  \275 Dr. Sarnow");
  									/*Text fÅr Infozeile ausgeben*/
  wd_clr(whandle[1]);/*Lîsche Fensterinhalt*/
  wd_update(whandle[1]);/*Aktualisiere Fensterinhalt*/
  multi() ;/*Verwaltet alle Ereignisse*/

}

multi()
{ int event,mx,my,dummy,keycode;

  do
  { 
  	 objc_draw(formular,0,MAX_DEPTH,dix,diy,diw,dih);/*Zeichne das Formular neu*/
     event = evnt_multi(MU_KEYBD | MU_BUTTON | MU_MESAG,       /*Warten auf...*/
                       1,1,1,
                       FALSE,0,0,0,0,
                       FALSE,0,0,0,0,
                       msgbuff,0,0,
                       &mx,&my,&dummy,&dummy,&keycode,&dummy) ;

	wd_redraw(msgbuff);/*Automatischer Redraw Befehl (MMTOOL4)*/

    if (event & MU_MESAG)	/*MenÅleiste gewÑhlt*/
    { switch(msgbuff[0])
      { case MN_SELECTED : do_menu(msgbuff[3],msgbuff[4]) ;
                           break ;
        
      }
    }

    /* weitere abfragen */
   if (event & MU_BUTTON)
   {
      obval=objc_find(formular,0,MAX_DEPTH,mx,my);/*Finde angeklicktes Objekt*/
      menu_bar(menu_tree,FALSE);/*MenÅleiste aus*/
      switch(obval)
      {
         case XLISP:/* Es war der XLISP-Knopf*/
         	wd_close(whandle[1]);/*Fenster dicht*/
			curon(); /*Weg mit dem Desktop*/
            strcpy(xlopt," ");				/*ERzeuge Parameterstring*/
            xlopt=strcat(xlopt,lspfile);	/*fÅr den XLISP Aufruf*/
            for (dummy=0;dummy<7;dummy++)
            {
               if (strlen(options[dummy])>1)
               {
                  xlopt=strcat(xlopt," ");
                  xlopt=strcat(xlopt,options[dummy]);
               }
            }
            Pexec(0,"xlisp.ttp",xlopt,0L);	/*Los geht's*/
			curoff();	/*Desktop wieder an*/
			wd_display(whandle[1],xfull,yfull,wfull,hfull);/*Fenster auf*/
            break;
            
         case EDITOR:		/*Wie bei XLISP*/
         	wd_close(whandle[1]);
            strcpy(xlopt," ");
			xlopt=strcat(xlopt,lspfile);
			hide_mouse();
            Pexec(0,"editor.prg",xlopt,0L);
            show_mouse();
			wd_display(whandle[1],xfull,yfull,wfull,hfull);
            break;
            
         case OPTIONEN:	/*WÑhle Optionsfile*/
            keycode=opt();/*Welcher Button wird gedrÅckt?*/
            strcpy(d,options[keycode]);				/*Auswahl erfolgt mit*/
            strcpy(was," XLISP Hilfsfile wÑhlen ");	/*Hilfe der File Selector-Routine*/
            strcpy(akt," OK ");						/*aus der MM-tool Diskette 4*/
            file_select(pf,d,was,akt,"*.LSP","*.*","*.*","*.*",2);/*Aufruf derselben*/
            strcpy(options[keycode],d);/*gewÑhlte Datei festhalten*/
            break;
            
         case LISPFILE:		/*Lisp Workfile wÑhlen*/
            strcpy(d,lspfile);/*sonst wie bei Options*/
            strcpy(was," Lisp File wÑhlen ");
            strcpy(akt," OK ");
            file_select(pf,d,was,akt,"*.LSP","*.*","*.*","*.*",2);
            strcpy(lspfile,d);
            break;
            
         case CIAO:	/*TschÅs, au revoir, good bye*/
         	wd_delete(whandle[1]);
         	rsrc_free();
            show_mouse();
            close_vwork();
            break;
      }
      menu_bar(menu_tree,TRUE);
   }
  
  }while(TRUE) ;

} /* multi */

do_menu(title,item)/*Routine fÅhrt die in der MenÅleiste gewÑhlte*/
int title,item ; 	/*Routine aus. Hat hier nicht viel zu tun*/
{ switch(title)
  { case DESK  : 
         switch(item)
         { case INFORM : info() ; break ;
         }
   
  }
  menu_tnormal(menu_tree,title,1) ;/*MenÅtitel wieder normal zeichnen*/

} /* do menu */

info() 	/*Zeige das Info-formular*/
{       
   form_dial(FMD_START,320,200,0,0,x_info,y_info,w_info,h_info);
   form_dial(FMD_GROW,320,200,0,0,x_info,y_info,w_info,h_info);
   objc_draw(urheber,0,20,x_info,y_info,w_info,h_info);
   objc_change(urheber,INFOEX,0,x_info,y_info,w_info,h_info,(NORMAL | OUTLINED | SHADOWED),1);
   form_do(urheber,0);
   form_dial(FMD_SHRINK,320,200,0,0,x_info,y_info,w_info,h_info);
   form_dial(FMD_FINISH,320,200,0,0,x_info,y_info,w_info,h_info);
}
 
opt()	
{       
   int wahl;
   char *str;
   
   form_dial(FMD_START,320,200,0,0,x_opt,y_opt,w_opt,h_opt);/*Zeige das Formular*/
   form_dial(FMD_GROW,320,200,0,0,x_opt,y_opt,w_opt,h_opt); /*fÅr die Wahl der Hilfs-*/
   objc_draw(optfiles,0,20,x_opt,y_opt,w_opt,h_opt);		/*routinen*/
   form_do(optfiles,0);
   form_dial(FMD_SHRINK,320,200,0,0,x_opt,y_opt,w_opt,h_opt);
   form_dial(FMD_FINISH,320,200,0,0,x_opt,y_opt,w_opt,h_opt);
   wahl=dialog_wahl(optfiles,BUTTON1,BUTTON7);/*finde den gedrÅckten Knopf (aus MMtool 4)*/
   objc_change(optfiles,wahl,0,x_opt,y_opt,w_opt,h_opt,NORMAL,0);/*Stelle ihn wieder normal dar*/
   switch (wahl)	/*Leider haben nicht alle Objekte den gleiche Offset*/
   {
      case BUTTON1:
         wahl=0;
         break;

      case BUTTON2:
         wahl=1;
         break;
         
      case BUTTON3:
         wahl=2;
         break;

      case BUTTON4:
         wahl=3;
         break;

      case BUTTON5:
         wahl=4;
         break;

      case BUTTON6:
         wahl=5;
         break;

      case BUTTON7:
         wahl=6;
         break;

   }
   return(wahl);
}

curon()			/*Cursor an und Desktop ab*/
{
	graf_mouse(M_OFF,0L);
	Cconout(0x1b);
	Cconout('E');
	Cconout(0x1b);
	Cconout('e');
}

curoff()		/*Cursor ab und Desktop an*/
{
	Cconout(0x1b);
	Cconout('f');
	graf_mouse(M_ON,0L);
}
