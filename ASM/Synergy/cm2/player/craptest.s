; testje om te laten zien dat het werkt.
; klinkt trouwens best wel gaaf !
; Als je iets wil veranderen bel mij dan even, dan weet ik het ook.
; De replayer wordt nog verandert dus die heb ik gescheiden (SCAVY_CM.MUS)
; SoundFX hopelijk in de loop van de week.
; Misschien wel handig om van de functie nummers EQU te maken ?
; song nummers 0-4 zijn de land - Riedeltjes ! -
; song nummer 5 is de Textviewer - Song ! -
; song nummer 6 is de Intro - Song ! -
; Deze test versie is ‚‚n keer gecrashed in de replayer zonder reden.
;  misschien ligt het aan dit simpele test programmaatje, misschien niet.
; functie beschrijvingen in CRAPMAN.S
; misschien wel handig om bij 'do_mus' hier beneden te kijken.  
 
 		Section	Text
 
 		clr.l	-(sp)
 		move.w	#32,-(sp)
 		trap	#1
 		addq.l	#6,sp
 		move.l	d0,user
 		
 		move.b	$484.w,o484
 		clr.b	$484.w
 		
 		moveq	#0,d0		;init Replayer !!!
 		bsr	Sound_Handler
 		move.l	d0,$4d6.w
 		
 		moveq	#1,d0
 		moveq	#5,d1		;init Text viewer music
 		bsr	Sound_Handler
 		
 		move.w	#5,new_mus
 		
loop: 		move.b	$fffffc02.w,d0
 		cmp.b	#57,d0
 		beq	done
 		cmp.b	#1,d0
 		ble	loop
		cmp.b	#6,d0
		ble	do_mus
		cmp.b	#8,d0
		ble	do_sng
		cmp.b	#10,d0
		ble	do_sfx
		bra	loop
		
done: 		clr.l	$4d6.w
 		bsr	cm2+12
 		
 		move.b	o484,$484.w
 		
 		move.l	user,-(sp)
 		move.w	#32,-(sp)
 		trap	#1
 		addq.l	#6,sp
 		clr.w	-(sp)
 		trap	#1	
 
; testje  
; structure:  1. fade huidige muziek uit.
;             2. wacht totdat het helemaal uitgefade is.
;             3. save huidige song. (NA HET FADEN !!!)
;             4. initializeer een Riedeltje.
;             5. wacht totdat het riedeltje afgelopen is.
;             6. restore het vorige muziekje.
;             7. fade het vorige muziekje in.
;             8. wacht totdat het helemaal ingefade is. 
 
do_mus:		and.w	#$00ff,d0
		subq.w	#2,d0
		move.w	d0,new_mus

		moveq	#2,d0			;fade out
		moveq	#10,d1
		bsr	Sound_Handler

wmus:		moveq	#4,d0			;wait fade
		bsr	Sound_Handler
		tst.l	d0
		bmi	wmus
 		
 		moveq	#7,d0			;save mus
 		bsr	Sound_Handler
 		
 		moveq	#1,d0			;init riedel
		move.w	new_mus,d1
 		bsr	Sound_Handler
 			
wried: 		moveq	#6,d0			;wait riedel
 		bsr	Sound_Handler
 		tst.l	d0
 		bmi	wried
 
 		moveq	#8,d0			;restore mus
 		bsr	Sound_Handler
 		
 		moveq	#3,d0			;fade in mus
 		moveq	#6,d1
 		bsr	Sound_Handler
 			
wmus2: 		moveq	#5,d0			;wait fade in
 		bsr	Sound_Handler
 		tst.l	d0
 		bmi.s	wmus2
 
 		bra	loop			;doewie
 
do_sng:		and.w	#$00ff,d0
		subq.w	#7,d0
		move.w	d0,new_sng
		
		moveq	#2,d0			;fade out
		moveq	#10,d1
		bsr	Sound_Handler

wmuss:		moveq	#4,d0			;wait fade
		bsr	Sound_Handler
		tst.l	d0
		bmi	wmuss
		 
 		moveq	#1,d0			;init song
		move.w	new_sng,d1
		addq.w	#5,d1
 		bsr	Sound_Handler
 		
 		bra	loop
 
do_sfx:		move.b	d0,d1
		add.b	#128,d1
sx		cmp.b	$fffffc02.w,d1
		bne.s	sx
		and.w	#$00ff,d0
		sub.w	#9,d0
		move.w	d0,new_sfx 
 		
 		moveq	#9,d0
 		move.w	new_sfx,d1
 		bsr	Sound_Handler
 
 		bra	loop
 		
 		INCLUDE	"E:\CRAPMAN.MUS\CRAPMAN.S"
 		
 		Section	BSS
 		
user:		ds.l	1
o484:		ds.w	1
new_mus:	ds.w	1
new_sng:	ds.w	1
new_sfx:	ds.w	1

		End 		