; hash table, self expanding, quadratic probing.
; can tell if label was found (for double labels errors and searching).
; meant for use in qdsp assembler.

Hash.ENTRIES:		=	1031	2053		; nextprime(2048)
Hash.BUFSIZE:		=	32768	65536
Hash.DOUBLE_KEY:	=	-1
Hash.REHASH_FAILED:	=	-2
Hash.NULL_STRING:	=	-3
Hash.REBUF_FAILED:	=	-4

	IFND	QDSP

	COMMENT	HEAD=%111

	bsr	Hash.init
	tst.l	d0
	bmi	exit	

	lea	Hash.string1,a0
	moveq	#1,d1
	bsr	addString0
	tst.l	d0
	bmi	deinit

	lea	Hash.string2,a0
	moveq	#2,d1
	bsr	addString0
	tst.l	d0
	bmi	deinit

	lea	Hash.string3,a0
	moveq	#3,d1
	bsr	addString0
	tst.l	d0
	bmi	deinit

	lea	Hash.string4,a0
	moveq	#4,d1
	bsr	addString0
	tst.l	d0
	bmi.s	deinit

	lea	Hash.string5,a0
	moveq	#5,d1
	bsr	addString0
	tst.l	d0
	bmi.s	deinit

	lea	Hash.string6,a0
	moveq	#6,d1
	bsr	addString0
	tst.l	d0
	bmi.s	deinit

	lea	Hash.string7,a0
	moveq	#7,d1
	bsr	addString0
	tst.l	d0
	bmi.s	deinit

	lea	Hash.string8,a0
	moveq	#8,d1
	bsr	addString0
	tst.l	d0
	bmi.s	deinit

	lea	Hash.string8,a0
	moveq	#8,d1
	bsr	addString0
	tst.l	d0
	bmi.s	deinit

	lea	Hash.string9,a0
	moveq	#9,d1
	bsr	addString0
	tst.l	d0
	bmi.s	deinit

	lea	Hash.string9,a0
	move.w	len,d0
	bsr	Hash.get
	tst.w	Hash.wasFound
	beq.s	deinit
	
	nop

deinit:	bsr	Hash.deinit

exit:	clr.w	-(sp)
	trap	#1

	INCLUDE	INCLUDE\GEMDOS.S

	ENDC

; INPUT:
; a0: string (null terminated)
; d1.l=data
; OUTPUT:
; d0.l= 0:ok, <0:error
addString0:
	movea.l	a0,a1
.loop:	tst.b	(a1)+
	bne.s	.loop
	subq	#1,a1
	sub.l	a0,a1
	move.l	a1,d0
	move.w	d0,len
	bsr	Hash.add
	rts

; OUTPUT:
; d0.l= 0:ok, <0:error
Hash.init:
	move.l	#Hash.ENTRIES,d0
	move.l	d0,Hash.numEntries
	move.l	d0,d1
	lsl.l	#2,d0				; d0*4
	Malloc	d0
	move.l	d0,Hash.tableAdr
	beq.s	.error

; Clear hash table.
	clr.l	Hash.numTaken			; 0 occupied
	movea.l	d0,a0				; a0: table
	clr.l	d0
.loop:	move.l	d0,(a0)+
	subq.l	#1,d1
	bne.s	.loop

; Allocate stringbuffer.
	move.l	#Hash.BUFSIZE,d0
	move.l	d0,Hash.bufSize
	Malloc	d0
	move.l	d0,Hash.bufferAdr
	move.l	d0,Hash.nextStringAdr
	beq.s	.error

; Clear buffer.
	movea.l	d0,a0				; a0: buffer
	move.l	Hash.bufSize,d1
	clr.l	d0
.cloop:	move.b	d0,(a0)+
	subq.l	#1,d1
	bne.s	.cloop

	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

; PRE: Hash.init was successful
Hash.deinit:
	Mfree	Hash.bufferAdr
	Mfree	Hash.tableAdr
	rts

; todo: check if entry already in here
; INPUT:
; a0: string
; d0.w=stringlength (0 gives error)
; d1.l=data
; OUTPUT:
; d0.l= 0:ok, <0:error
Hash.add:
	movem.l	d2-d7/a1-a6,-(sp)

	move.l	a0,a6
	move.w	d0,.stringsize
.redo:	bsr	Hash.calcKey			; d0.l=key
	tst.w	Hash.wasFound
	bne.s	.success
	tst.l	d0
	bmi	.null_string

; Insert the stingaddress in the table.
	movea.l	Hash.tableAdr,a1
	movea.l	Hash.nextStringAdr,a2
	move.l	a2,(a1,d0.l*4)

; Check if we should rehash..
	move.l	Hash.numTaken,d0
	addq.l	#1,d0
	add.l	d0,d0
	cmp.l	Hash.numEntries,d0
	bhs.s	.rehash				; Too high load? -> Rehash to speed up!
	lsr.l	d0
	move.l	d0,Hash.numTaken		; Only if not rehashed, complete the increment.

; Copy string to buffer.
	clr.l	d7
	move.w	.stringsize(pc),d7
	movea.l	a2,a1				; a1: current string
	adda.l	d7,a1				; Add stringlength.
	addq	#4,a1				; Add datalength. a1: next string
	suba.l	Hash.bufferAdr,a1		; a1=projected bufsize
	cmpa.l	Hash.bufSize,a1
	bhs.s	.rebuf

.copy:	move.l	d1,(a2)+			; Copy data.
	subq.w	#1,d7
.cploop:move.b	(a6)+,(a2)+
	dbf	d7,.cploop
	clr.b	(a2)+
	move.l	a2,Hash.nextStringAdr		; Set new string address.

.success:
	movem.l	(sp)+,d2-d7/a1-a6
	moveq	#0,d0
	rts

.rehash:bsr	Hash.reHash
	move.l	d0,d2				; d2.l=rehash resultcode
	movea.l	a6,a0
	move.w	.stringsize(pc),d0
	tst.l	d2
	beq.s	.redo
; Error, rehashing failed.
	movem.l	(sp)+,d2-d7/a1-a6
	moveq	#Hash.REHASH_FAILED,d0
	rts

; kill kill fuck kill fuck kill kill fuck kill fuck kill kill fuck kill kill
.rebuf:	bsr	Hash.extendBuffer
	movea.l	Hash.nextStringAdr,a2
	tst.l	d0
	beq.s	.copy
.rebuf_failed:
	movem.l	(sp)+,d2-d7/a1-a6
	moveq	#Hash.REBUF_FAILED,d0
	rts

.null_string:
	movem.l	(sp)+,d2-d7/a1-a6
	moveq	#Hash.NULL_STRING,d0
	rts

.stringsize:
	DC.W	0

; INPUT:
; a0: string
; d0.w= string length
; OUTPUT:
; d1.l= data (crap if not found)
Hash.get:
	bsr.s	Hash.calcKey
	tst.w	Hash.wasFound(pc)
	bne.s	.ok
	rts
.ok:	movea.l	Hash.tableAdr,a0		; a0: table
	movea.l	(a0,d0.l*4),a0			; a0: string
	move.l	(a0),d1				; d1.l=data
	rts

; INPUT:
; a0: string (nullterminated)
; OUTPUT:
; d1.l= data (crap if not found)
Hash.get0:
	bsr	Hash.calcKey0
	tst.w	Hash.wasFound(pc)
	bne.s	.ok
	rts
.ok:	movea.l	Hash.tableAdr,a0		; a0: table
	movea.l	(a0,d0.l*4),a0			; a0: string
	move.l	(a0),d1				; d1.l=data
	rts

; Hashes and applies quadratic probing.
; INPUT:
; a0: string (need not be nullterminated)
; d0.w=stringlength
; OUTPUT:
; d0.l= >=0:key, <0:error
Hash.calcKey:
	movem.l	d1-d3/a0-a3,-(sp)
	move.w	d0,d3
	subq.w	#1,d0
	ext.l	d0
	bmi.s	.end

; Hash the shit.
	clr.l	d2
.loop:	move.b	(a0)+,d1
	eor.b	d1,d2
	move.l	d2,d1
	rol.l	d2,d2
	eor.l	d1,d2
	dbf	d0,.loop
	clr.l	d1
	divu.l	Hash.numEntries,d1:d2
	move.l	d1,d0
	suba.w	d3,a0				; a0: string
	subq.w	#1,d3

; Apply quadratic probing to resolve mess..
	moveq	#0,d1				; d1.l=i[0]
	movea.l	Hash.tableAdr,a2
.ploop:	movea.l	a0,a3				; a3: string
	movea.l	(a2,d0.l*4),a1
	tst.l	a1
	sne	Hash.wasFound			; Mark as 'not found'.
	beq.s	.end				; Vacant? Shove it in!
	addq	#4,a1				; a1: stored string
	move.w	d3,d2
.cloop:	cmpm.b	(a1)+,(a3)+
	dbne	d2,.cloop
	tst.w	d2				; Whole searchstring done?
	bpl.s	.next				; no -> not found.
	tst.b	(a1)				; Whole dst. string done?
	bne.s	.next				; no -> not found.
	seq	Hash.wasFound			; Mark as 'found'.
	bra.s	.end				; String matches? Found!

.next:	addq.w	#1,d1				; d1.l=i[n+1]=i[n]+1
	move.l	d1,d2
	add.l	d2,d2				; d2.l=2*i[n+1]
	subq.l	#1,d2				; d2.l=2*i[n+1]-1
	add.l	d2,d0				; d0.l=pos[n+1]
	cmp.l	Hash.numEntries,d0		; Correct pos..
	blt.s	.ploop
	sub.l	Hash.numEntries,d0		
	bra.s	.ploop	

.end:	movem.l	(sp)+,d1-d3/a0-a3
	rts

; INPUT:
; a0: string (nullterminated)
; OUTPUT:
; d0.l=key
; a0: end of string
Hash.calcKey0:
	movea.l	a0,a1
	moveq	#-1,d0
.loop:	addq.w	#1,d0
	tst.b	(a1)+
	bne.s	.loop
	move.l	a1,-(sp)
	bsr	Hash.calcKey
	movea.l	(sp)+,a0
	rts

; OUTPUT:
; d0.l= 0:ok, <0:error (fatal, deinit required)
Hash.reHash:
	movem.l	d1-a6,-(sp)

; Allocate new table.
	move.l	Hash.numEntries,d0
	add.l	d0,d0
	bsr	Hash.nextPrime
	move.l	d0,d7				; d7.l= new #entries
	move.l	d7,Hash.numEntries		; Set new #entries.
	lsl.l	#2,d0				; d0*4
	Malloc	d0
	beq.s	.error

; Clear new table.
	movea.l	d0,a1				; a1: new table
	movea.l	d0,a2				; a2: new table
	clr.l	d0
.cloop:	move.l	d0,(a1)+
	subq.l	#1,d7
	bne.s	.cloop

; Rebuild table.
	movea.l	Hash.tableAdr,a6		; a6: old table
	move.l	a2,Hash.tableAdr		; Set new table.
	movea.l	Hash.bufferAdr,a0		; a0: strings
	clr.l	d0
.loop:	cmpa.l	Hash.nextStringAdr,a0
	bhs.s	.rebuilt
	movea.l	a0,a5				; a5: data+string
	addq	#4,a0				; a0: string
	bsr	Hash.calcKey0
	move.l	a5,(a2,d0.l*4)			; Store string address.
	bra.s	.loop	
.rebuilt:

	Mfree	a6				; Free up old table.
	movem.l	(sp)+,d1-a6
	moveq	#0,d0
	rts
.error:	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts

; OUTPUT:
; d0.l= 0:ok, <0:error
Hash.extendBuffer:
	movem.l	d1-a6,-(sp)

; Allocate new space.
	move.l	Hash.bufSize,d0			; d0.l=old buffersize
	add.l	d0,d0				; d0.l=new buffersize = old buffersize * 2
	move.l	d0,Hash.bufSize			; Set new buffersize.
	Malloc	d0
	beq.s	.error

; Copy old buffer to new.
	movea.l	d0,a1				; a1: new buf
	movea.l	d0,a2				; a2: new buf
	movea.l	Hash.bufferAdr,a0		; a0: old buf
	movea.l	a0,a3				; a3: old buf
	move.l	Hash.nextStringAdr,d0
	sub.l	a0,d0				; d0.l=#bytes to copy
.cploop:move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.cploop

; Relocate table pointers.
	movea.l	Hash.tableAdr,a0
	move.l	Hash.numEntries,d7
.loop:	move.l	(a0),d0
	beq.s	.next
	sub.l	a3,d0				; d0.l=offset
	add.l	a2,d0				; d0.l=offset+new_base=new_adr
.next:	move.l	d0,(a0)+			; Store new address.
	subq.l	#1,d7
	bne.s	.loop

; Set new addresses.
	move.l	a1,Hash.nextStringAdr		; Set new buffer end.
	Mfree	Hash.bufferAdr			; Free up old buffer.
	move.l	a2,Hash.bufferAdr		; Set new buffer.

	movem.l	(sp)+,d1-a6
	moveq	#0,d0
	rts
.error:	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts

; lame primalty tester
; INPUT:
; d0.w=num (0 extended)
; OUTPUT:
; d0.w=nextPrime(num)
Hash.nextPrime:
	movem.l	d1-d4,-(sp)
; First make it odd.
	btst	#0,d0
	bne.s	.odd
	addq.w	#1,d0

.odd:	moveq	#1,d1
	clr.l	d4

.loop:	addq.w	#2,d1
	move.w	d1,d2
	mulu.w	d2,d2
	cmp.l	d0,d2
	bhs.s	.end
	move.l	d0,d3
	divu.w	d1,d3				; num mod d1
	swap	d3				; d3.w=rest
	tst.w	d3				; test rest
	bne.s	.loop
	moveq	#1,d4
	bra.s	.loop				; modulo 0 -> not prime -> try again!

.end:	addq.w	#2,d0				; Try next number..
	tst.l	d4				; Number not prime?
	bne.s	.odd				; -> Try next!

	subq.w	#2,d0				; Last num was okay..
	movem.l	(sp)+,d1-d4
	rts

	IFND	QDSP

Hash.string1:
	DC.B	"bitch",0
Hash.string2:
	DC.B	"bitchass",0
Hash.string3:
	DC.B	"meuhBlah",0
Hash.string4:
	DC.B	"arggghhh",0
Hash.string5:
	DC.B	"teringneet",0
Hash.string6:
	DC.B	"mothafokka",0
Hash.string7:
	DC.B	"krijgdetering",0
Hash.string8:
	DC.B	"kloothommel",0
Hash.string9:
	DC.B	"unclefucker",0
	EVEN

	ENDC

	BSS

Hash.bufSize:
	DS.L	1
Hash.tableAdr:
	DS.L	1
Hash.bufferAdr:
	DS.L	1
Hash.numEntries:				; #slots
	DS.L	1
Hash.numTaken:					; #slots occupied
	DS.L	1
Hash.nextStringAdr:
	DS.L	1
Hash.wasFound:
	DS.W	1

len:	ds.w	1
