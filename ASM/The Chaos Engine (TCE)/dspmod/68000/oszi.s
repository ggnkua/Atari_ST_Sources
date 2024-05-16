				export oszi_vbl, oszi_on, oszi_off

				include	"dspmods.h"

DMABufSize		equ	16384
				

oszi_vbl:		tst.b	oszi_flag
				beq.s	exit
				movem.l	d0-a6,-(sp)
				pea		oszi_vbl_s
				move.w	#$26,-(sp)
				trap	#14
				addq.l	#6,sp
				movem.l	(sp)+,d0-a6
exit:           rts
				


oszi_vbl_s:     lea     oszi,a0
                moveq   #0,d0
                move.w  #2048-1,d1
cls_oszi:       move.l  d0,(a0)+
                dbra    d1,cls_oszi

                clr.w   d0
                move.b  $ffff8909.w,d0  ;Counter High
                swap    d0
                move.b  $ffff890b.w,d0  ;Counter Mid
                lsl.w   #8,d0
                move.b  $ffff890d.w,d0  ;Counter Low
                sub.l   #dma_buffer,d0
                sub.l   #1000*4,d0      ;ca 20ms zurck
                bpl.s   ok
                add.l   #DMABufSize,d0
ok:             add.l   #dma_buffer,d0
                movea.l d0,a0
                lea     oszi,a1
                moveq   #0,d0
loop1:          move.w  #$8000,d2
                moveq   #16-1,d1
loop2:          move.b  (a0),d4         ;links
                move.b  2(a0),d5        ;rechts
                adda.w  #12,a0          ;3 Samples weiter
                cmpa.l  #dma_buffer+DMABufSize,a0
                bcs.s   m1
                suba.l  #DMABufSize,a0
m1:             ext.w   d4
                ext.w   d5
                asr.w   #1,d4           ;/2, -64...63
                asr.w   #1,d5           ;/2
                add.w   #64,d4          ;Mittellinie links
                add.w   #64+128,d5      ;Mittelinie rechts
                asl.w   #5,d4           ;*32
                asl.w   #5,d5           ;*32
                add.w   d0,d4
                add.w   d0,d5
                or.w    d2,0(a1,d4.w)
                or.w    d2,0(a1,d5.w)
                lsr.w   #1,d2
                dbra    d1,loop2
                addq.w  #2,d0
                cmp.w   #32,d0
                bne.s   loop1

                lea     oszi,a0
                movea.l physbase,a1
                adda.w  #128*XRES/8+26,a1
                move.w  #256-1,d0
zeile:          moveq   #16-1,d1
spalte:         move.w  (a0)+,(a1)+
                dbra    d1,spalte
                adda.w  #XRES/8-16*2,a1
                dbra    d0,zeile
                rts
                

oszi_on:		movem.l	d0-a6,-(sp)
				pea		oszi_on_s
				move.w	#$26,-(sp)
				trap	#14
				addq.l	#6,sp
				movem.l	(sp)+,d0-a6
				st		oszi_flag
				rts
				
oszi_on_s:		move.w  #$200b,$ffff8932.w ;DSP-Out-> DAC & DMA-In
                clr.b   $ffff8900.w     ;keine DMA-Interrupts
                clr.b   $ffff8936.w     ;record 1 Track
                move.b  #$40,$ffff8921.w ;16 Bit

                move.b  #$80,$ffff8901.w ;select Record-Frame-Register

                move.l  #dma_buffer,d0
                move.l  d0,d1
                move.b  d1,$ffff8907.w  ;Basis Low
                lsr.l   #8,d1
                move.b  d1,$ffff8905.w  ;Basis Mid
                lsr.l   #8,d1
                move.b  d1,$ffff8903.w  ;Basis High

                add.l   #DMABufSize,d0
                move.l  d0,d1
                move.b  d1,$ffff8913.w  ;End Low
                lsr.l   #8,d1
                move.b  d1,$ffff8911.w  ;End Mid
                lsr.l   #8,d1
                move.b  d1,$ffff890f.w  ;End High

                move.b  #$b0,$ffff8901.w ;repeated record

				moveq	#0,d0
				move.b	$ffff8201.w,d0
				lsl.w	#8,d0
				move.b	$ffff8203.w,d0
				lsl.l	#8,d0
				move.b	$ffff820d.w,d0
				move.l	d0,physbase
				
				rts

oszi_off:		movem.l	d0-a6,-(sp)
				pea		oszi_off_s
				move.w	#$26,-(sp)
				trap	#14
				addq.l	#6,sp
				movem.l	(sp)+,d0-a6
				rts
					
oszi_off_s:     clr.b   $ffff8901.w     ;DMA-Stop
                rts

				data
oszi_flag:		dc.b	0
				dc.b	0
				
				bss
				
physbase:		ds.l 1
dma_buffer:     ds.b DMABufSize
oszi:           ds.w 16*256
