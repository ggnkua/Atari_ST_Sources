; The PHF hit back with -   \\ Froggies Over The Fence musics //

; All musics by Jess Of The Overlanders (formerly Ninja Turtle Of Undead)
; 


; All 50 musics hacked in 5 minutes! using my de-linker by
; Grazey Of P.H.F. (1/12/93)

; The worst bit was typing all the bloody tune names in!
; loadsa great tunes here! goto end of file!

; NOTE! Songs	?a.mus	are on Zak Hacks #14
; NOTE! Songs	?b.mus	are on Zak Hacks #15

grazey	opt x-

	clr.l	-(sp)				
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack+2
	bclr	#0,$484.w				

	clr	d0
	bsr	music

.ll	bsr	music+8
	move	$468.w,d0
.ll1	cmp	$468.w,d0
	beq.s	.ll1
	cmp.b	#$39,$fffffc02.w
	bne.s	.ll

quit	bsr	music+4

stack	move.l	#stack,-(sp)			
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr	-(sp)				
	trap	#1					

music	incbin 	gb.mus
endmus	

;Tunes				Filename

;My First Resonant Burp		aa.mus	\
;Throw It In A Trash Can	ba.mus	|
;The Legacy Nightmare		ca.mus	|
;Jochen Spirit			da.mus	|
;The Undead Horror Show		ea.mus	|
;I Want U To Shoot Zem Up	fa.mus	|
;The Singing Green Frog		ga.mus	|
;Cubase versus Notator		ha.mus	|
;Tears On My Keyboard		ia.mus	|
;For Your Loader 1		ja.mus	|
;For Your Loader 2		ka.mus	|
;For Your Loader 3		la.mus	----- Zak Hacks #14
;That's Illogical Captain	ma.mus	|
;Generation 2.0			na.mus	|
;Hardrock Ballad		oa.mus	|
;The Popples Revenge		pa.mus	|
;Let The Djoard Bells Ring	qa.mus	|
;Unfinished,Sorry AN Cool	ra.mus	|
;Do You Speak Russian		sa.mus	|
;Run For Your Life		ta.mus	|
;Middle Earth Theme		ua.mus	|
;Sharpness Buzztone		va.mus	|
;The Twins Paradoie		wa.mus	|
;Protect Your Environment	xa.mus	|
;Another Western Legend		ya.mus	/

;Pentatonik Illusion		ab.mus	\
;A Sixties Slow			bb.mus	|
;My ST Suntans in Brazil	cb.mus	|
;Lemon Squeezers Dream		db.mus	|
;My Name Is Jess, Jess Bond	eb.mus	|
;SOS : Means Save Our ST	fb.mus	|
;Best Part: Ze 16 mns hit	gb.mus	|
;Please No			hb.mus	|
;Wave Mania Is My Passion	ib.mus	|
;The Battle Of Arpegios		jb.mus	|
;Not a Soporific Lullaby	kb.mus	|
;Throw The Confettis		lb.mus	----- Zak Hacks #15
;Psychosonorous Disorder	mb.mus	|
;Super Marios Bros Family	nb.mus	|
;Tra La Li and Tra La La	ob.mus	|
;I Found The Dead Zone		pb.mus	|
;Camerto For Acid Band		qb.mus	|
;Akira Versus San Go Ku		rb.mus	|
;970 Bytes to Swing		sb.mus	|
;See Ya Again on Falcon		tb.mus	|
;If It Works Good		ub.mus	|
;This Music			vb.mus	|
;Once Again			wb.mus	|
;Echelle			xb.mus	|
;Guille				yb.mus	/



