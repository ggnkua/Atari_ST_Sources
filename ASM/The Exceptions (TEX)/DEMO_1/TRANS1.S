;dieses programm laeuft nur in farbe
;source ab K-SEKA 1.5
;listing von Gunter (oder 6719)

x:
clr.l	-(sp)
move.w	#$20,-(sp)
trap	#1
addq.l	#6,sp
move.l	d0,ssp

linea	#$a			;maus aus

move.w	#4,-(sp)
trap	#14
addq.l	#2,sp
move.w	d0,oldres

clr.w	-(sp)			;low-res
move.l	#-1,-(sp)
move.l	#-1,-(sp)
move.w	#5,-(sp)
trap	#14
lea	12(sp),sp

move.l	$44e.w,screen		;videoadresse holen
movem.l	$ffff8240.w,d0-d7	;alte palette
movem.l d0-d7,oldpal		;merken

bsr	fillscreen		;hintergrundmuster aufbauen
movem.l	pal1(pc),d0-d7		;1. palette
movem.l	d0-d7,$ffff8240.w	;setzen

move.l	#dtab,dpos		;etwas initialisieren
move.l	screen(pc),clrzeiger

move.l	#dobbs,$4d2.w		;bewegt den transparentblock
bsr	keys
clr.l	$4d2.w

move.w	oldres(pc),-(sp)
move.l	#-1,-(sp)
move.l	#-1,-(sp)
move.w	#5,-(sp)
trap	#14
lea	12(sp),sp

movem.l	oldpal(pc),d0-d7	;alte palette
movem.l	d0-d7,$ffff8240.w	;wieder setzen
linea	#$9			;maus an

move.l	ssp(pc),-(sp)
move.w	#$20,-(sp)
trap	#1
addq.l	#6,sp

;illegal
clr.w	-(sp)			;oder terminate
trap	#1

;------------------------------------------------
fillscreen:
movem.l	graphic(pc),d6-d7	;dies sind daten fuer 16 pixel
				;daraus wird der hintergrund aufgebaut
move.l	screen(pc),a0
moveq	#100-1,d1		;100*2 zeilen ausfuellen

alles:
moveq	#20-1,d0		;20*16 pixel = eine zeile
zeile1:
move.l	d6,(a0)+
move.l	d7,(a0)+
dbf	d0,zeile1

moveq	#10-1,d0		;nur noch jede zweite spalte fuellen
zeile2:
move.l	d6,(a0)+
move.l	d7,(a0)+
addq.l	#8,a0
dbf	d0,zeile2

dbf	d1,alles
rts

graphic:
dc.w	$55AA,$33CC,$0FF0,$0000 ;<--- die letzte plane ist leer !!

;------------------------------------------------
dobbs:
move.l	clrzeiger(pc),a1	;vorherige position
moveq	#0,d7			;loeschen
bsr	block

clr.l	d2
move.l	dpos(pc),a2		;pointer auf tabelle
move.w	(a2)+,d2		;wert holen
tst.w	(a2)
bpl	w_dobbs			;negativ ist ende der tabelle
lea	dtab(pc),a2		;von vorne

w_dobbs:
move.l	a2,dpos
mulu	#160,d2			;ich weiž, daž es schneller geht
			;aber hier kommt es wirklich nicht darauf an

move.l	screen(pc),a1
add.l	d2,a1
add.w	#48,a1			;ab pixels 96 beginnt der block
move.l	a1,clrzeiger		;wert merken fuer n„chsten vbl
moveq	#-1,d7			;diesmal ausfuellen
bsr	block
rts

;---------------------
block:
moveq	#52,d0			;anzahl der zeilen (aus historischen 
move.l	#160,d1			;   gruenden..!!)
fill_zeilen:
move.w	d7,6(a1)		;es wird jeweils nur die letzte
move.w	d7,14(a1)		;plane geaendert
move.w	d7,22(a1)
move.w	d7,30(a1)
move.w	d7,38(a1)
move.w	d7,46(a1)
move.w	d7,54(a1)
move.w	d7,62(a1)		;(auf einer breite von 8*16 pixels)
add.l	d1,a1
dbf	d0,fill_zeilen
rts

;------------------------------------------------
keys:
move.w	#7,-(sp)		;konin
trap	#1
addq.l	#2,sp

cmp.b	#"0",d0			;zischen 0 und 4 ?
blt	keys
cmp.b	#"4",d0
bgt	keys

cmp.b	#"0",d0
beq	exit
ext.w	d0
sub.w	#$31,d0			;"1" ist nun 0
add.w	d0,d0
add.w	d0,d0

move.l	colors(pc,d0.w),a0	;zeiger auf pal1-4 holen
movem.l	(a0),d0-d7
movem.l	d0-d7,$ffff8240.w	;und die palette setzen
bra	keys

exit:
rts

;------------------------------------------------
colors: dc.l pal1,pal2,pal3,pal4

pal1:
dc.w	$000,$111,$222,$333,$444,$555,$666,$777
dc.w	$772,$772,$772,$772,$772,$772,$772,$772
pal2:
dc.w	$000,$111,$222,$333,$444,$555,$666,$777
dc.w	$772,$111,$222,$333,$444,$555,$666,$777
pal3:
dc.w	$000,$111,$222,$333,$444,$555,$666,$777
dc.w	$772,$772,$772,$772,$444,$555,$666,$777
pal4:
dc.w	$000,$111,$222,$333,$444,$555,$666,$777
dc.w	$400,$600,$720,$730,$740,$750,$760,$772

screen:		dc.l 0
ssp:		dc.l 0
oldres:		dc.w 0
oldpal:		blk.w 16,0

clrzeiger:	dc.l 0
dpos:		dc.l 0

dtab:
 dc.w 46,51,56,61,66	;wer keine lust hat, die ganze tabelle abzu-
 dc.w 72,78,84,78,72	;tippen, kann auch irgendwo aufh”ren
 dc.w 66,61,56,51,46	;dann aber die -1 am ende nicht vergessen !!!
 dc.w 41,37,33,30,26
 dc.w 23,20,17,15,13
 dc.w 11,09,08,07,06
 dc.w 05,05,05,05,05
 dc.w 06,07,08,09,11
 dc.w 13,15,17,20,23
 dc.w 26,30,33,37,41
 dc.w 46,51,56,61,66
 dc.w 72,78,84,78,72
 dc.w 66,61,56,51,46
 dc.w 42,38,34,31,27
 dc.w 24,22,19,17,16
 dc.w 15,15,15,15,16
 dc.w 17,19,22,24,27
 dc.w 30,34,38,41,45
 dc.w 49,53,56,60,63
 dc.w 66,68,71,72,73
 dc.w 74,74,74,74,72
 dc.w 71,69,66,63,60
 dc.w 57,53,50,46,42
 dc.w 38,34,31,28,25
 dc.w 22,20,18,16,15
 dc.w 15,15,15,16,17
 dc.w 19,21,24,27,30
 dc.w 34,37,41
 dc.w -1	;endekennung, nicht vergessen

;tschuež, bis zum naechsten mal (ich werde dann ueber randaufklapp
;				 routinen berichten)
