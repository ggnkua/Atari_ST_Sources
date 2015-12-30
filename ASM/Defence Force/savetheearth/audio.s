 
 SECTION TEXT
 
 even
     
; How to use the Microwire/LMC1992:
; http://alive.atari.org/alive11/mcrowire.php
; http://www.atari-forum.com/wiki/index.php/Atari_STE_FAQ_compiled_by_The_Paranoid_/_Paradox 

;Master Volume: d d d  d d d  (all 6 bits used)
;                     0 0 0  0 0 0  = -80 db volume
;                     0 1 0  1 0 0  = -40 db volume
;                     1 0 1  x x x  =   0 db volume (max)
;      Each increment represents 2 db. If the 3 left bit encode "101",
;      the last 3 bits are being ignored.
;
;      Left channel:  x d d  d d d  (left bit ignored)
;                       0 0  0 0 0  = -40 db volume
;                       0 1  0 1 0  = -20 db volume
;                       1 0  1 x x  =   0 db volume (max)
;      Each increment represents 2 db. If the 3 left bit carry "101",
;      the last 2 bits are being ignored.
;      
;      Right channel: x d d  d d d  (left bit ignored)
;                       0 0  0 0 0  = -40 db volume
;                       0 1  0 1 0  = -20 db volume
;                       1 0  1 x x  =   0 db volume (max)
;      Each increment represents 2 db. If the left 3 bit are "101",
;      the last 2 bits are being ignored.
 

; Device adress:
; - LMC1992         '10'
;
; Command:
; - Mixer           '000'
; - Bass            '001'
; - Treble          '010'
; - Master volume   '011'
; - Right volume    '100'
; - Left volume     '101'
;

LMC_MIXER		equ %10000000000
LMC_BASS		equ %10001000000
LMC_TREBLE		equ %10010000000
LMC_MASTERVOL	equ %10011000000
LMC_RIGHTVOL	equ %10100000000
LMC_LEFTVOL		equ %10101000000

 
; d0=data to send
SetMixer
 move.w sr,-(sp)
 move.w #$2700,sr                           ;interrupts off during start of operation
 
 move.w #%11111111111,$ffff8924.w           ;set microwiremask
 move.w d0,$ffff8922.w
.waitstart
 cmpi.w #%11111111111,$ffff8924.w           ;wait formicrowire write to start
 beq.s .waitstart
 move.w (sp)+,sr                            ;now microwire write started we can safely re-enable interrupts
.waitend
 cmpi.w #%11111111111,$ffff8924.w           ;wait for microwire write to finish
 bne.s .waitend
 rts
 
 
 
 
InitMixer 
 move.w	#LMC_MIXER+%000001,d0		; mix DMA+YM equally
 bsr.s SetMixer
 move.w	#LMC_BASS+%000110,d0		; +0db bass
 bsr.s SetMixer
 move.w	#LMC_TREBLE+%000110,d0		; +0db treble
 bsr.s SetMixer
 move.w	#LMC_MASTERVOL+%101000,d0	; -0db master volume
 bsr.s SetMixer
 move.w	#LMC_RIGHTVOL+%010100,d0	; -0db right
 bsr.s SetMixer
 move.w	#LMC_LEFTVOL+%010100,d0		; -0db left
 bsr.s SetMixer
 rts
 

FadeAudioOut
 move.w #%101000,d1
.loop 
 subq.w #1,d1
 move.w d1,d0
 add.w #LMC_MASTERVOL,d0
 bsr SetMixer
 bsr WaitVbl
 bsr WaitVbl
 bsr WaitVbl
 tst.w d1
 bne.s .loop
 rts 
  

 
 
 even
 
; Audio DMA issues here:
; http://atari-ste.anvil-soft.com/html/devdocu4.htm 
; a0=sample start
; a1=sample end
; return d0=approximate duration in VBLs
StartReplay
 movem.l a0/a1/d1,-(sp)
 
 move.l a1,d0
 sub.l a0,d0				; Size in bytes
 lsr.l #8,d0				; /256 (12517 khz=12517 bytes per second=250.34 bytes per VBL)
 
 move.l a0,d1				; Start adress
 
 lea $ffff8900.w,a0
 
 move.b d1,$7(a0)			; $ffff8907.w Dma start adress (low)
 lsr.l #8,d1
 move.b d1,$5(a0)			; $ffff8905.w Dma start adress (mid)
 lsr.l #8,d1
 move.b d1,$3(a0)			; $ffff8903.w Dma start adress (high)

 move.l a1,d1				; End adress
 move.b d1,$13(a0)			; $ffff8913.w Dma end adress (low)
 lsr.l #8,d1
 move.b d1,$11(a0)			; $ffff8911.w Dma end adress (mid)
 lsr.l #8,d1
 move.b d1,$f(a0)			; $ffff890f.w Dma end adress (high)
   
 move.b #1+128,$21(a0)		; $ffff8921.w DMA mode (128=mono) (0=6258,1=12517,2=25033,3=50066)
 move.b #1,$1(a0)			; $ffff8901.w DMA control (0=stop, 1=play once, 2=loop)

 movem.l (sp)+,a0/a1/d1
 rts

   
EndReplay
 lea $ffff8900.w,a0
 move.b #0,1(a0)			; $ffff8901.w DMA Control
 rts
  

 
; Xia code

dmaplay_numframesperblock equ 5+6+5+6	; 22

; a0=sequence start
; a1=Sample sequence adresses
DmaSequencePlayerInit
 move.l a0,_AdrDmaPlayPosition
 move.l a0,_AdrDmaPlayStart
 move.l a1,_AdrDmaAddressTable
 move.w #0,dmaplay_sequence_index
 move.w #1,dmaplay_waitcounter
 rts

DmaSequencePlayerVbl
 ;move.w #$777,$ffff8240.w
 subq.w #1,dmaplay_waitcounter
 bne.s .exit
 
.next_sequence
 addq.w #1,dmaplay_sequence_index
 
 move.l a6,-(sp)
 move.l d0,-(sp)
 
 move.w #dmaplay_numframesperblock,dmaplay_waitcounter
_AdrDmaPlayPosition=*+2 
 lea $123456,a6
 moveq.l #0,d0 ; maybe this could be removed for optimization?
 move.b (a6),d0
 bmi.s .loop
 
.continue
 lsl.w #2,d0
_AdrDmaAddressTable=*+2 
 lea $123456,a6
 move.l (a6,d0.l),d0
 
 ; Stop the sample
 lea $ffff8901.w,a6
 sf.b (a6)					; $ffff8901.w DMA control (0=stop, 1=play once, 2=loop)

 ; Set the new adress
 movep.l d0,(a6)
 add.l #11000,d0
 movep.l d0,$0d-1(a6)
 move.b #128+2,$21-1(a6)	; $ffff8921.w DMA mode (128=mono) (0=6258,1=12517,2=25033,3=50066)
 move.b #1,(a6)				; $ffff8901.w DMA control (0=stop, 1=play once, 2=loop)
	
 addq.l #1,_AdrDmaPlayPosition

 move.l (sp)+,d0
 move.l (sp)+,a6
.exit	
 ;move.w #$000,$ffff8240.w
 rts

.loop
 ;loop the song
_AdrDmaPlayStart=*+2 
 lea $123456,a6
 move.l a6,_AdrDmaPlayPosition
 move.b (a6),d0
 bra.s .continue
 
 
 section DATA
 
 even


 section BSS
 

dmaplay_sequence_index	ds.w 1
dmaplay_waitcounter		ds.w 1 ; set this to 1 to make the music start playing immediately on execution
