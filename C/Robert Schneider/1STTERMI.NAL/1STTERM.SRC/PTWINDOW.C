overlay "window"

#include <osbind.h>
#include <gembind.h>
#include "ptvars.h"

extern int reverse();
extern int win_up();
extern int cursor(), del_cursor();
extern long calc_xy_adr();

int when_cr=80;

align_x(x)
{
   return( (x&0xfff0) + ((x&0x000c) ? 0x0010 : 0));
}

clr_window()
{
   int hc;

   hc=window_box.g_h;
   hide_mouse();

#ifdef COLOR
      asm
      {
         CLR.L    D0
         CLR.L    D1
         CLR.L    D2
         MOVEA.L  SCREEN(A4), A0     ; phys_base nach A0 (DESTINATION)
         MOVE.W   window_box+2(A4), D0
         MULU     #160, D0
         ADDA.L   D0, A0             ; y-coordinate dazuaddieren

         MOVE.W   max_ycur(A4), D0     ; y-zaehler nach D0(aeussere Schleife)

         MOVE.W   s_up_x(A4), D2
         ASL.W    #1, D2
         ADDA.L   D2, A0             ; x-coordinate dazuaddieren

         MOVEA.L  A0, A2
L1:
         CLR.L    D1
         MOVE.W   s_up_w(A4), D1     ; BREITE IST INNERE SCHLEIFE
         SUBQ.W   #1, D1
L2:      
         CLR.L    160(A0)
         CLR.L    320(A0)
         CLR.L    480(A0)
         CLR.L    640(A0)
         CLR.L    800(A0)
         CLR.L    960(A0)
         CLR.L    1120(A0)
         CLR.L    (A0)+
         DBF      D1, L2
         ADDA.L   screenline(A4), A2
         MOVE.L   A2, A0
         DBF      D0, L1

         MOVE.L   screenline(A4),D1             
         MULU     max_ycur(A4),D1
         ADD.L    screenline(A4),D1     
         DIVU     #160,D1
         MOVE.W   hc(A6), D0
         SUB.W    D1,D0
         SUB.W    #1,D0
         BLE      ALL_CLEAR

PL1:
         MOVE.W   s_up_w(A4), D1     ; BREITE IST INNERE SCHLEIFE
         SUBQ.W   #1, D1
PL2:     CLR.L    (A0)+
         DBF      D1, PL2
         ADDA.L   #160, A2
         MOVE.L   A2, A0
         DBF      D0, PL1
ALL_CLEAR:
      }
#else
      asm
      {
         CLR.L    D0
         CLR.L    D1
         CLR.L    D2
         MOVEA.L  SCREEN(A4), A0     ; phys_base nach A0 (DESTINATION)
         MOVE.W   window_box+2(A4),D0
         MULU     #80, D0
         ADDA.L   D0, A0             ; y-coordinate dazuaddieren

         MOVE.W   max_ycur(A4), D0     ; y-zaehler nach D0(aeussere Schleife)

         MOVE.W   s_up_x(A4), D2
         ADDA.L   D2, A0             ; x-coordinate dazuaddieren

         MOVEA.L  A0, A2

L1:      MOVE.W   s_up_w(A4), D1     ; BREITE IST INNERE SCHLEIFE
         ASR.W    #1, D1
         SUBQ.W   #1, D1
         CLR.L    D3
L2:      CLR.L    0(A0)
         CLR.L    80(A0)
         CLR.L    160(A0)
         CLR.L    240(A0)
         CLR.L    320(A0)
         CLR.L    400(A0)
         CLR.L    480(A0)
         CLR.L    560(A0)
         CLR.L    640(A0)
         CLR.L    720(A0)
         CLR.L    800(A0)
         CLR.L    880(A0)
         CLR.L    960(A0)
         CLR.L    1040(A0)
         CLR.L    1120(A0)
         CLR.L    1200(A0)
         ADDQ.L   #4, D3
         ADDQ.L   #4, A0
         DBF      D1, L2
         ASR.W    #1,D3
         CMP.W    s_up_w(A4), D3
         BGE      LEFTSO
         CLR.W    0(A0)
         CLR.W    80(A0)
         CLR.W    160(A0)
         CLR.W    240(A0)
         CLR.W    320(A0)
         CLR.W    400(A0)
         CLR.W    480(A0)
         CLR.W    560(A0)
         CLR.W    640(A0)
         CLR.W    720(A0)
         CLR.W    800(A0)
         CLR.W    880(A0)
         CLR.W    960(A0)
         CLR.W    1040(A0)
         CLR.W    1120(A0)
         CLR.W    1200(A0)
LEFTSO:
         ADDA.L   screenline(A4), A2
         MOVE.L   A2, A0
         DBF      D0, L1

         MOVE.L   screenline(A4),D1             
         MULU     max_ycur(A4),D1
         ADD.L    screenline(A4),D1     
         DIVU     #80,D1
         MOVE.W   hc(A6), D0
         SUB.W    D1,D0
         
         BLE      ALL_CLEAR
         SUBQ.W   #1, D0
                        
PL1:     MOVE.W   s_up_w(A4), D1     ; BREITE IST INNERE SCHLEIFE IN D1
         ASR.W    #1, D1
         SUBQ.W   #1, D1
         CLR.L    D3
PL2:     CLR.L    (A0)
         ADDQ.L   #4, D3
         ADDQ.L   #4, A0
         DBF      D1, PL2
         ASR.W    #1,D3
         CMP.W    s_up_w(A4), D3
         BGE      PLEFTSO
         CLR.W    (A0)
PLEFTSO:
         ADDA.L   #80, A2
         MOVE.L   A2, A0
         DBF      D0, PL1
ALL_CLEAR:
      }
#endif

   xcur=ycur=0; 
   show_mouse();
  
}

do_redraw()
{
   GRECT box;
   int pxyarray[8];
   if(mouse.mhide)
   {
      mouse.monline=1;
      mouse.mis=mouse.mshould=mouse.mhide=0;
      asm
      {
         DC.W  0xA00A
      }
   }
   else
      hide_mouse();


   wind_get(wi_han1,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);

   while(box.g_w && box.g_h)
   {
      if(box.g_x-window_box.g_x+box.g_w>redraw_w||
         box.g_y-window_box.g_y+box.g_h>redraw_h)
      {
         box.g_w=0;
         set_xy_cur(wi_han1);
         clr_window();
         save_screen();
      }
      else
      {
         pxyarray[0]=box.g_x-window_box.g_x;
         pxyarray[1]=box.g_y-window_box.g_y;
         pxyarray[2]=pxyarray[0]+box.g_w-1;
         pxyarray[3]=pxyarray[1]+box.g_h-1;
         pxyarray[4]=box.g_x;
         pxyarray[5]=box.g_y;
         pxyarray[6]=box.g_x+box.g_w-1;
         pxyarray[7]=box.g_y+box.g_h-1;
         vro_cpyfm(vdi_handle,3,pxyarray,&save,&screen);
         wind_get(wi_han1,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
      }
   }
   if(mouse.monline)
   {
      mouse.monline=0;
      mouse.mhide=1;
   }
   else
      show_mouse();
}


rc_equal(p1,p2)
GRECT *p1,*p2;
{
/*p1 = current  p2 = full*/

   if(p1->g_x>p2->g_x||
      p1->g_y>p2->g_y||
      p1->g_w<p2->g_w||
      p1->g_h<p2->g_h)
      return(FALSE);

   return(TRUE);
}

do_open(w,org_xy,xy,wh)
int w;
long org_xy;
long xy,wh;
{
   graf_growbox(org_xy,SMWH,xy,wh);
   wind_open(w,xy,wh);
}


set_xy_cur(handle,oxy,owh)
int handle;
long oxy,owh;
{

   int pxyarray[4];
   register long *pl;

   pl =(long *) &window_box;
   if(handle>0)
      wind_get(handle,WF_WXYWH,
         &window_box.g_x,&window_box.g_y,&window_box.g_w,&window_box.g_h);

   if(handle==-1)
   {
      *pl++ = oxy;
      *pl   = owh;
   }

   s_up_x=window_box.g_x>>3;
   s_down_x= s_up_x&=0xfffe;
   s_up_y=window_box.g_y;


   s_down_w=s_up_w=window_box.g_w>>4;

   null_xcur=window_box.g_x;
   null_ycur=window_box.g_y;

   max_xcur=(window_box.g_w>>3)-1;

   if(onli_vt52)
   {
      max_ycur = 24;

#ifdef COLOR
      s_down_h = s_up_h = (max_ycur*7);
      screenline = 1120l;
#else
      s_down_h = s_up_h = (max_ycur*15);
      screenline = 1200l;
      s_up_y++;
#endif
      s_down_y=window_box.g_y+s_down_h;
   }
   else
   {

#ifdef COLOR
      max_ycur=(window_box.g_h>>3)-1;
      s_down_h = s_up_h = (max_ycur<<3);
#else
      max_ycur=(window_box.g_h>>4)-1;
      s_down_h = s_up_h = (max_ycur<<4);
#endif

      screenline = 1280l;
      s_down_y=window_box.g_y+s_down_h-1;
   }
   xcur=0;
   ycur=0;
}

do_full(wh,grower)
int wh,grower;
{
   GRECT prev;
   GRECT curr;
   GRECT full;
   GRECT help;

   hide_mouse();
   wind_get(wi_han1,WF_CXYWH,&curr.g_x,&curr.g_y,&curr.g_w,&curr.g_h);
   wind_get(wi_han1,WF_PXYWH,&prev.g_x,&prev.g_y,&prev.g_w,&prev.g_h);
   wind_get(wi_han1,WF_FXYWH,&full.g_x,&full.g_y,&full.g_w,&full.g_h);
   if(rc_equal(&curr,&full))
   /* Window ist schon fulled, also letzte Windowgr”že benutzen */
   {
      if(grower)
         graf_shrinkbox(prev,full);

      wind_calc(1,47,prev,&help.g_x,&help.g_y,&help.g_w,&help.g_h);
      help.g_w=align_x(help.g_w);
      wind_calc(0,47,help,&prev.g_x,&prev.g_y,&prev.g_w,&prev.g_h);
      wind_set(wi_han1,WF_CXYWH,prev);
      set_xy_cur(wi_han1);
      do_redraw();
   }
   else
   /* Window kleiner als fulled, also gr”žte Windowgr”že benutzen */
   {
      if(grower)
         graf_growbox(curr,full);
      wind_calc(1,47,full,&help.g_x,&help.g_y,&help.g_w,&help.g_h);
      help.g_w=align_x(help.g_w);
      wind_calc(0,47,help,&full.g_x,&full.g_y,&full.g_w,&full.g_h);
      wind_set(wi_han1,WF_CXYWH,full);
      set_xy_cur(wi_han1);
      do_redraw();
   }
   show_mouse();
}

save_screen()
{
   int a;
   int xy[8];
   long *p;

   wind_get(wi_han1,WF_WXYWH,&window_box.g_x,&window_box.g_y,&window_box.g_w,&window_box.g_h);

   xy[0]=window_box.g_x;
   xy[1]=window_box.g_y;
   xy[2]=window_box.g_x+window_box.g_w-1;
   xy[3]=window_box.g_y+window_box.g_h-1;
   xy[4]=0;
   xy[5]=0;
   xy[6]=window_box.g_w-1;
   xy[7]=window_box.g_h-1;
   redraw_w=window_box.g_w;
   redraw_h=window_box.g_h;
   if(mouse.mhide)
   {
      mouse.monline=1;
      mouse.mis=mouse.mshould=mouse.mhide=0;
   }

   hide_mouse();

   vro_cpyfm(vdi_handle,3,xy,&screen,&save);

   if(mouse.monline)
   {
      mouse.mhide=1;
      mouse.monline=0;
   }
   else
      show_mouse();
}


out_s(string)
char *string;
{
   out_string=1;
      out_c(string);
   out_string=0;
}

out_c(out)
char *out;
{
   if(mouse.mhide)
   {
      mouse.monline=1;
      if(mouse.mis)
         asm{ DC.W  0xA00A }

      mouse.mis=mouse.mshould=mouse.mhide=0;
   }      

   if(curs_on)
      del_cursor();

   asm
   {
         
NO_CURS:
         CLR.L    D7
         TST.W    out_string(A4)          ; FLAG OB STRING ODER ZEICHEN
         BNE      OUT_S

         MOVE.W   out(A6), D7             ; HOLE AUS 'OUT' DAS ZEICHEN UND
         ANDI.L   #0XFF, D7
         BRA      OUT_C                   ; UND RAUS DAMIT

OUT_S:   MOVEA.L  out(A6), A0             ; HOLE AUS DEM STRING 'OUT' DAS
         ADDQ.L   #1, out(A6)             ; ZEICHEN, ' OUT++ ' UND LEGE ES
         MOVE.B   (A0), D7                ; IN 'BYTE' AB.
         BEQ      FEDDIG
         ANDI.L   #0XFF, D7
OUT_C:
         CMPI.W   #14, D7                 ; CONTROL CHARACTER ?
         BGE      NO_CONTROL              ; ANSCHEINEND NICHT

         CMPI.W   #7,D7                   ; KLINGLER ?
         BNE      NO_BELL                 ; NEIN

         PEA      sound(A4)               ; JA, SOUNDTABLE AUF STACK
         MOVE.W   #32,-(A7)               ; Dosound
         TRAP     #14
         ADDQ.L   #6,A7
         BRA      DONE

NO_BELL:
         CMPI.W   #8, D7                  ; BACKSPACE ?
         BNE      NO_BS                   ; NEIN

         TST.W    xcur(A4)                ; JA, X-POSITION GR™žER NULL ?
         BEQ      DONE                    ; NEIN
         SUBQ.W   #1, xcur(A4)            ; X-POSITION DEKREMENTIEREN
         MOVE.W   out_string(A4), -(A7)   ; STRINGFLAG SICHERN
         CLR.W    out_string(A4)          ; STRINGFLAG L™SCHEN
         MOVE.W   vtrevers(A4), -(A7)     ; REVERSFLAG SICHERN
         CLR.W    vtrevers(A4)            ; REVERSFLAG L™SCHEN
         MOVE.W   #32, -(A7)              ; EIN SPACE
         JSR      out_c(PC)               ; AUSGEBEN
         ADDQ.L   #2, A7                  ; STACK KORRIGIEREN
         MOVE.W   (A7)+, vtrevers(A4)     ; REVERSFLAG RESTAURIEREN
         MOVE.W   (A7)+, out_string(A4)   ; STRINGFLAG RESTAURIEREN
         SUBQ.W   #1, xcur(A4)            ; UND X-POSITION DEKREMENTIEREN
         BRA      DONE

NO_BS:
         CMPI.W   #13, D7                 ; CR ?
         BNE      NO_CR                   ; NEIN
         CLR.W    xcur(A4)                ; JA, X-POSITION AUF NULL SETZEN
         TST.W    lf_screen(A4)           ; LF NACH CR BEI SCREEN GESETZT ?
         BNE      DO_LF                   ; JA
         BRA      DONE                    ; NEIN , FEDDIG

NO_CR:
         CMPI.W   #10, D7                 ; LF ?
         BNE      NO_CONTROL              ; NEIN
DO_LF:
         MOVE.W   ycur(A4), D1            ; HOLE Y-POSITION
         CMP.W    max_ycur(A4), D1        ; KLEINER MAX-Y-POSITION ?
         BGE      MAXY                    ; NEIN
         ADDQ.W   #1, ycur(A4)            ; JA, Y-POSITION INKREMENTIEREN
         BRA      DONE                    ; ABFLUG
MAXY:    JSR      win_up(PC)              ; WINDOW HOCHSCROLLEN
         BRA      DONE                    ; ABFLUG

NO_CONTROL:
         JSR      calc_xy_adr(PC)   ;
         TST.L    D0
         BEQ      DONE1
         MOVE.L   D0, A0            ; = ADRESSE IM BILDSCHIRMSPEICHER
         MOVE.L   STARTFONT(A4), A1 ; ADRESSE DER ZEICHENSATZDATEN
         ADDA.L   D7, A1

#ifdef COLOR

         MOVE.B   (A1), (A0)        ; DATEN DER SCANLINE
         MOVE.B   (A1), 2(A0)
         MOVE.B   256(A1), 160(A0)
         MOVE.B   256(A1), 162(A0)
         MOVE.B   512(A1), 320(A0)
         MOVE.B   512(A1), 322(A0)
         MOVE.B   768(A1), 480(A0)
         MOVE.B   768(A1), 482(A0)
         MOVE.B   1024(A1), 640(A0)
         MOVE.B   1024(A1), 642(A0)
         TST.W    onli_vt52(A4)     ; OB VT52 EIN
         BNE      VTCHAR            ; 15 ZEILEN DAS ZEICHEN
         MOVE.B   1280(A1), 800(A0)
         MOVE.B   1280(A1), 802(A0)
         MOVE.B   1536(A1), 960(A0)
         MOVE.B   1536(A1), 962(A0)
         MOVE.B   1792(A1), 1120(A0)
         MOVE.B   1792(A1), 1122(A0)
         BRA      NOVTCHAR
VTCHAR:
         MOVE.B   1536(A1), 800(A0)
         MOVE.B   1536(A1), 802(A0)
         MOVE.B   1792(A1), 960(A0)
         MOVE.B   1792(A1), 962(A0)
NOVTCHAR:

#else

         TST.W    onli_vt52(A4)     ; OB VT52 EIN
         BNE      VTCHAR            ; 15 ZEILEN DAS ZEICHEN
         MOVE.B   (A1), (A0)  ; DATEN DER SCANLINE NACH D4
VTCHAR:
         MOVE.B   256(A1), 80(A0)
         MOVE.B   512(A1), 160(A0)
         MOVE.B   768(A1), 240(A0)
         MOVE.B   1024(A1), 320(A0)
         MOVE.B   1280(A1), 400(A0)
         MOVE.B   1536(A1), 480(A0)
         MOVE.B   1792(A1), 560(A0)
         MOVE.B   2048(A1), 640(A0)
         MOVE.B   2304(A1), 720(A0)
         MOVE.B   2560(A1), 800(A0)
         MOVE.B   2816(A1), 880(A0)
         MOVE.B   3072(A1), 960(A0)
         MOVE.B   3328(A1), 1040(A0)
         MOVE.B   3584(A1), 1120(A0)
         MOVE.B   3840(A1), 1200(A0)
#endif
         TST.W    onli_vt52(A4)        ; HAMMA VT52
         BEQ      DONE1                ; HAMMA NICH
         TST.W    vtrevers(A4)         ; HAMMA REVERS
         BEQ      NOREVERSE            ; HAMMA NICH
         MOVE.L   A0, -(A7)            ; GANZEN 15 SCANLINES NOTTEN
         JSR      reverse(PC)          
         ADDA.L   #4, A7
NOREVERSE:
         TST.W    vtwrap(A4)              ; WRAPFLAG ON
         BNE      DONE1                   ; NEIN ALSO X NUR ERH™HEN
         MOVE.W   xcur(A4), D0
         CMP.W    max_xcur(A4), D0
         BGE      DONE
         ADDQ.W   #1, xcur(A4)            ; ERH™HEN
         BRA      DONE

DONE1:
         MOVE.W   xcur(A4), D0
         CMP.W    when_cr(A4), D0
         BGE      Y_UP
         ADDQ.W   #1, xcur(A4)
         BRA      DONE

Y_UP:    CLR.W    xcur(A4)
         MOVE.W   ycur(A4), D0            ; HOLE Y-POSITION
         CMP.W    max_ycur(A4), D0        ; KLEINER MAX-Y-POSITION ?
         BGE      MAXY2                   ; NEIN
         ADDQ.W   #1, ycur(A4)            ; JA, Y-POSITION INKREMENTIEREN
         BRA      DONE                    ; ABFLUG
MAXY2:   JSR      win_up(PC)              ; WINDOW HOCHSCROLLEN
DONE:
         TST.W    out_string(A4)
         BEQ      FEDDIG
         BRA      OUT_S
FEDDIG:
   }
   if(curs_on)
      cursor();
   if(mouse.monline)
   {
      mouse.mhide=1;
      mouse.monline=0;
   }
}

long calc_xy_adr()
{
   register long adr;

   if((unsigned)xcur >max_xcur||(unsigned)ycur > max_ycur)
      return 0;

   adr=(long)SCREEN;


#ifdef COLOR
   adr+=(ycur*screenline)+xcur+xcur;      /* offset vom window */
   adr+=(null_ycur*160)+(null_xcur>>2);   /* offset vom Screen */
   adr-=((null_xcur>>3)+xcur)&1;
#else
   adr+=(ycur*screenline)+xcur;          /* offset vom window */
   adr+=(null_ycur*80)+(null_xcur>>3);   /* offset vom Screen */
#endif

   curs_adr=adr;
   return(adr);
}

