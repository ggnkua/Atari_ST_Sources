; Mad Max Music Driver

; By Grazey Of The P?????.H??????.F?????.

; See Bottom Of file for filenames and credits

; If ya use this zak credit the hacker!

; Bar code By GRAZEY

	opt	x+
	clr.l	-(sp)			;Super mode
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,oldstk			
	bclr	#0,$484.w		;Kill click	

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,col
	clr.w	$ffff8240.w
	jsr	bars(pc)

	moveq	#1,d0
	bsr	music
;	bsr	music+4			Insert this line for 3D Doc music
	bsr	music+8

	move.l	$70.w,old70		;Save old vbl
	move.l	#grazey,$70.w		;Install my new vbl	

	move.w	#8,-(sp)		;Wait for a key press	
	trap	#1				 	
	lea	2(sp),sp				 

	move.l old70,$70.w		;Restore old vbl
	move.l #$08080000,$ffff8800.w	;Clear sound registers	
	move.l #$09090000,$ffff8800.w		
	move.l #$0a0a0000,$ffff8800.w		
	movem.l	col,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr	d0
	bsr	music			

	move.l oldstk,-(sp)			

	move.w	#$20,-(sp)		;User mode	
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)			;See yooo	
	trap	#1		
			
grazey	movem.l	d0-a6,-(sp)
	jsr	music+8(pc)
	jsr	bars+186(pc)
	jsr	bars+298(pc)
	movem.l	(sp)+,d0-a6
	move.l	old70,-(sp)
	rts

oldstk	dc.l	0
old70	dc.l	0
col	ds.l	8
bars	incbin	"bars.bin"	

music	incbin	"shaolin.mus"
zx

;	Name							Hacker Tunes
;--------------------------------------------------------------------------
;	3ddoc.mus	Cuddy 3D Doc, Original By Matt Gray	Grazey	1
;	Atomino.mus						Grazey	1
;	Atomix.mus						Grazey	1
;	Axelf.mus						Grazey	1
;	Bach.mus						Grazey	1
;	Chambscp.mus	Tune 1 By Jeroen Tel			Grazey	2
;	Charts_4.mus						Grazey	3
;	Circus10						Grazey	9
;	Confed_2.mus						Grazey	2
;	cud_bs.mus	Cuddly Demos				Zippy	1
;	cud_eh.mus						Zippy	1
;	cud_mm.mus						Zippy	1
;	cud_res.mus						Zippy	1
;	dragon5.mus						Grazey	5
;	gianamix.mus	Original By Chris Huelsbeck,GGS/Shades	Grazey	1
;	greatc2.mus	Pro Tennis Tour 2			Grazey	1
;	high_scr.mus	Pre-Historic Tale			Mug Uk	1
;	in_game1.mus	Pre-Historic Tale			Mug Uk	1
;	in_game2.mus	Pre-Historic Tale			Grazey	1
;	in_game3.mus	Pre-Historic Tale			Grazey	1
;	jamb_2.mus	7 Gates Of Jambala			Grazey	2
;	jamb_10.mus	7 Gates Of Jambala			Grazey	10
;	larrymnu.mus	Comic Bakery By Martin Galway		Grazey	1
;	land_lv1.mus	Enchanted Land			Sewer Hedgehog	1
;	land_lv2.mus	Enchanted Land			Sewer Hedgehog	1
;	land_lv3.mus	Enchanted Land				Grazey	1
;	land_lv4.mus	Enchanted Land			Sewer Hedgehog	1
;	land_lv5.mus	Enchanted Land			Sewer Hedgehog	1
;	land_lv6.mus	Enchanted Land			Sewer Hedgehog	1
;	land_tcb.mus	Enchanted Land				Grazey	1
;	maddy.mus						Grazey	1
;	maddy2.mus						Grazey	1
;	maddy3.mus						Grazey	1
;	maddy4.mus						Grazey	1
;	maddy5.mus						Grazey	1
;	maddy6.mus						Grazey	1
;	maddy7.mus						Grazey	1
;	maddy8.mus						Grazey	1
;	maddy9.mus						Grazey	1
;	maddya.mus						Grazey	1
;	mainmenu.mus	Pre-Historic Tale,also Maggie music	Grazey	1
;	medusa1.mus	Rings Of Medusa				Grazey	1
;	medusa2.mus	     "					Grazey	1
;	mindbmm.mus						Grazey	1
;	moonsup.mus						Grazey	1
;	pablo.mus	Pablo & The Gold Of Montezuma		Grazey	6
;	rings2_1	Return to Medusa			Grazey	1
;	rings2.mus	Return To Medusa			Grazey	2
;	s_fx.mus	Pre-Historic Tale			Mug Uk	8
;	shaolin.mus	Chambers Of Shaolin			Grazey	1
;	shaolin2.mus	Chambers Of Shaolin			Grazey	1
;	shaolin3.mus	Chambers Of Shaolin			Grazey	1
;	so_what.mus	So Watt Demo				Zippy	1
;	sowhat2.mus	So Watt Demo				Zippy	1
;	sowhat3.mus	So Watt Demo				Zippy	1
;	sowhat4.mus	So Watt Demo				Zippy	1
;	starblz.mus						Grazey	1
;	storml_4.mus	Stormlord By Jeroen Tel Of M.O.N.	Grazey	4
;	synres.mus						Grazey	1
;	terami_6.mus						Grazey	6
;	thalin_2.mus						Grazey	3
;	thunderb.mus						Grazey	2
;	turload.mus	Turrican Loader By Chris Huelsbeck	Grazey	1
;	warp1.mus						Grazey	1
;	warp2.mus						Grazey	1
;	warp_8.mus	Tunes 2-8				Grazey	8
