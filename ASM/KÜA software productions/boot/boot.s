
; D-Bug Bootblock Code
;
; (c) 1991 Cyrano Jones / D-Bug.

;
; Da bootshitctor
; By GGN of KšA software productions/Paradize/D-BUG
; Coded at Outline 06 (03/06/06) from 11:00 to 19:59 ;)
;
; PARTY VERSION!!!!! Expect full version in about 20 years featuring overscan,
; raster scrollers and lots of other crap!
;
; Thanks: Cyclone for urging me to code it in the first place and encouragement
;         Rana for tolerating with me all this time and some design input
;         Defjam for faking that he liked it (although he burned me with the
;         question: "is that 128 bytes?" ;)
;         Grazey and Paranoid for being the first victims of this code (they
;         saw previews ;)
;	
	opt	p+

                lea     pattern(PC),A0
                lea     34(A0),A1
                move.w  #15*16-1,D7
rotloop:        move.w  (A0)+,D0
                ror.w   #1,D0
                move.w  D0,(A1)+
                dbra    D7,rotloop


                clr.w   -(SP)
                move.l  #-1,-(SP)
                move.l  (SP),-(SP)
                move.w  #5,-(SP)
                trap    #14

                pea     message(PC)
                move.w  #9,-(SP)
                trap    #1

                move.w  #2,-(SP)
                trap    #14
                lea     20(SP),SP
                movea.l D0,A6

nbsinus         EQU 512
cos1            EQU 32766       ;cos(2*pi/512)
sin1            EQU 402         ;sin(2*pi/512)

genere_sinus:
                lea     tabsinus(PC),A0
                moveq   #nbsinus/4-1,D7
                move.w  #$7FFF,D0       ;cos(0)=1
                clr.w   D1              ;sin(0)=0
.loop:
                move.w  D0,(A0)+
                move.w  D1,(A0)+

                move.w  D0,D3
                muls    #cos1,D3
                move.w  D1,D4
                muls    #sin1,D4

                muls    #cos1,D1
                muls    #sin1,D0

                sub.l   D4,D3
                add.l   D0,D1

                move.l  D3,D0

                add.l   D0,D0
                swap    D0
                add.l   D1,D1
                swap    D1
                dbra    D7,.loop

                lea     tabsinus(PC),A0
                moveq   #nbsinus/4-1,D2
.loop2:
                move.w  (A0)+,D0
                move.w  (A0)+,D1
                move.w  D0,nbsinus*1/4*4-4+2(A0)
                neg.w   D0
                move.w  D0,nbsinus*2/4*4-4+0(A0)
                move.w  D0,nbsinus*3/4*4-4+2(A0)
                move.w  D1,nbsinus*3/4*4-4+0(A0)
                neg.w   D1
                move.w  D1,nbsinus*1/4*4-4+0(A0)
                move.w  D1,nbsinus*2/4*4-4+2(A0)

                dbra    D2,.loop2

;0123
;x
;xx
;xxx
;xxxx
;i               SET 0
;                REPT 16
;                move.w  #i/2,$FFFF8240+i.w
;i               SET i+2
;                ENDR

;                clr.w   $FFFF8240.w
;                move.w  #$0777,$FFFF825E.w
;;;;;;;;                clr.w   $FFFF824C.w
;                move.w  #$0700,$FFFF825E.w
;                move.w  #$0700,$FFFF824E.w
;                move.w  #$0700,$FFFF8246.w
;                move.w  #$0100,$FFFF8250.w
;                move.w  #$0400,$FFFF8258.w
		movem.l palette(pc),d0-d7
		movem.l d0-7,$ffff8240.w


go:


;                addq.w  #1,$FFFF8246.w
                move.w  phase(PC),D6    ;phase
                lea     199*160(A6),A5

                move.w  #39,D7          ;no of blocks
                lea     tabsinus(PC),A1
                moveq   #1,D4           ;next byte's position
                moveq   #0,D5           ;current screen offset

wave:           move.w  D6,D0
                lea     0(A5,D5.w),A2   ;screen address
                move.w  0(A1,D0.w),D1
                muls    #16,D1
                add.l   D1,D1
                swap    D1
                add.w   #16,D1

                moveq   #31,D0

drawloop:       subq.w  #1,D1
                sge     (A2)
                lea     -160(A2),A2
                dbra    D0,drawloop

                add.w   #64,D6          ;increase phase
                and.w   #2047,D6
;                subq.w  #1,D5           ;next pixel
;                bge.s   nonextbyte
;                 moveq   #7,D5
                add.w   D4,D5
                adda.w  D4,A6           ;hehe
                eori.w  #6,D4           ;bitplane shit

                dbra    D7,wave

;                move.w  #$0FFF,$FFFF8240.w
                move.w  #37,-(SP)
                trap    #14
		addq.l	#2,sp
;                move.w  #$0312,$FFFF8240.w


                lea     -160(A6),A6
		lea	phase(pc),a3
                addi.w  #64,(a3)
                andi.w  #2047,(a3)

                move.w  #32*20-1,D7
                lea     (-31*160)(A5),A4
                lea     2(A4),A3
copystuff:
                move.w  4(A4),4(A3)
                move.w  2(A4),2(A3)
                move.w  (A4),(A3)

                addq.l  #8,A4
                addq.l  #8,A3
                dbra    D7,copystuff

                lea     0(A6),A0
                move.w  counter(PC),D0
                lea     pattern(PC),A1
                lea     0(A1,D0.w),A1

                moveq   #15,D0
drawpatloop0:   moveq   #19,D1
                move.w  (A1)+,D2
drawpatloop1:   move.w  D2,(A0)
                addq.l  #8,A0
                dbra    D1,drawpatloop1
                dbra    D0,drawpatloop0
		lea	counter(pc),a0
                addi.w  #32,(a0)
                andi.w  #511,(a0)

                cmpi.b  #57,$FFFFFC02.w
                bne     go
;                bra     go

                rts

                DATA

;                                    1234567890123456789012345678901234567890
message:        DC.B 13,10,10,10,10,"  Outline 2k6 - GGN/KšA/Paradize/D-BUG",0
                EVEN
palette: 	dc.w $0,$f00,$f0,$700,$fff,$f00,$f0,$ff0
		dc.w $f,$f0f,$ff,$555,$333,$f33,$3f3,$ff3
pattern:	
                DC.W %100000000
                DC.W %100000000
                DC.W %1010000000
                DC.W %1010000000
                DC.W %10001000000
                DC.W %10001000000
                DC.W %100000100000
                DC.W %100100100000
                DC.W %1001000010000
                DC.W %1001000010000
                DC.W %10010000001000
                DC.W %10010000001000
                DC.W %100100000000100
                DC.W %100100000000100
                DC.W %1001000000000010
                DC.W %1001111111111110
;                DC.W %0000000100000000
;                DC.W %0000000100000000
;                DC.W %0000001010000000
;                DC.W %0000001010000000
;                DC.W %0000010001000000
;                DC.W %0000010001000000
;                DC.W %0000100000100000
;                DC.W %0000100100100000
;                DC.W %0001001010010000
;                DC.W %0001001010010000
;                DC.W %0010010001001000
;                DC.W %0010010001001000
;                DC.W %0100100000100100
;                DC.W %0100100000100100
;                DC.W %1001000000000010
;                DC.W %1001111111111110


                BSS

                DS.W 16*15

counter:        DS.W 1
tabsinus:       DS.B 2048
phase:          DS.W 1
fuck_end
                END
