*************************************************
*
* GEMMA Extension for STOS, interpreter version.
*
* AES extension, v1.50 Part 2
*
* (c)1997 The GEMMA programming team
* All rights reserved.
*
* This source code, (or any derived from it) may only
* only be distributed under the GNU Public Licence
* (available on request). In essence this states that
* this source code must be available and that binaries
* must be distributed as freeware.
*
* The authors reserves the right to change the status of
* this software at any time, without prior warning or
* notification.
*
*    Supervisor mode   - The AES should NOT be called from
*                        supervisor mode (which STOS is in)
*    on-line help (not one help command per new command!)

* Jump header

	output C:\STOS\GEMMA.EXE

        bra     INIT

***********************************************
*
* Header
*

* Start of token list
        dc.b    128

TOKENS  

* even=instruction, odd=function
	dc.b	"wind_new",128		* 1
	dc.b	"rsrc_load",129
	dc.b	"rsrc_free",130
	dc.b	"rsrc_gaddr",131
	dc.b	"rsrc_saddr",132
	dc.b	"rsrc_rcfix",133	* 5
	dc.b	"rsrc_obfix",134

	dc.b	"shel_write",135
	dc.b	"shel_read",136
	dc.b	"shel_get",137
	dc.b	"shel_put",138		* 10
	dc.b	"shel_find",139
	dc.b	"shel_envrn",140
	dc.b	"appl_getinfo",141
	dc.b	"fsel_input",142
	dc.b	"gemmaver$",143		* 15
	dc.b	"fsel_exinput",144
	dc.b	"dummygemma4",145
	dc.b	"frm_center",146
	dc.b	"global",147
	dc.b	"dummygemma5",148	* 20
	dc.b	"pexec",149
	dc.b	"initgemma",150
	dc.b	"gemsys",151		* 23
	dc.b	"storeinit",152
	dc.b	"dummygemma6",153
	dc.b	"initstos",154
	dc.b	"init_appl",155
	dc.b	"exitsys",156
	dc.b	"command$",157

* The end of the token list
        dc.b    0

	even
	
* Now the jump table

JUMPS   dc.w   29		in order of token, starting from 128
	dc.l	wind_new	* 1
	dc.l	rsrc_load
	dc.l	rsrc_free
	dc.l	rsrc_gaddr
	dc.l	rsrc_saddr
	dc.l	rsrc_rcfix	* 5
	dc.l	rsrc_obfix
	dc.l	shel_write
	dc.l	shel_read
	dc.l	shel_get
	dc.l	shel_put	* 10
	dc.l	shel_find
	dc.l	shel_envrn
	dc.l	appl_getinfo
	dc.l	fsel_input
	dc.l	gemmaver	* 15
	dc.l	fsel_exinput
	dc.l	dummy
	dc.l	form_center
	dc.l	gb
	dc.l	dummy		* 20
	dc.l	pexec
	dc.l	initgemma
	dc.l	gemsys		* 23
	dc.l	storeinit
	dc.l	dummy
	dc.l	initstos
	dc.l	initappl
	dc.l	exitsystem
	dc.l	command

* macro to call a given AES routine
aes	macro	aes_number
	move	#\1,d0
	lea	control,a1
	move.w	d0,(a1)+			store the op code
	sub.w	#10,d0
	mulu	#3,d0			size is the priority, not speed
	lea	gem_ctrl_list,a0
	add.w	d0,a0			points to the entry
	moveq	#0,d0
	move.b	(a0)+,d0
	move.w	d0,(a1)+		do control1
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control2
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control3
	clr.w	(a1)			assumes control4=0 (all except RSRC_GADDR)
	move.l	#aes_params,d1
*	move.l	d1,gbstore
	move.w	#200,d0			function number
	trap	#2

	moveq.l	#0,d2
	move.l	d0,d3
	move.w	int_out,d3		usually a returned value
	endm



* The welcome mesages in English and French

WELCOME dc.b	10,13

	dc.b	10,13,"                          The GEMMA Extension v1.52"
	dc.b	10,13,"                       (c) 1997 The GEMMA programming team"
 	dc.b	10,13,"                           AES routines installed.",10,13,0

	dc.b	10,13,"                          le Extension GEMMA v1.52"
	dc.b	10,13,"                     (c) 1997 Le GEMMA programming team"
 	dc.b	10,13,"                        routines de AES installes.",10,13,0
        even

* Some system variables

RETURN		dc.l	0
SYSTEM		dc.l	0
SYSSTORE	ds.l	0

* The routine that is called on start-up

INIT    move.l	a6,SYSSTORE	* address of GEMMAOS desktop info!!!
	lea     END,a0
        lea     COLDST,a1
        rts

COLDST  move.l	a0,SYSTEM
	lea     WELCOME,a0      ; vital stuff
        lea     WARMST,a1
        lea     TOKENS,a2
        lea     JUMPS,a3
        rts

* Executed on UNDO in editor

WARMST  rts


*************************
*
* Our commands
*
*

* The AES commands --------------------------------------------
wind_new	move.l	(sp)+,RETURN
		tst.w	d0
		bne	SYNTAX

		aes	109

		move.l	RETURN,a0
		jmp	(a0)

rsrc_load	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * file_name$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	110
		move.l	RETURN,a0
		jmp	(a0)

rsrc_free	move.l	(sp)+,RETURN
		tst.w	d0
		bne	SYNTAX

		aes	111

		move.l	RETURN,a0
		jmp	(a0)

rsrc_gaddr	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

*		movem.l	(sp)+,d2-d4   * addr&
*		tst.b	d2
*		bne	TYPEMIS
*		move.l	d3,addr_in
		
		movem.l	(sp)+,d2-d4   * index
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * type
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		move.l	#112<<16+2,control
		move.l	#1<<16,control+4
		move.w	#1,control+8		unique!
		move.l	#aes_params,d1
		move.w	#200,d0
		trap	#2
		moveq.l	#0,d2
		move.l	d2,d3
		move.l	addr_out,d3
*		move.l	(addr_out),(addr_in)

		move.l	RETURN,a0
		jmp	(a0)

rsrc_saddr	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * addr&
		tst.b	d2
		bne	TYPEMIS
		move.l	a3,a5
		move.l	a5,(addr)
		move.l	a5,addr_in

		movem.l	(sp)+,d2-d4   * index
		tst.b	d2
		bne	TYPEMIS
		move.w	d2,int_in+2

		movem.l	(sp)+,d2-d4   * type
		tst.b	d2
		bne	TYPEMIS
		move.w	d1,int_in

		aes	113

		* addr
		move.l	(addr),a5
		move.l	addr_out,2(a5)

		move.l	(mystore),a5


		move.l	RETURN,a0
		jmp	(a0)

rsrc_obfix	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * object
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	114
		move.l	RETURN,a0
		jmp	(a0)

rsrc_rcfix	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4    * rc_header
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	115

		move.l	RETURN,a0
		jmp	(a0)

shel_read	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * tail$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * cmd$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	120
		move.l	RETURN,a0
		jmp	(a0)

shel_write	move.l	(sp)+,RETURN
		cmpi.w	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * commandline$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * commandname$
		cmpi.b	#$80,d2                    
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		movem.l	(sp)+,d2-d4   * over
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+4

		movem.l	(sp)+,d2-d4   * gr
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+2

		movem.l	(sp)+,d2-d4   * ex
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		aes	121
		move.l	RETURN,a0
		jmp	(a0)

shel_get	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * length
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * buff&
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	122
		move.l	RETURN,a0
		jmp	(a0)

shel_put	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * length
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.w	d3,int_in

		movem.l	(sp)+,d2-d4   * buff&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	123
		move.l	RETURN,a0
		jmp	(a0)

shel_find	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * file$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	124
		move.l	RETURN,a0
		jmp	(a0)

shel_envrn	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * name$
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * env$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	125
		move.l	RETURN,a0
		jmp	(a0)


appl_getinfo	move.l	(sp)+,RETURN
		cmpi.w	#5,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * ap_gtype
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,int_in+8

		movem.l	(sp)+,d2-d4   * ap_gtype1
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in+6

		movem.l	(sp)+,d2-d4   * ap_gtype2
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.l	2(a5),int_in+4

		movem.l	(sp)+,d2-d4   * ap_gtype3
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	2(a5),int_in+2

		movem.l	(sp)+,d2-d4   * ap_gtype4
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(h_out)
		move.l	2(a5),int_in

		aes	130

		* ap_gtype1
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		* ap_gtype2
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* ap_gtype3
		move.l	(w_out),a5
		move.w	int_out+6,2(a5)

		* ap_gtype4
		move.l	(h_out),a5
		move.w	int_out+8,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

gemmaver	move.l	(sp)+,RETURN
		cmpi	#0,d0		test number of opperands
		bne	SYNTAX

		move.l	#$80,d2		return value - d2=type
		lea	gemma,a0
		move.l	a0,d3		d3=pointer to string
		clr.l	d4

		move.l	RETURN,a0
		jmp	(a0)

operver		move.l	(sp)+,RETURN
		cmpi	#0,d0
		bne	SYNTAX

		move.l	($4f2),sysbase		* Find OS base
		moveq.l	#0,d2
		move.l	(sysbase),a0
		add.w	#2,a0
		move.w	(a0),d3			* Return deek (OS+2)

		move.l	RETURN,a0
		jmp	(a0)

*gem		move.l	(sp)+,RETURN
*		cmpi	#0,d0
*		bne	SYNTAX

*		move.l	($4f2),a0
*		add.w	#$14,a0
*		move.l	(a0),mupb	* mupb

*		moveq.l	#0,d2
*		move.l	mupb,a4
*		move.l	(a4),d4
*		cmp.l	#$87654321,d4

*		beq	yesgem
*		bne	nogem

*		move.l	RETURN,a0
*		jmp	(a0)

*yesgem		move.w	#1,d3
*		move.l	RETURN,a0
*		jmp	(a0)
*		rts
*nogem		move.w	#0,d3
*		move.l	RETURN,a0
*		jmp	(a0)
*		rts

gb		move.l	(sp)+,RETURN
		cmpi.w	#0,d0
		bne	SYNTAX

		moveq.l	#0,d2
		lea.l	global(pc),a0
		move.l	a0,d3

		move.l	RETURN,a0
		jmp	(a0)

initappl	move.l	(sp)+,RETURN
		cmpi.w	#0,d0
		bne	SYNTAX
		
		aes	10

* aes_version=PEEKW(PEEKL(GB+4))

*		move.l	#0,d2
*		move.l	#aes_params,d3

*		lea.l	global,a0
*		add.l	#4,a0
*		
*		move.l	(a0),a1
*		move.w	(a1),d3

		lea.l	aes_params(pc),a0
*		lea.l	global(pc),a0
		move.l	a0,d3

		move.w	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

exitsystem	move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX

* pterm

		move.l	SYSSTORE,a0
		
		move.l	#$8,a2
		move.l	#100,d1
		move.l	a0,a3
		add.l	d1,a3

bit		move.l	(a3)+,(a2)+
		cmp	#$28,a2
		bne	bit

		move.l	(a3)+,$400
		move.l	(a3)+,$404
		move.l	(a3)+,$40C
		
		move.w	#0,-(sp)
		move.w	#$4c,-(sp)
		trap	#1

		move.l	RETURN,a0
		jmp	(a0)

command		move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX

		move.l	$4f2,a0
		move.l	$28(a0),a1
		move.l	(a1),a2		* basepage
		
		clr.l	d1
		move.b	128(a2),d1
		cmp	#0,d1
		beq	.err

		clr.l	d2
		
		move.l	a1,a2
		add.l	#129,a2
		lea.l	file(pc),a3
		move.w	d1,(a3)
		add.l	#2,a3		* 0,x
.cont		move.b	(a2)+,d2
		move.b	d2,(a3)+
		sub.b	#1,d1
		cmp	#0,d1
		bne	.cont

		lea.l	file(pc),a0
		move.l	a0,d3
		bra	.quit

.err		lea.l	file(pc),a0
		move.w	#0,(a0)
		move.l	a0,d3

.quit		move.l	#$80,d2
				
		move.l	RETURN,a0
		jmp	(a0)

pexec		move.l	(sp)+,RETURN
		cmp	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* environment string
		cmpi.b	#0,d2
		bne	TYPEMIS
		move.l	d3,dump1

		movem.l	(sp)+,d2-d4	* commandline
		cmpi.b	#0,d2
		beq	TYPEMIS
		move.l	d3,dump2

		movem.l	(sp)+,d2-d4	* filename
		cmpi.b	#0,d2
		beq	TYPEMIS
		add.l	#2,d3
		move.l	d3,dump3

		movem.l	(sp)+,d2-d4	* mode
		cmpi.b	#0,d2
		bne	TYPEMIS
		move.w	d3,dump4

		move.l	dump1,-(sp)
		move.l	dump2,a0

* get length of command line, then text. Skip 0 at front.

		add.l	#1,a0
		move.l	a0,-(sp)
		move.l	dump3,-(sp)
		move.w	dump4,-(sp)
		move.w	#$4b,-(sp)
		trap	#1		* pexec
		add.l	#16,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

gemsys		move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

* return the address of the pointer to gemsys in GEMMAOS!

		movem.l	(sp)+,d2-d4
		tst.b	d2
		bne	TYPEMIS

		mulu	#4,d3

		move.l	#0,d2
		move.l	SYSSTORE,a0
		add.l	d3,a0
		move.l	(a0),d3

		move.l	RETURN,a0
		jmp	(a0)

initgemma	move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX
		
mysys1		move.l	SYSSTORE,a0
		move.l	a0,-(sp)	* store a0
		move.l	8(a0),-(sp)	* pointer to mouse routine

		lea.l	param,a1
		move.w	#1,(a1)
		move.l	a1,-(sp)	* pointer to mode handler
		move.w	#1,-(sp)	* new mouse mode (relative)
		move.w	#0,-(sp)	* initmous
		trap	#14
		add.l	#12,sp
		move.l	(sp)+,a0

		move.l	$456,a1

		move.l	12(a0),(a1)	* restore VBL 1
		move.l	a0,-(sp)
		
* now to set the mouse
		move.l	#0,addr_in
		move.w	#0,int_in

		aes	78
* now to display the mouse

		move.w	#77,control	graf_handle
		move.w	#0,control+2
		move.w	#5,control+4
		move.w	#0,control+6
		move.w	#0,control+8
		bsr	call_aes

		move.w	d0,current_handle

		move.w	#122,contrl
		clr.w	contrl1
		move.w	#1,contrl3
		move.w	current_handle,contrl6
		move.w	#0,intin
		bsr	call_vdi

		move.l	(sp)+,a0

		move.l	56(a0),d0
		cmp.l	#$30000,d0
		bne	next1

		move.l	72(a0),$ff8260

* setscreen

		move.l	a0,-(sp)

		move.l	56(a0),d0
		cmp.l	#$30000,d0
		bne	next1

* Falcon only res change

next2		move.w	42(a0),-(sp)	* (vsetmode)+2
		move.w	#3,-(sp)	* mode
		move.l	48(a0),-(sp)	* phybase
		move.l	44(a0),-(sp)	* logbase
		move.w	#5,-(sp)	* vsetscreen
		trap	#14
		add.l	#14,sp
		bra	next3

* pre Falcon bits:

next1
		move.w	42(a0),-(sp)	* (vsetmode)+2
		move.l	48(a0),-(sp)	* phybase
		move.l	44(a0),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

next3		move.l	(sp)+,a0
		
		move.w	54(a0),$ff8260
*		move.l	72(a0),$ff8260

		move.l	RETURN,a0
		jmp	(a0)

fsel_input	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * ok (address!)
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in

		movem.l	(sp)+,d2-d4   * name$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * path$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	90

		* ok
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

fsel_exinput	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * promt$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+8

		movem.l	(sp)+,d2-d4   * ok
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in

		movem.l	(sp)+,d2-d4   * name$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in+4

		movem.l	(sp)+,d2-d4   * path$
		cmpi.b	#$80,d2
		bne	TYPEMIS
		addq.l	#2,d3
		move.l	d3,addr_in

		aes	91

		* ok
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

form_center	move.l	(sp)+,RETURN
		cmpi.w	#5,d0
		bne	SYNTAX

* form_center tree&, x, y, w,h

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4   * h
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(h_out)
		move.w	2(a5),int_in+6

		movem.l	(sp)+,d2-d4   * w
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(w_out)
		move.w	2(a5),int_in+4

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(y_out)
		move.w	2(a5),int_in+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(x_out)
		move.w	2(a5),int_in

		movem.l	(sp)+,d2-d4   * tree&
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,addr_in

		aes	54

		* h
		move.l	(h_out),a5
		move.w	int_out+8,2(a5)

		* w
		move.l	(w_out),a5
		move.w	int_out+6,2(a5)

		* y
		move.l	(y_out),a5
		move.w	int_out+4,2(a5)

		* x
		move.l	(x_out),a5
		move.w	int_out+2,2(a5)

		move.l	(mystore),a5

		move.l	RETURN,a0
		jmp	(a0)

storeinit	move.l	(sp)+,RETURN
		cmpi.w	#0,d0
		bne	SYNTAX
		
* store old stuff!

*		pea	setit(pc)
*		move.w	#$26,-(sp)
*		trap	#$e
*		add.l	#6,sp	

		bsr	setit
		
		move.l	RETURN,a0
		jmp	(a0)

*******************
*
* Odds and sods...
*

dummy	move.l	(sp)+,RETURN
	bra	NOTDONE

SYNTAX	moveq	#12,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

TYPEMIS	moveq	#19,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

NOTDONE	moveq	#0,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

call_vdi
	move.l	#vdi_params,d1
	move.w	#$73,d0
	trap	#2
	rts

call_aes
	move.l	#aes,d1
	move.w	#$C8,d0
	trap	#2
	move.w	int_out,d0
	rts

setit	lea	stosstore,a0

	move.l	a0,-(sp)
	move.w	#$22,-(sp)
	trap	#14
	add.l	#2,sp

	move.l	(sp)+,a0

	move.l	d0,72(a0)
	add.l	#16,d0			* kbdvbase+16
	move.l	d0,a1
	move.l	(a1),8(a0)

	move.l	$456,a1

	move.l	(a1)+,12(a0)		* VBL1
	move.l	(a1)+,16(a0)		*    2
	move.l	(a1)+,20(a0)		*    3
	move.l	(a1)+,24(a0)		*    4
	move.l	(a1)+,28(a0)		*    5
	move.l	(a1)+,32(a0)		*    6
	move.l	(a1)+,36(a0)		*    7

	move.l	a0,-(sp)
	move.w	#-1,-(sp)		* vsetmode -1
	move.w	#$58,-(sp)
	trap	#14
	add.l	#4,sp
	move.l	(sp)+,a0

	move.w	d0,40(a0)

	move.l	a0,-(sp)		* logbase
	move.w	#3,-(sp)
	trap	#14
	add.l	#2,sp
	move.l	(sp)+,a0

	move.l	d0,44(a0)

	move.l	a0,-(sp)
	move.w	#2,-(sp)		* physbase
	trap	#14
	add.l	#2,sp
	move.l	(sp)+,a0

	move.l	d0,48(a0)

*	move.l	#0,-(sp)
*	move.w	#$20,-(sp)
*	trap	#1
*	add.l	#6,sp

	move.l	($44c),52(a0)		* SHIFTMD

	move.l	a0,-(sp)

****
* get _MCH cookie
	move.l    $5a0,d0
	tst.l     d0
	beq.s     .nocook       No cookie jar = plain ST.
	move.l    d0,a0
	move.l    #'_VDO',d0

.nextcook
	tst       (a0)
	beq.s     .nocook       No _VDO cookie = plain ST.
	move.l    (a0)+,d1
	cmp.l     d0,d1
	beq.s     .fndcook
	addq.l    #4,a0
	bra.s     .nextcook

.fndcook
	lea       vdocook(pc),a6
	move.l    (a0),d0
	move.l    d0,(a6)
.nocook

	move.l	(sp)+,a0

	move.l	vdocook(pc),d0		* VDO type
	move.l	d0,56(a0)

	move.l	a0,-(sp)
	move.w	#4,-(sp)
	trap	#14
	add.l	#2,sp
	move.l	(sp)+,a0

	move.l	d0,60(a0)		* GETREZ

	move.l	($ff8260),64(a0)	* ST SHIFT

	move.l	($ff8266),68(a0)	* Falcon SPSHIFT

	move.l	a0,-(sp)

.savefv		lea	stosscrbuf(pc),a1
		move.l	#'FVD2',(a1)+	4 bytes header
		move.b	$ff8006,(a1)+	monitor type
		move.b	$ff820a,(a1)+	sync
		move.l	$ff820e,(a1)+	offset & vwrap
		move.w	$ff8266,(a1)+	spshift
		move.l	#$ff8282,a0	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a0
		bne	.loop1
		move.l	#$ff82a2,a0	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a0
		bne	.loop2
		move	$ff82c2,(a1)+	video control
		move	$ff82c0,(a1)+	video clock
		move.b	$ff8260,(a1)+	shifter resolution
		move.b	$ff820a,(a1)+	video sync mode
*		rts

	move.l	(sp)+,a0

	lea	stosscrbuf(pc),a1
	move.l	a1,72(a0)




*	movem.l	(sp)+,a0-a6/d0-d6	* restore registers

*	pea	gemosalert1(pc)
*	move.w	#$13C,-(sp)
*	trap	#1
*	addq.l	#6,sp

	rts

initstos	move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX
		
*		movem.l	(sp)+,d2-d4
*		tst	d2
*		bne	TYPEMIS

*		move.l	d3,dstore
		
*		tst	d3
*		beq	mysys1
*		move.l	stosstore,a0
*		bsr	mysys2
		
		lea.l	stosstore,a0
		move.l	a0,-(sp)	* store a0
		move.l	8(a0),-(sp)	* pointer to mouse routine

		lea.l	param,a1
		move.w	#1,(a1)
		move.l	a1,-(sp)	* pointer to mode handler
		move.w	#1,-(sp)	* new mouse mode (relative)
		move.w	#0,-(sp)	* initmous
		trap	#14
		add.l	#12,sp
		move.l	(sp)+,a0

		move.l	$456,a1

		move.l	12(a0),(a1)	* restore VBL 1

		move.l	a0,a2
		add.l	#72,a0
		
		move.l	(a0),a0

		lea	stosscrbuf(pc),a0		

@setfv		cmp.l	#'FVD2',(a0)+	4 bytes header
*		bne	.error
		
.ready		addq.l	#2,a0
		move.l	$70,-(sp)
		move	sr,-(sp)
		move.l	#.vbl,$70
		move	#$2300,sr
		
		move.l	$466,d0
.wait		cmp.l	$466,d0
		beq	.wait
		
		move.l	(a0)+,$ff820e	offset & vwrap
		move.w	(a0)+,$ff8266	spshift
		move.l	#$ff8282,a1	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a1
		bne	.loop1
		move.l	#$ff82a2,a1	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a1
		bne	.loop2
		move	(a0)+,$ff82c2	video control
		move	(a0)+,$ff82c0	video clock
		addq.l	#1,a0
		move.b	(a0)+,$ff820a	video sync mode
		move	(sp)+,sr
		move.l	(sp)+,$70
		moveq	#0,d0
		bra	.cont
*.error		moveq	#-1,d0
*		rts
*.wrongmon	moveq	#-2,d0
*		rts
*.sm124		cmp.b	#0,(a0)
*		bne	.wrongmon
*		bra	.ready
*.vga		cmp.b	#2,(a0)
*		bne	.wrongmon
*		bra	.ready
.vbl		addq.l	#1,$466
		rte

.cont		move.l	a2,a0
* setscreen
		
		move.w	42(a0),-(sp)	* (vsetmode)+2
		move.w	#3,-(sp)	* mode
		move.l	48(a0),-(sp)	* phybase
		move.l	44(a0),-(sp)	* logbase
		move.w	#5,-(sp)	* vsetscreen
		trap	#14
		add.l	#14,sp
		
*		move.w	54(a0),$ff8260

		move.l	RETURN,a0
		jmp	(a0)

















*
* SETFV.S
*
*	@setfv
*	 Sets the falcon video registers. The data that is
*	 written to the video registers must be a .FV (Falcon Video)
*	 file. Supervisor only.
* In	 a0.l=adr. to Falcon Video data
* Out	 d0.l: 0=no error  -1=error, no FV data  -2=error, wrong monitor (not used yet)
*	 (destroys a0-a1)
*
*	@savefv
*	 Saves the falcon video registers to memory. Supervisor only.
*	 (destroys a0-a1)
*
*	@resorefv
*	 Restores the saved falcon video registers. Supervisor only.
*	 (destroys a0-a1)
*


.setfv2		cmp.l	#'FVD2',(a0)+	4 bytes header
		bne	.error2
		
.ready2		addq.l	#2,a0
		move.l	$70,-(sp)
		move	sr,-(sp)
		move.l	#.vbl2,$70
		move	#$2300,sr
		
		move.l	$466,d0
.wait2		cmp.l	$466,d0
		beq	.wait2
		
		move.l	(a0)+,$ff820e	offset & vwrap
		move.w	(a0)+,$ff8266	spshift
		move.l	#$ff8282,a1	horizontal control registers
.loop3		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a1
		bne	.loop3
		move.l	#$ff82a2,a1	vertical control registers
.loop4		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a1
		bne	.loop4
		move	(a0)+,$ff82c2	video control
		move	(a0)+,$ff82c0	video clock
		addq.l	#1,a0
		move.b	(a0)+,$ff820a	video sync mode
		move	(sp)+,sr
		move.l	(sp)+,$70
		moveq	#0,d0
		rts
.error2		moveq	#-1,d0
		rts
.wrongmon2	moveq	#-2,d0
		rts
.sm1242		cmp.b	#0,(a0)
		bne	.wrongmon2
		bra	.ready2
.vga2		cmp.b	#2,(a0)
		bne	.wrongmon2
		bra	.ready2
.vbl2		addq.l	#1,$466
		rte
		

@savefv		lea	FVbuffer1298(pc),a1
		move.l	#'FVD2',(a1)+	4 bytes header
		move.b	$ff8006,(a1)+	monitor type
		move.b	$ff820a,(a1)+	sync
		move.l	$ff820e,(a1)+	offset & vwrap
		move.w	$ff8266,(a1)+	spshift
		move.l	#$ff8282,a0	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a0
		bne	.loop1
		move.l	#$ff82a2,a0	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a0
		bne	.loop2
		move	$ff82c2,(a1)+	video control
		move	$ff82c0,(a1)+	video clock
		move.b	$ff8260,(a1)+	shifter resolution
		move.b	$ff820a,(a1)+	video sync mode
		rts
		
@restorefv	lea	FVbuffer1298(pc),a0
		bsr	@setfv
		rts


FVbuffer1298	ds.w	24
vdocook		ds.l	1

*************************
*
* Data space...
*

even

file	ds.l	20

* this is a table of pointers to all the AES arrays
aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out

* this is the list of Control parameters for the AES calls
* contains control(1..3), comment is the function number
* (an asterisk indicates it is not defined)
gem_ctrl_list
	dc.b	0,1,0	10	appl_init
	dc.b	2,1,1	11	appl_read
	dc.b	2,1,1	12	appl_write
	dc.b	0,1,1	13	appl_find
	dc.b	2,1,1	14	appl_tplay
	dc.b	1,1,1	15	appl_record
	dc.b	0,0,0	16*
	dc.b	0,0,0	17*
	dc.b	1,3,1	18	appl_search (4.0)
	dc.b	0,1,0	19	appl_exit
	dc.b	0,1,0	20	evnt_keybd
	dc.b	3,5,0	21	evnt_button
	dc.b	5,5,0	22	evnt_mouse
	dc.b	0,1,1	23	evnt_mesag
	dc.b	2,1,0	24	evnt_timer
	dc.b	16,7,1	25	evnt_multi
	dc.b	2,1,0	26	evnt_dclick
	dc.b	0,0,0	27*
	dc.b	0,0,0	28*
	dc.b	0,0,0	29*
	dc.b	1,1,1	30	menu_bar
	dc.b	2,1,1	31	menu_icheck
	dc.b	2,1,1	32	menu_ienable
	dc.b	2,1,1	33	menu_tnormal
	dc.b	1,1,2	34	menu_text
	dc.b	1,1,1	35	menu_register
	dc.b	2,1,2	36	menu_popup (3.3)
	dc.b	2,1,2	37	menu_attach (3.3)
	dc.b	3,1,1	38	menu_istart (3.3)
	dc.b	1,1,1	39	menu_settings (3.3)
	dc.b	2,1,1	40	objc_add
	dc.b	1,1,1	41	objc_delete
	dc.b	6,1,1	42	objc_draw
	dc.b	4,1,1	43	objc_find
	dc.b	1,3,1	44	objc_offset
	dc.b	2,1,1	45	objc_order
	dc.b	4,2,1	46	objc_edit
	dc.b	8,1,1	47	objc_change
	dc.b	4,3,0	48	objc_sysvar
	dc.b	0,0,0	49*
	dc.b	1,1,1	50	form_do
	dc.b	9,1,0	51	form_dial
	dc.b	1,1,1	52	form_alert
	dc.b	1,1,0	53	form_error
	dc.b	0,5,1	54	form_center
	dc.b	3,3,1	55	form_keybd
	dc.b	2,2,1	56	form_button
	dc.b	0,0,0	57*
	dc.b	0,0,0	58*
	dc.b	0,0,0	59*
	dc.b	0,0,0	60*
	dc.b	0,0,0	61*
	dc.b	0,0,0	62*
	dc.b	0,0,0	63*
	dc.b	0,0,0	64*
	dc.b	0,0,0	65*
	dc.b	0,0,0	66*
	dc.b	0,0,0	67*
	dc.b	0,0,0	68*
	dc.b	0,0,0	69*
	dc.b	4,3,0	70	graf_rubberbox
	dc.b	8,3,0	71	graf_dragbox
	dc.b	6,1,0	72	graf_movebox
	dc.b	8,1,0	73	graf_growbox
	dc.b	8,1,0	74	graf_shrinkbox
	dc.b	4,1,1	75	graf_watchbox
	dc.b	3,1,1	76	graf_slidebox
	dc.b	0,5,0	77	graf_handle
	dc.b	1,1,1	78	graf_mouse
	dc.b	0,5,0	79	graf_mkstate
	dc.b	0,1,1	80	scrp_read
	dc.b	0,1,1	81	scrp_write
	dc.b	0,0,0	82*
	dc.b	0,0,0	83*
	dc.b	0,0,0	84*
	dc.b	0,0,0	85*
	dc.b	0,0,0	86*
	dc.b	0,0,0	87*
	dc.b	0,0,0	88*
	dc.b	0,0,0	89*
	dc.b	0,2,2	90	fsel_input
	dc.b	0,2,3	91	fsel_exinput
	dc.b	0,0,0	92*
	dc.b	0,0,0	93*
	dc.b	0,0,0	94*
	dc.b	0,0,0	95*
	dc.b	0,0,0	96*
	dc.b	0,0,0	97*
	dc.b	0,0,0	98*
	dc.b	0,0,0	99*
	dc.b	5,1,0	100	wind_create
	dc.b	5,1,0	101	wind_open
	dc.b	1,1,0	102	wind_close
	dc.b	1,1,0	103	wind_delete
	dc.b	2,5,0	104	wind_get
	dc.b	6,1,0	105	wind_set
	dc.b	2,1,0	106	wind_find
	dc.b	1,1,0	107	wind_update
	dc.b	6,5,0	108	wind_calc
	dc.b	0,0,0	109	wind_new
	dc.b	0,1,1	110	rsrc_load
	dc.b	0,1,0	111	rsrc_free
	dc.b	2,1,0	112 ** Control(4)=1 ** rsrc_gaddr
	dc.b	2,1,1	113	rsrc_saddr
	dc.b	1,1,1	114	rsrc_obfix
	dc.b	0,0,0	115	rsrc_rcfix (4.0)
	dc.b	0,0,0	116*
	dc.b	0,0,0	117*
	dc.b	0,0,0	118*
	dc.b	0,0,0	119*
	dc.b	0,1,2	120	shel_read
	dc.b	3,1,2	121	shel_write
	dc.b	1,1,1	122	shel_get
	dc.b	1,1,1	123	shel_put
	dc.b	0,1,1	124	shel_find
	dc.b	0,1,3	125	shel_envrn
	dc.b	0,0,0	126*
	dc.b	0,0,0	127*
	dc.b	0,0,0	128*
	dc.b	0,0,0	129*
	dc.b	1,5,0	130*	appl_getinfo (4.0)

	even

* these don't need initialising...
dummyout	ds.l	1
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1
gemma		dc.b	0,4,"1.72"

*the VDI parameters

current_handle	ds.w	1

contrl		ds.w	1
contrl1		ds.w	1
contrl2		ds.w	1
contrl3		ds.w	1
contrl4		ds.w	1
contrl5		ds.w	1
contrl6		ds.w	1
contrl7		ds.w	1
contrl8		ds.w	1
contrl9		ds.w	1
contrl10	ds.w	1
contrl11	ds.w	1

intin		ds.w	128
intout		ds.w	128
ptsin		ds.w	128
ptsout		ds.w	128

global2		ds.w	14

vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout
aes		dc.l	control,global2,int_in,int_out,addr_in,addr_out



mystore		ds.l	1
x_out		ds.l	1
y_out		ds.l	1
w_out		ds.l	1
h_out		ds.l	1
button		ds.l	1
kstate		ds.l	1
key_pressed	ds.l	1
gotclicks	ds.l	1
addr		ds.l	1
oldsp		ds.l	1
newsp		ds.l	1

sysbase		ds.l	1
mupb		ds.l	1

dump1		ds.w	1
dump2		ds.l	1
dump3		ds.l	1
dump4		ds.l	1

param		ds.l	4
stosstore	ds.l	100	* for storing pre-STOS stuff
stosscrbuf	ds.l	100
dstore		ds.l	1
gbstore		ds.l	1

END