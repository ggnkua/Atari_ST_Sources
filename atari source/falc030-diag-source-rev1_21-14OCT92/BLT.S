	.extern Blt,ebltmsg,got_blt

*       Blitter test program
*	Apr 17, 92	Added variable Blt for expansion blitter test, TLE	
*       Dec 17, 87:     .prod conditional for manufac or field service
*       Dec 1, 87       don't turn green!
*       Nov 18, 87      added missing HOP function test.
*       OCT 16, 87      error codes changed to G_.
*       aug 29, 87      adapt for field service cart
*               beefed up RAM test, op test (and fix bug in op decode).
*       april 20, 1987  endmask, op, hop, fxsr, skew forward, reverse, smudge

lin_span equ    40              ;line span in words

b_halft equ     0               ;32 bytes RAM
b_snxwd equ     $20             ;byte offset to next word in line
b_swrap equ     $22             ;byte offset to 1st word in line
b_sadd  equ     $24
b_f1msk equ     $28
b_ctmsk equ     $2a
b_f2msk equ     $2c
b_dnxwd equ     $2e             ;byte offset to next word in line
b_dwrap equ     $30             ;byte offset to 1st word in line
b_dadd  equ     $32
b_dspan equ     $36             ;words in a dest. line
b_ht    equ     $38
b_hop   equ     $3a
hop0    equ     0               ;use all ones
hop1    equ     1               ;use halftone ram
hop2    equ     2               ;use source
hop3    equ     3               ;use source & halftone
b_op    equ     $3b
b_line  equ     $3c     ;7=busy, 6=hog, 5=smudge, 3-0=line number
b_skew  equ     $3d     ;7=fxsr, 6=nfsr, 3-0=skew

;dram    equ     $90000
;sram    equ     $80000
dram     equ     $70000
sram     equ     $60000
	.text

*       test in order:
*       1. source and destination ram
*       2. halftone ram
*       3. endmask (use all 0 op)
*       4. op (use source, no halftone)
*       5. hop (op is source only): test all 1's, all halftone, src & ht
*       6. skew
*       7  smudge

blttst: move.l  #blt,Blt	;added for expansion blitter, TLE
	
testblt:
	clr.b   erflg0
	clr.b   erflg1
	lea     bltmsg,a5
	bsr     dsptst
	bsr     isblt
	beq     got_blt
	move    #red,palette
	lea     no_blt,a5
	bsr     dspmsg
	rts

*       test halftone RAM
*       write target with $01; write all others with 0 and f, verify target,
*       repeat, writing left shifted data to target, until 16 patterns done
*       repeat with next target
got_blt:
;        lea     blt,a0
	move.l   Blt,a0
tstht:  moveq   #0,d0           ;starting pattern for target
ht256:  move    d0,(a0)         ;write target 
	move    #$ffff,d1       ;surround pattern
	moveq   #0,d2
*       fill background
; filht0: lea     blt,a1
filht0: move.l    Blt,a1
	moveq   #15,d7          ;# of cells
filht1: 
;	cmpa    a0,a1
	cmpa.l  a0,a1
	beq     filht2
	move    d2,(a1)
	move    d1,(a1)         ;write all others
filht2: adda    #2,a1
	dbra    d7,filht1
*       verify target
	cmp     (a0),d0         ;check target
	bne     htrf

	add     #$101,d0
	cmp     #$100,d0
	bne     ht256           ;256 combinations

	adda    #2,a0           ;next target
;        cmpa.l  #blt+32,a0

	move.l  Blt,a1
	add.l   #32,a1
	cmpa.l  a1,a0

	beq     blt_init
	bne     tstht

htrf:   bset    #0,erflg0
	bra     blt_end
	
*       set up parameters for display memory (blt register values)
blt_init:
;        lea     blt,a6
	move.l  Blt,a6
	moveq   #2,d1
	bsr     blt_inc         ;set up blt increment registers
	move.b  v_shf_mod,d0
	andi    #3,d0
	lsl     d0
	move    #400,n_lines    ; # of lines
	move    #lin_span,dspan
	move    #0,b_line(a6)   ;init control word (skew and line number)

*       endmask test
*       using all 1's (op=0), mask off 1 bit at a time and check result

em_tst: move.b  #$f,b_op(a6)    ;op=all ones
	moveq   #1,d0
	move    d0,b_f1msk(a6)  ;mask
	move    d0,b_ctmsk(a6)
	move    d0,b_f2msk(a6)
em_rpt: moveq   #0,d0
	lea     dram,a0
	move    dspan,d1
	bsr     bfill           ;fill destination with 0's
	move    #1,b_ht(a6)     ;no. of lines
	bsr     blast
	move    b_ctmsk(a6),d0
	move    dspan,d1
	lea     dram,a0
	bsr     bcmpbk  
	beq     em_shf
	bset    #1,erflg0
	bra     blt_end
em_shf: lsl     b_f1msk(a6)
	lsl     b_ctmsk(a6)
	lsl     b_f2msk(a6)
	bcc     em_rpt          ;until 16 bits tested

*       test op (halftone must work too--set to use source only)
*       using patterns aaaa and 5555 do:
*       for 16 operations:
*               fill source and dest
*               perform blt (one line)
*               perform logical op on source and dest patterns
*               compare dest with resulting pattern
*       repeat using complemented patterns
*       repeat using s=0, d=1's
*       repeat using s=1's, d=1's

op_tst: move.b  #hop2,b_hop(a6) ;use all source, no halftone
	move    #$ffff,d0
	move    d0,b_f1msk(a6)  ;mask=all bits changed
	move    d0,b_ctmsk(a6)
	move    d0,b_f2msk(a6)
	move    #$aaaa,spatt    ;s = aaaa
	move    #$5555,dpatt    ;d = 5555
	bsr     tst_op16
	not     dpatt           ;s = 5555
	not     spatt           ;d = aaaa
	bsr     tst_op16
	clr     spatt           ;s = 0000
	move    #$ffff,dpatt    ;d = ffff
	bsr     tst_op16
	not     spatt           ;s=ffff
	not     dpatt           ;d=0000
	bsr     tst_op16
	not     spatt           ;s = 0000 ; d = 0000
	bsr     tst_op16
	move    #$ffff,spatt    ;s = ffff
	move    #$ffff,dpatt    ;d = ffff
	bsr     tst_op16        ;
	tst.b   erflg0
	bne     blt_end

*       test hop
*       0. source only is previously tested (op test)
*       1. test all ones
*       2. test all halftone
*       3. test source & halftone

*       test all ones
tst_hop:
	move    #0,b_line(a6)   ;clear control word
	move.b  #3,b_op(a6)     ;op uses source only
	moveq   #0,d0
	moveq   #16,d1
;        lea     b_halft+blt,a0
	move.l  Blt,a0
	bsr     bfill           ;fill halftone
	lea     sram,a0
	move    dspan,d1        ;line
	lsl     #4,d1           ;x16
	bsr     bfill           ;fill source
	lea     dram,a0
	bsr     bfill           ;fill dest
	move.b  #hop0,b_hop(a6) ;all ones
	move    #1,b_ht(a6)     ;no. of lines
*
	bsr     blast           ;blast 1 line

	moveq   #$ff,d0
	lea     dram,a0
	move    dspan,d1        ;# of words
	bsr     bcmpbk
	beq     tstht1
	bset    #3,erflg0
	bra     blt_end

*       test using halftone data only
tstht1: moveq   #1,d0
;        lea     b_halft+blt,a0
	move.l  Blt,a0
	move.b  #hop1,b_hop(a6) ;use halftone ram
flht1:  move    d0,(a0)+        ;write halftone pattern
	lsl     d0              ;walk 1 across 16 bits
	bcc     flht1           ;16 words of halftone
	move    n_lines,b_ht(a6)        ;# of lines = full screen
*
	move    #0,b_line(a6)   ;clear control word
	bsr     blast           ;blast 32k bytes

	lea     dram,a0
cmpht0: moveq   #1,d0           ;data repeated for 1 line
cmpht1: move    dspan,d1        ;get line size
	subq    #1,d1
cmpht:  cmp     (a0)+,d0
	beq     ht_ok
	bset    #3,erflg0
	bra     tst_sk          ;go to skew test
ht_ok:  dbra    d1,cmpht        ;until end of line
	lsl     d0              ;new data for next line
	bcc     cmpht1          ;until 16 lines
	cmpa.l  #dram+$7d00,a0
	bne     cmpht0          ;until end of screen

*       test halftone AND source
	move.b  #hop3,b_hop(a6) ;HOP = ht & src
	move    #$aaaa,d0
;        lea     b_halft+blt,a0
	move.l  Blt,a0
	moveq   #16,d1
	bsr     bfill           ;fill halftone = aaaa
	move    #$5555,d0
	lea     sram,a0
	move    #lin_span,d1
	bsr     bfill           ;fill source = 5555
	move    #$ffff,d0
	move    #lin_span,d1
	lea     dram,a0
	bsr     bfill           ;fill dest = ffff
	move    #1,b_ht(a6)
	bsr     blast           ;blast a line
	moveq   #0,d0
	lea     dram,a0
	moveq   #lin_span-1,d1
cmphp3: cmp     (a0)+,d0        ; 5555 & aaaa = 0000
	beq     tsthp3
	bset    #3,erflg0
tsthp3: dbra    d1,cmphp3

*--------------------------------

*       skew test
*       blt from word aligned source to non-aligned dest

tst_sk: move.b  #3,b_op(a6)     ;op=source
	move.b  #hop2,b_hop(a6) ;hop=source
	move    #$0001,b_f1msk(a6)      
	move    #$ffff,b_ctmsk(a6)
	move    #$fffe,b_f2msk(a6)

*       shift 15 bits to the right, blt from left to right
*       also test nfsr 
*       s = aaaa,...    d = 1555,5555,...,5554
	moveq   #0,d0
	lea     dram,a0
	move    dspan,d1        
	bsr     bfill           ;fill destination with 0's
	move    #$aaaa,d0
	lea     sram,a0
	bsr     bfill           ;fill source with 1's
	move.b  #$4f,b_skew(a6) ;flush (write w/o read)
	add     #1,dspan        ;extra write
	move    #1,b_ht(a6)     ;no. of lines
	bsr     blast           ;blast away
	bsr     sk_cmp          ;and verify
	beq     ht_gd
	bset    #4,erflg0
ht_gd:

*       force extra source read
*       s = 1234,1234,1234,1234,5555
*       d =    4123,4123,4123,4555
fxsr:   lea     sram,a0         ;fill source
	move    #$1234,d0
	moveq   #3,d7   
fxsr0:  move    d0,(a0)+        ;4 words of 1234
	dbra    d7,fxsr0
	move    #$5555,(a0)     ;end word
	move.b  #$84,b_skew(a6) ;fxsr, nfsr and shift 4
	move    #1,b_ht(a6)     ;1 line
	move    #4,dspan        ;line length
	lea     dram,a0
	move    #$10,d1
	moveq   #0,d0
	bsr     bfill           ;clear dest
	move    #$ffff,b_f1msk(a6)      
	move    #$ffff,b_ctmsk(a6)
	move    #$ffff,b_f2msk(a6)
	bsr     blast           ;blast out a line
	lea     dram,a0         ;check result
	moveq   #$2,d7
fxsr1:  cmpi    #$4123,(a0)+    ;check 3 words
	bne     fxsrf
	dbra    d7,fxsr1
	cmpi    #$4555,(a0)+    ;check last word
	beq     sk2
fxsrf:  bset    #5,erflg0

*       blt from right to left
*       s = aaaa,aaaa,...       d = 1555,5555,...,5554
sk2:    move    #-2,d1
	bsr     blt_inc         ; write inc reg
	move    #$fffe,b_f1msk(a6)      
	move    #$ffff,b_ctmsk(a6)
	move    #$0001,b_f2msk(a6)
	move    #$aaaa,d0
	move    #80,d1
	lea     sram,a0
	bsr     bfillr          ;fill source
	moveq   #0,d0
	lea     dram,a0
	add     #$10,d1
	bsr     bfillr          ;fill destination with 0's
	move    #2,b_ht(a6)     ;no. of lines
	move.b  #$4f,b_skew(a6)
	bsr     blast           ;blast out data
	bsr     skr_cmp
	beq     smudg
	bset    #6,erflg0

*       smudge: least significant 4 bits of source indexes halftone
smudg:  lea     b_halft(a6),a0
	moveq   #2,d1
	bsr     blt_inc
	moveq   #0,d0
smudg0: move    d0,(a0)+        ;fill halftone with 0,1111,2222,...,ffff
	add     #$1111,d0
	cmpi    #$1110,d0
	bne     smudg0
	lea     sram,a0
	moveq   #0,d0
smudg1: move    d0,(a0)+        ;fill source with 16 bytes: 0,1,2,...,f
	addq    #1,d0
	cmpi    #16,d0
	bne     smudg1
	lea     dram,a0
	move    #$20,d1
	moveq   #0,d0
	bsr     bfill
	move.b  #1,b_hop(a6)    ;use halftone only
	move.b  #3,b_op(a6)     ;use source only
	move.b  #0,b_skew(a6)
	move.b  #$20,b_line(a6) ;set smudge bit
	move    #$ffff,b_f1msk(a6)      
	move    #$ffff,b_ctmsk(a6)
	move    #$ffff,b_f2msk(a6)
	move    #16,dspan
	move    #1,b_ht(a6)     ;one line
	bsr     blast
	lea     dram,a0         ;check result
	moveq   #0,d0
smudg2: cmp     (a0)+,d0
	bne     smudgf
	add     #$1111,d0
	cmpi    #$1110,d0
	bne     smudg2
	bra     tst_x

smudgf: bset    #7,erflg0

*       test x,y counters
*       blt 2 lines of 2 words, words are 16kb apart, lines are 2 bytes apart

tst_x:  move.b  #3,b_op(a6)     ;use source only
	move.b  #hop2,b_hop(a6) ;use all source, no halftone
	move    #$ffff,d0
	move    d0,b_f1msk(a6)  ;mask=all bits changed
	move    d0,b_ctmsk(a6)
	move    d0,b_f2msk(a6)
	move    #$3ffe,b_snxwd(a6) ;next word +16k
	move    #$3ffe,b_dnxwd(a6)
	move    #2,b_swrap(a6)  ;next line +2
	move    #2,b_dwrap(a6)
	move    #2,b_ht(a6)     ;2 lines
	move    #2,dspan        ;2 words/line
	move    #$aaaa,d0       ;source pattern
	lea     sram,a0
	move    d0,(a0)         ;first word
	move    d0,$3ffe(a0)    ;next word
	move    d0,$4000(a0)    ;next line
	move    d0,$7ffe(a0)    ;next word
	lea     dram,a0
	moveq   #0,d0           ;clear dest
	move    d0,(a0)         ;first word
	move    d0,$3ffe(a0)    ;next word
	move    d0,$4000(a0)    ;next line
	move    d0,$7ffe(a0)    ;next word
*
	bsr     blast           ;blast 

	lea     dram,a0
	move    #$aaaa,d0
	cmp     (a0),d0
	bne     x_fail
	cmp     $3ffe(a0),d0
	bne     x_fail
	cmp     $4000(a0),d0
	bne     x_fail
	cmp     $7ffe(a0),d0
	beq     tst_y
x_fail: bset    #0,erflg1

*       blt 2 lines of 2 words, words are 2 bytes apart, lines are 16kb apart
tst_y:  move    #$3ffe,b_swrap(a6) ;next line +16k
	move    #$3ffe,b_dwrap(a6)
	move    #2,b_snxwd(a6)  ;next word +2
	move    #2,b_dnxwd(a6)
	move    #2,b_ht(a6)     ;2 lines
	move    #2,dspan        ;2 words/line
	move    #$aaaa,d0       ;source pattern
	lea     sram,a0
	move    d0,(a0)         ;first word
	move    d0,$2(a0)       ;next word
	move    d0,$4000(a0)    ;next line
	move    d0,$4002(a0)    ;next word
	lea     dram,a0
	moveq   #0,d0           ;clear dest
	move    d0,(a0)         ;first word
	move    d0,$2(a0)       ;next word
	move    d0,$4000(a0)    ;next line
	move    d0,$4002(a0)    ;next word
*
	bsr     blast           ;blast 

	lea     dram,a0
	move    #$aaaa,d0
	cmp     (a0),d0
	bne     y_fail
	cmp     $2(a0),d0
	bne     y_fail
	cmp     $4000(a0),d0
	bne     y_fail
	cmp     $4002(a0),d0
	beq     blt_end
y_fail: bset    #1,erflg1

blt_end:
	move.b  erflg1,d3
	lsl     #8,d3
	move.b  erflg0,d3
	moveq   #0,d1           ;bit ptr
	moveq   #0,d2
	lea     bmsgtb(pc),a0   ;message ptr
blte0:  btst    d1,d3           ;test error bit
	beq     blte1
	move.l  0(a0,d2),a5     ;print message if set
	bsr     dspmsg
blte1:  add.l   #4,d2           ;add to message ptr index
	addq    #1,d1           ;bump bit ptr
	cmp.l   #bmsgte,d2
	blt     blte0

*       print pass/fail and go home
	move.b  erflg0,d0
	or.b    erflg1,d0
	beq     bltpas
bad_blt:
	move    #red,palette
	lea     falmsg,a5
	bra     blt_ex

;;        .if prod
;bltpas: 
;        lea     pasmsg,a5
;        move    #green,palette  ;if manufact. test, turn screen green
;blt_ex: bsr     dspmsg          ;and display at current position
;;        .else
bltpas:
	lea     pasmsg,a5
blt_ex:
	move.b	#t_SBLIT,d0
	bsr     dsppf           ;if field service, don't change color,
;;        .endif                  ;display at top
	rts

bmsgtb: dc.l    htrfm           ;erflg0
	dc.l    em_flm
	dc.l    op_fail
	dc.l    ht_fail
	dc.l    sk_fail
	dc.l    fx_fail
	dc.l    sk2_fail
	dc.l    smg_fail
	dc.l    xf_msg          ;erflg1
	dc.l    yf_msg
	dc.l    b_to
	dc.l    b_addcnt
bmsgte  equ     *-bmsgtb

*-------------------------------
*       test 16 ops
*       entry:  spatt = source pattern
*               dpatt = destination pattern
*       exit:   erflg0 bit 2 set if error
tst_op16:
	moveq   #0,d0           ;init op 
*       blt 16 ops
tst_op: move.b  d0,b_op(a6)
	move    spatt,d0
	move    dspan,d1
	lea     sram,a0
	bsr     bfill           ;fill source
	move    dpatt,d0
	lea     dram,a0
	bsr     bfill           ;fill dest
	move    #1,b_ht(a6)     ;1 line

	bsr     blast           ;blast 1 line

	bsr     op_decod        ;generate dest pattern in d0
	lea     dram,a0
	move    dspan,d1        ;no. of lines
	bsr     bcmpbk          ;compare pattern to memory
	beq     nxt_op
	bset    #2,erflg0

nxt_op: move.b  b_op(a6),d0
	addq    #1,d0
	cmpi.b  #16,d0
	bne     tst_op
	rts

*--------------------------------
*       let 'er rip
*       exit:   ne if error, erflg1 bits 2 or 3 set
blast:  move.l  #dram,b_dadd(a6) ;re-init values changed by blaster
	move.l  #sram,b_sadd(a6)
	move    dspan,b_dspan(a6)
	bset    #7,b_line(a6)
	move.l  #$100000,d7
wt_blt: btst    #7,b_line(a6)
	beq     blt_don
	subq    #1,d7
	bne     wt_blt
	bset    #2,erflg1
	andi    #$1f,ccr
blt_don:
	rts

*-------------------------------
*       init blt inc registers
*       d1 = init value
blt_inc:
	move    d1,b_snxwd(a6)  ; inc to next word, same line
	move    d1,b_dnxwd(a6)
	move    d1,b_swrap(a6)  ; inc to first word, next line
	move    d1,b_dwrap(a6)
	rts

*----------------------------------
*       generate dest pattern using source, dest, and op
*       s op d = d
*       exit:   d0.w=pattern
*       uses:   d0-d2,a0-a1
op_decod:
	clr.l   d2
	move.b  b_op(a6),d2
	lsl     #2,d2           ;shift for long table
	move    spatt,d0
	move    dpatt,d1
	lea     op_tbl,a0
	move.l  0(a0,d2),a1     ;get jump address
	jmp     (a1)            ;go to op routine

op_tbl: dc.l    op0,op1,op2,op3,op4,op5,op6,op7
	dc.l    op8,op9,op10,op11,op12,op13,op14,op15

*       logical operations. d0=s, d1=d
op0:    moveq   #0,d0
	rts
op1:    and     d1,d0
	rts
op2:    not     d1
	and     d1,d0
	rts
op3:    rts
op4:    not     d0
	and     d1,d0
	rts
op5:    move    d1,d0
	rts
op6:    eor     d1,d0
	rts
op7:    or      d1,d0
	rts
op8:    not     d0
	not     d1
	and     d1,d0
	rts
op9:    not     d0
	eor     d1,d0
	rts
op10:   not     d1
	move    d1,d0
	rts
op11:   not     d1
	or      d1,d0
	rts
op12:   not     d0
	rts
op13:   not     d0
	or      d1,d0
	rts
op14:   not     d0
	not     d1
	or      d1,d0
	rts
op15:   moveq   #$ff,d0
	rts
	
*----------------------------------
*       Compare block to pattern
*       a0 = block
*       d0.w = pattern
*       d1.w = size (words)
*       exit:   eq if equal
bcmpbk: subq    #1,d1
bcmpb0: cmp.w   (a0)+,d0
	bne     bcmpb1
	dbra    d1,bcmpb0
	rts
bcmpb1: subq    #2,a0           ;return failed location
	rts

*--------------------------------
*       compare skew test
*       compare dest data to masks
*       exit:   eq if pass
sk_cmp: lea     dram,a0         ;start address
	move    dspan,d7
	subq    #3,d7           ;number of words in middle
	cmpi    #1,(a0)+        ;1st word skewed 15 bits
	bne     sk_out
sk_cm1: cmpi    #$5555,(a0)+
	bne     sk_out
	dbra    d7,sk_cm1
	cmpi    #$5554,(a0)+    ;last word skewed 15 bits
sk_out: rts


*--------------------------------
*       compare skew reverse
*       compare dest data to masks
*       exit:   eq if pass
skr_cmp:
	lea     dram,a0         ;start address
	adda.l  #2,a0           ;set for pre-dec
	move    dspan,d7
	subq    #3,d7           ;number of words in middle
	cmpi    #$5554,-(a0)    ;last word skewed 15 bits right
	bne     skr_out
skr_cm1:
	cmpi    #$5555,-(a0)
	bne     skr_out
	dbra    d7,skr_cm1
	cmpi    #1,-(a0)        ;1st word skewed 15 bits
skr_out: rts
	        
*----------------------------------
*       Fill a block with a word
*       d0.w = data
*       d1.w = size (words)
*       a0 = start
*       exit:   registers preserved
bfill:  movem.l d1/a0,-(sp)
	subq    #1,d1
bfill0: move.w  d0,(a0)+
	dbra    d1,bfill0
	movem.l (sp)+,d1/a0
	rts

*----------------------------------
*       Fill a block with a word, decrement
*       d0.w = data
*       d1.w = size (words)
*       a0 = start
*       exit:   registers preserved
bfillr: movem.l d1/a0,-(sp)
	subq    #1,d1
	adda.l  #2,a0
bfilr0: move.w  d0,-(a0)
	dbra    d1,bfilr0
	movem.l (sp)+,d1/a0
	rts

*-------------------------------
*       test for blitter
*       exit:   eq if present
*               sets bitflg in mega status byte
isblt:  ori.b   #bltflg,mega    ;assume blt
	move.l  8,a4            ;save bus error vector
	lea     bltbe(pc),a0    ;replace it
	move.l  a0,8
	clr     d7              ;flag bus error occurence
;        move.b  blt,d0          ;access chip, if bus error, not installed
	
	move.l  Blt,a0
	move.b  (a0),d0          ;access chip, if bus error, not installed

	nop
	move.l  a4,8            ;restore vector
	tst     d7
	beq     blt_is          ;br if we have blt
	andi.b  #_bltflg,mega
	andi.b  #$fb,ccr
blt_is: rts

*       bus error handler
bltbe:  move    #$ff,d7         ;set flag if bus error
	add     #8,sp
	rte

	.data
bltmsg: dc.b    'Testing Blitter',cr,lf,eot
ebltmsg: dc.b   'Testing Expansion Blitter ',cr,lf,eot
htrfm:  dc.b    'G1 halftone RAM',cr,lf,eot
em_flm: dc.b    'G2 endmask',cr,lf,eot
op_fail: dc.b   'G3 operation ',cr,lf,eot
ht_fail: dc.b   'G4 halftone op',cr,lf,eot
sk_fail: dc.b   'G5 skew',cr,lf,eot
sk2_fail: dc.b  'G6 reverse blt',cr,lf,eot
fx_fail: dc.b   'G7 force extra source read',cr,lf,eot
smg_fail: dc.b  'G8 smudge',cr,lf,eot
xf_msg: dc.b    'G9 x count',cr,lf,eot
yf_msg: dc.b    'G10 y count',cr,lf,eot
b_to:   dc.b    'G11 time-out',cr,lf,eot
b_addcnt: dc.b  'G12 address count',cr,lf,eot
no_blt: dc.b    'No Blitter installed',cr,lf,eot
