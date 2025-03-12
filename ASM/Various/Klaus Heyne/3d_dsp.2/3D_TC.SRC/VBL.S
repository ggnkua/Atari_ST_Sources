;------------------------------------------------
; DSP als Grafik-Koprozessor
; Assembler-Routinen zum Host-Programm
;                      (c) 1995 by MAXON-Computer
;                      Autor: Klaus Heyne         
;------------------------------------------------
GLOBL vbl_init,vbl_exit,clr_val
GLOBL screen1,scrsize,clrflag,zeit,scancode
;------------------------------------------------
; VBL-Routine installieren/entfernen (SUPERVISOR)
;------------------------------------------------
vbl_init:		
	moveq	  #0,D1			;Suche "Null-Eintrag"
	move.l  #_vbl,D2		;Setze neue Routine
	bra	  vbl_inex
vbl_exit:
	move.l  #_vbl,D1     ;Suche die Routine
	moveq	  #0,D2        ;Setze "Null-Eintrag"
	
vbl_inex:   				;Zeiger auf Zeigertabelle
   movea.l $0456,A0		;aller VBlank-Prozesse
	move.w  $0454,D0     ;Anzahl der maximal akti-
   subq.w  #1,D0			;vierbaren Routinen
vblinex2: 
   cmp.l   (A0)+,D1		;Eintrag suchen
   beq	  vblinex3			
   dbra	  D0,vblinex2
   rts						;return (-1) (Fehler)
vblinex3:   
   move.l  D2,-(A0)	   ;neuer Eintrag
	moveq	  #0,D0
   rts						;return(0)	
;------------------------------------------------
; logischen Bildschirm l”schen (VBL-Routine)
; und Tastatur-Scancode holen
;------------------------------------------------
_vbl: 
   tst.w   clrflag       ;screen l”schen ?
   beq     _vbl2
   movem.l D0-D1/A0,-(SP)
   move.l  screen1,A0    ;aktueller logbase
   move.l  scrsize,D0    ;Bildschirmgr”že
   lsr.l   #2,D0			 ;in longwords
   move.w  clr_val,D1    ;Hintergrundfarbe
   swap    D1
   move.w  clr_val,D1	 ;als longword
cls:							
   move.l  D1,(A0)+		
   subq.l  #1,D0			
   bgt	  cls					
   clr.w   clrflag		 ;Flag l”schen
   move.l  $4BA,D0		 ;Zeitmessung eines
   move.l  timer,D1		 ;gesamten Zyklus'
   move.l  D0,timer		 
   sub.l	  D1,D0
   move.w  D0,zeit		 ;Zeit merken
   movem.l (SP)+,D0-D1/A0
_vbl2:						 ;Tastaturscancode holen	
   move.b  $FFFFFC02,scancode+1
   rts
;------------------------------------------------
   DATA	
;------------------------------------------------
timer:     DC.L 0
					