***************************************************************
*        Assembly Language Source To Write A Bootsector       *
*        Thanks very much to Mike (Radix) For His Help!       *
***************************************************************

Booter  move #1,-(sp)               ;Executable
        move #-1,-(sp)              ;Disktype unchanged
        move.l #-1,-(sp)            ;Serial number unchanged
        move.l #Boot,-(sp)          ;Fetch boot code
        move #18,-(sp)              ;Create prototype boot
        trap #14                    ;Do it
        add.l #14,sp                ;Tidy
        bsr Write                   ;Go and write it!!
	clr.w	-(sp)
	trap	#1
        
Write   movem.l d0-d2/a0-a2,-(sp)   ;Get registers
        move #1,-(sp)               ;Write 1 Sector
        move #0,-(sp)               ;Side 0
        move #0,-(sp)               ;Track 0
        move #1,-(sp)               ;Sector 1
        move #0,-(sp)               ;Drive 0 (A:)
        clr.l -(sp)
        move.l #Boot,-(sp)          ;Address of boot code
        move #9,-(sp)               ;Floppy write
        trap #14                    ;...and do it!
        add.l #20,sp                ;Tidy
        movem.l (sp)+,d0-d2/a0-a2   ;Restore 'em
        rts                         ;Return
        
Boot    bra.s Bcode                 ;Branch to bootcode
      DC.B   $90,$47,$4e,$55,$52,$4b,$00
      DC.B   $91,$1a,$00,$02,$02,$01,$00
      DC.B   $02,$80,$00,$68,$06,$F9,$03,$00
      DC.B   $0A,$00,$02,$00,$00,$00,$00,$00

*        ds.b 6                      ;loader
*        dc.b 255,255,255            ;serial no.
*        dc.b 0,2                    ;512 byes per sector
*        dc.b 2                      ;sectors per cluster
*        dc.b 1,0                    ;reserved sectors
*        dc.b 2                      ;number of FATs
*        dc.b 112,0                  ;max no of dir entries
*        dc.b $a0,$5                  ;no of sectors on disk
*        dc.b 249                    ;media type
*        dc.b 5,0                    ;sectors per FAT
*        dc.b 9,0   	            ;sectors per track
*        dc.b 2,0                    ;sides
*        ds.b 30                     ;filler

Bcode   move #7,d7
        move #$777,d2               ;Color $777
Bootll  move d2,$ff8240             ;Colour register 0
        move.l #$3fff,d1            ;Timing - from $3FFF to 0
Bootlsw subq.l #1,d1
        bne.s Bootlsw
        sub #$111,d2                ;Subtract $111 from d2
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
        dbf d7,Bootll

	bclr 	#0,$484.w
*	move.l	#$15000,$42a
*	move.l	#$31415926,$426	
*	move.l	#$752019f3,$420
*	move.l	#$237698aa,$43a

	RTS
