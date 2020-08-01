


*****************************************************************
*                >PART 'initialising'
*********************************************************************
*       initialising the system
*********************************************************************
*On the returnstack there will come only one pointer to a structure,
*which contains all necessary data to run F68KANS which are
;registers:    DS.L 16         ;d0,d1,d2,d3.......,a5,a6,a7
;forthregs:    DS.L 4          ;a3,a5,a6,a7
;TIBptr        DS.L 1
;codelen:      DS.L 1
;datalen:      DS.L 1
;SI_GROUP		DS.L 1			;Pointer to the System Interface


forthregs       EQU 16*4
TIBptr          EQU forthregs+(4*4)
codelen         EQU TIBptr+4
datalen         EQU codelen+4
SI_group       	EQU datalen+4


;; A0 is important during initialisation!!!

sys:
init:           move.l  A0,-(SP)
                addq.l  #8,SP           ;A7 to returnheigth
                movea.l (SP),A0         ;Pointer to parastruc
                movem.l D0-A7,(A0)      ;save all registers
                move.l  -8(SP),8*4(A0)  ;save old A0, too
                movea.l -4(SP),A1       ;get returnaddress

                movem.l forthregs(A0),A3/A5-A7 ;load forth registers

                adda.l  #of,A5          ;points to the middle of first segment
                move.l  A0,D0			;pointer to forthparas
                sub.l   A3,D0			;make it data segment relativ 
                move.l  D0,(tforthparas-datas)(A3)	;and save it
                move.l  A1,(bootsys-datas)(A3) 		;remember exit
                move.l  (15*4)(A0),(saveret-datas)(A3) ;remember loaders SP

	* relocate the segment table
                lea     (table-datas)(A3),A1 	;pointer to the table
                move.l  A5,D1           		;0.th segment pointer
                move.l  #(tablesize-1),D0
relo_loop:
                move.l  D1,(A1)+
                addi.l  #$010000,D1
                dbra    D0,relo_loop


	* set memory parameters
                move.l  (bootuser-datas)(A3),D5 	;initialize USER-Pointer

                move.l  codelen(A0),D0  ;fetch length of code
                add.l   A5,D0           ;calculate systop
                sub.l   A3,D0           ;make ist rel. to DT
                subi.l  #of,D0          ;substract offset
                move.l  D0,(tsystop-datas)(A3) ;set systop

                move.l  datalen(A0),D0  ;fetch length of data
                move.l  D0,(tdatatop-datas)(A3) ;set datatop
                move.l  #0,(tdatabot-datas)(A3) ;because all rel. to DT
                lea     -of(A5),A1
                suba.l  A3,A1           ;calculate offset of segm.
                move.l  A1,(tsysbot-datas)(A3) ;set it


	* fetch stackbases
                move.l  D5,D0
                addi.l  #ototib,D0
                move.l  TIBptr(A0),D1
                sub.l   A3,D1           ;make pointer relativ
                move.l  D1,0(A3,D0.w)   ;set >TIB

	* now fetch I/O-addresses
	*
	* The first entry in the SI_group has to be the BIOS table.
	* Let's have a look after it.
	*
			move.l	SI_group(a0),a1		;pointer to the System Interface SI
			cmp.l	#'BIOS',(a1)
			bne		biosmissing
		*ok, the BIOS seems to be there
				
			move.l	4(a1),a1			;pointer to BIOS functiontable	
			
sibioskey		equ		0
sibioskey_quest equ		4	
sibiosemit		equ		8
sibiosemit_quest equ	12
			
		*KEY		
                move.l  D5,D0
                addi.l  #olkey,D0
                move.l  sibioskey(A1),D1
*                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,0(A3,D0.l)   ;set KEY
                
		*KEY?		
                move.l  D5,D0
                addi.l  #olkey_quest,D0
                move.l  sibioskey_quest(A1),D1
*                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,0(A3,D0.l)   ;set KEY?
                
		*EMIT		
                move.l  D5,D0
                addi.l  #olemit,D0
                move.l  sibiosemit(A1),D1
*                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,0(A3,D0.l)   ;set EMIT
                

		*EMIT?		
                move.l  D5,D0
                addi.l  #olemit_quest,D0
                move.l  sibiosemit_quest(A1),D1
*                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,0(A3,D0.l)   ;set EMIT?
                
                  

	* now initialise with given pointers

                move.l  D5,D0
                addi.l  #osnull,D0
                move.l  A6,D1
                sub.l   A3,D1           ;make pointer relativ
                move.l  D1,0(A3,D0.l)   ;set data-stackbase

                move.l  D5,D0
                addi.l  #ornull,D0
                move.l  SP,D1
                sub.l   A3,D1           ;make pointer relativ
                move.l  D1,0(A3,D0.l)   ;set returnstack

                move.l  #(hello-datas),-(A6)
*                move.l  #50,-(A6)
				bsr		count
                bsr     type

                jmp     (cold-(sys+of))(A5) ;jump into the system


************* Errors *******************
biosmissing: 	jmp		(bye-sys-of)(a5)	; ...


*				rts			;jump out of the system


*************************************************************************
*                ENDPART
