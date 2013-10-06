;********************************************************************

iera            equ $fffffa07           ;Interrupt-Enable-Register A
ierb            equ $fffffa09           ;                                                               B
imra            equ $fffffa13
isra            equ $fffffa0f
isrb            equ $fffffa11
tacr            equ $fffffa19
tbcr            equ $fffffa1b
tadr            equ $fffffa1f
tbdr            equ $fffffa21
tccr            equ $fffffa1d
tcdr            equ $fffffa23
aer             equ $fffffa03
STColor         equ $ffff8240
FColor          equ $ffff9800
timer_int       equ $0120
timer_c_int     equ $0114


vbaselow        equ $ffff820d
vbasemid        equ $ffff8203
vbasehigh       equ $ffff8201
vcountlow       equ $ffff8209
vcountmid       equ $ffff8207
vcounthigh      equ $ffff8205
linewid         equ $ffff820f
hscroll         equ $ffff8265

keyctl          equ $fffffc00
keybd           equ $fffffc02

DspHost         equ $ffffa200
HostIntVec      equ $03fc

PCookies        equ $05a0


* Adresse       Funktion                Input                Output
*-------------------------------------------------------------------------
* player+28:    install Player          -                    d0: Version (BCD)
* player+28+4:  de-install Player       -                    -
* player+28+8:  start Player            a0: Modul            -
* player+28+12: stop Player             -                    -
* player+28+16: Player-Int ( 50 Hz )    -                    -
* player+28+20: MOD-Playtime            a0: Modul            d0: Playtime
*                                                            in BCD, z.B. $1234
*                                                            = 12 Min, 34 Sek
* player+28+24: dc.w MainVolume
*               0: max Volume
*               $40: Volume=0
* player+28+26: dc.w Surrounddelay
*               0: Surround aus
*               1...$800 Delay

;********************************************************************


play_mod:       movea.l a0,a6
                bsr     player+28+8     ;Start Player

                move.w  #1,timer50

wait_key:       move.w  #2,-(sp)
                move.w  #1,-(sp)        ;Bconstat
                trap    #13
                addq.l  #4,sp

                tst.w   d0
                bne.s   key

		bra.s	wait_key

key:            move.w  #2,-(sp)
                move.w  #2,-(sp)        ;Bconin
                trap    #13
                addq.w  #4,sp

                cmp.b   #" ",d0
                beq.s   exit

                cmp.b   #"s",d0
                bne.s   wait_key
                move.w  player+28+26,d0
                bchg    #11,d0
                move.w  d0,player+28+26
                bra.s   wait_key

exit:           ;bsr     VolDown
                bsr     player+28+3*4   ;Stop

                rts

                
VolDown:        lea     player+28+24,a0 ;Main-Volume
                moveq   #0,d0
vol_down1:      bsr     wait23
                move.w  d0,(a0)
                addq.w  #1,d0
                cmp.w   #$50,d0
                bne.s   vol_down1
                rts
                
timer_b:        andi    #$f8ff,sr       ;setze Interruptlevel 3
                ori     #$0300,sr
                movem.l d0-a6,-(sp)
                bsr     player+28+4*4
                move.w  timer50,d0
                addq.w  #1,d0
                cmp.w   #50,d0
                bne.s   timer_b1
                clr.w   d0
timer_b1:       move.w  d0,timer50
                movem.l (sp)+,d0-a6
                bclr    #0,$fffffa0f.w
                addq.w  #1,count
                rte


init:           move.w  #$200b,$ffff8932.w ;DSP-Out-> DAC & DMA-In
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

                add.l   #8000,d0
                move.l  d0,d1
                move.b  d1,$ffff8913.w  ;End Low
                lsr.l   #8,d1
                move.b  d1,$ffff8911.w  ;End Mid
                lsr.l   #8,d1
                move.b  d1,$ffff890f.w  ;End High

                move.b  #$b0,$ffff8901.w ;repeated record

                lea     SaveArea,a0
                move.l  timer_int.w,(a0)+
                move.b  tbcr.w,(a0)+
                move.b  tbdr.w,(a0)+
                move.b  #246,tbdr.w
                move.b  #7,tbcr.w
                move.l  #timer_b,timer_int.w
                bset    #0,imra.w
                bset    #0,iera.w

                rts

off:            clr.b   $ffff8901.w     ;DMA-Stop
                bclr    #0,iera.w
                bclr    #0,imra.w
                lea     SaveArea,a0
                move.l  (a0)+,timer_int.w
                move.b  (a0)+,tbcr.w
                move.b  (a0)+,tbdr.w

                rts


wait23:           move.l  d0,-(sp)
                move.w  count,d0
                addq.w  #3,d0
wait1:          cmp.w   count,d0
                bne.s   wait1
                move.l  (sp)+,d0
                rts

;**************************************

savesp		ds.l	1

count:          ds.w 1
SaveArea:       ds.b 6

timer50:        dc.w 0

dma_buffer:     ds.b 8000

player:         incbin 'D:\DSP56001\DSPMOD\DSPMOD.BSW'

;**************************************
