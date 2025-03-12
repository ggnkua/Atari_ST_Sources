/* MagicSLM - Hauptmodul                       */
/* by Bernd Spellenberg & Harald Sch”nfeld     */
/* (c) Maxon 1995                              */

# define EXTERN extern
# include <portab.h>
# include <tos.h>
# include "global.h"

/* Resourcen includen                          */
# include "magicslm.h"
# include "magicslm.rsh"
# include "magicslm.rh"

# define WAIT  2500     /* Timer alle 2.5 Sek. */

/* Prototypen                                  */
void  FixTree(OBJECT *);
int   FileSelect(char *,char *,char *);
int   SetupDialog(void);
int   TosVersion(void);

char  AccName[]="  MagicSLM"; /* Name im Men  */
OBJECT *Setup,             /* Konfig. Dialog   */
       *Print;             /* Statusanzeige    */

char  InPath[256]="C:\\DEFAULT.PCL",
      OutPath[256]="C:\\DEFAULT.PCX";

int   Input, Output;       /* I/O Modi         */
int   TimerMode=0;         /* Timer aktiv j/n  */

void main (void)
{
   int   MsgBuffer[8];     /* AES Message Buf. */
   int   Dummy;
   int   AplId, MenuId;
   int   EventRes;      /* Resultat des Events */

/* Programm Anmeldung erfolgreich              */
   if((AplId = appl_init())>=0) {
   
      if((MenuId=       /* Men-Namenseintrag  */
          menu_register(AplId,AccName))>=0) {
   
         InitPcl();     /* PCL Interpreter-Init*/
         
/* Resourcen fixen                             */
         Setup = (OBJECT *)rs_trindex [SETUP];
         FixTree(Setup);
         Print = (OBJECT *)rs_trindex [PRINT];
         FixTree(Print);

/* Event-Hauptschleife                         */

         for(;;) {
         
/* Auf AES Message und evtl. Timer warten      */
            EventRes=evnt_multi(
                     MU_MESAG|TimerMode,
                     0,0,0,0,0,0,0,
                     0,0,0,0,0,0,
                     MsgBuffer,WAIT,0,
                     &Dummy,&Dummy,
                     &Dummy,&Dummy,
                     &Dummy,&Dummy);
            
            if(EventRes==MU_TIMER) { /* Timer? */
               if(SRec()) { /* Zeichen an AUX? */
/* Konvertierung aufrufen                      */
                  StartConversion();
                  StopScan();    /* Timer aus  */
               }
            } else {
/* Messages verarbeiten                        */
               switch(MsgBuffer[0]) {
               
/* Accessory angew„hlt, Konfigdialog ”ffnen    */
                  case AC_OPEN:
                     if(MsgBuffer[4] ==
                                 MenuId) {
                        SetupDialog();
                     }
                  break;
                  
                  case AC_CLOSE:
                  break;
               }
            }
         }
      }
   }
}


/* Setup-Dialog ”ffnen und abarbeiten          */

int SetupDialog(void)
{
   int Res;               /* Gedrckter Button */
   
   InitDlg(Setup);        /* Dialog darstellen */

   do {               /* Usereingaben abfragen */
      
      Res=form_do(Setup,ROOT)&0x7FFF;
      
   } while ( (Res!=STOP) && (Res!=START));
   
   CloseDlg();            /* Dialog schliessen */

   Setup[Res].ob_state&=~SELECTED; /* Gedrckte*/
                        /* Taste deselektieren */
   if (Res==STOP)        /* Falls STOP gew„hlt */
      StopScan(); /* Abfrage der ser. Schnitt- */
                         /* stelle unterlassen */
   else {             /* Eingabeform ermitteln */

      if(Setup[MODEMIN].ob_state&SELECTED)
         Input=MODEMINPUT;
      else if(Setup[FILEIN].ob_state&SELECTED)
         Input=FILEINPUT;

                      /* Ausgabeform ermitteln */
      if(Setup[SLMOUT].ob_state&SELECTED)
         Output=SLMOUTPUT;
      else if(Setup[PCXOUT].ob_state&SELECTED)
         Output=PCXOUTPUT;
      
      if(Input==FILEINPUT) {   /* PCL-Filename */
                                   /* abfragen */
         if(!FileSelect(InPath,"PCL",
               "HP-PCL Inputfile angeben")) {
            StopScan();
            return 0;
         }
      }

      if(Output==PCXOUTPUT) {  /* PCX-Filename */
                                   /* abfragen */
         if(!FileSelect(OutPath,"PCX",
               "PCX Outputfile angeben")) {
            StopScan();
            return 0;
         }
      }

      evnt_timer(100,0);   /* Bildschirmaufbau */
                                   /* abwarten */
      StartScan();        /* Wandlung beginnen */
   }
   
   return 1;
}

static int s_x, s_y, s_w, s_h; /* Object-Koord.*/

/* Dialog zeichnen und Bildschirmkontrolle     */
/* bernehmen                                  */

void InitDlg(OBJECT *object)
{
   wind_update(BEG_UPDATE);
   wind_update(BEG_MCTRL);
   form_center(object,&s_x,&s_y,&s_w,&s_h);
   form_dial(FMD_START,s_x,s_y,s_w,s_h,
                       s_x,s_y,s_w,s_h);
   objc_draw(object,ROOT,MAX_DEPTH,
                       s_x,s_y,s_w,s_h);
}

/* Objekt des Dialogs neu zeichnen             */

void UpdateDlg(OBJECT *Dlg, int Obj)
{
   objc_draw(Dlg,Obj,0,s_x,s_y,s_w,s_h);
}

/* Dialog schliessen und Kontrolle abgeben     */

void CloseDlg(void)
{
   form_dial(FMD_FINISH,s_x,s_y,s_w,s_h,
                        s_x,s_y,s_w,s_h);
   wind_update(END_MCTRL);
   wind_update(END_UPDATE);
}

/* Resourceobjekt fixen                        */

void FixTree(OBJECT *tree)
{
   int object  = 0;

   do {
      rsrc_obfix (tree, object);
   } while (! (tree[object++].ob_flags &
                                     LASTOB));
}

/* Fileselectbox darstellen                    */

int FileSelect(char *Path,char *Ext,char *Info)
{
   char FileName[32];       /* Reiner Filename */
   char *Pos;
   char OldPath[128]; /* Kopie des alten Pfads */
   int Ret;            /* Rckgabewert der Box */
   
   evnt_timer(100,0); /* Screenaufbau abwarten */
   
   strcpy(OldPath,Path);       /* Pfad sichern */

   evnt_timer(100,0);                  /* s.o. */
   
   Pos=strrchr(Path,'\\')+1;   /* Reinen File- */
   strcpy(FileName,Pos);        /* namen holen */

   strcpy(Pos,"*.");      /* Suchmaske an Pfad */
   strcat(Path,Ext);               /* anh„ngen */
   
     /* Filedialog je nach Tosversion mit oder */
                   /* ohne Infotext darstellen */
   if (TosVersion()>=0x0104)
      fsel_exinput(Path,FileName,&Ret,Info);
   else
      fsel_input(Path,FileName,&Ret);
   
   if(!Ret)   /* Falls Abbruch gew„hlt, alten */
      strcpy(Path,OldPath);  /* Pfad behalten */
   else               /* sonst neuen benutzen */
      strcpy(strrchr(Path,'\\')+1L,FileName);

   return(Ret); /*Rckgabe der Box weitergeben*/
}

/* Tosversion bestimmen                       */

int TosVersion(void)
{
   long Save;
   unsigned int Tos;
   
   Save=Super(0L);
   Tos=*(unsigned int *)(*(long *)(0x4f2)+2);
   Super((void *)Save);
   return(Tos);
}

/* šberprfen ob Button mit Maus angew„hlt     */

int CheckButton(void)
{
   int Mx, My, MkState, MbState;
   
                        /* Mausstatus abfragen */
   graf_mkstate(&Mx, &My, &MbState, &MkState);

   if(MbState&1) {  /* Falls linke Taste gedr. */

       /* Mauspos. mit den Buttons vergleichen */
      /* wenn gleich, Buttonnr.+255 zurckgeben*/
      
      if (objc_find(Print,ABBR,0,Mx,My)>=0) {
         return ABBR+255;
      }
      if (objc_find(Print,FF,0,Mx,My)>=0) {
         return FF+255;
      }
      if (objc_find(Print,RESET,0,Mx,My)>=0) {
         return RESET+255;
      }
      return 0;
   }
   else
      return 0;
}

/* Button selektieren oder deselektieren und   */
/* zeichnen                                    */

void SelectButton(OBJECT *Dlg, int Obj, int Mode)
{
   if(Mode)
      Dlg[Obj].ob_state|=SELECTED;
   else
      Dlg[Obj].ob_state&=~SELECTED;
   
   UpdateDlg(Dlg,Obj);
}
