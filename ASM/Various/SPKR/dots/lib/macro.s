initAndRun  macro
            allocateStackAndShrink                              ; stack + superexec
    jsr     disableMouse                                        ; turn off mouse
    jsr     saveAndKillTimers                                   ; kill timers and save them
    jsr     backupPalAndScrMemAndResolutionAndSetLowRes         ; save screen address and other display properties
    jsr     checkMachineTypeAndSetStuff                         ; check machine type, disable cache

    jsr     \1

.mainloop
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .mainloop                                       ;

    
.exit
    move.w  #$2700,sr
    move.l  #dummyvbl,$70.w             ;Install our own VBL
    move.l  #dummy,$68.w                ;Install our own HBL (dummy)
    move.l  #dummy,$134.w               ;Install our own Timer A (dummy)
    move.l  #dummy,$120.w               ;Install our own Timer B
    move.l  #dummy,$114.w               ;Install our own Timer C (dummy)
    move.l  #dummy,$110.w               ;Install our own Timer D (dummy)
    move.l  #dummy,$118.w               ;Install our own ACIA (dummy)
    clr.b   $fffffa07.w                 ;Interrupt enable A (Timer-A & B)
    clr.b   $fffffa13.w                 ;Interrupt mask A (Timer-A & B)
    clr.b   $fffffa09.w                 ;Interrupt enable B (Timer-C & D)
    clr.b   $fffffa15.w                 ;Interrupt mask B (Timer-C & D)
    move.w  #$2300,sr
    jsr restoresForMachineTypes
    jsr restorePalAndScreenMemAndResolution
    jsr restoreTimers
    jsr enableMouse
    rts

    endm

;;;;;;;; MACROS
exitOnSpace macro
    cmp.b   #$39,$fffffc02.w
    bne     .x\@
        move.w  #-1,demo_exit
        rts
.x\@
    endm

checkDemoExit   macro
    tst.w   demo_exit
    bne     exit
    endm

resetTimers macro
    move.w  #$2700,sr
    move.l  #dummyvbl,$70.w             ;Install our own VBL
    move.l  #dummy,$68.w                ;Install our own HBL (dummy)
    move.l  #dummy,$134.w               ;Install our own Timer A (dummy)
    move.l  #dummy,$120.w               ;Install our own Timer B
    move.l  #dummy,$114.w               ;Install our own Timer C (dummy)
    move.l  #dummy,$110.w               ;Install our own Timer D (dummy)
    move.l  #dummy,$118.w               ;Install our own ACIA (dummy)
    clr.b   $fffffa07.w                 ;Interrupt enable A (Timer-A & B)
    clr.b   $fffffa13.w                 ;Interrupt mask A (Timer-A & B)
    clr.b   $fffffa09.w                 ;Interrupt enable B (Timer-C & D)
    clr.b   $fffffa15.w                 ;Interrupt mask B (Timer-C & D)
    move.w  #$2300,sr
    endm

schedule_timerA_topBorder   macro
    ;Start up Timer A each VBL
    clr.b   $fffffa19.w         ;Timer-A control (stop)
    bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
    bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
    move.b  #98,$fffffa1f.w         ;Timer A Delay (data)
    move.b  #4,$fffffa19.w          ;Timer A Predivider (start Timer A)
    endm

schedule_timerB_bottomBorder    macro
    ;Start up Timer B each VBL
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #229,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    endm

checkScreen macro
    IFEQ    screenCheck
    pushd0
    pushd1
    moveq   #0,d0
    move.b  $ffff8205,d0
    move.l  screenpointer2,d1
    swap    d1
    cmp.w      d0,d1
    bne     .cont\@
        move.l  screenpointer,d0
        move.l  screenpointer2,d1
        move.b  #0,$ffffc123
.cont\@
    popd1
    popd0
    ENDC
    endm


donops macro
    REPT \1
        nop
    ENDR        
        endm   

raster	macro
	IFEQ	rasters
		move.w	#\1,$ffff8240
	ENDC
	endm     

  
screenswap  macro
    move.l  screenpointer,d0
    move.l  screenpointer2,screenpointer
    move.l  d0,screenpointer2
    endm

swapscreens macro
    move.l  screenpointer,d0
    move.l  screenpointer2,screenpointer
    move.l  d0,screenpointer2        
    endm



wait_for_vbl macro
    move.w  #0,$466.w       ;16
.loop\@
    tst.w   $466.w          ;12
    beq     .loop\@
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



initMusic   macro
        move.l  #\1,current_voice_pointer
        move.l  #\2,current_song_pointer
        move.l  #\3-\2,current_song_size
        jsr     musicPlayer
    endm

depackAndInitMusic  macro
    move.l  #\1,a0
    move.l  musicPointer,a1
    move.l  a1,current_voice_pointer
    jsr     cranker

    move.l  a1,d0
    and.l   #1,d0
    beq     .ok\@
        addq.l  #1,a1
.ok\@

    move.l  #\2,a0
    move.l  a1,current_song_pointer
    jsr     cranker
    sub.l   current_song_pointer,a1
    move.l  a1,current_song_size
    jsr     musicPlayer

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