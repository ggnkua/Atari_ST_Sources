		section text
BUMP_BM_SIZE_X	equ 320
BUMP_BM_SIZE_Y	equ 200

BUMP_LM_SIZE	equ	256

BUMP_LIGHT_X_MOVE_SIZE	equ 100
BUMP_LIGHT_Y_MOVE_SIZE	equ 200

BUMP_MAP_X_MOVE_SIZE	equ 300
BUMP_MAP_Y_MOVE_SIZE	equ 300

bumpInit:
		firstRunOrReturn
		bsr 	clearScreenBuffer3
		;bsr 	clearScreenBuffer2
		bsr 	clearScreenBuffer1

		move.l	ramBufferPtr,a0
		move.l	a0,a1
		move.l	a0,bumpMapPtr
		
		lea		bumpBitMap,a1

        move.l  #BUMP_BM_SIZE_Y-1,d7                     
bumpInitYloop:  
		move.l  #BUMP_BM_SIZE_X-1,d6                     
bumpInitXloop:  
		move.b  (a1),d0                         
        sub.b   2(a1),d0                        
        bpl.s   bumpInitSkip1                           
        neg.b   d0                              
bumpInitSkip1:  asr.b   #1,d0                           
        move.b  d0,(a0)+                        
        move.b  (a1),d0                         
        sub.b   BUMP_BM_SIZE_X*2(a1),d0         
        bpl.s   bumpInitSkip2                           
        neg.b   d0                              
bumpInitSkip2:  asr.b   #1,d0                           
        move.b  d0,(a0)+                        
        addq    #1,a1                           
        dbra    d6,bumpInitXloop                        
        dbra    d7,bumpInitYloop                        

		lea		bumpLightMap,a0
		move.l	ramBufferPtr,a1
		add.l	#BUMP_BM_SIZE_X*BUMP_BM_SIZE_Y*2,a1
		move.l	a1,bumpLightMapDataPtr
		
		cmp.w	#0,monitor
		bne.s	_bumpInitRgb		
		; vga init
		bsr		video_vga_160x200x16
		
		rts
		; rgb init
_bumpInitRgb
		bsr		video_rgb_320x100x16
		move.l	#BUMP_LM_SIZE*BUMP_LM_SIZE-1,d7
_bumpTxInitRgbLoop
		move.w	(a0),(a1)+
		move.w	(a0)+,(a1)+
		dbf	d7,_bumpTxInitRgbLoop	
		move.l	#BUMP_LM_SIZE*BUMP_LM_SIZE-1,d7
_bumpTxInitRgbLoop2
		move.l	#0,(a1)+
		dbf	d7,_bumpTxInitRgbLoop2		
		rts

bumpMain:
		move.l	bumpMapPtr,a2
		lea		bumpMapOffsetX,a4
		move.w	bumpMapOffsetXnow,d4
		add.l	(a4,d4.w*4),a2
		add.w	#1,bumpMapOffsetXnow
		cmp.w	#BUMP_MAP_X_MOVE_SIZE,bumpMapOffsetXnow
		blt.s	_bumpMapOffsetXok
		move.w	#0,bumpMapOffsetXnow
_bumpMapOffsetXok	

		lea		bumpMapOffsetY,a4
		move.w	bumpMapOffsetYnow,d4
		add.l	(a4,d4.w*4),a2
		add.w	#1,bumpMapOffsetYnow
		cmp.w	#BUMP_MAP_Y_MOVE_SIZE,bumpMapOffsetYnow
		blt.s	_bumpMapOffsetYok
		move.w	#0,bumpMapOffsetYnow
_bumpMapOffsetYok	

		cmp.w	#0,monitor
		bne		bumpMainRgb	
			
		; bump main vga
		bsr switchScreens
		move.l	scr1,a0
		lea		320(a0),a3
		
		lea		bumpLightMap,a1

		lea		bumpLightOffsetX,a4
		move.w	bumpLightOffsetXnow,d4
		add.l	(a4,d4.w*4),a1
		add.w	#1,bumpLightOffsetXnow
		cmp.w	#BUMP_LIGHT_X_MOVE_SIZE,bumpLightOffsetXnow
		blt.s	_bumpLightOffsetXokVga
		move.w	#0,bumpLightOffsetXnow
_bumpLightOffsetXokVga	

		lea		bumpLightOffsetY,a4
		move.w	bumpLightOffsetYnow,d4
		add.l	(a4,d4.w*4),a1
		add.w	#1,bumpLightOffsetYnow
		cmp.w	#BUMP_LIGHT_Y_MOVE_SIZE,bumpLightOffsetYnow
		blt.s	_bumpLightOffsetYokVga
		move.w	#0,bumpLightOffsetYnow
_bumpLightOffsetYokVga	

		moveq	#0,d0	
		move.l	#16,d5
			
        move.w  #100-1,d7                     
vgaBumpLoopY:  
		move.w  #10-1,d6                     
vgaBumpLoopX:  
		rept 2
		movem.w	(a2)+,d0-d4/a4-a6

		move.w	(a1,d0.l*2),d0
		move.w	d0,(a0)+
		move.w	d0,(a3)+

		move.w	2(a1,d1.l*2),d0
		move.w	d0,(a0)+
		move.w	d0,(a3)+

		move.w	4(a1,d2.l*2),d0
		move.w	d0,(a0)+
		move.w	d0,(a3)+

		move.w	6(a1,d3.l*2),d0
		move.w	d0,(a0)+
		move.w	d0,(a3)+

		move.w	8(a1,d4.l*2),d0
		move.w	d0,(a0)+
		move.w	d0,(a3)+
		
		move.w	10(a1,a4.l*2),d0
		move.w	d0,(a0)+
		move.w	d0,(a3)+
		
		move.w	12(a1,a5.l*2),d0
		move.w	d0,(a0)+
		move.w	d0,(a3)+

		move.w	14(a1,a6.l*2),d0
		move.w	d0,(a0)+
		move.w	d0,(a3)+

		add.l   d5,a1
		endr
        dbra    d6,vgaBumpLoopX   
        
        lea		320(a0),a0
        lea		320(a3),a3
        lea		320(a2),a2
		lea		192(a1),a1
                            
        dbra    d7,vgaBumpLoopY        
           
		rts
 
bumpMainRgb:
		; bump main rgb
		bsr switchScreens
		move.l	scr1,a0
		move.l	bumpLightMapDataPtr,a1

		lea		bumpLightOffsetX,a4
		move.w	bumpLightOffsetXnow,d4
		add.l	(a4,d4.w*4),a1
		add.l	(a4,d4.w*4),a1
		add.w	#1,bumpLightOffsetXnow
		cmp.w	#BUMP_LIGHT_X_MOVE_SIZE,bumpLightOffsetXnow
		blt.s	_bumpLightOffsetXokRGB
		move.w	#0,bumpLightOffsetXnow
_bumpLightOffsetXokRGB	

		lea		bumpLightOffsetY,a4
		move.w	bumpLightOffsetYnow,d4
		add.l	(a4,d4.w*4),a1
		add.l	(a4,d4.w*4),a1
		add.w	#1,bumpLightOffsetYnow
		cmp.w	#BUMP_LIGHT_Y_MOVE_SIZE,bumpLightOffsetYnow
		blt.s	_bumpLightOffsetYokRGB
		move.w	#0,bumpLightOffsetYnow
_bumpLightOffsetYokRGB	

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		move.l	d0,a3
		move.l	d0,a4
		move.l	d0,a5
		
		move.l	#32,d5		
        move.w  #100-1,d7                     
rgbBumpLoopY:  
		move.w  #4-1,d6                     
rgbBumpLoopX:  

		rept	5
		movem.w	(a2)+,d0-d4/a3-a5
		move.l	(a1,d0.l*4),(a0)+
		move.l	4(a1,d1.l*4),(a0)+
		move.l	8(a1,d2.l*4),(a0)+
		move.l	12(a1,d3.l*4),(a0)+
		move.l	16(a1,d4.l*4),(a0)+
		move.l	20(a1,a3.l*4),(a0)+
		move.l	24(a1,a4.l*4),(a0)+
		move.l	28(a1,a5.l*4),(a0)+
		add.l   d5,a1
		endr

        dbra    d6,rgbBumpLoopX   
        
        lea		320(a2),a2
		lea		192*2(a1),a1
                            
        dbra    d7,rgbBumpLoopY                    
		rts

		section data
	cnop 0,4
bumpLightMap	incbin 'bump/lightmap2.dat'
	cnop 0,4
bumpBitMap		
				incbin 'bump/bumpa3.dat'
				;incbin 'bump/bumpa41.dat'
	cnop 0,4
bumpLightOffsetX dc.l 96,102,108,112,118,124,130,136,142,146,152,156,160,164,168,172,176,180,182,184,186,188,190,190,190,192,190,190,190,188,186,184,182,180,176,172,168,164,160,156,152,146,142,136,130,124,118,112,108,102,96,90,84,80,74,68,62,56,50,46,40,36,32,28,24,20,16,12,10,8,6,4,2,2,2,0,2,2,2,4,6,8,10,12,16,20,24,28,32,36,40,46,50,56,62,68,74,80,84,90
	cnop 0,4
bumpLightOffsetY dc.l 39936,40960,41984,43520,44544,46080,47104,48640,49664,50688,52224,53248,54272,55296,56832,57856,58880,59904,60928,61952,62976,64000,65024,66048,67072,68096,68608,69632,70656,71168,72192,72704,73216,74240,74752,75264,75776,76288,76800,77312,77824,77824,78336,78848,78848,79360,79360,79360,79360,79360,79872,79360,79360,79360,79360,79360,78848,78848,78336,77824,77824,77312,76800,76288,75776,75264,74752,74240,73216,72704,72192,71168,70656,69632,68608,68096,67072,66048,65024,64000,62976,61952,60928,59904,58880,57856,56832,55296,54272,53248,52224,50688,49664,48640,47104,46080,44544,43520,41984,40960,39936,38912,37888,36352,35328,33792,32768,31232,30208,29184,27648,26624,25600,24576,23040,22016,20992,19968,18944,17920,16896,15872,14848,13824,12800,11776,11264,10240,9216,8704,7680,7168,6656,5632,5120,4608,4096,3584,3072,2560,2048,2048,1536,1024,1024,512,512,512,512,512,0,512,512,512,512,512,1024,1024,1536,2048,2048,2560,3072,3584,4096,4608,5120,5632,6656,7168,7680,8704,9216,10240,11264,11776,12800,13824,14848,15872,16896,17920,18944,19968,20992,22016,23040,24576,25600,26624,27648,29184,30208,31232,32768,33792,35328,36352,37888,38912
	cnop 0,4
bumpMapOffsetX 
				;dc.l 160,162,166,170,172,176,180,182,186,188,192,196,198,202,206,208,212,214,218,222,224,228,230,234,236,238,242,244,248,250,254,256,258,260,264,266,268,270,274,276,278,280,282,284,286,288,290,292,294,296,298,300,300,302,304,306,306,308,308,310,312,312,314,314,314,316,316,316,316,316,316,316,316,316,316,316,316,316,316,316,316,316,316,316,316,316,314,314,314,312,312,310,308,308,306,306,304,302,300,300,298,296,294,292,290,288,286,284,282,280,278,276,274,270,268,266,264,260,258,256,254,250,248,244,242,238,236,234,230,228,224,222,218,214,212,208,206,202,198,196,192,188,186,182,180,176,172,170,166,162,160,158,154,150,148,144,140,138,134,132,128,124,122,118,114,112,108,106,102,98,96,92,90,86,84,80,78,76,72,70,66,64,62,60,56,54,52,50,46,44,42,40,38,36,34,32,30,28,26,24,22,20,20,18,16,14,14,12,12,10,8,8,6,6,6,4,4,4,2,2,2,2,2,2,2,0,2,2,2,2,2,2,2,4,4,4,6,6,6,8,8,10,12,12,14,14,16,18,20,20,22,24,26,28,30,32,34,36,38,40,42,44,46,50,52,54,56,60,62,64,66,70,72,76,78,80,84,86,90,92,96,98,102,106,108,112,114,118,122,124,128,132,134,138,140,144,148,150,154,158
				dc.l 160,162,166,168,172,176,178,182,186,188,192,196,198,202,204,208,210,214,218,220,224,226,230,232,236,238,240,244,246,250,252,254,258,260,262,264,268,270,272,274,276,278,280,282,284,286,288,290,292,294,296,298,300,300,302,304,304,306,308,308,310,310,312,312,312,314,314,314,316,316,316,316,316,316,316,316,316,316,316,316,316,316,316,314,314,314,312,312,312,310,310,308,308,306,304,304,302,300,300,298,296,294,292,290,288,286,284,282,280,278,276,274,272,270,268,264,262,260,258,254,252,250,246,244,240,238,236,232,230,226,224,220,218,214,210,208,204,202,198,196,192,188,186,182,178,176,172,168,166,162,160,158,154,152,148,144,142,138,134,132,128,124,122,118,116,112,110,106,102,100,96,94,90,88,84,82,80,76,74,70,68,66,62,60,58,56,52,50,48,46,44,42,40,38,36,34,32,30,28,26,24,22,20,20,18,16,16,14,12,12,10,10,8,8,8,6,6,6,4,4,4,4,4,4,4,2,4,4,4,4,4,4,4,6,6,6,8,8,8,10,10,12,12,14,16,16,18,20,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,56,58,60,62,66,68,70,74,76,80,82,84,88,90,94,96,100,102,106,110,112,116,118,122,124,128,132,134,138,142,144,148,152,154,158
	cnop 0,4
bumpMapOffsetY dc.l 62720,62080,62080,62080,62080,62080,62080,62080,62080,62080,61440,61440,61440,61440,60800,60800,60800,60160,60160,60160,59520,59520,58880,58880,58880,58240,58240,57600,56960,56960,56320,56320,55680,55040,55040,54400,53760,53760,53120,52480,52480,51840,51200,50560,50560,49920,49280,48640,48000,47360,46720,46720,46080,45440,44800,44160,43520,42880,42240,41600,40960,40320,39680,39040,38400,37760,37120,37120,36480,35840,35200,34560,33920,33280,32640,32000,31360,30720,30080,29440,28800,28160,27520,26880,26880,26240,25600,24960,24320,23680,23040,22400,21760,21120,20480,19840,19200,18560,17920,17280,16640,16640,16000,15360,14720,14080,13440,13440,12800,12160,11520,11520,10880,10240,10240,9600,8960,8960,8320,7680,7680,7040,7040,6400,5760,5760,5120,5120,5120,4480,4480,3840,3840,3840,3200,3200,3200,2560,2560,2560,2560,1920,1920,1920,1920,1920,1920,1920,1920,1920,1280,1920,1920,1920,1920,1920,1920,1920,1920,1920,2560,2560,2560,2560,3200,3200,3200,3840,3840,3840,4480,4480,5120,5120,5120,5760,5760,6400,7040,7040,7680,7680,8320,8960,8960,9600,10240,10240,10880,11520,11520,12160,12800,13440,13440,14080,14720,15360,16000,16640,17280,17280,17920,18560,19200,19840,20480,21120,21760,22400,23040,23680,24320,24960,25600,26240,26880,26880,27520,28160,28800,29440,30080,30720,31360,32000,32640,33280,33920,34560,35200,35840,36480,37120,37120,37760,38400,39040,39680,40320,40960,41600,42240,42880,43520,44160,44800,45440,46080,46720,46720,47360,48000,48640,49280,49920,50560,50560,51200,51840,52480,52480,53120,53760,53760,54400,55040,55040,55680,56320,56320,56960,56960,57600,58240,58240,58880,58880,58880,59520,59520,60160,60160,60160,60800,60800,60800,61440,61440,61440,61440,62080,62080,62080,62080,62080,62080,62080,62080,62080
	even
	section bss
	even
bumpMapPtr			dc.l	0
bumpLightMapDataPtr	dc.l	0
bumpLightOffsetXnow	dc.w	0
bumpLightOffsetYnow	dc.w	0
bumpMapOffsetXnow	dc.w	0
bumpMapOffsetYnow	dc.w	0
	section text
