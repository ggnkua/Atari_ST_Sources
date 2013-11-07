.:              addq.l  #1,$00000466
                subq.w  #1,$00000452
                bmi     .
                movem.l D0-A6,-(A7)
                addq.l  #1,$00000462
                move.w  $00000454,D7
                beq     65535+0+402
                subq.l  #1,D7
                movea.l $00000456.w,A0
.:              movea.l (A0)+,A1
                cmpa.l  #0,A1
                beq.s   .
                movem.l D7-A0,-(A7)
                jsr     (A1)
                movem.l (A7)+,D7-A0
.:              dbra    D7,.
                ori.b   #6,D0
                ori.b   #$01,D6
ÿÿ:             ori.b   #$FF,D0
                ori.b   #$06,D0
                ori.b   #$22,D0
                ???
                ori.b   #$06,D0
                ori.b   #$22,D0
                ???
                ori.b   #6,D0
                ori.b   #.,D6
                btst    D0,-(A2)
                ???
                ori.b   #6,D0
                ori.b   #$01,D6
                ori.b   #\31,D0
                ???

.:
’




"




¥



ÿ
ÿ

ÿ
—
Á

’



.:              ori.b   #$06,D0
                btst    D0,-(A2)
                ori.b   #.,D0
                ori.b   #$00,D0
                ori.b   #$FF,D0
                ori.b   #$04,D0
.:              bclr    D0,(A2)
                ori.b   #255,D0
                ori.b   #$04,D0
.:              bclr    D0,(A2)
                ???
                ori.b   #$04,D0
                ori.b   #$FF,D0
                ori.b   #$00,D4
                ???
.:              ori.b   #$00,D0
ÿÿ:             ori.b   #$02,D0
                ori.b   #.,D0
                ori.b   #$FF,D0
.:              ori.b   #0,D4
.:              bclr    D0,(A2)
                ori.b   #0,D0
                end
