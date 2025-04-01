******************************************
* SETGER                                 *
*                                        *
* Einrichten von cookies fÅr deutsches   *
*                                        *
* Tastaturlayout, Datums- und Zeitformat *
*                                        *
* sowie deutschen Desktop unter MultiTOS *
*                                        *
* by Uwe Seimet  (c) MAXON Computer 1993 *                  *
******************************************


GEMDOS  = 1
XBIOS   = 14
SUPEXEC = 38

_p_cookies = $5a0


         ttmem
         ttram
         loadfast


         text

         pea set_cookies(pc)
         move #SUPEXEC,-(sp)
         trap #XBIOS
         addq.l #6,sp
         clr -(sp)
         trap #GEMDOS


set_cookies:
         move.l _p_cookies,d0
         beq.s no_jar               ;kein cookie jar-
         move.l d0,a0
loop:    movem.l (a0)+,d0-d1
         tst.l d0                   ;Ende der cookies
         bne loop                   ;suchen
         subq.l #8,a0
         move.l #"_AKP",(a0)+       ;Sprache, Tastatur
         move.l #$0101,(a0)+
         move.l #"_IDT",(a0)+
         move.l #$112e,(a0)+        ;Datums-, Zeitformat
         movem.l d0-d1,(a0)
no_jar:  rts
