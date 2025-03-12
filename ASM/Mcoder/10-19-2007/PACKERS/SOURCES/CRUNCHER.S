******************************
* New version 12/03/89 23h10 *
******************************


gemdos	equ 1
fopen	equ $3d
fread	equ $3f
fseek	equ $42
fclose	equ $3e
fcreate	equ $3c
fwrite	equ $40
c_conin	equ	1
c_conws	equ	9
b_conin	equ	2
b_constat equ	1


**********************
go:

	lea	tble,a6
Main_Loop
	cmp.b	#0,(a6)
	beq	bye
	
	move.l	a6,d0
	bsr	outstr
	move.l	#en,d0
	bsr	outstr
	
	move.l	a6,a1
	move.l	a6,a3
	move.l	#buf_load,a0
	jsr	load
	
	move.l	#buf_load,start
	move.l	#buf_load,d0
	add.l	len,d0
	move.l	d0,stop
	move.l	#buf,write
	jsr	kill
	
ch_point
	cmp.b	#".",(a3)+
	bne	ch_point
	
	move.b	#"C",(a3)+
	move.b	#"O",(a3)+
	move.b	#"M",(a3)+
	
	
	
	move.l	a6,d0
	jsr	outstr
	move.l	#fin,d0
	jsr	outstr

	move.l	a2,d0
	sub.l	#buf,d0
	move.l	a6,a1
	move.l	#buf,a0
	move.l	d0,len
	jsr	create
	
	
	move.l	a3,a6
	adda.l	#1,a6
	bra	Main_Loop
bye
	clr.l	-(sp)
	trap	#1

en
	dc.b	" en ",0
	even
fin
	dc.b	10,13,0,0,0
	even
; cruncher program v1.2
;save buf2 , a2

kill:
	movem.l	d0-d7/a0/a1/a3-a6,-(sp)
	
	move.l start,a0	; a0 is culow (current low addr.)
	move.l stop,a1	; a1 is end of data
	move.l write,a2	; a2 is write address
	moveq #1,d2	; prepare bit buffer
	clr.w d1	; clears jmplen (we haven't skipped any byte !!!)
	clr.l d7	; clear checksum

noteocrunch:
	bsr crunch	; crunches from culow. if a crunch occured
		; returns d0 false else returns d0 true
	tst.b d0
	beq.S crunched
	addq.w #1,d1
	cmpi.w #264,d1
	bne.S nojmp
	bsr dojmp

nojmp:
crunched:
	cmp.l a0,a1
	bgt.S noteocrunch

	bsr dojmp	; do not forget the last jmp

	bsr write1lwd		; flush buffer
	move.l d7,(a2)+		; write checksum

hh	move.l start,a0
	move.l stop,a1
	move.l a1,d2	; compute write original's length
			; (for decruncher)
	sub.l a0,d2
halte:	move.l d2,(a2)+		; then save it

	clr.l d0
	clr.l d1
	clr.l d2
	clr.l d3
	clr.l d4
	clr.l d5
	lea cnt,a3
	movem.w (a3)+,d0-d5
	move.l a2,a3
	sub.l a0,a3
	move.l stop,a4
	sub.l a2,a4
	
	movem.l	(sp)+,d0-d7/a0/a1/a3-a6
	rts

crunch:
	move.l a0,a3
	add.l #ofset,a3	; if culow + offset
	cmp.l a1,a3		; greater than end of data
	ble.S nottop
	move.l a1,a3		; set it to end of data

nottop:
	moveq #$1,d5		; initialize maxlen to 1
	move.l a0,a5		; scan of #offset next bytes
	addq #$1,a5

contcrunch:

	move.b (a0),d3		; save first byte in d3
	move.b $1(a0),d4	; and second byte in d4

quickfind:
	cmp.b (a5)+,d3		; find in the next space a two byte
	bne.S contfind		; duplicate with (culow)
	cmp.b (a5),d4
	beq.S lenfind

contfind:
	cmp.l a5,a3
	bgt.S quickfind
	bra endquickfind

lenfind:
	subq #1,a5		; correction from quickfind
	move.l a0,a4		; compare to (culow)

scan:
	move.b (a4)+,d3		; as quickfind but check length
			; of the duplicate
	cmp.b (a5)+,d3
	bne.S endequ
	cmp.l a5,a3
	bgt.S scan

endequ:
	move.l a4,d3	; compute length
	sub.l a0,d3	; of equal zones
	subq.l #1,d3
	cmp.l d3,d5	; if less than max length yet found
	bge.S nocrunch	; do not try to crunch

	move.l a5,d4	; compute displacement
	sub.l a0,d4	; from culow
	sub.l d3,d4
	subq #1,d4	; offset is there !!!!!!!

	cmp.l #$4,d3
	ble.S small

	moveq  #$6,d6		; we here have a zone of more than 5 bytes
	cmp.l #$00000101,d3	; check if not too big (avoid length ovf.)
	blt.S oksafe
	move.w #$100,d3		; switch to a reasonable offset value
oksafe:
	bra.S cont1

small:
	move.w d3,d6	; this is a small zone (2,3,4 bytes)
	subq.w #$2,d6	; compute offset in a 2 bytes table
	lsl.w #1,d6

cont1:
	lea table,a6		; get max offset table addr.
	cmp.w (a6,d6.w),d4	; if offset too big
	bge.S nocrunch		; exit
	move.l d3,d5		; set maximum to current value
	move.l d4,maxsoffset
	move.b d6,tbloffset

nocrunch:
	cmp.l a5,a3	; if not end of data
	bgt.S contcrunch	; continue the crunch

endquickfind:	; here ends the quickfind


; now current crunch is finished, d5 holds maximum length of of a
; valid zone,maxsoffset holds maximum length's offset

	cmp.l #$1,d5		; if maximum is 1 then do not crunch
	beq.S nothingfound

	bsr dojmp	; if we didn't crunched the last byte
		; don't forget to add a jmp

	move.b tbloffset,d6
	move.l maxsoffset,d3
	move.w 8(a6,d6.w),d0	; get length of offset. to write
	bsr wd0bits		; and write offset

	move.w 16(a6,d6.w),d0	; get length of length to write
	beq.S nolength		; if null (2,3,4 bytes) skip
	move.l d5,d3		; remember d5 holds the length
	subq #1,d3
	bsr wd0bits

nolength:
	move.w 24(a6,d6.w),d0	; get length of code to write
	move.w 32(a6,d6.w),d3	; get code
	bsr wd0bits		; and write code

	addi.w #$1,40(a6,d6.w)
;	addi.w #$1,$dff180

	add.l d5,a0	; add length to culow
	clr.b d0	; tell main program that you've done a good work
	rts

nothingfound:
	move.b (a0)+,d3
	moveq #$8,d0
	bsr wd0bits
	moveq #$1,d0
	rts

maxsoffset: dc.l 0
tbloffset:  dc.w 0

table:
offst:	dc.w $0100,$0200,$0400,$1000
lnoff:	dc.w $0008,$0009,$000a,$000c
length:	dc.w $0000,$0000,$0000,$0008
cdlen:	dc.w $0002,$0003,$0003,$0003
cde:	dc.w $0001,$0004,$0005,$0006
cnt:    dc.w $0,$0,$0,$0
cntjmp: dc.w $0,$0


dojmp:
	tst.w d1
	beq.S skipjmp
	move.w d1,d3
	clr.w d1
	cmp.w #9,d3
	bge.S bigjmp
	addq.w #1,cntjmp
	subq.w #1,d3
	;or.b #%00000000,d3	; write 3 bit code
	moveq #5,d0		; and 3 bits for offset
	bra wd0bits

skipjmp: 
	rts

bigjmp:
	addq.w #1,cntjmp+2
	subi.w #9,d3
	or.w #%0000011100000000,d3	; write 4 bit code
	moveq #11,d0			; and 8 bits for offset
	bra wd0bits

wd0bits:	; write d0 bits from d3,in tmpbuff d2 then in (a2)
	subq.w #1,d0
copybits:
	lsr.l #1,d3	; shift 1 bit from source
	roxl.l #1,d2	; and write it into buffer
	bcs.S writelwd	; if buffer full write & restore it
	dbf d0,copybits
	rts
write1lwd: 
	clr.w d0		; write a long word from d2

writelwd: 
	move.l d2,(a2)+	; store current buffer
	eor.l d2,d7			; update checksum
	moveq #1,d2			; then prepare for next loads
	dbf d0,copybits			; continue writing
	rts


;00xxx			-> skip 1 to 8 bytes when reading
;01xxxxxxxx		-> copy 2 times the bytes at 1 to 256 bytes of
;			    offset
;100xxxxxxxxx		-> idem previous but 3 times and 1 to 512
;101xxxxxxxxxx		-> idem with 4 bytes and 1 to 1024
;110xxxxxxxxxxxxyyyyyyyy -> copy 1 to 256 bytes from a 1 to 4096 offset
;111xxxxxxxx		-> skip 9 to 264 bytes when reading

start dc.l	0
write dc.l	0
stop  dc.l	0
ofset = $1000

tble
	dc.b "gene.prg",0,0,0
	DC.B "ALPHABE1.SPR",0
	DC.B "ANIMAL.SPR",0
	DC.B "BALAI.SPR",0 
	DC.B "BARRIERE.BIN",0
	DC.B "CHIENS.SPR",0 
	DC.B "DEBUT.DAT",0  
	DC.B "DECOHEL2.PI1",0
	DC.B "DRAGON.SPR",0 
	DC.B "DRAGON1.MUS",0
	DC.B "DRAGON2.MUS",0
	DC.B "DRAGON3.MUS",0
	DC.B "DRAGON4.MUS",0
	DC.B "EAU_LEV3.SPR",0
	DC.B "END.DAT",0    
	DC.B "GENE.PRG",0   
	DC.B "GES_ASC.PRG",0
	DC.B "GES_CAM.PRG",0
	DC.B "GES_TRA.PRG",0
	DC.B "GRIFFU.SPR",0 
	DC.B "GRIS.SPR",0   
	DC.B "GROSCON.SPR",0
	DC.B "HAUTASCE.DAT",0
	DC.B "IMG_DRA.DAT",0
	DC.B "MAP4.MAP",0   
	DC.B "MAP6.MAP",0   
	DC.B "MAP7.MAP",0   
	DC.B "MAP8.MAP",0   
	DC.B "MAP_L1N2.MAP",0
	DC.B "MAP_L3N1.MAP",0
	DC.B "MURSCORE.DAT",0
	DC.B "NANA.SPR",0   
	DC.B "NINJAFIN.SPR",0
	DC.B "OBJETS.SPR",0 
	DC.B "PIKCHAIN.SPR",0
	DC.B "POLICE.SPR",0 
	DC.B "POLICE1.DAT",0
	DC.B "PRES.PRG",0   
	DC.B "PRES1.DAT",0  
	DC.B "PRES_TIT.DAT",0
	DC.B "PTITCON.SPR",0
	DC.B "RONNIE.DAT",0 
	DC.B "SAMOURAI.SPR",0
	DC.B "SP61.SPR",0   
	DC.B "SP75.SPR",0   
	DC.B "SPRHELI2.DAT",0
	DC.B "SPRNJAL1.BLK",0
	DC.B "SPRNJAL3.BLK",0
	DC.B "SPRNJAL4.BLK",0
	DC.B "SPRNJAL6.BLK",0
	DC.B "SPRNJAL7.BLK",0
	DC.B "SPRNJAL8.BLK",0
	DC.B "SPR_PRES.SPR",0
	DC.B "STALACT.SPR",0
	DC.B "TBLSCR.PRG",0 
	DC.B "T_APPAR1.BIN",0
	DC.B "T_APPAR2.BIN",0
	DC.B "T_APPAR3.BIN",0
	DC.B "T_APPAR4.BIN",0
	DC.B "T_APPAR5.BIN",0
	DC.B "T_APPAR6.BIN",0
	DC.B "T_APPAR7.BIN",0
	DC.B "WAWA.SPR",0,0,0,0

	EVEN

nombuf
	ds.b	20
	even

************************
* load
* a1 = nom
* a0 = adr
************************
load:
	
	movem.l	d0-d7/a0-a6,-(sp)
	
	move.l	a0,a2
	move.w	#0,-(sp)	;mode 0=lecture
	move.l	a1,-(sp)	;adr nom
	move.w	#fopen,-(sp)	;code file_open
	trap	#gemdos
	addq.l	#8,sp		;d0=n d'identificateur
	move.w	d0,ident	;memo ident

	move.w	#2,-(sp)	; fin du fichier
	move.w	ident,-(sp)
	move.l	#0,-(sp)	; 0 octets avant la fin
	move.w	#fseek,-(sp)
	trap	#gemdos
	add.l	#10,sp
	move.l	d0,len
	
	move.w	#0,-(sp)	; debut du fichier
	move.w	ident,-(sp)
	move.l	#0,-(sp)	; 0 octets 
	move.w	#fseek,-(sp)
	trap	#gemdos
	add.l	#10,sp
	
	move.l	a2,a0
	move.l	a0,-(sp)
	move.l	len,-(sp)
	move.w	ident,-(sp)	
	move.w	#fread,-(sp)
	trap	#gemdos
	add.l	#12,sp
	
	move.w	ident,-(sp)
	move.w	#fclose,-(sp)
	trap	#gemdos
	addq.l	#4,sp
	
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	
*******************
* create
* a1 =nom
* a0 = adr
* {len} = longeur
*******************
create:
	
	movem.l	d0-d7/a0-a6,-(sp)
	
	move.l	a0,a2
	move.w	#0,-(sp)	; normal
	move.l	a1,-(sp)	;adr nom
	move.w	#fcreate,-(sp)	;code file_open
	trap	#gemdos
	addq.l	#8,sp		;d0=n d'identificateur
	move.w	d0,ident	;memo ident

	move.l	a2,a0
	move.l	a0,-(sp)
	move.l	len,-(sp)
	move.w	ident,-(sp)	
	move.w	#fwrite,-(sp)
	trap	#gemdos
	add.l	#12,sp
	
	move.w	ident,-(sp)
	move.w	#fclose,-(sp)
	trap	#gemdos
	addq.l	#4,sp
	
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	
outstr	; entree : d0 pointe sur la chaine a afficher
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,-(sp)
	move.w	#c_conws,-(sp)
	trap	#gemdos
	addq.l	#6,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	
ident
	dc.l	0
len
	dc.l	0
len2
	dc.l	0			
buf_load
	ds.l	150000/4
buf
	ds.l	100000/4
	