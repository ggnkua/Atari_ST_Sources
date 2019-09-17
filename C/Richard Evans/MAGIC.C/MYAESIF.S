; Modified _AESif code for LC 5.52 supporting some newer functions
; Only the relevant MagiC functions have the supporting routines included
; I cannot guarantee the reliability of this code, so please check
; It thoroughly before incorporating it into LCG.LIB   	
; If there are errors, please correct them and send me a copy if possible
; Richard Evans 07/08/94  		
		
		
		
		XDEF 	@_AESif	
		XREF 	__AESpb
		XREF 	__AESintout
	
		SECTION TEXT
	
@_AESif		lea 	$22(pc),a0
		move.l	$0(a0,d0.w),d0
		lea 	__AESpb(a4),a0
		movea.l (a0),a1
		movep.l d0,$1(a1)
		move.l 	a0,d1
		move.w 	#$c8,d0
		trap 	#$2
		lea 	__AESintout(a4),a0
		move.w 	(a0),d0
		ext.l 	d0
		rts
		dc.l 	$0A000100
		dc.l 	$0B020101
		dc.l 	$0C020101
		dc.l 	$0D000101
		dc.l 	$0E020101
		dc.l 	$0F010101
		dc.l 	$10020100	;GEM 2.0
		dc.l 	$11000100	;GEM 2.0
		dc.l 	$12010301	;AES 4.0
		dc.l 	$13000100
		dc.l 	$14000100
		dc.l 	$15030500
		dc.l 	$16050500
		dc.l 	$17000101
		dc.l 	$18020100
		dc.l 	$19100701
		dc.l 	$1A020100
	        dc.l 	$1B000000
	        dc.l 	$1C000000
	        dc.l 	$1D000000
		dc.l 	$1E010101
		dc.l 	$1F020101
		dc.l 	$20020101
		dc.l 	$21020101
		dc.l 	$22010102
		dc.l 	$23010101
 		dc.l 	$24010100	;GEM 2.0
        	dc.l 	$25000000
        	dc.l 	$26000000
        	dc.l 	$27000000
		dc.l 	$28020101
		dc.l 	$29010101
		dc.l 	$2A060101
		dc.l 	$2B040101
		dc.l 	$2C010301
		dc.l 	$2D020101
		dc.l 	$2E040201
		dc.l 	$2F080101
        	dc.l 	$30000000
        	dc.l 	$31000000
 		dc.l 	$32010203	;MagiC form_xdo
		dc.l 	$33090102	;MagiC form_xdial
		dc.l 	$34010101
		dc.l 	$35010100
		dc.l 	$36000501
		dc.l 	$37030301
		dc.l 	$38020201
   	    	dc.l 	$39000000
        	dc.l 	$3A000000
        	dc.l 	$3B000000
        	dc.l 	$3C000000
        	dc.l 	$3D000000
        	dc.l 	$3E000000
        	dc.l 	$3F000000
		dc.l 	$40000000
		dc.l 	$41000000
		dc.l 	$42000000
		dc.l 	$43000000
		dc.l 	$44000000
		dc.l 	$45000000
		dc.l 	$46040300	
		dc.l 	$47080300
		dc.l 	$48060100
		dc.l 	$49080100
		dc.l 	$4A080100
		dc.l 	$4B040101
		dc.l 	$4C030101
		dc.l 	$4D000500
		dc.l 	$4E010101
		dc.l 	$4F000500
		dc.l 	$50000101
		dc.l 	$51000101
		dc.l 	$52000100	;GEM 2.0
        	dc.l 	$53000000
        	dc.l 	$54000000
        	dc.l 	$55000000
        	dc.l 	$56000000
        	dc.l 	$57000000
        	dc.l 	$58000000
        	dc.l 	$59000000
		dc.l 	$5A000202
		dc.l 	$5B000203	;TOS 1.4
        	dc.l 	$5C000000
        	dc.l 	$5D000000
        	dc.l 	$5E000000
        	dc.l 	$5F000000
        	dc.l 	$60000000
        	dc.l 	$61000000
        	dc.l 	$62000000
        	dc.l 	$63000000
		dc.l 	$64050100
		dc.l 	$65050100
		dc.l 	$66010100
		dc.l 	$67010100
		dc.l 	$68020500
		dc.l 	$69060100
		dc.l 	$6A020100
		dc.l 	$6B010100
		dc.l 	$6C060500
		dc.l 	$6D000000	;TOS 1.4
		dc.l 	$6E000101
		dc.l 	$6F000100
		dc.l 	$70020100
		dc.l 	$71020101
		dc.l 	$72010101
        	dc.l 	$73000101	;MTOS rsrc_rcfix
        	dc.l 	$74000000
        	dc.l 	$75000000
        	dc.l 	$76000000
        	dc.l 	$77000000
		dc.l 	$78000102
		dc.l 	$79030102
		dc.l 	$7A010101
		dc.l 	$7B010101
		dc.l 	$7C000101
		dc.l 	$7D000103
		dc.l 	$7E000102	;GEM 2.0
		dc.l 	$7F000002	;GEM 2.0
		dc.l 	$80000000
		dc.l 	$81000000
		dc.l 	$82010500	;AES 4.01 appl_getinfo
		dc.l 	$83090100	;GEM 2.0
        	dc.l 	$84000000
        	dc.l 	$85000000
        	dc.l 	$86000000
        	dc.l 	$87020101	;MagiC form_popup
        	dc.l 	$88020101	;Magic form_xerr

		END