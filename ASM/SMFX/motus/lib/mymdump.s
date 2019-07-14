DUMP EQU 0

DUMP_DELTA	equ 1




;-------------- mym patch for dumping
dumpMymFrames
	move.l	musicBufferPointer,musicpointer
.doFrame
    pushd7
    	move.l	musicDumperPointer,a0
	   	jsr		8(a0)
	   	jsr		dumpFrame
    popd7
;        not.w	$ffff8240
    dbra    d7,.doFrame

;	nop
;	move.l	musicpointer,a1
;	move.l	musicBufferPointer,a0
;	sub.l	a0,a1


    move.l  musicBufferPointer,musicpointer
    rts

myCode
    jmp     $12345678


findEntryAndExitCode
    move.l  #$3A7C8800,d0
.ok
    cmp.l   (a0)+,d0
    bne     .ok
;    move.b	#0,$ffffc123
    move.w  myCode,-4(a0)
    move.l  #mymPatchCode,-2(a0)
    move.w  #$46C1,d0
.ok2
    cmp.w   (a0)+,d0
    bne     .ok2
    move.l  a0,exitAddress+2
    rts

;			  |0 Channel A Freq Low              BIT 7 6 5 4 3 2 1 0|
;       |     |1 Channel A Freq High                     BIT 3 2 1 0|
;       |     |2 Channel B Freq Low              BIT 7 6 5 4 3 2 1 0|
;       |     |3 Channel B Freq High                     BIT 3 2 1 0|
;       |     |4 Channel C Freq Low              BIT 7 6 5 4 3 2 1 0|
;       |     |5 Channel C Freq High                     BIT 3 2 1 0|
;       |     |6 Noise Freq                          BIT 5 4 3 2 1 0|
;       |     |7 Mixer Control                   BIT 7 6 5 4 3 2 1 0|
;       |     |8 Channel A Amplitude Control           BIT 4 3 2 1 0|
;       |     |9 Channel B Amplitude Control           BIT 4 3 2 1 0|
;       |     |10 Channel C Amplitude Control          BIT 4 3 2 1 0|
;       |     |11 Envelope Period High           BIT 7 6 5 4 3 2 1 0|
;       |     |12 Envelope Period Low            BIT 7 6 5 4 3 2 1 0|
;       |     |13 Envelope Shape                         BIT 3 2 1 0|
;       |     |14 Port A                         BIT 7 6 5 4 3 2 1 0|
;       |     |15 Port B (Parallel port)                            |

mymPatchCode
    IFEQ    DUMP
    	IFEQ	DUMP_DELTA
    		lea		dumpedRegs,a5
    		moveq	#0,d0
    		rept 8
    			move.l	d0,(a5)+
    		endr
    		lea		dumpedRegs,a5

	    ELSE
	        move.l  musicpointer,a5
	    ENDC
    ELSE
        lea     $ffff8800,a5
    ENDC


    IFEQ DUMP
		move.b  2(a1),(a5)+							;	reg0			; 0 channel A freq low
		move.b  6(a1),(a5)+							;	reg1			; 1 channel A freq high
		add.w   #8,a1
    ELSE
        move.l  (a1)+,(a5)
        move.l  (a1)+,(a5)
    ENDC

    IFEQ DUMP
		move.b  2(a1),(a5)+							;	reg2			; 2 channel B freq low
		move.b  6(a1),(a5)+							;	reg3			; 3 channel B freq high
		add.w   #8,a1
    ELSE
        move.l  (a1)+,(a5)
        move.l  (a1)+,(a5)
    ENDC

    IFEQ DUMP
        move.b  2(a1),(a5)+							;	reg4			; 4 channel C freq low
        move.b  6(a1),(a5)+							;	reg5			; 5 channel C freq high
        move.b  10(a1),(a5)+						;	reg6			; 6 noise freq
        move.b  14(a1),(a5)+						;	reg7			; 7 mixer control
        add.w   #16,a1
    ELSE
        move.l  (a1)+,(a5)
        move.l  (a1)+,(a5)
        move.l  (a1)+,(a5)
        move.l  (a1)+,(a5)
    ENDC

    tst.b   2(a1)
    beq     .doVolume_A
    move.w  78(a4),d0
    and.w   #$f,d0
    cmp.b   #$d,d0
    beq     .skipVolume_A
    cmp.b   #$5,d0
    beq     .skipVolume_A
.doVolume_A
    IFEQ DUMP
        move.b  2(a1),(a5)+							;	reg8			; 8 Channel A Amplitude Control
        add.w   #4,a1
    ELSE
        move.l  (a1)+,(a5)
    ENDC
    jmp     .volume_A_Done
.skipVolume_A
    IFEQ    DUMP
;    	move.b	#-1,(a5)+
		lea		1(a5),a5							;	reg10 skip
    ENDC
    addq.l  #4,a4
.volume_A_Done 

    tst.b   2(a1)
    beq     .doVolume_B
    move.w  $ce(a4),d0
    and.w   #$f,d0
    cmp.b   #$d,d0
    beq     .skipVolume_B
    cmp.b   #$5,d0
    beq     .skipVolume_B
.doVolume_B
    IFEQ DUMP
        move.b  2(a1),(a5)+							;	reg9			; 9 Channel B Amplitude Control
        add.w   #4,a1
    ELSE
        move.l  (a1)+,(a5)
    ENDC
    jmp     .volume_B_Done
.skipVolume_B
    IFEQ    DUMP
;    	move.b	#-1,(a5)+
		lea		1(a5),a5							;	reg10 skip
    ENDC
    addq.l  #4,a1
.volume_B_Done

    tst.b   2(a1)
    beq     .doVolume_C
    move.w  $14e(a4),d0
    and.w   #$f,d0
    cmp.b   #$d,d0
    beq     .skipVolume_C
    cmp.b   #$5,d0
    beq     .skipVolume_C
.doVolume_C
    IFEQ DUMP
        move.b  2(a1),(a5)+							;	reg10			; 10 Channel C Amplitude Control
        add.w   #4,a1
    ELSE
        move.l  (a1)+,(a5)
    ENDC
    jmp     .volume_C_Done
.skipVolume_C
    IFEQ    DUMP
;    	move.b	#-1,(a5)+
		lea		1(a5),a5							;	reg10 skip
    ENDC
    addq.l  #4,a1
.volume_C_Done



;------- buzzer stuff
;        move.w  8(a1),d2
;        beq.s   .endsetupbuzz               ;test if buzzer used
;
;        move.l  (a1)+,(a5)              ;fBuzz
;        move.l  (a1)+,(a5)              ;fBuzz
;
;        subq.w  #1,d2
;        lsl.w   #7,d2                   ; *128 bytes per instrument buffer
;        move.w  78(a4,d2.w),d0
;        andi.w  #$000F,d0
;        cmpi.b  #$B,d0                  ;d0 holds timer mixer nibble
;        beq.s   .endsetupbuzz               ;if syncbuzz dont touch the buzzer wave
;
;        move.b  #$D,(a5)
;        move.b  18(a4,d2.w),d0              ; new buzzer wave in d0
;        cmp.b   (a5),d0                 ; compare buzzer current
;        bne.s   .setupwave              ; if different setup wave
;        tst.b   50(a4,d2.w)             ; if not different then
;        bne.s   .endsetupbuzz               ; is buzzer waveform setup?
;        tst.b   19(a4,d2.w)             ; do we need buzzer start sync?
;        beq.s   .endsetupbuzz               ; if yes, go ahead and set up waveform
;.setupwave  
;		move.b  d0,2(a5)                ;
;.endsetupbuzz
;
    move.w  8(a1),d2									;        move.w  8(a1),d2
    bne     .doBuzz               						;        beq.s   .endsetupbuzz               ;test if buzzer used
.skipBuzz
	    IFEQ    DUMP
;	    	move.b	#-1,(a5)+
;	    	move.b	#-1,(a5)+
			lea		2(a5),a5
	    	move.b	#-1,(a5)+
;			lea		3(a5),a5							;		skip reg11,12 and 13
	    ENDC
	    add.w   #12,a1
	    jmp		.endsetupbuzz
.doBuzz
    IFEQ DUMP
        move.b  2(a1),(a5)+								;		reg 11 Envelope Period High
        move.b  6(a1),(a5)+								;		reg 12 Envelope Period Low 
        add.w   #8,a1
    ELSE		
        move.l  (a1)+,(a5)								;        move.l  (a1)+,(a5)              ;fBuzz
        move.l  (a1)+,(a5)								;        move.l  (a1)+,(a5)              ;fBuzz
    ENDC
    subq.w  #1,d2   
    lsl.w   #7,d2
    move.w  78(a4,d2.w),d0
    and.w   #$f,d0
    cmp.b   #$b,d0
    beq     .skipShape
;   move.b  #$d,$ffff8800           ; careful with that axe eugene!
    moveq   #0,d0
    move.b  18(a4,d2.w),d0
;   cmp.b   $ffff8800,d0
;	jmp		.setShape
    cmp.b   reg15,d0
    bne     .setShape
    tst.b   50(a4,d2.w)
    bne     .skipShape
    tst.b   19(a4,d2.w)
    beq     .skipShape
.setShape
;    lsl.w   #8,d0
 ;   or.l    #$0d000000,d0
    IFEQ DUMP
        move.b  d0,reg15
        move.b  d0,(a5)+
    ELSE
        move.l  d0,(a5)
    ENDC
    jmp     .endsetupbuzz
.skipShape
    IFEQ    DUMP
        move.b  #-1,(a5)+
;		lea		1(a5),a5
    ENDC
.endsetupbuzz
;    move.w  d1,sr
	IFEQ	DUMP
		IFEQ	DUMP_DELTA
		ELSE
		    move.l  a5,musicpointer
		ENDC
	ENDC
exitAddress
    jmp     $12345678



checkregs macro
    move.b  (a0)+,d0            ; special case that checks for -1 in the regs, so that I know to skip
    cmp.b	#-1,d0
    beq     .e\1
        move.w  #-1,f\1
        move.b  d0,reg\1
        addq.w  #1,d7
        jmp     .r\1
.e\1
        move.w  #0,f\1

.r\1
    endm

tryfillreg macro
    tst.w   f\1                 ; test if the flag for said register is 0 or not, 
    beq     .end\1              ; if 0 we got no change
        move.b #\1,(a1)+        ; select the register for psg
        move.b reg\1,(a1)+      ; move the register value into
.end\1
    endm

checkreg macro
    move.b  (a0)+,d0            ; get register from ym dump
    cmp.b   reg\1,d0            ; check with register since last change
    beq     .nochange\1         ; if equal, no change
.change\1
        move.w  #-1,f\1         ; set -1 on changeflag
        move.b  d0,reg\1        ; move register value to memory
        addq.w  #1,d7           ; set changed register counter +1
        jmp     .r\1            ; jump to end
.nochange\1
        move.w  #0,f\1          ; set 0 on changeflag
.r\1
    endm   


dumpFrame
	IFNE	DUMP_DELTA
	rts
	ENDC

	lea		dumpedRegs,a0						
	move.l	musicpointer,a1
	moveq   #0,d7           ; reset counter
			checkreg    0               
			checkreg    1
			checkreg    2
			checkreg    3
			checkreg    4
			checkreg    5
			checkreg    6
			checkreg    7
			checkreg    8
			checkreg    9
			checkreg    10
			checkreg    11
			checkreg    12
			checkregs   13
			; now d7 has the number of flags that are not good
			tst.w   d7
			beq     .noChange
.atLeastOneChange
	add.w   d7,d7
	add.w   d7,d7
	neg.w   d7
	add.w   #56,d7


	move.b  d7,(a1)+                ; indicate the number of changes
	tryfillreg 0
	tryfillreg 1
	tryfillreg 2
	tryfillreg 3
	tryfillreg 4
	tryfillreg 5
	tryfillreg 6
	tryfillreg 7
	tryfillreg 8
	tryfillreg 9
	tryfillreg 10
	tryfillreg 11
	tryfillreg 12
	tryfillreg 13
	jmp     .contxx
.noChange
    move.b  #56,(a1)+                ; no change     
.contxx
			move.l	a1,musicpointer
	rts

reg0    dc.b    -1
reg1    dc.b    -1
reg2    dc.b    -1
reg3    dc.b    -1
reg4    dc.b    -1
reg5    dc.b    -1
reg6    dc.b    -1
reg7    dc.b    -1
reg8    dc.b    -1
reg9    dc.b    -1
reg10    dc.b   -1
reg11    dc.b   -1
reg12    dc.b   -1
reg13    dc.b   -1

reg15   dc.w    0


f0      dc.w    0
f1      dc.w    0
f2      dc.w    0
f3      dc.w    0
f4      dc.w    0
f5      dc.w    0
f6      dc.w    0
f7      dc.w    0
f8      dc.w    0
f9      dc.w    0
f10     dc.w    0
f11     dc.w    0
f12     dc.w    0
f13     dc.w    0

dumpedRegs	ds.b	32

;; ................
;; Do YM write
;        move.w  #$ffff8800,a5               ;small optimisation
;        move.w  sr,d1
;        move.w  #$2700,sr               	 ;interrupts off
;
;
;        tst.b   INSTAOFFSET+19(a4)          ; do we need to do sync A ?
;        beq.s   .nochAsync
;        tst.b   INSTAOFFSET+50(a4)          ; have we synced A?
;        bne.s   .nochAsync
;        move.l  #$00000000,(a5)             ; sync A
;        move.l  #$01000000,(a5)             ; sync A
;.nochAsync 
;		 move.l  (a1)+,(a5)              ;fA
;        move.l  (a1)+,(a5)              ;fA
;
;
;        tst.b   INSTBOFFSET+19(a4)          ; do we need to do sync B ?
;        beq.s   .nochBsync
;        tst.b   INSTBOFFSET+50(a4)          ; have we synced B?
;        bne.s   .nochBsync
;        move.l  #$02000000,(a5)             ; sync B
;        move.l  #$03000000,(a5)
;.nochBsync  
;		 move.l  (a1)+,(a5)              ;fB
;        move.l  (a1)+,(a5)              ;fB
;
;
;        tst.b   INSTCOFFSET+19(a4)          ; do we need to do sync C ?
;        beq.s   .nochCsync
;        tst.b   INSTCOFFSET+50(a4)          ; have we synced C?
;        bne.s   .nochCsync
;        move.l  #$04000000,(a5)             ; sync C
;        move.l  #$05000000,(a5)
;.nochCsync 
;		 move.l  (a1)+,(a5)              ;fC
;        move.l  (a1)+,(a5)              ;fC
;
;
;        move.l  (a1)+,(a5)              ;fNoise
;        move.l  (a1)+,(a5)              ;Mixer
;
;
;        tst.b   2(a1)
;        beq.s   .skiptovolA
;        move.w  INSTAOFFSET+78(a4),d0
;        andi.w  #$000F,d0
;        cmpi.b  #$D,d0                  ;test digi
;        beq.s   .timerfxA
;        cmpi.b  #$5,d0                  ;test SID
;        beq.s   .timerfxA
;.skiptovolA move.l  (a1)+,(a5)              ;vA
;        bra.s   .endA
;.timerfxA   addq.l  #4,a1
;.endA
;
;        tst.b   2(a1)
;        beq.s   .skiptovolB
;        move.w  INSTBOFFSET+78(a4),d0
;        andi.w  #$000F,d0
;        cmpi.b  #$D,d0                  ;test digi
;        beq.s   .timerfxB
;        cmpi.b  #$5,d0                  ;test SID
;        beq.s   .timerfxB
;.skiptovolB move.l  (a1)+,(a5)              ;vB
;        bra.s   .endB
;.timerfxB   addq.l  #4,a1
;.endB
;
;        tst.b   2(a1)
;        beq.s   .skiptovolC
;        move.w  INSTCOFFSET+78(a4),d0
;        andi.w  #$000F,d0
;        cmpi.b  #$D,d0                  ;test digi
;        beq.s   .timerfxD
;        cmpi.b  #$5,d0                  ;test SID
;        beq.s   .timerfxD
;.skiptovolC move.l  (a1)+,(a5)              ;vC
;        bra.s   .endC
;.timerfxD   addq.l  #4,a1
;.endC
;
;        move.w  8(a1),d2
;        beq.s   .endsetupbuzz               ;test if buzzer used
;
;        move.l  (a1)+,(a5)              ;fBuzz
;        move.l  (a1)+,(a5)              ;fBuzz
;
;        subq.w  #1,d2
;        lsl.w   #7,d2                   ; *128 bytes per instrument buffer
;        move.w  78(a4,d2.w),d0
;        andi.w  #$000F,d0
;        cmpi.b  #$B,d0                  ;d0 holds timer mixer nibble
;        beq.s   .endsetupbuzz               ;if syncbuzz dont touch the buzzer wave
;
;        move.b  #$D,(a5)
;        move.b  18(a4,d2.w),d0              ; new buzzer wave in d0
;        cmp.b   (a5),d0                 ; compare buzzer current
;        bne.s   .setupwave              ; if different setup wave
;        tst.b   50(a4,d2.w)             ; if not different then
;        bne.s   .endsetupbuzz               ; is buzzer waveform setup?
;        tst.b   19(a4,d2.w)             ; do we need buzzer start sync?
;        beq.s   .endsetupbuzz               ; if yes, go ahead and set up waveform
;.setupwave  
;		move.b  d0,2(a5)                ;
;.endsetupbuzz
;
;        move.w  d1,sr                   ;restore interrupts





prs macro
	move.b	(a0)+,d6
	cmp.b	#-1,d6
	beq		.skipNote\@
		move.b	d7,(a1)
		move.b	d6,(a2)
.skipNote\@
;	add.w	#1,a0
	add.b	#1,d7
	endm

pr macro
	move.b	(a0)+,d6
	move.b	d7,(a1)
	move.b	d6,(a2)
;	add.w	#1,a0
	add.b	#1,d7
	endm	

replayMymDump
	subq.w	#1,mymFrames
	blt		.alert
    move.l  musicpointer,a0
    IFEQ	DUMP_DELTA

    lea     $ffff8800.w,a4
    lea     $ffff8802.w,a1
    moveq   #0,d0
    move.b  (a0)+,d0
    ble		.skip						; crash prevention 1
    and.w	#%1111111110,d0				; crash prevention 2
    cmp.b	#56,d0						; crash prevention 3
    ble		.kk
    	move.b	#56,d0
.kk
    jmp     .loop(pc,d0.w)
.loop
        REPT 14
            move.b  (a0)+,(a4)          ;     2
            move.b  (a0)+,(a1)          ;     2 -> 4            ;48
        ENDR
.skip

    ELSE
    lea		$ffff8800,a1
    lea		$ffff8802,a2
    moveq	#0,d7
    	REPT 8
    	pr
    	ENDR
    	REPT 6
    	prs
    	ENDR
    ENDC
    move.l  a0,musicpointer
	rts
.alert
	jsr		musicPlayer+8
;	move.b	#0,$ffffc123
	rts

playRegSkip macro
    move.w  (a0)+,d7
    cmp.w   #-1,d7
    beq     .skipNote\@
        move.l  d7,(a1)
.skipNote\@
    add.l   #$01000000,d7
    endm

playReg macro
    move.w  (a0)+,d7
    move.l  d7,(a1)
    add.l   #$01000000,d7
    endm

replayMymDump2
    move.l  musicpointer,a0
    lea     $ffff8800,a1
    moveq   #0,d7

        REPT 8
        playReg
        ENDR
        REPT 6
        playRegSkip
        ENDR
    move.l  a0,musicpointer
    rts
.waiter dc.w    50


musicpointer    dc.l    0

doMymStuff
	; cleamn shit
	lea		dumpedRegs,a0
	moveq	#0,d0
	move.w	d0,reg15

	REPT 8
	move.l	d0,(a0)+
	ENDR
	lea		f0,a0
	REPT 7
		move.l	d0,(a0)+
	ENDR
	lea		reg0,a0
	moveq	#-1,d0
	REPT 3
		move.l	d0,(a0)+
	ENDR
	move.w	d0,(a0)+

	; new:
	jsr		fixMusicDumper
	jsr		initMusicDumper
	jsr		setSongPosition

;		initMusicD	musicmyv,musicmys,musicmysend
	move.l	musicBufferPointer,musicpointer	
;    lea     replayroutine,a0
	move.l	musicDumperPointer,a0
	add.w	#2,a0
	jsr		findEntryAndExitCode
	rts



fixMusicDumper
	;determine offsets in the actual current player, so we can use them in the new player offsets
	lea		musicPlayerD,a0
	lea		current_voice_pointer,a1
	sub.l	a0,a1						;00007952
	lea		current_song_pointer,a2		
	sub.l	a0,a2						;00007956
	lea		current_song_size,a3
	sub.l	a0,a3						;0000795A
;	lea		musicmyv,a4
;	sub.l	a0,a4						;0000795E
;	lea		musicmys,a5	
;	sub.l	a0,a5						;0000C1B6
;	lea		musicmysend,a6
;	sub.l	a0,a6						;0000E9C0

	movem.l	a1-a3,myMusicPointers

	jsr		searchMysMyvInSND
	jsr		copyBinaryPlayerToBuffer
	rts

initMusicDumper
	move.l	musicDumperPointer,a0
	movem.l	myMusicPointers,a1-a6
	add.l	a0,a1						; current_voice_pointer address
	add.l	a0,a2						; current_song_pointer address
	add.l	a0,a3						; current_song_size address
;	add.l	a0,a4						; musicMyv
;	add.l	a0,a5						; musicMys
;	add.l	a0,a6						; musicMysEnd

	move.l	a4,(a1)
	move.l	a5,(a2)
	sub.l	a5,a6
	move.l	a6,(a3)


	jmp		(a0)

;;..........................................
;; counter = 0, so parse tracker line
;.testparse1	lea	instrumentA(pc),a4
;		tst.b	61(a4)				; test rle counter
;		bne.s	.skipparse1
;		moveq	#0,d0
;		moveq	#0,d1
;		move.b	4(a0),d0			; pattern number channel 1
;		move.b	44(a0),d1			; track pattern position
;		btst	#0,37(a0)			; channel muted?
;		sne	d2
;		bsr	parsetracker			; parse Ch A tracker codes
;		addq.b	#1,44(a0)			; increase position for next time
;		bra.s	.testparse2
;.skipparse1	subq.b	#1,61(a4)


;;..........................................................................................
;				;...+1090
;patterndata:	;			; TRACK
;		;ds.b	1		; 0 note number          ; 0 note   A
;		;ds.b	1		; 1 instrument number    ; 1 instru A
;		;ds.b	1		; 2 volume               ; 2 volume A
;		;ds.b	1		; 3 effect 1 type
;		;ds.b	1		; 4 effect 1 number
;		;ds.b	1		; 5 effect 2 type
;		;ds.b	1		; 6 effect 2 number
;		;ds.b	1		; 7 RLE byte - number of empty lines to next used line
;
;		ds.b	8*$40*256	; 8 bytes, 1 track, $40 lines, 256 patterns
;					; 131072 bytes (128k)
;trackerdataend:
;;..........................................................................................

setSongPosition
	lea		songPositionData,a0
;	move.b	#MYM_DUMP1_SONG_POS,8(a5)		; pattern
;	move.b	#MYM_DUMP1_CHAN1_PATTR,12(a5)
;	move.b	#MYM_DUMP1_CHAN2_PATTR,13(a5)
;	move.b	#MYM_DUMP1_CHAN3_PATTR,14(a5)
;
;	move.b	#MYM_DUMP1_SONG_POS_NEXT,46(a5)
;	move.b	#MYM_DUMP1_CHAN1_PATTR_NEXT,60(a5)
;	move.b	#MYM_DUMP1_CHAN2_PATTR_NEXT,61(a5)
;	move.b	#MYM_DUMP1_CHAN3_PATTR_NEXT,62(a5)

	move.b	(a0)+,8(a5)		; pattern
	move.b	(a0)+,12(a5)
	move.b	(a0)+,13(a5)
	move.b	(a0)+,14(a5)

	move.b	(a0)+,46(a5)
	move.b	(a0)+,60(a5)
	move.b	(a0)+,61(a5)
	move.b	(a0)+,62(a5)


	rts

songPositionData	ds.b	8

advanceSNDPos

	move.l	sndMys,a0		; song track orig snd
	move.b	#0,9(a0)

	lea		advanceSNDData,a1

;	move.b	#MYM_DUMP1_SONG_POS_END,8(a0)		; pattern
;	move.b	#MYM_DUMP1_CHAN1_PATTR_END,12(a0)
;	move.b	#MYM_DUMP1_CHAN2_PATTR_END,13(a0)
;	move.b	#MYM_DUMP1_CHAN3_PATTR_END,14(a0)

;	move.b	#MYM_DUMP1_SONG_POS_NEXT_END,46(a0)
;	move.b	#MYM_DUMP1_CHAN1_PATTR_NEXT_END,60(a0)
;	move.b	#MYM_DUMP1_CHAN2_PATTR_NEXT_END,61(a0)
;	move.b	#MYM_DUMP1_CHAN3_PATTR_NEXT_END,62(a0)

	move.b	(a1)+,8(a0)
	move.b	(a1)+,12(a0)
	move.b	(a1)+,13(a0)
	move.b	(a1)+,14(a0)

	move.b	(a1)+,46(a0)
	move.b	(a1)+,60(a0)
	move.b	(a1)+,61(a0)
	move.b	(a1)+,62(a0)

	move.b	#0,9(a0)
	move.b	#0,52(a0)
	move.b	#0,53(a0)
	move.b	#0,54(a0)
	move.b	#0,55(a0)
	rts

advanceSNDData		ds.b	8

copyBinaryPlayerToBuffer
	lea		musicPlayerDEnd,a0		; end of binary replayer
	lea		musicPlayerD,a1				; start of binary replayer
	sub.l	a1,a0					; size of binary player
	move.l	musicDumperPointer,a2	; target memory
	move.l	a2,a6					; for end val
	add.l	a0,a6					; end target memory
.cp	
	move.w	(a1)+,(a2)+				; copy word
	cmp.l	a6,a2					; done?
	blt		.cp						; iterate
; copy binary replayer, done
	move.l	a2,a4					; save end address
;	sub.l	musicDumperPointer,a4	; end address - start addres = offset to myv
	move.l	a4,myMusicPointers+12
;	move.l	myMusicPointers+12,a5	; get original myv offset
;	cmp.l	a4,a5					; check, since binary player should be the same
;	beq		.good
;		move.b	#0,$ffffc123		; derpderp if we get here
;		illegal
;.good
; WE COPIED PLAYER NOW
	; now we have copied the thing, now. we will insert from snd
	move.l	sndMys,a0				;get previously found starting value of track data from snd (marks the END of voice)
	move.l	sndMyv,a1				;get the start of the voice data
	sub.l	a1,a0					;voice data end - voice data start = voice data size
	add.l	a0,a6					;adjust target end length register
.cp2
	move.w	(a1)+,(a2)+				; copy word
	cmp.l	a6,a2					; done?
	blt		.cp2					; iterate
; WE COPIED MYV NOW, DETERMINE MYV SIZE = mysStart
	move.l	a2,a4					; current pos
;	sub.l	musicDumperPointer,a4	; offset to mys
	move.l	a4,myMusicPointers+16

	move.l	sndMysEnd,a0
	move.l	sndMys,a1
	sub.l	a1,a0
	add.l	a0,a6
.cp3
	move.w	(a1)+,(a2)+
	cmp.l	a6,a2
	blt		.cp3
	move.l	a2,a4
;	sub.l	musicDumperPointer,a4
	move.l	a4,myMusicPointers+20

	rts




searchMysMyvInSND
	lea		snd+28000,a0
	move.w	#'IN',d0
	move.w	#'ST',d1
.find1
	cmp.w	(a0)+,d0
	bne		.find1
		cmp.w	(a0)+,d1
		bne		.find1
		move.l	a0,a1						; INST DATA
		sub.l	#40,a1
;		move.b	#0,$ffffc123
	move.w	#'TR',d0
	move.w	#'AK',d1
.find2
	cmp.w	(a0)+,d0
	bne		.find2
		cmp.w	(a0)+,d1
		bne		.find2
		move.l	a0,a2
		sub.l	#8,a2
;		move.b	#0,$ffffc123
	move.w	#'DI',d0
	move.w	#'GI',d1
.find3
	cmp.w	(a0)+,d0
	bne		.find3
		cmp.w	(a0)+,d1
		bne		.find3
		move.l	a0,a3		; song end
		sub.l	#8,a3

;		sub.l	#4,a3
;		move.b	#0,$ffffc123

; now we have	a1: myv start
;				a2: mys start
;				a3: mys end
	move.l	a1,sndMyv
	move.l	a2,sndMys
	move.l	a3,sndMysEnd
	rts
musicDumperPointer	ds.l	1
sndMyv				ds.l	1
sndMys				ds.l	1
sndMysEnd			ds.l	1
myMusicPointers		ds.l	6		; offsets into addresses:	0	current_voice_pointer
									; 							1	current_song_pointer
									;							2	current_song_size
									;							3	musicmyv
									;							4	musicmys
									;							5	musicmysend

