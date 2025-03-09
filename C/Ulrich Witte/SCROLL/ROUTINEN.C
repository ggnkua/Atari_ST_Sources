/*   SCROLL - ROUTINEN  fÅr MEGAMAX LASER C   */
/*          von Ulrich Witte                  */
/*      (c) 1991 MAXON Computer               */

#include <osbind.h>
#include "scroll.h"

scroll_lr(scroll,warten,pixel,richtung) 
int pixel;
register int richtung;
long warten;
SCROLLER *scroll;
{
  register char *quelle;
  register int zeilen;
  register int words;
  register long offset;
  asm
  { 
       movea.l scroll(A6),A0 ;Adr. der Struktur
       move.w  (A0),words   ;Vars aus Struktur in
                            ;in Register schieben
       move.l  2(A0),offset 
       move.w  6(A0),zeilen 
       movea.l 8(A0),quelle  ;Adresse des Blocks
       move.w  pixel(A6),D2  
       subq.w  #1,D2
anzahl:move.l  warten(A6),D3 
pause1:dbf     D3,pause1     ;Pause 
                   ;Scrollgeschwindigkeit absolut
       movea.l quelle,A0       
       move.w  zeilen,D1       
       cmpi.w  #1,richtung   ;TRUE = linksherum
       beq.s   links1            
rechts1:move.w  -2(A0),D0 
       roxr.w  #1,D0 
       move.w  words,D0      ;worte pro Zeile  
       suba.l  offset,A0     ;Ptr auf Zeilenanf.
rechts2:roxr.w  (A0)+        ;alle Bytes 1
                             ;Pixel weiterrollen
       dbf     D0,rechts2  
       suba.l  #80,A0        ;==> 1 Zeile hîher
       dbf     D1,rechts1
       dbf     D2,anzahl
       bra.s   ende          ;das war's schon
       
links1:move.w  (A0),D0  
       roxl.w  #1,D0
       move.w  words,D0         
       adda.l  offset,A0       
links2:roxl.w  -(A0)
       dbf     D0,links2
       adda.l  #80,A0        ;==> nÑchste Zeile
       dbf     D1,links1
       dbf     D2,anzahl
ende:                
  }
}
                           
scroll_ou(scroll,warten,anzahl,richtung) 
int anzahl;
register int richtung;
long warten;
SCROLLER *scroll;
{
   register int zeilen;
   register int words;
   register long offset;
   register char *anfang,*ende,*lauf,*last_line; 
 
   asm
   { 
       movea.l scroll(A6),A0  ;Adr. der Struktur
       move.w  (A0),words  
       move.l  2(A0),offset
       move.w  6(A0),zeilen 
       movea.l 8(A0),A1      ;Adresse des Blocks
       movea.l A1,last_line 
       move.w  zeilen,D0     ;==> Zeilenzahl * 80
       mulu.w  #80,D0        ;==> anpassen
       cmpi.w  #1,richtung 
       beq.s   add              
       suba.l  D0,last_line  ;Adr der 1. Zeile
       bra.s   cont
add:   adda.l  D0,last_line  ;Adr der letzten 
                           ;Zeile fÅr hochsrollen
cont:  movea.l A1,anfang   ;Anfangs-Adr. buffern
       movea.l last_line,ende ;last_line buffern
       move.w  anzahl(A6),D3  ;GesamtdurchlÑufe
       subq.w  #1,D3
z1:    move.w  zeilen,D1      ;1. Schleife: 
                              ;GesamtdurchlÑufe
       movea.l anfang,lauf    ;Laufptr auf Anfang
       movea.l anfang,A1      ;Adr. der ersten
                         ;und letzten Zeile laden
       movea.l ende,last_line 
z:     move.l  warten(A6),D0  ;2. Schleife:
                              ;zeilenweise
pause: dbf     D0,pause       ;Pause...
       move.w  words,D2       ;Worte pro Zeile
       cmpi.w  #1,richtung
       beq.s   wo 
                    ; nach unten:
wu:    move.w  -82(lauf),-(lauf) ;==> 3.Schleife:
 ;Jede Zeile wortweise eine Zeile tiefer schieben
       dbf     D2,wu      
       adda.l  offset,lauf     
       suba.l  #80,lauf    ;==> nÑchste Zeile
       dbf     D1,z
       move.w  words,D2  ;letzte Zeile in erste
ll:    move.w  -(A1),-(last_line)  
       dbf     D2,ll
       dbf     D3,z1 
       bra.s   end      ;fertig
                        ;nach oben:
wo:    move.w  80(lauf),(lauf)+   ;==>
  ;jede Zeile wortweise eine Zeile hîher schieben
       dbf     D2,wo  
       suba.l  offset,lauf 
       adda.l  #80,lauf    ;==> nÑchste Zeile
       dbf     D1,z
       move.w  words,D2 
fl:    move.w  (A1)+,(last_line)+
               ;erste Zeile in die letzte Zeile
       dbf     D2,fl 
       dbf     D3,z1
end:      
   }
}

scrollinit(k,scroll,links_oder_oben)  
register SCROLLER *scroll;
register RECT *k;
int links_oder_oben;
{
   register int help;
/* x-Koordinaten geteilt durch 16 ergibt An- */
/* zahl der Worte pro Zeile */    
/* Die x-Koordinaten der Struktur */
/* dÅrfen nicht geÑndert werden */
   register int x1 = k->x1 >> 4;   
   register int x2 = k->x2 >> 4;   
   
/* Monitor-Adresse holen */
   scroll->adr = (char *)Physbase();  
/* Differenz merken */   
   help = x2 - x1;
   if (links_oder_oben)           
/* ==> Adresse auf linke obere Ecke setzen */
      scroll->adr += (x1 << 1) + (k->y1 * 80);
   else                            
/* ==> oder rechts unten als Adresse eintragen */
      scroll->adr += (x2 << 1) + 
      ((k->y2 - 1) * 80);  
   scroll->words = help - 1;
/* Bytes = Worte * 2 */
   scroll->offset = (long)(help << 1);
/* Zeilen - 1 */ 
   scroll->zeilen = k->y2 - k->y1 - 1;
/* Pixelzahl = Differenz * 16 */
   scroll->pixel = help << 4; 
}
