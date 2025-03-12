; G.S.R.V.3. Replay Code.

; Coderight P.H.F. August 1992

; Use this code after you have converted your music file to a GSR file.

; Music    = Relocation
; Music +4 = Initilisation
; Music +8 = VBL Call

	opt x+					
	clr.l -(sp)			;Super mode
	move.w #$20,-(sp)			
	trap #1					
	lea 6(sp),sp				
	move.l d0,oldstk			
	bclr #0,$484.w			;Kill click	

	bsr	music			;Relocation

;	move.l	#1,d0			;Tunes ? , If Applicable			

	bsr	music+4			;Initialisation

	bsr	turnon			;Turn on music

	move.w #8,-(sp)			;Wait for a key press	
	trap #1					
	lea 2(sp),sp				

	bsr turnoff			;Turn off music

	move.l oldstk,-(sp)			

	move.w #$20,-(sp)		;User mode	
	trap #1					
	lea 6(sp),sp  				

	clr.w -(sp)			;See yooo	
	trap #1		
			

grazey	movem.l d0-a6,-(sp)		;Save registers	
	jsr	music+8			;Call music
	movem.l (sp)+,d0-a6		;restore registers
	move.l old70,-(sp)		;Move old vbl to stack	
	rts					

turnon	move.l $70.w,old70		;Save old vbl
	move.l #grazey,$70.w		;Install my new vbl	
	rts

turnoff	move.l old70,$70.w		;Restore old vbl
	move.l #$08080000,$ff8800	;Clear sound registers	
	move.l #$09090000,$ff8800		
	move.l #$0a0a0000,$ff8800		
	rts

oldstk	dc.l 0
old70	dc.l 0

music	incbin "microgp.gsr"		; Converted Music ( Ripped by Grz )
     					; By Dave Lowe

