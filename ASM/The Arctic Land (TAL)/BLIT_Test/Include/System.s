; Sub routines to save an restore the system
; The Arctic Land (T.AL) 2019
; (from init030.s done by zpk of T.AL in 1994, and found back in a Faucontact mag !)
; Contact: uko.tal@gmail.com or uko at http://www.atari-forum.com

	TEXT
	
	; This file must be included at the top of the main code
	; but also contains code... so we directly go to the main code !
	bra main
	
; -----------------------------------------------------------------------------
; Macros
; -----------------------------------------------------------------------------	
; Save Timers
; \1 Control register
; \2 Save Control register
; \3 Data register
; \4 Save Data register
; \5 Shift for control registers of Timers C & D
save_timer	macro
	move.b \1,d0	; Control register
	move.b d0,\2
	
	ifeq NARG-5	; Timer C or D
	ifne \5
	lsr.b #\5,d0	; Timer D
	endif
	andi.b #7,d0	; Timer C or D
	endif
	
	beq.s .next\@	; Timer stopped
	
	ifeq NARG-4	; Timer A or B
	cmpi.b #8,d0	; Event count ?
	bne.s .wtimer_i\@	; No, get data register
	
	move.b \3,d0	; Data register
	bra.s .next\@
	endif
	
	; Wait until count reaches 1
.wtimer_i\@	move.l #1000,d1	; SainT block here, so we allow looping only a limited time
.wtimer\@	subq.l #1,d1
	beq.s .next\@
	move.b \3,d0
	cmpi.b #1,d0	; End of cycle ?
	bne.s .wtimer\@
	
	; Wait until count is no longer 1, so the max value !
	; Unless max value = 1, so we loop a while
	; With Ctrl = 7 (i.e div by 200), a value of 1 corresponds to 164 NOPs
	; So waiting 20 loops is enough here (too lazy to count cycles !)  
	move.l #20,d1
.rtimer\@	subq.l #1,d1
	beq.s .next\@
	move.b \3,d0
	cmpi.b #1,d0
	beq.s .rtimer\@
	
.next\@	move.b d0,\4	; Save timer counter
	endm


; Wait for sytem VBL
wait_sys	macro
	move.w sr,-(sp)
	andi.w #$fbff,sr
wait_sys\@	move.l HW_SYS_FRCLOCK.w,d0
	cmp.l HW_SYS_FRCLOCK.w,d0
	beq.s wait_sys\@
	move.w (sp)+,sr
	endm

; Clear keyboard buffer
clear_key	macro
	move.l d0,-(sp)
.start\@	btst #0,HW_ACIA_KBD_CTL.w
	beq.s .nomorekey\@
	move.b HW_ACIA_KBD_DAT.w,d0
	bra.s .start\@
.nomorekey\@	move.l (sp)+,d0
	endm

; Enable a timer
; \1 Timer Name "A", "B", "C" or "D"
; \2 Routine for vector
; Stop timer, set masks & vector
timer_enable	macro
	timer_stop \1
	ifc \1,"B"
	or.b #%00000001,(HW_MFP_ADR+$7).w
	or.b #%00000001,(HW_MFP_ADR+$13).w
	move.l #\2,HW_SYS_TIMB_VEC.w
	endif
	ifc \1,"A"
	or.b #%00100000,(HW_MFP_ADR+$7).w
	or.b #%00100000,(HW_MFP_ADR+$13).w
	move.l #\2,HW_SYS_TIMA_VEC.w
	endif
	endm

; Start a timer
; \1 Timer Name "A", "B", "C" or "D"
; \2 Control
; \3 Data
timer_start	macro
	ifc \1,"B"
	move.b #\3,(HW_MFP_ADR+$21).w
	move.b #\2,(HW_MFP_ADR+$1B).w
	endif
	ifc \1,"A"
	move.b #\3,(HW_MFP_ADR+$1F).w
	move.b #\2,(HW_MFP_ADR+$19).w
	endif
	endm	

; Stop a timer
; \1 Timer Name "A", "B", "C" or "D"
timer_stop	macro
	ifc \1,"B"
	move.b #0,(HW_MFP_ADR+$1B).w
	endif
	ifc \1,"A"
	move.b #0,(HW_MFP_ADR+$19).w
	endif
	endm	

; Notify the end of service of a timer
; \1 Timer Name "A", "B", "C" or "D"
timer_eos	macro
	ifc \1,"B"
	bclr #0,(HW_MFP_ADR+$F).w
	endif
	ifc \1,"A"
	bclr #5,(HW_MFP_ADR+$F).w
	endif
	endm	

; Set the palette
; \1 Palette address
set_palette	macro
	move.l \1,a0
	lea HW_ST_PAL_ADR.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	endm

; Test and set the palette, then clear the pointer
; \1 Palette address pointer
tset_palette	macro
	move.l \1,d0
	beq.s .noPalette
	set_palette d0
.noPalette	move.l #0,\1
	endm


; Swap two pointer contents
; \1 and \2 Pointers to exchange
swapPointers	macro
	move.l \1,-(sp)
	move.l \2,\1
	move.l (sp)+,\2
	endm

; Manage double buffering
; \1 PhysBase
; \2 LogBase
doubleBuffer	macro
	swapPointers \1,\2
	lea \1,a0
	addq.l #1,a0
	lea HW_SHIFTER_ADR.w,a1
	move.b (a0)+,$1(a1)
	move.b (a0)+,$3(a1)
	move.b (a0)+,$D(a1)
	endm
; Insert as many NOP as required
; \1 = Number of NOPs
nops	macro
	REPT \1
	nop
	ENDR
	endm

; Synchronise with VBL
; Useful before changing a VBL vector for example
syncVBL	macro
	move.l #vec_null,HW_SYS_VBL_VEC.w
	move.w #$2300,sr
	stop #$2300
	stop #$2300
	move.w #$2700,sr
	endm

; Convert a register value into text
; \1 Data register (not d6/d7)
; \2 Text buffer address
dxToText	macro
	movem.l d6-d7/a0,-(sp)
	moveq #7,d7
	lea \2,a0
	lea 8(a0),a0	; to the end
.loop\@	move.b \1,d6
	and.b #$F,d6
	cmp.b #9,d6
	bgt.s .letter\@
	add.b #48,d6	; ASCII for 0
	bra.s .endConv\@
.letter\@	add.b #55,d6	; ASCII for 7, because 65 is ASCII for A
.endConv\@	move.b d6,-(a0)
	lsr.l #4,\1
	dbf d7,.loop\@
	movem.l (sp)+,d6-d7/a0
	endm
	
; -----------------------------------------------------------------------------
; Save sytem sub routine
; -----------------------------------------------------------------------------	
save_system:	
	movem.l d0-a6,-(sp)
	
	; First SR
	move.w sr,sav_sr
	
	; Traps TBD
	
	; ST Palette
	lea HW_ST_PAL_ADR,a0
	lea sav_st_palette,a1
	move.w #15,d0
.savstpal	move.w (a0)+,(a1)+
	dbf d0,.savstpal
	
	; Screen configuration
.savscreen	move.w #XBIOS_PHYSBASE,-(sp)
	trap #14
	addq.w #2,sp
	move.l d0,sav_physbase

	move.w #XBIOS_LOGBASE,-(sp)
	trap #14
	addq.w #2,sp
	move.l d0,sav_logbase

	move.w #XBIOS_GETREZ,-(sp)
	trap #14
	addq.w #2,sp
	move.w d0,sav_getrez
	
	; Stop interrupts
	move.w #$2700,sr
	
	; Save vectors
.savvectors	lea sav_vectors,a0
	move.l HW_SYS_HBL_VEC.w,(a0)+
	move.l HW_SYS_VBL_VEC.w,(a0)+
	move.l HW_SYS_BERR_VEC.w,(a0)+
	move.l HW_SYS_TIMA_VEC.w,(a0)+
	move.l HW_SYS_TIMB_VEC.w,(a0)+
	move.l HW_SYS_TIMC_VEC.w,(a0)+
	move.l HW_SYS_TIMD_VEC.w,(a0)+
	
	; Save MFP
.savmfp	lea HW_MFP_ADR.w,a0
	lea sav_mfp,a1
	move.b 7(a0),(a1)+	; IERA
	move.b 9(a0),(a1)+	; IERB
	move.b $b(a0),(a1)+
	move.b $d(a0),(a1)+
	move.b $f(a0),(a1)+
	move.b $11(a0),(a1)+
	move.b $13(a0),(a1)+
	move.b $15(a0),(a1)+
	move.b $17(a0),(a1)+
	
	save_timer $19(a0),(a1)+,$1f(a0),(a1)+	; Timer A
	save_timer $1b(a0),(a1)+,$21(a0),(a1)+	; Timer B
	save_timer $1d(a0),(a1)+,$23(a0),(a1)+,4	; Timer C
	save_timer $1d(a0),(a1)+,$25(a0),(a1)+,0	; Timer D
	
	movem.l (sp)+,d0-a6
	rts
	
; -----------------------------------------------------------------------------
; Restore sytem sub routine
; -----------------------------------------------------------------------------	
restore_system:
	movem.l d0-a6,-(sp)

	clear_key

	move.w #$2700,sr

	; STE DMA Sound system
	lea HW_SND_ADR.w,a0
	move.b #0,HW_SND_ENABLE_O(a0)	; Stop Sound	

	; Restore MFP
.resmfp	lea HW_MFP_ADR.w,a0
	lea sav_mfp,a1
	move.b (a1)+,7(a0)	; IERA
	move.b (a1)+,9(a0)	; IERB
	move.b (a1)+,$b(a0)
	move.b (a1)+,$d(a0)
	move.b (a1)+,$f(a0)
	move.b (a1)+,$11(a0)
	move.b (a1)+,$13(a0)
	move.b (a1)+,$15(a0)
	move.b (a1)+,$17(a0)

	move.b (a1)+,$19(a0)	; Timer Control & Data
	move.b (a1)+,$1f(a0)
	move.b (a1)+,$1b(a0)
	move.b (a1)+,$21(a0)
	move.b (a1)+,$1d(a0)
	move.b (a1)+,$23(a0)
	move.b (a1)+,$1d(a0)
	move.b (a1)+,$25(a0)
	
	; Restore vectors
.resvectors	lea sav_vectors,a0
	move.l (a0)+,HW_SYS_HBL_VEC.w
	move.l (a0)+,HW_SYS_VBL_VEC.w
	move.l (a0)+,HW_SYS_BERR_VEC.w
	move.l (a0)+,HW_SYS_TIMA_VEC.w
	move.l (a0)+,HW_SYS_TIMB_VEC.w
	move.l (a0)+,HW_SYS_TIMC_VEC.w
	move.l (a0)+,HW_SYS_TIMD_VEC.w
	
	; Before XBIOS calls , back to ipl 3 and wait VBL
	move.w #$2300,sr
	wait_sys
	
	; Screen configuration
.resscreen	move.w sav_getrez,-(sp)
	move.l sav_physbase,-(sp)
	move.l sav_logbase,-(sp)
	move.w #XBIOS_SETSCREEN,-(sp)
	trap #14
	add.w #12,sp
	
	; ST Palette
	lea HW_ST_PAL_ADR,a0
	lea sav_st_palette,a1
	move.w #15,d0
.resstpal	move.w (a1)+,(a0)+
	dbf d0,.resstpal	
	
	; Traps TBD
	
	move.w sav_sr,sr
	
	movem.l (sp)+,d0-a6
	rts

; -----------------------------------------------------------------------------
; Wait Space Key
; -----------------------------------------------------------------------------
wait_space:	cmp.b #$39,HW_ACIA_KBD_DAT.w
	bne.s wait_space
.clear	clear_key
	cmp.b #$39,HW_ACIA_KBD_DAT.w
	beq.s .clear
	rts

; -----------------------------------------------------------------------------
; Init sytem sub routine
; -----------------------------------------------------------------------------	
init_system:
	movem.l d0-a6,-(sp)

	; Restore on bus error
	move.l #ex_restore,HW_SYS_BERR_VEC.w

	; Clear MFP interrupts
.stopMFP	lea HW_MFP_ADR.w,a0
	clr.b 7(a0)
	clr.b 9(a0)
	clr.b $b(a0)
	clr.b $d(a0)
	clr.b $f(a0)
	clr.b $11(a0)
	clr.b $13(a0)
	clr.b $15(a0)
	bclr #3,$17(a0)
	
	; No handler for exceptions
	; We do not touch yet VBL, because it will be necessary for XBIOS
	move.l #vec_null,HW_SYS_HBL_VEC.w
	move.l #vec_null,HW_SYS_TIMA_VEC.w
	move.l #vec_null,HW_SYS_TIMB_VEC.w
	move.l #vec_null,HW_SYS_TIMC_VEC.w
	move.l #vec_null,HW_SYS_TIMD_VEC.w
	
	movem.l (sp)+,d0-a6
	rts

init_system_cont:
	; 50 Hz
	or.b #2,(HW_SHIFTER_ADR+$A).w
	move.l #vec_null,HW_SYS_VBL_VEC.w
	rts
	
; -----------------------------------------------------------------------------
; Exception handling
; -----------------------------------------------------------------------------	
ex_restore:	bsr restore_system

	pea ex_restore_msg
	move.w #GEMDOS_CCONWS,-(sp)
	trap #1
	addq.l #6,sp
	
	bsr wait_space
	
	clr.w -(sp)
	trap #1

; -----------------------------------------------------------------------------
; Check system version
; Partly taken from:
; http://leonard.oxg.free.fr/articles/multi_atari/multi_atari.html
; -----------------------------------------------------------------------------	
assertSTE:
	movem.l d0-a6,-(sp)
	move.l $5a0.w,d0	; Cookie Jar
	beq .noCookie
	move.l d0,a0
	
.loop	move.l (a0)+,d0
	beq .noCookie
	cmp.l #'_MCH',d0
	beq.s .find
	
	addq.w #4,a0
	bra.s .loop

.noCookie	; This computer is an STF, not allowed
	pea beforeSTE_msg
	move.w #GEMDOS_CCONWS,-(sp)
	trap #1
	addq.l #6,sp
	
	bsr wait_space
	
	clr.w -(sp)
	trap #1

.find	move.w (a0)+,d7
	beq .noCookie ; STF

	cmpi.w #1,d7
	beq.s .STE
	
	; This computer is not an STE
	; TT or Falcon 030
	dc.l $4e7b0002 ; movec d0,cacr ; switch off cache
	bra.s .end

.STE	btst.b #4,1(a0)
	beq.s .end	; No MegaSTE
	clr.b $ffff8e21.w ; 8Mhz MegaSTE

.end	movem.l (sp)+,d0-a6
	rts

; -----------------------------------------------------------------------------
; Do nothing vector
; -----------------------------------------------------------------------------	
vec_null	rte

; -----------------------------------------------------------------------------	
	DATA
	 
ex_restore_msg	dc.b "Bus Error",$d,$a
	dc.b "Press the space bar and pray !", $a,$d, 0

beforeSTE_msg	dc.b "This demo requires at least a STE to work",$d,$a
	dc.b "Press the space bar to quit.", $a,$d, 0
	
; -----------------------------------------------------------------------------	
	BSS
	
sav_sr:	ds.w 1

sav_st_palette	ds.w 16
sav_physbase	ds.l 1
sav_logbase	ds.l 1
sav_getrez	ds.w 1	

sav_mfp	ds.b 32 

sav_vectors	ds.l 8
