;                   Music Analyzer
;               by Roel van de Kraats
;                       1995
;                   DSP Program

;tabsize=8

I_SSIRD 	equ	$000C
I_SSIRDE	equ	$000E

M_BCR		equ	$FFFE
M_PBC		equ	$FFE0
M_PCC		equ	$FFE1
HCR		equ	$FFE8
HSR		equ	$FFE9
HRX		equ	$FFEB
HTX		equ	$FFEB

M_RX		equ	$FFEF
M_CRA		equ	$FFEC
M_CRB		equ	$FFED
M_SR		equ	$FFEE
M_IPR		equ	$FFFF
M_UU		equ	$FFEA	;unused memory

VMAIN		equ	$0040
POINTS		equ	$400

maxncoef	equ	80
ncoef2K 	equ	80
ncoef500	equ	80
ncoef125	equ	80
ncoef30 	equ	64
ncoef48 	equ	48
ncoef78 	equ	32
ncoef126	equ	70
ncoef202	equ	48
ncoef328	equ	32
ncoef528	equ	64
ncoef852	equ	48
ncoef1K4	equ	32
ncoef2K2	equ	80
ncoef3K6	equ	64
ncoef5K8	equ	50
ncoef9K3	equ	32
ncoef15K	equ	25

		ORG	X:0
states		dsm	maxncoef
LeftBuf 	dsm	POINTS*4
RightBuf	dsm	POINTS*4

		ORG	Y:0

;coefficients for fir filter, made using the routines of 'firdemo'

coef2K
;Lowpass Filter, upper frequency: 2000 Hz.
;Sample frequency: 32780 Hz.
;80 coefficients
;Using Bartlett Windowing
		dc $113994,$109896,$0f3253,$0d2894,$0aa9f6,$07ecf0,$052a38,$029722,$0060a5,$fea77d
		dc $fd7dd3,$fce68f,$fcd659,$fd360e,$fde646,$fec37c,$ffaa55,$007b78,$011ea1,$018494
		dc $01a7d6,$018c30,$013d1c,$00cb6f,$004a9c,$ffcde3,$ff65d7,$ff1e76,$fefe10,$ff0503
		dc $ff2e49,$ff70ad,$ffc077,$001140,$0057b3,$008b03,$00a5e2,$00a6ea,$00906e,$0067d2
		dc $003480,$fffeb0,$ffce30,$ffa951,$ff942a,$ff9036,$ff9c60,$ffb560,$ffd66f,$fffa13
		dc $001afd,$0034c4,$004476,$0048dd,$004284,$003377,$001ecb,$000817,$fff2db,$ffe1fc
		dc $ffd769,$ffd3eb,$ffd724,$ffdfbf,$ffebc3,$fff8ee,$00051f,$000ea1,$00146c,$001633
		dc $00145d,$000fdd,$0009f5,$0003ef,$fffee8,$fffb99,$fffa43,$fffab2,$fffc52,$fffe5a
coef500
;Lowpass Filter, upper frequency: 500 Hz.
;Sample frequency: 8195 Hz.
;80 coefficients
;Using Bartlett Windowing
		dc $113994,$109896,$0f3253,$0d2894,$0aa9f6,$07ecf0,$052a38,$029722,$0060a5,$fea77d
		dc $fd7dd3,$fce68f,$fcd659,$fd360e,$fde646,$fec37c,$ffaa55,$007b78,$011ea1,$018494
		dc $01a7d6,$018c30,$013d1c,$00cb6f,$004a9c,$ffcde3,$ff65d7,$ff1e76,$fefe10,$ff0503
		dc $ff2e49,$ff70ad,$ffc077,$001140,$0057b3,$008b03,$00a5e2,$00a6ea,$00906e,$0067d2
		dc $003480,$fffeb0,$ffce30,$ffa951,$ff942a,$ff9036,$ff9c60,$ffb560,$ffd66f,$fffa13
		dc $001afd,$0034c4,$004476,$0048dd,$004284,$003377,$001ecb,$000817,$fff2db,$ffe1fc
		dc $ffd769,$ffd3eb,$ffd724,$ffdfbf,$ffebc3,$fff8ee,$00051f,$000ea1,$00146c,$001633
		dc $00145d,$000fdd,$0009f5,$0003ef,$fffee8,$fffb99,$fffa43,$fffab2,$fffc52,$fffe5a
coef9K3
;Bandpass Filter, lower frequency: 9000 Hz. upper frequency: 10000 Hz.
;Sample frequency: 32780 Hz.
;32 coefficients
;Using Bartlett Windowing
		dc $0f1766,$fc62f6,$f3a95c,$0932de,$06f486,$f45ee8,$ff3076,$0abfa4,$fbba42,$f89379
		dc $071aae,$031b27,$f89647,$00bfeb,$05c40b,$fcd4cb,$fccb48,$03e246,$00c9b7,$fcbd94
		dc $00cb98,$01ff76,$fea267,$ff3729,$012cea,$00071c,$ff545f,$0037a4,$003bcc,$ffd9e2
		dc $fff86c,$0006dd
coef3K6
;Bandpass Filter, lower frequency: 3500 Hz. upper frequency: 3800 Hz.
;Sample frequency: 32780 Hz.
;64 coefficients
;Using Bartlett Windowing
		dc $06ada8,$05076b,$011a95,$fccbf5,$fa1df1,$fa401a,$fd091f,$011628,$047b2c,$05acc3
		dc $04341f,$00db42,$fd422a,$fb14cb,$fb440c,$fd9e5a,$00f3e5,$03af4d,$049645,$035694
		dc $00a051,$fdc6e9,$fc1b62,$fc50ae,$fe31fd,$00c8a3,$02d9a8,$037b59,$027bfb,$006cb6
		dc $fe518f,$fd21a4,$fd5633,$febbf8,$0097cc,$02075d,$026c7f,$01b05a,$004260,$fed93f
		dc $fe1851,$fe4648,$ff35a3,$006550,$0144d2,$01787e,$00fdd0,$002234,$ff5584,$fef1ed
		dc $ff14f2,$ff9a10,$003552,$009cde,$00ab79,$006c11,$000c0f,$ffbeeb,$ffa39d,$ffb939
		dc $ffe641,$000bca,$001817,$000e43


		ORG	Y:2048
buf		dsm	POINTS

leftbuffaddr	ds	1
rightbuffaddr	ds	1
leftspec	ds	14
rightspec	ds	14

coef125
;Lowpass Filter, upper frequency: 125 Hz.
;Sample frequency: 2049 Hz.
;80 coefficients
;Using Bartlett Windowing
		dc $113932,$10983d,$0f3215,$0d287c,$0aaa09,$07ed2e,$052a99,$029799,$006122,$fea7ef
		dc $fd7e2a,$fce6c0,$fcd65f,$fd35e9,$fde5fc,$fec319,$ffa9e8,$007b10,$011e4d,$01845e
		dc $01a7c7,$018c48,$013d55,$00cbc1,$004afb,$ffce40,$ff6625,$ff1eab,$fefe25,$ff04f6
		dc $ff2e1d,$ff706a,$ffc028,$0010f0,$00576d,$008ad1,$00a5cb,$00a6ef,$00908d,$006806
		dc $0034c0,$fffef4,$ffce6c,$ffa97e,$ff9442,$ff9037,$ff9c4a,$ffb539,$ffd63d,$fff9de
		dc $001acc,$00349f,$004460,$0048d9,$004291,$003392,$001eef,$00083f,$fff2ff,$ffe219
		dc $ffd77b,$ffd3f0,$ffd71d,$ffdfaf,$ffebac,$fff8d5,$000507,$000e8e,$001460,$00162e
		dc $00145f,$000fe5,$0009ff,$0003fb,$fffef2,$fffba0,$fffa47,$fffab3,$fffc51,$fffe5a
coef15K
;Bandpass Filter, lower frequency: 14000 Hz. upper frequency: 15000 Hz.
;Sample frequency: 32780 Hz.
;25 coefficients
;Using Bartlett Windowing
		dc $116a0c,$f0642d,$0bec60,$f8f799,$01bb9d,$033187,$f8e729,$098d40,$f599cd,$09be93
		dc $f8177f,$05592f,$fd6eff,$0004ae,$01f4bf,$fcd3ca,$039c5b,$fc9cac,$02b6e3,$fe2a22
		dc $00fa2d,$ffb1e3,$ffe6c9,$003c03,$ffd4f0
coef5K8
;Bandpass Filter, lower frequency: 5500 Hz. upper frequency: 6000 Hz.
;Sample frequency: 32780 Hz.
;50 coefficients
;Using Bartlett Windowing
		dc $0909fd,$03ffe5,$fadf01,$f7a5b8,$fd8707,$05c550,$076c36,$010e84,$f9eaf6,$f9ad27
		dc $002e16,$061461,$0522a3,$fecffd,$fa335e,$fc1040,$01efa8,$054b1f,$02cc89,$fd9530
		dc $fb602f,$fe37bb,$02a467,$03dbdf,$00ee2e,$fd5c37,$fcefdd,$ffbb12,$0273c0,$024bcd
		dc $ffce83,$fddebc,$fe64b4,$007773,$01ba28,$010782,$ff6cfb,$feb436,$ff6a9f,$008cfd
		dc $00e1ec,$0045e8,$ff903d,$ff7a3a,$ffe97e,$004628,$003d6f,$0001b3,$ffe5ba,$fff463
coef2K2
;Bandpass Filter, lower frequency: 2100 Hz. upper frequency: 2300 Hz.
;Sample frequency: 32780 Hz.
;80 coefficients
;Using Bartlett Windowing
		dc $053fa9,$04ba8e,$0366e8,$01850b,$ff6c73,$fd7be0,$fc088c,$fb4f87,$fb6bb1,$fc51fb
		dc $fdd46b,$ffab30,$0181f1,$0306f5,$03f954,$0433ca,$03b258,$0291de,$0109ef,$ff6234
		dc $fde54e,$fcd3b1,$fc58be,$fc83f2,$fd4745,$fe7abe,$ffe47e,$014394,$025ba6,$02ff50
		dc $031771,$02a63c,$01c5b2,$00a202,$ff70ee,$fe67ec,$fdb2cb,$fd6c81,$fd9b4b,$fe30ab
		dc $ff0d0a,$000637,$00ef66,$01a137,$020050,$02017c,$01aaa3,$0110ac,$0052da,$ff9492
		dc $fef6d3,$fe9282,$fe749a,$fe9cb4,$fefe1f,$ff8318,$001163,$008f65,$00e8ad,$011135
		dc $0106d4,$00d0b2,$007d1e,$001e32,$ffc617,$ff839f,$ff5fd7,$ff5cf3,$ff76ac,$ffa3d9
		dc $ffd8dd,$000a4b,$002f37,$0042c6,$0044ab,$00389e,$0024f4,$0010c9,$00021f,$fffc72
coef1K4
;Bandpass Filter, lower frequency: 1350 Hz. upper frequency: 1450 Hz.
;Sample frequency: 8195 Hz.
;32 coefficients
;Using Bartlett Windowing
		dc $0c683a,$05bbcd,$f9abbb,$f4d0c0,$fb9a2f,$0655a4,$09de75,$033227,$f9deaa,$f78005
		dc $fdd8e6,$05bbcd,$071dfb,$014941,$fad4fe,$fa3db9,$ff6497,$047631,$047608,$001e83
		dc $fc5a73,$fcbe95,$002e50,$02c1ee,$022b61,$ffb256,$fe2b88,$fec69a,$0043ba,$00e642
		dc $006f5b,$ffe9f5
coef852
;Bandpass Filter, lower frequency: 840 Hz. upper frequency: 870 Hz.
;Sample frequency: 8195 Hz.
;48 coefficients
;Using Bartlett Windowing
		dc $082e8a,$0659c2,$020372,$fd0b0e,$f97dda,$f8be04,$faf930,$ff239d,$037400,$062779
		dc $06399e,$03c599,$ffec7e,$fc5182,$fa67b3,$fadce8,$fd5dd3,$00c6f0,$03a815,$04dfa8
		dc $040c05,$01a6e4,$fec4cb,$fc9928,$fbf64c,$fcfe98,$ff23f8,$017048,$02f2f6,$032347
		dc $020f3a,$004792,$fe974a,$fda9aa,$fdc6a1,$fec00d,$001303,$012972,$019c33,$01589e
		dc $009c32,$ffcd36,$ff4664,$ff2f62,$ff732d,$ffd590,$00195d,$002227
coef528
;Bandpass Filter, lower frequency: 510 Hz. upper frequency: 545 Hz.
;Sample frequency: 8195 Hz.
;64 coefficients
;Using Bartlett Windowing
		dc $064086,$05a85d,$042e34,$0215a6,$ffb998,$fd7cd7,$fbb9e6,$fab4b3,$fa9064,$fb4ac9
		dc $fcbe06,$fea7f5,$00b5d0,$029234,$03f2f5,$04a4b5,$04923d,$03c6bf,$026aaa,$00bbf0
		dc $ff030f,$fd86e9,$fc815a,$fc1672,$fc4fa4,$fd1b82,$fe51e3,$ffbb88,$011bdc,$023b18
		dc $02ef11,$032159,$02d1c9,$02153d,$0110ea,$fff346,$feebd2,$fe2339,$fdb513,$fdac35
		dc $fe021b,$fea139,$ff69b8,$00378f,$00e8ee,$0163c1,$019977,$01887f,$013b5b,$00c5b1
		dc $003ff1,$ffc28e,$ff6196,$ff2987,$ff1dd9,$ff3957,$ff7020,$ffb2c9,$fff1e3,$002136
		dc $003a02,$003be9,$002c5f,$0014d1
coef328
;Bandpass Filter, lower frequency: 320 Hz. upper frequency: 340 Hz.
;Sample frequency: 2049 Hz.
;32 coefficients
;Using Bartlett Windowing
		dc $0c45a9,$064d78,$faf791,$f4f4c8,$f964ba,$0382a2,$09b19e,$06a04e,$fdd227,$f7b9d6
		dc $f99e5b,$0111a4,$06d634,$05e687,$ffccc8,$fa915f,$fac7fd,$ff9554,$041b67,$046096
		dc $00c7c7,$fd18db,$fc944b,$ff19ba,$01dac9,$02655e,$00ca92,$ff02be,$fea66a,$ff84e5
		dc $005352,$0053f5
coef202
;Bandpass Filter, lower frequency: 195 Hz. upper frequency: 210 Hz.
;Sample frequency: 2049 Hz.
;48 coefficients
;Using Bartlett Windowing
		dc $0851dd,$06a006,$029303,$fdc180,$f9f923,$f8917d,$f9f256,$fd7846,$01bdab,$052826
		dc $0682cb,$056b00,$0269c8,$feb45f,$fbb074,$fa6d54,$fb44f2,$fdc5cd,$00e9b7,$038049
		dc $04a21b,$040120,$01fa72,$ff6733,$fd42c2,$fc4b0a,$fcbf50,$fe539a,$005942,$0208e7
		dc $02cef0,$027d5a,$01524c,$ffd502,$fe9ab0,$fe0c82,$fe453f,$ff1152,$000d6e,$00d410
		dc $0125c7,$00fc7e,$008455,$00006e,$ffa9c2,$ff976a,$ffb9f5,$ffe9ca
coef126
;Bandpass Filter, lower frequency: 120 Hz. upper frequency: 134 Hz.
;Sample frequency: 2049 Hz.
;70 coefficients
;Using Bartlett Windowing
		dc $05fadc,$0573e4,$04220f,$023d89,$0012ca,$fdf67b,$fc3885,$fb1832,$fabb35,$fb28d1
		dc $fc49c3,$fdeccc,$ffcef8,$01a650,$032d3a,$042cc1,$04844c,$042da6,$033ce4,$01dc4a
		dc $004509,$feb602,$fd6a0d,$fc8f50,$fc40db,$fc837b,$fd460c,$fe6521,$ffb145,$00f6c2
		dc $0205a8,$02b8d8,$02fb0c,$02c929,$0231b1,$015182,$004e9c,$ff51c5,$fe802a,$fdf5f1
		dc $fdc284,$fde716,$fe5776,$fefce1,$ffba51,$00716c,$010758,$01689b,$018b85,$0170e5
		dc $0122f3,$00b2e0,$00356d,$ffbf44,$ff61a3,$ff27ea,$ff165b,$ff2a2c,$ff5ac7,$ff9bf1
		dc $ffe054,$001bfd,$004658,$005b56,$005ba3,$004be8,$00335b,$0019f1,$00068b,$fffd8b
coef78
;Bandpass Filter, lower frequency: 73 Hz. upper frequency: 85 Hz.
;Sample frequency: 512 Hz.
;32 coefficients
;Using Bartlett Windowing
		dc $0dc1ff,$07887f,$fb5ff7,$f3f7c1,$f73572,$0186f5,$09a9bb,$09013d,$00f432,$f8f9b8
		dc $f7af90,$fd5fa9,$047b33,$06f8f4,$0371e9,$fdabd0,$fab58a,$fc7fa6,$00c0ce,$039428
		dc $02fd91,$003000,$fde902,$fdd697,$ff7224,$00fc0e,$0143e8,$007f6d,$ffaf7b,$ff7f04
		dc $ffc8cf,$000790
coef48
;Bandpass Filter, lower frequency: 44 Hz. upper frequency: 54 Hz.
;Sample frequency: 512 Hz.
;48 coefficients
;Using Bartlett Windowing
		dc $0a177b,$08249f,$0378ce,$fdd387,$f936da,$f72e7e,$f84a21,$fbf85f,$00caa6,$0503cd
		dc $0739c9,$06cf5b,$041cbb,$003e37,$fca104,$fa7c70,$fa6959,$fc3ade,$ff20c0,$020070
		dc $03dfc0,$043920,$031d63,$011c4a,$ff0299,$fd8a60,$fd1c03,$fdb4bc,$fef704,$005951
		dc $015dc3,$01bd01,$01765b,$00c366,$fff84a,$ff6005,$ff22e1,$ff3f0d,$ff92cd,$fff0d1
		dc $003477,$004ddf,$004289,$0024d8,$000849,$fff86f,$fff638,$fffb3e
coef30
;Bandpass Filter, lower frequency: 20 Hz. upper frequency: 32 Hz.
;Sample frequency: 512 Hz.
;64 coefficients
;Using Bartlett Windowing
		dc $09c0c5,$091b9a,$078fbe,$054f28,$029db2,$ffc8c8,$fd1e46,$fae3b1,$f94ec0,$f88021
		dc $f880ed,$f94303,$faa413,$fc72d2,$fe75a2,$0071bb,$0231f9,$038c7f,$046692,$04b659
		dc $04826e,$03df85,$02ec91,$01ce08,$00a8f7,$ff9e7d,$fec845,$fe364d,$fdee2a,$fdebb6
		dc $fe22ea,$fe8286,$fef716,$ff6dd5,$ffd723,$002827,$005b93,$00717a,$006e67,$0059e7
		dc $003cd4,$001fa8,$000925,$fffd6d,$fffdb0,$000861,$0019e6,$002d85,$003e71,$0048ba
		dc $0049fc,$0041b3,$003135,$001b4a,$000391,$ffedc5,$ffdd09,$ffd35e,$ffd159,$ffd61f
		dc $ffdfa8,$ffeb37,$fff5ee,$fffd5e

		ORG	P:0
		jmp	VMAIN

		ORG	P:I_SSIRD
		jsr	Receive

		ORG	P:I_SSIRDE
		jsr	RecErr

		ORG	P:VMAIN
		jmp	DoMain

RecErr		movep	x:M_SR,x:M_UU
		rti
Receive
		jclr	#3,X:M_SR,RecRight
		movep	x:M_RX,x:(r0)+
		rti
RecRight
		movep	x:M_RX,x:(r1)+
		rti

;#ncoef-1 in n5
;#coef in x1
;input in r6
;coef in r5
do_spec:
		move	n5,m3
		move	#states,r3
		;rep	x1		;using the repeat instruction gives
					;problems with the SSI interrupt,
					;because the rep instruction is not
					;interruptable. this is a little slower,
					;but at least it works
		do	x1,rep_spec1_1
		move	r7,x:(r3)+
rep_spec1_1	move	r6,r2
		move	r7,y1
		move	#buf,r6
		do	#POINTS/4,LoopSpec1_1
		move	r5,r4
		move	x:(r2)+,x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
		;rep	n5
		do	n5,rep_spec1_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
rep_spec1_2	macr	x0,y0,a 	(r3)-
		move	a,y:(r6)+
LoopSpec1_1
		move	#POINTS/16,n6
		move	#buf,r6
		nop
		move	y:(r6)+n6,x0
		do	#POINTS/16*3,LoopSpec1_2
		move	y:(r6)+,a
		abs	a
		cmp	y1,a
		jmi	Spec1NotMore
		move	a,y1			;get maximum value
Spec1NotMore
		nop
LoopSpec1_2
		rts

;#ncoef-1 in n5
;#coef in x1
;input in r6
;coef in r5
do_spec2:
		move	n5,m3
		move	#states,r3
		;rep	x1
		do	x1,rep_spec2_1
		move	r7,x:(r3)+
rep_spec2_1	move	r6,r2
		move	r7,y1
		move	#buf,r6
		move	#4,n2
		do	#POINTS/8,LoopSpec2_1
		move	r5,r4
		move	x:(r2)+n2,x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
		;rep	n5
		do	n5,rep_spec2_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
rep_spec2_2	macr	x0,y0,a 	(r3)-
		move	a,y:(r6)+
LoopSpec2_1
		move	#POINTS/32,n6
		move	#buf,r6
		nop
		move	y:(r6)+n6,x0
		do	#POINTS/32*3,LoopSpec2_2
		move	y:(r6)+,a
		abs	a
		cmp	y1,a
		jmi	Spec2NotMore
		move	a,y1
Spec2NotMore
		nop
LoopSpec2_2
		rts

;#ncoef-1 in n5
;#coef in x1
;input in r6
;coef in r5
do_spec3:
		move	n5,m3
		move	#states,r3
		;rep	x1
		do	x1,rep_spec3_1
		move	r7,x:(r3)+
rep_spec3_1	move	r6,r2
		move	r7,y1
		move	#buf,r6
		move	#16,n2
		do	#POINTS/16,LoopSpec3_1
		move	r5,r4
		move	x:(r2)+n2,x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
		;rep	n5
		do	n5,rep_spec3_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
rep_spec3_2	macr	x0,y0,a 	(r3)-
		move	a,y:(r6)+
LoopSpec3_1
		move	#POINTS/64,n6
		move	#buf,r6
		nop
		move	y:(r6)+n6,x0
		do	#POINTS/64*3,LoopSpec3_2
		move	y:(r6)+,a
		abs	a
		cmp	y1,a
		jmi	Spec3NotMore
		move	a,y1
Spec3NotMore
		nop
LoopSpec3_2
		rts
;#ncoef-1 in n5
;#coef in x1
;input in r6
;coef in r5
do_spec4:
		move	n5,m3
		move	#states,r3
		;rep	x1
		do	x1,rep_spec4_1
		move	r7,x:(r3)+
rep_spec4_1	move	r6,r2
		move	r7,y1
		move	#buf,r6
		move	#64,n2
		do	#POINTS/64,LoopSpec4_1
		move	r5,r4
		move	x:(r2)+n2,x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
		;rep	n5
		do	n5,rep_spec4_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
rep_spec4_2	macr	x0,y0,a 	(r3)-
		move	a,y:(r6)+
LoopSpec4_1
		move	#2,n6
		move	#buf,r6
		nop
		move	y:(r6)+n6,x0
		do	#POINTS/64-2,LoopSpec4_2
		move	y:(r6)+,a
		abs	a
		cmp	y1,a
		jmi	Spec4NotMore
		move	a,y1
Spec4NotMore
		nop
LoopSpec4_2
		rts


;32780 Hz -> 8195 Hz
low_pass1
		;left channel
		move	#ncoef2K-1,m3
		move	#states,r3
	;	rep	#ncoef2K
		do	#ncoef2K,repl_lp1_1
		move	r7,x:(r3)+
repl_lp1_1
		move	y:leftbuffaddr,r2
		move	#.5,y1
		move	#coef2K,r5
		do	#POINTS,Loopl_lp1
		move	r5,r4
		move	x:(r2),x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
	;	rep	#ncoef2K-1
		do	#ncoef2K-1,repl_lp1_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
repl_lp1_2	mac	x0,y0,a 	(r3)-
		move	a,x0
		macr	y1,x0,a
		move	a,X:(r2)+
Loopl_lp1

		;right channel
		move	#ncoef2K-1,m3
		move	#states,r3
	;	rep	#ncoef2K
		do	#ncoef2K,repr_lp1_1
		move	r7,x:(r3)+
repr_lp1_1
		move	y:rightbuffaddr,r2
		move	#.5,y1
		move	#coef2K,r5
		do	#POINTS,Loopr_lp1
		move	r5,r4
		move	x:(r2),x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0
	;	rep	#ncoef2K-1
		do	#ncoef2K-1,repr_lp1_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
repr_lp1_2	mac	x0,y0,a 	(r3)-
		move	a,x0
		macr	y1,x0,a
		move	a,X:(r2)+
Loopr_lp1
		rts


;8195 Hz -> 2049 Hz
low_pass2
		move	#ncoef500-1,m3
		move	#states,r3
		;rep	#ncoef500
		do	#ncoef500,repl_lp2_1
		move	r7,x:(r3)+
repl_lp2_1
		move	y:leftbuffaddr,r2
		move	#4,n2
		move	#.5,y1
		do	#POINTS/4,Loopl_lp2
		move	#coef500,r4
		move	x:(r2),x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
		;rep	#ncoef500-1
		do	#ncoef500-1,repl_lp2_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
repl_lp2_2	mac	x0,y0,a 	(r3)-
		move	a,x0
		macr	y1,x0,a
		move	a,X:(r2)+n2
Loopl_lp2


		move	#ncoef500-1,m3
		move	#states,r3
		;rep	#ncoef500
		do	#ncoef500,repr_lp2_1
		move	r7,x:(r3)+
repr_lp2_1
		move	y:rightbuffaddr,r2
		move	#4,n2
		move	#.5,y1
		do	#POINTS/4,Loopr_lp2
		move	#coef500,r4
		move	x:(r2),x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
		;rep	#ncoef500-1
		do	#ncoef500-1,repr_lp2_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
repr_lp2_2	mac	x0,y0,a 	(r3)-
		move	a,x0
		macr	y1,x0,a
		move	a,X:(r2)+n2
Loopr_lp2
		rts

;2049 Hz -> 512 Hz
low_pass3
		move	#ncoef125-1,m3
		move	#states,r3
		;rep	#ncoef125
		do	#ncoef125,repl_lp3_1
		move	r7,x:(r3)+
repl_lp3_1
		move	y:leftbuffaddr,r2
		move	#16,n2
		;move	#.5,y1
		do	#POINTS/16,Loopl_lp3
		move	#coef125,r4
		move	x:(r2),x0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
		;rep	#ncoef125-1
		do	#ncoef125-1,repl_lp3_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
repl_lp3_2	mac	x0,y0,a 	(r3)-
		move	a,x0
		;macr	y1,x0,a
		add	x0,a
		move	a,x:(r2)+n2
Loopl_lp3


		move	#ncoef125-1,m3
		move	#states,r3
		;rep	#ncoef125
		do	#ncoef125,repr_lp3_1
		move	r7,x:(r3)+
repr_lp3_1
		move	y:rightbuffaddr,r2
		move	#16,n2
		;move	#.5,y1
		do	#POINTS/16,Loopr_lp3
		move	#coef125,r4
		move	X:(R2),X0
		clr	a		x0,x:(r3)+	y:(r4)+,y0	
		;rep	#ncoef125-1
		do	#ncoef125-1,repr_lp3_2
		mac	x0,y0,a 	x:(r3)+,x0	y:(r4)+,y0
repr_lp3_2	mac	x0,y0,a 	(r3)-
		move	a,x0
		;macr	y1,x0,a
		add	x0,a
		move	a,x:(r2)+n2
Loopr_lp3
		rts



DoMain		reset
		ori	#$03,MR
		move	#LeftBuf,r0
		move	#RightBuf,r1
		move	#POINTS*4-1,m0
		move	m0,m1
		move	m0,m2
		move	m0,m3
		move	#0,r7
		move	#leftspec,r5
		rep	#14
		move	r7,y:(r5)+		;clear spectrum
		move	#rightspec,r5
		rep	#14
		move	r7,y:(r5)+
		movep	#$1,x:M_PBC
		movep	#$3000,x:M_IPR
		movep	#$4100,x:M_CRA
		movep	#$A800,x:M_CRB
		movep	#$0000,x:M_PCC
		movep	#$01F8,x:M_PCC
		movep	x:M_SR,x:M_UU
		movep	x:M_RX,x:M_SR
		andi	#$FC,MR			;enable interrupts

MainLoop
		jclr	#0,x:<<HSR,*		;wait for command
		movep	x:<<HRX,a

		move	#$123456,x0
		cmp	x0,a
		jne	MainLoop

		;get values for vu
		move	r0,r2
		move	r1,r3
		move	#POINTS*3,n2
		move	n2,n3
		move	x:(r2)+n2,x0
		move	x:(r3)+n3,x0
		move	r7,x0
		move	x0,x1
		move	x0,y0
		move	x0,y1
		do	#POINTS,LoopMax
		move	x:(r2)+,a
		sub	y0,a
		rep	#4
		asr	a			;kind of a lowpass filter
		add	y0,a
		move	a,y0
		abs	a
		cmp	x0,a
		jmi	NotMoreL
		move	a,x0			;get maximum value
NotMoreL	move	x:(r3)+,a
		sub	y1,a
		rep	#4
		asr	a
		add	y1,a
		move	a,y1
		abs	a
		cmp	x1,a
		jmi	NotMoreR
		move	a,x1			;for right channel too
NotMoreR
		nop
LoopMax

		jclr	#1,x:<<HSR,*
		movep	x0,x:<<HTX
		jclr	#1,x:<<HSR,*
		movep	x1,x:<<HTX



		;send data for scope

		;Full Range
		move	#POINTS*3,n2
		move	n2,n3
		move	r0,r2
		move	r1,r3
		move	x:(r2)+n2,x0
		move	x:(r3)+n3,x0
		move	#4,n2
		move	n2,n3

		do	#POINTS/4,LoopSendScL
		move	x:(r2)+n2,a
		asr	a
		jclr	#1,x:<<HSR,*
		movep	a,x:<<HTX
LoopSendScL
		do	#POINTS/4,LoopSendScR
		move	x:(r3)+n3,a
		asr	a
		jclr	#1,x:<<HSR,*
		movep	a,x:<<HTX
LoopSendScR

		;Small Range
		move	#POINTS*3,n2
		move	n2,n3
		;move	r0,r2
		;move	r1,r3
		move	x:(r2)+n2,x0
		move	x:(r3)+n3,x0

		do	#POINTS/4,LoopSendScL2
		move	x:(r2)+,a
		asr	a
		jclr	#1,x:<<HSR,*
		movep	a,x:<<HTX
LoopSendScL2
		do	#POINTS/4,LoopSendScR2
		move	x:(r3)+,a
		asr	a
		jclr	#1,x:<<HSR,*
		movep	a,x:<<HTX
LoopSendScR2

		;calculate values for spectrum

		move	r0,r2
		move	#POINTS*3,n2
		move	r1,r3
		move	n2,n3
		move	x:(r2)+n2,x0
		move	x:(r3)+n3,x0
		move	r2,y:leftbuffaddr
		move	r3,y:rightbuffaddr

		move	#>ncoef15K,x1
		move	#>ncoef15K-1,n5
		move	y:leftbuffaddr,r6
		move	#coef15K,r5
		jsr	do_spec
		move	y1,y:leftspec+13

		move	#>ncoef9K3,x1
		move	#>ncoef9K3-1,n5
		move	y:leftbuffaddr,r6
		move	#coef9K3,r5
		jsr	do_spec
		move	y1,y:leftspec+12

		move	#>ncoef5K8,x1
		move	#>ncoef5K8-1,n5
		move	y:leftbuffaddr,r6
		move	#coef5K8,r5
		jsr	do_spec
		move	y1,y:leftspec+11

		move	#>ncoef3K6,x1
		move	#>ncoef3K6-1,n5
		move	y:leftbuffaddr,r6
		move	#coef3K6,r5
		jsr	do_spec
		move	y1,y:leftspec+10

		move	#>ncoef2K2,x1
		move	#>ncoef2K2-1,n5
		move	y:leftbuffaddr,r6
		move	#coef2K2,r5
		jsr	do_spec
		move	y1,y:leftspec+9




		move	#>ncoef15K,x1
		move	#>ncoef15K-1,n5
		move	y:rightbuffaddr,r6
		move	#coef15K,r5
		jsr	do_spec
		move	y1,y:rightspec+13

		move	#>ncoef9K3,x1
		move	#>ncoef9K3-1,n5
		move	y:rightbuffaddr,r6
		move	#coef9K3,r5
		jsr	do_spec
		move	y1,y:rightspec+12

		move	#>ncoef5K8,x1
		move	#>ncoef5K8-1,n5
		move	y:rightbuffaddr,r6
		move	#coef5K8,r5
		jsr	do_spec
		move	y1,y:rightspec+11

		move	#>ncoef3K6,x1
		move	#>ncoef3K6-1,n5
		move	y:rightbuffaddr,r6
		move	#coef3K6,r5
		jsr	do_spec
		move	y1,y:rightspec+10

		move	#>ncoef2K2,x1
		move	#>ncoef2K2-1,n5
		move	y:rightbuffaddr,r6
		move	#coef2K2,r5
		jsr	do_spec
		move	y1,y:rightspec+9


		jsr	low_pass1



		move	#>ncoef1K4,x1
		move	#>ncoef1K4-1,n5
		move	y:leftbuffaddr,r6
		move	#coef1K4,r5
		jsr	do_spec2
		move	y1,y:leftspec+8

		move	#>ncoef852,x1
		move	#>ncoef852-1,n5
		move	y:leftbuffaddr,r6
		move	#coef852,r5
		jsr	do_spec2
		move	y1,y:leftspec+7

		move	#>ncoef528,x1
		move	#>ncoef528-1,n5
		move	y:leftbuffaddr,r6
		move	#coef528,r5
		jsr	do_spec2
		move	y1,y:leftspec+6




		move	#>ncoef1K4,x1
		move	#>ncoef1K4-1,n5
		move	y:rightbuffaddr,r6
		move	#coef1K4,r5
		jsr	do_spec2
		move	y1,y:rightspec+8

		move	#>ncoef852,x1
		move	#>ncoef852-1,n5
		move	y:rightbuffaddr,r6
		move	#coef852,r5
		jsr	do_spec2
		move	y1,y:rightspec+7

		move	#>ncoef528,x1
		move	#>ncoef528-1,n5
		move	y:rightbuffaddr,r6
		move	#coef528,r5
		jsr	do_spec2
		move	y1,y:rightspec+6


		jsr	low_pass2



		move	#>ncoef328,x1
		move	#>ncoef328-1,n5
		move	y:leftbuffaddr,r6
		move	#coef328,r5
		jsr	do_spec3
		move	y1,y:leftspec+5

		move	#>ncoef202,x1
		move	#>ncoef202-1,n5
		move	y:leftbuffaddr,r6
		move	#coef202,r5
		jsr	do_spec3
		move	y1,y:leftspec+4

		move	#>ncoef126,x1
		move	#>ncoef126-1,n5
		move	y:leftbuffaddr,r6
		move	#coef126,r5
		jsr	do_spec3
		move	y1,y:leftspec+3




		move	#>ncoef328,x1
		move	#>ncoef328-1,n5
		move	y:rightbuffaddr,r6
		move	#coef328,r5
		jsr	do_spec3
		move	y1,y:rightspec+5

		move	#>ncoef202,x1
		move	#>ncoef202-1,n5
		move	y:rightbuffaddr,r6
		move	#coef202,r5
		jsr	do_spec3
		move	y1,y:rightspec+4

		move	#>ncoef126,x1
		move	#>ncoef126-1,n5
		move	y:rightbuffaddr,r6
		move	#coef126,r5
		jsr	do_spec3
		move	y1,y:rightspec+3


		jsr	low_pass3



		move	#>ncoef78,x1
		move	#>ncoef78-1,n5
		move	y:leftbuffaddr,r6
		move	#coef78,r5
		jsr	do_spec4
		move	y1,y:leftspec+2

		move	#>ncoef48,x1
		move	#>ncoef48-1,n5
		move	y:leftbuffaddr,r6
		move	#coef48,r5
		jsr	do_spec4
		move	y1,a
		move	#.1,x1			;pump it up a little
		macr	y1,x1,a
		move	a,y:leftspec+1

		move	#>ncoef30,x1
		move	#>ncoef30-1,n5
		move	y:leftbuffaddr,r6
		move	#coef30,r5
		jsr	do_spec4
		move	y1,a
		move	#.3,x1
		macr	y1,x1,a
		move	a,y:leftspec



		move	#>ncoef78,x1
		move	#>ncoef78-1,n5
		move	y:rightbuffaddr,r6
		move	#coef78,r5
		jsr	do_spec4
		move	y1,y:rightspec+2

		move	#>ncoef48,x1
		move	#>ncoef48-1,n5
		move	y:rightbuffaddr,r6
		move	#coef48,r5
		jsr	do_spec4
		move	y1,a
		move	#.1,x1
		macr	y1,x1,a
		move	a,y:rightspec+1

		move	#>ncoef30,x1
		move	#>ncoef30-1,n5
		move	y:rightbuffaddr,r6
		move	#coef30,r5
		jsr	do_spec4
		move	y1,a
		move	#.3,x1
		macr	y1,x1,a
		move	a,y:rightspec



		move	m0,m3

		;wait for command and send data for spectrum

		jclr	#0,x:<<HSR,*
		movep	x:<<HRX,x0

		move	#leftspec,r5
		do	#14,LoopSendBarsL
		move	y:(r5)+,a
		rep	#5
		asr	a
		jclr	#1,x:<<HSR,*
		movep	a,x:<<HTX
LoopSendBarsL

		move	#rightspec,r5
		do	#14,LoopSendBarsR
		move	y:(r5)+,a
		rep	#5
		asr	a
		jclr	#1,x:<<HSR,*
		movep	a,x:<<HTX
LoopSendBarsR

		jmp	MainLoop
