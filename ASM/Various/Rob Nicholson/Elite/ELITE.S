; Elite Boot Loader V1.1

	include easymac.def
    include atari.def
   
load_addr:	equ $f000					; load address for loader.img
run_addr:	equ $f000					; run address for loader.img

	clr.l -(sp)							; disable cursor
	xbios cursconf
	lea free(pc),a0						; enough memory ?
	cmp.l #load_addr,a0
	if.s <hi>							; no
		pea error(pc)					; print error message
		bdos c_conws
		repeat							; hang machine
		again
	endif
    clr -(sp)                           ; load LOADER.IMG
    pea file_name(pc)
    bdos f_open
    move d0,d7
    push.l #load_addr
    push.l #$7fffffff
    push.w d7
    bdos f_read
    push d7
    bdos f_close
    jmp run_addr                        ; run program

error:		dc.b "Insufficent memory!",10,13,10
			dc.b "System Halted",0
file_name:	dc.b "loader.img",0

	even

free:
