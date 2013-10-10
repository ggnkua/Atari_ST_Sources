setikbd: move.l #keyint,$0118.w
rts
sendikbd: tst.b $FFFFFC02.w
btst #0,$FFFFFC00.w
bne.s sendikbd
move.b D0,$FFFFFC02.w
rts
keyint: move.l D0,-(SP)
keyint1: move.b $FFFFFC00.w,D0
tst.b $FFFFFC06.w
btst #7,D0
beq no_key
btst #0,D0
beq no_key
move.b $FFFFFC02.w,D0
cmp.b #$38,D0
bne.s k1
st alt
moveq #0,D0
k1: cmp.b #$38+128,D0
bne.s k2
sf alt
moveq #0,D0
k2: cmp.b #$2A,D0
bne.s k3
st shift
moveq #0,D0
k3: cmp.b #$2A+128,D0
bne.s k4
sf shift
moveq #0,D0
k4: cmp.b #$1D,D0
bne.s k4a
st ctrl
moveq #0,D0
k4a: cmp.b #$1D+128,D0
bne.s k4b
sf ctrl
moveq #0,D0
k4b:
tst.b D0
bpl.s *+2
moveq #0,D0
move.b ttab(PC,D0.w),key+3
move.b ttab(PC,D0.w),lastkey+3
tst.w shift
beq.s k5
add.w #ttabs-ttab,D0
move.b ttab(PC,D0.w),key+3
move.b ttab(PC,D0.w),lastkey+3
k5:
move.b D0,key+1
move.b D0,lastkey+1
move.w #20,rpt
btst #4,$FFFFFA01.w
bne keyint1
no_key: move.l (SP)+,D0
rte
lastkey: DC.L 0
key: DC.L 0
ctrl: DC.W 0
shift: DC.W 0
alt: DC.W 0
rpt: DC.W 0
keytab:
ttab: DC.B 0,"1234567890z' qwertzuiop?+ asdfghjkl”„ yxcvbnm .- "
DC.B '         '
DS.B 256,' '
ttabs: DC.B 0,'!"Y$%&/()=?` QWERTZUIOPs* ASDFGHJKL™Z YXCVBNM :_ '
DC.B '         '
DS.B 256,' '