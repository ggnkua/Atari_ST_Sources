********************************************************************
* BUSFIX.S  korrigiert fehlerhafte Zugriffe auf den Adrežbereich   *
* aužerhalb von ST- und TT-RAM.                                    *
* Problem: fehlerhafte Zugriffe auf das ST-RAM, die eine           *
* Adresse im TT-RAM ansprechen, k”nnen so nicht abgefangen werden. *
* (Dieser Fehler tritt z.B. bei TEMPUS V2.x auf.                   *
********************************************************************


SETEXEC =  5
BIOS    = 13

PTERMRES= 49
GEMDOS  =  1


       text

       pea fix
       move #2,-(sp)            ;Nummer des Busfehler-Vektors
       move #SETEXEC,-(sp)
       trap #BIOS
       addq.l #8,sp
       move.l 4(sp),a0          ;Adresse der Basepage
       move.l 12(a0),a0         ;Programml„nge
       lea $100(a0),a0          ;L„nge der Basepage
       clr -(sp)
       pea (a0)
       move #PTERMRES,-(sp)
       trap #GEMDOS             ;das war schon alles

*nach einem Busfehler befindet sich die Adresse, auf die
*zugegriffen wurde, auf dem Stack und kann manipuliert werden
fix:
       and.l #$00ffffff,16(sp)  ;oberes Adrežbyte ausblenden
       rte                      ;Buszyklus wiederholen


Listing 1
----------------------------------------------------------------------------


***********************************************************
* Diese Routine zur Behandlung einer Privilegverletzung   *
* erm”glicht auf dem TT Zugriffe auf die unteren 8 Bits   *
* des Statusregisters im User-Mode.                       *
* Ein Zugriff auf die oberen 8 Bits ist so nicht m”glich. *
***********************************************************


       move.l (a0),-(sp)
       move.l 6(sp),a0          ;Pointer auf Opcode
       cmp #$40c0,(a0)
       bcs Bomben               ;kein SR-Zugriff-
       cmp #$40f9,(a0)
       bhi Bomben               ;kein SR-Zugriff-
       move.b #$42,(a0)         ;SR im Programmcode durch CCR ersetzen
       move.l (sp)+,a0
       move.l d0,-(sp)
       movec cacr,d0
       or #$0808,d0             ;beide Caches l”schen
       movec d0,cacr
       move.l (sp)+,d0
       rte                      ;Befehl wiederholen

Bomben:Bomben werfen...

Listing 2
----------------------------------------------------------------------------


************************************************************
* Hier wird geprft, ob ein Programm auf einem TT l„uft.   *
* Falls ja wird die Variable ttflg entsprechend gesetzt.   *
* Diese Routine muž im Supervisor-Modus ausgefhrt werden! *
************************************************************


_p_cookies = $5a0


         text

tttest:
         move.l _p_cookies,d0   ;cookie jar vorhanden?
         beq nocookie           ;nein-
         move.l d0,a0
loop:    movem.l (a0)+,d0-d1
         tst.l d0               ;Ende der Liste?
         beq nocookie           ;ja-
         cmp.l #"_MCH",d0       ;cookie fr Computertyp?
         bne loop               ;nein-
         cmp.l #$00020000,d1    ;TT (oder gar neuer)?
         scc ttflg
nocookie:rts


         bss

ttflg:   ds.b 1

Listing 3
----------------------------------------------------------------------------


*******************************************************************
* Listing 3 noch einmal als C-Funktion, in Anlehnung an [4].      *
* Das Ergebnis ist TRUE, falls es sich um einen TT handelt.       *
*******************************************************************


#define MCH 0x5f4d4348l /* Cookie fr Prozessortyp */


struct cookie
  {
  long c;
  long v;
  };


boolean tttest()
{
  long oldssp=0;
  struct cookie *cookie_ptr;

  if (!Super(1l)) oldssp=Super(0l);
  cookie_ptr= *(struct cookie **) 0x5a0;
  if (oldssp) Super(oldssp);
  if (cookie_ptr)
    {
    while (cookie_ptr->c)
      {
      if (cookie_ptr->c!=MCH) cookie_ptr++;
      else break;
      }
    if (cookie_ptr->c) return(cookie_ptr->v>=0x00020000l);
    }
  return(FALSE);
}

