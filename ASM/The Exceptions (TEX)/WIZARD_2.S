;Sample program for 'standing' raster interrupts
;by Udo (TEX)
;for SEKA 1.5 or higher

x:
   move.l #0,-(sp)         ;Supervisor on
   move.w #$20,-(sp)
   trap   #1
   addq.l #6,sp
   move.l d0,savereg
   move.l #$78000,a7
   line_a $a               ;Mouse off

   move.w #4,-(sp)         ;Get old resolution
   trap   #14
   addq.l #2,sp
   move.w d0,oldrez

   move.l #$ff8240,a0      ;Mark old palette
   move.l #oldpal,a1
   movem.l (a0),d0-d7
   movem.l d0-d7,(a1)

   bsr    prepare          ;Prepare screen fill pattern
   bsr    hblon            ;HBL Routine on
   bsr    sub1             ;wait for 'ESC'
   bsr    hbloff           ;HBL Routine off

goon:
   move.l #oldpal,a0       ;Set old palette
   move.l #$ff8240,a1
   movem.l (a0),d0-d7
   movem.l d0-d7,(a1)
   move.w oldrez,-(sp)     ;Set old resolution
   move.l #-1,-(sp)
   move.l #-1,-(sp)
   move.w #5,-(sp)
   trap   #14
   add.l  #12,sp

   line_a $9               ;Mouse on
   move.l savereg,-(sp)    ;Supervisor off
   move.w #$20,-(sp)
   trap   #1
   addq.l #6,sp

   clr.l -(sp)             ;terminate
   trap  #1

oldrez: dc.w 0
savereg: dc.l 0
oldpal: blk.w 16,0

;-----------------------------
hblon:
   move.l $120.w,oldtb             ;Save old values
   move.l $118.w,oldkey
   move.l $118.w,newkey2+2
   move.l $70.w,old4
   move.l $70.w,new4b+2
   move.b $fffffa07.w,old07
   move.b $fffffa09.w,old09
   move.b $fffffa13.w,old13
   move.b $fffffa15.w,old15
   move.b $fffffa1b.w,old1b

   move.l #contr,a0
   and.b  #$df,$fffffa09.w         ;Timer C off
   and.b  #$fe,$fffffa07.w
   move.b (a0)+,d0
   cmp.b  #21,d0
   bne    noinst
   move.l #newtb,$120.w            ;install new vectors
   move.l #new4,$70.w
   move.l #newkey,$118.w
   or.b   #1,$fffffa07.w           ;Timer B on
   or.b   #1,$fffffa13.w
noinst:
   rts

hbloff:
   move.w sr,-(sp)
   move.w #$2700,sr
   move.b contr+1,d0
   cmp.b  #4,d0
   bne    noex
   move.b old07,$fffffa07.w        ;Reset old values
   move.b old09,$fffffa09.w
   move.b old13,$fffffa13.w
   move.b old15,$fffffa15.w
   move.b old1b,$fffffa1b.w

   move.l oldtb,$120.w             ;Reset old vectors
   move.l oldkey,$118.w
   move.l old4,$70.w
noex:
   move.w (sp)+,sr
   rts

old4: dc.l 0
oldtb: dc.l 0
oldkey: dc.l 0
old07: dc.b 0
old09: dc.b 0
old13: dc.b 0
old15: dc.b 0
old1b: dc.b 0
even

new4:                           ;New level 4 routine
   movem.l d0-d7,-(sp)
   move.b  #0,$fffffa1b.w       ;Keep timer
   move.b  distanz,$fffffa21.w  ;Set data register
   move.b  #8,$fffffa1b.w       ;start Timer
   movem.l palette,d0-d7        ;Set first palette
   movem.l d0-d7,$ffff8240.w
   move.l  palstart,pal         ;Install start values
   move.l  disstart,dis
   addq.l  #1,dis
   add.l   #32,pal
   movem.l (sp)+,d0-d7
new4b:
   jmp    $000000

newkey:                         ;Disable keyboard interrupt
   move.w #$2500,sr
newkey2:
   jmp    $000000

newtb:
   clr.b   $fffffa1b.w            ;Timer stop
   movem.l d0/d3-d7/a0-a6,-(sp)
   move.l  dis,a0
   move.w  #$fa21,a4
   move.b  (a0)+,(a4)             ;Set next offset value
   move.b  #8,-6(a4)
   move.l  a0,dis

   move.l  pal,a6             ;Prepare palette
   movem.l 2(a6),d4-d7/a0-a2
   move.w  #$8240,a5
   move.w  30(a6),d3
   move.b  (a4),d0            ;Wait for right border
wait:
   cmp.b   (a4),d0
   beq     wait
   movem.l d4-d7/a0-a2,2(a5)  ;Set colors as fast as possible
   move.w  d3,30(a5)
   move.w  (a6),(a5)          ;Set border color during blank
   add.l   #32,pal

   movem.l (sp)+,d0/d3-d7/a0-a6
   bclr    #0,$fffffa0f.w     ;End of interrupt
   rte

palstart: dc.l palette
disstart: dc.l distanz
contr: dc.b 21,4,15,06
pal: dc.l 0
dis: dc.l 0

distanz: dc.b 19,20,20,20,20,20,20,20,240
even

palette: dc.w $000,$001,$002,$003,$004,$005,$006,$007 ;0
         dc.w $010,$011,$012,$013,$014,$015,$016,$017
         dc.w $020,$021,$022,$023,$024,$025,$026,$027 ;1
         dc.w $030,$031,$032,$033,$034,$035,$036,$037
         dc.w $040,$041,$042,$043,$044,$045,$046,$047 ;2
         dc.w $050,$051,$052,$053,$054,$055,$056,$057
         dc.w $060,$061,$062,$063,$064,$065,$066,$067 ;3
         dc.w $070,$071,$072,$073,$074,$075,$076,$077
         dc.w $700,$701,$702,$703,$704,$705,$706,$707 ;4
         dc.w $710,$711,$712,$713,$714,$715,$716,$717
         dc.w $720,$721,$722,$723,$724,$725,$726,$727 ;5
         dc.w $730,$731,$732,$733,$734,$735,$736,$737
         dc.w $740,$741,$742,$743,$744,$745,$746,$747 ;6
         dc.w $750,$751,$752,$753,$754,$755,$756,$757
         dc.w $760,$761,$762,$763,$764,$765,$766,$767 ;7
         dc.w $770,$771,$772,$773,$774,$775,$776,$777
         dc.w $000,$700,$730,$750,$770,$470,$070,$075 ;8
         dc.w $077,$057,$027,$007,$507,$707,$704,$777

;-----------------------------
prepare:
   move.w #0,-(sp)                 ;Set low res
   move.l #-1,-(sp)
   move.l #-1,-(sp)
   move.w #5,-(sp)
   trap   #14
   add.l  #12,sp

   move.l $44e,a1                  ;Set screen address
   move.l #data,a0
   move.w #199,d0

loop:                           ;Fill screen with fill pattern
   movem.l (a0),d1-d7/a2-a4
   movem.l d1-d7/a2-a4,(a1)
   movem.l 40(a0),d1-d7/a2-a4
   movem.l d1-d7/a2-a4,40(a1)
   movem.l 80(a0),d1-d7/a2-a4
   movem.l d1-d7/a2-a4,80(a1)
   movem.l 120(a0),d1-d7/a2-a4
   movem.l d1-d7/a2-a4,120(a1)
   add.l   #160,a1
   dbf     d0,loop
   rts

data:                           ;Fill pattern
dc.w    $0000,$0000,$0000,$0000,$0FFF,$0000,$0000,$0000
dc.w    $FF00,$00FF,$0000,$0000,$000F,$FFFF,$0000,$0000
dc.w    $FFFF,$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000
dc.w    $0FFF,$0000,$FFFF,$0000,$FF00,$00FF,$FFFF,$0000
dc.w    $000F,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
dc.w    $0000,$0000,$0000,$FFFF,$0FFF,$0000,$0000,$FFFF
dc.w    $FF00,$00FF,$0000,$FFFF,$000F,$FFFF,$0000,$FFFF
dc.w    $FFFF,$FFFF,$0000,$FFFF,$0000,$0000,$FFFF,$FFFF
dc.w    $0FFF,$0000,$FFFF,$FFFF,$FF00,$00FF,$FFFF,$FFFF
dc.w    $000F,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

;-----------------------------
sub1:                           ;wait for 'ESC'
   move.w #7,-(sp)
   trap   #1
   addq.l #2,sp
   swap   d0
   cmp.b  #1,d0
   bne    sub1
   rts

