********************
*AYOROS FROM IMPACT*
********************
MUSIC_NUMBER	EQU	1
********************************************************************************
*MUSIC BY MAD MAX, PLAYER BY MAD MAX, EXECUTEUR BY AYOROS
*        NUMBER OF MUSIC COMPOSED BY LOTUS, PRESENT ON THIS DISK
*		FLIGHT.MUS  #1
*	        FLIGHT2.MUS #1,#2,#3
*               FLIGHT3.MUS #1,#2,#3
********************************************************************************   
		SECTION	TEXT
		
		OPT	O+
	
		CLR.L	-(SP)
		MOVE.W	#$20,-(SP)	*superviseur
		TRAP	#1
		ADDQ.L	#6,SP
	
		MOVE.L	D0,-(SP)
		
		MOVE.W	#1,-(SP)	*ecran moyenne resolution
		MOVE.L	#$78000,-(SP)   *adresse ecran $78000 pour 520 ST
		MOVE.L	#$78000,-(SP)   *adresse ecran $F8000 pour 1040 ST
		MOVE.W	#5,-(SP)
		TRAP	#14
		ADDQ.L	#6,SP

		DC.W	$A00A		*cache souris
		
		PEA	TEXT(PC)
		MOVE.W	#9,-(SP)	*affiche txt
		TRAP	#1
		ADDQ.L	#6,SP

		LEA	VU_METRE(PC),A2
		MOVE.L	A2,$4D6.W	*affiche vumetre
		

		LEA	STOP_MOUSE(PC),A4
		ADDQ.L	#3,A4
		MOVE.B	$484.W,(A4)	 *stop clavier bip et souris
		MOVE.B	#2,$484.W
		
		LEA	DATA(PC),A0	*adresse des data_packe
		LEA	MUSIC(PC),A1	*adresse music pour depack
		BSR	depack		*depack music
		
		MOVEQ	#MUSIC_NUMBER,D0	*appel musique
		BSR	MUSIC

		LEA	MUSIC(PC),A0
		ADDA.L	#8,A0
		MOVE.L	A0,$4D2.W		*exec musique
		
TOUCHE_ESPACE	
		CMP.B	#$39,$FFFFFC02.W	*attend appuie sur espace
		BNE.S	TOUCHE_ESPACE
	
		CLR.L	$4D2.W			*stop musique
		CLR.L	$4D6.W			*stop vumetre
		
	
		MOVE.L	#$08080000,$FFFF8800.W	*stop son
		MOVE.L	#$09090000,$FFFF8800.W
		MOVE.L	#$0A0A0000,$FFFF8800.W

STOP_MOUSE	MOVE.B	#$12,$484.W		*remet souris
		DC.W	$A009
	
		CLR.L	-(SP)			*stop programme
		TRAP	#1

VU_METRE
      		LEA     $78000+0+160*160,A0
      		MOVEA.L A0,A1 
      		MOVEA.L A0,A2 
      		MOVE.W  #3,D0 
VU_0		CLR.W   (A0)
      		CLR.W   160(A0) 
      		CLR.W   320(A0) 
      		CLR.W   480(A0) 
      		CLR.W   640(A0) 
      		CLR.W   800(A0) 
    	  	CLR.W   32(A0)
      		CLR.W   192(A0) 
 	     	CLR.W   352(A0) 
      		CLR.W   512(A0) 
	      	CLR.W   672(A0) 
     		CLR.W   832(A0) 
	      	CLR.W   64(A0)
      		CLR.W   224(A0) 
      		CLR.W   384(A0) 
      		CLR.W   544(A0) 
      		CLR.W   704(A0) 
     		CLR.W   864(A0) 
      		CLR.W   96(A0)
      		CLR.W   256(A0) 
      		CLR.W   416(A0) 
      		CLR.W   576(A0) 
      		CLR.W   736(A0) 
      		CLR.W   896(A0)
      		ADDQ.W  #8,A0 
      		DBF     D0,VU_0
      		MOVE.B  #8,$FFFF8800.W
      		MOVE.B  $FFFF8800.W,D0
      		ANDI.W  #$F,D0
VU_1		SUBQ.W  #1,(A1) 
      		SUBQ.W  #1,160(A1)
      		SUBQ.W  #1,320(A1)
      		SUBQ.W  #1,480(A1)
      		SUBQ.W  #1,640(A1)
      		SUBQ.W  #1,800(A1)
 	     	ADDQ.W  #8,A1 
      		DBF     D0,VU_1
 	     	ADDA.L  #$5A0,A2
      		MOVEA.L A2,A1 
  	    	MOVEA.L A2,A0 
      		MOVE.W  #3,D0 
VU_2:		CLR.W   (A0)
      		CLR.W   160(A0) 
      		CLR.W   320(A0) 
	     	CLR.W   480(A0) 
      		CLR.W   640(A0) 
	     	CLR.W   800(A0) 
      		CLR.W   32(A0)
      		CLR.W   192(A0) 
      		CLR.W   352(A0) 
      		CLR.W   512(A0) 
	      	CLR.W   672(A0) 
      		CLR.W   832(A0) 
	      	CLR.W   64(A0)
      		CLR.W   224(A0) 
	      	CLR.W   384(A0) 
      		CLR.W   544(A0) 
	      	CLR.W   704(A0) 
      		CLR.W   864(A0) 
	      	CLR.W   96(A0)
      		CLR.W   256(A0) 
	      	CLR.W   416(A0) 
      		CLR.W   576(A0) 
	      	CLR.W   736(A0) 
      		CLR.W   896(A0) 
      		ADDQ.W  #8,A0 
      		DBF     D0,VU_2
      		MOVE.B  #9,$FFFF8800.W
      		MOVE.B  $FFFF8800.W,D0
      		ANDI.W  #$F,D0
VU_3:		SUBQ.W  #1,(A1) 
      		SUBQ.W  #1,160(A1)
      		SUBQ.W  #1,320(A1)
      		SUBQ.W  #1,480(A1)
      		SUBQ.W  #1,640(A1)
      		SUBQ.W  #1,800(A1)
      		ADDQ.W  #8,A1 
      		DBF     D0,VU_3
      		ADDA.L  #$5A0,A2
      		MOVEA.L A2,A1 
      		MOVEA.L A2,A0 
      		MOVE.W  #3,D0 
VU_4:		CLR.W   (A0)
      		CLR.W   160(A0) 
      		CLR.W   320(A0) 
      		CLR.W   480(A0) 
      		CLR.W   640(A0) 
      		CLR.W   800(A0) 
      		CLR.W   32(A0)
      		CLR.W   192(A0) 
	      	CLR.W   352(A0) 
      		CLR.W   512(A0) 
	      	CLR.W   672(A0) 
      		CLR.W   832(A0) 
      		CLR.W   64(A0)
      		CLR.W   224(A0) 
      		CLR.W   384(A0) 
      		CLR.W   544(A0) 
      		CLR.W   704(A0) 
      		CLR.W   864(A0) 
      		CLR.W   96(A0)
      		CLR.W   256(A0) 
      		CLR.W   416(A0) 
      		CLR.W   576(A0) 
      		CLR.W   736(A0) 
      		CLR.W   896(A0) 
      		ADDQ.W  #8,A0 
      		DBF     D0,VU_4
      		MOVE.B 	#$A,$FFFF8800.W 
      		MOVE.B 	$FFFF8800.W,D0
  	    	ANDI.W  #$F,D0
VU_5:		SUBQ.W  #1,(A1) 
		SUBQ.W  #1,160(A1)
      		SUBQ.W  #1,320(A1)
      		SUBQ.W  #1,480(A1)
      		SUBQ.W  #1,640(A1)
      		SUBQ.W  #1,800(A1)
      		ADDQ.W  #8,A1 
      		DBF     D0,VU_5
 		RTS
***************************************************************************
depack	include	"a:\ice_unpa.s"

	SECTION	DATA
TEXT	
 DC.B	$1B,'E'
         ********************************************************************************
 DC.B	"              HERE IS....IMPACT SOUNDSHIP MUSIC 3 FOR YOUR PLEASURE             ",$A,$D,$A,$D,$A,$D
 DC.B	"           MUSIC COMPOSED BY MAD MAX, RIPPED AND EXEC_MUSIC BY AYOROS ",$A,$D,$A,$D
 DC.B	"                       MUSIC NAME : ........ THEME (C) 1991                 ",$A,$D,$A,$D,$A,$D
 DC.B	"THIS DISK WAS IMPROVED BY AYOROS, AND MOTIVATE BY ARAKIS ( WHO SWAPP THE DISK! )",$A,$D
 DC.B	"                             TO CONTACT US WRITE TO                             ",$D,$A
 DC.B	"      IMPACT OR ARAKIS  8 RUE BRUYERE DES BADAUDS  1428 LILLOIS  BELGIUM        ",$D,$A
 DC.B   "                           NO ILLEGAL SWAPPING PLEASE                           ",$A,$D
 DC.B	"                                 GREETINGS GO TO                                ",$D,$A
 DC.B	"ETERNAL, HOTLINE (ESP. RUTHLESS), FACTORY (HOOKER,RADIAL,MC REGGIE,ZORVACK,VAND)",$D,$A
 DC.B   "ARAKIS (FRODON), FUN VISION (NIC), ELITE (ALL MEMBERS), MYSTIC (LTK MR SPIRIT)  ",$D,$A
 DC.B	"   THE PENDRAGONS (SILVER), NEXT (LEM), FARAMIR, PHENIX, TSB, RADICAL BANDITS,  ",$D,$A
 DC.B	"    THE SYNDICATE (ALL MEMBERS), THE REPLICANTS (SNAKE), NIGHTHAWK, SWEETECH    ",$D,$A	
 DC.B	"ZUUL, FM, THE PROPHANATORS, DELTA FORCE, THE UNION, AUTOMATION, POMPEY PIRATES  ",$D,$A
 DC.B	"FIREHAWK, THE OVERLANDERS (DAUGUE DE MAUVE), THALION CREW, THE LOST BOYS (SAMMY)",$D,$A
 DC.B	"    DNT (AXIOM), EQUINOX, MAD VISION (ALEXIS), BAD BOYS, OMEGA, SYNC, AND HMD.  ",$A,$D  
 DC.B	0	
 
	EVEN
DATA	INCBIN	A:\FLIGHT.MUS\FLIGHT.MUS
	EVEN
	section bss
MUSIC		
	ds.b	30000