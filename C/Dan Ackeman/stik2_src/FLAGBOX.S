; flagbox.s           (c)Steve Adam 1995        steve@netinfo.com.au
;
; A short function to test and set flags using TAS for operation
; in a preemptive multitasking environment.
;
; Each flag occupies a whole byte, due to the way TAS works.
;
; 64 flags should probably do forever...
;
	MC68000

	EXPORT flagbox, set_flag, clear_flag, test_flag

	TEXT
set_flag:	move.w	4(a7), d0
			lea		flagbox, a0
			tas		0(a0, d0)
			beq.s	was_clear
			moveq	#1, d0		/* Return TRUE is flag was set		*/
			rts
was_clear:	moveq	#0, d0		/* Otherwise return FALSE (success)	*/
			rts

test_flag:	move.w	4(a7), d0
			lea		flagbox, a0
			tst.b	0(a0, d0)
			beq.s	was_clear
			moveq	#1, d0		/* Return TRUE is flag was set		*/
			rts

clear_flag:	move.w	4(a7), d0
			lea		flagbox, a0
			move.b	#0, 0(a0, d0)
			rts
	BSS

flagbox:
	ds.b	64

	END
