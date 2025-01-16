* Figure 3 *

;
; P_EXEC into memory and run from there
;
; PC Relative Load N' GO! Trainer source
;
; by MUG U.K(tm) - Accompanies articles in ST Applications
;
; Sometime in 1994


	opt     p+,o+

begin   bra.s   start
	dc.b    'Load N' GO! Loader '
	dc.b    'by MUG U.K(tm)',0
	even

start   movea.l a7,a5 
	lea     begin(pc),a7
	move.l  4(a5),a5
	move.l  $c(a5),d0
	add.l   $14(a5),d0
	add.l   $1c(a5),d0
	add.l   #$100,d0

	move.l  d0,-(a7)
	move.l  a5,-(a7)
	clr.w   -(a7)
	move.w  #$4a,-(a7)
	trap    #1
	adda.l  #12,a7

print   pea     message(pc)     ; Print Message
	move.w  #9,-(a7)
	trap    #1
	addq.l  #6,a7

wait    move.w  #7,-(a7)        ; Wait for key
	trap    #1
	addq.l  #2,sp           

loadprg pea     null(pc)
	pea     null(pc)
	pea     file(pc)        ; filename to load
	move.w  #3,-(A7)        ; LOAD BUT DON'T EXECUTE
	move.w  #$4b,-(a7)      ; P_EXEC
	trap    #1
	lea     16(a7),a7       ; ADJUST STACK

check   move.l    d0,d7 
	bmi.b   error           ; AN ERROR OCCURED

alter   move.l  d0,a1           ; START ADDRESS OF PROGRAM
	lea     $100(a1),a1     ; NOW STORED IN REGISTER A1

;
; This is where the alterations take place
; All offsets are as other trainer source code
;
	move.w  #$6008,$3fe(A1) ; Infinite Lives
	move.w  #$5279,$13a6(a1)

run_prg move.l  d7,-(a7)
	move.l  d7,-(a7)
	move.l  d7,-(a7)
	move.w  #4,-(a7)        ; RUN PROGRAM IN MEMORY
	move.w  #$4b,-(a7)      ; P_EXEC
	trap    #1
	lea     16(a7),a7 

error   move.w  #$4c,-(a7)      ; Quit & Error routine
	trap    #1

null    dc.l    0

file    dc.b    'pothole2.prg',0
	even

message dc.b    27,"E"
	dc.b    "POTHOLE 2",13,10
	dc.b    "---------",13,10,10
	dc.b    "Load N GO ! Trainer by MUG U.K(tm)",13,10,10
	dc.b    "For: ST Applications",13,10,10
	dc.b    0
	even
