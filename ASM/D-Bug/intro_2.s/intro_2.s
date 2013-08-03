;
; D-Bug Intro #2
; Coded by Cyrano Jones
;

ramtop		equ $380000
no_games	equ 2

	move.l 4(a7),a5			; Gemdos MEM_SHRINK
	lea $2000.w,a7			; Safe Stack on 512!
	move.l #$200,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	lea 12(a7),a7

	pea code(pc)
	move.w #$26,-(a7)
	trap #14
	lea $2000.w,a7

	move.w line,d0
	add.w d0,d0
	add.w d0,d0
	lea filenam(pc),a0
	move.l (a0,d0.w),a0

	clr.l -(a7)			; $4b program file
	move.l #ct,-(a7)
	move.l a0,-(a7)
	clr.w -(a7)
	move.w #$4b,-(a7)
	trap #1
	lea 14(a7),a7

quit_ld	move.w #$4c,-(a7)		; Back to Desktop
	trap #1

ct	dc.l 0
filenam	dc.l fn1,fn2

fn1	dc.b "title1.tos",0
	even
fn2	dc.b "title2.tos",0
	even

key_del	move.b d0,$fffffc02.w		; keyboard 'poke' routine
	move.w #$3000,d0
lab1	dbra d0,lab1
	rts

my_key	move.b $fffffc02.w,key		; keyboard 'scanner'
	bclr.b #6,$fffffa11.W
	rte
key	dc.l 0

mfp	move.l a0,-(a7)
	move.l colour,a0
	move.w (a0)+,$ffff8250.w
	move.l a0,colour
	move.l (a7)+,a0
        bclr #0,$fffffa0f.w  	end of interrupt 
        rte

colour	dc.l colours
colours	incbin beebris.pal
	dc.l $ffffffff
	even

code	clr.w -(a7)
	pea -1.w
	move.l (a7),-(a7)
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7

	lea colours+16,a0
	moveq.l #-5,d0
.loop	move.w (a0)+,d1
	bmi.s .done
	addq.w #1,d0
	bra.s .loop
.done	move.w d0,poke_it+2

	move.w #$2700,sr
	move.b $ffff8201.w,old_scr+1
	move.b $ffff8203.w,old_scr+2
	move.l old_scr,prt_scr
	move.l $70.w,old_vbl
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,old_pal

	move.l $118.w,old_key
	move.b #$1a,d0
	bsr key_del
	move.b #$12,d0
	bsr key_del
	move.l #my_key,$118.w

	moveq.l #0,d0
	bsr music

	move.b $fffffa07.w,xa07
	move.b $fffffa13.w,xa13
	move.b $fffffa1b.w,xa1b
	bclr.b #5,$fffffa15.w
	bclr.b #5,$fffffa09.w
	bclr.b #5,$fffffa0d.w		
	bclr.b #5,$fffffa11.w		

	move.l #mfp,$120.w		; HBL vector
	bset #0,$fffffa07.w		; M.F.P. set
	bset #0,$fffffa13.w

	move.l #vbl,$70.w

	bsr init_screen
	move.w #$2300,sr

space	tst.w countdown
	bpl.s .nope
	bsr clear
	bsr print_txt
	bsr move_prt
	move.w #400,countdown
.nope	cmp.b #$50,key
	bne _1_
	bsr down
	bra space
_1_	cmp.b #$48,key
	bne _2_
	bsr up
	bra space
_2_	cmp.b #$39,key
	bne.s space

	move.w #$2700,sr
	move.b xa07,$fffffa07.w
	move.b xa13,$fffffa13.w
	move.b xa1b,$fffffa1b.w
	bset.b #5,$fffffa15.w
	bset.b #5,$fffffa09.w
	bset.b #5,$fffffa0d.w		
	bset.b #5,$fffffa11.w		

	move.l old_key,$118.w
	move.b #$80,d0
	bsr key_del
	move.b #$1,d0
	bsr key_del

	move.l old_vbl,$70.w
	movem.l old_pal,d0-7
	movem.l d0-7,$ffff8240.w
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w

	move.l old_scr,a0
	move.l #($7d00/4)-1,d0
.wipe	clr.l (a0)+
	dbra d0,.wipe
	move.b old_scr+1,$ffff8201.w
	move.b old_scr+2,$ffff8203.w

	move.w #$2300,sr

	rts

clear	move.l old_scr,a0
	lea 6(a0),a0
	lea tmpprt+6,a1
	move.l #66,d0
.wiper
x	set 0
	rept 20
	clr.w x(a0)
	clr.w x(a1)
x	set x+8
	endr
	bsr frame_wait
	lea 160(a0),a0
	lea 160(a1),a1
	dbra d0,.wiper
	rts

print_txt
	move.l #tmpprt,prt_scr

	move.l ntxt,a0
	move.l (a0)+,d0
	bpl.s .ok
	lea txttab,a0
	move.l (a0)+,d0
.ok	move.l a0,ntxt
	move.l d0,a1
	bsr print
	rts

move_prt
	lea tmpprt+6,a0
	move.l old_scr,a1
	lea 6(a1),a1
	move.l #66,d7
.loop	
x	set 0
	rept 20
	move.w x(a0),x(a1)
x	set x+8
	endr
	lea 160(a0),a0
	lea 160(a1),a1
	bsr frame_wait
	dbra d7,.loop
	rts

xa07	dc.w 0
xa13	dc.w 0
xa1b	dc.w 0
prt_scr	dc.l 0

init_screen
	movem.l logo+2,d0-7
	movem.l d0-7,$ffff8240.w
	move.l old_scr,a0
	lea 68*160(a0),a0
	lea logo+34,a1
	move.l #(50*160/4)-1,d0
.loop	move.l (a1)+,(a0)+
	dbra d0,.loop

	lea lower,a1
	bsr print

	rts

up	tst.w line
	beq .rts
	sub.w #1,line
	move.l #8,d7
.loop1	move.l #42,d6
	move.l old_scr,a0
	lea 9*13*160+(3*160)+6(a0),a0
	lea 160(a0),a1
.loop2	move.w (a1),(a0)
	move.w 8(a1),8(a0)
	move.w 144(a1),144(a0)
	move.w 152(a1),152(a0)
	lea 160(a0),a0
	lea 160(a1),a1
	dbra d6,.loop2
	bsr frame_wait
	dbra d7,.loop1
	rts

.rts	rts

down	cmp.w #no_games-1,line
	beq .rts
	addq.w #1,line
	move.l #8,d7
.loop1	move.l #42,d6
	move.l old_scr,a0
	lea (9*13*160)+(48*160)+6(a0),a0
	lea -160(a0),a1
.loop2	move.w (a1),(a0)
	move.w 8(a1),8(a0)
	move.w 144(a1),144(a0)
	move.w 152(a1),152(a0)
	lea -160(a0),a0
	lea -160(a1),a1
	dbra d6,.loop2
	bsr frame_wait
	dbra d7,.loop1
.rts	rts

vbl	movem.l d0-a6,-(a7)
	move.l #colours+16,colour
	neg.w switch
	bpl.s skip
	lea colours+16,a0
	move.w (a0)+,d0
poke_it	move.w #$00000000,d1
.loop	move.w (a0)+,-4(a0)
	dbra d1,.loop
	move.w d0,-4(a0)
skip	move.b #4,$fffffa21.w
	move.b #8,$fffffa1b.w
	bsr music+8
	addq.w #1,vbl_flag
	subq.w #1,countdown
	movem.l (a7)+,d0-a6
	rte

frame_wait
	move.l d0,-(a7)
	move.w vbl_flag,d0
.wait1	cmp.w vbl_flag,d0
	beq.s .wait1
	move.l (a7)+,d0
	rts

countdown	dc.w 1
switch		dc.w -1
vbl_flag	dc.w 0
line		dc.w 0
old_scr		dc.l 0
old_pal		ds.w 16
old_vbl		dc.l 0
old_key		dc.l 0
tspeed		dc.w 2
n1		dc.l 1
n2		dc.l 7
next_add	dc.l 0

; call with a1 pointing at text
print	move.l prt_scr,a0		; screenbase to print on
	lea 6(a0),a0
	move.l a0,next_add
	move.l #1,n1
	move.l #7,n2
.loop	moveq.l #0,d0
	move.b (a1)+,d0
	bpl.s .write
	cmp.b #-1,d0
	beq.s .wrap
.nextline
	move.l #1,n1
	move.l #7,n2
	move.l next_add,a0
	add.l #160*9,a0
	move.l a0,next_add
	bra.s .loop
.wrap	rts
.write	sub.b #' ',d0
	add d0,d0
	add d0,d0
	lea ascii(pc),a2
	move.l (a2,d0),a2
	bsr.s .plotit
	bra. .loop
.plotit	
x	set 0
y	set 0
	rept 8
	move.b x(a2),y(a0)
x	set x+40
y	set y+160
	endr
	add.l n1,a0
	move.l n1,-(a7)
	move.l n2,n1
	move.l (a7)+,n2
	rts

;;
;; "." AND "-" ARE SWAPPED!!!
;;

ntxt	dc.l txttab

txttab	dc.l __1
	dc.l __2
	dc.l __3
	dc.l __4
	dc.l __5
	dc.l __6
	dc.l __7
	dc.l __8
	dc.l __9
	dc.l _10
	dc.l -1

__1	DC.B -2
	dc.b " XXXXX           XXXXX   XX   XX  XXXXXX",-2
	dc.b " XX  XX          XX XX   XX   XX  XX",-2
	dc.b " XX  XX  XXXXX   XXXXXX  XX   XX  XX XXX",-2
	dc.b " XX  XX          XX  XX  XX   XX  XX  XX",-2
	dc.b " XXXXX           XXXXXX  XXXXXXX  XXXXXX",-2
	dc.b "         COMPACTED MENU NUMBER X",-1

__2	dc.b -2
	dc.b "  TO SELECT A GAME USE THE UP AND DOWN  ",-2
	DC.B " CURSOR KEYS AND THEN HIT THE SPACE BAR ",-2
	DC.B "   TO START THE LOADING PROCESS-----",-2
	DC.B -2
	DC.B "        THIS MENU WAS CODED BY:",-2
	DC.B "       ""CYRANO JONES"" OF ""D.BUG"" ",-1

__3	DC.B -2
	DC.B "   D.BUG EXTEND OUR GREETINGS TO-----   ",-2
	DC.B -2
	DC.B "   CYNIX  (HI HUYS! COOL CRACKS)",-2
	DC.B "   UNITY  (YO! SEND ME YOUR STUFF!!)",-2
	DC.B "   ELITE  (NOT SEEN YOU FOR AGES---)",-2
	DC.B "   REPS!  (NICE CRACKS-----)",-1

__4	DC.B -2
	DC.B "     CYRANO JONES OF D.BUG SENDS A",-2
	DC.B "  MEGA.HUGE GREETING FLYING NORTHWARDS",-2
	DC.B "    TO HAL 9000- A GUY WHO SHARES MY",-2
	DC.B "   SLIGHTLY SICK TASTES IN HUMOUR----",-2
	DC.B -2
	DC.B "    HOPE TO MEET UP WITH YOU SOON!!!",-1

__5	DC.B -2
	DC.B "    SO YOU THINK I CAN'T BE BOTHERED",-2
	DC.B "  TO TYPE ANY NEW TEXT INTO THIS INTRO",-2
	DC.B "    DO YOU? WELL, YOU ARE WRONG----!",-2
	DC.B -2
	DC.B "  I WANT TO TRY TO GET WHAT WE, D.BUG,",-2
	DC.B "  ARE TRYING TO DO ACCROSS TO YOU-----"
	DC.B -1
	EVEN

__6	DC.B -2
	DC.B "  OUR SELF INFLICTED RULES ARE-",-2
	DC.B -2
	DC.B "  1- OUR DISKS CONTAIN ONLY STUFF THAT",-2
	DC.B "     IS CRACKED AND PACKED BY US-",-2
	DC.B -2
	DC.B "  2- WE DON'T CARE ABOUT A GAMES AGE-"
	DC.B -1
	EVEN

__7	DC.B -2
	DC.B "  3- WE DON'T CARE WHAT YOU THINK OF",-2
	DC.B "     OUR DISKS- WE DO THEM FOR US!",-2
	DC.B -2
	DC.B "  4- OUR 'SPEED' IS DICTATED BY THE",-2
	DC.B "     GAMES- IE, THEY MUST FIT ON A",-2
	DC.B "     DISK TOGETHER-"
	DC.B -1
	EVEN

__8	DC.B -2
	DC.B "     THERE- THAT SAYS IT ALL REALLY",-2
	DC.B "   WE HOPE YOU LIKE THE DISKS, BUT IF",-2
	DC.B "   YOU DON'T THEN WE DON'T CARE------",-2
	DC.B -2
	DC.B "    NOW, HOW WOULD YOU LIKE A COMING",-2
	DC.B "  SOON LIST? ALL THESE ARE FINISHED---"
	DC.B -1
	EVEN

__9	DC.B -2
	DC.B "        XXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B "       XXXXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B "     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B "     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B "    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B "    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	DC.B -1

_10	DC.B -2
	DC.B -2
	DC.B -2
	DC.B "    WATCH OUT FOR THESE COMING SOON!",-2
	DC.B -2
	DC.B -2
	DC.B -1

lower	dc.b -2,-2,-2,-2,-2,-2,-2
	dc.b -2
	dc.b -2
	dc.b -2
	dc.b -2
	dc.b -2
	dc.b -2
	dc.b -2
	DC.B "....        XXXXXXXXXXXXXXXX        ....",-2
	DC.B "      XXXXXXXXXXXXXXXXXXXXXXXXXXXX      ",-2
	DC.B -2
	DC.B "         D.BUG CORE MEMBERS ARE",-2
	DC.B -2
	DC.B " ICEMAN---------- HACKER, PACKER",-2
	DC.B " HOT KNIFE------- HACKER, PACKER",-2
	dc.b " CYRANO JONES---- HACKER, PACKER, CODER",-1
	even

font	incbin rawfont.bin
	even

ascii	
xx	set font
	rept 40
	dc.l xx
xx	set xx+1
	endr
xx	set font+(40*8)
	rept 40
	dc.l xx
xx	set xx+1
	endr

logo	incbin d_bug.dat
	even

music	incbin THUN_CAT.max

	section bss

tmpprt	ds.b 160*60