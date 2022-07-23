MARK_VBL	equ 0
EXIT_SPACE	equ 0
RGB_ONLY	equ	1
SCHED_TD	equ	0
CACR_1		equ 1
CACR_2		equ 0
MOD_MSX		equ 0
MP2_MSX		equ 1
DEBUG		equ 0
WAIT_1VBL	equ 1
SYNC_OFFSET	equ	0

PIC_FX		equ 1
TUNNEL_FX	equ 1
BUMP_FX		equ	1
ROTOZOOM_FX	equ	1
METABALL_FX	equ	1
PLASMA_FX	equ	1
GOU_3D_FX	equ 1
TEX_3D_FX	equ 1
WORMHOLE_FX	equ 1
GREETZ_FX	equ 1

RAM_BUFFER_SIZE	equ 1024*1024

	ifne	DEBUG
	OPT D+
	endif
		
	section text
			include system/main.s	
			include system/common.s

; effects			
			ifne TEX_3D_FX
			include 3d-tex/3d-tex.s
			endif

			ifne GOU_3D_FX
			include 3d-gou/3d.s
			endif

			ifne BUMP_FX
			include bump/bump.s
			endif

			ifne TUNNEL_FX
			include tunnel/tunnel.s
			endif			

			ifne ROTOZOOM_FX
			include rotozoom/rotozoom.s
			endif			

			ifne PLASMA_FX
			include plasma/plasma.s
			endif

			ifne WORMHOLE_FX
			include wormhole/wormhole.s
			endif			

			ifne PIC_FX
			include picture/picture.s
			endif

			ifne METABALL_FX
			include metaballs/metaballs.s
			endif
			
			ifne GREETZ_FX
			include greetz/greetz.s
			endif
			cnop	0,4
; data
	section data
	cnop 0,4
demoDefintion:

		ifne PIC_FX
		dc.l	1,pictureInitFade
		dc.l	3,pictureMainIntro2Fade
		dc.l	150+SYNC_OFFSET,tex3dInit
		dc.l	203+SYNC_OFFSET,pictureInitIntro3
		dc.l	406+SYNC_OFFSET,pictureInitIntro4
		dc.l	650+SYNC_OFFSET,pictureInitIntro5
		dc.l	894+SYNC_OFFSET,pictureInitIntro6
		dc.l	1057+SYNC_OFFSET,pictureInitIntro7
		dc.l	1297+SYNC_OFFSET,flashStart1
		dc.l	1299+SYNC_OFFSET,flashEnd1		
		dc.l	1300+SYNC_OFFSET,pictureInitIntro9
		dc.l	1463+SYNC_OFFSET,pictureInitIntro8
		endif
		ifne METABALL_FX
		dc.l	1622+SYNC_OFFSET,metaballsInit
		dc.l	1625+SYNC_OFFSET,metaballsMain
		endif
		ifne PIC_FX
		dc.l	1950+SYNC_OFFSET,pictureInitLogo1a
		dc.l	2032+SYNC_OFFSET,pictureInitLogo1d
		dc.l	2113+SYNC_OFFSET,pictureInitLogo1b	
		dc.l	2194+SYNC_OFFSET,pictureInitLogo1c		
		endif
		ifne PIC_FX
		dc.l	2273+SYNC_OFFSET,flashStart2
		dc.l	2275+SYNC_OFFSET,flashEnd2				
		dc.l	2276+SYNC_OFFSET,pictureInitTitle
		endif
		ifne TUNNEL_FX
		dc.l	2392+SYNC_OFFSET,tunnelInit2
		dc.l	2397+SYNC_OFFSET,tunnelMain	; 2397 albo	2438
		;dc.l	2922+SYNC_OFFSET,tunnelInit2B
		;dc.l	2925+SYNC_OFFSET,tunnelMain2
		dc.l	2923+SYNC_OFFSET,tunnelMain2
		endif
		ifne ROTOZOOM_FX
		dc.l	3246+SYNC_OFFSET,rotozoomInit
		dc.l	3251+SYNC_OFFSET,rotozoomMain
		endif
		ifne BUMP_FX
		dc.l	3559+SYNC_OFFSET,bumpInit
		dc.l	3574+SYNC_OFFSET,bumpMain
		endif
		ifne TEX_3D_FX
		dc.l	3900+SYNC_OFFSET,pictureInitCode
		dc.l	3903+SYNC_OFFSET,tex3dMain
		dc.l	4225+SYNC_OFFSET,pictureInitMsx
		dc.l	4227+SYNC_OFFSET,tex3dMain
		dc.l	4550+SYNC_OFFSET,pictureInitVisuals
		dc.l	4552+SYNC_OFFSET,tex3dMain
		endif
		ifne TUNNEL_FX
		dc.l	4871+SYNC_OFFSET,tunnelInit
		dc.l	4876+SYNC_OFFSET,tunnelMain
		endif
		ifne TEX_3D_FX
		dc.l	5120+SYNC_OFFSET,pictureInitGreyPre
		dc.l	5201+SYNC_OFFSET,pictureInitGreyPreFlashOn1
		dc.l	5283+SYNC_OFFSET,pictureInitGreyPreFlashOn2
		dc.l	5364+SYNC_OFFSET,pictureInitGreyPre4
		dc.l	5445+SYNC_OFFSET,pictureGreyVScrollInit
		dc.l	5526+SYNC_OFFSET,pictureGreyVScrollMain
		dc.l	5845+SYNC_OFFSET,flashStart3
		dc.l	5847+SYNC_OFFSET,flashEnd3	
		dc.l	5848+SYNC_OFFSET,pictureGreyVScrollEnd		
		dc.l	5851+SYNC_OFFSET,tex3dMain
		endif
		ifne GOU_3D_FX
		dc.l	6093+SYNC_OFFSET,pictureGouInit
		dc.l	6097+SYNC_OFFSET,gou3dMain
		endif
		ifne PLASMA_FX
		dc.l	6499+SYNC_OFFSET,plasmaInit
		dc.l	6502+SYNC_OFFSET,plasmaMain
		endif		
		ifne GREETZ_FX
		;149535 milisekundy aż do 158272 milisekundy, co 406
		dc.l	6827+SYNC_OFFSET,greetzInit
		dc.l	6908+SYNC_OFFSET,greetzText 		; 138157 = 6908
		dc.l	6989+SYNC_OFFSET,greetzHeartOn1		;?
		dc.l	7009+SYNC_OFFSET,greetzHeartOff1	;?
		dc.l	7029+SYNC_OFFSET,greetzHeartOn2		;?
		dc.l	7050+SYNC_OFFSET,greetzHeartOff2	;?
		dc.l	7070+SYNC_OFFSET,greetzHeartOn3		;?

		dc.l	7151+SYNC_OFFSET,copyGreetzSlideMain1	; 2:23:20
		dc.l	7172+SYNC_OFFSET,copyGreetzSlideMain2	; 2:23:440
		dc.l	7192+SYNC_OFFSET,copyGreetzSlideMain3	; 2:23:840
		dc.l	7212+SYNC_OFFSET,copyGreetzSlideMain4	; 2:24:240
		dc.l	7232+SYNC_OFFSET,copyGreetzSlideMain5	; 2:24:640
		dc.l	7253+SYNC_OFFSET,copyGreetzSlideMain6	; 2:25:60
		dc.l	7273+SYNC_OFFSET,copyGreetzSlideMain7	; 2:25:460
		dc.l	7293+SYNC_OFFSET,copyGreetzSlideMain8	; 2:25:860
		dc.l	7314+SYNC_OFFSET,copyGreetzSlideMain9	; 2:26:280
		dc.l	7334+SYNC_OFFSET,copyGreetzSlideMain10	; 2:26:680
		dc.l	7354+SYNC_OFFSET,copyGreetzSlideMain11	; 2:27:80
		dc.l	7375+SYNC_OFFSET,copyGreetzSlideMain12	; 2:27:500
		dc.l	7395+SYNC_OFFSET,copyGreetzSlideMain13	; 2:27:900
		dc.l	7415+SYNC_OFFSET,copyGreetzSlideMain14	; 2:28:300
		dc.l	7435+SYNC_OFFSET,copyGreetzSlideMain15	; 2:28:700
		dc.l	7456+SYNC_OFFSET,copyGreetzSlideMain16	; 2:29:120
		dc.l	7476+SYNC_OFFSET,copyGreetzSlideMain17	; 2:29:520
		dc.l	7496+SYNC_OFFSET,copyGreetzSlideMain18	; 2:29:920
		dc.l	7517+SYNC_OFFSET,copyGreetzSlideMain19	; 2:30:340
		dc.l	7537+SYNC_OFFSET,copyGreetzSlideMain20	; 2:30:740
		dc.l	7557+SYNC_OFFSET,copyGreetzSlideMain21	; 2:31:140
		dc.l	7578+SYNC_OFFSET,copyGreetzSlideMain22	; 2:31:560
		dc.l	7598+SYNC_OFFSET,copyGreetzSlideMain23	; 2:31:960
		dc.l	7618+SYNC_OFFSET,copyGreetzSlideMain24	; 2:32:360
		dc.l	7638+SYNC_OFFSET,copyGreetzSlideMain25	; 2:32:760
		dc.l	7659+SYNC_OFFSET,copyGreetzSlideMain26	; 2:33:180
		dc.l	7679+SYNC_OFFSET,copyGreetzSlideMain27	; 2:33:580
		dc.l	7699+SYNC_OFFSET,copyGreetzSlideMain28	; 2:33:980
		dc.l	7720+SYNC_OFFSET,copyGreetzSlideMain29	; 2:34:400
		dc.l	7740+SYNC_OFFSET,copyGreetzSlideMain30	; 2:34:800
		dc.l	7760+SYNC_OFFSET,copyGreetzSlideMain31	; 2:35:200
		dc.l	7781+SYNC_OFFSET,copyGreetzSlideMain32	; 2:35:620
		dc.l	7801+SYNC_OFFSET,copyGreetzSlideMain33	; 2:36:20
		dc.l	7821+SYNC_OFFSET,copyGreetzSlideMain34	; 2:36:420
		dc.l	7841+SYNC_OFFSET,copyGreetzSlideMain35	; 2:36:820
		dc.l	7862+SYNC_OFFSET,copyGreetzSlideMain36	; 2:37:240
		dc.l	7882+SYNC_OFFSET,copyGreetzSlideMain37	; 2:37:640
		endif
		
		ifne PIC_FX
		dc.l	7900+SYNC_OFFSET,pictureWowInit
		dc.l	7902+SYNC_OFFSET,pictureWowMain
		dc.l	8444+SYNC_OFFSET,pictureWowEnd		
		endif
		ifne WORMHOLE_FX
		dc.l	8447+SYNC_OFFSET,wormholeInit
		dc.l	8452+SYNC_OFFSET,wormholeMain
		endif
		ifne ROTOZOOM_FX
		dc.l	8772+SYNC_OFFSET,rotozoomInit2
		dc.l	8777+SYNC_OFFSET,rotozoomMain
		endif
		ifne PIC_FX
		dc.l	9100+SYNC_OFFSET,pictureEndScrollInit2
		dc.l	9102+SYNC_OFFSET,pictureEndScrollMain2
		; scroll trwa 488 klatek 

		dc.l	9590+SYNC_OFFSET,pictureInitPreEnd
		dc.l	9630+SYNC_OFFSET,pictureInitPreEndClr1
		dc.l	9671+SYNC_OFFSET,pictureInitPreEndClr2
		dc.l	9712+SYNC_OFFSET,pictureInitPreEndClr3
		
		dc.l	9752+SYNC_OFFSET,pictureInitLameboy
		dc.l	9827+SYNC_OFFSET,pictureInitLameboy2
		dc.l	9835+SYNC_OFFSET,pictureInitLameboy3

		dc.l	9875+SYNC_OFFSET,pictureInitFadeEndLogo
		dc.l	9877+SYNC_OFFSET,pictureMainFadeEndLogo
		endif		
		dc.l	10050,exit

; effects data
		cnop 0,4
		ifne TEX_3D_FX
		include '3d-tex/data2-tex.s'
		endif
