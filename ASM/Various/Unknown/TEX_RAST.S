	move.l    #0,-(sp)
     	move.w    #$20,-(sp)
     	trap      #1
     	addq.l    #6,sp
     	move.l    d0,savereg
     	move.l    #$78000,a7
     	DC.W 	$A00a
     	move.w    #4,-(sp)
     	trap      #14
     	addq.l    #2,sp
     	move.w    d0,oldrez
     	move.l    #$ff8240,a0
     	move.l    #oldpal,a1
     	movem.l   (a0),d0-d7
     	movem.l   d0-d7,(a1)

     	BSR       prepare             ;BILDSCHIRMMUSTER VORARBEITEN
     	BSR       hblon               ;HBL ROUTINE EINSCHALTEN
     	BSR       sub1                ;AUF 'ESC' WARTEN
     	BSR       hbloff              ;HBL ROUTINE AUSSCHALTEN

goon:
     	move.l    #oldpal,a0
     	move.l    #$ff8240,a1
     	movem.l   (a0),d0-d7
     	movem.l   d0-d7,(a1)
     	move.w    oldrez,-(sp)
     	move.l    #-1,-(sp)
     	move.l    #-1,-(sp)
     	move.w    #5,-(sp)
     	trap      #14
     	add.l     #12,sp
     	DC.W      $A009
     	move.l    savereg,-(sp)
     	move.w    #$20,-(sp)
     	trap      #1
     	addq.l    #6,sp

     	ILLEGAL
;     	clr.l     -(sp)
;     	trap      #1

oldrez:   dc.w  	0
savereg:  dc.l  	0
oldpal:   DS.w 	16


hblon:
     	MOVE.L    $120,oldtb
     	MOVE.L    $118,oldkey
     	MOVE.L    $118,newkey2+2
     	MOVE.L    $70,old4
     	MOVE.L    $70,new4b+2
     	MOVE.B    $FFFFFA07,old07
     	MOVE.B    $FFFFFA09,old09
     	MOVE.B    $FFFFFA13,old13
     	MOVE.B    $FFFFFA15,old15
     	MOVE.B    $FFFFFA1B,old1b

     	move.l    #contr,a0
     	and.b     #$df,$fffffa09
     	and.b     #$fe,$fffffa07
     	move.b    (a0)+,d0
     	cmp.b     #21,d0
     	bne       noinst
     	move.l    #newtb,$120
     	move.l    #new4,$70
     	move.l    #newkey,$118
     	or.b      #1,$fffffa07
     	or.b      #1,$fffffa13
noinst:
     	rts

hbloff:
     	move.w    sr,-(sp)
     	move.w    #$2700,sr
     	move.b    contr+1,d0
     	cmp.b     #4,d0
     	bne       noex
     	move.b    old07,$fffffa07
     	move.b    old09,$fffffa09
     	move.b    old13,$fffffa13
     	move.b    old15,$fffffa15
     	move.b    old1b,$fffffa1b
     	move.l    oldtb,$120
     	move.l    oldkey,$118
     	move.l    old4,$70
noex:
     	move.w    (sp)+,sr
     	rts

old4: 	dc.l 	0
oldtb: 	dc.l 	0
oldkey: 	dc.l 	0
old07: 	dc.b 	0
old09: 	dc.b 	0
old13: 	dc.b 	0
old15: 	dc.b 	0
old1b: 	dc.b 	0
 	even

new4:                               ; neue Level 4 Routtine
     	movem.l   d0-d7,-(sp)
     	move.b    #0,$fffffa1b
     	move.b    distanz,$fffffa21
     	move.b    #8,$fffffa1b
     	movem.l   palette,d0-d7
     	movem.l   d0-d7,$ff8240
     	move.l    palstart,pal
     	move.l    disstart,dis
     	addq.l    #1,dis
     	add.l     #32,pal
     	movem.l   (sp)+,d0-d7
new4b:
     	jmp       $000000
newkey:
     	move.w    #$2500,sr
newkey2:
     	jmp       $000000
newtb:
     	clr.b     $fffffa1b
     	movem.l   d0/d3-d7/a0-a6,-(sp)
     	move.l    dis,a0
     	move.w    #$fa21,a4
     	move.b    (a0)+,(a4)
     	move.b    #8,-6(a4)
     	move.l    a0,dis
     	move.l    pal,a6
     	movem.l   2(a6),d4-d7/a0-a2
     	move.w    #$8240,a5
     	move.w    30(a6),d3
     	move.b    (a4),d0
wait:
     	cmp.b     (a4),d0
     	beq       wait
     	movem.l   d4-d7/a0-a2,2(a5)
     	move.w    d3,30(a5)
     	move.w    (a6),(a5)
     	add.l     #32,pal
     	movem.l   (sp)+,d0/d3-d7/a0-a6
     	bclr      #0,$fffffa0f
     	rte

palstart: dc.l 	palette
disstart: dc.l 	distanz
contr: 	dc.b 	21,4,15,06
pal: 	dc.l 	0
dis: 	dc.l 	0
distanz: 	dc.b 	19,20,20,20,20,20,20,20,240
 	even

palette: 	dc.w $000,$001,$002,$003,$004,$005,$006,$007
         	dc.w $010,$011,$012,$013,$014,$015,$016,$017
         	dc.w $020,$021,$022,$023,$024,$025,$026,$027
         	dc.w $030,$031,$032,$033,$034,$035,$036,$037
         	dc.w $040,$041,$042,$043,$044,$045,$046,$047
         	dc.w $050,$051,$052,$053,$054,$055,$056,$057
         	dc.w $060,$061,$062,$063,$064,$065,$066,$067
         	dc.w $070,$071,$072,$073,$074,$075,$076,$077
         	dc.w $700,$701,$702,$703,$704,$705,$706,$707
         	dc.w $710,$711,$712,$713,$714,$715,$716,$717
         	dc.w $720,$721,$722,$723,$724,$725,$726,$727
         	dc.w $730,$731,$732,$733,$734,$735,$736,$737
         	dc.w $740,$741,$742,$743,$744,$745,$746,$747
         	dc.w $750,$751,$752,$753,$754,$755,$756,$757
         	dc.w $760,$761,$762,$763,$764,$765,$766,$767
         	dc.w $770,$771,$772,$773,$774,$775,$776,$777
         	dc.w $000,$700,$730,$750,$770,$470,$070,$075
         	dc.w $077,$057,$027,$007,$507,$707,$704,$777

prepare:
     	move.w    #0,-(sp)
     	move.l    #-1,-(sp)
     	move.l    #-1,-(sp)
     	move.w    #5,-(sp)
     	trap      #14
     	add.l     #12,sp
     	move.l    $44e,a1
     	move.l    #DATAA,a0
     	move.w    #199,d0

loop:
     	movem.l   (a0),d1-d7/a2-a4
     	movem.l   d1-d7/a2-a4,(a1)
     	movem.l   40(a0),d1-d7/a2-a4
     	movem.l   d1-d7/a2-a4,40(a1)
     	movem.l   80(a0),d1-d7/a2-a4
     	movem.l   d1-d7/a2-a4,80(a1)
     	movem.l   120(a0),d1-d7/a2-a4
     	movem.l   d1-d7/a2-a4,120(a1)
     	add.l     #160,a1
     	dbf       d0,loop
     	rts

DATAA:
 	dc.w      $0000,$0000,$0000,$0000,$0FFF,$0000,$0000,$0000
 	dc.w      $FF00,$00FF,$0000,$0000,$000F,$FFFF,$0000,$0000
 	dc.w      $FFFF,$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000
 	dc.w      $0FFF,$0000,$FFFF,$0000,$FF00,$00FF,$FFFF,$0000
 	dc.w      $000F,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
 	dc.w      $0000,$0000,$0000,$FFFF,$0FFF,$0000,$0000,$FFFF
 	dc.w      $FF00,$00FF,$0000,$FFFF,$000F,$FFFF,$0000,$FFFF
	dc.w      $FFFF,$FFFF,$0000,$FFFF,$0000,$0000,$FFFF,$FFFF
 	dc.w      $0FFF,$0000,$FFFF,$FFFF,$FF00,$00FF,$FFFF,$FFFF
 	dc.w      $000F,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

sub1:
     	move.w    #7,-(sp)
    	trap      #1
     	addq.l    #2,sp
     	swap      d0
     	cmp.b     #1,d0
     	bne       sub1
     	rts
     	END