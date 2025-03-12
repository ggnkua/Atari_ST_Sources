                opt D+

* Test fr DSPMOD
* coderight by bITmASTER of TCE  *
* der Oszi funktioniert nur mit 640*480 / 4 Farben !
* Oszicode ist sehr lame

OSZI            equ 1
VblFreq         equ 60                  ;fr Timer


DspModInit      equ 28
DspModOff       equ 32
DspModPlayerOn  equ 36
DspModPlayerOff equ 40
DspModPlayMusic equ 44
DspModPlayTime  equ 48
DspModModType   equ 52
DspModFx        equ 56
not_used        equ 60
DspModFlags     equ 61
DspModSurroundDelay equ 62
DspModDspTracks equ 64
DspModPlayInfos equ 66
DspModSampleSets equ 70

                >PART 'equ'
; 26/08/93

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

                endpart

                move.w  #2,-(sp)
                trap    #14
                addq.l  #2,sp
                move.l  d0,physbase

                pea     txt
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                pea     init
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp

                move.l  ver_ptr,-(sp)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                pea     txt4
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                lea     mod1,a0
                bsr     play_mod

                lea     mod2,a0
                bsr     play_mod

                pea     off
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp
                moveq   #2,d0

                clr.w   -(sp)
                trap    #1


play_mod:       >PART
                lea     voltab4,a1
                bsr     player+DspModModType
                cmp.w   #4,d0
                beq.s   tracks4
                lea     voltab8,a1
tracks4:
                movea.l a0,a6
                bsr     player+DspModPlayerOn ;Start Player

                pea     txt1
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                move.l  a6,-(sp)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                movea.l a6,a0
                bsr     player+DspModPlayTime
                move.w  d0,d7
                move.w  d7,d6
                and.w   #$ff,d6         ;d6 = Sekunden
                lsr.w   #8,d7
                and.w   #$ff,d7         ;d7 = Minuten


                pea     txt2
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                move.w  d7,d0
                bsr     print_bcd

                move.w  #":",-(sp)
                move.w  #2,-(sp)
                trap    #1
                addq.l  #4,sp

                move.w  d6,d0
                bsr     print_bcd

                bsr     print_time
                move.w  #VblFreq,timer

wait_key:       move.w  #2,-(sp)
                move.w  #1,-(sp)        ;Bconstat
                trap    #13
                addq.l  #4,sp

                tst.w   d0
                bne.s   key

wait_timer:     tst.w   timer
                bne.s   wait_key

                move.w  d6,d0
                or.w    d7,d0
                beq.s   wait_key1       ;Timer ist Null

                move.b  #$99,d0
                abcd    d0,d6           ;Sekunden -1
                cmp.b   d0,d6           ;Unterlauf ?
                bne.s   wait_key1       ;nein
                move.w  #$59,d6         ;Sekunden = 59
                abcd    d0,d7           ;Minuten -1

wait_key1:      bsr     print_time
wait_s:         tst.w   timer
                beq.s   wait_s
                bra     wait_key

key:            move.w  #2,-(sp)
                move.w  #2,-(sp)        ;Bconin
                trap    #13
                addq.w  #4,sp
r:

                cmp.b   #" ",d0
                beq.s   exit
                cmp.b   #"s",d0
                bne.s   interpolate
                bchg    #0,player+DspModFlags
                bra.s   wait_timer

interpolate:    cmp.b   #"i",d0
                bne.s   wait_timer
                bchg    #1,player+DspModFlags
                bra     wait_timer

exit:           bsr     VolDown
                bsr     player+DspModPlayerOff ;Stop

                rts
                endpart

txt:            dc.b $1b,"E","DSP-Replay by bITmASTER, ",0
txt1:           dc.b $1b,"Y",35,32,"now playing: ",0
txt2:           dc.b $1b,"Y",35,40+32,"Play-Time: ",0
txt3:           dc.b $1b,"Y",35,60+32,0
txt4:           dc.b $0a,$0d
                dc.b "Surround: s",$0a,$0d
                dc.b "Interpolate: i",0

                even

print_bcd:      >PART
                move.l  d0,-(sp)
                move.l  d0,-(sp)
                lsr.w   #4,d0
                and.w   #$0f,d0
                add.w   #$30,d0
                move.w  d0,-(sp)
                move.w  #2,-(sp)
                trap    #1
                addq.l  #4,sp
                move.l  (sp)+,d0
                and.w   #$0f,d0
                add.w   #$30,d0
                move.w  d0,-(sp)
                move.w  #2,-(sp)
                trap    #1
                addq.l  #4,sp
                move.l  (sp)+,d0
                rts
                endpart

print_time:     >PART
                pea     txt3
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                move.w  d7,d0           ;Minuten
                bsr     print_bcd

                move.w  #":",-(sp)
                move.w  #2,-(sp)
                trap    #1
                addq.l  #4,sp

                move.w  d6,d0           ;Sekunden
                bsr     print_bcd
                rts
                endpart

VolDown:        >PART
                moveq   #8-1,d0
                moveq   #0,d1
                movea.l player+DspModSampleSets,a0 ;Zeiger auf Sample-Sets
VolDown1:       bsr     wait
                move.w  24(a0),d2
                sub.w   #$0700,d2
                bpl.s   VolDown2
                moveq   #0,d2
                addq.w  #1,d1
VolDown2:       move.w  d2,24(a0)
                adda.w  #28,a0
                dbra    d0,VolDown1
                cmp.w   #8,d1
                bne.s   VolDown
                rts
                endpart

vbl:            >PART
                movem.l d0-a6,-(sp)
                bsr     player+44

                if OSZI

                lea     oszi,a0
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
                sub.l   #820*4,d0       ;16.6ms zurck
                bpl.s   ok
                add.l   #8000,d0
ok:             add.l   #dma_buffer,d0
                movea.l d0,a0
                lea     oszi,a1
                moveq   #0,d0
loop1:          move.w  #$8000,d2
                moveq   #16-1,d1
loop2:          move.b  (a0),d4         ;links
                move.b  2(a0),d5        ;rechts
                adda.w  #12,a0          ;3 Samples weiter
                cmpa.l  #dma_buffer+8000,a0
                bcs.s   m1
                suba.l  #8000,a0
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
                adda.w  #64*160,a1
                move.w  #256-1,d0
zeile:          moveq   #16-1,d1
spalte:         move.w  (a0)+,(a1)+
                addq.w  #2,a1
                dbra    d1,spalte
                adda.w  #160-16*4,a1
                dbra    d0,zeile
                endc

                subq.w  #1,timer
                bpl.s   m2
                move.w  #VblFreq-1,timer
m2:

                addq.w  #1,count
                movem.l (sp)+,d0-a6
                move.l  old_vbl,-(sp)
                rts                     ;weiter in TOS-VBL
                endpart

init:           >PART
                bsr     player+DspModInit ;install Player
                move.l  a0,ver_ptr

                move.w  #$200b,$ffff8932.w ;DSP-Out-> DAC & DMA-In
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


                move.l  $70.w,old_vbl
                move.l  #vbl,$70.w

                rts

                endpart

off:            >PART
                clr.b   $ffff8901.w     ;DMA-Stop
                move.l  old_vbl,$70.w

                bsr     player+DspModOff ;aus
                rts
                endpart

wait:           move.l  d0,-(sp)
                move.w  count,d0
                addq.w  #3,d0
wait1:          cmp.w   count,d0
                bne.s   wait1
                move.l  (sp)+,d0
                rts

                data

voltab4:        dc.w $7fff,$7fff,$7fff,$7fff
                dc.w 0,0,0,0
voltab8:        dc.w $3fff,$3fff,$3fff,$3fff
                dc.w $3fff,$3fff,$3fff,$3fff

timer:          dc.w 0

;                path 'C:\PC\SOURCE\DSP_MOD\'
                path 'C:\DSPMOD'
player:         ibytes 'DSPMOD.TCE'
                path 'D:\MOD\'
mod1:           ibytes 'BLUESTAR.MOD'   ;'MEGAWORL.MOD'
                path 'D:\MOD.8'
mod2:           ibytes 'LFOVER.MOD'
                bss

ver_ptr:        ds.l 1
count:          ds.w 1
old_vbl:        ds.l 1
physbase:       ds.l 1
vbl_slot:       ds.l 1
dma_buffer:     ds.b 8000
oszi:           ds.w 16*256
                end
