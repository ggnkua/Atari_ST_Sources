


		text



lccCmd00	moveq	#TREDKEY,d0
		bra	lccCmd
lccCmd01	moveq	#TGREENKEY,d0
		bra	lccCmd
lccCmd02	moveq	#TBLUEKEY,d0
		bra	lccCmd
lccCmd03	moveq	#TYELLOWKEY,d0
		bra	lccCmd
lccCmd04	moveq	#TSCANNER,d0
		bra	lccCmd
lccCmd05	moveq	#TNIGHT,d0
		bra	lccCmd
lccCmd06	moveq	#TBMEDKIT,d0
		bra	lccCmd
lccCmd07	moveq	#TBARMOR,d0
		bra	lccCmd
lccCmd08	moveq	#TAMMO0DEF,d0
		bra	lccCmd
lccCmd09	moveq	#TAMMO1DEF,d0
		bra	lccCmd
lccCmd10	moveq	#TAMMO2DEF,d0
		bra	lccCmd
lccCmd11	moveq	#TAMMO3DEF,d0
		bra	lccCmd
lccCmd12	moveq	#TAMMO4DEF,d0
		bra	lccCmd
lccCmd13	moveq	#TAMMO5DEF,d0
		bra	lccCmd
lccCmd14	moveq	#TAMMO6DEF,d0
		bra	lccCmd
lccCmd15	moveq	#TAMMO7DEF,d0
		bra	lccCmd
lccCmd16	moveq	#TAMMO8DEF,d0
		bra	lccCmd
lccCmd17	moveq	#TAMMO9DEF,d0
		bra	lccCmd
lccCmd18	moveq	#TMASK,d0
		bra	lccCmd
lccCmd19	moveq	#TINVUL,d0
		bra	lccCmd
lccCmd20	moveq	#TGENINVUL,d0
		bra	lccCmd
lccCmd21	moveq	#TINVIS,d0
		bra	lccCmd
lccCmd22	moveq	#TGENINVIS,d0
		bra	lccCmd
lccCmd23	moveq	#TPISTOL0,d0
		bra	lccCmd
lccCmd24	moveq	#TPISTOL1,d0
		bra	lccCmd
lccCmd25	moveq	#TPISTOL2,d0
		bra	lccCmd
lccCmd26	moveq	#TPISTOL3,d0
		bra	lccCmd
lccCmd27	moveq	#TPISTOL4,d0
		bra	lccCmd
lccCmd28	moveq	#TPISTOL5,d0
		bra	lccCmd
lccCmd29	moveq	#TPISTOL6,d0
		bra	lccCmd
lccCmd30	moveq	#TPISTOL7,d0
		bra	lccCmd
lccCmd31	moveq	#TPISTOL8,d0
		bra	lccCmd
lccCmd32	moveq	#TPISTOL9,d0
		bra	lccCmd
lccCmd33	moveq	#TRADSUIT,d0
		bra	lccCmd
lccCmd34	moveq	#TGEIGERCOUNTER,d0
		bra.s	lccCmd
lccCmd35	moveq	#TBACKPACK,d0
		bra.s	lccCmd
lccCmd36	moveq	#TMONDETECTOR,d0
		bra.s	lccCmd
lccCmd37	moveq	#TTRNDETECTOR,d0
		bra.s	lccCmd
lccCmd38	moveq	#TSMALLPLAN,d0
		bra.s	lccCmd
lccCmd39	moveq	#TPLAN,d0
		bra.s	lccCmd
lccCmd40	moveq	#TREVOLVINGPLAN,d0
		bra.s	lccCmd
lccCmd41	moveq	#TWELDER,d0
		bra.s	lccCmd
lccCmd42	moveq	#TGIFT,d0
		bra.s	lccCmd
lccCmd43	moveq	#TBIERKRUG,d0
		bra.s	lccCmd
lccCmd44	moveq	#TCONDOM,d0
		bra.s	lccCmd
lccCmd45	moveq	#TIDCARD,d0
		bra.s	lccCmd
lccCmd46	moveq	#TNEVERGET,d0
		bra.s	lccCmd
lccCmd47	moveq	#TPRIMARY,d0
		bra.s	lccCmd
lccCmd48	moveq	#TSECONDARY,d0
		bra.s	lccCmd
lccCmd49	moveq	#TLEVELEND,d0
		bra.s	lccCmd
lccCmd50	moveq	#TCOLOR0,d0
		bra.s	lccCmd
lccCmd51	moveq	#TCOLOR1,d0
		bra.s	lccCmd
lccCmd52	moveq	#TCOLOR2,d0
		bra.s	lccCmd
lccCmd53	moveq	#TCOLOR3,d0
		bra.s	lccCmd
lccCmd54	moveq	#TCOLOR4,d0
		bra.s	lccCmd
lccCmd55	moveq	#TCOLOR5,d0
		bra.s	lccCmd
lccCmd56	moveq	#TCOLOR6,d0
		bra.s	lccCmd
lccCmd57	moveq	#TCOLOR7,d0
		bra.s	lccCmd
lccCmd58	moveq	#TDCOLOR0,d0
		bra.s	lccCmd
lccCmd59	moveq	#TDCOLOR1,d0
		bra.s	lccCmd
lccCmd60	moveq	#TDCOLOR2,d0
		bra.s	lccCmd
lccCmd61	moveq	#TDCOLOR3,d0
		bra.s	lccCmd
lccCmd62	moveq	#TDCOLOR4,d0
		bra.s	lccCmd
lccCmd63	moveq	#TDCOLOR5,d0
		bra.s	lccCmd
lccCmd64	moveq	#TDCOLOR6,d0
		bra.s	lccCmd
lccCmd65	moveq	#TDCOLOR7,d0
		bra.s	lccCmd

		nop

lccCmd		lea	temporaryThing,a0
		move.w	d0,THINGTYPE(a0)

		lea	things,a1
		movea.l	(a1,d0.w*4),a1
		move.l	THGROUT(a1),d0
		beq.s	lcccSkip
		movea.l	d0,a1
		jsr	(a1)
lcccSkip
		lea	lccTxt,a0
		bsr	laptopAppendLines

		rts




		data


lcc00		dc.l	lccCmdString00
		dc.l	lccCmd00
		dc.w	0

lcc01		dc.l	lccCmdString01
		dc.l	lccCmd01
		dc.w	0

lcc02		dc.l	lccCmdString02
		dc.l	lccCmd02
		dc.w	0

lcc03		dc.l	lccCmdString03
		dc.l	lccCmd03
		dc.w	0

lcc04		dc.l	lccCmdString04
		dc.l	lccCmd04
		dc.w	0

lcc05		dc.l	lccCmdString05
		dc.l	lccCmd05
		dc.w	0

lcc06		dc.l	lccCmdString06
		dc.l	lccCmd06
		dc.w	0

lcc07		dc.l	lccCmdString07
		dc.l	lccCmd07
		dc.w	0

lcc08		dc.l	lccCmdString08
		dc.l	lccCmd08
		dc.w	0

lcc09		dc.l	lccCmdString09
		dc.l	lccCmd09
		dc.w	0

lcc10		dc.l	lccCmdString10
		dc.l	lccCmd00
		dc.w	0

lcc11		dc.l	lccCmdString11
		dc.l	lccCmd11
		dc.w	0

lcc12		dc.l	lccCmdString12
		dc.l	lccCmd12
		dc.w	0

lcc13		dc.l	lccCmdString13
		dc.l	lccCmd13
		dc.w	0

lcc14		dc.l	lccCmdString14
		dc.l	lccCmd14
		dc.w	0

lcc15		dc.l	lccCmdString15
		dc.l	lccCmd15
		dc.w	0

lcc16		dc.l	lccCmdString16
		dc.l	lccCmd16
		dc.w	0

lcc17		dc.l	lccCmdString17
		dc.l	lccCmd17
		dc.w	0

lcc18		dc.l	lccCmdString18
		dc.l	lccCmd18
		dc.w	0

lcc19		dc.l	lccCmdString19
		dc.l	lccCmd19
		dc.w	0

lcc20		dc.l	lccCmdString20
		dc.l	lccCmd20
		dc.w	0

lcc21		dc.l	lccCmdString21
		dc.l	lccCmd21
		dc.w	0

lcc22		dc.l	lccCmdString22
		dc.l	lccCmd22
		dc.w	0

lcc23		dc.l	lccCmdString23
		dc.l	lccCmd23
		dc.w	0

lcc24		dc.l	lccCmdString24
		dc.l	lccCmd24
		dc.w	0

lcc25		dc.l	lccCmdString25
		dc.l	lccCmd25
		dc.w	0

lcc26		dc.l	lccCmdString26
		dc.l	lccCmd26
		dc.w	0

lcc27		dc.l	lccCmdString27
		dc.l	lccCmd27
		dc.w	0

lcc28		dc.l	lccCmdString28
		dc.l	lccCmd28
		dc.w	0

lcc29		dc.l	lccCmdString29
		dc.l	lccCmd29
		dc.w	0

lcc30		dc.l	lccCmdString30
		dc.l	lccCmd30
		dc.w	0

lcc31		dc.l	lccCmdString31
		dc.l	lccCmd31
		dc.w	0

lcc32		dc.l	lccCmdString32
		dc.l	lccCmd32
		dc.w	0

lcc33		dc.l	lccCmdString33
		dc.l	lccCmd33
		dc.w	0

lcc34		dc.l	lccCmdString34
		dc.l	lccCmd34
		dc.w	0

lcc35		dc.l	lccCmdString35
		dc.l	lccCmd35
		dc.w	0

lcc36		dc.l	lccCmdString36
		dc.l	lccCmd36
		dc.w	0

lcc37		dc.l	lccCmdString37
		dc.l	lccCmd37
		dc.w	0

lcc38		dc.l	lccCmdString38
		dc.l	lccCmd38
		dc.w	0

lcc39		dc.l	lccCmdString39
		dc.l	lccCmd39
		dc.w	0

lcc40		dc.l	lccCmdString40
		dc.l	lccCmd40
		dc.w	0

lcc41		dc.l	lccCmdString41
		dc.l	lccCmd41
		dc.w	0

lcc42		dc.l	lccCmdString42
		dc.l	lccCmd42
		dc.w	0

lcc43		dc.l	lccCmdString43
		dc.l	lccCmd43
		dc.w	0

lcc44		dc.l	lccCmdString44
		dc.l	lccCmd44
		dc.w	0

lcc45		dc.l	lccCmdString45
		dc.l	lccCmd45
		dc.w	0

lcc46		dc.l	lccCmdString46
		dc.l	lccCmd46
		dc.w	0

lcc47		dc.l	lccCmdString47
		dc.l	lccCmd47
		dc.w	0

lcc48		dc.l	lccCmdString48
		dc.l	lccCmd48
		dc.w	0

lcc49		dc.l	lccCmdString49
		dc.l	lccCmd49
		dc.w	0

lcc50		dc.l	lccCmdString50
		dc.l	lccCmd50
		dc.w	0

lcc51		dc.l	lccCmdString51
		dc.l	lccCmd51
		dc.w	0

lcc52		dc.l	lccCmdString52
		dc.l	lccCmd52
		dc.w	0

lcc53		dc.l	lccCmdString53
		dc.l	lccCmd53
		dc.w	0

lcc54		dc.l	lccCmdString54
		dc.l	lccCmd54
		dc.w	0

lcc55		dc.l	lccCmdString55
		dc.l	lccCmd55
		dc.w	0

lcc56		dc.l	lccCmdString56
		dc.l	lccCmd56
		dc.w	0

lcc57		dc.l	lccCmdString57
		dc.l	lccCmd57
		dc.w	0

lcc58		dc.l	lccCmdString58
		dc.l	lccCmd58
		dc.w	0

lcc59		dc.l	lccCmdString59
		dc.l	lccCmd59
		dc.w	0

lcc60		dc.l	lccCmdString60
		dc.l	lccCmd60
		dc.w	0

lcc61		dc.l	lccCmdString61
		dc.l	lccCmd61
		dc.w	0

lcc62		dc.l	lccCmdString62
		dc.l	lccCmd62
		dc.w	0

lcc63		dc.l	lccCmdString63
		dc.l	lccCmd63
		dc.w	0

lcc64		dc.l	lccCmdString64
		dc.l	lccCmd64
		dc.w	0


		IFEQ LANGUAGE
lccTxt		dc.b	"Running Milan cheat used.",0
		ELSE
lccTxt		dc.b	"Running Milan Cheat angewendet.",0
		ENDC
		even


		IFNE CHEATS1FLAG
		include	"src\laptop\cheats_1.s"
		ENDC

		IFNE CHEATS2FLAG
		include	"src\laptop\cheats_2.s"
		ENDC

		IFNE CHEATS3FLAG
		include	"src\laptop\cheats_3.s"
		ENDC

		IFNE CHEATS4FLAG
		include	"src\laptop\cheats_4.s"
		ENDC

