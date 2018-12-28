
	; SETLANG: modifies the buil-in language of PROGDESK

	opt P=68000,w+
	
	; langues: FR = 0, EN = 1, IT = 3, CZ = 4
	;	   PL = 4, SW = 5, ES = 6

MAXLANG = 7

	output "SETLANG.TOS"

XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM
   
	text
	
	move.l 4(sp),a0
	move.l $18(a0),a1
	add.l $1c(a0),a1
	add.l #$200,a1
	move.l a1,sp
	sub.l a0,a1
	move.l a1,-(sp)
	move.l a0,-(sp)
	clr.w -(sp)
	GEMDOS $4a,12
	
	pea titre(pc)
	GEMDOS 9,6
	
	move #2,-(sp)
	pea fichier(pc)
	GEMDOS 61,8			; fopen
	move.l d0,d3
	bmi err1
	
	clr -(sp)
	move d3,-(sp)
	move.l #30,-(sp)	;fseek to data
	GEMDOS 66,10
	
	cmp.l #30,d0
	bne err2
	
	pea buff(pc)
	move.l #16,-(sp)
	move d3,-(sp)
	GEMDOS 63,12		; read 16 bytes
	
	cmp.l #16,d0
	bne err2
	
	pea found(pc)
	GEMDOS 9,6

	lea buff+16(pc),a0
	move.l #$0d0a0a00,(a0)
	
	pea buff+2(pc)
	GEMDOS 9,6
	
	lea buff(pc),a3
	lea modif(pc),a1
	moveq #0,d0
	move (a3),d0
	divs #10,d0
	add.b #'0',d0
	move.b d0,(a1)+
	swap d0
	add.b #'0',d0
	move.b d0,(a1)

	pea current(pc)
	GEMDOS 9,6

.key:	
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	
	cmp.b #27,d0
	beq fin2				; escape
	
	and.w #$DF,d0		; upper
	sub.b #'A',d0
	bmi.s .key			; not a letter?
	
	cmp.b #MAXLANG,d0
	bpl.s .key			; to high?
	
	move.w d0,(a3)		; save lang code
	
	clr -(sp)
	move d3,-(sp)
	move.l #30,-(sp)	;fseek to data
	GEMDOS 66,10
	
	cmp.l #30,d0
	bne.s err2
	
	pea (a3)
	move.l #2,-(sp)
	move d3,-(sp)
	GEMDOS 64,12		; fwrite 2 bytes
	
	move d3,-(sp)
	GEMDOS 62,4			; fclose

	pea saved(pc)
	bra fin
saved: dc.b 13,10," Value saved !",0
	even
		
err1: pea nontrouve(pc)
	bra fin
nontrouve: dc.b 13,10,7," Can't find PROGDESK.PRG !",0
	even

err2: pea taille(pc)
	bra fin
taille: dc.b 13,10,7," The file size is not correct !",0
	even
	
fin:
	GEMDOS 9,6		; dernier message

fin2:	
	pea wait(pc)
	GEMDOS 9,6
	
	move.l #$20002,-(sp) ; attente touche
	trap #13
	addq.l #4,sp
	
	clr -(sp)
	trap #1
	
	data
titre: dc.b 27,"E Set Language for Progdesk",13,10,10,0
fichier: dc.b "PROGDESK.PRG",0
wait: dc.b 13,10," Press a key to quit...",0
found: dc.b " Found ",0
current: dc.b " Current setting is "
modif: dc.b "00",13,10,10
	dc.b " Please select your language (Esc=Quit)",13,10,10
	dc.b " a: French(0)   b: English(1)   c: Italian(2)",13,10
	dc.b " d: Czech(3)    e: Polish(4)    f: Swedish(5)",13,10
	dc.b " g: Spanish(6)",13,10,0

	bss
buff: ds.b 100