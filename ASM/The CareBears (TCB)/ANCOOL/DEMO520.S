** ASSEMBLERSKOLAN TILL AMZ 2, MAJ 89 **




     ;MEGASCROLLER

x:
        jmp     main(pc)
init_ints:
        move.w  sr,save_sr      ;spara statusregister
        move.l  $70.w,save_vbi  ;spara vbi
        move.l  #vbi,$70.w      ;s„tt vbi
        move.w  #$2300,sr       
        rts
copy_blk:
        move.l  save_sst,a1     ;a1=sk„rmstart
        add.l   #160*8,a1              
        move.l  a1,a6
        move.l  a1,a2
        moveq   #11,d1          ;hur m†nga rader med block
blk_loop:
        moveq   #19,d0          ;hur m†nga block per rad
blk_loop2:
        moveq   #15,d2          ;hur m†nga rader blocket inneh†ller
        lea     block,a0        ;lea grafiken
blk_loop3:
        move.l  (a0)+,(a2)      ;flytta ut grafik
        move.w  (a0)+,4(a2)
        lea     160(a2),a2      ;n„sta scanline
        dbra    d2,blk_loop3
        lea     8(a1),a1        ;n„sta block
        move.l  a1,a2
        dbra    d0,blk_loop2
        lea     15*160(a1),a1   ;n„sta rad
        move.l  a1,a2
        dbra    d1,blk_loop
        lea     atari,a2        ;lea atari logo
        moveq   #11,d1          ;hur m†nga rader  
remove_blk3:
        moveq   #19,d0          ;hur m†nga block per rad
remove_blk2:
        cmp.b   #0,(a2)+        ;rensa?       
        beq     not_blk         ;om inte, hoppa f”rbi
        moveq   #15,d2
        move.l  a6,a0
remove_blk:
        move.l  #0,(a0)         ;rensa grafik
        move.l  #0,4(a0)
        lea     160(a0),a0      ;n„sta scanline
        dbra    d2,remove_blk
not_blk:
        lea     8(a6),a6
        dbra    d0,remove_blk2
        lea     15*160(a6),a6
        dbra    d1,remove_blk3
        rts
copy_screens:
        move.l  save_sst,a6     ;a6=sk„rmstart
        lea     $30000,a1       ;$30000 f”r atari 520ST      
        moveq   #3,d1           ;hur m†nga sk„rmar-1
copy_loop2:
        move.l  a6,a0
        move.l  #7999,d0
copy_loop:
        move.l  (a0)+,(a1)+     ;kopiera sk„rm 1
        dbra    d0,copy_loop
        move.l  a6,a0
        move.l  #7999,d0
copy_loop3:
        move.l  (a0)+,(a1)+     ;kopiera sk„rm 2
        dbra    d0,copy_loop3
        move.l  a6,a0
        lea     31840(a0),a0
        moveq   #79,d0
copy_loop4:
        move.l  (a0)+,(a1)+
        dbra    d0,copy_loop4
        dbra    d1,copy_loop2
        rts
endit:
        move.l  #$80000+32000,currpicadd2       ;†terst„ll pekare
        move.l  #$80000,currpicadd              ;†terst„ll pekare
        moveq   #3,d7
        rts
calculate:
        add.l   #64000,currpicadd      ;addera 2 sk„rmar
        dbra    d7,not_now
        sub.l   #160*8,currpicadd2     ;flytta sk„rmen 8 scanlines
        cmp.l   #$80000,currpicadd2             
        beq.s   endit
        move.l  currpicadd2(pc),currpicadd
        moveq   #3,d7
not_now:
        rts
main:
        move.w  #0,-(sp)               ;initialisera sk„rm
        move.l  #-1,-(sp)
        move.l  #-1,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        pea     0                      ;supervisormode
        move.w  #$20,-(sp)
        trap    #1
        lea     6(sp),sp
        move.l  d0,save_stk            ;spara stack

        move.w  #2,-(sp)        
        trap    #14
        addq.l  #2,sp
        move.l  d0,save_sst            ;h„mta sk„rmstart

        move.l  #text,-(sp)            ;skriv text
        move.w  #$9,-(sp)
        trap    #1
        addq.l  #6,sp

        movem.l $ffff8240.w,d0-d7       ;spara f„rger
        movem.l d0-d7,save_pal
        movem.l pal,d0-d7               ;s„tt f„rger
        movem.l d0-d7,$ffff8240.w

        jsr     copy_blk(pc)            
        jsr     copy_screens(pc)
        jsr     init_ints(pc)

        moveq   #3,d7
        move.w  #0,wfnc
demo_loop:
        cmp.w   #1,wfnc                 ;v„nta p† vsync
        bne.s   demo_loop
        move.w  #0,wfnc
        jsr     calculate(pc)           ;r„kna ut sk„rmpekare
        cmp.b   #185,$fffffc02.w        ;space?
        bne.s   demo_loop

        movem.l save_pal,d0-d7          ;†terst„ll f„rger
        movem.l d0-d7,$ffff8240.w
        move.l  save_vbi(pc),$70.w      ;†terst„ll vbi
        move.w  save_sr(pc),sr          ;†terst„ll sr

        move.l  save_stk(pc),-(sp)      ;ut ut supervisormode
        move.w  #$20,-(sp)
        trap    #1
        lea     6(sp),sp

        clr.w   -(sp)                   ;avsluta 
        trap    #1
vbi:
        move.w  #1,wfnc                 
        move.l  currpicadd(pc),d0       ;s„tt sk„rmpekare
        lsr.l   #8,d0
        move.b  d0,$ffff8203.w
        lsr.w   #8,d0
        move.b  d0,$ffff8201.w
        rte
currpicadd:     dc.l    $30000
currpicadd2:    dc.l    $30000+32000
save_vbi:       dc.l    0
save_sr:        dc.w    0
wfnc:           dc.w    0
save_stk:       dc.l    0
save_sst:       dc.l    0
save_pal:       ds.w    16
pal:                                      ;f„rger
        dc.w    $000,$077,$066,$055,$044,$033,$022,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$700
block:                                    ;grafik
        dc.w    $7FFF,$FFFE,$0001,$3FFF,$FFFC,$0003
        dc.w    $1FFF,$FFF8,$0007,$0ABF,$FAB0,$054F
        dc.w    $02BF,$FAA0,$055F,$02BF,$FA80,$057F
        dc.w    $00BF,$FA80,$057F,$09DF,$FF20,$00FF
        dc.w    $09DF,$FF20,$00FF,$095F,$FE20,$01FF
        dc.w    $112F,$FC10,$03FF,$2117,$F808,$07FF
        dc.w    $C109,$F006,$0FFF,$0007,$E000,$1FFF
        dc.w    $0003,$C000,$3FFF,$0001,$8000,$7FFF
atari:                                    ;atari logo
        dc.b    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    0,0,0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,0,0
        dc.b    0,0,0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,0,0
        dc.b    0,0,0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,0,0
        dc.b    0,0,0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,0,0
        dc.b    0,0,0,0,0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,0
        dc.b    0,0,0,0,0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,0
        dc.b    0,0,0,0,0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,0
        dc.b    0,0,0,0,0,1,0,0,0,1,1,0,0,0,1,0,0,0,0,0
        dc.b    0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,1,0,0,0,0
        dc.b    0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0
        dc.b    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
text:
        dc.b    "*** -4 BitPlane FullScreen Scroller- ***",0

