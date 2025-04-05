#include "ptvars.h"
overlay "screen"
extern int reverse();

getfont()
{
   asm
   {
         DC.W     0xa000
#ifdef COLOR
         MOVEA.L  4(A1), A0
#else
         MOVEA.L  8(A1), A0
#endif
         ADDA.L   #76, A0
         MOVE.L   (A0),STARTFONT(A4)
         MOVE.W   #3, -(A7)
         TRAP     #14
         ADDA.L   #2, A7
         MOVE.L   D0,SCREEN(A4)
   }
}


win_up()
{
   asm
   {
      CLR.L    D0
      CLR.L    D1
      CLR.L    D2
      MOVEA.L  SCREEN(A4), A0     ; phys_base nach A0 (DESTINATION)
      MOVE.W   s_up_y(A4), D0
#ifdef COLOR
      MULU     #160, D0
#else
      ADD.W    onli_vt52(A4), D0
      MULU     #80, D0
#endif
      ADDA.L   D0, A0             ; y-coordinate dazuaddieren

      MOVEA.L  A0, A1
      ADDA.L   screenline(A4), A1          ; A1 IST SOURCE

      MOVE.W   max_ycur(A4),D0
      SUBQ.W   #1, D0

      MOVE.W   s_up_x(A4), D2
#ifdef COLOR
      ASL.W    #1,D2
#endif
      ADDA.L   D2, A0             ; x-coordinate dazuaddieren
      ADDA.L   D2, A1

      MOVEA.L  A0, A2
      MOVEA.L  A1, A3

L1:   MOVE.W   s_up_w(A4), D1     ; BREITE IST INNERE SCHLEIFE

#ifndef COLOR
      ASR.W    #1, D1
#endif
      SUBQ.W   #1, D1
      CLR.L    D3
L2:   
#ifdef COLOR
      MOVE.L   0(A1), 0(A0)
      MOVE.L   160(A1), 160(A0)
      MOVE.L   320(A1), 320(A0)
      MOVE.L   480(A1), 480(A0)
      MOVE.L   640(A1), 640(A0)
      MOVE.L   800(A1), 800(A0)
      MOVE.L   960(A1), 960(A0)
      MOVE.L   1120(A1), 1120(A0)
#else
      MOVE.L   0(A1), 0(A0)
      MOVE.L   80(A1), 80(A0)
      MOVE.L   160(A1), 160(A0)
      MOVE.L   240(A1), 240(A0)
      MOVE.L   320(A1), 320(A0)
      MOVE.L   400(A1), 400(A0)
      MOVE.L   480(A1), 480(A0)
      MOVE.L   560(A1), 560(A0)
      MOVE.L   640(A1), 640(A0)
      MOVE.L   720(A1), 720(A0)
      MOVE.L   800(A1), 800(A0)
      MOVE.L   880(A1), 880(A0)
      MOVE.L   960(A1), 960(A0)
      MOVE.L   1040(A1), 1040(A0)
      MOVE.L   1120(A1), 1120(A0)
      MOVE.L   1200(A1), 1200(A0)
      ADDQ.L   #4, D3
#endif
      ADDQ.L   #4, A0
      ADDQ.L   #4, A1
      DBF      D1, L2
#ifndef COLOR
      ASR.W    #1,D3
      CMP.W    s_up_w(A4), D3
      BGE      LEFTSO
      MOVE.W   0(A1), 0(A0)
      MOVE.W   80(A1), 80(A0)
      MOVE.W   160(A1), 160(A0)
      MOVE.W   240(A1), 240(A0)
      MOVE.W   320(A1), 320(A0)
      MOVE.W   400(A1), 400(A0)
      MOVE.W   480(A1), 480(A0)
      MOVE.W   560(A1), 560(A0)
      MOVE.W   640(A1), 640(A0)
      MOVE.W   720(A1), 720(A0)
      MOVE.W   800(A1), 800(A0)
      MOVE.W   880(A1), 880(A0)
      MOVE.W   960(A1), 960(A0)
      MOVE.W   1040(A1), 1040(A0)
      MOVE.W   1120(A1), 1120(A0)
      MOVE.W   1200(A1), 1200(A0)
LEFTSO:
#endif
      ADDA.L   screenline(A4), A2
      ADDA.L   screenline(A4), A3
      MOVE.L   A2, A0
      MOVE.L   A3, A1
      DBF      D0, L1
   }
   clr_line(max_ycur);
   w_up++;
}


win_down()
{
   asm
   {
      CLR.L    D0
      CLR.L    D1
      CLR.L    D2

      MOVEA.L  SCREEN(A4), A0     ; phys_base nach A0 (SOURCE)
      MOVE.W   s_down_y(A4), D0
#ifdef COLOR
      MULU     #160, D0
#else
      MULU     #80, D0
#endif
      ADDA.L   D0, A0             ; y-coordinate dazuaddieren
      CLR.L    D0
      MOVE.W   s_down_x(A4), D0
#ifdef COLOR
      ASL.W    #1, D0
#endif
      ADDA.L   D0, A0             ; x-coordinate    - "" -
      CLR.L    D0
      MOVE.W   s_down_w(A4), D0
      ADDA.L   D0, A0             ; Breite dazu
      ADDA.L   D0, A0             ; nochmal weil in Worten angegeben

#ifdef COLOR
      ADDA.L   D0, A0             ; Breite dazu
      ADDA.L   D0, A0             ; nochmal weil in Worten angegeben
#endif

      MOVEA.L  A0, A1
      ADDA.L   screenline(A4), A0          ; A1 IST DESTINATION

      MOVEA.L  A0, A2
      MOVEA.L  A1, A3

      MOVE.W   max_ycur(A4),D0

      SUBQ.W   #1, D0

L1:
      MOVE.W   s_down_w(A4), D1   ; BREITE IST INNERE SCHLEIFE
#ifndef COLOR
      ASR.W    #1, D1
      BCC      UPSO
      MOVE.W   -(A1), -(A0)
      MOVE.W   -80(A1), -80(A0)
      MOVE.W   -160(A1), -160(A0)
      MOVE.W   -240(A1), -240(A0)
      MOVE.W   -320(A1), -320(A0)
      MOVE.W   -400(A1), -400(A0)
      MOVE.W   -480(A1), -480(A0)
      MOVE.W   -560(A1), -560(A0)
      MOVE.W   -640(A1), -640(A0)
      MOVE.W   -720(A1), -720(A0)
      MOVE.W   -800(A1), -800(A0)
      MOVE.W   -880(A1), -880(A0)
      MOVE.W   -960(A1), -960(A0)
      MOVE.W   -1040(A1), -1040(A0)
      MOVE.W   -1120(A1), -1120(A0)
      MOVE.W   -1200(A1), -1200(A0)
UPSO:
#endif
      SUBQ.L   #1, D1
L2:
#ifdef COLOR
      MOVE.L   -(A1), -(A0)
      MOVE.L   -160(A1), -160(A0)
      MOVE.L   -320(A1), -320(A0)
      MOVE.L   -480(A1), -480(A0)
      MOVE.L   -640(A1), -640(A0)
      MOVE.L   -800(A1), -800(A0)
      MOVE.L   -960(A1), -960(A0)
      MOVE.L   -1120(A1), -1120(A0)
#else
      MOVE.L   -(A1), -(A0)
      MOVE.L   -80(A1), -80(A0)
      MOVE.L   -160(A1), -160(A0)
      MOVE.L   -240(A1), -240(A0)
      MOVE.L   -320(A1), -320(A0)
      MOVE.L   -400(A1), -400(A0)
      MOVE.L   -480(A1), -480(A0)
      MOVE.L   -560(A1), -560(A0)
      MOVE.L   -640(A1), -640(A0)
      MOVE.L   -720(A1), -720(A0)
      MOVE.L   -800(A1), -800(A0)
      MOVE.L   -880(A1), -880(A0)
      MOVE.L   -960(A1), -960(A0)
      MOVE.L   -1040(A1), -1040(A0)
      MOVE.L   -1120(A1), -1120(A0)
      MOVE.L   -1200(A1), -1200(A0)
#endif
      DBF      D1, L2
      SUBA.L   screenline(A4), A2
      SUBA.L   screenline(A4), A3
      MOVE.L   A2, A0
      MOVE.L   A3, A1
      DBF      D0, L1

   }
   clr_line(0);
}

del_cursor()
{
   if(old_curs_adr)
      reverse(old_curs_adr);
   old_curs_adr=0l;
}

cursor()
{
   register long a;

   del_cursor();
   if(!calc_xy_adr())
      return;
   reverse(old_curs_adr=curs_adr);
}

asm{   

reverse:
	 MOVE.L   4(A7), A0
#ifdef COLOR
         NOT.B       (A0)
         NOT.B      2(A0)
         NOT.B    160(A0)
         NOT.B    162(A0)
         NOT.B    320(A0)
         NOT.B    322(A0)
         NOT.B    480(A0)
         NOT.B    482(A0)
         NOT.B    640(A0)
         NOT.B    642(A0)
         NOT.B    800(A0)
         NOT.B    802(A0)
         NOT.B    960(A0)
         NOT.B    962(A0)
	 TST.W    onli_vt52(A4)
         BNE      VT_52_REV
         NOT.B    1120(A0)
         NOT.B    1122(A0)
VT_52_REV:
#else

	 TST.W    onli_vt52(A4)
         BNE      VT_52_REV
         NOT.B    (A0)                    ; 16 SCANLINES ICKSOHREN
VT_52_REV:
         NOT.B    80(A0)
         NOT.B    160(A0)
         NOT.B    240(A0)
         NOT.B    320(A0)
         NOT.B    400(A0)
         NOT.B    480(A0)
         NOT.B    560(A0)
         NOT.B    640(A0)
         NOT.B    720(A0)
         NOT.B    800(A0)
         NOT.B    880(A0)
         NOT.B    960(A0)
         NOT.B    1040(A0)
         NOT.B    1120(A0)
         NOT.B    1200(A0)
#endif
         RTS
   }

#ifdef COLOR

o_putbig(x,y,c)
int x,y,c;
{
   asm
   {

         CLR.L    D0
         MOVE.W   x(A6), D0
         CLR.L    D1
         MOVE.W   y(A6), D1
         MULU.W   #160, D1
         ADD.L    SCREEN(A4), D1
         MOVE.L   D0, D2
         DIVU     #8, D2
         SWAP     D2
         MOVE.W   D2, D0
         TST.W    D0
         BNE      POINT1
         MOVE.W   #8, D0
POINT1:  SWAP     D2
         ANDI.L   #65535, D2
         ADD.L    D2, D1
         ADD.L    D2, D1
         BTST     #1, D1
         BEQ      GERADE
         SUBQ.L   #1, D1
GERADE:
         MOVE.L   D1, A0
         MOVE.L   STARTFONT(A4), A1
         MOVE.L   #7, D1                  ; ACHT SCANLINES
         CLR.L    D2
         MOVE.W   c(A7), D2               ; ASCII DES ZEICHENS
         ANDI.L   #255, D2
LOOP1:   CLR.L    D3

         MOVE.B   (A0), D3                ; AB HIER PLANE 0 SETZEN
         ASL.W    #8,D3
         MOVE.B   1(A0), D4
         OR.B     D4, D3
         CLR.L    D4
         MOVE.B   #255, D4
         ASL.W    D0, D4
         NOT.W    D4
         AND.W    D4, D3
         CLR.L    D4
         MOVE.B   0(A1, D2), D4
         ASL.W    D0, D4
         OR.W     D4, D3
         OR.B     D3, 1(A0)
         LSR.W    #8, D3
         OR.B     D3, (A0)

         MOVE.B   2(A0), D3             ; AB HIER PLANE 1 SETZEN
         ASL.W    #8,D3
         MOVE.B   3(A0), D4
         OR.B     D4, D3
         CLR.L    D4
         MOVE.B   #255, D4
         ASL.W    D0, D4
         NOT.W    D4
         AND.W    D4, D3
         CLR.L    D4
         MOVE.B   0(A1, D2), D4
         ASL.W    D0, D4
         OR.W     D4, D3
         OR.B     D3, 3(A0)
         LSR.W    #8, D3
         OR.B     D3, 2(A0)

         ADDA.L   #160, A0
         ADDA.L   #256, A1
         DBF      D1,LOOP1
   }
}

putbig(x,y,c)
int x,y,c;
{
   asm
   {

         CLR.L    D0
         MOVE.W   x(A6), D0
         CLR.L    D1
         MOVE.W   y(A6), D1
         MULU.W   #160, D1
         ADD.L    SCREEN(A4), D1
         MOVE.L   D0, D2
         DIVU     #8, D2
         SWAP     D2
         MOVE.W   D2, D0
         TST.W    D0
         BNE      POINT1
         MOVE.W   #8, D0
POINT1:  SWAP     D2
         ANDI.L   #65535, D2
         ADD.L    D2, D1
         ADD.L    D2, D1
         BTST     #1, D1
         BEQ      GERADE
         SUBQ.L   #1, D1
GERADE:
         MOVE.L   D1, A0
         MOVE.L   STARTFONT(A4), A1
         MOVE.L   #7, D1                  ; ACHT SCANLINES
         CLR.L    D2
         MOVE.W   c(A7), D2               ; ASCII DES ZEICHENS
         ANDI.L   #255, D2
LOOP1:   CLR.L    D3

         MOVE.B   (A0), D3                ; AB HIER PLANE 0 SETZEN
         ASL.W    #8,D3
         MOVE.B   1(A0), D4
         OR.B     D4, D3
         CLR.L    D4
         MOVE.B   #255, D4
         ASL.W    D0, D4
         NOT.W    D4
         AND.W    D4, D3
         CLR.L    D4
         MOVE.B   0(A1, D2), D4
         ASL.W    D0, D4
         OR.W     D4, D3
         MOVE.B   D3, 1(A0)
         LSR.W    #8, D3
         MOVE.B   D3, (A0)

         MOVE.B   2(A0), D3             ; AB HIER PLANE 1 SETZEN
         ASL.W    #8,D3
         MOVE.B   3(A0), D4
         OR.B     D4, D3
         CLR.L    D4
         MOVE.B   #255, D4
         ASL.W    D0, D4
         NOT.W    D4
         AND.W    D4, D3
         CLR.L    D4
         MOVE.B   0(A1, D2), D4
         ASL.W    D0, D4
         OR.W     D4, D3
         MOVE.B   D3, 3(A0)
         LSR.W    #8, D3
         MOVE.B   D3, 2(A0)

         ADDA.L   #160, A0
         ADDA.L   #256, A1
         DBF      D1,LOOP1
   }
}

#else

o_putbig(x,y,c)
int x,y,c;
{
   asm
   {

         CLR.L    D0
         MOVE.W   x(A6), D0
         CLR.L    D1
         MOVE.W   y(A6), D1
         MULU.W   #80, D1
         ADD.L    SCREEN(A4), D1
         MOVE.L   D0, D2
         DIVU     #8, D2
         SWAP     D2
         MOVE.W   D2, D0
         TST.W    D0
         BNE      POINT1
         MOVE.W   #8, D0
POINT1:  SWAP     D2
         ANDI.L   #65535, D2
         ADD.L    D2, D1
         MOVE.L   D1, A0
         MOVE.L   STARTFONT(A4), A1
         MOVE.L   #15, D1
         CLR.L    D2
         MOVE.W   c(A7), D2
         ANDI.L   #255, D2
LOOP1:   CLR.L    D3
         MOVE.B   (A0), D3
         ASL.W    #8,D3
         MOVE.B   1(A0), D4
         OR.B     D4, D3
         CLR.L    D4
         MOVE.B   #255, D4
         ASL.W    D0, D4
         NOT.W    D4
         AND.W    D4, D3
         CLR.L    D4
         MOVE.B   0(A1, D2), D4
         ASL.W    D0, D4
         OR.W     D4, D3
         OR.B     D3, 1(A0)
         LSR.W    #8, D3
         OR.B     D3, (A0)
         ADDA.L   #80, A0
         ADDA.L   #256, A1
         DBF      D1,LOOP1
   }
}

putbig(x,y,c)
int x,y,c;
{
   asm
   {

         CLR.L    D0
         MOVE.W   x(A6), D0         ; X-KOORDINATE LINKS OBEN VOM CELL
         CLR.L    D1
         MOVE.W   y(A6), D1         ; Y-KOORDINATE LINKS OBEN VOM CELL
         MULU.W   #80, D1           ; Y * 80 (BYTES) +
         ADD.L    SCREEN(A4), D1    ; SCREENBASE IST ADRESSE VON 0/Y
         MOVE.L   D0, D2
         DIVU     #8, D2            ; X/8 = X IN BYTES
         SWAP     D2                ; REST DER DIVISION AUFHEBEN FUER
         MOVE.W   D2, D0            ; VERSCHIEBUNG 
         TST.W    D0
         BNE      POINT1            ; NEIN
         MOVE.W   #8, D0            ; JA, ALSO 8 MAL VERSCHIEBEN = 0 MAL
POINT1:  SWAP     D2                ; X/8 WIEDER NACH D2.W
         ANDI.L   #65535, D2        ; HIWORD OESCHEN
         ADD.L    D2, D1            ; X/8 ZUR ADRESSE DAZUADDIEREN
         MOVE.L   D1, A0            ; = ADRESSE IM BILDSCHIRMSPEICHER
         MOVE.L   STARTFONT(A4), A1 ; ADRESSE DER ZEICHENSATZDATEN
         MOVE.L   #15, D1           ; 16 SCANLINES (DBF = 15)
         CLR.L    D2
         MOVE.W   c(A6), D2         ; AUSZUGEBENDES ZEICHEN
         ANDI.L   #255, D2          ; HIBYTE LOESCHEN
LOOP1:   CLR.L    D3
         MOVE.B   (A0), D3          ; 1.BYTE AUS BILDSCHIRM
         ASL.W    #8, D3            ; INS HYBYTE SCHIEBEN
         MOVE.B   1(A0), D4         ; 2.BYTE AUS BILDSCHIRM
         OR.B     D4, D3            ; INS LOBYTE OREN
         MOVE.L   #255, D4          ; 255 = 8 GESETZTE PIXEL
         ASL.W    D0, D4            ; JE NACHDEM NACH LINKS SCHIEBEN
         NOT.W    D4                ; UMDREHEN (ALLES GESETZT BIS AUF 8)
         AND.W    D4, D3            ; 8 PIXEL LOESCHEN
         CLR.L    D4
         MOVE.B   0(A1, D2), D4     ; DATEN DER SCANLINE NACH D4
         ASL.W    D0, D4            ; JE NACHDEM NACH LINKS SCHIEBEN
         OR.W     D4, D3            ; UND IN DIE VORHER LEERGEMACHTEN 8 PIXEL
         MOVE.B   D3, 1(A0)         ; LOBYTE ZURUECKSCHREIBEN
         LSR.W    #8, D3            ; HIBYTE INS LOBYTE
         MOVE.B   D3, (A0)          ; HIBYTE ZURUECKSCHREIBEN
         ADDA.L   #80, A0           ; 80 BYTES = EINE PIXELZEILE
         ADDA.L   #256, A1          ; ZUR STARTADRESSE VOM FONT 256
         DBF      D1,LOOP1          ; DAS GANZE 16 MAL
   }
}
#endif
