;;;;;;;; MACROS
checkScreen macro
    pushd0
    pushd2
    moveq   #0,d0
    moveq   #0,d2
    move.b  $ffff8205,d2
    move.l  screenpointer2,d1
    swap    d1
    cmp.w   d2,d1
    bne     .cont\@
        swap    d2
        move.l  screenpointer,d0
        move.l  screenpointer2,d1
        move.b  #0,$ffffc123
.cont\@
    popd1
    popd0
    endm


donops macro
    REPT \1
        IFNE playmusic
        ELSE
        nop
        ENDC
    ENDR        
        endm   

raster	macro
	IFNE	rasters
		move.w	\1,$ffff8240
	ENDC
	endm       

screenswap  macro
    move.l  screenpointer,d0
    move.l  screenpointer2,screenpointer
    move.l  d0,screenpointer2
        
    move.l  screenpointershifter,d0
    move.l  screenpointer2shifter,screenpointershifter
    move.l  d0,screenpointer2shifter    
    endm



framecount_start macro
    IFNE framecount
        move.w  #0,_framecounter
    ENDC
    endm

framecount_stop macro
    IFNE framecount
        move.l  #0,d0
        move.w  _framecounter,d0
        move.b  #0,$ffffc123
    ENDC
    endm


wait_for_vbl macro
    move.w  #0,$466.w       ;16
.loop\@
    tst.w   $466.w          ;12
    beq     .loop\@
    endm

swapscreens macro
    move.l  screenpointer,d0
    move.l  screenpointer2,screenpointer
    move.l  d0,screenpointer2
                
    endm


setbg	macro
	IFNE	rasters
		move.w	\1,$ffff8240
	ENDC
	endm

pushalldata macro
    movem.l d0-d7,-(sp)
    endm
    
popalldata macro
    movem.l (sp)+,d0-d7
    endm

pushall macro
    movem.l a0-a6/d0-d7,-(sp)
    endm

popall macro
    movem.l (sp)+,a0-a6/d0-d7
    endm

pusha0 macro
    move.l a0,-(sp)
    endm
pusha1 macro
    move.l a1,-(sp)
    endm
pusha2 macro
    move.l a2,-(sp)
    endm
pusha3 macro
    move.l a3,-(sp)
    endm
pusha4 macro
    move.l a4,-(sp)
    endm
pusha5 macro
    move.l a5,-(sp)
    endm
pusha6 macro
    move.l a6,-(sp)
    endm
popa0 macro
    move.l (sp)+,a0
    endm
popa1 macro
    move.l (sp)+,a1
    endm
popa2 macro
    move.l (sp)+,a2
    endm
popa3 macro
    move.l (sp)+,a3
    endm
popa4 macro
    move.l (sp)+,a4
    endm
popa5 macro
    move.l (sp)+,a5
    endm
popa6 macro
    move.l (sp)+,a6
    endm

pushd0 macro
    move.l d0,-(sp)
    endm
pushd1 macro
    move.l d1,-(sp)
    endm
pushd2 macro
    move.l d2,-(sp)
    endm
pushd3 macro
    move.l d3,-(sp)
    endm
pushd4 macro
    move.l d4,-(sp)
    endm
pushd5 macro
    move.l d5,-(sp)
    endm
pushd6 macro
    move.l d6,-(sp)
    endm
pushd7 macro
    move.l d7,-(sp)
    endm
popd0 macro
    move.l (sp)+,d0
    endm
popd1 macro
    move.l (sp)+,d1
    endm
popd2 macro
    move.l (sp)+,d2
    endm
popd3 macro
    move.l (sp)+,d3
    endm
popd4 macro
    move.l (sp)+,d4
    endm
popd5 macro
    move.l (sp)+,d5
    endm
popd6 macro
    move.l (sp)+,d6
    endm
popd7 macro
    move.l (sp)+,d7
    endm


superUserMode macro
            clr.l       -(a7)
            move.w      #32,-(a7)
            trap        #1
            addq.l      #6,a7
            move.l      d0,_old_stack
    endm
 
 
userMode macro
            move.l      _old_stack,-(a7)
            move.w  #32,-(a7)  
            trap        #1
            addq.l  #6,a7  
    endm

allocateStackAndShrink  macro
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
        pea     demostart
        move.w  #$26,-(sp)
        trap    #14
        addq.l  #6,sp
    
        clr.w   -(sp)
        trap    #1   

demostart
    endm  