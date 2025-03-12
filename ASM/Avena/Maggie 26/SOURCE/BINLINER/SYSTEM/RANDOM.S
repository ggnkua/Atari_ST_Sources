;
;
; RANDOM.S
;
; handles routines for random generation, jittering
; and random "lines" buffers
;
;
;
;
;

; supported:
;
; MACROS
; ran_genrandom		\dataregister
; ran_random_object	\centremid,\offsetmid
; ran_jitter_object	\centremid,\offsetmid,\centretimer\offsettimer

; -------------------------------------------------------------------
ran_genrandom	MACRO				;quick pseudorandom number
		rol.l	\1,\1			;generator code
		add.l	#$42342389,\1
		ENDM


; -------------------------------------------------------------------
; 	declarations for a simple ran_random_object
;
; 	made of the output value, the centre value and the deviation value
;

			rsreset
random_object_centre	rs.w	1
random_object_deviation	rs.w	1
random_object_size	rs.b	1		

; -------------------------------------------------------------------
; 	declarations for a more complex jitter_object
;
; 	made of a random_object for the timer and a random_object
; 	for the output

			rsreset
jitter_object_outval	rs.b	random_object_size
jitter_object_timer	rs.b	random_object_size
; -------------------------------------------------------------------


random_object:		MACRO
			dc.w	\1		;centre
			dc.w	\2		;deviation
			ENDM


jitter_object:		MACRO
			random_object	\1,\2
			random_object	\3,\4
			ENDM

; -------------------------------------------------------------------
random_seed:	dc.w	$4321,$4389

random_generate:
		movem.w	random_seed(pc),d0/d1	; not crypto-strong,
		add.w	#$7283,d1		; but good enough for our
		rol.w	#3,d1			; purposes
		eor.w	d1,d0
		rol.w	d0
		movem.w	d0/d1,random_seed
		rts

; -------------------------------------------------------------------
random_object_init:
		rts

random_object_deinit:
		rts

random_object_getvalue:
					; to get a random value, simply make a
					; random number 0-$ffff, muls by 
					; random_object_deviation, add
					; random_object_centre, return in d0
		bsr	random_generate
		muls.w	random_object_deviation(a0),d0
		add.w	random_object_centre(a0),d0
		rts

; -------------------------------------------------------------------
jitter_object_init:
		rts

jitter_object_deinit:
		rts

jitter_object_getvalue:
					; the jitter object is
					; made of two random objects.
					; first check the counter
		rts

; -------------------------------------------------------------------
; ran_init:	sets up the whole random libraries
; ran_deinit:	"deconstructor"
;
;
;
;
; -------------------------------------------------------------------
ran_init:
		rts


ran_deinit:
		rts