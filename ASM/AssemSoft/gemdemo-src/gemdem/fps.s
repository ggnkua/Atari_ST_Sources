;  ___________     ______   ______    ____________
; !           \   !      ! !      !  /           /
; ! !    _     \  ! !    !_!      ! / /  _______/
; ! !   ! \     \ ! !             ! \ \         \
; !     !_/   / / !       _     ! !  \_______  \ \
; !          / /  !      ! !    ! !  /         / /
; !___________/   !______! !______! /___________/
;                  /|     &   /\
;                 /_|        /__
;                /  |ssem   ___/oft
;
; GemDemo - Atari and compatibles.
;
; File: fps.s
; Desc: Frames per second calculator
; Edit: June 10, 1998 - 02.30 CET
; Info: Coding by Evil/DHS.
;       'fps_50hz' should run from 50Hz interupt
;       'fps' should run once each mainloop
;
;       Current fps = fps_real (long)
;       Average fps = fps_average (long)
;    Seconds in use = fps_seconds (long)
; Number of updates = fps_updates (long)
;
;       Tablength = 8

		rsreset
FPS_real:	rs.l	1
FPS_average:	rs.l	1
FPS_updates:	rs.l	1
FPS_seconds:	rs.l	1
FPS_frames:	rs.l	1
FPS_second:	rs.b	1
		rs.b	1
FPS_ssize:	= __RS



	section text


fps_50hz:	;cmp.b	#49,fps_second		;see if 1 sec has gone..
		;beq.s	.ok			;yes
		;add.b	#1,fps_second		;no

		subq.b	#1,fps_second
		beq.s	.ok
		rts

.ok:		move.l	fps_frames,fps_real	;put last seconds fps for read
		clr.l	fps_frames		;okey.. let's clear and do it again..
		;clr.b	fps_second		;
		move.b	#49,fps_second
		
		addq.l	#1,fps_seconds		;total seconds in progress
		move.l	fps_seconds,d0		;get all secs
		move.l	fps_updates,d1		;get all updates done
		divu.l	d0,d1			;get average fps
		move.l	d1,fps_average		;store average fps
		rts

fps:		addq.l	#1,fps_frames
		addq.l	#1,fps_updates
		rts

		;section bss
fps_real:	ds.l	1	;current fps
fps_average:	ds.l	1	;average fps
fps_updates:	ds.l	1	;number of updates done totally
fps_seconds:	ds.l	1	;how many secs we have been running

fps_frames:	ds.l	1	;frame counter per second
fps_second:	ds.b	1	;second counter (50 Hz timer)
		even

	