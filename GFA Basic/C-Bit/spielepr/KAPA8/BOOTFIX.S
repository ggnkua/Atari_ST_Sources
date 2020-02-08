*******************************
;
;		Bootet Demos
;
;		kann genutzt werden um bestimmte Anpassungen
;   vor dem Booten problematicher Programme
;		vorzunehmen !!!
;
; (Schaltet Cache aus)
; (und Falcon auf 8 MHz) 

 
                move.l  #$020002,-(SP) ;BIOS 2 (warte auf Taste)
                trap    #13
                addq.l  #4,SP
                pea     install(PC)
                move.w  #38,-(SP) ;Superexec (ausfÅhren im Supervisormodus)
                trap    #14
                addq.l  #6,SP


install:        
                	
								movec   cacr,d0
;								andi #$fefe,d0	;CACHE aus (fÅr TT/Falcon)
;								movec   d0,cacr
;    						bclr	#0,$ffff8007.w ; 8MHZ Falcon
                move.w  #0,$0446.w
                movea.l $047A.w,A0		;Vektor zur Bootroutine
                jsr     (A0)					;Springe Bootroutine an
                tst.l   D0
                bne.s   res
                lea     $0600,A0
                movem.l (A0)+,D0-A6
                movea.l #$FC03EA,A6 ;KompatiblitÑt zu gewissen Demos
                movea.l $04C6.w,A0  ;Adresse des Sektorpuffers
                jsr     (A0)				
res:            move.l  4,-(SP)			;RESET
                move.w  #38,-(SP)
                trap    #14
                END
