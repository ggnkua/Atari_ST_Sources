*************************************************
*
* Extension: NetWorld
*
* Modified 29/07/1998
* Due to demand of networking STOS games together
*
*  Interpreter version
*

        OUTPUT  C:\STOS\NETWORLD.EXI

* Jump header
        bra     INIT

***********************************************
*
* Header
*

* Start of token list
        dc.b    128

TOKENS  dc.b	"krfree",128		even=instruction, odd=function
	dc.b	"krmalloc",129
	dc.b	"housekeep",130
	dc.b	"krgetfree",131
	dc.b	"ser_disable",132	* 5
	dc.b	"krrealloc",133
	dc.b	"ser_enable",134
	dc.b	"gerrtxt$",135
	dc.b	"clr_flag",136
	dc.b	"gvstr$",137		* 10
	dc.b	"ofport",138
	dc.b	"carrier_detect",139
	dc.b	"dummynetweb",140
	dc.b	"tcp_open",141
	dc.b	"dummynetweb7",142	* 15
	dc.b	"tcp_close",143
	dc.b	"dummynetweb8",144
	dc.b	"tcp_send",145
	dc.b	"dummynetweb9",146
	dc.b	"tcp_wait_state",147	* 20
	dc.b	"dummynetweb10",148
	dc.b	"tcp_ack_wait",149
	dc.b	"dummynetweb11",150
	dc.b	"udp_open",151
	dc.b	"dummynetweb12",152	* 25
	dc.b	"udp_close",153
	dc.b	"dummynetweb13",154
	dc.b	"udp_send",155
	dc.b	"dummynetweb14",156
	dc.b	"cnkick",157		* 30
	dc.b	"dummynetweb15",158
	dc.b	"cnget_char",159
	dc.b	"dummynetweb16",160
	dc.b	"dummy",161			* cannot be used!
	dc.b	"dummynetweb17",162	* 35
	dc.b	"cnget_ndb",163
	dc.b	"dummynetweb18",164
	dc.b	"cnget_block",165
	dc.b	"dummynetweb19",166
	dc.b	"resolve",167		* 40
	dc.b	"dummynetweb20",168
	dc.b	"set_flag",169
	dc.b	"dummynetweb21",170
	dc.b	"cngetport",171
	dc.b	"dummynetweb22",172	* 45
	dc.b	"oport",173
	dc.b	"dummynetweb23",174
	dc.b	"set_flag",175
	dc.b	"dummynetweb24",176
	dc.b	"stvstr",177		* 50
	dc.b	"dummynetweb25",178
	dc.b	"cngetport",179
	dc.b	"dummynetweb26",180
	dc.b	"queryport",181
	dc.b	"dummynetweb27",182	* 55
	dc.b	"gresolve",183
	dc.b	"dummynetweb28",184
	dc.b	"gtcpwaitstate",185
	dc.b	"dummynetweb29",186
	dc.b	"cnbyte_count",187	* 60
	dc.b	"dummynetweb30",188
	dc.b	"stikinit",189


* The end of the token list
        dc.b    0

	even
	
* Now the jump table

JUMPS	dc.w	62
	dc.l	krfree
	dc.l	krmalloc
	dc.l	housekeep
	dc.l	krgetfree
	dc.l	ser_disable		* 5
	dc.l	krrealloc
	dc.l	ser_enable
	dc.l	gerrtxt
	dc.l	clr_flag
	dc.l	getvstr			* 10
	dc.l	ofport
	dc.l	carrier_detect
	dc.l	dummy
	dc.l	tcp_open
	dc.l	dummy			* 15
	dc.l	tcp_close
	dc.l	dummy
	dc.l	tcp_send
	dc.l	dummy
	dc.l	tcp_wait_state		* 20
	dc.l	dummy
	dc.l	tcp_ack_wait
	dc.l	dummy
	dc.l	udp_open
	dc.l	dummy			* 25
	dc.l	udp_close
	dc.l	dummy
	dc.l	udp_send
	dc.l	dummy
	dc.l	cnkick			* 30
	dc.l	dummy
	dc.l	cnget_char
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy			* 35
	dc.l	cnget_ndb
	dc.l	dummy
	dc.l	cnget_block
	dc.l	dummy
	dc.l	resolve			* 40
	dc.l	dummy
	dc.l	set_flag
	dc.l	dummy
	dc.l	cngetport
	dc.l	dummy			* 45
	dc.l	oport
	dc.l	dummy
	dc.l	set_flag
	dc.l	dummy
	dc.l	stvstr			* 50
	dc.l	dummy
	dc.l	cngetport
	dc.l	dummy
	dc.l	queryport
	dc.l	dummy			* 55
	dc.l	gresolve
	dc.l	dummy
	dc.l	gtcpwaitstate
	dc.l	dummy
	dc.l	cnbyte_count		* 60
	dc.l	dummy
	dc.l	stikky

* The welcome mesages in English and French

WELCOME dc.b    10,13,"                            The NetWorld Extension v1.1"
	dc.b	10,13,"                                    STOS version"
	dc.b	10,13,"                               (c) Paul Jones 1998"
	dc.b	10,13,"                               All rights reserved.",10,13,0


        dc.b    10,13,"                             le Extension Networld v1.1"
        dc.b	10,13,"                                (c) Paul Jones 1998",10,13,0
        even

* Some system variables

RETURN	dc.l	0
SYSTEM	dc.l	0

* The routine that is called on start-up

INIT    lea     END,a0
        lea     COLDST,a1
        rts

COLDST	move.l	a0,SYSTEM
	lea     WELCOME,a0      ; vital stuff
        lea     WARMST,a1
        lea     TOKENS,a2
        lea     JUMPS,a3
        rts

* Executed on UNDO in editor

WARMST  

*****************************************
* init routine to get pointers etc	*
* should be run in SUPER		*
* return: d0=0  no stik found		*
*         d0=-1 stik found but inactive	*
*	  d0=-2 stik found but maybe 	*
*		corrupted		*
*         d0=1  stik active		*
*****************************************

* the following finds the STiK cookie (or STiNGs) and returns certain
* values to which represents the status of it.

stik_init
	movem.l	d0-d1/a0,-(sp)
	move.l	COOKIEJAR.w,a0		;haal koekdoospijl op
	tst.l	(a0)
	beq	.no_jar_found		;we hebben geen koekjes!
	move.l	#"STiK",d0		;ik wil zo'n koekje, mam?
.zoek_koekie2	
	tst.l	(a0)			;de bodem?
	beq	.no_stik_cookie		;yess
	lea	8(a0),a0
	cmp.l	-8(a0),d0		;stik-koekie?
	bne.s	.zoek_koekie2		;
	move.l	-4(a0),stikpointer	;stikpointer ophalen
	bra	.stik_found              
.no_jar_found
.no_stik_cookie
	clr.l	d0			;Stik not found
.leave_stik_init	
	movem.l	(sp)+,d0-d1/a0
	rts
.acterror
*	move.l	#-2,d0
	lea.l	stikinit(pc),a0		* stikinit=-2
	move.l	#-2,(a0)
	bra	.leave_stik_init
.stik_found
	tst.l	stikpointer
	bne	.stik_active
*	move.l	#-1,d0
	lea.l	stikinit(pc),a0		* stikinit=-1
	move.l	#-1,(a0)
	bra	.leave_stik_init
.stik_active
	move.l	stikpointer,a0		;check the magic
	cmp.l	#"STiK",(a0)
	bne	.acterror
	cmp.l	#"magi",4(a0)
	bne	.acterror
	cmp.w	#"c"*256,8(a0)
	bne	.acterror

	lea.l	drvheader(pc),a1
	move.l	10(a0),(a1)		;pointer to drvheader routine
	lea.l	etmexec(pc),a1
	move.l	14(a0),(a1)		;pointer to rout?
	lea.l	stikconfig(pc),a1
	move.l	18(a0),(a1)		;pointer to stikconfig
	lea.l	tplpointer(pc),a1
	move.l	22(a0),(a1)		;pointer to transport structure

        move.l  10(a0),a0                       ;find transport layer
.module
	pea	TRANSPORT_DRIVER(pc)
	jsr	(a0)
	lea	4(sp),sp
	lea.l	tplpointer(pc),a1
	move.l  d0,(a1)           ;pointer to transport structure

	tst.l	(a1)
	beq.s	.tplnotfound

	lea.l	stikinit(pc),a0
	move.l	#1,(a0)
	bra	.leave_stik_init

.tplnotfound
	lea.l	stikinit(pc),a0
	move.l	#-3,(a0)
	bra	.leave_stik_init

******************
*
* Our commands
*
*

*****************************************
*  KRmalloc x.l				*
*  allocate a block of stiks internal	*
*  buffer. returns 0 if failed		*
*  d0=sin otherwise			*
*****************************************
krmalloc	move.l	(sp)+,RETURN
		cmpi	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	12(a0),a0
		jsr	(a0)

		add.l	#4,sp

		move.l	d0,d3
		move.l	#0,d2
		
		move.l	RETURN,a0
		jmp	(a0)

*****************************************
*  KRfree sin.l				*
*  free a block of stiks internal	*
*  buffer. 				*
*****************************************
krfree		move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* sin
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	16(a0),a0
		jsr	(a0)

		add.l	#4,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*****************************************
*  KRgetfree flag.w			*
*****************************************
krgetfree	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	20(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*****************************************
*  KRrealloc block.l,size.l		*
*****************************************
krrealloc	move.l	(sp)+,RETURN
		cmp	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* size
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump1

		movem.l	(sp)+,d2-d4	* block
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump2

		move.l	dump1,-(sp)
		move.l	dump2,-(sp)

		move.l	tplpointer,a0
		move.l	24(a0),a0
		jsr	(a0)

		add.l	#8,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*****************************************
*  get_err_txt error.w			*
*****************************************
gerrtxt		move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* error
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	28(a0),a0
		jsr	(a0)

		add.l	#2,sp

* d0=address of text, convert into text!
* note: STOS needs 0,length,string!

		lea.l	massdump,a1
		add.l	#2,a1

		move.l	d0,a0
		move.l	#0,d1

.next		move.b	(a0)+,d3
		cmp.b	#0,d3
		beq.s	.quit
		move.b	d3,(a1)+
		add.l	#1,d1
		bra.s	.next
.quit		lea.l	massdump,a1
		add.l	#1,a1
		move.b	d1,(a1)

		move.l	#$80,d2
		lea.l	massdump,a0
		move.l	a0,d3

*		move.l	#$80,d2
*		move.l	d0,d3

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
*  getvstr	x.l				*
*************************************************
getvstr		move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		cmp.w	#0,d2
		bne	TYPEMIS

* 0,length,string
* all move back one, add chr$(0) at end
* d3=start

*.text2		add.l	#2,d3

*.text2		add.l	#1,d3
*		move.l	d3,a0
*		move.l	d3,a1

*		move.b	(a0),d0		* d0=length

*.copy		move.b	1(a0),d3
*		move.b	d3,(a0)
*		add.l	#1,a0
*		sub.b	#1,d0
*		cmp.b	#0,d0
*		bne.s	.copy

*		move.b	(a0)+,0

*		add.l	#1,a1
*		move.l	a1,d3
		
		move.l	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	32(a0),a0
		jsr	(a0)

		add.l	#4,sp

* Copy responce into string!
* d0=address

		lea.l	massdump,a1
		add.l	#2,a1

		move.l	d0,a0
		move.l	#0,d1

.next		move.b	(a0)+,d3
		cmp.b	#0,d3
		beq.s	.quit
		move.b	d3,(a1)+
		add.l	#1,d1
		bra.s	.next
.quit		lea.l	massdump,a1
		add.l	#1,a1
		move.b	d1,(a1)

		move.l	#$80,d2
		lea.l	massdump,a0
		move.l	a0,d3

*		move.l	#$80,d2
*		move.l	d0,d3

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* carrier_detect 				*
*************************************************
carrier_detect	move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX

		move.l	tplpointer,a0
		move.l	36(a0),a0
		jsr	(a0)

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* TCP_open h.l,p.w,t.w,o.w			*
*************************************************
tcp_open	move.l	(sp)+,RETURN
		cmp	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* o
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* t
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump2

		movem.l	(sp)+,d2-d4	* p
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump3

		movem.l	(sp)+,d2-d4	* h
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump4

		move.w	dump1,-(sp)
		move.w	dump2,-(sp)
		move.w	dump3,-(sp)
		move.l	dump4,-(sp)

		move.l	tplpointer,a0
		move.l	40(a0),a0
		jsr	(a0)

		add.l	#10,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* TCP_close x.w,y.w				*
*************************************************
tcp_close	move.l	(sp)+,RETURN
		cmp	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump2

		move.w	dump1,-(sp)
		move.w	dump2,-(sp)

		move.l	tplpointer,a0
		move.l	44(a0),a0
		jsr	(a0)

		add.l	#4,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* TCP_send x.w,y.l,z.w				*
*************************************************
tcp_send	move.l	(sp)+,RETURN
		cmp	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* z
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump2

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump3

		move.w	dump1,-(sp)
		move.l	dump2,-(sp)
		move.w	dump3,-(sp)

		move.l	tplpointer,a0
		move.l	48(a0),a0
		jsr	(a0)

		add.l	#8,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* TCP_wait_state x.w,y.w,z.w			*
*************************************************
tcp_wait_state	move.l	(sp)+,RETURN
		cmp	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* z
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump2

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump3

		move.w	dump1,-(sp)
		move.w	dump2,-(sp)
		move.w	dump3,-(sp)

		move.l	tplpointer,a0
		move.l	52(a0),a0
		jsr	(a0)

		add.l	#6,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* TCP_ack_wait x.w,y.w				*
*************************************************
tcp_ack_wait	move.l	(sp)+,RETURN
		cmp	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump2

		move.w	dump1,-(sp)
		move.w	dump2,-(sp)

		move.l	tplpointer,a0
		move.l	56(a0),a0
		jsr	(a0)

		add.l	#4,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* UDP_open x.l,y.w				*
*************************************************
udp_open	move.l	(sp)+,RETURN
		cmp	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump2

		move.w	dump1,-(sp)
		move.l	dump2,-(sp)

		move.l	tplpointer,a0
		move.l	60(a0),a0
		jsr	(a0)

		add.l	#6,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* UDP_close x.w					*
*************************************************
udp_close	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	64(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* UDP_send x.w,y.l,z.w				*
*************************************************
udp_send	move.l	(sp)+,RETURN
		cmp	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* z
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump2

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump3

		move.w	dump1,-(sp)
		move.l	dump2,-(sp)
		move.w	dump3,-(sp)

		move.l	tplpointer,a0
		move.l	68(a0),a0
		jsr	(a0)

		add.l	#8,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* CNkick x.w					*
*************************************************
cnkick		move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	72(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* CNbyte_count x.w				*
*************************************************
cnbyte_count	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	76(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* CNget_char x.w				*
*************************************************
cnget_char	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	80(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* CNget_NDB x.w					*
*************************************************
cnget_ndb	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)	

		move.l	tplpointer,a0
		move.l	84(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* CNget_block x.w,y.l,z.w			*
*************************************************
cnget_block	move.l	(sp)+,RETURN
		cmp	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* z
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump2

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump3

		move.w	dump1,-(sp)
		move.l	dump2,-(sp)
		move.w	dump3,-(sp)

		move.l	tplpointer,a0
		move.l	88(a0),a0
		jsr	(a0)

		add.l	#8,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* housekeep					*
*************************************************
housekeep	move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX

		move.l	tplpointer,a0
		move.l	92(a0),a0
		jsr	(a0)

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
*  resolve dn.l,rdn.l,returnlist.l,size.w	*
*************************************************
resolve		move.l	(sp)+,RETURN
		cmp	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* size
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* returnlist
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump2

		movem.l	(sp)+,d2-d4	* rdn
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump3

		movem.l	(sp)+,d2-d4	* dn
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump4

		move.w	dump1,-(sp)
		move.l	dump2,-(sp)
		move.l	dump3,-(sp)
		move.l	dump4,-(sp)

		move.l	tplpointer,a0
		move.l	96(a0),a0
		jsr	(a0)

		add.l	#14,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* ser_disable					*
*************************************************
ser_disable	move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX

		move.l	tplpointer,a0
		move.l	100(a0),a0
		jsr	(a0)

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* ser_enable					*
*************************************************
ser_enable	move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX

		move.l	tplpointer,a0
		move.l	104(a0),a0
		jsr	(a0)

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* set_flag x.w					*
*************************************************
set_flag	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)

		move.l	tplpointer,a0
		move.l	108(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* clear_flag x.w				*
*************************************************
clr_flag	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)

		move.l	tplpointer,a0
		move.l	112(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* CNgetport x.w					*
*************************************************
cngetport	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,-(sp)

		move.l	tplpointer,a0
		move.l	116(a0),a0
		jsr	(a0)

		add.l	#2,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* on_port x.l					*
*************************************************
oport		move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX


		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,-(sp)

		move.l	tplpointer,a0
		move.l	120(a0),a0
		jsr	(a0)
		add.l	#4,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

* Extras from v1.13 of STiK...

*************************************************
* off_port x.l					*
*************************************************
ofport		move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,-(sp)

		move.l	tplpointer,a0
		move.l	124(a0),a0
		jsr	(a0)

		add.l	#4,sp

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* setvstr x.l,y.l				*
*************************************************
stvstr		move.l	(sp)+,RETURN
		cmp	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump1

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump2

		move.l	dump1,-(sp)
		move.l	dump2,-(sp)

		move.l	tplpointer,a0
		move.l	128(a0),a0
		jsr	(a0)

		add.l	#8,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* query_port x.l				*
*************************************************
queryport	move.l	(sp)+,RETURN
		cmp	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,-(sp)

		move.l	tplpointer,a0
		move.l	132(a0),a0
		jsr	(a0)

		add.l	#4,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
*  g_resolve dn.l,rdn.l,returnlist.l,size.w	*
*************************************************
gresolve	move.l	(sp)+,RETURN
		cmp	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* size
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* returnlist
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump2

		movem.l	(sp)+,d2-d4	* rdn
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump3

		movem.l	(sp)+,d2-d4	* dn
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,dump4

		move.w	dump1,-(sp)
		move.l	dump2,-(sp)
		move.l	dump3,-(sp)
		move.l	dump4,-(sp)

		move.l	tplpointer,a0
		move.l	136(a0),a0
		jsr	(a0)

		add.l	#14,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************************************
* g_TCP_wait_state x.w,y.w,z.w			*
*************************************************
gtcpwaitstate	move.l	(sp)+,RETURN
		cmp	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* z
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump1

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump2

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,dump3

		move.w	dump1,-(sp)
		move.w	dump2,-(sp)
		move.w	dump3,-(sp)

		move.l	tplpointer,a0
		move.l	140(a0),a0
		jsr	(a0)

		add.l	#6,sp

		move.l	d0,d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

* stikky - returns whether system is internet/intranet compliant

stikky		move.l	(sp)+,RETURN
		cmp	#0,d0
		bne	SYNTAX

		lea.l	stikinit(pc),a0
		move.l	(a0),d3
		move.l	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************
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


*************************
*
* Data space
*

global	ds.l	1

*      transprt.h        (c) Steve Adam 1995   steve@netinfo.com.au
*      transprt.s        Goof 1996 arcovang@caiw.nl
*
*      Include this file to use functions from the tcp module.
*      ie: tcp/udp, etc....


TRANSPORT_DRIVER	dc.b	"TRANSPORT_TCPIP",0
TCP_DRIVER_VERSION	dc.b	"01.07",0
	even
** TCP connection states    
TCLOSED		equ 	0   ;No connection.  Null, void, absent, .....        */
TLISTEN		equ 	1   ; Wait for remote request.                         */
TSYN_SENT	equ 	2   ; Connect request sent.  Await matching request    */
TSYN_RECV	equ 	3   ; Wait for connection ACK.  (Listener only??)      */
TESTABLISH	equ 	4   ; Connection is established.  Handshake completed  */
TFIN_WAIT1	equ 	5   ; Await termination request or acknowledgement     */
TFIN_WAIT2	equ 	6   ; Await termination request.                       */
TCLOSE_WAIT	equ 	7   ; Await termination request from local user        */
TCLOSING	equ 	8   ; Await termination acknowledge from remote TCP    */
TLAST_ACK	equ 	9   ; Await acknowledgement of terminate request sent  */
TTIME_WAIT	equ 	10   ; Delay to ensure remote has received term' ACK    */
* TCP and connection ERROR states. */
E_NORMAL	equ 	0	; No error occured...                      */
E_OBUFFULL	equ 	-1	; Output buffer is full                    */
E_NODATA	equ 	-2	; No data available.                       */
E_EOF		equ 	-3	; EOF from remote..						*/
E_RRESET	equ 	-4	; RST received from remote.                */
E_UA		equ 	-5	; RST.  Other end sent unacceptable pkt    */
E_NOMEM		equ 	-6	; Something failed due to lack of memory   */
E_REFUSE	equ 	-7	; Connection refused by remote             */
E_BADSYN	equ 	-8	; A SYN was received in the window         */
E_BADHANDLE	equ 	-9	; Bad connection handle used.              */
E_LISTEN	equ 	-10	; The connection is in LISTEN state        */
E_NOCCB		equ 	-11	; No free CCB's available                  */
E_NOCONNECTION	equ 	-12	; No connection matches this packet. (TCP) */
E_CONNECTFAIL	equ 	-13	; Failure to connect to remote port. (TCP) */
E_BADCLOSE	equ 	-14	; Invalid TCP_close() requested            */
E_USERTIMEOUT	equ 	-15	; A user function timed out                */
E_CNTIMEOUT	equ 	-16	; A the connection timed out               */
E_CANTRESOLVE	equ 	-17	; Can't resolve the hostname               */
E_BADDNAME	equ 	-18	; Domain name or Dotted Dec.  bad format   */
E_LOSTCARRIER	equ 	-19	; The modem disconnected                   */
E_NOHOSTNAME	equ 	-20	; Hostname does not exist                  */
E_DNSWORKLIMIT	equ 	-21	; Resolver Work limit reached              */
E_NONAMESERVER	equ 	-22	; No nameservers could be found for query  */
E_DNSBADFORMAT	equ 	-23	; Bad format of DS query                   */
E_UNREACHABLE	equ 	-24	; Destination unreachable                  */
E_DNSNOADDR	equ 	-25	; No address records exist for host        */
E_LASTERROR	equ 	25	; ABS of last error code in this list      */

* FLagbox Flag definitions	(max 64 flags...) */
FL_do_resolve	equ 	0
FL_housekeep	equ 	1

P_ICMP	equ 	1
P_TCP	equ 	6
P_UDP	equ 	17

COOKIEJAR	equ	$000005a0

stikpointer	ds.l	1	;pointer from stikcookie
drvheader	ds.l	1	;pointer to drvheader routine
etmexec		ds.l	1	;pointer to etm_exec routine
stikconfig	ds.l	1	;pointer to stik config struct
tplpointer	ds.l	1	;pointer to transport structure
stikbasepage	ds.l	1	;pointer to stik basepage
stik_status	ds.l	1	;stik's status

stikinit	ds.l	1	;contains 1 if internet/intranet compliant

dump1		ds.l	1
dump2		ds.l	1
dump3		ds.l	1
dump4		ds.l	1
dump5		ds.l	1


massdump	ds.b	258

*************************
*
* End of code

	dc.l	0
END
