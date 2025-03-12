;#######################################
;#          Die Hexer, Teil 5          #
;#######################################
;#               Listing 1             #
;#       The Exceptions (Gunter)       # 
;#        35 Farben pro Zeile          #
;# (c) M&T, ST-Magazin, November 1988  #
;#######################################
;
;
; Listing 1: Erste Testversion fÅr
; mehr als 16 Farben pro Zeile 
; fÅr K-SEKA ab 1.5  Programm
; von Gunter (6719)
; auch falls wir uns wiederholen:
; Das Programm lÑuft nur in Farbe


x:
clr.l  -(sp)
move.w #$20,-(sp)
trap   #1
addq.l #6,sp
move.l d0,s_sp

move.l #clr,-(sp)	;Bildschirm loeschen
move.w #9,-(sp)
trap   #1
addq.l #2,sp

move.w #$2700,sr	; keine interrupts bitte !
move.b #02,$ffff820a.w	; 50 Hz vertical sync .
move.w #$8240,a0	; $ff8240 = Hintergrundfarbe
move.w (a0),old_back
moveq  #-1,d0		; Schleifenzaehler

loop:			; das ist die 512 Takzyklenschleife
move.w #$777,(a0)
move.w #$766,(a0)
move.w #$755,(a0)
move.w #$744,(a0)
move.w #$733,(a0)
move.w #$722,(a0)
move.w #$700,(a0)
move.w #$710,(a0)
move.w #$720,(a0)
move.w #$730,(a0)
move.w #$740,(a0)
move.w #$750,(a0)
move.w #$760,(a0)
move.w #$770,(a0)
move.w #$761,(a0)
move.w #$752,(a0)
move.w #$743,(a0)
move.w #$734,(a0)
move.w #$725,(a0)
move.w #$716,(a0)
move.w #$727,(a0)
move.w #$737,(a0)
move.w #$747,(a0)
move.w #$757,(a0)
move.w #$767,(a0)

move.w #$577,(a0)
move.w #$566,(a0)
move.w #$555,(a0)
move.w #$544,(a0)
move.w #$533,(a0)
move.w #$522,(a0)
move.w #$500,(a0)
move.w #$510,(a0)
move.w #$520,(a0)
move.w #$530,(a0)
move.w #$540,(a0)
move.w #$550,(a0)
move.w #$560,(a0)
move.w #$570,(a0)
move.w #$561,(a0)
move.w #$552,(a0)

nop
nop			;zum Ausgleich fÅr die 512 Taktzyklen
dbf    d0,loop		; und von vorne

move.w #$2300,sr	; interrupts erlauben !
move.w old_back,(a0)
move.l s_sp,-(sp)
move.w #$20,-(sp)
trap   #1
addq.l #6,sp

;illegal
clr.w  -(sp)
trap   #1


s_sp: dc.l 0
old_back: dc.w 0
clr:  dc.b 27,"E",0
even
