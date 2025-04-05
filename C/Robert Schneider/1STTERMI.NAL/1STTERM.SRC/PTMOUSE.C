overlay "mousemov"

#include <osbind.h>
#include "ptvars.h"

extern char *index();

extern int vq_mouse();
extern int set_mouse();
extern int vex_curv();
extern int v_show_c();
extern int OLDMMOVE(), OLDBUTT(),_LINEAVAR();
extern int _OLDMMOVE(),_MSPOINT(),_IRMOUSE();
extern int _IRSTART(),_MMOVE(),_IOREC(),_TXNEW();

asm
{
   _LINEAVAR:   DC.W  0X4E71,0X4E71
   _OLDMMOVE:   DC.W  0X4E71,0X4E71
   _MSPOINT:    DC.W  0X4E71,0X4E71
   _IRSTART:    DC.W  0X4E71,0X4E71
   _IOREC:      DC.W  0X4E71,0X4E71
}



iswurst()
{
   asm
   {

_MMOVE:                                ; EINSPRUNG BEI MOUSEMOVE.
         MOVEM.L  D0-A6, -(A7)
         MOVE.W   SR, -(A7)
         ORI.W    #0X0700, SR
         MOVEA.L  _MSPOINT(PC), A0
         TST.W    (A0)                 ; Umschalter aktiv ?
         BEQ      END                  ; nein.
         MOVE.W   #1,4(A0)             ; mouse soll ein sein ?
END:
         MOVE.W   (A7)+, SR
         MOVEM.L  (A7)+, D0-A6
         MOVEA.L  _OLDMMOVE(PC), A3
         JMP      (A3)

/* NACHFOLGENDER SCHROTT LéUFT IM VAU-Bé-EL */

_IRMOUSE:
         MOVE.W   SR, -(A7)
         ORI.W    #0X0700, SR
         MOVEA.L  _MSPOINT(PC),A0      ; Mousearray nach A0
         TST.W    (A0)                 ; Umschalter aktiv ?
         BEQ      IREND                ; Nein.
         TST.W    2(A0)                ; ist Mouse ein ?
         BNE      IREND                ; ja.
         TST.W    4(A0)                ; soll Mouse ein sein ?
         BEQ      IREND                ; Nein.

         MOVE.W   #1, 2(A0)            ; mouse_is = 1
         MOVEA.L  _LINEAVAR,A0
         MOVEA.L   4(A0),A1            ; CONTRL array  
         CLR.W    2(A1)                ; CONTRL[1]=0; 
         MOVE.W   #1,6(A1)             ; CONTRL[3]=1;
         MOVEA.L   8(A0),A1            ; INTIN array 
         CLR.W    (A1)                 ; INTIN[0]=0; 
         DC.W     0XA009               ; mouse einschalten.

IREND:
         MOVE.W   (A7)+, SR
         RTS                           ;


/* Weil der Atari kein RTS/CTS kann mÅssen wir ihm auf die SprÅnge helfen. */

_TXNEW:
         MOVE.L   A0, -(A7)
         MOVEA.L  _IOREC(PC), A0
         BTST     #2, 32(A0)
         BEQ      TXATARI
         MOVEA.L  #0XFFFA01, A0
         BTST     #2, (A0)
         BEQ      TXATARI
         BCLR     #2, 14(A0)                   /* INTERRUPT BIT LôSCHEN */
         MOVE.L   (A7)+, A0
         RTE

TXATARI:
         MOVE.L   (A7)+, A0
         TRAP     #5
         RTE
   }
}

rtsinit(a)
int a;
{
   long super;

   super=Super(0l);
   if(!a)
   {
      asm
      {
         MOVE.L   0X94, D0            /* TRAP 5 ADRESSE HOLEN    */
         MOVE.L   D0 , 0X128          /* INTERRUPT MFP SETZEN    */
      }
      Super(super);
      return;
   }

   asm
   {
         MOVE.L   0X128, D0            /* MFP INTERRUPT */
         MOVE.L   D0, 0X94             /* TRAP 5 */
         MOVE.L   iorec(A4), A0        /* IOREC ADR */
         LEA      _IOREC(PC), A1       /* SICHERN FöR INTERRUPT */
         MOVE.L   A0,(A1)
         LEA      _TXNEW(PC), A0       /* NEUER MFP INTERRUPT */
         MOVE.L   A0, 0X128
   }
   Super(super);

}

mousemov(p)
long p;
{
   long *movvex;
   long a,*point,*pend;

   if(p<0)
   {
      asm
      {
         MOVE.L   _MSPOINT(PC), D0      ; Gebe die Addresse des Mouse-Arrays
         UNLK     A6                    ; zurÅck
         RTS
      }
   }
   a=Super(0l);

   if(p==0)
   {
      asm
      {
         PEA      movvex(A6)            ; Puffer fÅr die RÅckgabe
         MOVE.L   _OLDMMOVE(PC), -(A7)  ; Alter Mousevektor
         MOVE.W   vdi_handle(A4), -(A7)
         JSR      vex_curv(PC)          ; Zeiger zurÅckstellen
         ADDA.L   #10, A7
         MOVE.L  _IRSTART(PC), A0       ; VBL-routine lîschen
         CLR.L    (A0)
      }
      Super(a);
      return;
   }

   point = (long *) 0x456l;
   point = (long *) *point;
   pend  = point +7;

   while (*point && point<pend)
      point++;
   asm
   {
         LEA      _LINEAVAR,A0
         MOVE.L   line_a_var(A4),(A0)

         LEA      _MSPOINT(PC), A0           /* setze Mouse-Array */
         MOVE.L   p(A6), (A0)

         LEA      _OLDMMOVE(PC), A0          /* setze alte Mouseadresse */
         MOVE.L   A0, movvex(A6)

         LEA     _IRMOUSE(PC), A0            /* setze VBL-Routinen pointer */
         MOVE.L   point(A6), A1
         MOVE.L   A0, (A1)

         LEA     _IRSTART(PC), A0            /* setze VBL-Routine */
         MOVE.L   point(A6), (A0)
   }
   Super(a);
   vex_curv(vdi_handle,_MMOVE,movvex);

}

mouseset(m_on)
int m_on;
{
   register int *p;

   if(!m_on)
      set_mouse();         /* mouse einschalten bei mouseset(0) */
   else
      asm{ DC.W 0XA00A }   /* mouse ausschalten bei mouseset(1) */

   asm
   {
      MOVE.L _MSPOINT(PC), p
   }

   p[0]=m_on;  /* mhide */
   p[1]=0;     /* mis   */      
   p[2]=0;     /* mshould */
   p[3]=0;     /* monline */
}

overlay "main"

do_exec(how,over)
int how;
char *over;
{
   int a,b,defdrive;
   int kind,tos=0;
   GRECT work;
   char name[40],pfad[80];
   char para[80],*p;
   char defpath[128];
   char s[60];
   long seppin,seppout;

   if((long)buf_point!=(long)buf_start)
      if(brain_alert(1,"[1][Puffer wird gelîscht !][OK|Abbruch]")==2)
         return(0);

   if(!how)
   {
      defdrive=Dgetdrv();
      Dgetpath(defpath,defdrive);

      pfad[0]=name[0]=0;

      if(!file_select("Programm aufrufen",pfad,name,""))
         return(0);

      Dsetdrv(pfad[0]-'A');
      Dsetpath(&pfad[2]);

      strcat(pfad,name);
      p=index(name,'.');
      para[0]=32; para[1]=0;
      if(p&&!strcmp(p,".TTP"))
      {
         tos=1;
         file_name("Programm aufrufen","öbergabeparameter fÅr:","",pfad,para+1);
      }
      if(p&&!strcmp(p,".TOS"))
         tos=1;
   }
   else
   {
      strcpy(&para[1],over);
      para[0]=' ';
      strcpy(pfad,"1ST_COMP.PRG");
      strcpy(name,pfad);
   }

   own_loaded=0;
   if(own_table)
      if(Mfree(own_table))
         brain_alert(1,"[3][Mfree-Error|own_table][+]");

   if(autoda)
   {
      autoda=0;
      autocode=0;
   }

   if(Mfree(reserved))
      brain_alert(1,"[3][Mfree-Error|reserved][+]");

   wind_close(wi_han1);
   wind_delete(wi_han1);

   graf_shrinkbox(SMXY,SMWH,window_box);

   asm
   {
      MOVE.L   OLDMMOVE(PC), seppin(A6)
   }
   vex_motv(vdi_handle,seppin,&seppout);

   asm
   {
      MOVE.L   OLDMBUTT(PC), seppin(A6)
   }
   vex_butv(vdi_handle,seppin,&seppout);

   mousemov(0l);
   rtsinit(0);

   *iorec = old_io;

   form_dial(3,0l,0l,SXY,SWH);
#ifdef COLOR
   clr_box(SXY,639,9);
#else
   clr_box(SXY,639,17);
#endif
   b=strlen(name);
   b<<=3;
   b=320-(b>>1);

   for(a=0;a<strlen(name);a++)
   {
#ifdef COLOR
      o_putbig(b+(a<<3),1,name[a]);
#else
      o_putbig(b+(a<<3),2,name[a]);
#endif
   }

   if(tos)
      Cconws("\33E\33e");


   if(online)
      wind_update(END_MCTRL);

   b=Pexec(0,pfad,para,"");

   if(online)
      wind_update(BEG_MCTRL);

   if(tos)
      Cconws("\33f");

   if(b)
      form_error(0-b);

   wind_set(0,WF_NEWDESK,0l,0l);
   form_dial(3,0l,0l,SXY,SWH);

   if(!how)
   {
      Dsetdrv(defdrive);
      Dsetpath(defpath);
   }

   wholefree=Malloc(-1l);

   reserved=(char *)Malloc(wholefree);
   if(!reserved)
   {
      brain_alert(1,"[3][Nicht der selbe Speicher|verfÅgbar !][OK]");
      wholefree-=5000;
      reserved=(char *)Malloc(wholefree);
      if(!reserved)
      {
         form_error(39); ptexit(-2);
      }
   }
   box_space=reserved;
   if(wholefree<100000l)
   {
      form_alert(1,"[1][Ihr Programm|hat nicht genug|Speicher|Åbrig gelassen !][TERM beenden]");
      ptexit(-2);
   }
   save.fd_addr=(long)((long)box_space+20000l);
   new_io.ibuf=(char *)((long)save.fd_addr+32000l);
   *iorec=new_io;

   buf_size=wholefree-84256l;
   buf_start=buf_point=(char *)((long)new_io.ibuf+32000l);
   buf_end=buf_start+buf_size;

   vex_butv(vdi_handle,MBUTTON,&p);   /* Ab jetzt habe ich    */
   vex_motv(vdi_handle,MMOVE,&p);     /* das groûe Sagen !!!  */

   mousemov(&mouse);    /* Mausabschaltung initialisieren */
   rtsinit(1);

/* exactly bis hierher */

 /************ MenÅleisteninit **********************/

   menu_bar(deskmenu,1);
   menu_bar(deskmenu,0);
   init_menu();

 /************* Windowinitialisierung **************/

   wind_update(BEG_UPDATE);

   hide_mouse();

   if(onli_vt52)
#ifdef COLOR
      kind=1;
#else
      kind=0;
#endif
   else
      kind=47;

   wi_han1=wind_create(kind,gl_xfull-1,gl_yfull,gl_wfull,gl_hfull);
   if(wi_han1 == -1)
   {
      wind_update(END_UPDATE);
      graf_mouse(ARROW,0l);
      brain_alert(1,"[1][Kein Window zur VerfÅgung !][OK]");
      ptexit(1);
      Pterm0();
   }
   wind_set(wi_han1,WF_NAME,windtitel);

   gl_xfull = align_x(gl_xfull);

   redraw_w=redraw_h=0;

   do_open(wi_han1,SMXY,align_x(gl_xfull)-1,gl_yfull,gl_wfull,gl_hfull);
   do_full(wi_han1,0);

   wi_han_off=wi_han1;
   set_xy_cur(wi_han1);
   clr_window();
   save_screen();
   top_window=wi_han1;

   PFEIL;
   show_mouse();
   wind_update(END_UPDATE);
   return(1);
}
