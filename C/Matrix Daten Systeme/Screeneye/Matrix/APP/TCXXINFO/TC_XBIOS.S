/*	tc_xbios.s	/	MATRIX	/	WA	31.7.91	*/
			
				.include	"\tc\matlib\sys_vars.i"
				.include	"\tc\matlib\xbra.i"

				.include	"tcxxinfo.i"
		
				.super

;----------------------------------- tc xbios trap handler -----------

				.export	fct_xbios
				.export	old_xbios

				.text

		xbra	xbios,"MTCI"
				
				btst	#13,(sp)		;	super mode	?
				bne		xb_super
				
				move.l	usp,a1			;	user mode
				move.w	(a1),d0
				bra		xb_user

xb_super:		move.l	sp,a1			;	super mode

				tst		_longframe
				beq		xb_68000
				move.w	8(a1),d0		;	68030 : bios call number
				bra		xb_user
xb_68000:
				move.w	6(a1),d0		;	68000 : bios call number
				

xb_user:		cmpi.w	#CHECKinst,d0
				blt		start_old
				beq		check_inst

				cmpi.w	#GETscreen,d0
				beq		get_screen
				
				cmpi.w	#GETboard,d0
				beq		get_board
				
				
start_old:		move.l	old_xbios,a1	;	no ext. BIOS call
				jmp		(a1)


**************************************************************************				


				.import	screen_parameter,board_parameter

check_inst:		move.l	#INSTokay,d0
				rte

get_screen:		move.l	screen_parameter,d0
				rte

get_board:		move.l	board_parameter,d0
				rte

				.end