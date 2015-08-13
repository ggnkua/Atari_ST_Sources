*
immed	equ	5
anyea	equ	$1234
index   equ     100
*
bd      equ     $1234           base displacement
od      equ     $5678           outer displacement
abs     equ     $7ABC           absolute address
longabs equ     $13579BDF       long absolute address
*
	org	$10000
*
*       Effective address tests
*
	tst     d0
	tst     a0
	tst     (a0)
	tst     (a0)+
	tst     -(a0)
	tst     index(a0)
	tst     (index,a0)
	tst     abs.w
	tst     abs.l
	tst     #immed
	tst     index+*(PC)
	tst     (index+*,PC)
*
*       The tough ones: indexed indirect
*
	tst     ([bd,a0,d0],od)
	tst     ([bd,a0],d0,od)
	tst     ([bd])
	tst     ([bd],od)
	tst     ([a0,d0])
	tst     ([bd,a0,d0])
	tst     ([a0,d0],od)
	tst     ([d0])
	tst     ([bd,d0])
	tst     ([d0],od)
	tst     ([bd,d0],od)
	tst     ([bd],d0)
	tst     ([bd],d0,od)
	tst     ([a0],d0)
	tst     ([bd,a0],d0)
	tst     ([a0],d0,od)
*
*       supressed base register cases
*
	tst     ([bd,za0,d0],od)
	tst     ([bd,za0],d0,od)
	tst     ([za0,d0])
	tst     ([bd,za0,d0])
	tst     ([za0,d0],od)
	tst     ([za0],d0)
	tst     ([bd,za0],d0)
	tst     ([za0],d0,od)
*
*       supressed index register
*
	tst     ([bd,a0,zd0],od)
	tst     ([bd,a0],zd0,od)
	tst     ([a0,zd0])
	tst     ([bd,a0,zd0])
	tst     ([a0,zd0],od)
	tst     ([zd0])
	tst     ([bd,zd0])
	tst     ([zd0],od)
	tst     ([bd,zd0],od)
	tst     ([bd],zd0)
	tst     ([bd],zd0,od)
	tst     ([a0],zd0)
	tst     ([bd,a0],zd0)
	tst     ([a0],zd0,od)
*
*       pc relative
*
	tst     ([bd,pc,d0],od)
	tst     ([bd,pc],d0,od)
	tst     ([pc,d0])
	tst     ([bd,pc,d0])
	tst     ([pc,d0],od)
	tst     ([pc],d0)
	tst     ([bd,pc],d0)
	tst     ([pc],d0,od)
*
*       supressed pc relative
*
	tst     ([bd,zpc,d0],od)
	tst     ([bd,zpc],d0,od)
	tst     ([zpc,d0])
	tst     ([bd,zpc,d0])
	tst     ([zpc,d0],od)
	tst     ([zpc],d0)
	tst     ([bd,zpc],d0)
	tst     ([zpc],d0,od)
*
*       supressed base reg and index reg.
*
	tst     ([bd,za0,zd0],od)
	tst     ([bd,za0],zd0,od)
	tst     ([za0,zd0])
	tst     ([bd,za0,zd0])
	tst     ([za0,zd0],od)
	tst     ([za0],zd0)
	tst     ([bd,za0],zd0)
	tst     ([za0],zd0,od)
*
*       index register scaling
*
	tst     ([d0.w*1])
	tst     ([d0.w*2])
	tst     ([d0.w*4])
	tst     ([d0.w*8])
	tst     ([d0.l*1])
	tst     ([d0.l*2])
	tst     ([d0.l*4])
	tst     ([d0.l*8])
*
*       all values for index reg
*
	tst     ([d0.w*1])
	tst     ([d1.w*1])
	tst     ([d2.w*1])
	tst     ([d3.w*1])
	tst     ([d4.w*1])
	tst     ([d5.w*1])
	tst     ([d6.w*1])
	tst     ([d7.w*1])
	tst     ([zd0.w*1])
	tst     ([zd1.w*1])
	tst     ([zd2.w*1])
	tst     ([zd3.w*1])
	tst     ([zd4.w*1])
	tst     ([zd5.w*1])
	tst     ([zd6.w*1])
	tst     ([zd7.w*1])
*
*       forced size on base disp./outer disp.
*
	tst     ([bd.w],od.w)
	tst     ([bd.l],od.w)
	tst     ([bd.w],od.l)
	tst     ([bd.l],od.l)
*
*       a very long instruction
*
	move.l  ([bd.l,a0,d0.l*8],od.l),([bd.l,sp,d7.l*8],od.l)
*
*       68020 instruction set tests
*
	abcd.b          d0,d0
	abcd            d0,d0
	abcd.b          -(a0),-(a0)
	abcd            -(a0),-(a0)
	add.b           #immed,(a4)
	add.w           #immed,(a4)
	add.l           #immed,(a4)
	add             #immed,(a4)
	add.w           anyea,d0
	add.l           anyea,d0
	add             anyea,d0
	add.b           (a6),d0
	add.b           d0,(a2)
	add.w           d0,(a2)
	add.l           d0,(a2)
	add             d0,(a2)
	adda            anyea,a0
	adda.w          anyea,a0
	adda.l          anyea,a0
	addi.b          #immed,(a4)
	addi.w          #immed,(a4)
	addi.l          #immed,(a4)
	addi            #immed,(a4)
	addq.b          #immed,(a5)
	addq.w          #immed,(a5)
	addq.l          #immed,(a5)
	addq            #immed,(a5)
	addx.b          d0,d0
	addx.w          d0,d0
	addx.l          d0,d0
	addx            d0,d0
	addx.b          -(a0),-(a0)
	addx.w          -(a0),-(a0)
	addx.l          -(a0),-(a0)
	addx            -(a0),-(a0)
	and.b           (a6),d0
	and.w           (a6),d0
	and.l           (a6),d0
	and             (a6),d0
	and.b           d0,(a2)
	and.w           d0,(a2)
	and.l           d0,(a2)
	and             d0,(a2)
	and.b           #immed,(a4)
	and.w           #immed,(a4)
	and.l           #immed,(a4)
	and             #immed,(a4)
	and.b           #immed,CCR
	and             #immed,CCR
	and.w           #immed,SR
	and             #immed,SR
	andi.b          #immed,(a4)
	andi.w          #immed,(a4)
	andi.l          #immed,(a4)
	andi            #immed,(a4)
	andi.b          #immed,CCR
	andi            #immed,CCR
	andi.w          #immed,SR
	andi            #immed,SR
	asl.w           (a2)
	asl             (a2)
	asl.b           d0,d0
	asl.w           d0,d0
	asl.l           d0,d0
	asl             d0,d0
	asl.b           #immed,d0
	asl.w           #immed,d0
	asl.l           #immed,d0
	asl             #immed,d0
	asr.w           (a2)
	asr             (a2)
	asr.b           d0,d0
	asr.w           d0,d0
	asr.l           d0,d0
	asr             d0,d0
	asr.b           #immed,d0
	asr.w           #immed,d0
	asr.l           #immed,d0
	asr             #immed,d0
bcclabel
	bcc.b           bcclabel
	bcc.w           bcclabel
	bcc.l           bcclabel
	bcc             bcclabel
	bcs             bcclabel
	beq             bcclabel
	bge             bcclabel
	bgt             bcclabel
	bhi             bcclabel
	ble             bcclabel
	bls             bcclabel
	blt             bcclabel
	bmi             bcclabel
	bne             bcclabel
	bpl             bcclabel
	bvc             bcclabel
	bvs             bcclabel
	bra             bcclabel
	bsr             bcclabel
	bchg.l          d0,d0
	bchg            d0,d0
	bchg.l          #immed,d0
	bchg            #immed,d0
	bchg            d0,(a0)
	bchg            #immed,(a0)
	bclr            d0,d0
	bclr            #immed,d0
	bclr            d0,(a0)
	bclr            #immed,(a0)
	bset            d0,d0
	bset            #immed,d0
	bset            d0,(a0)
	bset            #immed,(a0)
	btst            d0,d0
	btst            #immed,d0
	btst            d0,(a6)
	btst            #immed,(a6)
*
	bfchg           (a1){d0:d0}
	bfchg           (a1){d0:immed}
	bfchg           (a1){immed:d0}
	bfchg           (a1){immed:immed}
	bfclr           (a1){d0:immed}
	bfexts          d0{d0:immed},d0
	bfexts          (a0){d0:immed},d0
	bfextu          d0{d0:immed},d0
	bfextu          (a0){d0:immed},d0
	bfffo           d0{d0:immed},d0
	bfffo           (a0){d0:immed},d0
	bfins           d0,(a1){d0:immed}
	bfset           (a1){d0:immed}
	bftst           d0{d0:immed}
	bftst           (a0){d0:immed}
	bkpt            #immed
	callm           #immed,(a0)
	cas.b           d0,d0,(a2)
	cas.w           d0,d0,(a2)
	cas.l           d0,d0,(a2)
	cas             d0,d0,(a2)
	cas2.w          d0:D1,d0:D1,(A5):(d0)
	cas2.l          d0:D1,d0:D1,(A5):(d0)
	cas2            d0:D1,d0:D1,(A5):(d0)
	cas2            d0:d1,d2:d3,(d4):(d5)
	chk.w           (a6),d0
	chk.l           (a6),d0
	chk             (a6),d0
	chk2.b          (a0),a0
	chk2.w          (a0),a0
	chk2.l          (a0),a0
	chk2            (a0),a0
	chk2.b          (a0),d0
	chk2.w          (a0),d0
	chk2.l          (a0),d0
	chk2            (a0),d0
	clr.b           (a4)
	clr.w           (a4)
	clr.l           (a4)
	clr             (a4)
	cmp.b           #immed,(a6)
	cmp.w           #immed,(a6)
	cmp.l           #immed,(a6)
	cmp             #immed,(a6)
	cmp.w           anyea,d0
	cmp.l           anyea,d0
	cmp             anyea,d0
	cmp.b           (a6),d0
	cmpa.w          anyea,a0
	cmpa.l          anyea,a0
	cmpa            anyea,a0
	cmpi.b          #immed,(a6)
	cmpi.w          #immed,(a6)
	cmpi.l          #immed,(a6)
	cmpi            #immed,(a6)
	cmpm.b          (a0)+,(a0)+
	cmpm.w          (a0)+,(a0)+
	cmpm.l          (a0)+,(a0)+
	cmpm            (a0)+,(a0)+
	cmp2.b          (a0),a0
	cmp2.w          (a0),a0
	cmp2.l          (a0),a0
	cmp2            (a0),a0
	cmp2.b          (a0),d0
	cmp2.w          (a0),d0
	cmp2.l          (a0),d0
	cmp2            (a0),d0
dbcclabel
	dbcc            d0,dbcclabel
	dbcs            d0,dbcclabel
	dbeq            d0,dbcclabel
	dbf             d0,dbcclabel
	dbge            d0,dbcclabel
	dbgt            d0,dbcclabel
	dbhi            d0,dbcclabel
	dble            d0,dbcclabel
	dbls            d0,dbcclabel
	dblt            d0,dbcclabel
	dbmi            d0,dbcclabel
	dbne            d0,dbcclabel
	dbpl            d0,dbcclabel
	dbt             d0,dbcclabel
	dbvc            d0,dbcclabel
	dbvs            d0,dbcclabel
	dbra            d0,dbcclabel
	divs.w          (a6),d0
	divs            (a6),d0
	divs.l          (a6),d0
	divs.l          (a6),d0:D1
	divsl.l         (a6),d0:D1
	divsl           (a6),d0:D1
	divu.w          (a6),d0
	divu            (a6),d0
	divu.l          (a6),d0
	divu.l          (a6),d0:D1
	divul.l         (a6),d0:D1
	divul           (a6),d0:D1
	eor.b           d0,(a4)
	eor.w           d0,(a4)
	eor.l           d0,(a4)
	eor             d0,(a4)
	eor.b           #immed,(a4)
	eor.w           #immed,(a4)
	eor.l           #immed,(a4)
	eor             #immed,(a4)
	eor.b           #immed,CCR
	eor             #immed,CCR
	eor.w           #immed,SR
	eor             #immed,SR
	eori.b          #immed,(a4)
	eori.w          #immed,(a4)
	eori.l          #immed,(a4)
	eori            #immed,(a4)
	eori.b          #immed,CCR
	eori            #immed,CCR
	eori.w          #immed,SR
	eori            #immed,SR
	exg.l           d0,d0
	exg             d0,d0
	exg.l           a0,a0
	exg             a0,a0
	exg.l           d0,a0
	exg             d0,a0
	exg.l           a0,d0
	exg             a0,d0
*
	exg             d0,d1
	exg             d0,a1
	exg             a0,d1
	exg             a0,a1
*
	ext.w           d0
	ext             d0
	ext.l           d0
	extb.l          d0
	extb            d0
	illegal
	jmp             (a0)
	jsr             (a0)
	lea.l           (a0),a0
	lea             (a0),a0
	link.w          a0,#immed
	link            a0,#immed
	link.l          a0,#immed
	lsl.w           (a2)
	lsl             (a2)
	lsl.b           d0,d0
	lsl.w           d0,d0
	lsl.l           d0,d0
	lsl             d0,d0
	lsl.b           #immed,d0
	lsl.w           #immed,d0
	lsl.l           #immed,d0
	lsl             #immed,d0
	lsr.w           (a2)
	lsr             (a2)
	lsr.b           d0,d0
	lsr.w           d0,d0
	lsr.l           d0,d0
	lsr             d0,d0
	lsr.b           #immed,d0
	lsr.w           #immed,d0
	lsr.l           #immed,d0
	lsr             #immed,d0
	move.w          anyea,(a4)
	move            anyea,(a4)
	move.b          (a6),(a4)
	move.l          anyea,(a4)
	move.w          anyea,a0
	move            anyea,a0
	move.l          anyea,a0
	move.w          CCR,(a4)
	move            CCR,(a4)
	move.w          (a6),CCR
	move            (a6),CCR
	move.w          SR,(a4)
	move            SR,(a4)
	move.w          (a6),SR
	move            (a6),SR
	move.l          usp,a0
	move            usp,a0
	move.l          a0,usp
	move            a0,usp
	movea.w         anyea,a0
	movea           anyea,a0
	movea.l         anyea,a0
	movec.l         sfc,a0
	movec           dfc,a0
	movec.l         vbr,d0
	movec           cacr,d0
	movec.l         a0,usp
	movec           a0,caar
	movec.l         d0,msp
	movec           d0,isp
	movem.w         a0-a3,-(a0)
	movem           a0-a3,-(a0)
	movem.l         a0-a3,-(a0)
	movem.w         (a0)+,a0-a3
	movem           (a0)+,a0-a3
	movem.l         (a0)+,a0-a3
	movem           a0-a7/d0-d7,-(sp)
	movem           a7-a0/d7-d0,-(sp)
	movem           (sp)+,a0-a7/d0-d7
	movem           (sp)+,a7-a0/d7-d0
	movem           a0/a2/a4/a6/d0/d2/d4/d6,(sp)
	movem           d3,-(sp)
	movem           (sp)+,d3
	movem           a0-a3/d0-d3,(sp)
	movem           a0-a3/d0-d3,-(sp)
	movep.w         d0,index(a0)
	movep           d0,index(a0)
	movep.l         d0,index(a0)
	movep.w         index(a0),d0
	movep           index(a0),d0
	movep.l         index(a0),d0
	moveq.l         #immed,d0
	moveq           #immed,d0
	moves.b         a0,(a2)
	moves.w         a0,(a2)
	moves.l         a0,(a2)
	moves           a0,(a2)
	moves.b         d0,(a2)
	moves.w         d0,(a2)
	moves.l         d0,(a2)
	moves           d0,(a2)
	moves.b         (a2),a0
	moves.w         (a2),a0
	moves.l         (a2),a0
	moves           (a2),a0
	moves.b         (a2),d0
	moves.w         (a2),d0
	moves.l         (a2),d0
	moves           (a2),d0
	muls.w          (a6),d0
	muls            (a6),d0
	muls.l          (a6),d0
	muls.l          (a6),d0:D1
	mulu.w          (a6),d0
	mulu            (a6),d0
	mulu.l          (a6),d0
	mulu.l          (a6),d0:D1
	nbcd.b          (a4)
	nbcd            (a4)
	neg.b           (a4)
	neg.w           (a4)
	neg.l           (a4)
	neg             (a4)
	negx.b          (a4)
	negx.w          (a4)
	negx.l          (a4)
	negx            (a4)
	nop
	not.b           (a4)
	not.w           (a4)
	not.l           (a4)
	not             (a4)
	or.b            (a6),d0
	or.w            (a6),d0
	or.l            (a6),d0
	or              (a6),d0
	or.b            d0,(a2)
	or.w            d0,(a2)
	or.l            d0,(a2)
	or              d0,(a2)
	or.b            #immed,(a4)
	or.w            #immed,(a4)
	or.l            #immed,(a4)
	or              #immed,(a4)
	or.b            #immed,CCR
	or              #immed,CCR
	or.w            #immed,SR
	or              #immed,SR
	ori.b           #immed,(a4)
	ori.w           #immed,(a4)
	ori.l           #immed,(a4)
	ori             #immed,(a4)
	ori.b           #immed,CCR
	ori             #immed,CCR
	ori.w           #immed,SR
	ori             #immed,SR
	pack            -(a0),-(a0),#immed
	pack            d0,d0,#immed
	pea.l           (a0)
	pea             (a0)
	reset
	rol.w           (a2)
	rol             (a2)
	rol.b           d0,d0
	rol.w           d0,d0
	rol.l           d0,d0
	rol             d0,d0
	rol.b           #immed,d0
	rol.w           #immed,d0
	rol.l           #immed,d0
	rol             #immed,d0
	ror.w           (a2)
	ror             (a2)
	ror.b           d0,d0
	ror.w           d0,d0
	ror.l           d0,d0
	ror             d0,d0
	ror.b           #immed,d0
	ror.w           #immed,d0
	ror.l           #immed,d0
	ror             #immed,d0
	roxl.w          (a2)
	roxl            (a2)
	roxl.b          d0,d0
	roxl.w          d0,d0
	roxl.l          d0,d0
	roxl            d0,d0
	roxl.b          #immed,d0
	roxl.w          #immed,d0
	roxl.l          #immed,d0
	roxl            #immed,d0
	roxr.w          (a2)
	roxr            (a2)
	roxr.b          d0,d0
	roxr.w          d0,d0
	roxr.l          d0,d0
	roxr            d0,d0
	roxr.b          #immed,d0
	roxr.w          #immed,d0
	roxr.l          #immed,d0
	roxr            #immed,d0
	rtd             #immed
	rte
	rtm             a0
	rtm             d0
	rtr
	rts
	sbcd.b          d0,d0
	sbcd            d0,d0
	sbcd.b          -(a0),-(a0)
	sbcd            -(a0),-(a0)
	scc.b           (a4)
	scc             (a4)
	scs             (a4)
	seq             (a4)
	sf              (a4)
	sge             (a4)
	sgt             (a4)
	shi             (a4)
	sle             (a4)
	sls             (a4)
	slt             (a4)
	smi             (a4)
	sne             (a4)
	spl             (a4)
	st              (a4)
	svc             (a4)
	svs             (a4)
	stop            #immed
	sub.b           #immed,(a4)
	sub.w           #immed,(a4)
	sub.l           #immed,(a4)
	sub             #immed,(a4)
	sub.w           anyea,d0
	sub.l           anyea,d0
	sub             anyea,d0
	sub.b           (a6),d0
	sub.b           d0,(a2)
	sub.w           d0,(a2)
	sub.l           d0,(a2)
	sub             d0,(a2)
	suba.w          anyea,a0
	suba.l          anyea,a0
	suba            anyea,a0
	subi.b          #immed,(a4)
	subi.w          #immed,(a4)
	subi.l          #immed,(a4)
	subi            #immed,(a4)
	subq.b          #immed,(a5)
	subq.w          #immed,(a5)
	subq.l          #immed,(a5)
	subq            #immed,(a5)
	subx.b          d0,d0
	subx.w          d0,d0
	subx.l          d0,d0
	subx            d0,d0
	subx.b          -(a0),-(a0)
	subx.w          -(a0),-(a0)
	subx.l          -(a0),-(a0)
	subx            -(a0),-(a0)
	swap.w          d0
	swap            d0
	tas.b           (a4)
	tas             (a4)
	trap            #immed
	trapcc
	trapcc.w        #immed
	trapcc.l        #immed
	trapcs
	trapcs.w        #immed
	trapcs.l        #immed
	trapeq
	trapeq.w        #immed
	trapeq.l        #immed
	trapf
	trapf.w         #immed
	trapf.l         #immed
	trapge
	trapge.w        #immed
	trapge.l        #immed
	trapgt
	trapgt.w        #immed
	trapgt.l        #immed
	traphi
	traphi.w        #immed
	traphi.l        #immed
	traple
	traple.w        #immed
	traple.l        #immed
	trapls
	trapls.w        #immed
	trapls.l        #immed
	traplt
	traplt.w        #immed
	traplt.l        #immed
	trapmi
	trapmi.w        #immed
	trapmi.l        #immed
	trapne
	trapne.w        #immed
	trapne.l        #immed
	trappl
	trappl.w        #immed
	trappl.l        #immed
	trapt
	trapt.w         #immed
	trapt.l         #immed
	trapvc
	trapvc.w        #immed
	trapvc.l        #immed
	trapvs
	trapvs.w        #immed
	trapvs.l        #immed
	trapv
	tst.w           anyea
	tst.l           anyea
	tst             anyea
	tst.b           (a6)
	unlk            a0
	unpk            -(a0),-(a0),#immed
	unpk            d0,d0,#immed
*
*       Floating point
*
	fabs.b          (a0),fp0
	fabs.w          (a0),fp0
	fabs.l          (a0),fp0
	fabs.s          (a0),fp0
	fabs.d          (a0),fp0
	fabs.x          (a0),fp0
	fabs.p          (a0),fp0
	fabs.x          fp0
	fabs.x          fp0,fp1
*
	facos.x         fp0
	facos.d         (a0),fp0
	facos.x         fp0,fp1
	fadd.d          (a0),fp0
	fadd.x          fp0,fp1
	fasin.x         fp0
	fasin.d         (a0),fp0
	fasin.x         fp0,fp1
	fatan.x         fp0
	fatan.d         (a0),fp0
	fatan.x         fp0,fp1
	fatanh.x	fp0
	fatanh.d	(a0),fp0
	fatanh.x        fp0,fp1
fbcclab
	fbra.w          fbcclab
	fbra.l          fbcclab
	fbra            fbcclab
	fbeq            fbcclab
	fbf             fbcclab
	fbge            fbcclab
	fbgl            fbcclab
	fbgle           fbcclab
	fbgt            fbcclab
	fble            fbcclab
	fblt            fbcclab
	fbne            fbcclab
	fbnge           fbcclab
	fbngl           fbcclab
	fbngle          fbcclab
	fbngt           fbcclab
	fbnle           fbcclab
	fbnlt           fbcclab
	fboge           fbcclab
	fbogl           fbcclab
	fbogt           fbcclab
	fbole           fbcclab
	fbolt           fbcclab
	fbor            fbcclab
	fbseq           fbcclab
	fbsf            fbcclab
	fbsne           fbcclab
	fbst            fbcclab
	fbt             fbcclab
	fbueq           fbcclab
	fbuge           fbcclab
	fbugt           fbcclab
	fbule           fbcclab
	fbult           fbcclab
	fbun            fbcclab
	fcmp.d          (a0),fp0
	fcmp.x          fp0,fp1
	fcos.x          fp0
	fcos.d          (a0),fp0
	fcos.x          fp0,fp1
	fcosh.x         fp0
	fcosh.d         (a0),fp0
	fcosh.x         fp0,fp1
fdbcclabel
	fdbeq           d0,fdbcclabel
	fdbf            d0,fdbcclabel
	fdbge           d0,fdbcclabel
	fdbgl           d0,fdbcclabel
	fdbgle          d0,fdbcclabel
	fdbgt           d0,fdbcclabel
	fdble           d0,fdbcclabel
	fdblt           d0,fdbcclabel
	fdbne           d0,fdbcclabel
	fdbnge          d0,fdbcclabel
	fdbngl          d0,fdbcclabel
	fdbngle         d0,fdbcclabel
	fdbngt          d0,fdbcclabel
	fdbnle          d0,fdbcclabel
	fdbnlt          d0,fdbcclabel
	fdboge          d0,fdbcclabel
	fdbogl          d0,fdbcclabel
	fdbogt          d0,fdbcclabel
	fdbole          d0,fdbcclabel
	fdbolt          d0,fdbcclabel
	fdbor           d0,fdbcclabel
	fdbra           d0,fdbcclabel
	fdbseq          d0,fdbcclabel
	fdbsf           d0,fdbcclabel
	fdbsne          d0,fdbcclabel
	fdbst           d0,fdbcclabel
	fdbt            d0,fdbcclabel
	fdbueq          d0,fdbcclabel
	fdbuge          d0,fdbcclabel
	fdbugt          d0,fdbcclabel
	fdbule          d0,fdbcclabel
	fdbult          d0,fdbcclabel
	fdbun           d0,fdbcclabel
	fdiv.d          (a0),fp0
	fdiv.x          fp0,fp1
	fetox.x         fp0
	fetox.d         (a0),fp0
	fetox.x         fp0,fp1
	fetoxm1.x	fp0
	fetoxm1.d	(a0),fp0
	fetoxm1.x	fp0,fp1
	fgetexp.x	fp0
	fgetexp.d	(a0),fp0
	fgetexp.x	fp0,fp1
	fgetman.x	fp0
	fgetman.d	(a0),fp0
	fgetman.x	fp0,fp1
	fint.x          fp0
	fint.d          (a0),fp0
	fint.x          fp0,fp1
	fintrz.x	fp0
	fintrz.d	(a0),fp0
	fintrz.x	fp0,fp1
	flog10.x	fp0
	flog10.d	(a0),fp0
	flog10.x	fp0,fp1
	flog2.x         fp0
	flog2.d         (a0),fp0
	flog2.x         fp0,fp1
	flogn.x         fp0
	flogn.d         (a0),fp0
	flogn.x         fp0,fp1
	flognp1.x	fp0
	flognp1.d	(a0),fp0
	flognp1.x	fp0,fp1
	fmod.d          (a0),fp0
	fmod.x          fp0,fp1
	fmove.d         (a0),fp0
	fmove.x         fp0,fp1
	fmove.d         fp0,(a2)
	fmove.p         fp0,(a2){d0}
	fmove.p         fp0,(a2){immed}
	fmove.l         (a5),fpcr
	fmove.l         (a5),fpsr
	fmove.l         (a5),fpiar
	fmove.l         fpcr,(a6)
	fmove.l         fpsr,(a6)
	fmove.l         fpiar,(a6)
	fmovecr.x       #immed,fp0
	fmovecr         #immed,fp0
	fmovem.x        fp0-fp5,-(a4)
	fmovem.x	d0,-(a4)
	fmovem.x        (a3)+,fp0-fp5
	fmovem.x	(a3)+,d0
	fmovem          (a5),fpcr/fpsr/fpiar
	fmovem          fpcr/fpsr/fpiar,(a6)
	fmul.d          (a0),fp0
	fmul.x          fp0,fp1
	fneg.x          fp0
	fneg.d          (a0),fp0
	fneg.x          fp0,fp1
	fnop
	frem.d          (a0),fp0
	frem.x          fp0,fp1
	frestore	(a3)+
	fsave           -(a4)
	fscale.d	(a0),fp0
	fscale.x	fp0,fp1
	fseq.b          (a2)
	fseq            (a2)
	fsf             (a2)
	fsge            (a2)
	fsgl            (a2)
	fsgle           (a2)
	fsgt            (a2)
	fsle            (a2)
	fslt            (a2)
	fsne            (a2)
	fsnge           (a2)
	fsngl           (a2)
	fsngle          (a2)
	fsngt           (a2)
	fsnle           (a2)
	fsnlt           (a2)
	fsoge           (a2)
	fsogl           (a2)
	fsogt           (a2)
	fsole           (a2)
	fsolt           (a2)
	fsor            (a2)
	fsseq           (a2)
	fssf            (a2)
	fssne           (a2)
	fsst            (a2)
	fst             (a2)
	fsueq           (a2)
	fsuge           (a2)
	fsugt           (a2)
	fsule           (a2)
	fsult           (a2)
	fsun            (a2)
	fsgldiv.d	(a0),fp0
	fsgldiv.x	fp0,fp1
	fsglmul.d	(a0),fp0
	fsglmul.x	fp0,fp1
	fsin.x          fp0
	fsin.d          (a0),fp0
	fsin.x          fp0,fp1
	fsincos.d	(a0),fp0:fp1
	fsincos.x	fp0,fp1:fp2
	fsinh.x         fp0
	fsinh.d         (a0),fp0
	fsinh.x         fp0,fp1
	fsqrt.x         fp0
	fsqrt.d         (a0),fp0
	fsqrt.x         fp0,fp1
	fsub.d          (a0),fp0
	fsub.x          fp0,fp1
	ftan.x          fp0
	ftan.d          (a0),fp0
	ftan.x          fp0,fp1
	ftanh.x         fp0
	ftanh.d         (a0),fp0
	ftanh.x         fp0,fp1
	ftentox.x	fp0
	ftentox.d	(a0),fp0
	ftentox.x	fp0,fp1
	ftrapeq
	ftrapeq.w       #immed
	ftrapeq.l       #immed
	ftrapf
	ftrapf.w        #immed
	ftrapf.l        #immed
	ftrapge
	ftrapge.w       #immed
	ftrapge.l       #immed
	ftrapgl
	ftrapgl.w       #immed
	ftrapgl.l       #immed
	ftrapgle
	ftrapgle.w      #immed
	ftrapgle.l      #immed
	ftrapgt
	ftrapgt.w      #immed
	ftrapgt.l      #immed
	ftraple
	ftraple.w      #immed
	ftraple.l      #immed
	ftraplt
	ftraplt.w      #immed
	ftraplt.l      #immed
	ftrapne
	ftrapne.w      #immed
	ftrapne.l      #immed
	ftrapnge
	ftrapnge.w      #immed
	ftrapnge.l      #immed
	ftrapngl
	ftrapngl.w      #immed
	ftrapngl.l      #immed
	ftrapngle
	ftrapngle.w      #immed
	ftrapngle.l      #immed
	ftrapngt
	ftrapngt.w      #immed
	ftrapngt.l      #immed
	ftrapnle
	ftrapnle.w      #immed
	ftrapnle.l      #immed
	ftrapnlt
	ftrapnlt.w      #immed
	ftrapnlt.l      #immed
	ftrapoge
	ftrapoge.w      #immed
	ftrapoge.l      #immed
	ftrapogl
	ftrapogl.w      #immed
	ftrapogl.l      #immed
	ftrapogt
	ftrapogt.w      #immed
	ftrapogt.l      #immed
	ftrapole
	ftrapole.w      #immed
	ftrapole.l      #immed
	ftrapolt
	ftrapolt.w      #immed
	ftrapolt.l      #immed
	ftrapor
	ftrapor.w      #immed
	ftrapor.l      #immed
	ftrapseq
	ftrapseq.w      #immed
	ftrapseq.l      #immed
	ftrapsf
	ftrapsf.w      #immed
	ftrapsf.l      #immed
	ftrapsne
	ftrapsne.w      #immed
	ftrapsne.l      #immed
	ftrapst
	ftrapst.w      #immed
	ftrapst.l      #immed
	ftrapt
	ftrapt.w      #immed
	ftrapt.l      #immed
	ftrapueq
	ftrapueq.w      #immed
	ftrapueq.l      #immed
	ftrapuge
	ftrapuge.w      #immed
	ftrapuge.l      #immed
	ftrapugt
	ftrapugt.w      #immed
	ftrapugt.l      #immed
	ftrapule
	ftrapule.w      #immed
	ftrapule.l      #immed
	ftrapult
	ftrapult.w      #immed
	ftrapult.l      #immed
	ftrapun
	ftrapun.w       #immed
	ftrapun.l       #immed
	ftest.d         (a0)
	ftest.x         fp0
	ftwotox.x	fp0
	ftwotox.d       (a0),fp0
	ftwotox.x	fp0,fp1
*
*       PMMU
*
pbcclabel
	pbbs.w          pbcclabel
	pbbs.l          pbcclabel
	pbbs            pbcclabel
	pbls            pbcclabel
	pbss            pbcclabel
	pbas            pbcclabel
	pbws            pbcclabel
	pbis            pbcclabel
	pbgs            pbcclabel
	pbcs            pbcclabel
	pbbc            pbcclabel
	pblc            pbcclabel
	pbsc            pbcclabel
	pbac            pbcclabel
	pbwc            pbcclabel
	pbic            pbcclabel
	pbgc            pbcclabel
	pbcc            pbcclabel
pdbcclabel
	pdbbs.w         d0,pdbcclabel
	pdbbs           d0,pdbcclabel
	pdbls           d0,pdbcclabel
	pdbss           d0,pdbcclabel
	pdbas           d0,pdbcclabel
	pdbws           d0,pdbcclabel
	pdbis           d0,pdbcclabel
	pdbgs           d0,pdbcclabel
	pdbcs           d0,pdbcclabel
	pdbbc           d0,pdbcclabel
	pdblc           d0,pdbcclabel
	pdbsc           d0,pdbcclabel
	pdbac           d0,pdbcclabel
	pdbwc           d0,pdbcclabel
	pdbic           d0,pdbcclabel
	pdbgc           d0,pdbcclabel
	pdbcc           d0,pdbcclabel
	pflusha
	pflush          d0{immed}
	pflush          $F{immed}
	pflush          sfc{immed}
	pflush          dfc{immed}
	pflush          d0{immed},(a2)
	pflushg         d0,$3
	pflushg         d0,$3,(a2)
	pflushr         (a3)
	ploadr          d0,(a2)
	ploadw          d0,(a2)
	pmove.b         (a4),tc
	pmove.w         (a4),tc
	pmove.l         (a4),tc
	pmove           (a4),tc
	pmove.b         tc,(a5)
	pmove.w         tc,(a5)
	pmove.l         tc,(a5)
	pmove           tc,(a5)
	prestore        (sp)+
	psave           -(sp)
	psbs.b          (a6)
	psbs            (a6)
	psls            (a6)
	psss            (a6)
	psas            (a6)
	psws            (a6)
	psis            (a6)
	psgs            (a6)
	pscs            (a6)
	psbc            (a6)
	pslc            (a6)
	pssc            (a6)
	psac            (a6)
	pswc            (a6)
	psic            (a6)
	psgc            (a6)
	pscc            (a6)
	ptestr          d0,(a2),5
	ptestr          d0,(a2),5,A1
	ptestw          d0,(a2),5
	ptestw          d0,(a2),5,A2
	ptrapbs
	ptrapbs.w               #immed
	ptrapbs.l               #immed
	ptrapls
	ptrapls.w               #immed
	ptrapls.l               #immed
	ptrapss
	ptrapss.w               #immed
	ptrapss.l               #immed
	ptrapas
	ptrapas.w               #immed
	ptrapas.l               #immed
	ptrapws
	ptrapws.w               #immed
	ptrapws.l               #immed
	ptrapis
	ptrapis.w               #immed
	ptrapis.l               #immed
	ptrapgs
	ptrapgs.w               #immed
	ptrapgs.l               #immed
	ptrapcs
	ptrapcs.w               #immed
	ptrapcs.l               #immed
	ptrapbc
	ptrapbc.w               #immed
	ptrapbc.l               #immed
	ptraplc
	ptraplc.w               #immed
	ptraplc.l               #immed
	ptrapsc
	ptrapsc.w               #immed
	ptrapsc.l               #immed
	ptrapac
	ptrapac.w               #immed
	ptrapac.l               #immed
	ptrapwc
	ptrapwc.w               #immed
	ptrapwc.l               #immed
	ptrapic
	ptrapic.w               #immed
	ptrapic.l               #immed
	ptrapgc
	ptrapgc.w               #immed
	ptrapgc.l               #immed
	ptrapcc
	ptrapcc.w               #immed
	ptrapcc.l               #immed
	pvalid.l        tc,(a2)
	pvalid          tc,(a2)
	pvalid.l        a3,(a2)
	pvalid          a4,(a2)
*
*       register tests
*
	pmove           tc,d0
	pmove           drp,(a0)
	pmove           srp,(a0)
	pmove           crp,(a0)
	pmove           cal,d0
	pmove           val,d0
	pmove           scc,d0
	pmove           bad0,d0
	pmove           bad1,d0
	pmove           bad2,d0
	pmove           bad3,d0
	pmove           bad4,d0
	pmove           bad5,d0
	pmove           bad6,d0
	pmove           bad7,d0
	pmove           bac0,d0
	pmove           bac1,d0
	pmove           bac2,d0
	pmove           bac3,d0
	pmove           bac4,d0
	pmove           bac5,d0
	pmove           bac6,d0
	pmove           bac7,d0
	pmove           psr,d0
	pmove           pcsr,d0


	pmove           d0,tc
	pmove           (a0),drp
	pmove           (a0),srp
	pmove           (a0),crp
	pmove           d0,cal
	pmove           d0,val
	pmove           d0,scc
	pmove           d0,bad0
	pmove           d0,bad1
	pmove           d0,bad2
	pmove           d0,bad3
	pmove           d0,bad4
	pmove           d0,bad5
	pmove           d0,bad6
	pmove           d0,bad7
	pmove           d0,bac0
	pmove           d0,bac1
	pmove           d0,bac2
	pmove           d0,bac3
	pmove           d0,bac4
	pmove           d0,bac5
	pmove           d0,bac6
	pmove           d0,bac7
*       pmove           d0,psr
*       pmove           d0,pcsr
	dc.b	1,2,3,4,5,6,7,8,9,0,1,2,3
	dc.b	1,2,3,4,5,6,7,8,9,0,1,2
	dc.b	1,2,3,4,5,6,7,8,9,0,1
	dc.b	1,2,3,4,5,6,7,8,9,0
	dc.b	1,2,3,4,5,6,7,8,9
	dc.b	1,2,3,4,5,6,7,8
	dc.b	1,2,3,4,5,6,7
	dc.b	1,2,3,4,5,6
	dc.b	1,2,3,4,5
	dc.b	1,2,3,4
	dc.b	1,2,3
	dc.b	1,2
	dc.b	1
*
	dc.w    1,2,3,4,5,6,7,8,9,0,1,2,3
	dc.w    1,2,3,4,5,6,7,8,9,0,1,2
	dc.w    1,2,3,4,5,6,7,8,9,0,1
	dc.w    1,2,3,4,5,6,7,8,9,0
	dc.w    1,2,3,4,5,6,7,8,9
	dc.w    1,2,3,4,5,6,7,8
	dc.w    1,2,3,4,5,6,7
	dc.w    1,2,3,4,5,6
	dc.w    1,2,3,4,5
	dc.w    1,2,3,4
	dc.w    1,2,3
	dc.w    1,2
	dc.w    1

	dc.l    1,2,3,4,5,6,7,8,9,0,1,2,3
	dc.l    1,2,3,4,5,6,7,8,9,0,1,2
	dc.l    1,2,3,4,5,6,7,8,9,0,1
	dc.l    1,2,3,4,5,6,7,8,9,0
	dc.l    1,2,3,4,5,6,7,8,9
	dc.l    1,2,3,4,5,6,7,8
	dc.l    1,2,3,4,5,6,7
	dc.l    1,2,3,4,5,6
	dc.l    1,2,3,4,5
	dc.l    1,2,3,4
	dc.l    1,2,3
	dc.l    1,2
	dc.l    1

	end
	nam
	name
	opt     nol             listing off
*
*       this shouldn't be listed
*
	opt     l               turn listing back on
	pag
	page
	spc
	ttl
	ds.b    5
	ds.w    5
	ds.l    5
	ds      5
fconst  fequ    $1321
	fopt

	org     $F
	dc.b    1
	org     $FF
	dc.b    1
	org     $FFF
	dc.b    1
	org     $FFFF
	dc.b    1
	org     $FFFFF
	dc.b    1
	org     $FFFFFF
	dc.b    1
	org     $FFFFFFF
	dc.b    1
	org     $FFFFFFFF
	dc.b    1

	dc.b    'string'
	dc.w    'string'
	dc.l    'string'
junk    equ     $12345678
*
*       68030 Pmove's to Transparent Translation registers
*
	pmove   junk,tt0
	pmove   junk,tt1
	pmove   tt0,junk
	pmove   tt1,junk
*
*	bug fix test for static field scanning
*
	pflush  d0{5}
	pflush  d0{5},(a0)
*
*	variations on pmove for 68030
*
	pmove   #3456,tc
	pmovefd #3456,tc	TLB flush disabled (68030 only)
*
*	generic co-processor support (1st expr. is always co-proc id)
*
	cpdbcc		7,d0,*
	cpbcc		6,44,*
	cpgen		5,$ffff,(a0)+
	cprestore	4,(sp)
	cpsave		3,-(sp)
	cpscc		2,63,(a0)
	cptrapcc	1,63
	cptrapcc.w	0,$10,#100
	cptrapcc.l	0,$15,#$12345678
