	move.l 4(a7),a5
	move.l #$100,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	add.w #12,a7
	
	clr.l	-(a7)
	move.w	#$20,-(a7)		;supervisor mode
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp
	
	move.l	#reboot,$42a
	move.l	#$31415926,$426

	move.l	#0,$484.w		;no keyclick
	bsr	on			;start music

	bra	strt

zippy	movem.l d0-a6,-(a7)		;save registers
	bsr	(music+8)		;call playback
	movem.l	(a7)+,d0-a6		;restore registers
	move.l	oldint,-(a7)		;old vbl on sp
	rts				;call old vbl

on	move.l	$70.w,oldint		;save old vbl
	moveq	#2,d0			;music #1
	bsr	music			;call init
	move.l	#zippy,$70.w		;install new vbl
	rts

off	move.l	oldint,$70.w		;restore old vbl
	move.l	#$08080000,$ff8800	;clear vol. chan a
	move.l	#$09090000,$ff8800	;clear vol. chan b
	move.l	#$0a0a0000,$ff8800	;clear vol. chan c
	rts

oldstk	dc.l	0
oldint	dc.l	0

music	incbin	"gear.dat"		;music file

strt	move.w	#4,-(a7)		;get rez
	trap	#14
	addq.l	#2,a7
	move.w	d0,old_rez
	cmpi.w	#2,d0
	beq	quit

	lea	$ffff8240.w,a0
	lea	def_pal,a1
	lea	32(a1),a1		;store colours
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)

	clr.w	-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;set screen
	trap	#14
	lea	12(a7),a7

	;move.b	#4,def_spd		;default scroll speed
	;move.b	def_spd,speed

	;clr.l	-(a7)
	;move.w	#$20,-(a7)		;supervisor mode
	;trap	#1
	;addq.l	#6,a7
	;move.l	d0,old_sp
	
	dc.w	 $a00a			;kill mouse
	
	move.w	#4,-(a7)		;get rez
	trap	#14
	addq.l	#2,a7
	move.w	d0,old_rez
	cmpi.w	#2,d0
	beq	quit

	lea	$ffff8240.w,a0
	lea	def_pal,a1
	lea	32(a1),a1		;store colours
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)

	lea	$ffff8260.w,a0
	lea	new_pal,a1
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,-(a0)

	clr.w	-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;set screen
	trap	#14
	lea	12(a7),a7

	move.w	#8000,d0
	lea	$44e,a0
	move.l	(a0),a0
	lea	piccy+34,a1
nextlb	move.l	(a1)+,(a0)+
	dbf	d0,nextlb

	move.b	#7,def_spd		;default scroll speed
	move.b	def_spd,speed

******* start of scroller code ************************

start	lea	scrl,a0
scroll	moveq.l	#0,d4
	move.b	(a0),d4			;next letter
	cmpi.b	#']',d4
	bne.s	notp
	bsr	pause
	adda	#1,a0
	bra.s	scroll
notp 	cmpi.b	#'{',d4
	bne.s	not1
	move.l	#0,sclin
	adda	#1,a0
	bra.s	scroll
not1	cmpi.b	#'~',d4
	bne.s	not2
	move.l	#8160,sclin
	adda	#1,a0
	bra.s	scroll
not2	cmpi.b	#'}',d4
	bne.s	none
	move.l	#16320,sclin	
	adda	#1,a0
	bra.s	scroll
none	tst.b	(a0)+			;end of scrl?
	bne.s	chr_val
	bra.s	start

chr_val	subi.b	#32,d4			;wheres that character?
	divu.w	#20,d4			;divide	by number of letters per line
	moveq.l	#0,d5
	move.w	d4,d5
	mulu.w	#272,d5			;multiply by 160 (bytes per line) * height
	mulu.w	#10,d5
	clr.w	d4
	swap	d4
	asl	#3,d4			;multiply remainder by (width of char)
	lea	font,a5
	add.w	d5,a5
	add.w	d4,a5
	;add.l	#160,a5

	;move.w	#0,byt	
	move.w	#16,byt1

	;moveq	#1,d3
	moveq.w	#15,d7
	lea	stc_pad,a6		;copy letter to scratch pad
cpy_chr	move.l	(a5),(a6)
	addq.l	#4,a6
	lea	160(a5),a5
	dbf	d7,cpy_chr

sechalf	move.w	byt1,d6			;pixels across
pixels	move.l	$44e.w,a1		;screen address
	lea	10240(a1),a1		;some where near the bottom!
	adda.l	sclin,a1
	lea	stc_pad,a6
	;adda	byt,a6

	moveq.w	#15,d7			;lines to roxl
lines	move.l	(a6),d0
	lsl.l	d0
	move.l	d0,(a6)+

	roxl	152(a1)			;lotsa roxl's
	roxl	144(a1)
	roxl	136(a1)
	roxl	128(a1)
	roxl	120(a1)
	roxl	112(a1)
	roxl	104(a1)
	roxl	96(a1)
	roxl	88(a1)
	roxl	80(a1)
	roxl	72(a1)
	roxl	64(a1)
	roxl	56(a1)
	roxl	48(a1)
	roxl	40(a1)
	roxl	32(a1)
	roxl	24(a1)
	roxl	16(a1)
	roxl	8(a1)
	roxl	(a1)

	lea	160(a1),a1		;add 160 (1 line) to screen addr
	dbf	d7,lines

	subq.b	#1,speed
	bne.s	no_wait
	move.l	$462.w,d0		;vbl frame counter
vbl	cmp.l	$462.w,d0		;wait for vbl
	beq.s	vbl
	move.b	def_spd,speed

no_wait	dbf	d6,pixels		;rest of the pixels
	;move.w	#160,byt
	;move.w	#10,byt1
	;dbf	d3,sechalf

	move.w	#$ff,-(a7)		;wait for a key press
	move.w	#$06,-(a7)
	trap	#1
	addq.l	#4,a7

	cmpi.b	#"+",d0
	beq	plus
	cmpi.b	#"-",d0
	beq	minus
	cmpi.b	#"0",d0
	bne.s	g1
	eor.b	#2,hertz
	eor.w	#$706,$ffff8242
	bra	return
g1	cmpi.b	#"1",d0
	bne.s	g2
	move.l	#prog1,game
	bra	loadok
g2	cmpi.b	#"2",d0
	bne.s	g3
	move.l	#prog2,game
	bra	loadok
g3	cmpi.b	#"3",d0
	bne.s	g4
	move.l	#prog3,game
	bra	loadok
g4	cmpi.b	#"4",d0
	bne.s	funkey
	move.l	#prog4,game
	bra	loadok
funkey	swap	d0
	cmpi.b	#$3b,d0
	bne.s	f2
f1	moveq	#1,d0
	bsr	music
	bra.s	return
f2	cmpi.b	#$3c,d0
	bne.s	f3
	moveq	#2,d0
	bsr	music
	;bra.s	return
f3	;cmpi.b	#$3d,d0
	;bne.s	f4
	;moveq	#8,d0
	;bsr	music
	;bra.s	return
f4	;cmpi.b	#$3e,d0
	;bne.s	return
	;moveq	#2,d0
	;bsr	music

return	bra	scroll

******* end of scroller code ***************************

pause	move.l	#300,d6
l1	move.l	#5000,d7
l2	dbf	d7,l2
	dbf	d6,l1
	rts

reboot	lea	$70000,a7
	eor.b	#2,$ffff820a
	move.b	#$7,$ffff8201
	move.b	#$80,$ffff8203

	move.w	#8000,d0
	move.l	#$78000,a0
	;move.l	(a0),a0
	lea	rebpic+34,a1
nextlc	move.l	(a1)+,(a0)+
	dbf	d0,nextlc

	lea	$ffff8260.w,a0
	lea	reb_pal,a1
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,-(a0)

	;clr.w	-(a7)
	;move.l	#-1,-(a7)
	;move.l	#-1,-(a7)
	;move.w	#5,-(a7)		;set screen
	;trap	#14
	;lea	12(a7),a7

	clr.l	$426.w
rebloop	bra.s	rebloop
	
******** speed routines **************************

plus	cmpi.b	#8,def_spd
	bgt.s	return
	addq.b	#1,def_spd
	bra.s	return

minus	cmpi.b	#4,def_spd
	blt	return
	subq.b	#1,def_spd
	bra	return

******* end speed routines **************************

loadok	move.w	old_rez,-(a7)		;restore rez
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;set screen
	trap	#14
	lea	12(a7),a7

	lea	def_pal,a0
	lea	$ffff8260.w,a1		;restore colours
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	move.w	#0,$ffff8240
	move.w	#$777,$ffff825e

quit	jsr	off

	clr.l	$426.w
	clr.l	$42a.w
	move.b	hertz,d4
	eor.b	d4,$ff820a

	move.l	old_sp,-(a7)
	move.w	#$20,-(a7)		;user mode
	trap	#1
	addq.l	#6,a7
	
	move.l	game,d4
	clr.l	-(a7)
	move.l	#ct,-(a7)
	move.l	d4,-(a7)
	clr.w	-(a7)
	move.w	#$4b,-(a7)
	trap	#1

	;pea	error(pc)
	;move.w	#9,-(a7)
	;trap	#1		;display message
	;addq.l	#6,a7
	

	;move.w #7,-(a7)		;wait key
	;trap #1			;call gemdos
	;lea 2(a7),a7		;correct stack
	clr.w -(a7)		;terminate
	trap #1			;call gemdos


ct	dc.l	0
hertz	ds.b	1
sclin	ds.l	1
game	ds.l	1
wgam	ds.l	1
prog1	dc.b	"\kultrun.spk",0
prog2	dc.b	"\ultdarts.spk",0
prog3	dc.b	"\quit_out",0
prog4	dc.b	"\derick.spk",0
error	dc.b	"shit !! where's the fucking file !!!",0

scrl	dc.b	"~HIYA, DUDES    ]               THIS MENU WAS CODED IN 100% MACHINE CODE BY          S P I K E     ]I WOULD LIKE TO KNOW WHY SOMEONE DIDN'T FORCE ME TO EAT THE DEVPAC MANUAL BEFORE !!!!"
	dc.b	"                    {I'M UP HERE NOW DUDES AND DUDETTES !!!!!!                    }AND NOW I'M DOWN HERE !!!!!!                    "
	dc.b	"~THE BEST BIT IS WHEN SOMETHING LIKE THIS HAPPENS......"
	dc.b	"                    {    THE        ~WILD!      }BOYS       ]{            ~             }             ~ARE        ]            {SPIKE      ~GORBY      }AND SNAZ     ]{             ~             }              "
	dc.b	"SO WHAT DO YOU THINK OF THAT !!!!          GO ON SAY IT.....           YES, YOU BLOODY WELL SHOULD BE IMPRESSED !!!!!                    {THIS MENU WAS RELEASED AFTER (YES, AFTER!!) MENU 19 AND IT SHOWS!!!!!                    "
	dc.b	"~HERE WE GO AGAIN !!!!                    {IT'S NOT TOO EASY TO READ THIS SCROLLER IS IT !!!!                    }ESPECIALLY WHEN THE LINE KEEPS CHANGING !!                    ~OK, DUDES BEFORE I HAND THIS SCROLLER OVER TO SNAZ I WILL "
	dc.b	"TELL YOU WHAT THE KEYS ARE......                    {F1 FOR MUZAK 1  ~OR        }F2 FOR MUZAK 2  ]"
	dc.b	"{                 ~           }                 {PLUS OR MINUS   ~FOR        }SCROLL SPEED    ]{                ~           }                "
	dc.b	"{       NOW FOR THE PROGRAMS......            1: KULT      ~2: ULTIMATE DARTS }3: WILD! BOOTSECTOR]{              ~                  }                    "
	dc.b	"{AND FINALLY    ~4: DERICK THE DROID}(ONE MEG ONLY!)  ]{                ~                    }                  "
	dc.b	"{OOPS, NEARLY FORGOT.....             PRESS 0 TO    ~CHANGE THE    }HERTZ       ]{               ~               }             "
	dc.b	"{NOW LET'S SEE........        NOPE, NO OTHER KEYS TO TELL YOU ABOUT, SO I'LL PASS YOU ONTO THAT COOL GUY                    ~SNAZ       ]            "
	dc.b	"~WOW, WHAT A COOL INTRO THIS IS !!!!!                    {THIS MENU IS ONLY SUITABLE FOR PIRATES WITH MENUS 17 AND UNDER.                    "
	dc.b	"~IT IS NOT TO BE SUPPLIED TO ANYONE WITHOUT THEM.        WELCOME TO:-                    {THE WILD! BOYS   ~COMPACT DISK    }NUMBER 18     ]{                 "
	dc.b	"~                }               {I AM IN A BAD MOOD TODAY.     LOTS OF THINGS HAVE ADDED TOGETHER TO REALLY DRIVE ME NUTS.      FIRSTLY, "
	dc.b	"I WOKE UP TO FIND THAT THERE WAS NONE OF THOSE MASSIVE JIFFY BAGS (THAT ALL US ST USERS LOVE) ON MY CARPET.  (WHAT NO DISKS!!) SO I HAD TO PLAY KICK OFF FINAL WHISTLE UNTIL THE SECOND POST ARRIVED.                    "
	dc.b	"~SECONDLY, (SCROLL NOW ON THE SECOND LINE !!!          GET IT ??         OH, PLEASE YOURSELF THEN !!!!)      THE BELL RANG ABOUT HALF ELEVEN, I FELL DOWN THE STAIRS, SMACKED MY HEAD ON THE                    "
	dc.b	"}THREE PIECE SUITE    (SURELY YOU GET IT NOW !!!!)      I GOT UP, OPENED THE DOOR AND THERE WAS MR POSTMAN WITH ONE (COUNT 'EM, ONE!!!) BAG OF DISKS. I THOUGHT BETTER THAN NOTHING, SO I OPENED IT.                    "
	dc.b	"{ARH!!!!    F**K!!!    IT'S FROM ONE OF MY DEMO CONTAX.      I MEAN HOW AM I MENT TO SURVIVE WITH JUST ONE BAG OF DEMOS TO KEEP ME ENTERTAINED FOR THE WHOLE DAY.                    ~THIS BRINGS ME ONTO "
	dc.b	"THE NEXT TOPIC.     A TOPIC NOT OF THE SWEETY TYPE BUT OF THE VERY SERIOUS TYPE.......                    {HOW MANY OF YOU READING THIS SCROLL, JUST POTTER ABOUT WITH YOUR ST EVERY SINGLE "
	dc.b	"SPARE MINUTE YOU GET ?                    }WHAT LIKE ME SNAZ?? - (SPIKE)                    ~YES, PEOPLE LIKE SPIKE HERE.....        BE HONEST ABOUT IT.     WHEN YOU'RE NOT CRACKING, PACKING, "
	dc.b	"CODING OR COPYING, WHAT ARE YOU DOING??                    }YOU'RE EITHER PLAYING SOME GAME FROM A MENU,   DOING A PIC    OR    READING A SCROLL (LIKE YOU ARE NOW - SEE CAUGHT YOU!!!)                    "
	dc.b	"{WHY DO WE DO IT ??                    ~WELL, BECAUSE WE ARE ALL BLOODY ADDICTED TO THE ST.   GO ON ADMIT IT.      WELL, IF YOU ARE NOT ADDICTED TO YOUR ST THEN STOP READING THIS SCROLL AND DO SUMMIN' "
	dc.b	"USEFUL, LIKE CUT THE LAWN OR MAYBE DO THE WASHING UP!!!                    }IF YOU'RE STILL HERE YOU HAVE PROBABLY NOW COME TO TERMS WITH BEING AN ST ADDICT. ANYWAY AT LEAST YOU'RE NOT AN A*IGA ADDICT.                    "
	dc.b	"{GREETINGS TIME BOYS AND GIRLS...........     A HAVE NOT SEEN YOU IN AGES, GOES TO        THE POMPEY PIRATES ~AUTOMATION     }BBC + MEDWAY BOYS ]{                    ~               }                  "
	dc.b	"{TIMEWARP     ~THUNDERFORCE   }AWESOME     ]{              ~                }              {EMPIRE       ~FOFT       }FOF       ]{             ~            }            "
	dc.b	"{THE WILD! BOYS  ~(CRACK N PACK)  }(US!!)      ]{                 ~                 }              ~AND        ]            {THE WILD BOYS   ~DEMO CREW     }(HI POWERMAN + FBJ)]{                 "
	dc.b	"~               }                    {PERSONAL GREETS GO TO   JAMES   KEITH   VOODOO   CARL   DEAN   STEVE   JOHN   AND   PHEONIX.                    ~SO, YOU THOUGHT THIS WAS THE END OF THE SCROLL.     "
	dc.b	"AH NNOOO!                    }NOW I'LL TELL YOU ALL ABOUT THE TIME I...........NO, I'LL GIVE YOU A BREAK AS THIS SCROLL IS ALREADY ER, EM, ER, EM                    ~CLOCKING UP THE BYTES?? - (SPIKE)                    "
	dc.b	"{YES, THAT'S IT SPIKE!       CLOCKING UP THE BYTES!!                    ~DID YOU KNOW WE HAVE NOW DONE OVER 20 MENUS !!          I KNOW IT'S NOT A LOT COMPARED TO THE BIG GROUPS BUT WOT THE ECK!!                    "
	dc.b	"}OK SNAZ, I'LL FINISH THIS SCROLLY OFF AS YOU SO KINDLY GAVE ME A HALF FINISHED VERSION OF IT!!!!                    {SPIKE AT THE KEYBOARD.       AND YES, GORBY ISN'T HERE SO YOU WON'T BE READING ANY OF THE "
	dc.b	"CRAP HE VERBALLY SAYS.                    ~I THINK IT'S ABOUT TIME HE PUT GOB TO KEYBOARD !!!            RIGHT, THIS IS WHERE I SAY CHEERIO AND TOODLE PIP, BUT AS THERE ARE TWO OF US HERE (NOW! ANYWAY!!), "
	dc.b	"WE'LL SAY IT TOGETHER.....                    {IT'S GOODBYE    ~FROM        }SPIKE       ]{                ~            }             {AND IT'S GOODBYE  ~FROM        }SNAZ        ]{                  ~            }            "
	dc.b	"{OK PEOPLES,    SO YOU DON'T WANT TO PLAY ANY OF THE GAMES !?!        WELL, I SUPPOSE I HAD BETTER GIVE YOU SOME INFO ON US.                    ~WELL, WE'VE BEEN DOING MENUS SINCE JAN '90.  (YES THAT'S RIGHT.  "
	dc.b	"WELL BEFORE THE OTHER WILD BOYS EVEN EXISTED!)      (SOME 9 MONTHS INFACT - SNAZ).                    }ORIGINAL MEMBERS WERE        SPIKE (ME)        SMUDGER        RASTAN        AND ACE.                    "
	dc.b	"~I'M THE ONLY ORIGINAL MEMBER STILL LEFT !!!!          WE MET SNAZ JUST AFTER WE FINISHED MENU 5, AND HE HAS BEEN DISTRIBUTING OUR DISKS SINCE.                    {HE ASKED IF HE COULD WRITE A SCROLLER FOR US.     "
	dc.b	"WE AGREED FINE.    (ESPECIALLY AS I'M NOT EXACTLY KEEN ON WRITING THEM MYSELF!!).          SO, WAS BORN THE NEW WILD! BOYS.......                    ~OK.    YOU'VE EITHER NODDED OFF, OR YOU'RE ONE OF THOSE "
	dc.b	"SCROLLERHOLICS !!!!        WELL, WHATEVER WE'RE DEFINATLEY SIGNING OFF NOW........                    }I THINK I WILL BOMB OUT IN 5 SECONDS, SO YOU HAD BETTER CHOOSE ONE OF THOSE GAMES TO PLAY OR ELSE....                    "
	dc.b	"~5                    4                    3                    2                    1                    BOMB !!!!     ]               {WRRRRAAAAAPPPP!!! ~WRRRRAAAAAPPPP!!! }WRRRRAAAAAPPPP!!! ]"
	dc.b	"{                    ~                    }                    ]"
	dc.b	0
	;incbin	"a:\18.doc"

new_pal	dc.w	$000,$600,$677,$567,$457,$346,$236,$126,$015,$777,$666,$555,$444,$333,$222,$600
reb_pal	dc.w	$000,$777,$775,$763,$752,$742,$632,$522,$410,$300,$556,$223,$754,$112,$334,$700

	even

font	incbin	"a:\font18.dat"
piccy	incbin	"a:\cd18pic.pi1"
rebpic	incbin	"a:\reboot.pi1"

byt	ds.w	1
byt1	ds.w	1
old_sp	ds.l	1
old_rez	ds.w	1
speed	ds.w	1
def_spd	ds.w	1
def_pal	ds.w	16
stc_pad	ds.l	16
	
 