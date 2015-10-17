start:
;................................................................
        move.l  4(sp),a5                ; address to basepage
        move.l  $0c(a5),d0              ; length of text segment
        add.l   $14(a5),d0              ; length of data segment
        add.l   $1c(a5),d0              ; length of bss segment
        add.l   #$1000,d0               ; length of stackpointer
        add.l   #$100,d0                ; length of basepage
        move.l  a5,d1                   ; address to basepage
        add.l   d0,d1                   ; end of program
        and.l   #-2,d1                  ; make address even
        move.l  d1,sp                   ; new stackspace
        move.l  d0,-(sp)                ; mshrink()
        move.l  a5,-(sp)                ;
        move.w  d0,-(sp)                ;
        move.w  #$4a,-(sp)              ;
        trap    #1                      ;
        lea     12(sp),sp               ;

	pea 	demo
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1    

demo:
	; save the old screen address
	lea	save_screenadr,a0    		;  the address of where to be saved
	move.b	$ffff8201.w,(a0)+		; move data in
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820d.w,(a0)+
	
	; save the palette
	movem.l $ffff8240.w,d0-d7		; load the palette bites into data regs
	movem.l	d0-d7,save_pal			; move the data to the pointed address
	
	;align new screen address
	move.l	#screen1+256,d0
	clr.b	d0
	move.l	d0,screenpointer
	lsr.w	#8,d0
	move.l	d0,screenpointershifter

	move.l	d0,$ffff8200.w

    tst.w   is_ste
    beq     .no_ste
        move.b  #0,$FF820D
        move.b  #0,$FF820F
        move.b  #0,$FF8265
.no_ste

	;align new screen address for double buffer
	move.l  #screen2+256,d0
	clr.b	d0
	move.l	d0,screenpointer2
	lsr.w	#8,d0
	move.l	d0,screenpointer2shifter

	;clr.b 	$ffff8e21.w ; 8 mhz, no cache


	;save old resolution
	move.b	$ffff8260.w,save_res    ; save old
	clr.b	$ffff8260.w				; set low res