*	Created by TT-Digger v7.1
*	Fri Sep 14 17:51:20 2007

*	TT-Digger v7

	ds.b	4928
.ENDMOD
.MODULE ftimtotm
	 lea 	 -18(a7),a7		       ; 47757 FFEE	     O   
	 moveq	 #31,d0			       ; 70037 		     p 
	 and	 (a0),d0		       ; C0120 		      P
	 add	 d0,d0			       ; D0100 		      @
	 move	 d0,(a7)		       ; 37200 		     >€
	 move	 (a0),d1		       ; 31020 		     2 
	 lsr	 #5,d1			       ; E5111 		      I
	 and	 #63,d1			       ; C1174 003F	      | ?
	 move	 d1,2(a7)		       ; 37501 0002	     ?A  
	 move	 (a0),d2		       ; 32020 		     4 
	 moveq	 #11,d0			       ; 70013 		     p 
	 lsr	 d0,d2			       ; E0152 		      j
	 and	 #31,d2			       ; C2174 001F	      |  
	 move	 d2,4(a7)		       ; 37502 0004	     ?B  
	 moveq	 #31,d1			       ; 71037 		     r 
	 and	 2(a0),d1		       ; C1150 0002	      h  
	 move	 d1,6(a7)		       ; 37501 0006	     ?A  
	 move	 2(a0),d2		       ; 32050 0002	     4(  
	 lsr	 #5,d2			       ; E5112 		      J
	 and	 #15,d2			       ; C2174 000F	      |  
	 subq	 #1,d2			       ; 51502 		     SB
	 move	 d2,8(a7)		       ; 37502 0008	     ?B  
	 move	 2(a0),d0		       ; 30050 0002	     0(  
	 moveq	 #9,d1			       ; 71011 		     r 
	 lsr	 d1,d0			       ; E1150 		      h
	 and	 #127,d0		       ; C0174 007F	      |  
	 add	 #80,d0			       ; D0174 0050	      | P
	 move	 d0,10(a7)		       ; 37500 000A	     ?@  
	 lea 	 (a7),a0		       ; 40727 		     A 
	 bsr 	 _cnvDatSec		       ; 60400 00DA	     a   
	 moveq	 #1,d1			       ; 71001 		     r 
	 bsr 	 _conSecDat		       ; 60400 017A	     a  z
	 lea 	 18(a7),a7		       ; 47757 0012	     O   
	 rts				       ; 47165 		     Nu


