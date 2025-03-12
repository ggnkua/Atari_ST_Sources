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

