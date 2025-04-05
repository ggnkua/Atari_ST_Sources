;
; DUMP
;
; September 21, 2003
; Anders Eriksson
; ae@dhs.nu
;
; modtype.s

		section	text


		move.l	filebuffer,a0				;address to module
		move.l	1080(a0),d0				;get value at offset #1080


		cmp.l	#"M.K.",d0				;noisetracker 4ch
		beq.s	.pt4ch					;

		cmp.l	#"M!K!",d0				;noisetracker 4ch
		beq.s	.pt4ch					;

		cmp.l	#"M&K&",d0				;noisetracker 4ch
		beq.s	.pt4ch					;

		cmp.l	#"FLT4",d0				;startrekker 4ch
		beq.s	.pt4ch					;

		cmp.l	#"RASP",d0				;startrekker 4ch
		beq.s	.pt4ch					;

		cmp.l	#"FA04",d0				;Digital tracker 4ch (old vers)
		beq.s	.pt4ch					;


		cmp.l	#"6CHN",d0				;Fasttracker 6ch
		beq.s	.misc6ch				;

		cmp.l	#"CD61",d0				;Octalyser STe 6ch
		beq.s	.misc6ch				;

		cmp.l	#"06CH",d0				;Fasttracker xxch
		beq.s	.misc6ch				;

		cmp.l	#"FA06",d0				;Digital tracker 6ch (old vers)
		beq.s	.misc6ch				;


		cmp.l	#"8CHN",d0				;Fasttracker 8ch
		beq.s	.misc8ch				;

		cmp.l	#"CD81",d0				;Octalyser STe 8ch
		beq.s	.misc8ch				;

		cmp.l	#"FLT8",d0				;Startrekker 8ch
		beq.s	.misc8ch				;

		cmp.l	#"08CH",d0				;Fasttracker xxch
		beq.s	.misc8ch

		cmp.l	#"OCTA",d0				;Octalsyer STe (old vers)
		beq.s	.misc8ch				;

		cmp.l	#"FA08",d0				;Digital tracker 8ch (old vers)
		beq.s	.misc8ch				;


		bra.w	exit_unknown



.pt4ch:		move.l	#"M.K.",1080(a0)			;put general 4ch header
		move.b	#"4",channels_text+10			;
		bra.s	.done					;

.misc6ch:	move.l	#"CD61",1080(a0)			;put general 6ch header
		move.b	#"6",channels_text+10			;
		bra.s	.done					;

.misc8ch:	move.l	#"CD81",1080(a0)			;put general 8ch header
		move.b	#"8",channels_text+10			;


.done:

		section	text
		