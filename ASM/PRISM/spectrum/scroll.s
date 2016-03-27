init_car	lea fonte+(16*180),a3
	
	move.l ecran,a5
	lea 160*151(a5),a5
	move.l ecran1,a4
	lea 160*151(a4),a4
	
n1	set 0

	rept 6
	
	move.b n1+7(a4),n1+6(a5)
	move.b n1+14(a4),n1+7(a5)
	move.b n1+15(a4),n1+14(a5)
	move.b n1+22(a4),n1+15(a5)
	move.b n1+23(a4),n1+22(a5)
	move.b n1+30(a4),n1+23(a5)
	move.b n1+31(a4),n1+30(a5)
	move.b n1+38(a4),n1+31(a5)
	move.b n1+39(a4),n1+38(a5)
	move.b n1+46(a4),n1+39(a5)
	move.b n1+47(a4),n1+46(a5)
	move.b n1+54(a4),n1+47(a5)
	move.b n1+55(a4),n1+54(a5)
	move.b n1+62(a4),n1+55(a5)
	move.b n1+63(a4),n1+62(a5)
	move.b n1+70(a4),n1+63(a5)
	move.b n1+71(a4),n1+70(a5)
	move.b n1+78(a4),n1+71(a5)
	move.b n1+79(a4),n1+78(a5)
	move.b n1+86(a4),n1+79(a5)
	move.b n1+87(a4),n1+86(a5)
	move.b n1+94(a4),n1+87(a5)
	move.b n1+95(a4),n1+94(a5)
	move.b n1+102(a4),n1+95(a5)
	move.b n1+103(a4),n1+102(a5)
	move.b n1+110(a4),n1+103(a5)
	move.b n1+111(a4),n1+110(a5)
	move.b n1+118(a4),n1+111(a5)
	move.b n1+119(a4),n1+118(a5)
	move.b n1+126(a4),n1+119(a5)
	move.b n1+127(a4),n1+126(a5)
	move.b n1+134(a4),n1+127(a5)
	move.b n1+135(a4),n1+134(a5)
	move.b n1+142(a4),n1+135(a5)
	move.b n1+143(a4),n1+142(a5)
	move.b n1+150(a4),n1+143(a5)
	move.b n1+151(a4),n1+150(a5)
	move.b n1+158(a4),n1+151(a5)
	move.b n1+159(a4),n1+158(a5)
	move.b (a3)+,n1+159(a5)
	
n1	set n1+160
	
	endr
	
	move.b n1+7(a4),n1+6(a5)
	move.b n1+14(a4),n1+7(a5)
	move.b n1+15(a4),n1+14(a5)
	move.b n1+22(a4),n1+15(a5)
	move.b n1+23(a4),n1+22(a5)
	move.b n1+30(a4),n1+23(a5)
	move.b n1+31(a4),n1+30(a5)
	move.b n1+38(a4),n1+31(a5)
	move.b n1+39(a4),n1+38(a5)
	move.b n1+46(a4),n1+39(a5)
	move.b n1+47(a4),n1+46(a5)
	move.b n1+54(a4),n1+47(a5)
	move.b n1+55(a4),n1+54(a5)
	move.b n1+62(a4),n1+55(a5)
	move.b n1+63(a4),n1+62(a5)
	move.b n1+70(a4),n1+63(a5)
	move.b n1+71(a4),n1+70(a5)
	move.b n1+78(a4),n1+71(a5)
	move.b n1+79(a4),n1+78(a5)
	move.b n1+86(a4),n1+79(a5)
	move.b n1+87(a4),n1+86(a5)
	move.b n1+94(a4),n1+87(a5)
	move.b n1+95(a4),n1+94(a5)
	
	move.w sr,-(sp)
	or.w #$700,sr
	
	lea $ffff8240.w,a0
	
	lea pal_spec,a1
	
	ifeq debug
time2	move.w #$0,$ffff8240.w
	endc	
	
	moveq #16,d1
	
attend	move.b $ffff8209.w,d0
	beq.s attend
	
	sub.l d0,d1
	lsr.w d1,d1
	
	move.b n1+102(a4),n1+95(a5)
	move.b n1+103(a4),n1+102(a5)
	move.b n1+110(a4),n1+103(a5)
	move.b n1+111(a4),n1+110(a5)
	move.b n1+118(a4),n1+111(a5)
	move.b n1+119(a4),n1+118(a5)
	move.b n1+126(a4),n1+119(a5)
	move.b n1+127(a4),n1+126(a5)
	move.b n1+134(a4),n1+127(a5)
	move.b n1+135(a4),n1+134(a5)
	move.b n1+142(a4),n1+135(a5)
	move.b n1+143(a4),n1+142(a5)
	move.b n1+150(a4),n1+143(a5)
	move.b n1+151(a4),n1+150(a5)
	move.b n1+158(a4),n1+151(a5)
	nop
	
loop_spec	spec
	
	move.b n1+159(a4),n1+158(a5)
	move.b (a3)+,n1+159(a5)
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
	nop
	
	spec
	
	move.b n1+14(a4),n1+7(a5)
	move.b n1+15(a4),n1+14(a5)
	move.b n1+22(a4),n1+15(a5)
	
	spec
	
	move.b n1+23(a4),n1+22(a5)
	move.b n1+30(a4),n1+23(a5)
	move.b n1+31(a4),n1+30(a5)
	
	spec
	
	move.b n1+38(a4),n1+31(a5)
	move.b n1+39(a4),n1+38(a5)
	move.b n1+46(a4),n1+39(a5)
	
	spec
	
	move.b n1+47(a4),n1+46(a5)
	move.b n1+54(a4),n1+47(a5)
	move.b n1+55(a4),n1+54(a5)
	
	spec
	
	move.b n1+62(a4),n1+55(a5)
	move.b n1+63(a4),n1+62(a5)
	move.b n1+70(a4),n1+63(a5)
		
	spec
	
	move.b n1+71(a4),n1+70(a5)
	move.b n1+78(a4),n1+71(a5)
	move.b n1+79(a4),n1+78(a5)
		
	spec
	
	move.b n1+86(a4),n1+79(a5)
	move.b n1+87(a4),n1+86(a5)
	move.b n1+94(a4),n1+87(a5)
		
	spec
	
	move.b n1+95(a4),n1+94(a5)
	move.b n1+102(a4),n1+95(a5)
	move.b n1+103(a4),n1+102(a5)
		
	spec
	
	move.b n1+110(a4),n1+103(a5)
	move.b n1+111(a4),n1+110(a5)
	move.b n1+118(a4),n1+111(a5)
		
	spec
	
	move.b n1+119(a4),n1+118(a5)
	move.b n1+126(a4),n1+119(a5)
	move.b n1+127(a4),n1+126(a5)
		
	spec
	
	move.b n1+134(a4),n1+127(a5)
	move.b n1+135(a4),n1+134(a5)
	move.b n1+142(a4),n1+135(a5)
		
	spec
	
	move.b n1+143(a4),n1+142(a5)
	move.b n1+150(a4),n1+143(a5)
	move.b n1+151(a4),n1+150(a5)
		
	spec
	
	move.b n1+158(a4),n1+151(a5)
	move.b n1+159(a4),n1+158(a5)
	move.b (a3)+,n1+159(a5)
	nop
		
	spec
	
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
	move.b n1+14(a4),n1+7(a5)
	move.b n1+15(a4),n1+14(a5)
		
	spec
	
	move.b n1+22(a4),n1+15(a5)
	move.b n1+23(a4),n1+22(a5)
	move.b n1+30(a4),n1+23(a5)
		
	spec
	
	move.b n1+31(a4),n1+30(a5)
	move.b n1+38(a4),n1+31(a5)
	move.b n1+39(a4),n1+38(a5)
		
	spec
	
	move.b n1+46(a4),n1+39(a5)
	move.b n1+47(a4),n1+46(a5)
	move.b n1+54(a4),n1+47(a5)
		
	spec
	
	move.b n1+55(a4),n1+54(a5)
	move.b n1+62(a4),n1+55(a5)
	move.b n1+63(a4),n1+62(a5)
		
	spec
	
	move.b n1+70(a4),n1+63(a5)
	move.b n1+71(a4),n1+70(a5)
	move.b n1+78(a4),n1+71(a5)
		
	spec
	
	move.b n1+79(a4),n1+78(a5)
	move.b n1+86(a4),n1+79(a5)
	move.b n1+87(a4),n1+86(a5)
		
	spec
	
	move.b n1+94(a4),n1+87(a5)
	move.b n1+95(a4),n1+94(a5)
	move.b n1+102(a4),n1+95(a5)
		
	spec
	
	move.b n1+103(a4),n1+102(a5)
	move.b n1+110(a4),n1+103(a5)
	move.b n1+111(a4),n1+110(a5)
		
	spec
	
	move.b n1+118(a4),n1+111(a5)
	move.b n1+119(a4),n1+118(a5)
	move.b n1+126(a4),n1+119(a5)
		
	spec
	
	move.b n1+127(a4),n1+126(a5)
	move.b n1+134(a4),n1+127(a5)
	move.b n1+135(a4),n1+134(a5)
		
	spec
	
	move.b n1+142(a4),n1+135(a5)
	move.b n1+143(a4),n1+142(a5)
	move.b n1+150(a4),n1+143(a5)
		
	spec
	
	move.b n1+151(a4),n1+150(a5)
	move.b n1+158(a4),n1+151(a5)
	move.b n1+159(a4),n1+158(a5)
		
	spec
	
	move.b (a3)+,n1+159(a5)
	nop
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
	move.b n1+14(a4),n1+7(a5)
	
	spec
	
	move.b n1+15(a4),n1+14(a5)
	move.b n1+22(a4),n1+15(a5)
	move.b n1+23(a4),n1+22(a5)
		
	spec
	
	move.b n1+30(a4),n1+23(a5)
	move.b n1+31(a4),n1+30(a5)
	move.b n1+38(a4),n1+31(a5)
		
	spec
	
	move.b n1+39(a4),n1+38(a5)
	move.b n1+46(a4),n1+39(a5)
	move.b n1+47(a4),n1+46(a5)
		
	spec
	
	move.b n1+54(a4),n1+47(a5)
	move.b n1+55(a4),n1+54(a5)
	move.b n1+62(a4),n1+55(a5)
		
	spec
	
	move.b n1+63(a4),n1+62(a5)
	move.b n1+70(a4),n1+63(a5)
	move.b n1+71(a4),n1+70(a5)
	
	spec
	
	move.b n1+78(a4),n1+71(a5)
	move.b n1+79(a4),n1+78(a5)
	move.b n1+86(a4),n1+79(a5)
		
	spec
	
	move.b n1+87(a4),n1+86(a5)
	move.b n1+94(a4),n1+87(a5)
	move.b n1+95(a4),n1+94(a5)
		
	spec
	
	move.b n1+102(a4),n1+95(a5)
	move.b n1+103(a4),n1+102(a5)
	move.b n1+110(a4),n1+103(a5)
		
	spec
	
	move.b n1+111(a4),n1+110(a5)
	move.b n1+118(a4),n1+111(a5)
	move.b n1+119(a4),n1+118(a5)
		
	spec
	
	move.b n1+126(a4),n1+119(a5)
	move.b n1+127(a4),n1+126(a5)
	move.b n1+134(a4),n1+127(a5)
		
	spec
	
	move.b n1+135(a4),n1+134(a5)
	move.b n1+142(a4),n1+135(a5)
	move.b n1+143(a4),n1+142(a5)
		
	spec
	
	move.b n1+150(a4),n1+143(a5)
	move.b n1+151(a4),n1+150(a5)
	move.b n1+158(a4),n1+151(a5)
		
	spec
	
	move.b n1+159(a4),n1+158(a5)
	move.b (a3)+,n1+159(a5)
	nop
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
	
	spec
	
	move.b n1+14(a4),n1+7(a5)
	move.b n1+15(a4),n1+14(a5)
	move.b n1+22(a4),n1+15(a5)
		
	spec
	
	move.b n1+23(a4),n1+22(a5)
	move.b n1+30(a4),n1+23(a5)
	move.b n1+31(a4),n1+30(a5)
		
	spec
	
	move.b n1+38(a4),n1+31(a5)
	move.b n1+39(a4),n1+38(a5)
	move.b n1+46(a4),n1+39(a5)
		
	spec
	
	move.b n1+47(a4),n1+46(a5)
	move.b n1+54(a4),n1+47(a5)
	move.b n1+55(a4),n1+54(a5)
		
	spec
	
	move.b n1+62(a4),n1+55(a5)
	move.b n1+63(a4),n1+62(a5)
	move.b n1+70(a4),n1+63(a5)
		
	spec
	
	move.b n1+71(a4),n1+70(a5)
	move.b n1+78(a4),n1+71(a5)
	move.b n1+79(a4),n1+78(a5)
		
	spec
	
	move.b n1+86(a4),n1+79(a5)
	move.b n1+87(a4),n1+86(a5)
	move.b n1+94(a4),n1+87(a5)
		
	spec
	
	move.b n1+95(a4),n1+94(a5)
	move.b n1+102(a4),n1+95(a5)
	move.b n1+103(a4),n1+102(a5)
		
	spec
	
	move.b n1+110(a4),n1+103(a5)
	move.b n1+111(a4),n1+110(a5)
	move.b n1+118(a4),n1+111(a5)
		
	spec
	
	move.b n1+119(a4),n1+118(a5)
	move.b n1+126(a4),n1+119(a5)
	move.b n1+127(a4),n1+126(a5)
		
	spec
	
	move.b n1+134(a4),n1+127(a5)
	move.b n1+135(a4),n1+134(a5)
	move.b n1+142(a4),n1+135(a5)
		
	spec
	
	move.b n1+143(a4),n1+142(a5)
	move.b n1+150(a4),n1+143(a5)
	move.b n1+151(a4),n1+150(a5)
		
	spec
	
	move.b n1+158(a4),n1+151(a5)
	move.b n1+159(a4),n1+158(a5)
	move.b (a3)+,n1+159(a5)
	nop
		
	spec
	
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
	move.b n1+14(a4),n1+7(a5)
	move.b n1+15(a4),n1+14(a5)

	spec
	
	move.b n1+22(a4),n1+15(a5)
	move.b n1+23(a4),n1+22(a5)
	move.b n1+30(a4),n1+23(a5)
		
	spec
	
	move.b n1+31(a4),n1+30(a5)
	move.b n1+38(a4),n1+31(a5)
	move.b n1+39(a4),n1+38(a5)
		
	spec
	
	move.b n1+46(a4),n1+39(a5)
	move.b n1+47(a4),n1+46(a5)
	move.b n1+54(a4),n1+47(a5)
		
	spec
	
	move.b n1+55(a4),n1+54(a5)
	move.b n1+62(a4),n1+55(a5)
	move.b n1+63(a4),n1+62(a5)
		
	spec
	
	move.b n1+70(a4),n1+63(a5)
	move.b n1+71(a4),n1+70(a5)
	move.b n1+78(a4),n1+71(a5)
		
	spec
	
	move.b n1+79(a4),n1+78(a5)
	move.b n1+86(a4),n1+79(a5)
	move.b n1+87(a4),n1+86(a5)
		
	spec
	
	move.b n1+94(a4),n1+87(a5)
	move.b n1+95(a4),n1+94(a5)
	move.b n1+102(a4),n1+95(a5)
		
	spec
	
	move.b n1+103(a4),n1+102(a5)
	move.b n1+110(a4),n1+103(a5)
	move.b n1+111(a4),n1+110(a5)
		
	spec
	
	move.b n1+118(a4),n1+111(a5)
	move.b n1+119(a4),n1+118(a5)
	move.b n1+126(a4),n1+119(a5)
		
	spec
	
	move.b n1+127(a4),n1+126(a5)
	move.b n1+134(a4),n1+127(a5)
	move.b n1+135(a4),n1+134(a5)
		
	spec
	
	move.b n1+142(a4),n1+135(a5)
	move.b n1+143(a4),n1+142(a5)
	move.b n1+150(a4),n1+143(a5)
		
	spec
	
	move.b n1+151(a4),n1+150(a5)
	move.b n1+158(a4),n1+151(a5)
	move.b n1+159(a4),n1+158(a5)
		
	spec
	
	move.b (a3)+,n1+159(a5)
	nop
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
	move.b n1+14(a4),n1+7(a5)
		
	spec
	
	move.b n1+15(a4),n1+14(a5)
	move.b n1+22(a4),n1+15(a5)
	move.b n1+23(a4),n1+22(a5)
		
	spec
	
	move.b n1+30(a4),n1+23(a5)
	move.b n1+31(a4),n1+30(a5)
	move.b n1+38(a4),n1+31(a5)
		
	spec
	
	move.b n1+39(a4),n1+38(a5)
	move.b n1+46(a4),n1+39(a5)
	move.b n1+47(a4),n1+46(a5)
		
	spec
	
	move.b n1+54(a4),n1+47(a5)
	move.b n1+55(a4),n1+54(a5)
	move.b n1+62(a4),n1+55(a5)
		
	spec
	
	move.b n1+63(a4),n1+62(a5)
	move.b n1+70(a4),n1+63(a5)
	move.b n1+71(a4),n1+70(a5)
		
	spec
	
	move.b n1+78(a4),n1+71(a5)
	move.b n1+79(a4),n1+78(a5)
	move.b n1+86(a4),n1+79(a5)
		
	spec
	
	move.b n1+87(a4),n1+86(a5)
	move.b n1+94(a4),n1+87(a5)
	move.b n1+95(a4),n1+94(a5)
		
	spec
	
	move.b n1+102(a4),n1+95(a5)
	move.b n1+103(a4),n1+102(a5)
	move.b n1+110(a4),n1+103(a5)
		
	spec
	
	move.b n1+111(a4),n1+110(a5)
	move.b n1+118(a4),n1+111(a5)
	move.b n1+119(a4),n1+118(a5)
		
	spec
	
	move.b n1+126(a4),n1+119(a5)
	move.b n1+127(a4),n1+126(a5)
	move.b n1+134(a4),n1+127(a5)
		
	spec
	
	move.b n1+135(a4),n1+134(a5)
	move.b n1+142(a4),n1+135(a5)
	move.b n1+143(a4),n1+142(a5)
		
	spec
	
	move.b n1+150(a4),n1+143(a5)
	move.b n1+151(a4),n1+150(a5)
	move.b n1+158(a4),n1+151(a5)
		
	spec
	
	move.b n1+159(a4),n1+158(a5)
	move.b (a3)+,n1+159(a5)
	nop
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
		
	spec
	
	move.b n1+14(a4),n1+7(a5)
	move.b n1+15(a4),n1+14(a5)
	move.b n1+22(a4),n1+15(a5)
		
	spec
	
	move.b n1+23(a4),n1+22(a5)
	move.b n1+30(a4),n1+23(a5)
	move.b n1+31(a4),n1+30(a5)
		
	spec
	
	move.b n1+38(a4),n1+31(a5)
	move.b n1+39(a4),n1+38(a5)
	move.b n1+46(a4),n1+39(a5)
		
	spec
	
	move.b n1+47(a4),n1+46(a5)
	move.b n1+54(a4),n1+47(a5)
	move.b n1+55(a4),n1+54(a5)
		
	spec
	
	move.b n1+62(a4),n1+55(a5)
	move.b n1+63(a4),n1+62(a5)
	move.b n1+70(a4),n1+63(a5)
		
	spec
	
	move.b n1+71(a4),n1+70(a5)
	move.b n1+78(a4),n1+71(a5)
	move.b n1+79(a4),n1+78(a5)
		
	spec
	
	move.b n1+86(a4),n1+79(a5)
	move.b n1+87(a4),n1+86(a5)
	move.b n1+94(a4),n1+87(a5)
		
	spec
	
	move.b n1+95(a4),n1+94(a5)
	move.b n1+102(a4),n1+95(a5)
	move.b n1+103(a4),n1+102(a5)
		
	spec
	
	move.b n1+110(a4),n1+103(a5)
	move.b n1+111(a4),n1+110(a5)
	move.b n1+118(a4),n1+111(a5)
		
	spec
	
	move.b n1+119(a4),n1+118(a5)
	move.b n1+126(a4),n1+119(a5)
	move.b n1+127(a4),n1+126(a5)
		
	spec
	
	move.b n1+134(a4),n1+127(a5)
	move.b n1+135(a4),n1+134(a5)
	move.b n1+142(a4),n1+135(a5)
		
	spec
	
	move.b n1+143(a4),n1+142(a5)
	move.b n1+150(a4),n1+143(a5)
	move.b n1+151(a4),n1+150(a5)
		
	spec
	
	move.b n1+158(a4),n1+151(a5)
	move.b n1+159(a4),n1+158(a5)
	move.b (a3)+,n1+159(a5)
	nop
		
	spec
	
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
	move.b n1+14(a4),n1+7(a5)
	move.b n1+15(a4),n1+14(a5)
	
	spec
	
	move.b n1+22(a4),n1+15(a5)
	move.b n1+23(a4),n1+22(a5)
	move.b n1+30(a4),n1+23(a5)
		
	spec
	
	move.b n1+31(a4),n1+30(a5)
	move.b n1+38(a4),n1+31(a5)
	move.b n1+39(a4),n1+38(a5)
		
	spec
	
	move.b n1+46(a4),n1+39(a5)
	move.b n1+47(a4),n1+46(a5)
	move.b n1+54(a4),n1+47(a5)
		
	spec
	
	move.b n1+55(a4),n1+54(a5)
	move.b n1+62(a4),n1+55(a5)
	move.b n1+63(a4),n1+62(a5)
		
	spec
	
	move.b n1+70(a4),n1+63(a5)
	move.b n1+71(a4),n1+70(a5)
	move.b n1+78(a4),n1+71(a5)
		
	spec
	
	move.b n1+79(a4),n1+78(a5)
	move.b n1+86(a4),n1+79(a5)
	move.b n1+87(a4),n1+86(a5)
		
	spec
	
	move.b n1+94(a4),n1+87(a5)
	move.b n1+95(a4),n1+94(a5)
	move.b n1+102(a4),n1+95(a5)
		
	spec
	
	move.b n1+103(a4),n1+102(a5)
	move.b n1+110(a4),n1+103(a5)
	move.b n1+111(a4),n1+110(a5)
		
	spec

	move.b n1+118(a4),n1+111(a5)
	move.b n1+119(a4),n1+118(a5)
	move.b n1+126(a4),n1+119(a5)
		
	spec
	
	move.b n1+127(a4),n1+126(a5)
	move.b n1+134(a4),n1+127(a5)
	move.b n1+135(a4),n1+134(a5)
		
	spec
	
	move.b n1+142(a4),n1+135(a5)
	move.b n1+143(a4),n1+142(a5)
	move.b n1+150(a4),n1+143(a5)
		
	spec
	
	move.b n1+151(a4),n1+150(a5)
	move.b n1+158(a4),n1+151(a5)
	move.b n1+159(a4),n1+158(a5)
		
	spec
	
	move.b (a3)+,n1+159(a5)
	nop
n1	set n1+160
	move.b n1+7(a4),n1+6(a5)
	move.b n1+14(a4),n1+7(a5)
		
	spec
	
	move.b n1+15(a4),n1+14(a5)
	move.b n1+22(a4),n1+15(a5)
	move.b n1+23(a4),n1+22(a5)
		
	spec
	
	move.b n1+30(a4),n1+23(a5)
	move.b n1+31(a4),n1+30(a5)
	move.b n1+38(a4),n1+31(a5)
		
	spec
	
	move.b n1+39(a4),n1+38(a5)
	move.b n1+46(a4),n1+39(a5)
	move.b n1+47(a4),n1+46(a5)
		
	spec
	
	move.b n1+54(a4),n1+47(a5)
	move.b n1+55(a4),n1+54(a5)
	move.b n1+62(a4),n1+55(a5)
		
	spec
	
	move.b n1+63(a4),n1+62(a5)
	move.b n1+70(a4),n1+63(a5)
	move.b n1+71(a4),n1+70(a5)
		
	spec
	
	move.b n1+78(a4),n1+71(a5)
	move.b n1+79(a4),n1+78(a5)
	move.b n1+86(a4),n1+79(a5)
		
	spec
	
	move.b n1+87(a4),n1+86(a5)
	move.b n1+94(a4),n1+87(a5)
	move.b n1+95(a4),n1+94(a5)
	
	spec
		
	move.b n1+102(a4),n1+95(a5)
	move.b n1+103(a4),n1+102(a5)
	move.b n1+110(a4),n1+103(a5)
	
	spec
	
	move.b n1+111(a4),n1+110(a5)
	move.b n1+118(a4),n1+111(a5)
	move.b n1+119(a4),n1+118(a5)
	
	spec
	
	move.b n1+126(a4),n1+119(a5)
	move.b n1+127(a4),n1+126(a5)
	move.b n1+134(a4),n1+127(a5)
	
	spec
	
	move.b n1+135(a4),n1+134(a5)
	move.b n1+142(a4),n1+135(a5)
	move.b n1+143(a4),n1+142(a5)
	
	spec
	
	move.b n1+150(a4),n1+143(a5)
	move.b n1+151(a4),n1+150(a5)
	move.b n1+158(a4),n1+151(a5)
	
	movem.l (a1)+,d0-d7
	movem.l d0-d7,(a0)

	movem.l (a1)+,d0-d7
	movem.l d0-d7,(a0)
	
	movem.l (a1)+,d0-d7
	movem.l d0-d7,(a0)

	movem.l (a1),d0-d3
	movem.l d0-d3,(a0)
	
	move.w (sp)+,sr

scroll	move.b n1+159(a4),n1+158(a5)
	move.b (a3)+,n1+159(a5)
	
nextchar	moveq #0,d0	
	
	move.l mes_pnt,a0
	move.b (a0)+,d0
	move.l a0,mes_pnt
	 
	cmp.b #-1,d0
	beq.s again
	
	lsl.l #2,d0
	lea tab_font,a0
	
	move.l (a0,d0.w),init_car+2
	
	rts
	
again	move.l #message,mes_pnt
	bra.s nextchar