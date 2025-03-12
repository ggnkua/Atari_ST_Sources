; Test Blitter Execution times
; The Arctic Land (T.AL) 2020
; Contact: uko.tal@gmail.com or uko at http://www.atari-forum.com


	INCDIR ".\Include"
	INCLUDE "Symbols.s"
	INCLUDE "System.s"
	OUTPUT .TOS

	OPT D+
	OPT X+

; Parameters for the tests
; X position (to set SKEW & NFSR if not 0)
CUR_X	equ 0
; Size in word of a line of the source bitmap
X_COUNT	equ 2
; Force mask values (0=default (computed from SKEW), 1=Set to $0001, 2=$FFFF)
LEF_MASK_FORCE	equ 0
MID_MASK_FORCE	equ 0
RIG_MASK_FORCE	equ 0

	TEXT

main:	; Supexec 
	pea main_super
	move.w #XBIOS_SUPEXEC,-(SP)
	trap #14 
	addq.w #6,SP

	; Exit
	clr.w -(SP)
	trap #1
	
main_super:
	bsr save_system
	bsr init_system
	
	lea screen+255,a0	; Alignment
	move.l a0,d0
	and.l #~$FF,d0
	
	move.w #0,-(sp)
	move.l d0,-(sp)
	move.l d0,-(sp)
	move.w #XBIOS_SETSCREEN,-(sp)
	trap #14
	add.w #12,sp

	; Fill screen with dots to measure execution time
	bsr fill_dotsimage
		
	; Set VBL
	syncVBL
	move.l #my_vbl,HW_SYS_VBL_VEC.w
	move.w #$2300,sr
		
	; Wait key	
	bsr wait_space

	bsr restore_system	
	rts

my_vbl:
	; Source and Dest Addresses
	lea imgData,a2
	move.l $44e,a3
	lea 8(a3),a3
		
	; Blitter initialisation
	lea HW_BLT_ADR.w,a6
	
	ifeq MID_MASK_FORCE
	move.w #$FFFF,HW_BLT_MMASK_O(a6)
	endif
	ifeq MID_MASK_FORCE-1
	move.w #$0001,HW_BLT_MMASK_O(a6)
	endif
	ifeq MID_MASK_FORCE-2
	move.w #$FFFF,HW_BLT_MMASK_O(a6)
	endif

	move.w #2,HW_BLT_SXINC_O(a6)	; Source has one bitplan	
	move.w #2,HW_BLT_SYINC_O(a6)
	move.w #8,HW_BLT_DXINC_O(a6)	; Dest has always 4 bitplanes
	move.b #2,HW_BLT_HOP_O(a6)	; Source (HOP)
	move.b #3,HW_BLT_LOP_O(a6)	; Source (OP)

	move.w #X_COUNT,d0	; Nb words/line source for XCount
	
	move.w #CUR_X,d1
	beq.s .aligned
	
	move.w d1,d2
	add.w d2,d2
	move.w .blit_endmaskSl(PC,d2.w),d2
	ifeq LEF_MASK_FORCE
	move.w d2,HW_BLT_LMASK_O(a6)
	endif
	ifeq LEF_MASK_FORCE-1
	move.w #$0001,HW_BLT_LMASK_O(a6)
	endif
	ifeq LEF_MASK_FORCE-2
	move.w #$FFFF,HW_BLT_LMASK_O(a6)
	endif
	
	not.w d2
	ifeq RIG_MASK_FORCE
	move.w d2,HW_BLT_RMASK_O(a6)
	endif
	ifeq RIG_MASK_FORCE-1
	move.w #$0001,HW_BLT_RMASK_O(a6)
	endif
	ifeq RIG_MASK_FORCE-2
	move.w #$FFFF,HW_BLT_RMASK_O(a6)
	endif
	
	ori.b #%01000000,d1	; NFSR
	move.b d1,HW_BLT_SKEW_O(a6)
	addq.w #1,d0		; Increase the X count since NFSR is set
	bra.s .endAligned
	
	; To be kept from the usage... 128 bytes max
.blit_endmaskSl	dc.w $FFFF,$7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF,$00FF,$007F,$003F,$001F,$000F,$0007,$0003,$0001,$0000
	

	; Aligned (No SKEW)
.aligned	move.b #0,HW_BLT_SKEW_O(a6)

	ifeq LEF_MASK_FORCE
	move.w #$FFFF,HW_BLT_LMASK_O(a6)
	endif
	ifeq LEF_MASK_FORCE-1
	move.w #$0001,HW_BLT_LMASK_O(a6)
	endif
	ifeq LEF_MASK_FORCE-2
	move.w #$FFFF,HW_BLT_LMASK_O(a6)
	endif
	
	ifeq RIG_MASK_FORCE
	move.w #$FFFF,HW_BLT_RMASK_O(a6)
	endif
	ifeq RIG_MASK_FORCE-1
	move.w #$0001,HW_BLT_RMASK_O(a6)
	endif
	ifeq RIG_MASK_FORCE-2
	move.w #$FFFF,HW_BLT_RMASK_O(a6)
	endif

.endAligned	move.w #SCRLINE_LEN,d1	; Nb bytes/line dest
	move.w d0,HW_BLT_XCOUNT_O(a6)
	subq.w #1,d0
	lsl.w #3,d0
	sub.w d0,d1
	move.w d1,HW_BLT_DYINC_O(a6)

	; Ready to launch
	; Sync with begin of screen
	moveq #64,d0
	lea (HW_SHIFTER_ADR+$9).w,a0
.sync	move.b (a0),d1	
	beq.s .sync
	sub.b d1,d0
	lsr.b d0,d0
	
	; Show Execution time
	move.w #$007,HW_ST_PAL_ADR.w

	; Launch 5 times
	moveq #4,d7
.loopBlit	move.l a2,HW_BLT_SADR_O(a6)
	move.l a3,HW_BLT_DADR_O(a6)
	move.w #200,HW_BLT_YCOUNT_O(a6)	
	or.b #$C0,HW_BLT_CTL_O(a6)	; Run in HOG mode
	dbf d7,.loopBlit

.end	move.w #$000,HW_ST_PAL_ADR.w
	rte
	

nbLines	equ 200
nbSpcLines	equ 5
fill_dotsimage:
	move.l $44e,a1

	REPT nbLines/nbSpcLines
	move.w #$FFFF,(a1)
	REPT 9
	lea 16(a1),a1
	move.w #$8000,(a1)
	ENDR
	lea 8(a1),a1
	move.w #$FFFF,(a1)
	lea 8(a1),a1
	lea (160*(nbSpcLines-1))(a1),a1
	ENDR

	rts
	
	DATA
	even
imgData	dcb.w X_COUNT*200,$FFFF

	BSS
screen	ds.l 40*200+256/4,0

