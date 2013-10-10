*       68000 stand alone disassembler
*
opsize  equ     8       ; number of chars for op
*

	section disassembler,CODE

; a0=pointer to code to disassemble
; a1=pointer to test buffer

	xdef	@Decode68K

@Decode68K:
	movem.l	d1-d7/a0-a6,-(a7)
	move.l  a1,a2
	moveq   #39,d1
clrlp   move.b  #32,(a2)+
	dbra    d1,clrlp
	move.l  a0,d0
	bsr     long3
	addq.l  #2,a1
*
	move.w  (a0)+,d0
	move.w  d0,d3
	rol.w   #5,d0
	and.w   #30,d0
	lea     jumptab(pc),a2
	move.w  0(a2,d0),d0
	add.w   d0,a2
	move.w  d3,d0
	jsr     (a2)
doneop  move.b  #0,(a1)+
;	clr.b   (a1)+
;	move.l  a0,-(sp)
;	lea     4(sp),a0
;	bsr     message			; print string pointed at by a0
;	move.l  (sp)+,a0
;	lea     64(sp),sp
	move.l	a0,d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts
*
jumptab dc.w    n0-jumptab
	dc.w    n1-jumptab
	dc.w    n2-jumptab
	dc.w    n3-jumptab
	dc.w    n4-jumptab
	dc.w    n5-jumptab
	dc.w    n6-jumptab
	dc.w    n7-jumptab
	dc.w    n8-jumptab
	dc.w    n9-jumptab
	dc.w    na-jumptab
	dc.w    nb-jumptab
	dc.w    nc-jumptab
	dc.w    nd-jumptab
	dc.w    ne-jumptab
	dc.w    nf-jumptab
*
n8      move.w  d0,d1
	and.w   #%111000000,d1
	lea     divut(pc),a2
	cmp.w   #%011000000,d1
	beq.s   divop
	lea     divst(pc),a2
	cmp.w   #%111000000,d1
	beq.s   divop
	and.w   #%111110000,d0
	cmp.w   #%100000000,d0
	beq.s   sbcdop
	lea     ort(pc),a2
sameop  bsr     move3
	move.w  d3,d2
	and.w   #192,d2
	move.w  d3,d1
	bsr.s   dosub
	move.b  #',',(a1)+
	move.w  d3,d1
	not.w   d1
*
dosub   btst    #8,d1
	beq     effadd2
	bra     dreg3
*
sbcdop  lea     sbcdt(pc),a2
	bsr     move2
sameop3 move.w  d3,d0
	bsr.s   dosub2
	move.b  #',',(a1)+
	move.w  d3,d0
	rol.w   #7,d0
*
dosub2  btst    #3,d3
	beq     dreg
	bra     aregim
*
divop   bsr     move2
	moveq   #$40,d2         ; word if immediate
efdreg  bsr     effadd4
	bra     dreg3
*
nd      lea     addt(pc),a2
	bra.s   sameas
*
n9      lea     subt(pc),a2
sameas  move.w  d0,d1
	and.w   #%11000000,d1
	cmp.w   #%11000000,d1
	beq.s   subaop
	and.w   #%100110000,d0
	cmp.w   #%100000000,d0
	beq.s   subxop
	bra.s   sameop
*
subaop  bsr     move
	lsr.w   #2,d0
	bsr     worl
	addq.l  #opsize-5,a1
	move.w  d3,d2
	lsr.w   #1,d2
efareg  bsr     effadd4
	bra     areg3
*
subxop  bsr     move
	move.b  #'X',(a1)+
	bsr     dosize
	addq.l  #opsize-6,a1
	bra     sameop3
*
nb      move.w  d0,d1
	and.w   #%111000,d1
	and.w   #%111000000,d0
	btst    #8,d0
	bne.s   ecmop
	cmp.w   #%11000000,d0
	beq.s   cmpaop
	lea     cmpt(pc),a2
samee   bsr     move3
	move.w  d3,d2
	bra     efdreg
*
eorop2  lea     eort(pc),a2
	bsr     move3
	bsr     dreg3
	bra     effadd3
*
cmpaop  lea     cmpt(pc),a2
	bra     subaop
*
ecmop   cmp.w   #%111000000,d0
	beq.s   cmpaop
	cmp.w   #%1000,d1
	bne.s   eorop2
	lea     cmpt(pc),a2
	bsr     move3
	move.w  d3,d0
	bsr     aregip
	move.b  #',',(a1)+
	move.w  d3,d0
	rol.w   #7,d0
	bra     aregip
*
nc      move.w  d0,d1
	and.w   #%111000000,d1
	lea     mulut(pc),a2
	cmp.w   #%011000000,d1
	beq     divop
	lea     mulst(pc),a2
	cmp.w   #%111000000,d1
	beq     divop
	and.w   #%111110000,d0
	cmp.w   #%100000000,d0
	beq.s   abcdop
	cmp.w   #%101000000,d0
	beq.s   exgop
	cmp.w   #%110000000,d0
	beq.s   exgop
	lea     andt(pc),a2
	bra     sameop
*
abcdop  lea     abcdt(pc),a2
	bsr     move2
	bra     sameop3
*
exgop   lea     exgt(pc),a2
	bsr     move2
	move.w  d3,d0
	rol.w   #7,d0
	btst    #7,d3
	bne.s   isd
	btst    #3,d3
	beq.s   isd
	bsr     areg
	bra.s   exgcont
isd     bsr     dreg
exgcont move.b  #',',(a1)+
	move.w  d3,d0
	btst    #3,d0
	beq     dreg
	bra     areg
*
ne      and.w   #192,d0
	cmp.w   #192,d0
	beq.s   smemop
	move.l  a1,-(sp)
	move.w  d3,d0
	lsr.w   #3,d0
	bsr.s   getshft
	bsr     dosize
	move.l  (sp)+,a1
	addq.l  #opsize,a1
	btst    #5,d3
	bne.s   isreg
	bsr     getim
	bra.s   gotop
isreg   bsr     dreg3
	move.b  #',',(a1)+
gotop   bra     dreg2
*
getshft and.w   #3,d0
	add.w   d0,d0
	move.b  shift(pc,d0),(a1)+
	move.b  shift+1(pc,d0),(a1)+
	cmp.w   #4,d0
	bne.s   notx
	move.b  #'X',(a1)+
notx    move.b  #'L',(a1)+
	btst    #8,d3
	bne.s   gotlr
	move.b  #'R',-1(a1)
gotlr   rts
*
shift   dc.b    'ASLSRORO'
*
smemop  move.l  a1,-(sp)
	move.w  d3,d0
	rol.w   #7,d0
	bsr.s   getshft
	move.b  #'.',(a1)+
	move.b  #'W',(a1)+
	move.l  (sp)+,a1
	addq.l  #opsize,a1
	bra     effadd2
*
na
nf      lea     dcwt(pc),a2
	bsr     move2
	bra     wordd
*
n7      lea     moveqt(pc),a2
	bsr     move2
	move.b  #'#',(a1)+
	bsr     snumbb
	move.b  #',',(a1)+
	bra     dreg3
*
n6      move.b  #'B',(a1)+
	bsr     docond
	lea     rat(pc),a2
	subq.w  #2,d0
	bcs.s   setra
	lea     srt(pc),a2
	bne.s   nomod
setra   subq.l  #2,a1
	bsr     move
nomod   addq.l  #opsize-3,a1
	move.b  d3,d0
	beq     relword
	move.b  #'.',3-opsize(a1)
	move.b  #'S',4-opsize(a1)
	bra     relbyt2
*
n5      move.w  d0,d1
	and.w   #192,d1
	cmp.w   #192,d1
	beq.s   bs
	lea     addqt(pc),a2
	btst    #8,d0
	beq.s   isadd
	lea     subqt(pc),a2
isadd   bsr     move3
	move.w  d3,d0
	bsr.s   getim
	bra     effadd
*
getim   move.b  #'#',(a1)+
	move.w  d3,d1
	rol.w   #7,d1
	and.w   #7,d1
	bne.s   not8
	moveq   #8,d1
not8    add.b   #'0',d1
	move.b  d1,(a1)+
	move.b  #',',(a1)+
	rts
*
bs      moveq   #%00111000,d1
	and.w   d0,d1
	cmp.w   #%00001000,d1
	beq.s   dbcc
	move.b  #'S',(a1)+
	bsr     docond
	addq.l  #opsize-3,a1
	bra     effadd2
*
dbcc    move.b  #'D',(a1)+
	move.b  #'B',(a1)+
	bsr     docond
	addq.l  #opsize-4,a1
	bsr     dreg2
	move.b  #',',(a1)+
	bra     relword
*
docond  move.w  d3,d0
	lsr.w   #7,d0
	and.w   #30,d0
	move.b  condt(pc,d0),(a1)+
	move.b  condt+1(pc,d0),(a1)+
	rts
*
condt   dc.b    'T F HILSCCCSNEEQ'
	dc.b    'VCVSPLMIGELTGTLE'
*
n1      moveq   #0,d2
	bra.s   movsame
*
n2      move.w  #128,d2
	bra.s   movsame
*
n3      moveq   #64,d2
movsame lea     movet(pc),a2
	bsr     move
	move.w  d2,d0
	bsr     dosize2
	addq.l  #opsize-6,a1
	bsr     effadd4
	move.w  d3,d0
	rol.w   #7,d0
	lsl.b   #5,d0
	lsr.w   #5,d0
	lsl.b   #5,d0
	lsr.w   #5,d0
	bra     effadd
*
n4      move.w  d0,d1
	lsr.w   #6,d1
	and.w   #3,d1
	lea     j4(pc),a2
	btst    #8,d0
	beq     opsame4
*
leachk  subq.w  #2,d1
	beq.s   chkop
	lea     leat(pc),a2
	bsr     move2
	bra     efareg
*
chkop   lea     chkt(pc),a2
	bsr     move2
	bra     efdreg
*
illegal lea     illt(pc),a2
	bra     move
*
j4      dc.w    negxop-j4
	dc.w    clrop-j4
	dc.w    negop-j4
	dc.w    notop-j4
	dc.w    nbcdop-j4
	dc.w    tstop-j4
	dc.w    movemop-j4
	dc.w    trapop-j4
*
tstop   cmp.w   #$4afc,d0
	beq.s   illegal
	cmp.w   #3,d1
	beq.s   tasop
	lea     tstt(pc),a2
	bra     opsame5
*
tasop   lea     tast(pc),a2
	bsr     move2
	bra     effadd2
*
movemop lea     movemt(pc),a2
	bsr     move
	move.w  d3,d0
	bsr.s   worl
	addq.l  #opsize-7,a1
	move.w  (a0)+,-(sp)
	bsr     effadd4
	move.w  (sp)+,d0
	bra     doregs
*
worl    move.b  #'.',(a1)+
	move.b  #'W',(a1)+
	btst    #6,d0
	beq.s   gotw3
	move.b  #'L',-1(a1)
gotw3   rts
*
trapop  move.w  d3,d0
	btst    #7,d0
	beq.s   notj
	lea     jsrt(pc),a2
	btst    #6,d0
	beq.s   gotj
	lea     jmpt(pc),a2
gotj    bsr     move2
	bra     effadd2
*
notj    move.w  d0,d1
	and.w   #%00110000,d1
	bne.s   notrap
	lea     trapt(pc),a2
	bsr     move2
	move.b  #'#',(a1)+
	and.w   #15,d0
	cmp.w   #10,d0
	bcs.s   not2
	sub.w   #10,d0
	move.b  #'1',(a1)+
not2    add.b   #'0',d0
	move.b  d0,(a1)+
	rts
*
notrap  cmp.w   #16,d1
	bne.s   notlnk
	btst    #3,d0
	bne.s   unlkop
	lea     linkt(pc),a2
	bsr     move2
	bsr     areg
	move.b  #',',(a1)+
	move.b  #'#',(a1)+
	move.w  (a0)+,d0
	bra     snumb
*
unlkop  lea     unlkt(pc),a2
	bsr     move2
	bra     areg
*
notlnk  cmp.w   #32,d1
	bne.s   misc
	lea     movet(pc),a2
	bsr     move
	move.b  #'.',(a1)+
	move.b  #'L',(a1)+
	addq.l  #opsize-6,a1
	move.w  d0,d1
	bsr.s   uspora
	move.b  #',',(a1)+
	not.w   d1
*
uspora  btst    #3,d1
	beq     areg
	lea     uspt(pc),a2
	bra     move
*
misc    and.w   #7,d0
	lea     textt(pc),a2
	add.w   d0,d0
	move.w  0(a2,d0),d0
	add.w   d0,a2
	cmp.w   #$4e72,d3       ; stop
	bne     move
	bsr     move2
	move.b  #'#',(a1)+
	move.b  #'$',(a1)+
	bra     word
*
textt   dc.w    resett-textt
	dc.w    nopt-textt
	dc.w    stopt-textt
	dc.w    rtet-textt
	dc.w    rtdt-textt
	dc.w    rtst-textt
	dc.w    trapvt-textt
	dc.w    rtrt-textt
*
nbcdop  tst.w   d1
	bne.s   notnbcd
	lea     nbcdt(pc),a2
	bsr     move2
	bra     effadd2
*
notnbcd subq.w  #1,d1
	bne.s   notswap
	move.w  d0,d1
	and.w   #%00111000,d1
	bne.s   peaop
	lea     swapt(pc),a2
	bsr     move2
	bra     dreg
*
peaop   lea     peat(pc),a2
	bsr     move2
	bra     effadd
*
notswap and.w   #%00111000,d0
	bne.s   movemr
	lea     extt(pc),a2
	bsr     move
	move.w  d1,d0
	bsr     dosize3
	addq.l  #opsize-5,a1
	bra     dreg2
*
movemr  lea     movemt(pc),a2
	bsr     move
	move.w  d3,d0
	bsr     worl
	addq.l  #opsize-7,a1
	move.w  (a0)+,d0
	move.w  d3,d1
	and.w   #%00111000,d1
	cmp.w   #%00100000,d1
	bne.s   notsp
	moveq   #15,d2
mml     lsr.w   #1,d0
	roxl.w  #1,d1
	dbra    d2,mml
	move.w  d1,d0
notsp   bsr.s   doregs
	bra     effadd3
*
doregs  move.w  d0,-(sp)
	moveq   #$44,d1			; ascii 'D'
	bsr.s   reglist
	move.w  (sp)+,d0
	ror.w   #8,d0
	moveq   #$41,d1			; ascii 'A'
	bsr.s   reglist
	subq.l  #1,a1
	rts
reglist moveq   #$2f,d2			; ascii '0'-1
reglp   addq.w  #1,d2
	lsr.b   #1,d0
	bcs.s   yesreg
	bne.s   reglp
	rts
yesreg  move.b  d1,(a1)+
	move.b  d2,(a1)+
	move.b  #'/',(a1)+
	btst    #0,d0
	beq.s   reglp
	move.b  #'-',-1(a1)
	subq.w  #1,d2
reglp2  addq.w  #1,d2
	lsr.b   #1,d0
	bcs.s   reglp2
	move.b  d2,(a1)+
	move.b  #'/',(a1)+
	addq.w	#1,d2
	bra.s   reglp
*
notop   cmp.w   #3,d1
	beq.s   movetsr
	lea     nott(pc),a2
	bra.s   opsame5
*
movetsr lea     movewt(pc),a2
	bsr     move2
;       move.w  d3,d0
	moveq   #$40,d2
	bsr     effadd
	move.b  #',',(a1)+
	lea     srt(pc),a2
	bra     move
*
negop   cmp.w   #3,d1
	beq.s   movtccr
	lea     negt(pc),a2
	bra.s   opsame5
*
movtccr lea     movebt(pc),a2
	bsr     move2
;       move.w  d3,d0
	bsr     effadd
	move.b  #',',(a1)+
	lea     ccrt(pc),a2
	bra     move
*
clrop   cmp.w   #3,d1
	beq.s   movccr
	lea     clrt(pc),a2
	bra.s   opsame5
*
movccr  lea     movebt(pc),a2
	bsr     move2
	lea     ccrt(pc),a2
	bsr     move
	move.b  #',',(a1)+
;       move.w  d3,d0
	bra     effadd
*
negxop  cmp.w   #3,d1
	beq.s   movesr
	lea     negxt(pc),a2
opsame5 bsr     move3
	bra     effadd2
*
movesr  lea     movewt(pc),a2
	bsr     move2
	lea     srt(pc),a2
	bsr     move
	move.b  #',',(a1)+
;       move.w  d3,d0
	bra     effadd
*
n0      btst    #8,d0
	bne.s   opbits
	lea     j2(pc),a2
opsame4 rol.w   #8,d0
	and.w   #14,d0
	move.w  0(a2,d0),d0
	add.w   d0,a2
	move.w  d3,d0
	jmp     (a2)
*
opbits  and.w   #%00111000,d0
	cmp.w   #%00001000,d0
	beq.s   movepop
	bsr     getbop
	bsr     dreg3
	bra     effadd3
*
movepop lea     movept(pc),a2
	bsr     move
	move.w  d3,d0
	bsr     worl
	addq.l  #opsize-7,a1
	btst    #7,d0
	beq.s   toreg
	rol.w   #7,d0
	bsr     dreg
	move.b  #',',(a1)+
	move.w  d3,d0
	bra     aregid
*
toreg   bsr     aregid
	move.b  #',',(a1)+
	bra     dreg3
*
j2      dc.w    opori-j2
	dc.w    opandi-j2
	dc.w    opsubi-j2
	dc.w    opaddi-j2
	dc.w    opbiti-j2
	dc.w    opeori-j2
	dc.w    opcmpi-j2
	dc.w    errori-j2
*
opbiti  bsr.s   getbop
	move.b  #'#',(a1)+
	move.b  #'$',(a1)+
	move.w  (a0)+,d0
	and.w   #31,d0
	bsr     byte2
	bra     effadd3
*
getbop
	move.w  d3,d0
	and.w   #192,d0
	lsr.w   #4,d0
	lea     btstt(pc),a2
	add.w   d0,a2
	move.b  (a2)+,(a1)+
	move.b  (a2)+,(a1)+
	move.b  (a2)+,(a1)+
	move.b  (a2)+,(a1)+
	addq.l  #opsize-4,a1
errori  rts
*
opandi  lea     andt(pc),a2
	bra.s   opsame
*
opsubi  lea     subt(pc),a2
	bra.s   opsame
*
opaddi  lea     addt(pc),a2
	bra.s   opsame
*
opeori  lea     eort(pc),a2
	bra.s   opsame
*
opcmpi  lea     cmpt(pc),a2
	bra.s   opsame
*
opori   lea     ort(pc),a2
opsame  bsr     move3
	bsr     imop
	move.b  #',',(a1)+
	move.w  d3,d0
	lea     ccrt(pc),a2
	cmp.b   #%00111100,d0
	beq     move
	lea     srt(pc),a2
	cmp.b   #%01111100,d0
	beq     move
	bra     effadd
*
dosize  move.w  d3,d0
dosize2 lsr.w   #6,d0
dosize3 and.w   #3,d0
	move.b  #'.',(a1)+
	move.b  size(pc,d0),(a1)+
	rts
*
size    dc.b    'BWL '
*
imop    move.w  d3,d0
*
imop2   move.b  #'#',(a1)+
	move.b  #'$',(a1)+
	and.w   #192,d0
	beq.s   byte
	cmp.w   #64,d0
	beq.s   word
*
long    move.l  (a0)+,d0
long2   moveq   #0,d1
long3   move.w  d0,-(sp)
	swap    d0
	bsr.s   word3
	move.w  (sp)+,d0
	bsr.s   word3
	bra.s   test0
*
word    move.w  (a0)+,d0
word2   moveq   #0,d1
	bsr.s   word3
	bra.s   test0
word3   move.w  d0,-(sp)
	ror.w   #8,d0
	bsr.s   byte3
	move.w  (sp)+,d0
	bra.s   byte3
*
byte    move.w  (a0)+,d0
byte2   moveq   #0,d1
	bsr.s   byte3
test0   tst.w   d1
	bne.s   nozero
	move.b  #'0',(a1)+
	rts
byte3   move.w  d0,-(sp)
	lsr.w   #4,d0
	bsr.s   nybble
	move.w  (sp)+,d0
nybble  and.w   #15,d0
	beq.s   zeron
	cmp.w   #10,d0
	bcs.s   noth
	addq.w  #7,d0
noth    add.b   #'0',d0
	move.b  d0,(a1)+
	moveq   #1,d1
nozero  rts
*
zeron   tst.w   d1
	beq.s   nozero
	move.b  #'0',(a1)+
	rts
*
effadd4 bsr.s   effadd2
	move.b  #',',(a1)+
	rts
*
effadd3 move.b  #',',(a1)+
*
effadd2 move.w  d3,d0
*
effadd  move.w  d0,d1
	lsr.w   #2,d1
	and.w   #14,d1
	lea     efadt(pc),a2
	move.w  0(a2,d1),d1
	jmp     0(a2,d1)
*
efadt   dc.w    dreg-efadt
	dc.w    areg-efadt
	dc.w    aregi-efadt
	dc.w    aregip-efadt
	dc.w    aregim-efadt
	dc.w    aregid-efadt
	dc.w    aregii-efadt
	dc.w    special-efadt
*
dreg3   move.w  d3,d0
	rol.w   #7,d0
	bra.s   dreg
*
dreg2   move.w  d3,d0
*
dreg    move.b  #'D',(a1)+
	bra.s   regno
*
areg3   move.w  d3,d0
	rol.w   #7,d0
*
areg    move.b  #'A',(a1)+
regno
	and.w   #7,d0
	add.b   #'0',d0
	move.b  d0,(a1)+
	rts
*
aregi   move.b  #'(',(a1)+
	bsr.s   areg
	move.b  #')',(a1)+
	rts
*
aregip  bsr.s   aregi
	move.b  #'+',(a1)+
	rts
*
aregim  move.b  #'-',(a1)+
	bra.s   aregi
*
aregid  move.w  d0,-(sp)
	move.w  (a0)+,d0
	bsr.s   snumb
	move.w  (sp)+,d0
	bra     aregi
*
snumb   tst.w   d0
	bpl.s   wordd
	move.b  #'-',(a1)+
	neg.w   d0
*
wordd   move.b  #'$',(a1)+
	bra     word2
*
snumbb  tst.b   d0
	bpl.s   notmin2
	move.b  #'-',(a1)+
	neg.b   d0
notmin2 move.b  #'$',(a1)+
	bra     byte2
*
aregii  move.w  d0,-(sp)
	move.b  1(a0),d0
	bsr     snumbb
	move.w  (sp)+,d0
	bsr     aregi
sameop2 move.b  #',',-1(a1)
	move.b  (a0),d0
	bsr     regad
	move.w  (a0)+,d0
	move.b  #'.',(a1)+
	move.b  #'W',(a1)+
	btst    #11,d0
	beq.s   notl
	move.b  #'L',-1(a1)
notl    move.b  #')',(a1)+
	rts
*
regad   move.b  #'D',(a1)+
	tst.b   d0
	bpl.s   gotdr
	move.b  #'A',-1(a1)
gotdr   lsr.w   #4,d0
	and.w   #7,d0
	add.b   #'0',d0
	move.b  d0,(a1)+
	rts
*
special and.w   #7,d0
	cmp.w   #5,d0
	bcc     error
	add.w   d0,d0
	lea     spectab(pc),a2
	move.w  0(a2,d0),d0
	jmp     0(a2,d0)
*
spectab dc.w    abss-spectab
	dc.w    absl-spectab
	dc.w    pcd-spectab
	dc.w    pci-spectab
	dc.w    imm-spectab
*
abss    move.b  #'$',(a1)+
	move.w  (a0)+,d0
	ext.l   d0
	bsr     long2
	move.b  #'.',(a1)+
	move.b  #'W',(a1)+
	rts
*
absl    move.b  #'$',(a1)+
	bra     long
*
pcd     bsr.s   relword
	lea     pct(pc),a2
	bra.s   move
*
relword move.w  (a0),d0
	ext.l   d0
	add.l   a0,d0
	addq.l  #2,a0
	move.b  #'$',(a1)+
	bra     long2
*
pci     bsr.s   relbyte
	lea     pct(pc),a2
	bsr.s   move
	bra     sameop2
*
relbyte move.b  1(a0),d0
relbyt2 ext.w   d0
	ext.l   d0
	add.l   a0,d0
	move.b  #'$',(a1)+
	bra     long2
*
imm     move.w  d2,d0
	bra     imop2
*
move2   move.l  a1,-(sp)
	bsr.s   move
	move.l  (sp)+,a1
	addq.l  #opsize,a1
	rts
*
move3   move.l  a1,-(sp)
	bsr.s   move
	bsr     dosize
	move.l  (sp)+,a1
	addq.l  #opsize,a1
	rts
*
move    move.b  (a2)+,(a1)+
	bpl.s   move
	bclr    #7,-1(a1)
error   rts
*
startup dc.b    12,30,15,29,0,0
*
andt    dc.b    'AN','D'+128
ort     dc.b    'O','R'+128
eort    dc.b    'EO','R'+128
subt    dc.b    'SU','B'+128
addt    dc.b    'AD','D'+128
cmpt    dc.b    'CM','P'+128
btstt   dc.b    'BTST'
bchgt   dc.b    'BCHG'
bclrt   dc.b    'BCLR'
bsett   dc.b    'BSET'
srt     dc.b    'S','R'+128
ccrt    dc.b    'CC','R'+128
pct     dc.b    '(PC',')'+128
movept  dc.b    'MOVE','P'+128
movet   dc.b    'MOV','E'+128
movewt  dc.b    'MOVE.','W'+128
movebt  dc.b    'MOVE.','B'+128
negxt   dc.b    'NEG','X'+128
negt    dc.b    'NE','G'+128
nott    dc.b    'NO','T'+128
clrt    dc.b    'CL','R'+128
nbcdt   dc.b    'NBC','D'+128
swapt   dc.b    'SWA','P'+128
peat    dc.b    'PE','A'+128
extt    dc.b    'EX','T'+128
movemt  dc.b    'MOVE','M'+128
leat    dc.b    'LE','A'+128
chkt    dc.b    'CH','K'+128
illt    dc.b    'ILLEGA','L'+128
tstt    dc.b    'TS','T'+128
tast    dc.b    'TA','S'+128
jmpt    dc.b    'JM','P'+128
jsrt    dc.b    'JS','R'+128
trapt   dc.b    'TRA','P'+128
linkt   dc.b    'LIN','K'+128
unlkt   dc.b    'UNL','K'+128
resett  dc.b    'RESE','T'+128
nopt    dc.b    'NO','P'+128
stopt   dc.b    'STO','P'+128
rtet    dc.b    'RT','E'+128
rtdt    dc.b    'RT','D'+128
rtst    dc.b    'RT','S'+128
trapvt  dc.b    'TRAP','V'+128
rtrt    dc.b    'RT','R'+128
uspt    dc.b    'US','P'+128
subqt   dc.b    'SUB','Q'+128
addqt   dc.b    'ADD','Q'+128
rat     dc.b    'R','A'+128
moveqt  dc.b    'MOVE','Q'+128
dcwt    dc.b    'DC.','W'+128
divst   dc.b    'DIV','S'+128
divut   dc.b    'DIV','U'+128
mulut   dc.b    'MUL','U'+128
mulst   dc.b    'MUL','S'+128
sbcdt   dc.b    'SBC','D'+128
abcdt   dc.b    'ABC','D'+128
exgt    dc.b    'EX','G'+128

		END