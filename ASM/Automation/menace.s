//
// Most of this code was written in a position independant format. This was a kickback from the Sinclair QL days as is the
// use of Trap exceptions. No particular reason for using them except that it was "clean".
//

//
// Defines for trap #4 calls
//
SYS_SET_VIDEOBASE		equ		0
SYS_SET_PALETTE			equ		1
SYS_SET_AUDIO			equ		2
SYS_SET_PALETTE_ENTRY	equ		3
SYS_PRINT_CHAR			equ		5
SYS_PRINT				equ		6
SYS_DELAY_FRAMES		equ		7

FRAME_BUFFER_COUNT		equ		8
BYTES_PER_LINE			equ		160
MAX_PROJECTILES			equ		15
ALIEN_COUNT				equ		15

//
// Graphic data absolute addresses
GFX_LEVEL_PALETTES		equ		$3fdc
GFX_LANDSCAPE_PALETTES	equ		$4142
GFX_PALETTE				equ		$4a2c
GFX_TOP_OUTRIDER		equ		$4a74
GFX_BTM_OUTRIDER		equ		$4aaa	
//
// Hardware addresses
HW_ACIA_BASE			equ		$fffffc00
HW_ACIA_CONTROL			equ		$fffffc00
HW_ACIA_DATA			equ		$fffffc02

HW_VIDEO_BASE			equ		$ffff8200
HW_VIDEO_SYNC			equ		$ffff8204
HW_VIDEO_PALETTE		equ		$ffff8240
						rsreset
SPRITE_X				rs.w	1
SPRITE_Y				rs.w	1
						rs.b	8
SPRITE_SIZEOF			rs.b	0		// Should be 12

			rsreset			
// Should be 12 bytes!
proj.life	rs.w	1
proj.x		rs.w	1
proj.y		rs.w	1
proj.xvel	rs.w	1
proj.yvel	rs.w	1
proj.b1		rs.b	1
proj.b2		rs.b	1

proj.size	rs.b	0


						rsreset
screen.base				rs.l	1
other.screen			rs.l	1
LevelPalettePtr			rs.l	1
FrameBufferIndex		rs.w	1
game.stage				rs.w	1
FrameRateLock			rs.w	1

level.number			rs.w	1

keycode					rs.b	1

ship.x					rs.w	1
ship.y					rs.w	1
ship.collision			rs.b	1
ship.damage				rs.w	1
ship.speed				rs.w	1
ship.energy				rs.w	1
forcefield.timer		rs.w	1
LandscapeDamage			rs.w	1
BonusScoreInc			rs.w	1
KillScoreInc			rs.w	1


mult1.on				rs.b	1
mult2.on				rs.b	1
speedup.bonuses			rs.b	1
outrider.bonuses			rs.b	1
forcefield.bonuses		rs.b	1
all.coords				rs.w	1
demo.timer			rs.w	1
screen.bufptrs		rs.l	FRAME_BUFFER_COUNT
restore.bufptrs		rs.l	FRAME_BUFFER_COUNT
projectiles				rs.b	SPRITE_SIZEOF*ALIEN_COUNT
draw.list				rs.w	3*ALIEN_COUNT
alien.state				rs.b	table.size*ALIENT_COUNT
restore.buffers			rs.b	3024*FRAME_BUFFER_COUNT
scroll.buffer			rs.b	6*4*16*12
scroll.buffer2			rs.b	6*4*16*12

*		*********************************
*		*	Data structures		*
*		*********************************

	rsreset
next.path				RS.W	1			offset to the next path		0
x.pos					RS.W	1			current x position			2		
y.pos					RS.W	1			current y position			4
kills.what				RS.W	1			kills others if dead (0-11)	6
table.offset			RS.W	1			the current table offset	8
sprite.num				RS.B	1			sprite number				10
anim.num				RS.B	1			animation number			11
anim.delay				RS.B	1			delay in 1/25 secs			12
anim.delay2				RS.B	1			static delay				13
speed					RS.B	1			speed in pixels				14
pause.count				RS.B	1			dynamic pause counter		15
mode					RS.B	1			flags, see bleow			16
loop.offset				RS.B	1			loop offset (-ve)			17
loop.count				RS.B	1			dynamic loop count			18
hits.num				RS.B	1			number of hits to kill		19
num.anims				RS.B	1			no of animations			20
seek.count				RS.B	1			dynamic seek count			21
table.size				RS.B	0										22?

* This is followed by x,y bytes to move to (always even) with the following
* special codes

*	x = 0, path finished, terminate alien
*	x = $e0, perform a pause (up to 10 secs), followed by the pause value, $ff forever
*	x = $e1, perform the loop
*	x = $e2, toggle the offset mode
*	x = $e3, speed change, followed by new speed byte
*	x = $e4, sprite change, followed by sprite num, max anims
*	x = $e5, start seek mode, followed by count & two 0 bytes
*	x = $e6, reload the aliens x,y coords, followed by two xy bytes
*	x = $e7, reload the table offset, old one stored in loop.offset
*	x = $e8, restore the old table offset
*	x = $e9, fire a heat seeker, followed by count
*	x = $ea, new animation number, followed by animation number
*	x = $eb, repeat table indefinitely

*	mode bit 0 = offset mode
*	     bit 1 = seek mode
*	     bit 2 = 
*	     bit 3 = up/down animation type
*	     bit 4 = 0-animate up/1-animate down
*	     bit 5 = heat seeker path

EntryPoint
			movea.l		#StackTop,a0
			movea.l		a0,a7
			suba.w		#$100,a0
			move		a0,usp									// Set supervisor and user stack ptrs
			lea			GlobalVariables,a6						// Ptr to global variables
			move.w		#$40,d1
			movea.l		#$fffffa13,a0							// Set keyboard interrupt
			movep.w		d1,$0(a0)
			movea.l		#$fffffa07,a0
			movep.w		d1,$0(a0)
			lea			KeyboardHandler,a1
			move.l		a1,$118									// ACIA handler (keyboard)
			lea			Trap0Handler,a0
			move.l		a0,$80									// Trap #0 vector
			lea			Trap4Handler,a0
			move.l		a0,$90									// Trap #4 vector
			clr.l		screen.base(a6)
			move.b		$ffff8201,1(a6)
			move.b		$ffff8203,2(a6)
			move.w		#$1,FrameRateLock(a6)
			bsr .l		+$30be
			lea			+$3e80(a6),a0
			move		#$2600,sr								// Disable interrupts
			nop 
			nop 
			lea			GlobalVariables,a6						// Ptr to global vars
			nop 
			nop 
			lea			VBLHandler,a0							// VBL handler
			move.l		a0,$70									// VBL vector
			move		#$2300,sr								// Enable interrupts
			move.w		#$8000,VideoMode(a6)					// Set to lo-res video mode on next vblank
			lea			KeyboardInit,a2							// Initialize keyboard & mouse
@InitLoop
			move.w		(a2)+,d0
			beq.s		@InitDone
			trap		#0
			bra.s		@InitLoop
@InitDone
0006a8 : 6100 315e                : bsr .l +$315e // 3808 - load something?
0006ac : 6100 27ea                : bsr .l ChecksumLowMemory
MainMenu
0006b0 : 7001                     : moveq #1,d0
0006b2 : 6100 2ffc                : bsr .l play.music
0006b6 : 6100 1f96                : bsr .l TitleMainLoop
0006ba : 6100 01ae                : bsr .l reset.globals
			move.w		#$0,level.number(a6)
			bsr			init.screen
			bsr 		draw.titles
0006cc : 0c2e 0039 0064           : cmpi.b #$39,keycode(a6)
0006d2 : 672e                     : beq.s start.game3
0006d4 : 082e 0007 0063           : btst #$7,joy.btn(a6)
0006da : 6626                     : bne.s start.game
0006dc : 6100 3010                : bsr .l +$3010		// 36ee
0006e0 : 6100 3030                : bsr .l +$3030		// 3712
0006e4 : 0c2e 0039 0064           : cmpi.b #$39,keycode(a6)
0006ea : 672c                     : beq.s start.game2
0006ec : 082e 0007 0063           : btst #$7,joy.btn(a6)
0006f2 : 6624                     : bne.s start.game2
0006f4 : 6100 27d2                : bsr .l +$27d2		// 2ec8 - show intro bitmap?
0006f8 : 601e                     : bra.s start.game2
enter.game
			bsr			init.screen2
			bsr			draw.titles
start.game3
000702 : 422e 00c3                : clr.b +$c3(a6)
start.game
000706 : 207c 0004 fffc           : movea.l #StackTop,a0
00070c : 2e48                     : movea.l a0,a7
00070e : 90fc 0100                : suba.w #$100,a0
000712 : 4e60                     : move a0,usp
000714 : 6100 2ffc                : bsr .l +$2ffc				// 3712
start.game2
			bsr			soft.init
			clr.b		joy.btn(a6)
			clr.b		keycode(a6)
			lea			GFX_LEVEL_PALETTES,a0					// Copy palette for this level
			move.w		level.number(a6),d0						// to the local palette buffer
			lsl.w		#5,d0
			adda.w		d0,a0
			st			+$72(a6)
			st			+$73(a6)
			lea			GFX_PALETTE,a1
			moveq		#7,d0
@copylp		move.l		(a0)+,(a1)+
			dbra		d0,@copylp
000748 : 51ee 0090                : sf  +$90(a6)
			move.w		#$0,game.stage(a6)
@gameloop
			cmpi.w		#$2,game.stage(a6)						// Update health bars on frame buffer #2
			bne.s		@noupdate								// This helps spread out processing time
			bsr			UpdateHealthBars
@noupdate
			move.l		scroll.strip(a6),d0
			move.l		scroll.strip2(a6),scroll.strip(a6)
			move.l		d0,scroll.strip2(a6)
			move.l		d0,scroll.buffptr(a6)
			moveq		#7,d1
@updatecycle
			// This is the loop that effectively cycles through all 8 display buffers
			// and depending which one is being rendered,
			move.w		d1,-(a7)								// Preserve loop counter (16 pixel loop, 2 pixels per iteration)
			bsr			SwapFrameBuffers
			bsr			erase.starfield							// Our pitiful starfield
			bsr			erase.projectiles
			bsr			erase.outrider
			bsr			erase.sprites
			// It was initially intended that specific code could be executed on alternate
			// 8 cycle execution cycles as this would help help mitigate the cost of some 
			// of these operations (like the time it would take to render the scroll strip 
			// for the right of the display has to be split in 3 - if I remember right - so 
			// that the processing time can be split evenly between that and other not so 
			// frequent tasks. Turned out, though, that this was used very little. There were
			// only ever 2 different things performed and it could have just as well been done
			// with an and and bne sequence.
			move.w		(a7),d1									// stage specific code block? Loop specific special code?
			andi.w		#$3,d1
			lsl.w		#1,d1
			lea			loop.specific,a0
			adda.w		0(a0,d1.W),a0							// This was my form of position independant jump tables (word sized offsets).
			jsr			(a0)                  +98
			cmpi.w		#$3,game.stage(a6)
			bne.s		@noguardian
			bsr			draw.guardian
@noguardian	
			bsr			scroll.screen
			bsr			update.scores
0007b0 : 4a2e 0112                : tst.b +$112(a6)
0007b4 : 672e                     : beq.s +46
0007b6 : 536e 0110                : subq.w #1,+$110(a6)
0007ba : 6b00 2076                : bmi .l +$2076
0007be : 4281                     : clr.l d1
0007c0 : 322e 0084                : move.w +$84(a6),d1
0007c4 : 342e 0086                : move.w ship.x(a6),d2
0007c8 : 362e 0088                : move.w ship.y(a6),d3
0007cc : b27c 0010                : cmp.w #$10,d1
0007d0 : 641e                     : bcc.s +30
0007d2 : 066e 0001 0084           : addi.w #$1,+$84(a6)
0007d8 : 0241 0007                : andi.w #$7,d1
0007dc : 7000                     : moveq #0,d0			// draw.ship or explosion or bonus?
0007de : 6100 049a                : bsr		draw.bob
0007e2 : 600c                     : bra.s +12
0007e4 : 6100 1854                : 
			bsr			check.fire
			bsr			update.position
			bsr			draw.ship
			bsr			draw.aliens
			bsr			check.collision
			bsr 		draw.outrider
			bsr			check.endoflevel
			bsr			draw.projectiles
000804 : 6100 13e0                : bsr .l +$13e0		// 1be6
000808 : 4a2e 0072                : tst.b +$72(a6)
00080c : 6704                     : beq.s +4
00080e : 6100 170a                : bsr .l +$170a		// 1f1a
			move.w		(a7)+,d1
			dbra		d1,@updatecycle
			tst.w		demo.timer(a6)						// Demo mode active?
			beq.s		@nodemo
			tst.b		keycode(a6)							// Any key pressed? Go back to menu
			bne			MainMenu
			btst		#$7,joy.btn(a6)								// Was fire button pressed?
			bne			MainMenu
			subq.w		#1,demo.timer(a6)					// Did timer expire?
			beq			MainMenu
@nodemo		cmpi.b		#$1,keycode(a6)						// Was escape pressed?
			bne 		@gameloop								// Nope, keep in the game
			bra			MainMenu

clear.palettes
			lea			$411c,a0
			bsr.s		@clear
			movea.l		#HW_VIDEO_PALETTE,a0					// Clear palette
@clear		moveq		#7,d0
@lp			clr.l		(a0)+
			dbra		d0,@lp
			rts 

00085e : 7607                     : moveq #7,d3
000860 : 7002                     : moveq #SYS_SET_AUDIO,d0
000862 : 4e44                     : trap #4
000864 : 51cb fffa                : dbra d3,-6
000868 : 4e75                     : rts 
reset.globals
			lea			GlobalVariables,a6
			move.w		#$4,ship.speed(a6)
			sf			LasersActive(a6)
			sf			CanonsActive(a6)
			sf			mult1.on(a6)
			sf			mult2.on(a6)
000886 : 42ae 00d2                : clr.l +$d2(a6)
00088a : 3d7c 0001 0084           : move.w #$1,+$84(a6)
			clr.w		LaserBarLength(a6)
			clr.w		CanonBarLength(a6)
			move.w		#79,EnergyBarLength(a6)
			clr.w		demo.timer(a6)
			lea			LevelScores(a6),a1
			clr.l		(a1)+
			clr.l		(a1)+
			clr.l		(a1)+
			clr.l		(a1)+
			clr.l		(a1)+
			clr.l		(a1)+
			clr.b		speedup.bonuses(a6)
			clr.b		outrider.bonuses(a6)
			clr.b		forcefield.bonuses(a6)
			clr.b		laser.bonuses(a6)
			clr.b		canon.bonuses(a6)
			clr.b		energy.bonuses(a6)
			rts 
soft.init
			lea			GlobalVariables,a6
			lea			projectiles(a6),a0
			move.w		#$26f7,d0
			clr.l		(a0)+
			dbra		d0,-4
			movea.l		#$10000,a3
			move.l		a3,screen.base(a6)
			moveq		#7,d0
			lea			restore.buffers(a6),a0
			lea			screen.bufptrs(a6),a2
			lea			restore.bufptrs(a6),a1
@initlp		adda.w		#15*6*32+144,a0
			clr.l		(a0)									// Make sure first few entries in restore stack are clear
			clr.l		4(a0)
			clr.l		8(a0)
			clr.l		12(a0)
			move.l		a0,(a1)+								// Set restore stack ptr
			move.l		a3,(a2)+								// Set display buffer address
			adda.l		#32768,a3
			dbra		d0,@initlp
			clr.w		FrameBufferIndex(a6)
			move.w		#FRAME_BUFFER_COUNT*4,FrameBufferCount(a6)
			move.w		#$7,alien.count(a6)
			moveq		#7,d0
			move.l		#$70d00,landscape(a6)
			lea			scroll.buffer(a6),a0
			move.l		a0,scroll.strip2(a6)
			lea			scroll.buffer2(a6),a0
			move.l		a0,scroll.strip(a6)
			movea.l		restore.bufptrs(a6),a5
			move.w		#$60,ship.y(a6)							// Set initial ship position
			move.w		#$64,ship.x(a6)
				move.w #$0,+$c4(a6)
			move.w		#$5,path.delay(a6)
			move.w		#999,ship.energy(a6)						// Set energy to 999 
				move.w #$1,+$92(a6)
			clr.l		last.path(a6)
			clr.w		game.stage(a6)
			movea.l		screen.base(a6),a3
			moveq		#7,d7
@loop
			movea.l		a3,a2
			bsr			InitFrameBuffer
			adda.l		#32768,a3
			dbra		d7,@loop
			move.w		#$3,FrameRateLock(a6)
			move.w		EnergyBarLength(a6),d1
			move.w		#$5620,d4
			moveq		#2,d2
			bsr 		draw.bar
			move.w		CanonBarLength(a6),d1
			move.w		#$5630,d4
			moveq		#4,d2
			bsr			draw.bar
			move.w		LaserBarLength(a6),d1
			move.w		#$5628,d4
			moveq		#3,d2
			bsr			draw.bar
0009b8 : 41f9 0000 4cd0           : lea LevelPalettes,a0
			move.w		level.number(a6),d0
0009c2 : c0fc 0060                : mulu #$60,d0
0009c6 : d088                     : add.l a0,d0
0009c8 : 2d40 005e                : move.l d0,LevelPalettePtr(a6)
0009cc : 42ae 00d6                : clr.l +$d6(a6)
			clr.w		no.bonus(a6)
			clr.w		bonus.delay(a6)
0009d8 : 42ae 00ce                : clr.l +$ce(a6)
0009dc : 426e 00ec                : clr.w +$ec(a6)
			clr.w		ship.damage(a6)
0009e4 : 426e 00e8                : clr.w +$e8(a6)
0009e8 : 426e 0074                : clr.w +$74(a6)
			clr.w		forcefield.timer(a6)
0009f0 : 51ee 0112                : sf  +$112(a6)
			sf			difficulty.level(a6)
0009f8 : 51ee 007c                : sf  +$7c(a6)
0009fc : 51ee 007a                : sf  +$7a(a6)
000a00 : 51ee 007b                : sf  +$7b(a6)
000a04 : 51ee 007d                : sf  +$7d(a6)
000a08 : 51ee 007e                : sf  +$7e(a6)
000a0c : 51ee 0097                : sf  +$97(a6)
000a10 : 51ee 0072                : sf  +$72(a6)
000a14 : 3d6e 00de 00dc           : move.w LandscapeDamage(a6),landcoll.damage(a6)
000a1a : 3d7c 0002 00e0           : move.w #$2,+$e0(a6)
000a20 : 4e75                     : rts 

InitFrameBuffer
			move.w		#199,d1
			movea.l		#$50100,a1
			adda.w		10(a1),a1
@linelp		moveq		#31,d0
@clrlp		clr.l		(a2)+									// Clear out left side of display
			dbra		d0,@clrlp
			moveq		#7,d0									// Copy the score strip
@copylp		move.l		(a1)+,(a2)+
			dbra		d0,@copylp
			dbra		d1,@linelp
			rts 
=0xa46
// This draws 1/3 of the scroll on strip from the right of the display.
draw.strip
			cmpi.w		#$3,game.stage(a6)
			bcc.s		@done
			cmpi.w		#$2,game.stage(a6)
			beq.s		@done
			cmpi.w		#$1,game.stage(a6)
			beq .l		@scrolling.guardian
			movea.l		scroll.buffptr(a6),a0
			movea.l		landscape(a6),a4
			moveq		#1,d1
@linelp		moveq		#0,d0
			move.b		(a4)+,d0							// Get landscape block #
			cmp.b		#$ff,d0							// end of list? done
			beq.s		@done
			mulu		#3*2*16,d0
			movea.l		#$72900,a1						// Level block graphics
			movea.l		a1,a2
			adda.l		d0,a1
			moveq		#0,d0
			cmpa.l		#$70d0d,a4
			bcs.s		@noclip
			move.b		-13(a4),d0						// Previous landscape block#
@noclip		mulu		#$60,d0
			adda.l		d0,a2
			moveq		#15,d0
@blocklp	move.w		(a2)+,(a0)+
			move.w		(a1)+,(a0)+
			move.w		30(a2),(a0)+
			move.w		30(a1),(a0)+
			move.w		62(a2),(a0)+
			move.w		62(a1),(a0)+
			dbra		d0,@blocklp
			dbra		d1,@linelp
			moveq		#0,d1
			move.l		a4,landscape(a6)
			move.l		a0,scroll.buffptr(a6)
@done		rts 

000ac0 : 3d7c 0001 00ca           : move.w #$1,game.stage(a6)
000ac6 : 422e 0070                : clr.b +$70(a6)
000aca : 3d7c 004c 006e           : move.w #$4c,+$6e(a6)
000ad0 : 4e75                     : rts 
UpdateHealthBars
000ad2 : 302e 00a2                : move.w landscape(a6),d0
000ad6 : 206e 00b2                : movea.l +$b2(a6),a0
000ada : c0fc 0018                : mulu #$18,d0
000ade : 247c 0007 b100           : movea.l #$7b100,a2
000ae4 : d4c0                     : adda.w d0,a2
000ae6 : 43ee 01da                : lea +$1da(a6),a1
000aea : 7e17                     : moveq #23,d7
000aec : 3a3c 000c                : move.w #$c,d5
000af0 : 7c07                     : moveq #7,d6
000af2 : 101a                     : move.b (a2)+,d0
000af4 : 0d00                     : btst d6,d0
000af6 : 660c                     : bne.s +12
000af8 : 4251                     : clr.w (a1)
000afa : 4269 0004                : clr.w 4(a1)
000afe : 4269 0008                : clr.w 8(a1)
000b02 : 600a                     : bra.s +10
000b04 : 3298                     : move.w (a0)+,(a1)
000b06 : 3358 0004                : move.w (a0)+,4(a1)
000b0a : 3358 0008                : move.w (a0)+,8(a1)
000b0e : d2c5                     : adda.w d5,a1
000b10 : 51ce ffe2                : dbra d6,-30
000b14 : 51cf ffda                : dbra d7,-38
000b18 : 2d48 00b2                : move.l a0,+$b2(a6)
000b1c : 302e 00a2                : move.w landscape(a6),d0
000b20 : 5240                     : addq.w #1,d0
000b22 : 3d40 00a2                : move.w d0,landscape(a6)
000b26 : b07c 0010                : cmp.w #$10,d0
000b2a : 6322                     : bls.s +34
000b2c : 50ee 0090                : st  +$90(a6)
000b30 : 3d7c 0003 00ca           : move.w #$3,game.stage(a6)
000b36 : 3d7c 0001 00dc           : move.w #$1,landcoll.damage(a6)
000b3c : 3d7c 0004 00e0           : move.w #$4,+$e0(a6)
000b42 : 3d7c 0002 0054           : move.w #$2,FrameRateLock(a6)
000b48 : 7000                     : moveq #0,d0
000b4a : 6100 2b64                : bsr .l +$2b64
000b4e : 4e75                     : rts 
@scrolling.guardian
000b50 : 206e 0000                : movea.l screen.base(a6),a0
000b54 : 4aa8 7760                : tst.l +$7760(a0)
000b58 : 664e                     : bne.s +78
000b5a : 4aa8 7764                : tst.l +$7764(a0)
000b5e : 6648                     : bne.s +72
000b60 : 4a98                     : tst.l (a0)+
000b62 : 6644                     : bne.s +68
000b64 : 4a98                     : tst.l (a0)+
000b66 : 6640                     : bne.s +64
000b68 : 4a6e 00f2                : tst.w all.coords(a6)
000b6c : 663a                     : bne.s +58
000b6e : 41ee 01d8                : lea scroll.buffer(a6),a0
000b72 : 2d48 00ae                : move.l a0,scroll.strip(a6)
000b76 : 2d48 00aa                : move.l a0,scroll.strip2(a6)
000b7a : 3d7c 0002 00ca           : move.w #$2,game.stage(a6)
000b80 : 49f9 0000 409c           : lea $409c,a4
000b86 : 302e 00f6                : move.w level.number(a6),d0
000b8a : e948                     : lsl.w #4,d0
000b8c : d8c0                     : adda.w d0,a4
000b8e : 3204                     : move.w d4,d1
000b90 : 6118                     : bsr.s +24
000b92 : 426e 00a2                : clr.w landscape(a6)
000b96 : 2d7c 0007 b280 00b2      : move.l #$7b280,+$b2(a6)
000b9e : 3d7c 0007 0074           : move.w #$7,+$74(a6)
000ba4 : 426e 0076                : clr.w +$76(a6)
000ba8 : 4e75                     : rts 

000baa : 48e7 e800                : movem.l d0-2/d4,-(a7)
000bae : 7800                     : moveq #0,d4
000bb0 : 341c                     : move.w (a4)+,d2
000bb2 : 3204                     : move.w d4,d1
000bb4 : 7003                     : moveq #SYS_SET_PALETTE_ENTRY,d0
000bb6 : 4e44                     : trap #4
000bb8 : 5244                     : addq.w #1,d4
000bba : b87c 0008                : cmp.w #$8,d4
000bbe : 66f0                     : bne.s -16
000bc0 : 4cdf 0017                : movem.l (a7)+,d0-2/d4
000bc4 : 4e75                     : rts 
// The scroll mechanism does a block move of 16 pixels and then replaces the last
// strip with 16 pixels from a scroll buffer. This scroll buffer contains the landscape
// data being moved in to view. There are 8 screens, each 2 pixels on from the last
// and this scroll buffer is what causes the 2 pixel scroll to work.
scroll.screen
			cmpi.w		#$3,game.stage(a6)
			bcc.s		@done
			move.l		a6,-(a7)
			move.l		a5,-(a7)
			movea.l		screen.base(a6),a0
			addq.w		#8,a0
			movea.l		scroll.strip(a6),a1						// Ptr to scrolling data?
			moveq		#42,d1									// Line modulo
			move.w		#191,d0									// line count
@loop
			movem.l		(a0)+,d3-7/a2-6							// move 80 pixels
			movem.l		d3-7/a2-6,+$ffd0(a0)
			movem.l		(a0)+,d3-7/a2-6							// and another 80
			movem.l		d3-7/a2-6,+$ffd0(a0)
			movem.l		(a0)+,d3-7/a2-6							// and the final 80
			movem.l		d3-7/a2-6,+$ffd0(a0)
			subq.w		#8,a0									// Now "scroll" in the landscape
			move.l		(a1),d2
			lsl.l		#2,d2
			move.l		d2,(a1)+
			swap		d2
			move.w		d2,(a0)+
			move.l		(a1),d2
			lsl.l		#2,d2
			move.l		d2,(a1)+
			swap		d2
			move.w		d2,(a0)+
			move.l		(a1),d2
			lsl.l		#2,d2
			move.l		d2,(a1)+
			swap		d2
			move.w		d2,(a0)+
			adda.w		d1,a0								// Line modulo. This will leave the score strip alone
			dbra		d0,@loop
			movea.l		(a7)+,a5
			movea.l		(a7)+,a6
@done		rts 
//
// Render the end-of-level guardian. This was simply compressed using a bitmask to get rid of
// zeros. Runlength may have been more efficient but *I think* when I tried it, it turned out
// to use more space. I had run out of memory so I had to compress it in some manner (if I
// remember right, it was because I ran out of disk block space.
//
draw.guardian
000c2c : 226e 0000                : movea.l screen.base(a6),a1
000c30 : b3fc 0001 0000           : cmpa.l #$10000,a1
000c36 : 673a                     : beq.s +58
000c38 : 247c 0007 b100           : movea.l #$7b100,a2
000c3e : 47ea 0180                : lea +$180(a2),a3
000c42 : 363c 0098                : move.w #$98,d3
000c46 : 7e0f                     : moveq #15,d7
000c48 : 2049                     : movea.l a1,a0
000c4a : 7c17                     : moveq #23,d6
000c4c : 181a                     : move.b (a2)+,d4
000c4e : 7a07                     : moveq #7,d5
000c50 : 0b04                     : btst d5,d4
000c52 : 6606                     : bne.s +6
000c54 : 4298                     : clr.l (a0)+
000c56 : 4298                     : clr.l (a0)+
000c58 : 6006                     : bra.s +6
000c5a : 20db                     : move.l (a3)+,(a0)+
000c5c : 30db                     : move.w (a3)+,(a0)+
000c5e : 4258                     : clr.w (a0)+
000c60 : d0c3                     : adda.w d3,a0
000c62 : 51cd ffec                : dbra d5,-20
000c66 : 51ce ffe4                : dbra d6,-28
000c6a : 5049                     : addq.w #8,a1
000c6c : 51cf ffda                : dbra d7,-38
000c70 : 4e75                     : rts 
000c72 : 3d7c 0004 00ca           : move.w #$4,game.stage(a6)
000c78 : 4e75                     : rts 
draw.bob
000c7a : 3a02                     : move.w d2,d5			// This is some sort of sprite rendering code
000c7c : 5542                     : subq.w #2,d2
000c7e : 6300 0734                : bls .l +$734
000c82 : 206e 0000                : movea.l screen.base(a6),a0
000c86 : c6fc 00a0                : mulu #$a0,d3
000c8a : d0c3                     : adda.w d3,a0
000c8c : 2602                     : move.l d2,d3
000c8e : 0242 000f                : andi.w #$f,d2
000c92 : e24b                     : lsr.w #1,d3
000c94 : 0243 00f8                : andi.w #$f8,d3
000c98 : d0c3                     : adda.w d3,a0
000c9a : 90fc 0010                : suba.w #$10,a0
000c9e : 2c05                     : move.l d5,d6
000ca0 : 7eff                     : moveq #-1,d7
000ca2 : 0445 0020                : subi.w #$20,d5
000ca6 : 6210                     : bhi.s +16
000ca8 : 3a06                     : move.w d6,d5
000caa : 5545                     : subq.w #2,d5
000cac : 6316                     : bls.s +22
000cae : 4445                     : neg.w d5
000cb0 : 0245 001f                : andi.w #$1f,d5
000cb4 : eaaf                     : lsr.l d5,d7
000cb6 : 6012                     : bra.s +18
000cb8 : 0445 00e2                : subi.w #$e2,d5
000cbc : 650c                     : bcs.s +12
000cbe : ba7c 0020                : cmp.w #$20,d5
000cc2 : 6304                     : bls.s +4
000cc4 : 4287                     : clr.l d7
000cc6 : 6002                     : bra.s +2
000cc8 : ebaf                     : lsl.l d5,d7
000cca : 2d47 00b6                : move.l d7,edge.mask(a6)
000cce : 0880 0007                : bclr #$7,d0
000cd2 : 6600 0130                : bne .l @upsidedown					// Our bob is flipped on y
000cd6 : b07c 0001                : cmp.w #$1,d0
000cda : 6612                     : bne.s +18
000cdc : 227c 0005 0100           : movea.l #$50100,a1
000ce2 : d2e9 000e                : adda.w 14(a1),a1
000ce6 : c2fc 0180                : mulu #$180,d1
000cea : d2c1                     : adda.w d1,a1
000cec : 602c                     : bra.s +44
000cee : b07c 0002                : cmp.w #$2,d0
000cf2 : 6612                     : bne.s +18
000cf4 : 227c 0005 0100           : movea.l #$50100,a1
000cfa : d2e9 0010                : adda.w 16(a1),a1
000cfe : c2fc 0180                : mulu #$180,d1
000d02 : d2c1                     : adda.w d1,a1
000d04 : 6014                     : bra.s +20
000d06 : 226e 005e                : movea.l LevelPalettePtr(a6),a1
000d0a : 0240 00ff                : andi.w #$ff,d0
000d0e : e548                     : lsl.w #2,d0
000d10 : d3c0                     : adda.l d0,a1
000d12 : 2251                     : movea.l (a1),a1
000d14 : c2fc 0180                : mulu #$180,d1
000d18 : d2c1                     : adda.w d1,a1
000d1a : 2202                     : move.l d2,d1
000d1c : 2001                     : move.l d1,d0
000d1e : e788                     : lsl.l #3,d0
000d20 : 45f9 0000 3d9e           : lea $3d9e,a2
000d26 : d4c0                     : adda.w d0,a2
000d28 : 2c1a                     : move.l (a2)+,d6
000d2a : 2e12                     : move.l (a2),d7
000d2c : 45e8 0008                : lea 8(a0),a2
000d30 : 47e8 0010                : lea 16(a0),a3
000d34 : 7417                     : moveq #23,d2
@renderup
000d36 : 2848                     : movea.l a0,a4
000d38 : 381c                     : move.w (a4)+,d4
000d3a : 885c                     : or.w (a4)+,d4
000d3c : 885c                     : or.w (a4)+,d4
000d3e : 885c                     : or.w (a4)+,d4
000d40 : 4844                     : swap d4
000d42 : 381c                     : move.w (a4)+,d4
000d44 : 885c                     : or.w (a4)+,d4
000d46 : 885c                     : or.w (a4)+,d4
000d48 : 885c                     : or.w (a4)+,d4
000d4a : 3a1c                     : move.w (a4)+,d5
000d4c : 8a5c                     : or.w (a4)+,d5
000d4e : 8a5c                     : or.w (a4)+,d5
000d50 : 8a5c                     : or.w (a4)+,d5
000d52 : 4a2e 0098                : tst.b +$98(a6)
000d56 : 671a                     : beq.s +26
000d58 : 2029 000c                : move.l 12(a1),d0
000d5c : c0ae 00b6                : and.l edge.mask(a6),d0
000d60 : e2b8                     : ror.l d1,d0
000d62 : 2600                     : move.l d0,d3
000d64 : 4843                     : swap d3
000d66 : c086                     : and.l d6,d0
000d68 : c647                     : and.w d7,d3
000d6a : 4680                     : not.l d0
000d6c : 4643                     : not.w d3
000d6e : c880                     : and.l d0,d4
000d70 : ca43                     : and.w d3,d5
000d72 : 3b05                     : move.w d5,-(a5)
000d74 : 2b04                     : move.l d4,-(a5)
000d76 : 4684                     : not.l d4
000d78 : 4645                     : not.w d5
			REPT 4
000d7a : 2019                     : move.l (a1)+,d0
000d7c : c0ae 00b6                : and.l edge.mask(a6),d0
000d80 : e2b8                     : ror.l d1,d0
000d82 : 2600                     : move.l d0,d3
000d84 : 4843                     : swap d3
000d86 : c086                     : and.l d6,d0
000d88 : c647                     : and.w d7,d3
000d8a : c084                     : and.l d4,d0
000d8c : c645                     : and.w d5,d3
000d8e : 875b                     : or.w d3,(a3)+
000d90 : 815a                     : or.w d0,(a2)+
000d92 : 4840                     : swap d0
000d94 : 8158                     : or.w d0,(a0)+
			ENDR
000dea : 303c 0098                : move.w #BYTES_PER_LINE-8,d0
000dee : d0c0                     : adda.w d0,a0
000df0 : d4c0                     : adda.w d0,a2
000df2 : d6c0                     : adda.w d0,a3
000df4 : 51ca ff40                : dbra d2,@renderup
000df8 : 90fc 00a0                : suba.w #$a0,a0
000dfc : 3b3c 0017                : move.w #$17,-(a5)
000e00 : 2b08                     : move.l a0,-(a5)
000e02 : 4e75                     : rts 
// Sprites were never more than 32 pixels wide. So, I always assumed 48 pixels when scrolled in the 16 pixel
// sub screen block range. 
@upsidedown
000e04 : 226e 005e                : movea.l LevelPalettePtr(a6),a1
000e08 : 0240 00ff                : andi.w #$ff,d0
000e0c : e548                     : lsl.w #2,d0
000e0e : d3c0                     : adda.l d0,a1
000e10 : 2251                     : movea.l (a1),a1
000e12 : c2fc 0180                : mulu #$180,d1
000e16 : d2c1                     : adda.w d1,a1
000e18 : d2fc 0170                : adda.w #$170,a1
000e1c : 2202                     : move.l d2,d1
000e1e : 2001                     : move.l d1,d0
000e20 : e788                     : lsl.l #3,d0
000e22 : 45f9 0000 3d9e           : lea $3d9e,a2
000e28 : d4c0                     : adda.w d0,a2
000e2a : 2c1a                     : move.l (a2)+,d6
000e2c : 2e12                     : move.l (a2),d7
000e2e : 45e8 0008                : lea 8(a0),a2
000e32 : 47e8 0010                : lea 16(a0),a3
000e36 : 7417                     : moveq #24-1,d2
@renderdownlp
000e38 : 2848                     : movea.l a0,a4
000e3a : 381c                     : move.w (a4)+,d4			// build a mask for first 16 pixels
000e3c : 885c                     : or.w (a4)+,d4
000e3e : 885c                     : or.w (a4)+,d4
000e40 : 885c                     : or.w (a4)+,d4
000e42 : 4844                     : swap d4
000e44 : 381c                     : move.w (a4)+,d4			// build a mask for 2nd 16 pixels
000e46 : 885c                     : or.w (a4)+,d4
000e48 : 885c                     : or.w (a4)+,d4
000e4a : 885c                     : or.w (a4)+,d4
000e4c : 3a1c                     : move.w (a4)+,d5			// build a mask for 3rd 16 pixel block
000e4e : 8a5c                     : or.w (a4)+,d5
000e50 : 8a5c                     : or.w (a4)+,d5
000e52 : 8a5c                     : or.w (a4)+,d5
000e54 : 3b05                     : move.w d5,-(a5)			// Store on the rebuild stack
000e56 : 2b04                     : move.l d4,-(a5)
000e58 : 4684                     : not.l d4				// invert the masks for sprite rendering
000e5a : 4645                     : not.w d5
			REPT 4
000e94 : 2019                     : move.l (a1)+,d0			// render 16 pixels (repeated 4 times)
000e96 : c0ae 00b6                : and.l edge.mask(a6),d0
000e9a : e2b8                     : ror.l d1,d0
000e9c : 2600                     : move.l d0,d3
000e9e : 4843                     : swap d3
000ea0 : c086                     : and.l d6,d0
000ea2 : c647                     : and.w d7,d3
000ea4 : c084                     : and.l d4,d0
000ea6 : c645                     : and.w d5,d3
000ea8 : 875b                     : or.w d3,(a3)+
000eaa : 815a                     : or.w d0,(a2)+
000eac : 4840                     : swap d0
000eae : 8158                     : or.w d0,(a0)+
			ENDR

000ecc : 92fc 0020                : suba.w #$20,a1
000ed0 : 303c 0098                : move.w #BYTES_PER_LINE-8,d0
000ed4 : d0c0                     : adda.w d0,a0
000ed6 : d4c0                     : adda.w d0,a2
000ed8 : d6c0                     : adda.w d0,a3
000eda : 51ca ff5c                : dbra d2,@renderdownlp
000ede : 90fc 00a0                : suba.w #$a0,a0
000ee2 : 3b3c 0017                : move.w #$17,-(a5)
000ee6 : 2b08                     : move.l a0,-(a5)
000ee8 : 4e75                     : rts 
draw.aliens
			bsr.s		process.aliens
			lea			draw.list(a6),a1
			move.w		alien.count(a6),d7
@loop
			moveq		#0,d2
			moveq		#0,d3
			move.w		(a1)+,d2							// x.pos
			move.w		(a1)+,d3							// y.pos
			moveq		#0,d0
			moveq		#0,d1
			move.b		(a1)+,d0							// Anim #
			move.b		(a1)+,d1							// frame #
			tst.w		d2
			beq.s		@nodraw
			move.w		d7,-(a7)
			move.l		a1,-(a7)
			bsr .l		draw.bob
			movea.l		(a7)+,a1
			move.w		(a7)+,d7
@nodraw
			dbra		d7,@loop
			rts 

process.aliens
			clr.w		all.coords(a6)
			lea			path.buffer,a0
			lea			draw.list(a6),a1						// where to store the info
			move.w		alien.count(a6),d7
process.loop
			move.w		table.offset(a0),d0						// get offset in d0
			move.w		x.pos(a0),d1
			beq			finished								// alien dead
			clr.w		last.x(a6)
			clr.w		last.y(a6)
			move.w		y.pos(a0),d2
			subq.b		#1,anim.delay(a0)
			bne			same.anim

			move.b		num.anims(a0),d3
			beq			same.anim
			btst		#3,mode(a0)
			beq			up.only
			btst		#4,mode(a0)
			bne			down.anim
			addq.b		#1,anim.num(a0)							// increase anim num
			cmp.b		anim.num(a0),d3
			bne			process1
			bchg		#4,mode(a0)
			bra			process1
down.anim
			subq.b		#1,anim.num(a0)
			bpl			process1
			move.b		#1,anim.num(a0)
			bchg		#4,d6
			bra			process1

up.only
			move.w		d1,last.x(a6)							// store its coords
			move.w		d2,last.y(a6)
			clr.w		d1										// kill this alien
			bra			finished
process1
			move.b		anim.delay2(a0),anim.delay(a0)			// restore the delay
same.anim
			tst.b		sprite.num(a0)		
			beq			finished								// dont move explosions
			tst.b		pause.count(a0)
			beq			no.pause								// no pause 
			cmp.b		#$ff,pause.count(a0)
			beq			finished								// ff means pause forever...
			subq.b		#1,pause.count(a0)
			beq			update									// if zero update the offset
			bra			finished								// not zero so do nufink
no.pause
			clr.w		d3
			clr.w		d4
			clr.w		d5
			move.b		speed(a0),d5							// speed in d5
			move.b		0(a0,d0.w),d3							// d3 is the x coord to go to
			move.b		1(a0,d0.w),d4							// d4 is the y coord to go to
			bsr			check.seek								// check all seek bits
			tst.b		sprite.num(a0)
			beq			store.coords							// a heat seeker may have exploded
			btst		#0,mode(a0)								// test for offset mode
			bne			add.offsets
			tst.w		d3										// if x goto is minus then
			bmi			check.y									// leave x coord alone
			lsl.w		#1,d3									// even coord only
			cmp.w		d3,d1									// check difference between the 
			sne			x.equal(a6)								// two x coords
			beq			check.y
			blt			increase.x								// if d1<d3 then increase x
			sub.w		d5,d1									// else decrease it
			cmp.w		d3,d1									// has it now passed
			bgt			check.y									// the x coord
			move.w		d3,d1									// if so, make it equal to the x
			sf			x.equal(a6)
			bra			check.y
increase.x
			add.w		d5,d1
			cmp.w		d3,d1
			blt			check.y									// is it still less than x
			move.w		d3,d1
			sf			x.equal(a6)
check.y		tst.w		d4
			bmi			store.coords							// check wether to leave y alone
			lsl.w		#1,d4				
			cmp.w		d4,d2									// compares d2 to d4
			sne			y.equal(a6)
			beq			store.coords
			blt			increase.y								// if d2<d4 then increase y
			sub.w		d5,d2
			cmp.w		d4,d2
			bgt			store.coords
			move.w		d4,d2
			sf			y.equal(a6)
			bra			store.coords
increase.y
			add.w		d5,d2
			cmp.w		d4,d2
			blt			store.coords
			move.w		d4,d2
			sf			y.equal(a6)
			bra			store.coords

add.offsets
			ext.w		d3
			ext.w		d4
			add.w		d3,d1									// add the offsets
			add.w		d4,d2
			clr.b		x.equal(a6)								// signal to update table
			clr.b		y.equal(a6)

store.coords
			move.w		d1,x.pos(a0)							// restore the new coords
			move.w		d2,y.pos(a0)
			move.b		x.equal(a6),d3
			or.b		d3,y.equal(a6)							// is the alien there
			bne			finished								// no, so dont update the table
			btst		#5,mode(a0)								// heat seeker ?
			beq			update
			bsr			explode.alien							// heat seekers explode when they
			bra			finished								// hit their target
update
			btst		#1,mode(a0)								// check for seek mode
			beq			new.offset
			bsr			copy.coords
			subq.b		#1,seek.count(a0)
			bne			finished
			bclr		#1,mode(a0)								// reset seek mode


new.offset
			addq.w		#2,d0
			move.w		d0,table.offset(a0)						// new offset
			tst.w		0(a0,d0.w)
			beq			path.finished							// path finished, so branch
			moveq		#0,d4
			move.b		0(a0,d0.w),d4							// get code in d4 & d3
			move.w		d4,d3

			sub.w		#$e0,d4
			bcs.s		finished
			cmp.w		#$10,d4
			bcc.s		finished

			add.w		d4,d4
			lea			vector.table,a2							// get table base
			add.w		0(a2,d4.w),a2							// get routine address in a2
			jmp			(a2)									// and jump to it

vector.table
			dc.w		init.pause-vector.table
			dc.w		loop.back-vector.table
			dc.w		toggle.offset-vector.table
			dc.w		change.speed-vector.table
			dc.w		change.sprite-vector.table
			dc.w		seek.mode-vector.table
			dc.w		reload.coords-vector.table
			dc.w		new.table-vector.table
			dc.w		restore.offset-vector.table
			dc.w		fire.heatseeker-vector.table
			dc.w		change.anim-vector.table
			dc.w		restart.table-vector.table
			dc.w		start.xy-vector.table
			dc.w		start.seekx-vector.table
			dc.w		start.seeky-vector.table
			dc.w		return-vector.table						// 16 codes maximum

finished
			or.w		d1,all.coords(a6)
			move.w		d1,(a1)+			
			move.w		d2,(a1)+								// store it all in the 
			move.b		sprite.num(a0),(a1)+					// buffer
			move.b		anim.num(a0),(a1)+
			move.b		d6,mode(a0)								// save the mode byte
			add.w		next.path(a0),a0
			dbf			d7,process.loop
			rts
001108 : 4241                     : clr.w d1
00110a : 4268 0002                : clr.w 2(a0)
00110e : 0828 0002 0010           : btst #$2,16(a0)
001114 : 57ee 00cc                : seq no.bonus(a6)
001118 : 6000 ffb4                : bra .l -$4c

check.seek
			btst		#6,mode(a0)								// bit 6 for seek on ship x
			beq			check.seeky
			st			y.equal(a6)								// make sure it never updates table
			move.w		ship.x(a6),d3							// get new x coord to goto
			moveq		#-1,d4									// signal to leave y alone
			lsr.w		#1,d3									// even coords only
			subq.b		#1,seek.count(a0)						// check count
			bne			check.seeky
			bclr		#6,mode(a6)								// reset if count zero
check.seeky
			btst		#7,mode(a6)								// bit 7 for seek on ship y
			beq			check.heat
			st			x.equal(a6)								// make sure it never updates table
			move.w		ship.y(a6),d4							// get new y coord to goto
			moveq		#-1,d3									// signal to leave x alone
			lsr.w		#1,d4									// even coords only
			subq.b		#1,seek.count(a0)						// check count
			bne			check.heat
			bclr		#7,mode(a0)								// reset if count zero
check.heat
			btst		#5,mode(a0)								// bit 5 for a heat seeking mine
			beq			return									// all finished
			move.w		x.pos(a5),d3							// get new x coord to goto
			move.w		y.pos(a5),d4							// get new y coord to goto
			lsr.w		#1,d3									// even coords only
			lsr.w		#1,d4									// even coords only
			subq.b		#1,seek.count(a0)						// check count
			bne			return
			bsr			explode.alien							// kill mine if count zero
			rts

init.pause
			move.b		1(a0,d0.w),pause.count(a0)				// setup the pause
			bra			finished

loop.back
			clr.w		d3
			move.b		loop.offset(a0),d3						// get the loop offset in words
			lsl.w		#1,d3									// convert to bytes
			subq.b		#1,loop.count(a0)						// reduce the loop counter
			beq			update
			sub.w		d3,table.offset(a0)						// and work out the new path PC
			bra			finished

toggle.offset
			bchg		#0,mode(a0)								// start or end offset mode
			bra			update									// get the next path value
				
seek.mode
			bset		#1,mode(a0)								// set the seek mode bit
			move.b		1(a0,d0.w),seek.count(a0)				// copy the count
			addq.w		#2,d0
			move.w		d0,table.offset(a0)
			bsr			copy.coords
			bra			finished

start.seekx
			bset		#6,mode(a0)								// set the seek on X bit
			move.b		1(a0,d0.w),seek.count(a0)				// copy the count
			addq.w		#2,d0
			move.w		d0,table.offset(a0)
			bra			finished

start.seeky
			bset		#7,mode(a0)								// set the seek on Y bit
			move.b		1(a0,d0.w),seek.count(a0)				// copy the count
			addq.w		#2,d0
			move.w		d0,table.offset(a0)
			bra			finished

0011f2 : 0828 0005 0010           : btst #$5,mode(a0)				// heatseek mode?
0011f8 : 6600 01ba                : bne .l next.stage

copy.coords
			move.w		ship.x(a6),d3							// copy the ship coords
			lsr.w		#1,d3
			move.b		d3,0(a0,d0.w)
			move.w		ship.y(a6),d3							// for the seek functions
			lsr.w		#1,d3
			addq.w		#2,d3
			move.b		d3,1(a0,d0.w)
			rts

change.speed
			move.b		1(a0,d0.w),speed(a0)					// copy the new speed byte
			bra			update

change.sprite
			addq.w		#2,d0
			move.b		0(a0,d0.w),sprite.num(a0)				// new sprite number
			move.b		1(a0,d0.w),num.anims(a0)				// new max anims
			clr.b		anim.num(a0)			
			move.b		anim.delay2(a0),anim.delay(a0)			// new anim delay
			bra			update

reload.coords
			addq		#2,d0
			clr.w		d1										// copy a new x,y position
			clr.w		d2										// into the sprite structure
			move.b		0(a0,d0.w),d1	
			move.b		1(a0,d0.w),d2
			lsl.w		#1,d1
			lsl.w		#1,d2
			move.w		d1,x.pos(a0)
			move.w		d2,y.pos(a0)
			bra			update	

new.table
			addq.w		#2,d0									// setup a new path PC
			move.w		d0,d4									// saving the old one in the
			move.b		d4,loop.offset+1(a0)					// loop.offset word
			lsr.w		#8,d4
			move.b		d4,loop.offset(a0)
			move.w		0(a0,d0.w),d0
			subq.w		#2,d0
			bra			new.offset

restore.offset
			move.b		loop.offset(a0),d0						// restore the old path PC
			lsl.w		#8,d0
			move.b		loop.offset+1(a0),d0
			bra			new.offset

fire.heatseeker
			lea			path.buffer(a6),a2						// start a new path at the
			move.w		alien.count(a6),d6						// present paths x,y coord
			addq		#2,d0
heat1		btst		#5,mode(a2)								// only if a free path entry
			beq			heat2									// can be found
			tst.w		x.pos(a2)
			bne			heat2
			move.w		d1,x.pos(a2)
			move.w		d2,y.pos(a2)
			move.b		0(a0,d0.w),seek.count(a2)
			move.b		1(a0,d0.w),hits.num(a2)
			move.b		#2,sprite.num(a2)
			move.b		#1,anim.delay(a2)
			clr.b		anim.num(a2)
			move.b		#3,num.anims(a2)
			bra			new.offset
heat2		add.w		(a2),a2
			dbf			d6,heat1
			bra			new.offset

change.anim
			move.b		1(a0,d0.w),anim.num(a0)					// new animation number
			bra			new.offset

restart.table
			move.w		#table.size-2,d0						// restart the path from the
			bra			update									// beginning


start.xy
			move.b		1(a0,d0.w),d4							// get path number to start
			subq.b		#2,d4									// cant use path 0
			move.l		a0,-(sp)								// save path pointer
			lea			path.buffer(a6),a0
find.num
			add.w		next.path(a0),a0
			dbf			d4,find.num								// get the path
			move.w		d1,x.pos(a0)							// new one starts at present x & y
			move.w		d2,y.pos(a0)
			move.w		d1,d4
			lsr.w		#1,d4
			move.b		d4,table.size(a0)						// set up the first xy coord to
			move.w		d2,d4									// goto. Must be the same as
			lsr.w		#1,d4									// the present xy
			move.b		d4,table.size+1(a0)
			move.w		#table.size,table.offset(a0)			// start of path
			move.b		#128,hits.num(a0)						// indistrutable
			move.b		#1,anim.delay(a0)
			clr.b		pause.count(a0)
			clr.b		anim.num(a0)							// reset anim info
			move.l		(sp)+,a0
			bra			new.offset


check.endoflevel
00132c : 0c2e 0001 00c0           : cmpi.b #$1,last.path(a6)
001332 : 6700 0176                : beq .l +$176 // 14aa
check.path
			tst.w		all.coords(a6)							// wait until all the x coords are 0 
			bne			check.end								// before a new path can start
			not.b		bonus.delay(a6)
			bne			check.end								// a small delay before the bonus
			tst.b		last.path(a6)							// path can start
			bne			start.path
001348 : 51ee 0098                : sf  +$98(a6)
			sf			bonus.mode(a6)
			move.w		last.x(a6),d1
			beq			start.path								// if all the aliens had been killed
			tst.b		no.bonus(a6)							// then we will start the bonus path
			bne			start.path
			move.w		#5,path.delay(a6)
			move.w		last.y(a6),d2
			lea			paths,a0
			adda.l		(a0),a0
			st			bonus.mode(a6)
			clr.w		bonus.num(a6)
			move.w		#7,bonus.count(a5)						// setup the bonus path coordinates
			move.w		d1,x.pos+2(a0)
			move.w		d2,y.pos+2(a0)
			clr.b		anim.num+2(a0)
			lsr.w		#1,d2
			move.w		#$0100,d1
			or.w		d2,d1
			move.w		d1,table.size+2(a0)
			bra			copy.path	
check.end
			rts

001396 : 4a2e 0078                : tst.b +$78(a6)
			bne.s		@done
			move.w		game.stage(a6),d0
			beq.s		@notend
			cmp.w		#$3,d0
			bls.s		next.stage
			cmp.w		#$4,d0
			beq.s		next.stage
@notend		subq.w		#1,path.delay(a6)
			beq.s		GameOver
@done		rts 

0013b6 : 4a2e 00c0
next.stage
			tst.b		last.path(a6)
			beq.s		next.wave
			cmpi.b		#$2,last.path(a6)
			beq.s		start.guardian
			cmpi.b		#$3,last.path(a6)
			beq .l		+$1858
			rts 
next.wave
			movea.l		#$78900,a0
@find		tst.l		(a0)+
			bne.s		@find
			movea.l		(a0),a0
			adda.l		#$78900,a0
			move.b		#$1,last.path(a6)				// Is this enabling the boss?
			move.w		#11,alien.count(a6)
			bra.s		start.wave

			movea.l		#$78900,a0				
@find2		tst.l		(a0)+					
			bne.s		@find2
			addq.w		#4,a0
			movea.l		(a0),a0
			adda.l		#$78900,a0
			move.b		#$3,last.path(a6)				// or is this?
			st			+$98(a6)
			st			difficulty.level(a6)
			move.w		#$30,ScoreAdd(a6)
			move.w		#$8,FrameBufferCount(a6)
			move.w		#$2,FrameRateLock(a6)
			bra.s		start.wave
start.guardian
001426 : 3d7c 0005 00c8           : move.w #$5,path.delay(a6)
00142c : 302e 00c4                : move.w +$c4(a6),d0
001430 : 207c 0007 8900           : movea.l #$78900,a0
001436 : 2230 0000                : move.l 0(a0,d0.W),d1
00143a : 6606                     : bne.s +6
00143c : 7004                     : moveq #4,d0
00143e : 2228 0004                : move.l 4(a0),d1
001442 : d288                     : add.l a0,d1
001444 : 5840                     : addq.w #4,d0
001446 : 3d40 00c4                : move.w d0,+$c4(a6)
00144a : 2041                     : movea.l d1,a0
start.wave
			clr.w		d0
			sf			no.bonus(a6)							// Flag gets set if an alien completes it's path
			move.w		level.number(a6),d0
			mulu		#$180,d0
			lea			GFX_LANDSCAPE_PALETTES,a1				// This *COULD* be level data ptr
			adda.w		d0,a1
			clr.w		d0
			move.b		12(a0),d0
			andi.w		#$7f,d0
			subq.w		#1,d0
			mulu		#$10,d0
			adda.w		d0,a1		
			moveq		#11,d1									// 5 alien wave specific colours [11-15]
			move.w		(a1)+,d2
			moveq		#SYS_SET_PALETTE_ENTRY,d0
			trap		#4		
			moveq		#12,d1
			move.w		(a1)+,d2
			moveq		#SYS_SET_PALETTE_ENTRY,d0
			trap		#4
			moveq		#13,d1
			move.w		(a1)+,d2
			moveq		#SYS_SET_PALETTE_ENTRY,d0
			trap		#4
			moveq		#14,d1
			move.w		(a1)+,d2
			moveq		#SYS_SET_PALETTE_ENTRY,d0
			trap		#4
			moveq		#15,d1
			move.w		(a1)+,d2
			moveq		#SYS_SET_PALETTE_ENTRY,d0
			trap		#4
			lea			alien.state(a6),a1						// initialize their positions
			move.w		(a0)+,d0
@lp			move.l		(a0)+,(a1)+
			dbra		d0,@lp
			rts 

0014aa : 4a6e 00da                : 
Collision
			tst.w		ship.energy(a6)							// Lower ship energy 1 point
			beq.s		@depleted
			subq.w		#1,ship.energy(a6)
@depleted
			rts 

0014b6 : 41ee 2680                : lea alien.state(a6),a0
0014ba : d0e8 0000                : adda.w 0(a0),a0
0014be : 4a28 000a                : tst.b 10(a0)
0014c2 : 6716                     : beq.s +22
0014c4 : 7e0a                     : moveq #10,d7
0014c6 : 6100 02d2                : bsr .l +$2d2
0014ca : 3028 0000                : move.w 0(a0),d0
0014ce : 6700 fee4                : beq .l -$11c
0014d2 : d0c0                     : adda.w d0,a0
0014d4 : 51cf fff0                : dbra d7,-16
0014d8 : 4e75                     : rts 

0014da : 4a68 0002                : tst.w 2(a0)
0014de : 6600 fed4                : bne .l -$12c
0014e2 : 207c 0007 8900           : movea.l #$78900,a0
0014e8 : 4a98                     : tst.l (a0)+
0014ea : 66fc                     : bne.s -4
0014ec : 5048                     : addq.w #8,a0
0014ee : 2050                     : movea.l (a0),a0
0014f0 : d1fc 0007 8900           : adda.l #$78900,a0
0014f6 : 50ee 00c0                : st  last.path(a6)
0014fa : 6000 ff50                : bra .l -$b0
001502
erase.sprites
@loop
			move.w		#BYTES_PER_LINE+6*4,d2					// Line modulo
			tst.l		(a5)									// Is there an address there?
			beq.s		@exit									// Nope, exit

			movea.l		(a5)+,a0								// Get the address
			move.w		(a5)+,d0								// The height to clear
@loop2
			move.w		(a5),d1									// get the upper 16 bits of the mask
			swap		d1
			move.w		(a5)+,d1								// and again
			and.l		d1,(a0)+								// Mask it out from planes 0,1
			and.l		d1,(a0)+								// Mask it out from planes 1,2
			move.w		(a5),d1									// And again for the lower 16 bits of the mask
			swap		d1
			move.w		(a5)+,d1
			and.l		d1,(a0)+
			and.l		d1,(a0)+
			move.w		(a5),d1
			swap		d1
			move.w		(a5)+,d1
			and.l		d1,(a0)+
			and.l		d1,(a0)+
			suba.w		d2,a0
			dbra		d0,@loop2
			bra.s		@loop

@exit		rts 
draw.projectiles
001532 
			lea			projectiles(a6),a0
			moveq		#MAX_PROJECTILES-1,d6
			moveq		#0,d7
@renderloop	
			tst.w		(a0)
			beq.s		@notinuse
			bsr.s		@render
			tst.w		(a0)									// Was it rendered?
			beq.s		@notrendered
@notinuse	addq.w		#1,d7
@notrendered
			adda.w		#proj.size,a0
			dbra		d6,@renderloop
			move.w		d7,-(a5)								// Save count of # sprites rendered
			rts 
@render
			moveq		#0,d3
			moveq		#0,d4
			move.w		proj.x(a0),d3
			move.w		proj.y(a0),d4
			move.l		d3,d1
			move.l		d4,d2
			movea.l		screen.base(a6),a1
			mulu		#$a0,d4
			adda.w		d4,a1
			move.l		d3,d4
			andi.w		#$f,d3
			lsr.w		#1,d4
			andi.w		#$f8,d4
			adda.w		d4,a1
			suba.w		#$10,a1
			tst.l		(a1)+
001580 : 6604                     : bne.s +4
001582 : 4a99                     : tst.l (a1)+
001584 : 671e                     : beq.s +30
001586 : 6100 00e4                : bsr .l +$e4
00158a : 40c0                     : move sr,d0
00158c : 0c6e 0004 00ca           : cmpi.w #$4,game.stage(a6)
001592 : 670c                     : beq.s +12
001594 : 4a2e 00c1                : tst.b bonus.mode(a6)
001598 : 6606                     : bne.s +6
00159a : 4a28 000a                : tst.b proj.b1(a0)
00159e : 6704                     : beq.s +4
0015a0 : 44c0                     : move d0,ccr
0015a2 : 6622                     : bne.s +34
			subq.w		#1,proj.life(a0)
			beq.s		@kill
			add.w		proj.xvel(a0),d1
			cmp.w		#$20,d1
			bmi.s		@kill
			cmp.w		#$113,d1
			bcc.s		@kill
			add.w		proj.yvel(a0),d2
			tst.w		d2
			bmi.s		@kill
			cmp.w		#$bf,d2
			bcs.s		@notdead
@kill
			clr.w		(a0)
			clr.l		d0
			move.b		proj.b1(a0),d0
			move.b		proj.b2(a0),d1
			bclr		d1,122(a6,d0.W)
			rts 
@notdead
0015d8 : 4280                     : clr.l d0
0015da : 1028 000a                : move.b proj.b1(a0),d0
0015de : e548                     : lsl.w #2,d0
0015e0 : 47f9 0000 3e26           : lea $3e26,a3
0015e6 : d6c0                     : adda.w d0,a3
0015e8 : 3141 0002                : move.w d1,proj.x(a0)
0015ec : 3142 0004                : move.w d2,proj.y(a0)
0015f0 : 226e 0000                : movea.l screen.base(a6),a1
0015f4 : c4fc 00a0                : mulu #$a0,d2
0015f8 : d2c2                     : adda.w d2,a1
0015fa : 2401                     : move.l d1,d2
0015fc : 0241 000f                : andi.w #$f,d1
001600 : e24a                     : lsr.w #1,d2
001602 : 0242 00f8                : andi.w #$f8,d2
001606 : d2c2                     : adda.w d2,a1
001608 : 92fc 0010                : suba.w #$10,a1
00160c : 2849                     : movea.l a1,a4
00160e : 361c                     : move.w (a4)+,d3
001610 : 865c                     : or.w (a4)+,d3
001612 : 865c                     : or.w (a4)+,d3
001614 : 865c                     : or.w (a4)+,d3
001616 : 4843                     : swap d3
001618 : 361c                     : move.w (a4)+,d3
00161a : 865c                     : or.w (a4)+,d3
00161c : 865c                     : or.w (a4)+,d3
00161e : 865c                     : or.w (a4)+,d3
001620 : 2b03                     : move.l d3,-(a5)
001622 : 4683                     : not.l d3
001624 : 7400                     : moveq #0,d2
001626 : 341b                     : move.w (a3)+,d2
001628 : 4842                     : swap d2
00162a : e2aa                     : lsr.l d1,d2
00162c : c483                     : and.l d3,d2
00162e : 8569 000e                : or.w d2,14(a1)
001632 : 4842                     : swap d2
001634 : 8569 0006                : or.w d2,6(a1)
001638 : d2fc 00a0                : adda.w #$a0,a1
00163c : 2849                     : movea.l a1,a4
00163e : 361c                     : move.w (a4)+,d3
001640 : 865c                     : or.w (a4)+,d3
001642 : 865c                     : or.w (a4)+,d3
001644 : 865c                     : or.w (a4)+,d3
001646 : 4843                     : swap d3
001648 : 361c                     : move.w (a4)+,d3
00164a : 865c                     : or.w (a4)+,d3
00164c : 865c                     : or.w (a4)+,d3
00164e : 865c                     : or.w (a4)+,d3
001650 : 2b03                     : move.l d3,-(a5)
001652 : 4683                     : not.l d3
001654 : 7400                     : moveq #0,d2
001656 : 341b                     : move.w (a3)+,d2
001658 : 4842                     : swap d2
00165a : e2aa                     : lsr.l d1,d2
00165c : c483                     : and.l d3,d2
00165e : 8569 000e                : or.w d2,14(a1)
001662 : 4842                     : swap d2
001664 : 8569 0006                : or.w d2,6(a1)
001668 : 2b09                     : move.l a1,-(a5)
00166a : 4e75                     : rts 

00166c : 2f08                     : move.l a0,-(a7)
00166e : 41ee 2680                : lea alien.state(a6),a0
001672 : 3a2e 004c                : move.w alien.count(a6),d5
001676 : 4a28 000a                : tst.b 10(a0)
00167a : 6700 0108                : beq .l +$108
00167e : 3828 0002                : move.w 2(a0),d4
001682 : 6700 0100                : beq .l +$100
001686 : 0444 000e                : subi.w #$e,d4
00168a : b244                     : cmp.w d4,d1
00168c : 6d00 00f6                : blt .l +$f6
001690 : 0644 001c                : addi.w #$1c,d4
001694 : b244                     : cmp.w d4,d1
001696 : 6e00 00ec                : bgt .l +$ec
00169a : 3828 0004                : move.w 4(a0),d4
00169e : b444                     : cmp.w d4,d2
0016a0 : 6d00 00e2                : blt .l +$e2
0016a4 : 0644 0018                : addi.w #$18,d4
0016a8 : b444                     : cmp.w d4,d2
0016aa : 6e00 00d8                : bgt .l +$d8
0016ae : 7011                     : moveq #17,d0
0016b0 : 6100 201a                : bsr .l +$201a
0016b4 : 4a2e 00c1                : tst.b bonus.mode(a6)
0016b8 : 6600 0102                : bne .l +$102
0016bc : 0c28 0003 000a           : cmpi.b #$3,10(a0)
0016c2 : 666a                     : bne.s +106
0016c4 : 50ee 0097                : st  +$97(a6)
0016c8 : 4a2e 0072                : tst.b +$72(a6)
0016cc : 6660                     : bne.s +96
0016ce : 50ee 0072                : st  +$72(a6)
0016d2 : 51ee 0073                : sf  +$73(a6)
0016d6 : 48e7 0070                : movem.l a1-3,-(a7)
0016da : 227c ffff 8240           : movea.l #HW_VIDEO_PALETTE,a1
0016e0 : 45f9 0000 4a2c           : lea $4a2c,a2
0016e6 : 47f9 0000 4a4c           : lea $4a4c,a3
0016ec : 243c 0700 0700           : move.l #$7000700,d2
0016f2 : 2219                     : move.l (a1)+,d1
0016f4 : 26c1                     : move.l d1,(a3)+
0016f6 : 8242                     : or.w d2,d1
0016f8 : 24c1                     : move.l d1,(a2)+
0016fa : 2219                     : move.l (a1)+,d1
0016fc : 26c1                     : move.l d1,(a3)+
0016fe : 8282                     : or.l d2,d1
001700 : 24c1                     : move.l d1,(a2)+
001702 : 2219                     : move.l (a1)+,d1
001704 : 26c1                     : move.l d1,(a3)+
001706 : 8282                     : or.l d2,d1
001708 : 24c1                     : move.l d1,(a2)+
00170a : 2219                     : move.l (a1)+,d1
00170c : 26c1                     : move.l d1,(a3)+
00170e : 8282                     : or.l d2,d1
001710 : 24c1                     : move.l d1,(a2)+
001712 : 2219                     : move.l (a1)+,d1
001714 : 26c1                     : move.l d1,(a3)+
001716 : 24c1                     : move.l d1,(a2)+
001718 : 2219                     : move.l (a1)+,d1
00171a : 26c1                     : move.l d1,(a3)+
00171c : 24c1                     : move.l d1,(a2)+
00171e : 2219                     : move.l (a1)+,d1
001720 : 26c1                     : move.l d1,(a3)+
001722 : 24c1                     : move.l d1,(a2)+
001724 : 2219                     : move.l (a1)+,d1
001726 : 26c1                     : move.l d1,(a3)+
001728 : 24c1                     : move.l d1,(a2)+
00172a : 4cdf 0e00                : movem.l (a7)+,a1-3
			btst		#$7,hits.num(a0)
			bne			@exitok
			subq.b		#1,hits.num(a0)
			bne			@exitok
			cmpi.b		#$3,sprite.num(a0)
			bne.s		@skip
			move.b		#$2,last.path(a6)
@skip
			bsr .l		explode.alien
			move.w		KillScoreInc(a6),ScoreAdd(a6)
			// Play sound?
			moveq		#19,d0
			bsr .l		+$1f70
			move.w		kills.what(a0),d0
001762 : 41ee 2680                : lea alien.state(a6),a0
			move.w		alien.count(a6),d5
@kill.loop	lsr.w		#1,d0
			bcc.s		@nokill
			bsr.s		explode.alien
			move.w		BonusScoreInc(a6),ScoreAdd(a6)
@nokill		adda.w		0(a0),a0
			dbra		d5,@kill.loop
			andi.b		#$0,ccr
			bra.s		@exit
@next		adda.w		0(a0),a0
			dbra		d5,-276
			ori.b		#$4,ccr
@exit		movea.l		(a7)+,a0
			rts 

@exit_ok	andi.b		#$0,ccr
			bra.s		@exit

explode.alien
			clr.b		anim.num(a0)
			clr.b		sprite.num(a0)
			move.b		#$7,num.anims(a0)
			move.b		#$1,anim.delay(a0)
			move.b		#$1,anim.delay2(a0)
			bclr		#$3,mode(a0)
			rts 

0017bc : 536e 00c6                : subq.w #1,+$c6(a6)
0017c0 : 6616                     : bne.s +22
0017c2 : 3d7c 0007 00c6           : move.w #$7,+$c6(a6)
0017c8 : 1228 000b                : move.b 11(a0),d1
0017cc : b23c 0006                : cmp.b #$6,d1
0017d0 : 6702                     : beq.s +2
0017d2 : 5241                     : addq.w #1,d1
0017d4 : 1141 000b                : move.b d1,11(a0)
0017d8 : 205f                     : movea.l (a7)+,a0
0017da : 4e75                     : rts 

erase.projectiles
			move.w		(a5)+,d7								// Get particle count
			bra.s		@endofloop								// do the funky dbf thing
@loop
			movea.l		(a5)+,a1								// Get screen address
			move.w		(a5)+,d1
			and.w		d1,6(a1)								// Mask the particle out of the screen
			move.w		(a5)+,d1
			and.w		d1,14(a1)								// then from the following 16 pixels too
			move.w		(a5)+,d1
			and.w		d1,BYTES_PER_LINE-6(a1)					// and now on the previous line
			move.w		(a5)+,d1
			and.w		d1,BYTES_PER_LINE-14(a1)
			dbra		d7,@loop
			rts 

001800 : 4a6e 009e                : 
draw.ship
			tst.w		forcefield.timer(a6)
			beq.s		@noforcefield
			subi.w		#$1,forcefield.timer(a6)
			not.b		ForceFieldFlash(a6)
			beq .l		next.stage								// Not to draw the ship?
@noforcefield	
			move.b		joy.btn(a6),d0
			move.w		+$84(a6),d1
			moveq		#0,d2
			lsr.w		#1,d0
			subx.b		d2,d1
			lsr.w		#1,d0
			addx.b		d2,d1
			move.w		d1,$82(a6)
			movea.l		#$50100,a1
			adda.w		12(a1),a1
			mulu		#$140,d1								// ship anim frame size
			adda.w		d1,a1
			move.w		ship.x(a6),d2							// X position of something
			move.w		ship.y(a6),d3							// Y position of something
			movea.l		screen.base(a6),a0
			mulu		#LINE_WIDTH_BYTES,d3
			adda.w		d3,a0
			move.l		d2,d3
			andi.w		#$f,d2
			lsr.w		#1,d3
			andi.w		#$f8,d3
			adda.w		d3,a0
			suba.w		#$10,a0
			move.l		d2,d1
			move.l		d1,d0
			lsl.l		#3,d0
			lea		$3d9e,a2									// Something is being drawn here. I used the first 3 words to generate
			adda.w		d0,a2									// a mask for the last word (which was then used as a collision plane)
			move.l		(a2)+,d6								// This is most likely bad-guy rendering since they all used the upper
			move.l		(a2),d7									// 8 colours
			lea			8(a0),a2
			lea			16(a0),a3
			sf			ship.collision(a6)
			moveq		#20-1,d2
@spritelp
			movea.l		a0,a4
			move.w		(a4)+,d4								// Create a restore mask for the line we're about to draw
			or.w		(a4)+,d4
			or.w		(a4)+,d4
			or.w		(a4)+,d4
			swap		d4
			move.w		(a4)+,d4
			or.w		(a4)+,d4
			or.w		(a4)+,d4
			or.w		(a4)+,d4
			move.w		(a4)+,d5
			or.w		(a4)+,d5
			or.w		(a4)+,d5
			or.w		(a4)+,d5
			move.w		d5,-(a5)								// Store the mask for later use
			move.l		d4,-(a5)
			not.l		d4										// Invert the mask for now
			not.w		d5	
				REPT 4
			move.l		(a1)+,d0								// Get 32 bits of sprite data
			ror.l		d1,d0									// Shift in to the right place
			move.l		d0,d3
			swap		d3
			and.l		d6,d0									// mask it with the shift mask
			and.w		d7,d3
			and.l		d4,d0									// mask it with the screen mask
			and.w		d5,d3
			or.w		d3,(a3)+								// and now write it to the screen
			or.w		d0,(a2)+
			swap		d0
			or.w		d0,(a0)+
				ENDR

			move.l		-4(a1),d0								// figure out if this sprite collided with anything (landscape included)
			ror.l		d1,d0
			move.l		d0,d3
			swap		d3
			and.l		d6,d0
			and.w		d7,d3
			not.l		d4
			not.w		d5
			and.l		d4,d0
			beq.s		@nocol1
			st			ship.collision(a6)						// Collision occurred
@nocol1
			and.w		d5,d3
			beq.s		@nocol2
			st			ship.collision(a6)
@nocol2
			move.w		#BYTES_PER_LINE-8,d0
			adda.w		d0,a0
			adda.w		d0,a2
			adda.w		d0,a3
			dbra		d2,@spritelp

			suba.w		#$a0,a0									// Store address of last line
			move.w		#20-1,-(a5)								// 20 lines to be restored
			move.l		a0,-(a5)								// Address to be restored
			tst.b		ship.collision(a6)
			beq.s		@nocollide
			tst.w		forcefield.timer(a6)
			bne.s		@nocollide
			clr.b		ship.collision(a6)
			move.w		landcoll.damage(a6),d0
			tst.b		difficulty.level(a6)
			bne.s		@nocollide
			add.w		d0,ship.damage(a6)
@nocollide
			rts 

// Do a coordinate check to see if we collided with a bad guy. I suppose I could have
// masked that in too but if I remember right, there's a good reason, speed wise, for
// doing it this way. Done using bounding boxes of a fixed size.
check.collision
			tst.b		bonus.mode(a6)
			bne			bonus.collcheck
			move.w		ship.x(a6),d2
			move.w		ship.y(a6),d3
			movea.l		screen.base(a6),a0
			mulu		#$a0,d3
			adda.w		d3,a0
			move.l		d2,d3
			andi.w		#$f,d2
			lsr.w		#1,d3
			andi.w		#$f8,d3
			adda.w		d3,a0
			suba.w		#$10,a0
			move.w		+$82(a6),d1
			mulu		#$4,d1
			lea			@table(pc,d1.W),a1
			moveq		#1,d0
@next		move.w		(a1)+,d1
			tst.w		14(a0,d1.W)
			beq.s		@nocol
			st			ship.collision(a6)
@nocol		dbra		d0,@next
			tst.b		ship.collision(a6)
			beq.s		@exit
			tst.w		forcefield.timer(a6)
			bne.s		@exit
			tst.b		difficulty.level(a6)					// This doesn't make sense.
			bne.s		@exit
			move.w		+$e0(a6),d0
			add.w		d0,ship.damage(a6)
@exit		rts 
@table		dc.w		$00a0,$0be0,$00a0,$0b40
			dc.w		$00a0,$0b40,$00a0,$0be0
			dc.w		$00a0,$0b40,$00a0,$0d20
			dc.w		$00a0,$0be0,$ff60,$0b40
			dc.w		$00a0,$0b40,$00a0,$0be0
			dc.w		$ff60,$0b40,$00a0,$0d20
19f2:
bonus.collcheck
// Check for collision with bonus icon?
            lea			alien.state(a6),a0
			move.w		ship.x(a6),d1
			move.w		ship.y(a6),d2
			move.w		x.pos(a0),d3
			move.w		y.pos(a0),d4
			subi.w		#$10,d3
			subi.w		#$a,d4
			cmp.w		d3,d1
			blt.s		@done
			cmp.w		d4,d2
			blt.s		@done
			addi.w		#$20,d3
			addi.w		#$14,d4
			cmp.w		d3,d1
			bhi.s		@done
			cmp.w		d4,d2
			bhi.s		@done
			clr.w		x.pos(a0)
			clr.b		bonus.mode(a6)
			clr.l		d0
			move.b		sprite.num(a0),d0						// Play sound when we hit the bonus icon
			lea			bonus.samples,a1
			move.b		0(a1,d0.W),d0
			bsr			play.sound
001a42 : 50ee 0078                : st  +$78(a6)
			move.b		anim.num(a0),d0
			beq .l		powerup.bonus
			subq.w		#1,d0
			beq .l		powerup.laser
			subq.w		#1,d0
			beq .l		powerup.canon
			subq.w		#1,d0
			beq.s		powerup.speed
			subq.w		#1,d0
			beq.s		powerup.outrider
			subq.w		#1,d0
			beq.s		powerup.forcefield
			bsr			powerup.shields
@done		rts 
// Add bonus
powerup.bonus
			move.w		#$1000,ScoreAdd(a6)
			rts 
powerup.speed
			cmpi.w		#$a,ship.speed(a6)						// If we've had 10 speedups, just give bonus
			bhi.s		powerup.bonus
			addi.w		#$1,ship.speed(a6)
			moveq		#1,d0
			move.b		speedup.bonuses(a6),d1
			move		#$0,ccr
			abcd		d0,d1
			move.b		d1,speedup.bonuses(a6)
			rts 
// Reset shields or forcefield?
powerup.forcefield
			move.w		#400,forcefield.timer(a6)				// Forcefield enabled for 16 seconds(?)
			sf			ForceFieldFlash(a6)
			moveq		#1,d0
			move.b		forcefield.bonuses(a6),d1
			move		#$0,ccr
			abcd		d0,d1
			move.b		d1,forcefield.bonuses(a6)
			rts 
// Add outrider?
powerup.outrider
			tst.b		mult1.on(a6)
			sne			mult2.on(a6)
			st			mult1.on(a6)
			moveq		#1,d0
			move.b		outrider.bonuses(a6),d1
			move		#$0,ccr
			abcd		d0,d1
			move.b		d1,outrider.bonuses(a6)
			rts 
draw.outrider
			moveq		#0,d1
			moveq		#0,d2
			tst.b		mult1.on(a6)
			beq.s		@NoOutriders
			move.w		ship.x(a6),d1
			move.w		ship.y(a6),d2
			subi.b		#8,d2
			bcc.s		@nocliptop
			clr.l		d2
@nocliptop	lea			GFX_TOP_OUTRIDER,a1
			bsr.s		@RenderOutrider
			tst.b		mult2.on(a6)
			beq.s		@OneOutrider
			moveq		#0,d1
			moveq		#0,d2
			move.w		ship.x(a6),d1
			move.w		ship.y(a6),d2
			addi.b		#19,d2
			cmp.w		#182,d2
			bls.s		@noclipbtm
			move.w		#182,d2
@noclipbtm	lea			GFX_BTM_OUTRIDER,a1
			bsr.s		@RenderOutrider
			move.w		#$2,-(a5)
			rts 
@NoOutriders
			move.w		#$0,-(a5)
			rts 
@OneOutrider
			move.w		#$1,-(a5)
			rts 
// Entry:
//		D1 - X position
//		D2 - Y position
//		A1 - Base of graphic data
@RenderOutrider
			moveq		#9,d0
			sub.w		+$8c(a6),d0
			lsr.w		#1,d0
			movea.l		screen.base(a6),a0
			mulu		#BYTES_PER_LINE,d2						// Convert y to screen offset
			adda.w		d2,a0
			move.l		d1,d2
			andi.w		#$f,d1									// D1 - bit offset within word
			lsr.w		#1,d2									// D2 - x coord converted to byte offset
			andi.w		#$f8,d2
			adda.w		d2,a0
			suba.w		#$10,a0
			mulu		#4*3*9,d0								// 32 pixels wide, 3 bitplanes, 9 pixels high
			adda.w		d0,a1
			moveq		#8,d0									// 9 pixels high
@drawloop	lea			8(a0),a2
			movea.l		a0,a4									// Create a 32 bit pixel mask from screen contents
			move.w		(a4)+,d4
			or.w		(a4)+,d4
			or.w		(a4)+,d4
			or.w		(a4)+,d4
			swap		d4
			move.w		(a4)+,d4
			or.w		(a4)+,d4
			or.w		(a4)+,d4
			or.w		(a4)+,d4
			move.l		d4,-(a5)								// Save screen mask for later restore
			not.l		d4

			move.w		(a1)+,d7								// Get bitplane 0 data
			swap		d7										// Move it to top 16 bits
			clr.w		d7										// Make sure nothing else there
			lsr.l		d1,d7									// Shift it to position
			and.l		d4,d7									// Mask it with screen mask

			move.w		(a1)+,d6								// Get bitplane 1 data
			swap		d6										// Move it to top 16 bits
			clr.w		d6										// Make sure nothing else there
			lsr.l		d1,d6									// Shift it to position
			and.l		d4,d6									// Mask it with screen mask

			move.w		(a1)+,d5								// Get bitplane 1 data
			swap		d5										// Move it to top 16 bits
			clr.w		d5										// Make sure nothing else there
			lsr.l		d1,d5									// Shift it to position
			and.l		d4,d5									// Mask it with screen mask

			or.w		d7,(a2)+								// Write to bitplane 0
			or.w		d6,(a2)+								// Write to bitplane 1
			addq.w		#2,a2									// Skip bitplane 2
			or.w		d5,(a2)+								// Write to bitplane 3

			swap		d7										// Switch to upper words
			swap		d6
			swap		d5

			or.w		d7,(a0)+								// Write to bitplane 0
			or.w		d6,(a0)+								// Write to bitplane 1
			addq.w		#2,a0									// Skip bitplane 2
			or.w		d5,(a0)+								// Write to bitplane 3
			adda.w		#BYTES_PER_LINE-8,a0					// On to next scanline
			adda.w		#BYTES_PER_LINE-8,a2									
			dbra		d0,@drawloop							// Do next line

			suba.w		#$a0,a0									// Store restore address
			move.l		a0,-(a5)
			rts 

// I once saw a profile of the 68k instruction set with respect to a C compiler and that
// used a branch to the end of a for loop for the condition check and loop count branch back
// using dbxx instructions. I saw no particular disadvantage to the method so I thought I'd
// use it anyway.
erase.outrider
			move.w		(a5)+,d7								// Get outrider count
			move.w		#BYTES_PER_LINE+16,d2					// Line modulo
			bra.s		@enter
			movea.l		(a5)+,a0
			moveq		#9-1,d6									// outrider is 9 pixels high
@blkloop
			move.w		(a5),d1									// Get mask (16 bit)
			swap		d1										// dup it in a 32 bit register
			move.w		(a5)+,d1
			and.l		d1,(a0)+								// mask it to bitplanes 0+1
			and.l		d1,(a0)+								// mask it to bitplanes 2+3
			move.w		(a5),d1									// do it again for the next 16 pixels
			swap		d1
			move.w		(a5)+,d1
			and.l		d1,(a0)+
			and.l		d1,(a0)+
			suba.w		d2,a0									// add the line modulo
			dbra		d6,@blkloop								// back again....
@enter
			dbra		d7,@next
			rts 

001be6 : 43f9 0000 3e3a           : lea $3e3a,a1
001bec : 302e 0094                : move.w +$94(a6),d0
001bf0 : e948                     : lsl.w #4,d0
001bf2 : d2c0                     : adda.w d0,a1
001bf4 : 2b09                     : move.l a1,-(a5)
001bf6 : 206e 0000                : movea.l screen.base(a6),a0
001bfa : 7607                     : moveq #7,d3
001bfc : 342e 0092                : move.w +$92(a6),d2
001c00 : 7200                     : moveq #0,d1
001c02 : 3019                     : move.w (a1)+,d0
001c04 : 45f0 0000                : lea 0(a0,d0.W),a2
001c08 : 4a9a                     : tst.l (a2)+
001c0a : 660a                     : bne.s +10
001c0c : 4a92                     : tst.l (a2)
001c0e : 6606                     : bne.s +6
001c10 : 3542 0002                : move.w d2,2(a2)
001c14 : 07c1                     : bset d3,d1
001c16 : 51cb ffea                : dbra d3,-22
001c1a : 3b01                     : move.w d1,-(a5)
001c1c : 4a2e 0090                : tst.b +$90(a6)
001c20 : 66c2                     : bne.s -62
001c22 : e35a                     : rol.w #1,d2
001c24 : 0802 0000                : btst #$0,d2
001c28 : 6710                     : beq.s +16
001c2a : 302e 0094                : move.w +$94(a6),d0
001c2e : 5240                     : addq.w #1,d0
001c30 : 0240 000f                : andi.w #$f,d0
001c34 : 3d40 0094                : move.w d0,+$94(a6)
001c38 : 7401                     : moveq #1,d2
001c3a : 3d42 0092                : move.w d2,+$92(a6)
001c3e : 4e75                     : rts 

erase.starfield
001c40 : 2056                     : movea.l (a6),a0
001c42 : 321d                     : move.w (a5)+,d1
001c44 : 225d                     : movea.l (a5)+,a1
001c46 : 7607                     : moveq #7,d3
001c48 : 7400                     : moveq #0,d2
001c4a : 3019                     : move.w (a1)+,d0																		
001c4c : 45f0 0000                : lea 0(a0,d0.W),a2
001c50 : 0701                     : btst d3,d1
001c52 : 6704                     : beq.s +4
001c54 : 3542 0006                : move.w d2,6(a2)
001c58 : 51cb fff0                : dbra d3,-16
001c5c : 4e75                     : rts 
update.scores
001c5e : 41ee 00d0                : lea ScoreAdd(a6),a0
001c62 : 4a58                     : tst.w (a0)+
001c64 : 672a                     : beq.s +42
001c66 : 43ee 00d6                : lea +$d6(a6),a1
001c6a : 44fc 0000                : move #$0,ccr
001c6e : c308                     : abcd -(a0),-(a1)
001c70 : c308                     : abcd -(a0),-(a1)
001c72 : c308                     : abcd -(a0),-(a1)
001c74 : 41ee 00d2                : lea +$d2(a6),a0
001c78 : 43ee 00da                : lea ship.energy(a6),a1
001c7c : 44fc 0000                : move #$0,ccr
001c80 : c308                     : abcd -(a0),-(a1)
001c82 : c308                     : abcd -(a0),-(a1)
001c84 : c308                     : abcd -(a0),-(a1)
001c86 : 4a2e 0098                : tst.b +$98(a6)
001c8a : 6604                     : bne.s +4
001c8c : 426e 00d0                : clr.w ScoreAdd(a6)
001c90 : 246e 0000                : movea.l screen.base(a6),a2
001c94 : d4fc 04e7                : adda.w #$4e7,a2
001c98 : 7602                     : moveq #2,d3
001c9a : 7000                     : moveq #0,d0
001c9c : 41ee 00d3                : lea +$d3(a6),a0
001ca0 : 1010                     : move.b (a0),d0
001ca2 : e808                     : lsr.b #4,d0
001ca4 : 6138                     : bsr.s print.scorech
001ca6 : 5e4a                     : addq.w #7,a2
001ca8 : 1018                     : move.b (a0)+,d0
001caa : 0240 000f                : andi.w #$f,d0
001cae : 612e                     : bsr.s print.scorech
001cb0 : 524a                     : addq.w #1,a2
001cb2 : 51cb ffec                : dbra d3,-20
001cb6 : 4a6e 0080                : tst.w demo.timer(a6)
001cba : 601a                     : bra.s +26
001cbc : 302e 011c                : move.w LowMemChecksum(a6),d0
001cc0 : b079 0000 0040           : cmp.w $40,d0
001cc6 : 6610                     : bne.s +16
001cc8 : 202e 0120                : move.l +$120(a6),d0
001ccc : 0480 0000 170c           : subi.l #$170c,d0
001cd2 : 5bee 0080                : smi demo.timer(a6)
001cd6 : 4e75                     : rts 

001cd8 : 50ee 0080                : st  demo.timer(a6)
001cdc : 4e75                     : rts 
// Entry: D0 - Character #
//		  A2 - Screen Buffer position
print.scorech
			move.b		@offset(pc,d0.W),d0						// Some sort of character printing
			lea			@bitmap(pc,d0.W),a1
			move.b		(a1)+,(a2)
			move.b		(a1)+,BYTES_PER_LINE*1(a2)
			move.b		(a1)+,BYTES_PER_LINE*2(a2)
			move.b		(a1)+,BYTES_PER_LINE*3(a2)
			move.b		(a1)+,BYTES_PER_LINE*4(a2)
			move.b		(a1)+,BYTES_PER_LINE*5(a2)
			move.b		(a1)+,BYTES_PER_LINE*6(a2)
			rts 
@offset
		dc.b $00,$08,$10,$18
		dc.b $20,$28,$30,$38
		dc.b $40,$48
@bitmap
		dc.l $7cc6c600,$c6c67c00			// 0
		dc.l $06060600,$06060600			// 1
	    dc.l $7c06067c,$c0c07c00			// 2
		dc.l $7c06067c,$06067c00			// 3
		dc.l $c6c6c67c,$06060600			// 4
		dc.l $7cc0c07c,$06067c00			// 5
		dc.l $7cc0c07c,$c6c67c00			// 6
		dc.l $7c060600,$06060600			// 7
		dc.l $7cc6c67c,$c6c67c00			// 8
		dc.l $7cc6c67c,$06067c00			// 9
powerup.canon
001d5c : 7001                     : moveq #1,d0
001d5e : 122e 0117                : move.b canon.bonuses(a6),d1
001d62 : 44fc 0000                : move #$0,ccr
001d66 : c300                     : abcd d0,d1
001d68 : 1d41 0117                : move.b d1,canon.bonuses(a6)
001d6c : 700a                     : moveq #10,d0
001d6e : b06e 0084                : cmp.w +$84(a6),d0
001d72 : 6712                     : beq.s +18
001d74 : 7007                     : moveq #7,d0
001d76 : b06e 0084                : cmp.w +$84(a6),d0
001d7a : 670a                     : beq.s +10
001d7c : 0c6e 0001 0084           : cmpi.w #$1,+$84(a6)
001d82 : 6702                     : beq.s +2
001d84 : 700a                     : moveq #10,d0
001d86 : 3d40 0084                : move.w d0,+$84(a6)
001d8a : 4aee 009b                : tas.b CanonsActive(a6)
001d8e : 675e                     : beq.s +94
001d90 : 724f                     : moveq #79,d1
001d92 : 383c 5630                : move.w #$5630,d4
001d96 : 3d41 00ea                : move.w d1,CanonBarLength(a6)
draw.bar
001d9a : 7404                     : moveq #4,d2
001d9c : 2c3c 0000 0055           : move.l #$55,d6
001da2 : e4be                     : ror.l d2,d6
001da4 : 2a06                     : move.l d6,d5
001da6 : 4845                     : swap d5
001da8 : 4280                     : clr.l d0
001daa : 43ee 0028                : lea screen.bufptrs(a6),a1
001dae : 7e07                     : moveq #7,d7
001db0 : 2059                     : movea.l (a1)+,a0
001db2 : d0c4                     : adda.w d4,a0
001db4 : 4280                     : clr.l d0
001db6 : 3001                     : move.w d1,d0
001db8 : 602c                     : bra.s +44
001dba : 8d58                     : or.w d6,(a0)+
001dbc : 5848                     : addq.w #4,a0
001dbe : 8d58                     : or.w d6,(a0)+
001dc0 : 8b58                     : or.w d5,(a0)+
001dc2 : 5848                     : addq.w #4,a0
001dc4 : 8b58                     : or.w d5,(a0)+
001dc6 : 90fc 00b0                : suba.w #$b0,a0
001dca : 5340                     : subq.w #1,d0
001dcc : 6b1c                     : bmi.s +28
001dce : e29e                     : ror.l #1,d6
001dd0 : e29d                     : ror.l #1,d5
001dd2 : 8d58                     : or.w d6,(a0)+
001dd4 : 5848                     : addq.w #4,a0
001dd6 : 8d58                     : or.w d6,(a0)+
001dd8 : 8b58                     : or.w d5,(a0)+
001dda : 5848                     : addq.w #4,a0
001ddc : 8b58                     : or.w d5,(a0)+
001dde : 90fc 00b0                : suba.w #$b0,a0
001de2 : e39e                     : rol.l #1,d6
001de4 : e39d                     : rol.l #1,d5
001de6 : 51c8 ffd2                : dbra d0,-46
001dea : 51cf ffc4                : dbra d7,-60
001dee : 4e75                     : rts 
powerup.laser
001df0 : 7001                     : moveq #1,d0
001df2 : 122e 0116                : move.b laser.bonuses(a6),d1
001df6 : 44fc 0000                : move #$0,ccr
001dfa : c300                     : abcd d0,d1
001dfc : 1d41 0116                : move.b d1,laser.bonuses(a6)
001e00 : 0c6e 000a 0084           : cmpi.w #$a,+$84(a6)
001e06 : 670c                     : beq.s +12
001e08 : 0c6e 0004 0084           : cmpi.w #$4,+$84(a6)
001e0e : 6704                     : beq.s +4
001e10 : 566e 0084                : addq.w #3,+$84(a6)
001e14 : 4aee 009a                : tas.b LasersActive(a6)
001e18 : 67d4                     : beq.s -44
001e1a : 383c 5628                : move.w #$5628,d4
001e1e : 724f                     : moveq #79,d1
001e20 : 3d41 00e6                : move.w d1,LaserBarLength(a6)
001e24 : 50ee 009a                : st  LasersActive(a6)
001e28 : 7403                     : moveq #3,d2
001e2a : 6000 ff70                : bra .l -$90
powerup.sheilds
001e2e : 7001                     : moveq #1,d0
001e30 : 122e 0118                : move.b energy.bonuses(a6),d1
001e34 : 44fc 0000                : move #$0,ccr
001e38 : c300                     : abcd d0,d1
001e3a : 1d41 0118                : move.b d1,energy.bonuses(a6)
001e3e : 724f                     : moveq #79,d1
001e40 : 383c 5620                : move.w #$5620,d4
001e44 : 3d41 00ee                : move.w d1,EnergyBarLength(a6)
001e48 : 7402                     : moveq #2,d2
001e4a : 6000 ff50                : bra .l -$b0
loop2.update
001e4e : 6100 00fe                : bsr .l +$fe
001e52 : 6100 01b8                : bsr .l +$1b8
001e56 : 6100 012c                : bsr .l +$12c
001e5a : 4a6e 006e                : tst.w +$6e(a6)
001e5e : 6722                     : beq.s +34
001e60 : 536e 006e                : subq.w #1,+$6e(a6)
001e64 : 302e 006e                : move.w +$6e(a6),d0
001e68 : 0240 0001                : andi.w #$1,d0
001e6c : 6614                     : bne.s +20
001e6e : 5239 0005 85c4           : addq.b #1,$585c4
001e74 : 4a2e 0070                : tst.b +$70(a6)
001e78 : 6700 0008                : beq .l +$8
001e7c : 5539 0005 85c4           : subq.b #2,$585c4
001e82 : 0c2e 0003 00c0           : cmpi.b #$3,last.path(a6)
001e88 : 660c                     : bne.s +12
001e8a : 4a39 0005 85bf           : tst.b $585bf
001e90 : 7013                     : moveq #19,d0
001e92 : 6100 1838                : bsr .l +$1838
001e96 : 4a6e 0074                : tst.w +$74(a6)
001e9a : 6726                     : beq.s +38
001e9c : 4a39 0005 85bf           : tst.b $585bf
001ea2 : 661e                     : bne.s +30
001ea4 : 4a6e 0076                : tst.w +$76(a6)
001ea8 : 6706                     : beq.s +6
001eaa : 536e 0076                : subq.w #1,+$76(a6)
001eae : 6012                     : bra.s +18
001eb0 : 303c 0082                : move.w #$82,d0
001eb4 : 6100 1816                : bsr .l +$1816
001eb8 : 3d7c 0001 0076           : move.w #$1,+$76(a6)
001ebe : 536e 0074                : subq.w #1,+$74(a6)
001ec2 : 4280                     : clr.l d0
001ec4 : 102e 0064                : move.b keycode(a6),d0
001ec8 : b03c 0039                : cmp.b #$39,d0
001ecc : 6700 0034                : beq .l +$34
001ed0 : b03c 0032                : cmp.b #$32,d0
001ed4 : 6708                     : beq.s +8
001ed6 : b03c 0012                : cmp.b #$12,d0
001eda : 6716                     : beq.s +22
001edc : 4e75                     : rts 

001ede : 086e 0000 0079           : bchg #$0,+$79(a6)
001ee4 : 6606                     : bne.s +6
001ee6 : 4ef9 0005 7d1c           : jmp $57d1c
001eec : 4ef9 0005 7d2a           : jmp $57d2a
001ef2 : 086e 0001 0079           : bchg #$1,+$79(a6)
001ef8 : 4e75                     : rts 

001efa : 066e 0001 00ca           : addi.w #$1,game.stage(a6)
001f00 : 4e75                     : rts 

001f02 : 422e 0063                : clr.b joy.btn(a6)
001f06 : 4a6e 0080                : tst.w demo.timer(a6)
001f0a : 660c                     : bne.s +12
001f0c : 7202                     : moveq #2,d1
001f0e : 7007                     : moveq #SYS_DELAY_FRAMES,d0
001f10 : 4e44                     : trap #4
001f12 : 4a2e 0063                : tst.b joy.btn(a6)
001f16 : 67f4                     : beq.s -12
001f18 : 4e75                     : rts 

001f1a : 41f9 0000 4a2c           : lea $4a2c,a0
001f20 : 6100 03f8                : bsr .l +$3f8
001f24 : 4a00                     : tst.b d0
001f26 : 6624                     : bne.s +36
001f28 : 4a2e 0073                : tst.b +$73(a6)
001f2c : 661a                     : bne.s +26
001f2e : 50ee 0073                : st  +$73(a6)
001f32 : 41f9 0000 4a4c           : lea $4a4c,a0
001f38 : 43f9 0000 4a2c           : lea $4a2c,a1
001f3e : 7007                     : moveq #7,d0
001f40 : 22d8                     : move.l (a0)+,(a1)+
001f42 : 51c8 fffc                : dbra d0,-4
001f46 : 6004                     : bra.s +4
001f48 : 422e 0072                : clr.b +$72(a6)
001f4c : 4e75                     : rts 

001f4e : 45ee 00e6                : lea LaserBarLength(a6),a2
001f52 : 3212                     : move.w (a2),d1
001f54 : 6700 f45e                : beq .l -$ba2
001f58 : 302a 0002                : move.w 2(a2),d0
001f5c : e448                     : lsr.w #2,d0
001f5e : b240                     : cmp.w d0,d1
001f60 : 6a08                     : bpl.s +8
001f62 : 3212                     : move.w (a2),d1
001f64 : e549                     : lsl.w #2,d1
001f66 : 3541 0002                : move.w d1,2(a2)
001f6a : 363c 5628                : move.w #$5628,d3
001f6e : 7404                     : moveq #4,d2
001f70 : 6000 0034                : bra .l +$34
001f74 : 3d7c 0001 0084           : move.w #$1,+$84(a6)
001f7a : 51ee 009a                : sf  LasersActive(a6)
001f7e : 51ee 009b                : sf  CanonsActive(a6)
001f82 : 4e75                     : rts 

001f84 : 45ee 00ea                : lea CanonBarLength(a6),a2
001f88 : 3212                     : move.w (a2),d1
001f8a : 6700 f428                : beq .l -$bd8
001f8e : 302a 0002                : move.w 2(a2),d0
001f92 : e448                     : lsr.w #2,d0
001f94 : b240                     : cmp.w d0,d1
001f96 : 6a08                     : bpl.s +8
001f98 : 3212                     : move.w (a2),d1
001f9a : e549                     : lsl.w #2,d1
001f9c : 3541 0002                : move.w d1,2(a2)
001fa0 : 363c 5630                : move.w #$5630,d3
001fa4 : 7405                     : moveq #5,d2
001fa6 : 4281                     : clr.l d1
001fa8 : 3212                     : move.w (a2),d1
001faa : 6358                     : bls.s +88
001fac : 2c3c 0000 01ff           : move.l #$1ff,d6
001fb2 : e4be                     : ror.l d2,d6
001fb4 : 2a06                     : move.l d6,d5
001fb6 : 4846                     : swap d6
001fb8 : 3c05                     : move.w d5,d6
001fba : 4845                     : swap d5
001fbc : 3005                     : move.w d5,d0
001fbe : 4845                     : swap d5
001fc0 : 3a00                     : move.w d0,d5
001fc2 : 4685                     : not.l d5
001fc4 : 4686                     : not.l d6
001fc6 : 4284                     : clr.l d4
001fc8 : 382a 0002                : move.w 2(a2),d4
001fcc : e44c                     : lsr.w #2,d4
001fce : 673a                     : beq.s +58
001fd0 : c2fc 00a0                : mulu #$a0,d1
001fd4 : 9641                     : sub.w d1,d3
001fd6 : 0643 00a0                : addi.w #$a0,d3
001fda : 7e07                     : moveq #7,d7
001fdc : 43ee 0028                : lea screen.bufptrs(a6),a1
001fe0 : 2059                     : movea.l (a1)+,a0
001fe2 : d0c3                     : adda.w d3,a0
001fe4 : 3004                     : move.w d4,d0
001fe6 : 600c                     : bra.s +12
001fe8 : cd98                     : and.l d6,(a0)+
001fea : cd98                     : and.l d6,(a0)+
001fec : cb98                     : and.l d5,(a0)+
001fee : cb98                     : and.l d5,(a0)+
001ff0 : d0fc 0090                : adda.w #$90,a0
001ff4 : 51c8 fff2                : dbra d0,-14
001ff8 : 51cf ffe6                : dbra d7,-26
001ffc : 302a 0002                : move.w 2(a2),d0
002000 : e448                     : lsr.w #2,d0
002002 : 9152                     : sub.w d0,(a2)
002004 : 026a 0003 0002           : andi.w #$3,2(a2)
00200a : 4e75                     : rts 

00200c : 4a2e 0112                : tst.b +$112(a6)
002010 : 6626                     : bne.s +38
002012 : 45ee 00ee                : lea EnergyBarLength(a6),a2
002016 : 3212                     : move.w (a2),d1
002018 : 6300 07f8                : bls .l +$7f8
00201c : 302a 0002                : move.w 2(a2),d0
002020 : e448                     : lsr.w #2,d0
002022 : b240                     : cmp.w d0,d1
002024 : 6a08                     : bpl.s +8
002026 : 3212                     : move.w (a2),d1
002028 : e549                     : lsl.w #2,d1
00202a : 3541 0002                : move.w d1,2(a2)
00202e : 7403                     : moveq #3,d2
002030 : 363c 5620                : move.w #$5620,d3
002034 : 6000 ff70                : bra .l -$90
002038 : 4e75                     : rts 
check.fire
00203a : 4a6e 0080                : tst.w demo.timer(a6)
00203e : 6600 01ea                : bne .l @done
002042 : 082e 0007 0063           : btst #$7,joy.btn(a6)
002048 : 6700 01e0                : beq .l @done
00204c : 4a2e 0062                : tst.b 98(a6)
002050 : 6600 01ce                : bne .l +$1ce ; // 2220
002054 : 50ee 0062                : st  98(a6)
002058 : 4a2e 009a                : tst.b LasersActive(a6)
00205c : 6714                     : beq.s +20
00205e : 4a6e 00e6                : tst.w LaserBarLength(a6)
002062 : 670e                     : beq.s +14
002064 : 7e02                     : moveq #2,d7
002066 : 0f2e 007b                : btst d7,+$7b(a6)
00206a : 6700 009a                : beq .l +$9a
00206e : 51cf fff6                : dbra d7,-10
002072 : 7e03                     : moveq #3,d7
002074 : 0f2e 007c                : btst d7,+$7c(a6)
002078 : 6756                     : beq.s +86
00207a : 51cf fff8                : dbra d7,-8
00207e : 4a2e 009b                : tst.b CanonsActive(a6)
002082 : 6714                     : beq.s +20
002084 : 4a6e 00ea                : tst.w CanonBarLength(a6)
002088 : 670e                     : beq.s +14
00208a : 7e02                     : moveq #2,d7
00208c : 0f2e 007a                : btst d7,+$7a(a6)
002090 : 6700 00b0                : beq .l +$b0
002094 : 51cf fff6                : dbra d7,-10
002098 : 4a2e 0078                : tst.b +$78(a6)
00209c : 6608                     : bne.s +8
00209e : 302e 008e                : move.w +$8e(a6),d0
0020a2 : 6100 1628                : bsr .l play.sound
0020a6 : 4a2e 009c                : tst.b mult1.on(a6)
0020aa : 670e                     : beq.s +14
0020ac : 7e01                     : moveq #1,d7
0020ae : 0f2e 007d                : btst d7,+$7d(a6)
0020b2 : 6700 00ca                : beq .l +$ca
0020b6 : 51cf fff6                : dbra d7,-10
0020ba : 4a2e 009d                : tst.b mult2.on(a6)
0020be : 670e                     : beq.s +14
0020c0 : 7e01                     : moveq #1,d7
0020c2 : 0f2e 007e                : btst d7,+$7e(a6)
0020c6 : 6700 00ce                : beq .l +$ce
0020ca : 51cf fff6                : dbra d7,-10
0020ce : 4e75                     : rts 

0020d0 : 6100 0134                : bsr .l +$134
0020d4 : 6700 014a                : beq .l +$14a
0020d8 : 0fee 007c                : bset d7,+$7c(a6)
0020dc : 30fc 000e                : move.w #$e,(a0)+
0020e0 : 7016                     : moveq #22,d0
0020e2 : d06e 0086                : add.w ship.x(a6),d0
0020e6 : 30c0                     : move.w d0,(a0)+
0020e8 : 700a                     : moveq #10,d0
0020ea : d06e 0088                : add.w ship.y(a6),d0
0020ee : 30c0                     : move.w d0,(a0)+
0020f0 : 20fc 000c 0000           : move.l #$c0000,(a0)+
0020f6 : 10fc 0002                : move.b #$2,(a0)+
0020fa : 10c7                     : move.b d7,(a0)+
0020fc : 3d7c 0001 008e           : move.w #$1,+$8e(a6)
002102 : 6000 ff7a                : bra .l -$86
002106 : 6100 00fe                : bsr .l +$fe
00210a : 6700 0114                : beq .l +$114
00210e : 0fee 007b                : bset d7,+$7b(a6)
002112 : 30fc 0007                : move.w #$7,(a0)+
002116 : 7011                     : moveq #17,d0
002118 : d06e 0086                : add.w ship.x(a6),d0
00211c : 30c0                     : move.w d0,(a0)+
00211e : 7011                     : moveq #17,d0
002120 : d06e 0088                : add.w ship.y(a6),d0
002124 : 30c0                     : move.w d0,(a0)+
002126 : 20fc 000a 0000           : move.l #$a0000,(a0)+
00212c : 10fc 0001                : move.b #$1,(a0)+
002130 : 10c7                     : move.b d7,(a0)+
002132 : 066e 0006 00e8           : addi.w #$6,+$e8(a6)
002138 : 3d7c 0002 008e           : move.w #$2,+$8e(a6)
00213e : 6000 ff32                : bra .l -$ce
002142 : 6100 00c2                : bsr .l +$c2
002146 : 6700 00d8                : beq .l +$d8
00214a : 0fee 007a                : bset d7,+$7a(a6)
00214e : 30fc 0018                : move.w #$18,(a0)+
002152 : 7005                     : moveq #5,d0
002154 : d06e 0086                : add.w ship.x(a6),d0
002158 : 30c0                     : move.w d0,(a0)+
00215a : 7001                     : moveq #1,d0
00215c : d06e 0088                : add.w ship.y(a6),d0
002160 : 30c0                     : move.w d0,(a0)+
002162 : 20fc 0012 0000           : move.l #$120000,(a0)+
002168 : 10fc 0000                : move.b #$0,(a0)+
00216c : 10c7                     : move.b d7,(a0)+
00216e : 066e 0006 00ec           : addi.w #$6,+$ec(a6)
002174 : 3d7c 0000 008e           : move.w #$0,+$8e(a6)
00217a : 6000 ff1c                : bra .l -$e4
00217e : 6100 0086                : bsr .l +$86
002182 : 6700 009c                : beq .l +$9c
002186 : 0fee 007d                : bset d7,+$7d(a6)
00218a : 7403                     : moveq #3,d2
00218c : 76ff                     : moveq #-1,d3
00218e : 78fc                     : moveq #-4,d4
002190 : 611a                     : bsr.s +26
002192 : 6000 ff26                : bra .l -$da
002196 : 6100 006e                : bsr .l +$6e
00219a : 6700 0084                : beq .l +$84
00219e : 0fee 007e                : bset d7,+$7e(a6)
0021a2 : 7404                     : moveq #4,d2
0021a4 : 7600                     : moveq #0,d3
0021a6 : 781a                     : moveq #26,d4
0021a8 : 6002                     : bra.s +2
0021aa : 4e75                     : rts 

0021ac : 30fc 000c                : move.w #$c,(a0)+
0021b0 : 302e 0086                : move.w ship.x(a6),d0
0021b4 : 5c40                     : addq.w #6,d0
0021b6 : 30c0                     : move.w d0,(a0)+
0021b8 : 302e 0088                : move.w ship.y(a6),d0
0021bc : d044                     : add.w d4,d0
0021be : 4a40                     : tst.w d0
0021c0 : 6a02                     : bpl.s +2
0021c2 : 7000                     : moveq #0,d0
0021c4 : 30c0                     : move.w d0,(a0)+
0021c6 : 302e 008c                : move.w +$8c(a6),d0
0021ca : e248                     : lsr.w #1,d0
0021cc : 6606                     : bne.s +6
0021ce : 70f8                     : moveq #-8,d0
0021d0 : 7800                     : moveq #0,d4
0021d2 : 6022                     : bra.s +34
0021d4 : 5340                     : subq.w #1,d0
0021d6 : 6606                     : bne.s +6
0021d8 : 70fc                     : moveq #-4,d0
0021da : 7804                     : moveq #4,d4
0021dc : 6018                     : bra.s +24
0021de : 5340                     : subq.w #1,d0
0021e0 : 6606                     : bne.s +6
0021e2 : 7000                     : moveq #0,d0
0021e4 : 7808                     : moveq #8,d4
0021e6 : 600e                     : bra.s +14
0021e8 : 5340                     : subq.w #1,d0
0021ea : 6606                     : bne.s +6
0021ec : 7004                     : moveq #4,d0
0021ee : 7804                     : moveq #4,d4
0021f0 : 6004                     : bra.s +4
0021f2 : 7008                     : moveq #8,d0
0021f4 : 7800                     : moveq #0,d4
0021f6 : 4a43                     : tst.w d3
0021f8 : 6702                     : beq.s +2
0021fa : 4444                     : neg.w d4
0021fc : 30c0                     : move.w d0,(a0)+
0021fe : 30c4                     : move.w d4,(a0)+
002200 : 10c2                     : move.b d2,(a0)+
002202 : 10c7                     : move.b d7,(a0)+
002204 : 4e75                     : rts 
// Returns Z flag set if not found
alloc.projectile
002206
			lea			projectiles(a6),a0
			moveq		#MAX_PROJECTILES-1,d0
@lp			tst.w		(a0)
			beq.s		@found
			adda.w		#proj.size,a0
			dbra		d0,@lp
			suba.l		a0,a0
			cmpa.l		#$0,a0
			// Force Z flag set
			rts 
@found
			// Check Z clear
			cmpa.l		#$0,a0
			rts 
@done
00222a : 422e 0062                : clr.b 98(a6)
00222e : 4e75                     : rts 
//---------------------------------------------------------
SwapFrameBuffers
			move.w		FrameBufferIndex(a6),d0
			move.l		a5,8(a6,d0.W)				// Set index to restore buffer for this frame
			move.l		40(a6,d0.W),86(a6)
			addq.w		#4,d0
			cmp.w		FrameBufferCount(a6),d0
			bcs.s		@noreset
			moveq		#0,d0
@notreset	move.w		d0,FrameBufferIndex(a6)
			move.l		40(a6,d0.W),screen.base(a6)
			movea.l		8(a6,d0.W),a5
			move.w		FrameRateLock(a6),d0
@waitframes		
			cmp.w		VBlankCounter(a6),d0
			bhi.s		@waitframes
			moveq		#SYS_SET_VIDEOBASE,d0
			trap		#4
			clr.w		VBlankCounter(a6)
			rts 
//---------------------------------------------------------
; ------
; This is used for programming the keyboard & mouse inputs
; ------
Trap0Handler
			tst.w		d0										// If top bit not set, don't wait for ready signal
			bpl.s		@write
@wait		btst		#$1,HW_ACIA_CONTROL						// Is keyboard ACIA busy?
			beq.s		@wait									// Yes, wait
			move.b		d0,HW_ACIA_DATA							// Write character to ACIA
			rte 
//---------------------------------------------------------
Trap4Handler
			tst.w		d0										// Trap #4 dispatch. Should have used
			beq.s		SetVideoAddress							// a jump table instead. It would
			cmp.w		#SYS_SET_PALETTE,d0						// have been more efficient
			beq.s		SetPaletteRegisters
			cmp.w		#SYS_SET_AUDIO,d0
			beq			SetAudioRegisters
			cmp.w		#SYS_SET_PALETTE_ENTRY,d0
			beq 		SetPaletteEntry							// Entry # in D1, value in D2
			cmp.w		#SYS_PRINT_CHAR,d0
			beq 		PrintCharacter
			cmp.w		#SYS_PRINT,d0
			beq			PrintString
			cmp.w		#SYS_DELAY_FRAMES,d0
			beq			FrameDelay
			rte 
//---------------------------------------------------------
// This routine is waiting until we reach almost the end of the display before we set the next
// address for the video hardware. This is because it's a dual buffered fifo type arrangement and the
// actual screen address would be set on the next vertical blank interrupt occurance instead of 
// immediately (which we always wanted)
SetVideoAddress
			movem.l		d0-1/a5-6,-(a7)
			movea.l		#HW_VIDEO_BASE,a5						// Base of video registers
			lea			GlobalVariables,a6
			moveq		#124,d0
@waitlp		move.b		7(a5),d1								// Current video addr mid byte
			andi.b		#$7f,d1
			cmp.b		d0,d1									// Wait until at end of the display
			bcs.s		@waitlp
			move.l		86(a6),d0								// Get ptr to display buffer
			clr.l		86(a6)									// Clear it for some reason
			lsr.l		#8,d0
			movep.w		d0,$1(a5)								// Set Video RAM address
			movem.l		(a7)+,d0-1/a5-6
			rte
			 
//---------------------------------------------------------
SetAudioRegisters
			movem.l		d0/a0-1,-(a7)
			movea.l		#$ffff8800,a0
			moveq		#0,d0
@lp			move.b		d0,(a0)
			move.b		(a1)+,2(a0)
			addq.w		#1,d0
			cmp.b		#$e,d0
			bne.s		@lp
			movem.l		(a7)+,d0/a0-1
			rte 

//---------------------------------------------------------
SetPaletteRegisters
			movem.l		d1-5/d7/a0-1,-(a7)
			bsr			SetPalette
			moveq		#7,d0
			moveq		#2,d1
			trap		#4
			movem.l		(a7)+,d1-5/d7/a0-1
			rte 
//---------------------------------------------------------
SetPalette
			clr.l		d7
			movea.l		#HW_VIDEO_PALETTE,a1
			moveq		#15,d5
@loop		move.w		(a1),d1									// Get hardware colour value
			move.w		(a0)+,d2								// Get our destination colour
			andi.w		#$777,d1								// Mask out STe extra bits
			cmp.w		d2,d1									// Is it the same?
			beq.s		@same
			moveq		#8,d0									// Fade the red portion
			clr.l		d1
			bsr.s		@fade
			move.w		d3,d1
			moveq		#4,d0									// Fade the green portion
			bsr.s		@fade
			or.w		d3,d1
			moveq		#0,d0									// Fade the blue portion
			bsr.s		@fade
			or.w		d3,d1
@same
			move.w		d1,(a1)+								// Store new palette entry
			dbra		d5,@loop
			move.l		d7,d0
			rts 
@fade
			move.w		(a1),d3									// Get a copy of the hw colour
			move.w		d2,d4									// Make a copy of the dest colour
			lsr.w		d0,d3									// Shift the desired colour nibble
			lsr.w		d0,d4									// in to the lowest nibble
			andi.w		#$7,d3
			andi.w		#$7,d4									// Mask out garbage
			cmp.w		d4,d3
			beq.s		@fadedone
			bhi.s		@fadedown
			st			d7										// Mark fade not complete
			addq.w		#1,d3									// make element closer to dest colour
@fadedone	andi.w		#$7,d3
			lsl.w		d0,d3
			rts 

@fadedown	subq.w		#1,d3
			st			d7
			bra.s		@fadedone

//---------------------------------------------------------
// D1 - Colour index
// D2 - Colour value
SetPaletteEntry
			movem.l			d1/a0,-(a7)
			movea.l			#HW_VIDEO_PALETTE,a0
			lsl.w			#1,d1
			move.w			d2,0(a0,d1.W)
			movem.l			(a7)+,d1/a0
			rte 
//---------------------------------------------------------
PrintCharacter
//	D1 - character code
//	D2 - X position in pixels
//	D3 - Y position in 8 line chunks
// X position will be updated
			movem.l			d0-1/d3-5/a0-3,-(a7)
			mulu			#8*BYTES_PER_LINE,d3				// Y position to screen offset
			movea.l			screen.base(a6),a0
			adda.w			d3,a0
			move.w			d2,d3
			move.w			d2,d0
			andi.w			#$f,d0								// D0 - bit offset within screen word
			lsr.w			#1,d3
			andi.w			#$f8,d3
			adda.w			d3,a0
			subi.w			#$21,d1								// Anything ' ' or less, draw a space
			bcs.s			@drawspace
			movea.l			#$50100,a1							// Base of graphics chunk
			adda.w			8(a1),a1							// Add offset to character set
			clr.l			d4
			move.b			0(a1,d1.W),d4						// Get width of character
			add.w			d4,d2								// Update x position with it
			mulu			#$60,d1
			lea				62(a1,d1.W),a1
			lea				32(a1),a2							// Ptr to bitplane 1
			lea				64(a1),a3							// Ptr to bitplane 2
			moveq			#-1,d4								// Generate mask value
			lsr.l			d0,d4
			not.l			d4
			moveq			#16-1,d1							// height of character
@charlp		move.w			(a1)+,d3
			bsr.s			@drawbitplane
			move.w			(a2)+,d3
			bsr.s			@drawbitplane
			move.w			(a3)+,d3
			bsr.s			@drawbitplane
			adda.w			#BYTES_PER_LINE-6,a0
			dbra			@charlp
@done		movem.l			(a7)+,d0-1/d3-5/a0-3
			rte 

@drawspace
			addi.w			#$8,d2								// Advance X position 8 pixels
			moveq			#-1,d4								// Build mask for space
			lsr.l			d0,d4
			not.l			d4
			moveq			#16-1,d1
@spacelp	moveq			#0,d3
			bsr.s			@drawbitplane
			bsr.s			@drawbitplane
			bsr.s			@drawbitplane
			adda.w			#BYTES_PER_LINE-6,a0
			dbra			d1,@spacelp
			bra.s			@done
@drawbitplane
			swap			d3									// Make sure lower word is clear
			clr.w			d3
			lsr.l			d0,d3								// Shift line to correct position
			and.w			d4,8(a0)							// Mask and store in lowest 16 bits
			or.w			d3,8(a0)
			swap			d4
			swap			d3
			and.w			d4,(a0)								// Mask and store upper 16 bits
			or.w			d3,(a0)+
			swap			d4
			rts 
//---------------------------------------------------------
PrintString
// A0 points to character string. First byte is column, 2nd byte is row
// line terminated with 0, string terminated with -1
			clr.l		d2
			clr.l		d3
			clr.l		d1
@line		move.b		(a0)+,d2							// Read X cell #
			move.b		(a0)+,d3							// Read Y cell #
			lsl.w		#1,d2
@loop		move.b		(a0)+,d1
			bmi.s		@done
			beq.s		@line
			moveq		#SYS_PRINT_CHAR,d0
			trap		#4
			bra.s		@loop
@done		rte 
//---------------------------------------------------------
FrameDelay
			movem.l		d1/a6,-(a7)
			lea			GlobalVariables,a6
			clr.w		VBlankCounter(a6)
@waitlp		cmp.w		VBlankCounter(a6),d1
			bne.s		@waitlp
			movem.l		(a7)+,d1/a6
			rte 
//---------------------------------------------------------
VBLHandler
			movem.l		d0-7/a0-6,-(a7)
			lea			GlobalVariables,a6
			jsr			$57d0e
			tst.b		$585bf
			bne.s		+4
			clr.b		+$78(a6)
			clr.w		HBlankCounter(a6)
			addi.w		#$1,VBlankCounter(a6)
			move.b		VideoMode(a6),d0
			bpl.s		@nonewmode
			andi.b		#$7f,d0
			move.b		d0,ShifterMode
			clr.b		VideoMode(a6)
@nonewmode	tst.b		+$90(a6)
			movem.l		(a7)+,d0-7/a0-6
			rte 
//---------------------------------------------------------
HBlankInterruptHandler
			movem.l		d0/a0/a6,-(a7)
			lea			GlobalVariables,a6
			move.w		HBlankCounter(a6),d0
			subq.w		#3,d0
			bcc.s		@nowrap
			moveq		#0,d0
@nowrap		andi.w		#$e0,d0
			addq.w		#1,HBlankCounter(a6)
			lea			GFX_LEVEL_PALETTE,a6
			adda.w		d0,a6
			movea.w		#HW_VIDEO_PALETTE+2*8,a0
			move.l		(a6)+,(a0)+
			move.l		(a6)+,(a0)+
			move.l		(a6)+,(a0)+
			move.l		(a6)+,(a0)+
			move.w		#$7,HW_VIDEO_PALETTE+2*8
			bclr		#$0,$fffffa0f
			movem.l		(a7)+,d0/a0/a6
			rte 
KeyboardHandler
0024ea : 48e7 c082                : movem.l d0-1/a0/a6,-(a7)
0024ee : 4240                     : clr.w d0
0024f0 : 4df9 0000 55da           : lea GlobalVariables,a6
0024f6 : 207c ffff fc00           : movea.l #HW_ACIA_BASE,a0
0024fc : 1010                     : move.b (a0),d0
0024fe : 0800 0007                : btst #$7,d0
002502 : 6700 0046                : beq .l +$46
002506 : 0800 0000                : btst #$0,d0
00250a : 673e                     : beq.s +62
00250c : 1028 0002                : move.b 2(a0),d0
002510 : 4a2e 0066                : tst.b +$66(a6)
002514 : 6652                     : bne.s +82
002516 : 4a2e 0067                : tst.b +$67(a6)
00251a : 665a                     : bne.s +90
00251c : 4a2e 0068                : tst.b +$68(a6)
002520 : 6706                     : beq.s +6
002522 : 422e 0068                : clr.b +$68(a6)
002526 : 6022                     : bra.s +34
002528 : b07c 00fe                : cmp.w #$fe,d0
00252c : 57ee 0068                : seq +$68(a6)
002530 : b07c 00ff                : cmp.w #$ff,d0
002534 : 57ee 0066                : seq +$66(a6)
002538 : 6710                     : beq.s +16
00253a : 3200                     : move.w d0,d1
00253c : 0241 00fc                : andi.w #$fc,d1
002540 : b27c 00f8                : cmp.w #$f8,d1
002544 : 6712                     : beq.s +18
002546 : 1d40 0064                : move.b d0,keycode(a6)
00254a : 08b9 0006 ffff fa11      : bclr #$6,$fffffa11
002552 : 4cdf 4103                : movem.l (a7)+,d0-1/a0/a6
002556 : 4e73                     : rte 

002558 : 1d7c 0002 0067           : move.b #$2,+$67(a6)
00255e : 0200 0003                : andi.b #$3,d0
002562 : 1d40 0069                : move.b d0,mouse.btn(a6)
002566 : 60e2                     : bra.s -30

002568 : 51ee 0066                : sf  +$66(a6)
00256c : 1d40 0063                : move.b d0,joy.btn(a6)
002570 : 51ee 0065                : sf  +$65(a6)
002574 : 60d4                     : bra.s -44

002576 : 7200                     : moveq #0,d1
002578 : 122e 0067                : move.b +$67(a6),d1
00257c : 5301                     : subq.b #1,d1
00257e : 1d80 106a                : move.b d0,106(a6,d1.W)
002582 : 1d41 0067                : move.b d1,+$67(a6)
002586 : 4a01                     : tst.b d1
002588 : 66c0                     : bne.s -64
00258a : 4200                     : clr.b d0
00258c : 4a2e 0069                : tst.b mouse.btn(a6)
002590 : 6704                     : beq.s +4
002592 : 08c0 0007                : bset #$7,d0
002596 : 4a2e 006a                : tst.b mouse.x(a6)
00259a : 670c                     : beq.s +12
00259c : 6a06                     : bpl.s +6
00259e : 08c0 0000                : bset #$0,d0
0025a2 : 6004                     : bra.s +4
0025a4 : 08c0 0001                : bset #$1,d0
0025a8 : 4a2e 006b                : tst.b mouse.y(a6)
0025ac : 670c                     : beq.s +12
0025ae : 6a06                     : bpl.s +6
0025b0 : 08c0 0002                : bset #$2,d0
0025b4 : 6004                     : bra.s +4
0025b6 : 08c0 0003                : bset #$3,d0
0025ba : 1d40 0063                : move.b d0,joy.btn(a6)
0025be : 50ee 0065                : st  +$65(a6)
0025c2 : 6000 ff86                : bra .l -$7a
update.position
0025c6 : 102e 0063                : move.b joy.btn(a6),d0
0025ca : 342e 008a                : move.w ship.speed(a6),d2
0025ce : 322e 0088                : move.w ship.y(a6),d1
0025d2 : 4a2e 0112                : tst.b +$112(a6)
0025d6 : 6606                     : bne.s +6
0025d8 : 4a6e 0080                : tst.w demo.timer(a6)		// if in demo mode, just clear any input
0025dc : 6706                     : beq.s @noinput
0025de : 422e 0063                : clr.b joy.btn(a6)
0025e2 : 4200                     : clr.b d0
@noinput
0025e4 : e248                     : lsr.w #1,d0
0025e6 : 6406                     : bcc.s +6
0025e8 : 9242                     : sub.w d2,d1
0025ea : 6402                     : bcc.s +2
0025ec : 7201                     : moveq #1,d1
0025ee : e248                     : lsr.w #1,d0
0025f0 : 640a                     : bcc.s +10
0025f2 : d242                     : add.w d2,d1
0025f4 : b23c 00a6                : cmp.b #$a6,d1
0025f8 : 6302                     : bls.s +2
0025fa : 9242                     : sub.w d2,d1
0025fc : 3d41 0088                : move.w d1,ship.y(a6)
002600 : 322e 0086                : move.w ship.x(a6),d1
002604 : e248                     : lsr.w #1,d0
002606 : 641c                     : bcc.s +28
002608 : 9242                     : sub.w d2,d1
00260a : b27c 0020                : cmp.w #$20,d1
00260e : 6402                     : bcc.s +2
002610 : 7220                     : moveq #32,d1
002612 : 526e 008c                : addq.w #1,+$8c(a6)
002616 : 0c6e 0009 008c           : cmpi.w #$9,+$8c(a6)
00261c : 6306                     : bls.s +6
00261e : 3d7c 0009 008c           : move.w #$9,+$8c(a6)
002624 : e248                     : lsr.w #1,d0
002626 : 6414                     : bcc.s +20
002628 : b27c 00f0                : cmp.w #$f0,d1
00262c : 620e                     : bhi.s +14
00262e : d242                     : add.w d2,d1
002630 : 046e 0001 008c           : subi.w #$1,+$8c(a6)
002636 : 6a04                     : bpl.s +4
002638 : 426e 008c                : clr.w +$8c(a6)
00263c : 3d41 0086                : move.w d1,ship.x(a6)
002640 : 4a2e 0065                : tst.b +$65(a6)
002644 : 6706                     : beq.s +6
002646 : 022e 0080 0063           : andi.b #$80,joy.btn(a6)
00264c : 4e75                     : rts 
TitleMainLoop
			bsr 		init.screen
			lea			MSG_Copyright,a0
			moveq		#SYS_PRINT,d0
			trap		#4
			lea			MSG_50Hz,a0			// "50HZ"
			btst		#$1,HW_VIDEO_SYNC
			beq.s		@is50hz
			lea			MSG_60Hz,a0			// "60HZ"
@is50hz		moveq		#SYS_PRINT,d0
			trap		#4
			move.w		#$ff08,d0			// Disable mouse?
			trap		#0
			move.w		#$ff1a,d0
			trap		#0
			lea			MSG_Joystick,a0
			tst.b		MouseEnabled(a6)
			bne.s		@printmsg
			move.w		#$ff12,d0			// Enable mouse?
			trap		#0
			move.w		#$ff14,d0
			trap		#0
			lea			MSG_Mouse,a0
@printmsg
			moveq		#SYS_PRINT,d0
			trap		#4
0026a4 : 41f9 0000 40fc           : lea $40fc,a0
0026aa : 6100 e1b2                : bsr .l -$1e4e
			move.w		#500,d7
@waitloop
			moveq		#SYS_DELAY_FRAMES,d0
			moveq		#1,d1
			trap		#4
			cmpi.b		#$3b,keycode(a6)					// "F1" Start a "normal" game
			beq .l		@normalgame
			cmpi.b		#$3c,keycode(a6)					// "F2" Start a "difficult" game
			beq .l		@difficultgame
			cmpi.b		#$3d,keycode(a6)					// "F3" Toggle 50/60hz
			bne.s		@notrefresh
@fliprefresh
			bchg		#$1,HW_VIDEO_SYNC
			bra 		TitleMainLoop
@notrefresh
			cmpi.b		#$3e,keycode(a6)					// "F4" Toggle Joystick/Mouse
			bne.s		@notjoymouse
			not.b		MouseEnabled(a6)
			bra			TitleMainLoop
@notjoymouse
			dbra		d7,@waitloop
@enterdemo
			bsr .l +$a0
			bsr .l +$108
			bne .l -$b0
			bsr .l +$ca
			bsr .l		reset.globals
			move.w		#70,demo.timer(a6)
			clr.w		level.number(a6)
			bra			enter.game
002716 : 51ee 0090                : sf  +$90(a6)
00271a : 4e75                     : rts 
@normalgame
			bsr 		clear.palettes
			move.w		#$750,BonusScoreInc(a6)
			move.w		#$150,KillScoreInc(a6)
			move.w		#$0,LandscapeDamage(a6)
			sf			+$90(a6)
			rts 
@difficultgame
			bsr .l		clear.palettes
			move.w		#$1500,BonusScoreInc(a6)
			move.w		#$300,KillScoreInc(a6)
			move.w		#$1,LandscapeDamage(a6)
			sf			+$90(a6)
			rts 

002754 : 41f9 0000 40fc           : lea $40fc,a0
00275a : 6100 e102                : bsr .l -$1efe
00275e : 3e3c 00fa                : move.w #$fa,d7
002762 : 422e 0064                : clr.b keycode(a6)
002766 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002768 : 7201                     : moveq #1,d1
00276a : 4e44                     : trap #4
00276c : 082e 0007 0063           : btst #$7,joy.btn(a6)
002772 : 6612                     : bne.s +18
002774 : 4a2e 0064                : tst.b keycode(a6)
002778 : 6614                     : bne.s +20
00277a : 51cf ffea                : dbra d7,-22
00277e : 6100 e0c6                : bsr .l -$1f3a
002782 : 7e00                     : moveq #0,d7
002784 : 4e75                     : rts 

002786 : 082e 0007 0063           : btst #$7,joy.btn(a6)
00278c : 66f8                     : bne.s -8
00278e : 6100 e0b6                : bsr .l -$1f4a
002792 : 7e01                     : moveq #1,d7
002794 : 4e75                     : rts 
init.screen
002796 : 50ee 0090                : st  +$90(a6)
			bsr			clear.palettes
init.screen2
00279e
			bsr			disable.hblank
			move.l		#$10000,screen.base(a6)
			move.l		screen.base(a6),86(a6)
			move.l		#$18000,other.screen(a6)
			moveq		#SYS_SET_VIDEOBASE,d0
			trap		#4
			movea.l		screen.base(a6),a0						// Clear the current buffer
			move.w		#$1f3f,d0
@loop		clr.l		(a0)+
			dbra		d0,@loop
			rts 

0027cc :	bsr.s		init.screen
			movea.l		#$50100,a1
			adda.w		2(a1),a1
			movea.l		screen.base(a6),a0
			adda.w		#$518,a0
			move.w		#$aa,d0
@drawlp		move.l		(a1)+,(a0)+
			move.l		(a1)+,(a0)+
			move.l		(a1)+,(a0)+
			move.l		(a1)+,(a0)+
			adda.w		#BYTES_PER_LINE-16,a0
			dbra		@drawlp,-14
			lea			MSG_GameOverTotals,a0
			moveq		#SYS_PRINT,d0
			trap		#4
0027fe : 6000 ff54                : bra .l -$ac
002802 : 619a                     : bsr.s -102
			lea			MSG_HighScores,a0
			moveq		#SYS_PRINT,d0
			trap		#4
00280e : 6000 ff44                : bra .l -$bc
002812 : 50ee 0112                : st  +$112(a6)
002816 : 3d7c 0012 0110           : move.w #$12,+$110(a6)
00281c : 3d7c 0000 0084           : move.w #$0,+$84(a6)
002822 : 7013                     : moveq #19,d0
002824 : 51ee 009c                : sf  mult1.on(a6)
002828 : 51ee 009d                : sf  mult2.on(a6)
00282c : 6100 0e9e                : bsr .l play.sound			// Explosion?
002830 : 4e75                     : rts 

002832 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002834 : 7264                     : moveq #100,d1
002836 : 4e44                     : trap #4
002838 : 51ee 0112                : sf  +$112(a6)
00283c : 302e 00f6                : move.w level.number(a6),d0
002840 : e548                     : lsl.w #2,d0
002842 : 41ee 00f8                : lea LevelScores(a6),a0
002846 : d0c0                     : adda.w d0,a0
002848 : 20ae 00d6                : move.l +$d6(a6),(a0)
00284c : 6100 ff48                : bsr .l -$b8
002850 : 41f9 0000 4feb           : lea MSG_Dead,a0
002856 : 7006                     : moveq #SYS_PRINT,d0
002858 : 4e44                     : trap #4
00285a : 41f9 0000 40fc           : lea $40fc,a0
002860 : 6100 dffc                : bsr .l -$2004
002864 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002866 : 724b                     : moveq #75,d1
002868 : 4e44                     : trap #4
00286a : 6100 ff2a                : bsr .l -$d6
00286e : 41f9 0000 532e           : lea $532e,a0
002874 : 7006                     : moveq #SYS_PRINT,d0
002876 : 4e44                     : trap #4
002878 : 41f9 0000 5403           : lea $5403,a0
00287e : 43ee 00f8                : lea LevelScores(a6),a1
002882 : 7e05                     : moveq #5,d7
002884 : 2019                     : move.l (a1)+,d0
002886 : 6100 011c                : bsr .l printhex.6digits
00288a : 51cf fff8                : dbra d7,-8
00288e : 202e 00d2                : move.l +$d2(a6),d0
002892 : 6100 0110                : bsr .l printhex.6digits
002896 : 102e 0113                : move.b speedup.bonuses(a6),d0
00289a : 6100 0102                : bsr .l printhex.2digits
00289e : 102e 0114                : move.b outrider.bonuses(a6),d0
0028a2 : 6100 00fa                : bsr .l printhex.2digits
0028a6 : 102e 0115                : move.b forcefield.bonuses(a6),d0
0028aa : 6100 00f2                : bsr .l printhex.2digits
0028ae : 102e 0116                : move.b laser.bonuses(a6),d0
0028b2 : 6100 00ea                : bsr .l printhex.2digits
0028b6 : 102e 0117                : move.b canon.bonuses(a6),d0
0028ba : 6100 00e2                : bsr .l printhex.2digits
0028be : 102e 0118                : move.b energy.bonuses(a6),d0
0028c2 : 6100 00da                : bsr .l printhex.2digits
0028c6 : 41f9 0000 40fc           : lea $40fc,a0
0028cc : 6100 df90                : bsr .l -$2070
0028d0 : 3e3c 012c                : move.w #$12c,d7
0028d4 : 6100 fe8c                : bsr .l -$174
0028d8 : 6100 febc                : bsr .l -$144
0028dc : 6100 0030                : bsr .l +$30
0028e0 : 48e7 4080                : movem.l d1/a0,-(a7)
0028e4 : 41f9 0000 54ae           : lea MSG_HighScores,a0
0028ea : 7006                     : moveq #SYS_PRINT,d0
0028ec : 4e44                     : trap #4
0028ee : 4cdf 0102                : movem.l (a7)+,d1/a0
0028f2 : 4a41                     : tst.w d1
0028f4 : 6a00 00da                : bpl .l +$da
0028f8 : 41f9 0000 40fc           : lea $40fc,a0
0028fe : 6100 df5e                : bsr .l -$20a2
002902 : 6100 fe5a                : bsr .l -$1a6
002906 : 51ee 0090                : sf  +$90(a6)
00290a : 6000 013a                : bra .l +$13a
00290e : 41f9 0000 55b6           : lea $55b6,a0
002914 : 202e 00d2                : move.l +$d2(a6),d0
002918 : 7207                     : moveq #7,d1
00291a : b098                     : cmp.l (a0)+,d0
00291c : 6e06                     : bgt.s +6
00291e : 51c9 fffa                : dbra d1,-6
002922 : 4e75                     : rts 

002924 : 2401                     : move.l d1,d2
002926 : 41f9 0000 55d6           : lea $55d6,a0
00292c : 2160 0004                : move.l -(a0),4(a0)
002930 : 51ca fffa                : dbra d2,-6
002934 : 2080                     : move.l d0,(a0)
002936 : 2401                     : move.l d1,d2
002938 : 41f9 0000 558e           : lea $558e,a0
00293e : 2168 ffe8 0004           : move.l -24(a0),4(a0)
002944 : 3168 ffec 0008           : move.w -20(a0),8(a0)
00294a : 1168 fff5 0011           : move.b -11(a0),17(a0)
002950 : 2168 fff6 0012           : move.l -10(a0),18(a0)
002956 : 2168 fffa 0016           : move.l -6(a0),22(a0)
00295c : 1168 fffe 001a           : move.b -2(a0),26(a0)
002962 : 90fc 001c                : suba.w #$1c,a0
002966 : 51ca ffd6                : dbra d2,-42
00296a : 5848                     : addq.w #4,a0
00296c : 2f01                     : move.l d1,-(a7)
00296e : 6100 0016                : bsr .l +$16
002972 : 221f                     : move.l (a7)+,d1
002974 : 5e48                     : addq.w #7,a0
002976 : 7409                     : moveq #9,d2
002978 : 10fc 0020                : move.b #$20,(a0)+
00297c : 51ca fffa                : dbra d2,-6
002980 : 90fc 000a                : suba.w #$a,a0
002984 : 4e75                     : rts 

002986 : 7405                     : moveq #5,d2
002988 : e188                     : lsl.l #8,d0
00298a : e998                     : rol.l #4,d0
00298c : 3600                     : move.w d0,d3
00298e : 0243 000f                : andi.w #$f,d3
002992 : 0643 0030                : addi.w #$30,d3
002996 : 10c3                     : move.b d3,(a0)+
002998 : 51ca fff0                : dbra d2,-16
00299c : 4e75                     : rts 
printhex.2digits
00299e : 7801                     : moveq #1,d4
0029a0 : 4840                     : swap d0
0029a2 : 6002                     : bra.s +2
printhex.6digits
0029a4 : 7805                     : moveq #5,d4
0029a6 : e188                     : lsl.l #8,d0
0029a8 : 4283                     : clr.l d3
0029aa : 4282                     : clr.l d2
0029ac : 1418                     : move.b (a0)+,d2
0029ae : e34a                     : lsl.w #1,d2
0029b0 : 1618                     : move.b (a0)+,d3
0029b2 : e998                     : rol.l #4,d0
0029b4 : 3200                     : move.w d0,d1
0029b6 : 0241 000f                : andi.w #$f,d1
0029ba : 0641 0030                : addi.w #$30,d1
0029be : 48e7 89c0                : movem.l d0/d4/d7/a0-1,-(a7)
0029c2 : 7005                     : moveq #SYS_PRINT_CHAR,d0
0029c4 : 4e44                     : trap #4
0029c6 : 4cdf 0391                : movem.l (a7)+,d0/d4/d7/a0-1
0029ca : 51cc ffe6                : dbra d4,-26
0029ce : 4e75                     : rts 

0029d0 : 2f01                     : move.l d1,-(a7)
0029d2 : 2648                     : movea.l a0,a3
0029d4 : 41f9 0000 541e           : lea $541e,a0
0029da : 7006                     : moveq #SYS_PRINT,d0
0029dc : 4e44                     : trap #4
0029de : 3a3c 0042                : move.w #$42,d5
0029e2 : 3c3c 0090                : move.w #$90,d6
0029e6 : 7e00                     : moveq #0,d7
0029e8 : 6100 01e0                : bsr .l +$1e0
0029ec : 41f9 0000 40fc           : lea $40fc,a0
0029f2 : 6100 de6a                : bsr .l -$2196
0029f6 : 49ee 25d8                : lea draw.list(a6),a4
0029fa : 7800                     : moveq #0,d4
0029fc : 7607                     : moveq #7,d3
0029fe : 969f                     : sub.l (a7)+,d3
002a00 : e34b                     : lsl.w #1,d3
002a02 : 343c 00a0                : move.w #$a0,d2
002a06 : 48e7 3000                : movem.l d2-3,-(a7)
002a0a : 6100 00d8                : bsr .l +$d8
002a0e : 4cdf 000c                : movem.l (a7)+,d2-3
002a12 : 1207                     : move.b d7,d1
002a14 : 0601 0041                : addi.b #$41,d1
002a18 : b23c 005c                : cmp.b #$5c,d1
002a1c : 6602                     : bne.s +2
002a1e : 7220                     : moveq #32,d1
002a20 : b23c 005d                : cmp.b #$5d,d1
002a24 : 6700 009e                : beq .l +$9e
002a28 : b23c 005e                : cmp.b #$5e,d1
002a2c : 6714                     : beq.s +20
002a2e : b83c 0009                : cmp.b #$9,d4
002a32 : 67d2                     : beq.s -46
002a34 : 16c1                     : move.b d1,(a3)+
002a36 : 38c2                     : move.w d2,(a4)+
002a38 : 38c3                     : move.w d3,(a4)+
002a3a : 5244                     : addq.w #1,d4
002a3c : 7005                     : moveq #SYS_PRINT_CHAR,d0
002a3e : 4e44                     : trap #4
002a40 : 60c4                     : bra.s -60
002a42 : 6100 0e08                : bsr .l +$e08
002a46 : 422e 0112                : clr.b +$112(a6)
002a4a : 6100 fd4a                : bsr .l -$2b6
002a4e : 41f9 0000 5106           : lea $5106,a0
002a54 : 7006                     : moveq #SYS_PRINT,d0
002a56 : 4e44                     : trap #4
002a58 : 41f9 0000 40fc           : lea $40fc,a0
002a5e : 4eb9 0000 085e           : jsr $85e
002a64 : 3d7c 0005 00f4           : move.w #$5,+$f4(a6)
002a6a : 343c 0096                : move.w #$96,d2
002a6e : 7608                     : moveq #8,d3
002a70 : 7220                     : moveq #32,d1
002a72 : 7005                     : moveq #SYS_PRINT_CHAR,d0
002a74 : 4e44                     : trap #4
002a76 : 7220                     : moveq #32,d1
002a78 : 7005                     : moveq #SYS_PRINT_CHAR,d0
002a7a : 4e44                     : trap #4
002a7c : 7230                     : moveq #48,d1
002a7e : d26e 00f4                : add.w +$f4(a6),d1
002a82 : 343c 0096                : move.w #$96,d2
002a86 : 7608                     : moveq #8,d3
002a88 : 7005                     : moveq #SYS_PRINT_CHAR,d0
002a8a : 4e44                     : trap #4
002a8c : 7e3c                     : moveq #60,d7
002a8e : 422e 0064                : clr.b keycode(a6)
002a92 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002a94 : 7201                     : moveq #1,d1
002a96 : 4e44                     : trap #4
002a98 : 082e 0007 0063           : btst #$7,joy.btn(a6)
002a9e : 6614                     : bne.s +20
002aa0 : 4a2e 0064                : tst.b keycode(a6)
002aa4 : 660e                     : bne.s +14
002aa6 : 51cf ffea                : dbra d7,-22
002aaa : 536e 00f4                : subq.w #1,+$f4(a6)
002aae : 6b00 dc00                : bmi .l MainMenu
002ab2 : 60b6                     : bra.s -74
002ab4 : 6100 fce0                : bsr .l init.screen
002ab8 : 6100 025a                : bsr .l draw.titles
002abc : 6100 ddac                : bsr .l reset.globals
002ac0 : 6000 dc44                : bra .l start.game
002ac4 : 4a04                     : tst.b d4
002ac6 : 6700 ff3e                : beq .l -$c2
002aca : 3624                     : move.w -(a4),d3
002acc : 3424                     : move.w -(a4),d2
002ace : 48e7 3000                : movem.l d2-3,-(a7)
002ad2 : 7220                     : moveq #32,d1
002ad4 : 7005                     : moveq #SYS_PRINT_CHAR,d0
002ad6 : 4e44                     : trap #4
002ad8 : 4cdf 000c                : movem.l (a7)+,d2-3
002adc : 1701                     : move.b d1,-(a3)
002ade : 5344                     : subq.w #1,d4
002ae0 : 6000 ff24                : bra .l -$dc
002ae4 : 4a2e 0065                : tst.b +$65(a6)
002ae8 : 6704                     : beq.s +4
002aea : 422e 0063                : clr.b joy.btn(a6)
002aee : 4a2e 0063                : tst.b joy.btn(a6)
002af2 : 67fa                     : beq.s -6
002af4 : 082e 0000 0063           : btst #$0,joy.btn(a6)
002afa : 6720                     : beq.s +32
002afc : be7c 000a                : cmp.w #$a,d7
002b00 : 651a                     : bcs.s +26
002b02 : 0447 000a                : subi.w #$a,d7
002b06 : 7407                     : moveq #7,d2
002b08 : 6100 00c0                : bsr .l +$c0
002b0c : 5546                     : subq.w #2,d6
002b0e : 6100 00ba                : bsr .l +$ba
002b12 : 7201                     : moveq #1,d1
002b14 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002b16 : 4e44                     : trap #4
002b18 : 51ca ffee                : dbra d2,-18
002b1c : 082e 0001 0063           : btst #$1,joy.btn(a6)
002b22 : 6720                     : beq.s +32
002b24 : be7c 0014                : cmp.w #$14,d7
002b28 : 641a                     : bcc.s +26
002b2a : 0647 000a                : addi.w #$a,d7
002b2e : 7407                     : moveq #7,d2
002b30 : 6100 0098                : bsr .l +$98
002b34 : 5446                     : addq.w #2,d6
002b36 : 6100 0092                : bsr .l +$92
002b3a : 7201                     : moveq #1,d1
002b3c : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002b3e : 4e44                     : trap #4
002b40 : 51ca ffee                : dbra d2,-18
002b44 : 082e 0002 0063           : btst #$2,joy.btn(a6)
002b4a : 672a                     : beq.s +42
002b4c : 4a47                     : tst.w d7
002b4e : 6726                     : beq.s +38
002b50 : be7c 000a                : cmp.w #$a,d7
002b54 : 6720                     : beq.s +32
002b56 : be7c 0014                : cmp.w #$14,d7
002b5a : 671a                     : beq.s +26
002b5c : 0447 0001                : subi.w #$1,d7
002b60 : 7407                     : moveq #7,d2
002b62 : 6100 0066                : bsr .l +$66
002b66 : 5545                     : subq.w #2,d5
002b68 : 6100 0060                : bsr .l +$60
002b6c : 7201                     : moveq #1,d1
002b6e : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002b70 : 4e44                     : trap #4
002b72 : 51ca ffee                : dbra d2,-18
002b76 : 082e 0003 0063           : btst #$3,joy.btn(a6)
002b7c : 672c                     : beq.s +44
002b7e : be7c 0009                : cmp.w #$9,d7
002b82 : 6726                     : beq.s +38
002b84 : be7c 0013                : cmp.w #$13,d7
002b88 : 6720                     : beq.s +32
002b8a : be7c 001d                : cmp.w #$1d,d7
002b8e : 671a                     : beq.s +26
002b90 : 0647 0001                : addi.w #$1,d7
002b94 : 7407                     : moveq #7,d2
002b96 : 6100 0032                : bsr .l +$32
002b9a : 5445                     : addq.w #2,d5
002b9c : 6100 002c                : bsr .l +$2c
002ba0 : 7201                     : moveq #1,d1
002ba2 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002ba4 : 4e44                     : trap #4
002ba6 : 51ca ffee                : dbra d2,-18
002baa : 082e 0007 0063           : btst #$7,joy.btn(a6)
002bb0 : 6700 ff32                : beq .l -$ce
002bb4 : 7003                     : moveq #3,d0
002bb6 : 6100 0b14                : bsr .l +$b14
002bba : 7203                     : moveq #3,d1
002bbc : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002bbe : 4e44                     : trap #4
002bc0 : 082e 0007 0063           : btst #$7,joy.btn(a6)
002bc6 : 66f2                     : bne.s -14
002bc8 : 4e75                     : rts 

002bca : 48e7 3ec0                : movem.l d2-6/a0-1,-(a7)
002bce : 206e 0000                : movea.l screen.base(a6),a0
002bd2 : ccfc 00a0                : mulu #$a0,d6
002bd6 : d0c6                     : adda.w d6,a0
002bd8 : 2c05                     : move.l d5,d6
002bda : 0245 000f                : andi.w #$f,d5
002bde : e24e                     : lsr.w #1,d6
002be0 : 0246 00f8                : andi.w #$f8,d6
002be4 : d0c6                     : adda.w d6,a0
002be6 : 90fc 0010                : suba.w #$10,a0
002bea : d0fc 0010                : adda.w #$10,a0
002bee : 43f9 0000 4c90           : lea $4c90,a1
002bf4 : 760f                     : moveq #15,d3
002bf6 : 6110                     : bsr.s +16
002bf8 : 610e                     : bsr.s +14
002bfa : d0fc 009c                : adda.w #$9c,a0
002bfe : 51cb fff6                : dbra d3,-10
002c02 : 4cdf 037c                : movem.l (a7)+,d2-6/a0-1
002c06 : 4e75                     : rts 

002c08 : 4282                     : clr.l d2
002c0a : 3419                     : move.w (a1)+,d2
002c0c : 4842                     : swap d2
002c0e : eaaa                     : lsr.l d5,d2
002c10 : 3c10                     : move.w (a0),d6
002c12 : 4846                     : swap d6
002c14 : 3c28 0008                : move.w 8(a0),d6
002c18 : b586                     : eor.l d2,d6
002c1a : 3146 0008                : move.w d6,8(a0)
002c1e : 4846                     : swap d6
002c20 : 30c6                     : move.w d6,(a0)+
002c22 : 4e75                     : rts 

002c24 : 6100 fb70                : bsr .l -$490
002c28 : 6100 00ea                : bsr .l +$ea
002c2c : 302e 00f6                : move.w level.number(a6),d0
002c30 : 41ee 00f8                : lea LevelScores(a6),a0
002c34 : e548                     : lsl.w #2,d0
002c36 : 21ae 00d6 0000           : move.l +$d6(a6),0(a0,d0.W)
002c3c : 206e 0000                : movea.l screen.base(a6),a0
002c40 : 302e 00f6                : move.w level.number(a6),d0
002c44 : c0fc 1400                : mulu #$1400,d0
002c48 : d0c0                     : adda.w d0,a0
002c4a : d0fc 03d0                : adda.w #$3d0,a0
002c4e : 6100 009c                : bsr .l +$9c
002c52 : 7e0f                     : moveq #15,d7
002c54 : 246e 0000                : movea.l screen.base(a6),a2
002c58 : 322e 00f6                : move.w level.number(a6),d1
002c5c : c2fc 1400                : mulu #$1400,d1
002c60 : d4c1                     : adda.w d1,a2
002c62 : d4fc 0a00                : adda.w #$a00,a2
002c66 : 6100 0062                : bsr .l +$62
002c6a : d4fc 0140                : adda.w #$140,a2
002c6e : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002c70 : 7201                     : moveq #1,d1
002c72 : 4e44                     : trap #4
002c74 : 51cf fff0                : dbra d7,-16
002c78 : 526e 00f6                : addq.w #1,level.number(a6)
002c7c : 51ee 00c3                : sf  +$c3(a6)
002c80 : 51ee 0090                : sf  +$90(a6)
002c84 : 0c6e 0005 00f6           : cmpi.w #$5,level.number(a6)
002c8a : 6300 da7a                : bls .l -$2586
002c8e : 3d7c 1500 00e4           : move.w #$1500,BonusScoreInc(a6)
002c94 : 3d7c 0300 00e2           : move.w #$300,KillScoreInc(a6)
002c9a : 3d7c 0001 00dc           : move.w #$1,landcoll.damage(a6)
002ca0 : 3d7c 0001 00de           : move.w #$1,LandscapeDamage(a6)
002ca6 : 426e 00f6                : clr.w level.number(a6)
002caa : 6100 0476                : bsr .l +$476
002cae : 41f9 0000 521f           : lea $521f,a0
002cb4 : 7006                     : moveq #SYS_PRINT,d0
002cb6 : 4e44                     : trap #4
002cb8 : 41f9 0000 40fc           : lea $40fc,a0
002cbe : 6100 db9e                : bsr .l -$2462
002cc2 : 50ee 00c3                : st  +$c3(a6)
002cc6 : 6000 da3e                : bra .l -$25c2
002cca : 227c 0005 0100           : movea.l #$50100,a1
002cd0 : d2e9 0000                : adda.w 0(a1),a1
002cd4 : 7c0f                     : moveq #15,d6
002cd6 : 2f0a                     : move.l a2,-(a7)
002cd8 : 24d9                     : move.l (a1)+,(a2)+
002cda : 24d9                     : move.l (a1)+,(a2)+
002cdc : 24d9                     : move.l (a1)+,(a2)+
002cde : 24d9                     : move.l (a1)+,(a2)+
002ce0 : d4fc 0090                : adda.w #$90,a2
002ce4 : 51ce fff2                : dbra d6,-14
002ce8 : 245f                     : movea.l (a7)+,a2
002cea : 4e75                     : rts 

// Masking a sprite or something
002cec : 227c 0005 0100           : movea.l #$50100,a1
002cf2 : d2e9 0004                : adda.w 4(a1),a1
002cf6 : 7220                     : moveq #32,d1
002cf8 : 7403                     : moveq #3,d2
002cfa : 3019                     : move.w (a1)+,d0
002cfc : 4640                     : not.w d0
002cfe : c158                     : and.w d0,(a0)+
002d00 : c158                     : and.w d0,(a0)+
002d02 : c158                     : and.w d0,(a0)+
002d04 : c158                     : and.w d0,(a0)+
002d06 : 51ca fff2                : dbra d2,-14
002d0a : d0fc 0080                : adda.w #$80,a0
002d0e : 51c9 ffe8                : dbra d1,-24
002d12 : 4e75                     : rts 
draw.titles
002d14 : 426e 006e                : clr.w +$6e(a6)
002d18 : 33fc 000a 0005 85c4      : move.w #$a,$585c4
002d20 : 4a6e 0080                : tst.w demo.timer(a6)
002d24 : 6606                     : bne.s +6
002d26 : 7002                     : moveq #2,d0
002d28 : 6100 0986                : bsr .l play.music				// start title music
002d2c : 41f9 0000 24a4           : lea HBlankInterruptHandler,a0
002d32 : 23c8 0000 0120           : move.l a0,$120
002d38 : 207c ffff 8201           : movea.l #$ffff8201,a0
002d3e : 4a28 0008                : tst.b 8(a0)
002d42 : 66fa                     : bne.s -6
002d44 : 0108 0004                : movep.w $4(a0),d0
002d48 : 0308 0000                : movep.w $0(a0),d1
002d4c : b240                     : cmp.w d0,d1
002d4e : 66ee                     : bne.s -18
002d50 : 13fc 0008 ffff fa1b      : move.b #$8,$fffffa1b		// Setting up the HBlank interrupt?
002d58 : 13fc 0001 ffff fa21      : move.b #$1,$fffffa21
002d60 : 08f9 0000 ffff fa07      : bset #$0,$fffffa07
002d68 : 08f9 0000 ffff fa13      : bset #$0,$fffffa13
002d70 : 41f9 0000 512b           : lea $512b,a0
002d76 : 7006                     : moveq #SYS_PRINT,d0
002d78 : 4e44                     : trap #4
002d7a : 206e 0004                : movea.l other.screen(a6),a0	// Looks like we're drawing the score bar strip from it's
002d7e : 2248                     : movea.l a0,a1				// buffer to the current display buffer (I kept 8, each 2 pixels
002d80 : 303c 1f3f                : move.w #$1f3f,d0			// on from each other to allow the scrolling effect)
002d84 : 4299                     : clr.l (a1)+
002d86 : 51c8 fffc                : dbra d0,-4
002d8a : d0fc 0290                : adda.w #$290,a0
002d8e : 227c 0005 0100           : movea.l #$50100,a1
002d94 : d2e9 0006                : adda.w 6(a1),a1
002d98 : 303c 00bf                : move.w #$bf,d0
002d9c : 20d9                     : move.l (a1)+,(a0)+
002d9e : 20d9                     : move.l (a1)+,(a0)+
002da0 : 20d9                     : move.l (a1)+,(a0)+
002da2 : 20d9                     : move.l (a1)+,(a0)+
002da4 : 20d9                     : move.l (a1)+,(a0)+
002da6 : 20d9                     : move.l (a1)+,(a0)+
002da8 : 20d9                     : move.l (a1)+,(a0)+
002daa : 20d9                     : move.l (a1)+,(a0)+
002dac : d0fc 0080                : adda.w #$80,a0
002db0 : 51c8 ffea                : dbra d0,-22
002db4 : 3a2e 00f6                : move.w level.number(a6),d5
002db8 : 7e00                     : moveq #0,d7
002dba : 6016                     : bra.s +22
002dbc : 3207                     : move.w d7,d1
002dbe : 5247                     : addq.w #1,d7
002dc0 : c2fc 1400                : mulu #$1400,d1
002dc4 : 206e 0004                : movea.l other.screen(a6),a0
002dc8 : d0c1                     : adda.w d1,a0
002dca : d0fc 03d0                : adda.w #$3d0,a0
002dce : 6100 ff1c                : bsr .l -$e4
002dd2 : 51cd ffe8                : dbra d5,-24
002dd6 : 246e 0004                : movea.l other.screen(a6),a2
002dda : 322e 00f6                : move.w level.number(a6),d1
002dde : c2fc 1400                : mulu #$1400,d1
002de2 : d4c1                     : adda.w d1,a2
002de4 : d4fc 0a00                : adda.w #$a00,a2
002de8 : 6100 fee0                : bsr .l -$120
002dec : 41f9 0000 40fc           : lea $40fc,a0
002df2 : 6100 da6a                : bsr .l -$2596
002df6 : 226e 0004                : movea.l other.screen(a6),a1
002dfa : 206e 0000                : movea.l screen.base(a6),a0
002dfe : d0fc 0028                : adda.w #$28,a0
002e02 : d2fc 0028                : adda.w #$28,a1
002e06 : 7e05                     : moveq #5,d7
002e08 : 7c0f                     : moveq #15,d6
002e0a : 7a01                     : moveq #1,d5
002e0c : 2448                     : movea.l a0,a2
002e0e : 2649                     : movea.l a1,a3
002e10 : 383c 00bf                : move.w #$bf,d4
002e14 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002e16 : 7201                     : moveq #1,d1
002e18 : 4e44                     : trap #4
002e1a : 301b                     : move.w (a3)+,d0
002e1c : c045                     : and.w d5,d0
002e1e : 34c0                     : move.w d0,(a2)+
002e20 : 301b                     : move.w (a3)+,d0
002e22 : c045                     : and.w d5,d0
002e24 : 34c0                     : move.w d0,(a2)+
002e26 : 301b                     : move.w (a3)+,d0
002e28 : c045                     : and.w d5,d0
002e2a : 34c0                     : move.w d0,(a2)+
002e2c : 301b                     : move.w (a3)+,d0
002e2e : c045                     : and.w d5,d0
002e30 : 34c0                     : move.w d0,(a2)+
002e32 : d4fc 0098                : adda.w #$98,a2
002e36 : d6fc 0098                : adda.w #$98,a3
002e3a : 51cc ffde                : dbra d4,-34
002e3e : 44fc 00ff                : move #$ff,ccr
002e42 : e355                     : roxl.w #1,d5
002e44 : 51ce ffc6                : dbra d6,-58
002e48 : 5148                     : subq.w #8,a0
002e4a : 5149                     : subq.w #8,a1
002e4c : 51cf ffba                : dbra d7,-70
002e50 : 4e75                     : rts 

002e52 : 206e 0000                : movea.l screen.base(a6),a0
002e56 : 7a05                     : moveq #5,d5
002e58 : 2e3c 7fff 7fff           : move.l #$7fff7fff,d7
002e5e : 7c0f                     : moveq #15,d6
002e60 : 7201                     : moveq #1,d1
002e62 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002e64 : 4e44                     : trap #4
002e66 : 383c 00c7                : move.w #$c7,d4
002e6a : 2248                     : movea.l a0,a1
002e6c : cf99                     : and.l d7,(a1)+
002e6e : cf99                     : and.l d7,(a1)+
002e70 : d2fc 0098                : adda.w #$98,a1
002e74 : 51cc fff6                : dbra d4,-10
002e78 : e29f                     : ror.l #1,d7
002e7a : 51ce ffe4                : dbra d6,-28
002e7e : 5048                     : addq.w #8,a0
002e80 : 51cd ffdc                : dbra d5,-36
002e84 : 4e75                     : rts 
disable.hblank
002e86 : 08b9 0000 ffff fa07      : bclr #$0,$fffffa07
002e8e : 08b9 0000 ffff fa13      : bclr #$0,$fffffa13
002e96 : 4e75                     : rts 
ChecksumLowMemory
			movea.l		#$600,a0								// Create checksum for lowest 16K (excluding vectors)
			clr.l		d0
			clr.l		d1
			move.w		#$3c00,d2
			move		#$0,ccr
@lp			add.b		(a0)+,d1
			addx.w		d2,d0
			dbra		d2,@lp
			move.w		d0,LowMemChecksum(a6)
			rts 

002eb8 : 3e3c 0154                : move.w #$154,d7
002ebc : 7cff                     : moveq #-1,d6
002ebe : 287c 0003 8040           : movea.l #$38040,a4
002ec4 : 7a01                     : moveq #1,d5
002ec6 : 600e                     : bra.s +14

002ec8 : 3e3c 00a0                : move.w #$a0,d7
002ecc : 7c01                     : moveq #1,d6
002ece : 287c 0003 8000           : movea.l #$38000,a4
002ed4 : 7a00                     : moveq #0,d5
002ed6 : 48e7 0308                : movem.l d6-7/a4,-(a7)
002eda : 4a45                     : tst.w d5
002edc : 6708                     : beq.s +8
002ede : 6100 080e                : bsr .l +$80e
002ee2 : 6100 d962                : bsr .l -$269e
002ee6 : 6100 f8b6                : bsr .l -$74a
002eea : 207c 0001 0000           : movea.l #$10000,a0
002ef0 : 303c 7fff                : move.w #$7fff,d0
002ef4 : 4298                     : clr.l (a0)+
002ef6 : 51c8 fffc                : dbra d0,-4
002efa : 207c 0001 0000           : movea.l #$10000,a0
002f00 : 6100 03ac                : bsr .l +$3ac
002f04 : 207c 0001 8000           : movea.l #$18000,a0
002f0a : 6100 03a2                : bsr .l +$3a2
002f0e : 207c 0002 8000           : movea.l #$28000,a0
002f14 : 6100 0398                : bsr .l +$398
002f18 : 41f9 0000 3f6c           : lea $3f6c,a0
002f1e : 6100 d93e                : bsr .l -$26c2
002f22 : 6100 0074                : bsr .l +$74
002f26 : 47f9 0000 2f78           : lea $2f78,a3
002f2c : 383c 00b8                : move.w #$b8,d4
002f30 : 4243                     : clr.w d3
002f32 : 612a                     : bsr.s +42
002f34 : 6100 0046                : bsr .l +$46
002f38 : 4cdf 10c0                : movem.l (a7)+,d6-7/a4
002f3c : 6100 0142                : bsr .l +$142
002f40 : 6100 004a                : bsr .l +$4a
002f44 : 47f9 0000 2f7a           : lea $2f7a,a3
002f4a : 4244                     : clr.w d4
002f4c : 363c 00b8                : move.w #$b8,d3
002f50 : 610c                     : bsr.s +12
002f52 : 720a                     : moveq #10,d1
002f54 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
002f56 : 4e44                     : trap #4
002f58 : 6100 f83c                : bsr .l -$7c4
002f5c : 4e75                     : rts 

002f5e : 343c 005c                : move.w #$5c,d2
002f62 : 48e7 3810                : movem.l d2-4/a3,-(a7)
002f66 : 6100 0062                : bsr .l +$62
002f6a : 4cdf 081c                : movem.l (a7)+,d2-4/a3
002f6e : d653                     : add.w (a3),d3
002f70 : 9853                     : sub.w (a3),d4
002f72 : 51ca ffee                : dbra d2,-18
002f76 : 4e75                     : rts 

002f78 : 0002 fffe                : ori.b #$fe,d2
002f7c : 4282                     : clr.l d2
002f7e : 6100 00c0                : bsr .l +$c0
002f82 : 5242                     : addq.w #1,d2
002f84 : b47c 0004                : cmp.w #$4,d2
002f88 : 66f4                     : bne.s -12
002f8a : 4e75                     : rts 

002f8c : 7403                     : moveq #3,d2
002f8e : 6100 00b0                : bsr .l +$b0
002f92 : 5342                     : subq.w #1,d2
002f94 : 6af8                     : bpl.s -8
002f96 : 4e75                     : rts 
// Bitplane conversion from Amiga seperated bitmaps to ST?
// Image 
002f98 : 227c 0003 8080           : movea.l #$38080,a1
002f9e : 207c 0002 0640           : movea.l #$20640,a0
002fa4 : 303c 00a3                : move.w #$a3,d0
002fa8 : 720c                     : moveq #12,d1
002faa : 5049                     : addq.w #8,a1
002fac : 2448                     : movea.l a0,a2
002fae : 34d9                     : move.w (a1)+,(a2)+
002fb0 : 34e9 15c6                : move.w +$15c6(a1),(a2)+
002fb4 : 34e9 2b8e                : move.w +$2b8e(a1),(a2)+
002fb8 : 34e9 4156                : move.w +$4156(a1),(a2)+
002fbc : 51c9 fff0                : dbra d1,-16
002fc0 : 41e8 00a0                : lea +$a0(a0),a0
002fc4 : 51c8 ffe2                : dbra d0,-30
002fc8 : 4e75                     : rts 

002fca : 426e 0050                : clr.w VBlankCounter(a6)
002fce : 207c 0002 0000           : movea.l #$20000,a0
002fd4 : 2004                     : move.l d4,d0
002fd6 : c0fc 00a0                : mulu #$a0,d0
002fda : d0c0                     : adda.w d0,a0
002fdc : 226e 0000                : movea.l screen.base(a6),a1
002fe0 : 247c 0002 8000           : movea.l #$28000,a2
002fe6 : 2003                     : move.l d3,d0
002fe8 : 3c3c 0038                : move.w #$38,d6
002fec : 6024                     : bra.s +36
002fee : 740c                     : moveq #12,d2
002ff0 : 2818                     : move.l (a0)+,d4
002ff2 : 2a18                     : move.l (a0)+,d5
002ff4 : 4a84                     : tst.l d4
002ff6 : 660a                     : bne.s +10
002ff8 : 4a85                     : tst.l d5
002ffa : 6606                     : bne.s +6
002ffc : 2812                     : move.l (a2),d4
002ffe : 2a2a 0004                : move.l 4(a2),d5
003002 : 22c4                     : move.l d4,(a1)+
003004 : 22c5                     : move.l d5,(a1)+
003006 : 504a                     : addq.w #8,a2
003008 : 51ca ffe6                : dbra d2,-26
00300c : d0c6                     : adda.w d6,a0
00300e : d2c6                     : adda.w d6,a1
003010 : d4c6                     : adda.w d6,a2
003012 : 51c8 ffda                : dbra d0,-38
003016 : 202e 0000                : move.l screen.base(a6),d0
00301a : 2d6e 0004 0000           : move.l other.screen(a6),screen.base(a6)
003020 : 2d40 0004                : move.l d0,other.screen(a6)
003024 : 2a7c ffff 8200           : movea.l #$ffff8200,a5
00302a : 122d 0007                : move.b 7(a5),d1
00302e : 0201 007f                : andi.b #$7f,d1
003032 : b23c 007c                : cmp.b #$7c,d1
003036 : 63f2                     : bls.s -14
003038 : e088                     : lsr.l #8,d0
00303a : 018d 0001                : movep.w d0,$1(a5)
00303e : 4e75                     : rts 

003040 : 2f02                     : move.l d2,-(a7)
003042 : 206e 0004                : movea.l other.screen(a6),a0
003046 : d0fc 2d38                : adda.w #$2d38,a0
00304a : 227c 0003 d7a0           : movea.l #$3d7a0,a1
003050 : c4fc 0a80                : mulu #$a80,d2
003054 : d2c2                     : adda.w d2,a1
003056 : 7037                     : moveq #55,d0
003058 : 7205                     : moveq #5,d1
00305a : 2448                     : movea.l a0,a2
00305c : 34d9                     : move.w (a1)+,(a2)+
00305e : 34e9 029e                : move.w +$29e(a1),(a2)+
003062 : 34e9 053e                : move.w +$53e(a1),(a2)+
003066 : 34e9 07de                : move.w +$7de(a1),(a2)+
00306a : 51c9 fff0                : dbra d1,-16
00306e : 41e8 00a0                : lea +$a0(a0),a0
003072 : 51c8 ffe4                : dbra d0,-28
003076 : 7206                     : moveq #6,d1
003078 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
00307a : 4e44                     : trap #4
00307c : 241f                     : move.l (a7)+,d2
00307e : 4e75                     : rts 

003080 : 3a3c 00b4                : move.w #$b4,d5
003084 : 206e 0004                : movea.l other.screen(a6),a0
003088 : d0fc 4380                : adda.w #$4380,a0
00308c : 43ee 3e80                : lea +$3e80(a6),a1
003090 : 303c 013f                : move.w #$13f,d0
003094 : 22d8                     : move.l (a0)+,(a1)+
003096 : 51c8 fffc                : dbra d0,-4
00309a : 2f0c                     : move.l a4,-(a7)
00309c : 7201                     : moveq #1,d1
00309e : 7007                     : moveq #SYS_DELAY_FRAMES,d0
0030a0 : 4e44                     : trap #4
0030a2 : 303c 013f                : move.w #$13f,d0
0030a6 : 41ee 3e80                : lea +$3e80(a6),a0
0030aa : 226e 0004                : movea.l other.screen(a6),a1
0030ae : d2fc 4380                : adda.w #$4380,a1
0030b2 : 22d8                     : move.l (a0)+,(a1)+
0030b4 : 51c8 fffc                : dbra d0,-4
0030b8 : de46                     : add.w d6,d7
0030ba : 206e 0004                : movea.l other.screen(a6),a0
0030be : d0fc 4380                : adda.w #$4380,a0
0030c2 : 3207                     : move.w d7,d1
0030c4 : 3007                     : move.w d7,d0
0030c6 : 0241 000f                : andi.w #$f,d1
0030ca : 0240 0ff0                : andi.w #$ff0,d0
0030ce : e248                     : lsr.w #1,d0
0030d0 : d0c0                     : adda.w d0,a0
0030d2 : 7807                     : moveq #7,d4
0030d4 : 2248                     : movea.l a0,a1
0030d6 : 3419                     : move.w (a1)+,d2
0030d8 : 8459                     : or.w (a1)+,d2
0030da : 8459                     : or.w (a1)+,d2
0030dc : 8459                     : or.w (a1)+,d2
0030de : 4842                     : swap d2
0030e0 : 3419                     : move.w (a1)+,d2
0030e2 : 8459                     : or.w (a1)+,d2
0030e4 : 8459                     : or.w (a1)+,d2
0030e6 : 8459                     : or.w (a1)+,d2
0030e8 : 4682                     : not.l d2
0030ea : 6100 0022                : bsr .l +$22
0030ee : 6100 001e                : bsr .l +$1e
0030f2 : 6100 001a                : bsr .l +$1a
0030f6 : 6100 0016                : bsr .l +$16
0030fa : d0fc 0098                : adda.w #$98,a0
0030fe : 51cc ffd4                : dbra d4,-44
003102 : 303c 013f                : move.w #$13f,d0
003106 : 285f                     : movea.l (a7)+,a4
003108 : 51cd ff90                : dbra d5,-112
00310c : 4e75                     : rts 

00310e : 4280                     : clr.l d0
003110 : 301c                     : move.w (a4)+,d0
003112 : 4840                     : swap d0
003114 : e2a8                     : lsr.l d1,d0
003116 : c082                     : and.l d2,d0
003118 : 8168 0008                : or.w d0,8(a0)
00311c : 4840                     : swap d0
00311e : 8158                     : or.w d0,(a0)+
003120 : 4e75                     : rts 

003122 : 4df9 0000 55da           : lea GlobalVariables,a6
003128 : 206e 0000                : movea.l screen.base(a6),a0
00312c : 227c 0001 8000           : movea.l #$18000,a1
003132 : 2d49 0000                : move.l a1,screen.base(a6)
003136 : 2d49 0056                : move.l a1,86(a6)
00313a : 303c 1f3f                : move.w #$1f3f,d0
00313e : 22d8                     : move.l (a0)+,(a1)+
003140 : 51c8 fffc                : dbra d0,-4
003144 : 7000                     : moveq #SYS_SET_VIDEOBASE,d0
003146 : 4e44                     : trap #4
003148 : 6100 05b6                : bsr .l +$5b6
00314c : 6100 fd04                : bsr .l -$2fc
003150 : 50ee 0090                : st  +$90(a6)
003154 : 6100 d6f0                : bsr .l -$2910
003158 : 6100 fd2c                : bsr .l -$2d4
00315c : 6100 0140                : bsr .l +$140
003160 : 206e 0000                : movea.l screen.base(a6),a0
003164 : 6100 0148                : bsr .l +$148
003168 : 4282                     : clr.l d2
00316a : 6100 00ce                : bsr .l +$ce
00316e : 41f9 0000 3f4c           : lea $3f4c,a0
003174 : 6100 d6e8                : bsr .l -$2918
003178 : 303c 1f3f                : move.w #$1f3f,d0
00317c : 206e 0000                : movea.l screen.base(a6),a0
003180 : 227c 0002 8000           : movea.l #$28000,a1
003186 : 22d8                     : move.l (a0)+,(a1)+
003188 : 51c8 fffc                : dbra d0,-4
00318c : 7007                     : moveq #SYS_DELAY_FRAMES,d0
00318e : 323c 0064                : move.w #$64,d1
003192 : 4e44                     : trap #4
003194 : 4282                     : clr.l d2
003196 : 6100 0162                : bsr .l +$162
00319a : 7204                     : moveq #4,d1
00319c : 7007                     : moveq #SYS_DELAY_FRAMES,d0
00319e : 4e44                     : trap #4
0031a0 : 5242                     : addq.w #1,d2
0031a2 : b47c 000a                : cmp.w #$a,d2
0031a6 : 66ee                     : bne.s -18
0031a8 : 206e 0000                : movea.l screen.base(a6),a0
0031ac : 227c 0002 8000           : movea.l #$28000,a1
0031b2 : 303c 1f3f                : move.w #$1f3f,d0
0031b6 : 20d9                     : move.l (a1)+,(a0)+
0031b8 : 51c8 fffc                : dbra d0,-4
0031bc : 7400                     : moveq #0,d2
0031be : 7007                     : moveq #SYS_DELAY_FRAMES,d0
0031c0 : 7205                     : moveq #5,d1
0031c2 : 4e44                     : trap #4
0031c4 : 6100 0074                : bsr .l +$74
0031c8 : 5242                     : addq.w #1,d2
0031ca : b47c 0009                : cmp.w #$9,d2
0031ce : 66ee                     : bne.s -18
0031d0 : 7007                     : moveq #SYS_DELAY_FRAMES,d0
0031d2 : 7214                     : moveq #20,d1
0031d4 : 4e44                     : trap #4
0031d6 : 41f9 0000 3f8c           : lea $3f8c,a0
0031dc : 6100 0096                : bsr .l +$96
0031e0 : 41f9 0000 3f9c           : lea $3f9c,a0
0031e6 : 6100 008c                : bsr .l +$8c
0031ea : 41f9 0000 3fac           : lea $3fac,a0
0031f0 : 6100 0082                : bsr .l +$82
0031f4 : 41f9 0000 3f8c           : lea $3f8c,a0
0031fa : 6100 0078                : bsr .l +$78
0031fe : 50ee 0090                : st  +$90(a6)
003202 : 6100 d642                : bsr .l -$29be
003206 : 6100 fc7e                : bsr .l -$382
00320a : 207c 0001 0000           : movea.l #$10000,a0
003210 : 2d48 0000                : move.l a0,screen.base(a6)
003214 : 2d48 0056                : move.l a0,86(a6)
003218 : 6100 0084                : bsr .l +$84
00321c : 7000                     : moveq #SYS_SET_VIDEOBASE,d0
00321e : 4e44                     : trap #4
003220 : 41f9 0000 519a           : lea $519a,a0
003226 : 7006                     : moveq #SYS_PRINT,d0
003228 : 4e44                     : trap #4
00322a : 41f9 0000 40fc           : lea $40fc,a0
003230 : 6100 d62c                : bsr .l -$29d4
003234 : 6100 fc82                : bsr .l -$37e
003238 : 4e75                     : rts 

00323a : 2f02                     : move.l d2,-(a7)
00323c : c4fc 1200                : mulu #$1200,d2
003240 : 0682 0003 0000           : addi.l #$30000,d2
003246 : 2242                     : movea.l d2,a1
003248 : 206e 0000                : movea.l screen.base(a6),a0
00324c : d0fc 12f8                : adda.w #$12f8,a0
003250 : 725f                     : moveq #95,d1
003252 : 2448                     : movea.l a0,a2
003254 : 7405                     : moveq #5,d2
003256 : 34d9                     : move.w (a1)+,(a2)+
003258 : 34e9 047e                : move.w +$47e(a1),(a2)+
00325c : 34e9 08fe                : move.w +$8fe(a1),(a2)+
003260 : 34e9 0d7e                : move.w +$d7e(a1),(a2)+
003264 : 51ca fff0                : dbra d2,-16
003268 : d0fc 00a0                : adda.w #$a0,a0
00326c : 51c9 ffe4                : dbra d1,-28
003270 : 241f                     : move.l (a7)+,d2
003272 : 4e75                     : rts 

003274 : 227c 00ff 8250           : movea.l #$ff8250,a1
00327a : 22d8                     : move.l (a0)+,(a1)+
00327c : 22d8                     : move.l (a0)+,(a1)+
00327e : 22d8                     : move.l (a0)+,(a1)+
003280 : 22d8                     : move.l (a0)+,(a1)+
003282 : 7013                     : moveq #19,d0
003284 : 6100 0446                : bsr .l +$446
003288 : 7409                     : moveq #9,d2
00328a : 7007                     : moveq #SYS_DELAY_FRAMES,d0
00328c : 7204                     : moveq #4,d1
00328e : 4e44                     : trap #4
003290 : 6100 ffa8                : bsr .l -$58
003294 : 5242                     : addq.w #1,d2
003296 : b47c 0012                : cmp.w #$12,d2
00329a : 66ee                     : bne.s -18
00329c : 4e75                     : rts 

00329e : 206e 0000                : movea.l screen.base(a6),a0
0032a2 : 303c 1f3f                : move.w #$1f3f,d0
0032a6 : 4298                     : clr.l (a0)+
0032a8 : 51c8 fffc                : dbra d0,-4
0032ac : 4e75                     : rts 

0032ae : 43f9 00fc 0000           : lea $fc0000,a1
0032b4 : 7e63                     : moveq #99,d7
0032b6 : 7c13                     : moveq #19,d6
0032b8 : 3219                     : move.w (a1)+,d1
0032ba : 3419                     : move.w (a1)+,d2
0032bc : 3619                     : move.w (a1)+,d3
0032be : 3819                     : move.w (a1)+,d4
0032c0 : b541                     : eor.w d2,d1
0032c2 : b343                     : eor.w d1,d3
0032c4 : 3a04                     : move.w d4,d5
0032c6 : 0245 0007                : andi.w #$7,d5
0032ca : 0244 0008                : andi.w #$8,d4
0032ce : ea7c                     : ror.w d5,d4
0032d0 : c244                     : and.w d4,d1
0032d2 : c444                     : and.w d4,d2
0032d4 : c644                     : and.w d4,d3
0032d6 : 4a90                     : tst.l (a0)
0032d8 : 6610                     : bne.s +16
0032da : 4aa8 0004                : tst.l 4(a0)
0032de : 660a                     : bne.s +10
0032e0 : 3142 0002                : move.w d2,2(a0)
0032e4 : 3143 0004                : move.w d3,4(a0)
0032e8 : 3081                     : move.w d1,(a0)
0032ea : 5048                     : addq.w #8,a0
0032ec : 51ce ffca                : dbra d6,-54
0032f0 : d0fc 00a0                : adda.w #$a0,a0
0032f4 : 51cf ffc0                : dbra d7,-64
0032f8 : 4e75                     : rts 

0032fa : 2f02                     : move.l d2,-(a7)
0032fc : 303c 1f3f                : move.w #$1f3f,d0
003300 : 207c 0002 8000           : movea.l #$28000,a0
003306 : 227c 0002 0000           : movea.l #$20000,a1
00330c : 22d8                     : move.l (a0)+,(a1)+
00330e : 51c8 fffc                : dbra d0,-4
003312 : 45f9 0000 339c           : lea $339c,a2
003318 : c4fc 0006                : mulu #$6,d2
00331c : d4c2                     : adda.w d2,a2
00331e : 227c 0004 4420           : movea.l #$44420,a1
003324 : d2da                     : adda.w (a2)+,a1
003326 : 207c 0002 0010           : movea.l #$20010,a0
00332c : 301a                     : move.w (a2)+,d0
00332e : 321a                     : move.w (a2)+,d1
003330 : c2fc 00a0                : mulu #$a0,d1
003334 : d0c1                     : adda.w d1,a0
003336 : 3400                     : move.w d0,d2
003338 : c4fc 0012                : mulu #$12,d2
00333c : 45f1 2000                : lea 0(a1,d2.W),a2			// Bitplane 1
003340 : 47f2 2000                : lea 0(a2,d2.W),a3			// Bitplane 2
003344 : 49f3 2000                : lea 0(a3,d2.W),a4			// Bitplane 3
003348 : 4bf4 2000                : lea 0(a4,d2.W),a5			// Mask
00334c : 5340                     : subq.w #1,d0
00334e : 7e08                     : moveq #8,d7
003350 : 3c1d                     : move.w (a5)+,d6				// Get mask
003352 : 4646                     : not.w d6					// Invert it
003354 : cd50                     : and.w d6,(a0)				// Mask out original data from
003356 : cd68 0002                : and.w d6,2(a0)				// all bitplanes on screen
00335a : cd68 0004                : and.w d6,4(a0)
00335e : cd68 0006                : and.w d6,6(a0)
003362 : 3c19                     : move.w (a1)+,d6				// Or in bitplane 0
003364 : 8d58                     : or.w d6,(a0)+
003366 : 3c1a                     : move.w (a2)+,d6				// Bitplane 1
003368 : 8d58                     : or.w d6,(a0)+
00336a : 3c1b                     : move.w (a3)+,d6				// Bitplane 2
00336c : 8d58                     : or.w d6,(a0)+
00336e : 3c1c                     : move.w (a4)+,d6				// Bitplane 3
003370 : 8d58                     : or.w d6,(a0)+
003372 : 51cf ffdc                : dbra d7,-36
003376 : d0fc 0058                : adda.w #$58,a0
00337a : 51c8 ffd2                : dbra d0,-46
00337e : 7007                     : moveq #SYS_DELAY_FRAMES,d0
003380 : 7201                     : moveq #1,d1
003382 : 4e44                     : trap #4
003384 : 303c 1f3f                : move.w #$1f3f,d0
003388 : 206e 0000                : movea.l screen.base(a6),a0
00338c : 227c 0002 0000           : movea.l #$20000,a1
003392 : 20d9                     : move.l (a1)+,(a0)+
003394 : 51c8 fffc                : dbra d0,-4
003398 : 241f                     : move.l (a7)+,d2
00339a : 4e75                     : rts 

00339c : 0000 0007                : ori.b #$7,d0
0033a0 : 003c 0276                : ori.b #$76,ccr
0033a4 : 000a                     : dc.w $a
0033a6 : 003d                     : dc.w $3d
0033a8 : 05fa                     : dc.w $5fa
0033aa : 000b                     : dc.w $b
0033ac : 003e                     : dc.w $3e
0033ae : 09d8                     : bset d4,(a0)+
0033b0 : 000e                     : dc.w $e
0033b2 : 0040 0ec4                : ori.w #$ec4,d0
0033b6 : 000f                     : dc.w $f
0033b8 : 0043 140a                : ori.w #$140a,d3
0033bc : 0011 0048                : ori.b #$48,(a1)
0033c0 : 1a04                     : move.b d4,d5
0033c2 : 0015 0052                : ori.b #$52,(a5)
0033c6 : 2166 0020                : move.l -(a6),32(a0)
0033ca : 005e 2ca6                : ori.w #$2ca6,(a6)+
0033ce : 0037 006e 3ffc           : ori.b #$6e,-4(a7,d3.L)
0033d4 : 003a                     : dc.w $3a
0033d6 : 008c                     : dc.w $8c
0033d8 : 48e7 7f7e                : movem.l d1-7/a1-6,-(a7)
0033dc : 4df9 0000 55da           : lea GlobalVariables,a6
0033e2 : 3d7c 0003 0010           : move.w #$3,16(a6)
0033e8 : 426e 0012                : clr.w 18(a6)
0033ec : 2d48 0014                : move.l a0,20(a6)
0033f0 : 263c 0000 0001           : move.l #$1,d3
0033f6 : 2d43 0018                : move.l d3,24(a6)
0033fa : 6100 027e                : bsr .l +$27e
0033fe : 6100 0032                : bsr .l +$32
003402 : 6100 0066                : bsr .l +$66
003406 : 6100 007c                : bsr .l +$7c
00340a : 6100 00c0                : bsr .l +$c0
00340e : 6100 00bc                : bsr .l +$bc
003412 : 6100 0056                : bsr .l +$56
003416 : 6100 019c                : bsr .l +$19c
00341a : 6100 0228                : bsr .l +$228
00341e : 4a00                     : tst.b d0
003420 : 6700 000a                : beq .l +$a
003424 : 262e 0018                : move.l 24(a6),d3
003428 : 51cb ffcc                : dbra d3,-52
00342c : 4cdf 7efe                : movem.l (a7)+,d1-7/a1-6
003430 : 4e75                     : rts 

003432 : 303c 0000                : move.w #$0,d0
003436 : 5200                     : addq.b #1,d0
003438 : e308                     : lsl.b #1,d0
00343a : 0040 0000                : ori.w #$0,d0
00343e : 0a00 0007                : eori.b #$7,d0
003442 : 0200 0007                : andi.b #$7,d0
003446 : 40e7                     : move sr,-(a7)
003448 : 007c 0700                : ori.w #$700,sr
00344c : 13fc 000e 00ff 8800      : move.b #$e,$ff8800
003454 : 1239 00ff 8800           : move.b $ff8800,d1
00345a : 0201 00f8                : andi.b #$f8,d1
00345e : 8200                     : or.b d0,d1
003460 : 13c1 00ff 8802           : move.b d1,$ff8802
003466 : 46df                     : move (a7)+,sr
003468 : 4e75                     : rts 

00346a : 33fc 0080 00ff 8606      : move.w #$80,$ff8606
003472 : 3c3c 00d0                : move.w #$d0,d6
003476 : 6100 0154                : bsr .l +$154
00347a : 3e3c 0028                : move.w #$28,d7
00347e : 6100 0146                : bsr .l +$146
003482 : 4e75                     : rts 

003484 : 6100 0172                : bsr .l +$172
003488 : 33fc 0086 00ff 8606      : move.w #$86,$ff8606
003490 : 3c3c 004f                : move.w #$4f,d6
003494 : 6100 0136                : bsr .l +$136
003498 : 33fc 0080 00ff 8606      : move.w #$80,$ff8606
0034a0 : 3c3c 001b                : move.w #$1b,d6
0034a4 : 6100 0126                : bsr .l +$126
0034a8 : 2e3c 0006 0000           : move.l #$60000,d7
0034ae : 5387                     : subq.l #1,d7
0034b0 : 6700 0010                : beq .l +$10
0034b4 : 0839 0005 00ff fa01      : btst #$5,$fffa01
0034bc : 6600 fff0                : bne .l -$10
0034c0 : 4e75                     : rts 

0034c2 : 3f3c fff9                : move.w #$fff9,-(a7)
0034c6 : 6100 017a                : bsr .l +$17a
0034ca : 4e75                     : rts 
// Some disk I/O routines
0034cc : 42b9 0000 000c           : clr.l $c
0034d2 : 40ee 0000                : move sr,screen.base(a6)
0034d6 : 46fc 2700                : move #$2700,sr
0034da : 33fc 0090 00ff 8606      : move.w #$90,$ff8606
0034e2 : 33fc 0190 00ff 8606      : move.w #$190,$ff8606
0034ea : 33fc 0090 00ff 8606      : move.w #$90,$ff8606
0034f2 : 3c3c 0016                : move.w #$16,d6
0034f6 : 343c 0200                : move.w #$200,d2
0034fa : c4c6                     : mulu d6,d2
0034fc : 3d42 0002                : move.w d2,2(a6)
003500 : 262e 0014                : move.l 20(a6),d3
003504 : d483                     : add.l d3,d2
003506 : 23c2 0000 0008           : move.l d2,$8
00350c : 6100 00be                : bsr .l +$be
003510 : 202e 0014                : move.l 20(a6),d0
003514 : 13c0 00ff 860d           : move.b d0,$ff860d
00351a : e088                     : lsr.l #8,d0
00351c : 13c0 00ff 860b           : move.b d0,$ff860b
003522 : e088                     : lsr.l #8,d0
003524 : 13c0 00ff 8609           : move.b d0,$ff8609
00352a : 33fc 0080 00ff 8606      : move.w #$80,$ff8606
003532 : 3c3c 00e8                : move.w #$e8,d6
003536 : 6100 0094                : bsr .l +$94
00353a : 2e3c 0005 0000           : move.l #$50000,d7
003540 : 2a79 0000 0008           : movea.l $8,a5
003546 : 303c 0200                : move.w #$200,d0
00354a : 51c8 fffe                : dbra d0,-2
00354e : 0839 0005 00ff fa01      : btst #$5,$fffa01
003556 : 6700 0028                : beq .l +$28
00355a : 5387                     : subq.l #1,d7
00355c : 6700 0052                : beq .l +$52
003560 : 1d79 00ff 8609 000d      : move.b $ff8609,13(a6)
003568 : 1d79 00ff 860b 000e      : move.b $ff860b,14(a6)
003570 : 1d79 00ff 860d 000f      : move.b $ff860d,15(a6)
003578 : bbee 000c                : cmpa.l 12(a6),a5
00357c : 6e00 ffd0                : bgt .l -$30
003580 : 33fc 0090 00ff 8606      : move.w #$90,$ff8606
003588 : 3a39 00ff 8606           : move.w $ff8606,d5
00358e : 3d45 0004                : move.w d5,other.screen(a6)
003592 : 0805 0000                : btst #$0,d5
003596 : 6700 0014                : beq .l +$14
00359a : 33fc 0080 00ff 8606      : move.w #$80,$ff8606
0035a2 : 6100 008c                : bsr .l +$8c
0035a6 : 46ee 0000                : move screen.base(a6),sr
0035aa : 4e75                     : rts 

0035ac : 6000 fff8                : bra .l -$8
0035b0 : 6000 fff4                : bra .l -$c
0035b4 : 33fc 0080 00ff 8606      : move.w #$80,$ff8606
0035bc : 103c 0007                : move.b #$7,d0
0035c0 : 6100 fe84                : bsr .l -$17c
0035c4 : 4e75                     : rts 

0035c6 : 51cf fffe                : dbra d7,-2
0035ca : 4e75                     : rts 

0035cc : 6100 0018                : bsr .l +$18
0035d0 : 33c6 00ff 8604           : move.w d6,$ff8604
0035d6 : 6100 000e                : bsr .l +$e
0035da : 4e75                     : rts 

0035dc : 3639 00ff 8604           : move.w $ff8604,d3
0035e2 : 6100 0002                : bsr .l +$2
0035e6 : 40e7                     : move sr,-(a7)
0035e8 : 3f07                     : move.w d7,-(a7)
0035ea : 3e3c 0028                : move.w #$28,d7
0035ee : 51cf fffe                : dbra d7,-2
0035f2 : 3e1f                     : move.w (a7)+,d7
0035f4 : 46df                     : move (a7)+,sr
0035f6 : 4e75                     : rts 

0035f8 : 3c2e 0010                : move.w 16(a6),d6
0035fc : 0246 0003                : andi.w #$3,d6
003600 : 2e3c 0005 0000           : move.l #$50000,d7
003606 : 33fc 0080 00ff 8606      : move.w #$80,$ff8606
00360e : 6100 ffbc                : bsr .l -$44
003612 : 5387                     : subq.l #1,d7
003614 : 6700 0010                : beq .l +$10
003618 : 0839 0005 00ff fa01      : btst #$5,$fffa01
003620 : 6600 fff0                : bne .l -$10
003624 : 4e75                     : rts 

003626 : 3f3c fff9                : move.w #$fff9,-(a7)
00362a : 6100 0016                : bsr .l +$16
00362e : 4e75                     : rts 

003630 : 6100 ffb4                : bsr .l -$4c
003634 : 3d79 00ff 8604 0012      : move.w $ff8604,18(a6)
00363c : 6100 ffa8                : bsr .l -$58
003640 : 4e75                     : rts 

003642 : 4e75                     : rts 
003644 : 222e 0014                : move.l 20(a6),d1
003648 : 0681 0000 2ee0           : addi.l #$2ee0,d1
00364e : 2041                     : movea.l d1,a0
003650 : 263c 0000 0dac           : move.l #$dac,d3
003656 : 243c 0000 0000           : move.l #$0,d2
00365c : 3a20                     : move.w -(a0),d5
00365e : 3020                     : move.w -(a0),d0
003660 : ba40                     : cmp.w d0,d5
003662 : 6608                     : bne.s +8
003664 : 5482                     : addq.l #2,d2
003666 : 51cb fff6                : dbra d3,-10
00366a : 74ff                     : moveq #-1,d2
00366c : 2d42 0120                : move.l d2,+$120(a6)
003670 : 0482 0000 170c           : subi.l #$170c,d2
003676 : 5bc0                     : smi d0
003678 : 4e75                     : rts 

00367a : 243c 0000 176f           : move.l #$176f,d2
003680 : 206e 0014                : movea.l 20(a6),a0
003684 : 2639 0000 04ba           : move.l $4ba,d3
00368a : 30c3                     : move.w d3,(a0)+
00368c : 51ca fffc                : dbra d2,-4
003690 : 4e75                     : rts 

003692 : 50ee 0090                : st  +$90(a6)
003696 : 6100 f0fe                : bsr .l -$f02
00369a : 41f9 0000 505a           : lea MSG_Escape,a0
0036a0 : 7006                     : moveq #SYS_PRINT,d0
0036a2 : 4e44                     : trap #4
0036a4 : 41f9 0000 40fc           : lea $40fc,a0
0036aa : 6100 d1b2                : bsr .l -$2e4e
0036ae : 4e75                     : rts 
play.music
0036b0 : 082e 0000 0079           : btst #$0,+$79(a6)
0036b6 : 6612                     : bne.s +18
0036b8 : 426e 006e                : clr.w +$6e(a6)
0036bc : 33fc 000a 0005 85c4      : move.w #$a,$585c4
0036c4 : 4ef9 0005 7d00           : jmp $57d00
0036ca : 4e75                     : rts 

play.sound
0036cc : 082e 0001 0079           : btst #$1,+$79(a6)
0036d2 : 6606                     : bne.s +6
0036d4 : 4ef9 0005 7d38           : jmp $57d38
0036da : 4e75                     : rts 

0036dc : 7e11                     : moveq #17,d7
0036de : 7c14                     : moveq #20,d6
0036e0 : 2a7c 0005 0100           : movea.l #$50100,a5
0036e6 : 7a01                     : moveq #1,d5
0036e8 : 6100 0194                : bsr .l +$194
0036ec : 4e75                     : rts 

0036ee : 4ef9 000d 2000           : jmp $d2000
0036f4 : 0003 8000                : ori.b #$0,d3
0036f8 : 7a02                     : moveq #2,d5
0036fa : 6100 017e                : bsr .l +$17e
0036fe : 4e75                     : rts 

003700 : 4ef9 000d 1000           : jmp $d1000
003706 : 0003 0000                : ori.b #$0,d3
00370a : 7a01                     : moveq #1,d5
00370c : 6100 016c                : bsr .l +$16c
003710 : 4e75                     : rts 

003712 : 6100 0032                : bsr .l +$32
003716 : 4a2e 00c3                : tst.b +$c3(a6)
00371a : 6604                     : bne.s +4
00371c : 6100 f734                : bsr .l -$8cc
003720 : 6100 d124                : bsr .l -$2edc
003724 : 6000 f760                : bra .l -$8a0
003728 : 4e75                     : rts 

00372a : 426e 011e                : clr.w +$11e(a6)
00372e : b07c 0002                : cmp.w #$2,d0
003732 : 6610                     : bne.s +16
003734 : 41f9 0000 5302           : lea $5302,a0
00373a : 10bc 0042                : move.b #$42,(a0)
00373e : 3d7c 0001 011e           : move.w #$1,+$11e(a6)
003744 : 4e75                     : rts 

003746 : 7a02                     : moveq #2,d5
003748 : 3e39 0000 56d0           : move.w $56d0,d7
00374e : cefc 000d                : mulu #$d,d7
003752 : 0647 0001                : addi.w #$1,d7
003756 : 7c0c                     : moveq #12,d6
003758 : be7c 0042                : cmp.w #$42,d7
00375c : 6604                     : bne.s +4
00375e : 7e42                     : moveq #66,d7
003760 : 7a01                     : moveq #1,d5
003762 : 4eb9 000d 0000           : jsr $d0000
003768 : 4e71                     : nop 
00376a : 4e71                     : nop 
00376c : 2a7c 0002 0000           : movea.l #$20000,a5
003772 : 207c 0006 7d00           : movea.l #$67d00,a0
003778 : 284d                     : movea.l a5,a4
00377a : 301d                     : move.w (a5)+,d0
00377c : 284d                     : movea.l a5,a4
00377e : d8c0                     : adda.w d0,a4
003780 : 5940                     : subq.w #4,d0
003782 : 7207                     : moveq #7,d1
003784 : 141d                     : move.b (a5)+,d2
003786 : 0302                     : btst d1,d2
003788 : 670c                     : beq.s +12
00378a : 10dc                     : move.b (a4)+,(a0)+
00378c : 51c9 fff8                : dbra d1,-8
003790 : 51c8 fff0                : dbra d0,-16
003794 : 4e75                     : rts 

003796 : 4218                     : clr.b (a0)+
003798 : 51c9 ffec                : dbra d1,-20
00379c : 51c8 ffe4                : dbra d0,-28
0037a0 : 4e75                     : rts 
// Looks like the cheatcode check right here. DRACONIA is the cheatcode!
0037a2 : 3d7c 000a 011a           : move.w #$a,+$11a(a6)
0037a8 : 50f9 0000 038a           : st  $38a
0037ae : 322e 011e                : move.w +$11e(a6),d1
0037b2 : ba3c 0001                : cmp.b #$1,d5
0037b6 : 6602                     : bne.s +2
0037b8 : 4241                     : clr.w d1
0037ba : 7401                     : moveq #1,d2
0037bc : 7601                     : moveq #1,d3
0037be : 7800                     : moveq #0,d4
0037c0 : 41ee 3e80                : lea +$3e80(a6),a0
0037c4 : 48e7 0702                : movem.l d5-7/a6,-(a7)
0037c8 : 4e71                     : nop 
0037ca : 4e71                     : nop 
0037cc : 4cdf 40e0                : movem.l (a7)+,d5-7/a6
0037d0 : 4a6e 011a                : tst.w +$11a(a6)
0037d4 : 602a                     : bra.s +42
0037d6 : 4a80                     : tst.l d0
0037d8 : 6600 050e                : bne .l +$50e
0037dc : 41ee 3e82                : lea +$3e82(a6),a0
0037e0 : 0c98 4452 4143           : cmpi.l #$44524143,(a0)+
0037e6 : 6600 0500                : bne .l +$500
0037ea : 0c98 4f4e 4941           : cmpi.l #$4f4e4941,(a0)+
0037f0 : 6600 04f6                : bne .l +$4f6
0037f4 : 1018                     : move.b (a0)+,d0
0037f6 : 0400 0030                : subi.b #$30,d0
0037fa : b005                     : cmp.b d5,d0
0037fc : 6600 04ea                : bne .l +$4ea
003800 : 6100 00c2                : bsr .l +$c2
003804 : 4280                     : clr.l d0
003806 : 4e75                     : rts 

003808 : 7a02                     : moveq #2,d5
00380a : 6100 ff96                : bsr .l -$6a
00380e : 322e 011e                : move.w +$11e(a6),d1
003812 : 7406                     : moveq #6,d2
003814 : 7601                     : moveq #1,d3
003816 : 7800                     : moveq #0,d4
003818 : 41ee 3e80                : lea +$3e80(a6),a0
00381c : 48e7 0702                : movem.l d5-7/a6,-(a7)
003820 : 7000                     : moveq #0,d0
003822 : 4eb9 000d 4000           : jsr $d4000
003828 : 4cdf 40e0                : movem.l (a7)+,d5-7/a6
00382c : 4bee 3e80                : lea +$3e80(a6),a5
003830 : 41f9 0000 5496           : lea $5496,a0
003836 : 7013                     : moveq #19,d0
003838 : bb08                     : cmpm.b (a0)+,(a5)+
00383a : 660e                     : bne.s +14
00383c : 51c8 fffa                : dbra d0,-6
003840 : 303c 012b                : move.w #$12b,d0
003844 : 10dd                     : move.b (a5)+,(a0)+
003846 : 51c8 fffc                : dbra d0,-4
00384a : 4e75                     : rts 

00384c : 7a02                     : moveq #2,d5
00384e : 6100 ff52                : bsr .l -$ae
003852 : 4a80                     : tst.l d0
003854 : 6600 db5e                : bne .l -$24a2
003858 : 322e 011e                : move.w +$11e(a6),d1
00385c : 7406                     : moveq #6,d2
00385e : 7601                     : moveq #1,d3
003860 : 7800                     : moveq #0,d4
003862 : 41f9 0000 5496           : lea $5496,a0
003868 : 48e7 0702                : movem.l d5-7/a6,-(a7)
00386c : 7001                     : moveq #1,d0
00386e : 4eb9 000d 4000           : jsr $d4000
003874 : 4cdf 40e0                : movem.l (a7)+,d5-7/a6
003878 : 4e75                     : rts 

00387a : 6100 ff26                : bsr .l -$da
00387e : 50f9 0000 038a           : st  $38a
003884 : 322e 011e                : move.w +$11e(a6),d1
003888 : ba3c 0001                : cmp.b #$1,d5
00388c : 6602                     : bne.s +2
00388e : 4241                     : clr.w d1
003890 : 204d                     : movea.l a5,a0
003892 : 7401                     : moveq #1,d2
003894 : 760a                     : moveq #10,d3
003896 : 2807                     : move.l d7,d4
003898 : 48e7 4706                : movem.l d1/d5-7/a5-6,-(a7)
00389c : 6100 0038                : bsr .l +$38
0038a0 : 4cdf 60e2                : movem.l (a7)+,d1/d5-7/a5-6
0038a4 : 4a80                     : tst.l d0
0038a6 : 6712                     : beq.s +18
0038a8 : 48e7 ff04                : movem.l d0-7/a5,-(a7)
0038ac : 41f9 0000 531c           : lea $531c,a0
0038b2 : 7006                     : moveq #SYS_PRINT,d0
0038b4 : 4e44                     : trap #4
0038b6 : 4cdf 20ff                : movem.l (a7)+,d0-7/a5
0038ba : dafc 1400                : adda.w #$1400,a5
0038be : 5247                     : addq.w #1,d7
0038c0 : 51ce ffc2                : dbra d6,-62
0038c4 : 13fc 000e 00ff 8800      : move.b #$e,$ff8800
0038cc : 13fc 0006 00ff 8802      : move.b #$6,$ff8802
0038d4 : 4e75                     : rts 

0038d6 : 70f5                     : moveq #-11,d0
0038d8 : 6100 01b6                : bsr .l +$1b6
0038dc : 6100 035a                : bsr .l +$35a
0038e0 : 6100 02b0                : bsr .l +$2b0
0038e4 : 6600 00a0                : bne .l +$a0
0038e8 : 33fc ffff 0000 0380      : move.w #$ffff,$380
0038f0 : 3cbc 0090                : move.w #$90,(a6)
0038f4 : 3cbc 0190                : move.w #$190,(a6)
0038f8 : 3cbc 0090                : move.w #$90,(a6)
0038fc : 33f9 0000 038c 00ff 8604 : move.w $38c,$ff8604
003906 : 3cbc 0080                : move.w #$80,(a6)
00390a : 3e3c 0090                : move.w #$90,d7
00390e : 6100 03aa                : bsr .l +$3aa
003912 : 2e3c 0004 0000           : move.l #$40000,d7
003918 : 2479 0000 0394           : movea.l $394,a2
00391e : 0839 0005 00ff fa01      : btst #$5,$fffa01
003926 : 673e                     : beq.s +62
003928 : 5387                     : subq.l #1,d7
00392a : 672c                     : beq.s +44
00392c : 13f9 00ff 8609 0000 0391 : move.b $ff8609,$391
003936 : 13f9 00ff 860b 0000 0392 : move.b $ff860b,$392
003940 : 13f9 00ff 860d 0000 0393 : move.b $ff860d,$393
00394a : b5f9 0000 0390           : cmpa.l $390,a2
003950 : 6ecc                     : bgt.s -52
003952 : 6100 02ca                : bsr .l +$2ca
003956 : 600e                     : bra.s +14
003958 : 33fc fffe 0000 0380      : move.w #$fffe,$380
003960 : 6100 02bc                : bsr .l +$2bc
003964 : 6020                     : bra.s +32
003966 : 3cbc 0090                : move.w #$90,(a6)
00396a : 3016                     : move.w (a6),d0
00396c : 0800 0000                : btst #$0,d0
003970 : 6714                     : beq.s +20
003972 : 3cbc 0080                : move.w #$80,(a6)
003976 : 6100 0356                : bsr .l +$356
00397a : 0240 0018                : andi.w #$18,d0
00397e : 6700 019a                : beq .l +$19a
003982 : 6100 00e6                : bsr .l +$e6
003986 : 0c79 0001 0000 038e      : cmpi.w #$1,$38e
00398e : 6604                     : bne.s +4
003990 : 6100 01c4                : bsr .l +$1c4
003994 : 5379 0000 038e           : subq.w #1,$38e
00399a : 6a00 ff40                : bpl .l -$c0
00399e : 6000 0170                : bra .l +$170
0039a2 : 70f5                     : moveq #-11,d0
0039a4 : 6100 00ea                : bsr .l +$ea
0039a8 : 6100 028e                : bsr .l +$28e
0039ac : 6100 01e4                : bsr .l +$1e4
0039b0 : 6600 009c                : bne .l +$9c
0039b4 : 33fc ffff 0000 0380      : move.w #$ffff,$380
0039bc : 3cbc 0190                : move.w #$190,(a6)
0039c0 : 3cbc 0090                : move.w #$90,(a6)
0039c4 : 3cbc 0190                : move.w #$190,(a6)
0039c8 : 33fc 0001 00ff 8604      : move.w #$1,$ff8604
0039d0 : 3cbc 0180                : move.w #$180,(a6)
0039d4 : 3e3c 00a0                : move.w #$a0,d7
0039d8 : 6100 02e0                : bsr .l +$2e0
0039dc : 2e3c 0004 0000           : move.l #$40000,d7
0039e2 : 2479 0000 0394           : movea.l $394,a2
0039e8 : 0839 0005 00ff fa01      : btst #$5,$fffa01
0039f0 : 673e                     : beq.s +62
0039f2 : 5387                     : subq.l #1,d7
0039f4 : 672c                     : beq.s +44
0039f6 : 13f9 00ff 8609 0000 0391 : move.b $ff8609,$391
003a00 : 13f9 00ff 860b 0000 0392 : move.b $ff860b,$392
003a0a : 13f9 00ff 860d 0000 0393 : move.b $ff860d,$393
003a14 : b5f9 0000 0390           : cmpa.l $390,a2
003a1a : 6ecc                     : bgt.s -52
003a1c : 6100 0200                : bsr .l +$200
003a20 : 600e                     : bra.s +14
003a22 : 33fc fffe 0000 0380      : move.w #$fffe,$380
003a2a : 6100 01f2                : bsr .l +$1f2
003a2e : 601e                     : bra.s +30
003a30 : 3cbc 0090                : move.w #$90,(a6)
003a34 : 3016                     : move.w (a6),d0
003a36 : 0800 0000                : btst #$0,d0
003a3a : 6712                     : beq.s +18
003a3c : 3cbc 0080                : move.w #$80,(a6)
003a40 : 6100 028c                : bsr .l +$28c
003a44 : 0240 0018                : andi.w #$18,d0
003a48 : 6700 00d0                : beq .l +$d0
003a4c : 611c                     : bsr.s +28
003a4e : 0c79 0001 0000 038e      : cmpi.w #$1,$38e
003a56 : 6604                     : bne.s +4
003a58 : 6100 00fc                : bsr .l +$fc
003a5c : 5379 0000 038e           : subq.w #1,$38e
003a62 : 6a00 ff44                : bpl .l -$bc
003a66 : 6000 00a8                : bra .l +$a8
003a6a : 72f3                     : moveq #-13,d1
003a6c : 0800 0006                : btst #$6,d0
003a70 : 6616                     : bne.s +22
003a72 : 72f8                     : moveq #-8,d1
003a74 : 0800 0004                : btst #$4,d0
003a78 : 660e                     : bne.s +14
003a7a : 72fc                     : moveq #-4,d1
003a7c : 0800 0003                : btst #$3,d0
003a80 : 6706                     : beq.s +6
003a82 : 3239 0000 0382           : move.w $382,d1
003a88 : 33c1 0000 0380           : move.w d1,$380
003a8e : 4e75                     : rts 

003a90 : 4df9 00ff 8606           : lea $ff8606,a6
003a96 : 33c0 0000 0380           : move.w d0,$380
003a9c : 33c0 0000 0382           : move.w d0,$382
003aa2 : 23c8 0000 0398           : move.l a0,$398
003aa8 : 33c1 0000 0384           : move.w d1,$384
003aae : 33c2 0000 0386           : move.w d2,$386
003ab4 : 33c3 0000 038c           : move.w d3,$38c
003aba : 33c4 0000 0388           : move.w d4,$388
003ac0 : 33fc 0002 0000 038e      : move.w #$2,$38e
003ac8 : 4287                     : clr.l d7
003aca : 3e39 0000 038c           : move.w $38c,d7
003ad0 : e14f                     : lsl.w #8,d7
003ad2 : e34f                     : lsl.w #1,d7
003ad4 : 2079 0000 0398           : movea.l $398,a0
003ada : d1c7                     : adda.l d7,a0
003adc : 23c8 0000 0394           : move.l a0,$394
003ae2 : 4a79 0000 038a           : tst.w $38a
003ae8 : 6a24                     : bpl.s +36
003aea : 6100 014c                : bsr .l +$14c
003aee : 4279 0000 038a           : clr.w $38a
003af4 : 6100 00ca                : bsr .l +$ca
003af8 : 6714                     : beq.s +20
003afa : 7e0a                     : moveq #10,d7
003afc : 6140                     : bsr.s +64
003afe : 6606                     : bne.s +6
003b00 : 6100 00be                : bsr .l +$be
003b04 : 6708                     : beq.s +8
003b06 : 33fc ff00 0000 038a      : move.w #$ff00,$38a
003b0e : 4e75                     : rts 

003b10 : 3039 0000 0380           : move.w $380,d0
003b16 : 48c0                     : ext.l d0
003b18 : 6002                     : bra.s +2
003b1a : 4280                     : clr.l d0
003b1c : 2f00                     : move.l d0,-(a7)
003b1e : 3cbc 0086                : move.w #$86,(a6)
003b22 : 3e39 0000 038a           : move.w $38a,d7
003b28 : 6100 0190                : bsr .l +$190
003b2c : 3c3c 0010                : move.w #$10,d6
003b30 : 6100 00aa                : bsr .l +$aa
003b34 : 201f                     : move.l (a7)+,d0
003b36 : 4e75                     : rts 

003b38 : 3e39 0000 0388           : move.w $388,d7
003b3e : 33fc fffa 0000 0380      : move.w #$fffa,$380
003b46 : 3cbc 0086                : move.w #$86,(a6)
003b4a : 6100 016e                : bsr .l +$16e
003b4e : 3c3c 0010                : move.w #$10,d6
003b52 : 6000 0088                : bra .l +$88
003b56 : 33fc fffa 0000 0380      : move.w #$fffa,$380
003b5e : 6160                     : bsr.s +96
003b60 : 6600 ffac                : bne .l -$54
003b64 : 4279 0000 038a           : clr.w $38a
003b6a : 3cbc 0082                : move.w #$82,(a6)
003b6e : 4247                     : clr.w d7
003b70 : 6100 0148                : bsr .l +$148
003b74 : 3cbc 0086                : move.w #$86,(a6)
003b78 : 3e3c 0005                : move.w #$5,d7
003b7c : 6100 013c                : bsr .l +$13c
003b80 : 3c3c 0010                : move.w #$10,d6
003b84 : 6156                     : bsr.s +86
003b86 : 6600 ff86                : bne .l -$7a
003b8a : 33fc 0005 0000 038a      : move.w #$5,$38a
003b92 : 33fc fffa 0000 0380      : move.w #$fffa,$380
003b9a : 3cbc 0086                : move.w #$86,(a6)
003b9e : 3e39 0000 0388           : move.w $388,d7
003ba4 : 6100 0114                : bsr .l +$114
003ba8 : 7c14                     : moveq #20,d6
003baa : 6130                     : bsr.s +48
003bac : 6600 ff60                : bne .l -$a0
003bb0 : 33f9 0000 0388 0000 038a : move.w $388,$38a
003bba : 0247 0018                : andi.w #$18,d7
003bbe : 4e75                     : rts 

003bc0 : 4246                     : clr.w d6
003bc2 : 6118                     : bsr.s +24
003bc4 : 6600 ff48                : bne .l -$b8
003bc8 : 0807 0002                : btst #$2,d7
003bcc : 0a3c 0004                : eori.b #$4,ccr
003bd0 : 6600 ff3c                : bne .l -$c4
003bd4 : 4279 0000 038a           : clr.w $38a
003bda : 4e75                     : rts 

003bdc : 7003                     : moveq #3,d0
003bde : 0200 0003                : andi.b #$3,d0
003be2 : 8c00                     : or.b d0,d6
003be4 : 2e3c 0004 0000           : move.l #$40000,d7
003bea : 3cbc 0080                : move.w #$80,(a6)
003bee : 6100 00de                : bsr .l +$de
003bf2 : 0800 0007                : btst #$7,d0
003bf6 : 6606                     : bne.s +6
003bf8 : 2e3c 0006 0000           : move.l #$60000,d7
003bfe : 6100 00b0                : bsr .l +$b0
003c02 : 5387                     : subq.l #1,d7
003c04 : 6712                     : beq.s +18
003c06 : 0839 0005 00ff fa01      : btst #$5,$fffa01
003c0e : 66f2                     : bne.s -14
003c10 : 6100 00b2                : bsr .l +$b2
003c14 : 4246                     : clr.w d6
003c16 : 4e75                     : rts 

003c18 : 6104                     : bsr.s +4
003c1a : 7c01                     : moveq #1,d6
003c1c : 4e75                     : rts 

003c1e : 3cbc 0080                : move.w #$80,(a6)
003c22 : 3e3c 00d0                : move.w #$d0,d7
003c26 : 6100 0092                : bsr .l +$92
003c2a : 3e3c 000f                : move.w #$f,d7
003c2e : 51cf fffe                : dbra d7,-2
003c32 : 6100 0090                : bsr .l +$90
003c36 : 4e75                     : rts 

003c38 : 3039 0000 0384           : move.w $384,d0
003c3e : 5200                     : addq.b #1,d0
003c40 : e308                     : lsl.b #1,d0
003c42 : 0a00 0007                : eori.b #$7,d0
003c46 : 0200 0007                : andi.b #$7,d0
003c4a : 613e                     : bsr.s +62
003c4c : 3cbc 0082                : move.w #$82,(a6)
003c50 : 3e39 0000 038a           : move.w $38a,d7
003c56 : 6162                     : bsr.s +98
003c58 : 4239 0000 0390           : clr.b $390
003c5e : 3cbc 0084                : move.w #$84,(a6)
003c62 : 3e39 0000 0386           : move.w $386,d7
003c68 : 6150                     : bsr.s +80
003c6a : 13f9 0000 039b 00ff 860d : move.b $39b,$ff860d
003c74 : 13f9 0000 039a 00ff 860b : move.b $39a,$ff860b
003c7e : 13f9 0000 0399 00ff 8609 : move.b $399,$ff8609
003c88 : 4e75                     : rts 

003c8a : 40e7                     : move sr,-(a7)
003c8c : 007c 0700                : ori.w #$700,sr
003c90 : 13fc 000e 00ff 8800      : move.b #$e,$ff8800
003c98 : 1239 00ff 8800           : move.b $ff8800,d1
003c9e : 1401                     : move.b d1,d2
003ca0 : 0201 00f8                : andi.b #$f8,d1
003ca4 : 8200                     : or.b d0,d1
003ca6 : 13c1 00ff 8802           : move.b d1,$ff8802
003cac : 46df                     : move (a7)+,sr
003cae : 4e75                     : rts 

003cb0 : 6124                     : bsr.s +36
003cb2 : 33c6 00ff 8604           : move.w d6,$ff8604
003cb8 : 601c                     : bra.s +28
003cba : 611a                     : bsr.s +26
003cbc : 33c7 00ff 8604           : move.w d7,$ff8604
003cc2 : 6012                     : bra.s +18
003cc4 : 6110                     : bsr.s +16
003cc6 : 3e39 00ff 8604           : move.w $ff8604,d7
003ccc : 6008                     : bra.s +8
003cce : 6106                     : bsr.s +6
003cd0 : 3039 00ff 8604           : move.w $ff8604,d0
003cd6 : 40e7                     : move sr,-(a7)
003cd8 : 3f07                     : move.w d7,-(a7)
003cda : 3e3c 0020                : move.w #$20,d7
003cde : 51cf fffe                : dbra d7,-2
003ce2 : 3e1f                     : move.w (a7)+,d7
003ce4 : 46df                     : move (a7)+,sr
003ce6 : 4e75                     : rts 

003ce8 : 2f2e 0000                : move.l screen.base(a6),-(a7)
003cec : 4280                     : clr.l d0
003cee : 1039 ffff 8201           : move.b $ffff8201,d0
003cf4 : 4840                     : swap d0
003cf6 : 1039 ffff 8203           : move.b $ffff8203,d0
003cfc : e148                     : lsl.w #8,d0
003cfe : 2f00                     : move.l d0,-(a7)
003d00 : 2240                     : movea.l d0,a1
003d02 : d3fc 0000 8000           : adda.l #$8000,a1
003d08 : b3fc 0006 0000           : cmpa.l #$60000,a1
003d0e : 6506                     : bcs.s +6
003d10 : 227c 0001 0000           : movea.l #$10000,a1
003d16 : 2d49 0000                : move.l a1,screen.base(a6)
003d1a : 303c 1f3f                : move.w #$1f3f,d0
003d1e : 4299                     : clr.l (a1)+
003d20 : 51c8 fffc                : dbra d0,-4
003d24 : 41f9 0000 52a0           : lea $52a0,a0
003d2a : ba3c 0001                : cmp.b #$1,d5
003d2e : 6706                     : beq.s +6
003d30 : 41f9 0000 52dd           : lea $52dd,a0
003d36 : 7006                     : moveq #SYS_PRINT,d0
003d38 : 4e44                     : trap #4
003d3a : 2d6e 0000 0056           : move.l screen.base(a6),86(a6)
003d40 : 7000                     : moveq #SYS_SET_VIDEOBASE,d0
003d42 : 4e44                     : trap #4
003d44 : 207c ffff 8240           : movea.l #HW_VIDEO_PALETTE,a0
003d4a : 43f9 0000 4a4c           : lea $4a4c,a1
003d50 : 45f9 0000 40fc           : lea $40fc,a2
003d56 : 7207                     : moveq #7,d1
003d58 : 22d0                     : move.l (a0),(a1)+
003d5a : 20da                     : move.l (a2)+,(a0)+
003d5c : 51c9 fffa                : dbra d1,-6
003d60 : 422e 0063                : clr.b joy.btn(a6)
003d64 : 422e 0064                : clr.b keycode(a6)
003d68 : 7007                     : moveq #SYS_SET_VIDEOBASE,d0
003d6a : 7201                     : moveq #1,d1
003d6c : 4e44                     : trap #4
003d6e : 4a2e 0064                : tst.b keycode(a6)
003d72 : 67f4                     : beq.s -12
003d74 : 2d5f 0056                : move.l (a7)+,86(a6)
003d78 : 2d5f 0000                : move.l (a7)+,screen.base(a6)
003d7c : 7000                     : moveq #SYS_SET_VIDEOBASE,d0
003d7e : 4e44                     : trap #4
003d80 : 207c ffff 8240           : movea.l #HW_VIDEO_PALETTE,a0
003d86 : 43f9 0000 4a4c           : lea $4a4c,a1
003d8c : 7207                     : moveq #7,d1
003d8e : 20d9                     : move.l (a1)+,(a0)+
003d90 : 51c9 fffc                : dbra d1,-4
003d94 : 046e 0001 011a           : subi.w #$1,+$11a(a6)
003d9a : 6000 fa0c                : bra .l -$5f4
//***********************************************************
// START OF DATA AREA
//***********************************************************
003d9e : ffff                     : line-F #$fff
003da0 : ffff                     : line-F #$fff
003da2 : 0000 0000                : ori.b #$0,d0
003da6 : 7fff                     : dc.w $7fff
003da8 : ffff                     : line-F #$fff
003daa : 0000 8000                : ori.b #$0,d0
003dae : 3fff                     : dc.w $3fff
003db0 : ffff                     : line-F #$fff
003db2 : 0000 c000                : ori.b #$0,d0
003db6 : 1fff                     : dc.w $1fff
003db8 : ffff                     : line-F #$fff
003dba : 0000 e000                : ori.b #$0,d0
003dbe : 0fff                     : dc.w $fff
003dc0 : ffff                     : line-F #$fff
003dc2 : 0000 f000                : ori.b #$0,d0
003dc6 : 07ff                     : dc.w $7ff
003dc8 : ffff                     : line-F #$fff
003dca : 0000 f800                : ori.b #$0,d0
003dce : 03ff                     : dc.w $3ff
003dd0 : ffff                     : line-F #$fff
003dd2 : 0000 fc00                : ori.b #$0,d0
003dd6 : 01ff                     : dc.w $1ff
003dd8 : ffff                     : line-F #$fff
003dda : 0000 fe00                : ori.b #$0,d0
003dde : 00ff                     : dc.w $ff
003de0 : ffff                     : line-F #$fff
003de2 : 0000 ff00                : ori.b #$0,d0
003de6 : 007f                     : dc.w $7f
003de8 : ffff                     : line-F #$fff
003dea : 0000 ff80                : ori.b #$80,d0
003dee : 003f                     : dc.w $3f
003df0 : ffff                     : line-F #$fff
003df2 : 0000 ffc0                : ori.b #$c0,d0
003df6 : 001f ffff                : ori.b #$ff,(a7)+
003dfa : 0000 ffe0                : ori.b #$e0,d0
003dfe : 000f                     : dc.w $f
003e00 : ffff                     : line-F #$fff
003e02 : 0000 fff0                : ori.b #$f0,d0
003e06 : 0007 ffff                : ori.b #$ff,d7
003e0a : 0000 fff8                : ori.b #$f8,d0
003e0e : 0003 ffff                : ori.b #$ff,d3
003e12 : 0000 fffc                : ori.b #$fc,d0
003e16 : 0001 ffff                : ori.b #$ff,d1
003e1a : 0000 fffe                : ori.b #$fe,d0
003e1e : 0000 ffff                : ori.b #$ff,d0
003e22 : 0000 ffff                : ori.b #$ff,d0
003e26 : 1557 2aab                : move.b (a7),+$2aab(a2)
003e2a : b80b                     : cmp.b a3,d4
003e2c : 5817                     : addq.b #4,(a7)
003e2e : 55c0                     : scs d0
003e30 : abc0                     : line-A #$bc0
003e32 : c000                     : and.b d0,d0
003e34 : c000                     : and.b d0,d0
003e36 : c000                     : and.b d0,d0
003e38 : c000                     : and.b d0,d0
003e3a : 25a0 36c8                : move.l -(a0),-56(a2,d3.W)
003e3e : 0f28 4b40                : btst d7,+$4b40(a0)
003e42 : 3930 0eb8                : move.w -72(a0,d0.L),-(a4)
003e46 : 3b98 6658                : move.w (a0)+,88(a5,d6.W)
003e4a : 2598 36c0                : move.l (a0)+,-64(a2,d3.W)
003e4e : 0f20                     : btst d7,-(a0)
003e50 : 4b38                     : dc.w $4b38
003e52 : 3928 0eb0                : move.w +$eb0(a0),-(a4)
003e56 : 3b90 6650                : move.w (a0),80(a5,d6.W)
003e5a : 2590 36b8                : move.l (a0),-72(a2,d3.W)
003e5e : 0f18                     : btst d7,(a0)+
003e60 : 4b30                     : dc.w $4b30
003e62 : 3920                     : move.w -(a0),-(a4)
003e64 : 0ea8                     : dc.w $ea8
003e66 : 3b88 6648                : move.w a0,72(a5,d6.W)
003e6a : 2588 36b0                : move.l a0,-80(a2,d3.W)
003e6e : 0f10                     : btst d7,(a0)
003e70 : 4b28                     : dc.w $4b28
003e72 : 3918                     : move.w (a0)+,-(a4)
003e74 : 0ea0                     : dc.w $ea0
003e76 : 3b80 6640                : move.w d0,64(a5,d6.W)
003e7a : 2580 36a8                : move.l d0,-88(a2,d3.W)
003e7e : 0f08 4b20                : movep.w $4b20(a0),d7
003e82 : 3910                     : move.w (a0),-(a4)
003e84 : 0e98                     : dc.w $e98
003e86 : 3b78 6638 25f8           : move.w $6638.W,+$25f8(a5)
003e8c : 36a0                     : move.w -(a0),(a3)
003e8e : 0f00                     : btst d7,d0
003e90 : 4b18                     : dc.w $4b18
003e92 : 3908                     : move.w a0,-(a4)
003e94 : 0e90                     : dc.w $e90
003e96 : 3b70 6630 25f0           : move.w 48(a0,d6.W),+$25f0(a5)
003e9c : 3698                     : move.w (a0)+,(a3)
003e9e : 0f78 4b10                : bchg d7,$4b10.W
003ea2 : 3900                     : move.w d0,-(a4)
003ea4 : 0e88                     : dc.w $e88
003ea6 : 3b68 6628 25e8           : move.w +$6628(a0),+$25e8(a5)
003eac : 3690                     : move.w (a0),(a3)
003eae : 0f70 4b08                : bchg d7,8(a0,d4.L)
003eb2 : 38f8 0e80                : move.w $e80.W,(a4)+
003eb6 : 3b60 6620                : move.w -(a0),+$6620(a5)
003eba : 25e0                     : dc.w $25e0
003ebc : 3688                     : move.w a0,(a3)
003ebe : 0f68 4b00                : bchg d7,+$4b00(a0)
003ec2 : 38f0 0e78                : move.w 120(a0,d0.L),(a4)+
003ec6 : 3bd8                     : dc.w $3bd8
003ec8 : 6618                     : bne.s +24
003eca : 25d8                     : dc.w $25d8
003ecc : 3680                     : move.w d0,(a3)
003ece : 0f60                     : bchg d7,-(a0)
003ed0 : 4b78                     : dc.w $4b78
003ed2 : 38e8 0e70                : move.w +$e70(a0),(a4)+
003ed6 : 3bd0                     : dc.w $3bd0
003ed8 : 6610                     : bne.s +16
003eda : 25d0                     : dc.w $25d0
003edc : 3678 0f58                : movea.w $f58.W,a3
003ee0 : 4b70                     : dc.w $4b70
003ee2 : 38e0                     : move.w -(a0),(a4)+
003ee4 : 0e68                     : dc.w $e68
003ee6 : 3bc8                     : dc.w $3bc8
003ee8 : 6608                     : bne.s +8
003eea : 25c8                     : dc.w $25c8
003eec : 3670 0f50                : movea.w 80(a0,d0.L),a3
003ef0 : 4b68                     : dc.w $4b68
003ef2 : 3958 0e60                : move.w (a0)+,+$e60(a4)
003ef6 : 3bc0                     : dc.w $3bc0
003ef8 : 6600 25c0                : bne .l +$25c0
003efc : 3668 0f48                : movea.w +$f48(a0),a3
003f00 : 4b60                     : dc.w $4b60
003f02 : 3950 0ed8                : move.w (a0),+$ed8(a4)
003f06 : 3bb8 65f8 25b8           : move.w $65f8.W,-72(a5,d2.W)
003f0c : 3660                     : movea.w -(a0),a3
003f0e : 0f40                     : bchg d7,d0
003f10 : 4b58                     : dc.w $4b58
003f12 : 3948 0ed0                : move.w a0,+$ed0(a4)
003f16 : 3bb0 65f0 25b0           : move.w -16(a0,d6.W),-80(a5,d2.W)
003f1c : 36d8                     : move.w (a0)+,(a3)+
003f1e : 0f38 4b50                : btst d7,$4b50.W
003f22 : 3940 0ec8                : move.w d0,+$ec8(a4)
003f26 : 3ba8 65e8 25a8           : move.w +$65e8(a0),-88(a5,d2.W)
003f2c : 36d0                     : move.w (a0),(a3)+
003f2e : 0f30 4b48                : btst d7,72(a0,d4.L)
003f32 : 3938 0ec0                : move.w $ec0.W,-(a4)
003f36 : 3ba0 65e0                : move.w -(a0),-32(a5,d6.W)
KeyboardInit
		dc.w	$ff80
		dc.w	$ff01
		dc.w	$ff08
		dc.w	$ff0b
		dc.w	$ff06
		dc.w	$ff06
		dc.w	$ff07
		dc.w	$ff04
		dc.w	$0000 
003f4c : 0000                : ori.b #$0,d0
003f4e : 0012 0022                : ori.b #$22,(a2)
003f52 : 0123                     : btst d0,-(a3)
003f54 : 0223 0344                : andi.b #$44,-(a3)
003f58 : 0554                     : bchg d2,(a4)
003f5a : 0234 0655 0666           : andi.b #$55,102(a4,d0.W)
003f60 : 0777 0766                : bchg d3,102(a7,d0.W)
003f64 : 0777 0777                : bchg d3,119(a7,d0.W)
003f68 : 0444 0333                : subi.w #$333,d4
003f6c : 0000 0777                : ori.b #$77,d0
003f70 : 0772 0770                : bchg d3,112(a2,d0.W)
003f74 : 0600 0777                : addi.b #$77,d0
003f78 : 0556                     : bchg d2,(a6)
003f7a : 0335 0664                : btst d1,100(a5,d0.W)
003f7e : 0554                     : bchg d2,(a4)
003f80 : 0543                     : bchg d2,d3
003f82 : 0443 0333                : subi.w #$333,d3
003f86 : 0333 0222                : btst d1,34(a3,d0.W)
003f8a : 0222 0777                : andi.b #$77,-(a2)
003f8e : 0771 0760                : bchg d3,96(a1,d0.W)
003f92 : 0730 0610                : btst d3,16(a0,d0.W)
003f96 : 0500                     : btst d2,d0
003f98 : 0300                     : btst d1,d0
003f9a : 0200 0777                : andi.b #$77,d0
003f9e : 0556                     : bchg d2,(a6)
003fa0 : 0446 0335                : subi.w #$335,d6
003fa4 : 0224 0113                : andi.b #$13,-(a4)
003fa8 : 0003 0002                : ori.b #$2,d3
003fac : 0777 0565                : bchg d3,101(a7,d0.W)
003fb0 : 0465 0353                : subi.w #$353,-(a5)
003fb4 : 0242 0131                : andi.w #$131,d2
003fb8 : 0030 0020 0555           : ori.b #$20,85(a0,d0.W)
003fbe : 0000 0233                : ori.b #$33,d0
003fc2 : 0000 0102                : ori.b #$2,d0
003fc6 : 0001 0070                : ori.b #$70,d1
003fca : 0075 0077 0057           : ori.w #$77,87(a5,d0.W)
003fd0 : 0027 0007                : ori.b #$7,-(a7)
003fd4 : 0507                     : btst d2,d7
003fd6 : 0707                     : btst d3,d7
003fd8 : 0704                     : btst d3,d4
003fda : 0777 0000                : bchg d3,0(a7,d0.W)
003fde : 0722                     : btst d3,-(a2)
003fe0 : 0502                     : btst d2,d2
003fe2 : 0300                     : btst d1,d0
003fe4 : 0453 0141                : subi.w #$141,(a3)
003fe8 : 0032 0022 0772           : ori.b #$22,114(a2,d0.W)
003fee : 0650 0430                : addi.w #$430,(a0)
003ff2 : 0000 0200                : ori.b #$0,d0
003ff6 : 0400 0600                : subi.b #$0,d0
003ffa : 0700                     : btst d3,d0
003ffc : 0000 0765                : ori.b #$65,d0
004000 : 0623 0603                : addi.b #$3,-(a3)
004004 : 0355                     : bchg d1,(a5)
004006 : 0135 0013                : btst d0,19(a5,d0.W)
00400a : 0566                     : bchg d2,-(a6)
00400c : 0772 0650                : bchg d3,80(a2,d0.W)
004010 : 0430 0000 0200           : subi.b #$0,0(a0,d0.W)
004016 : 0400 0600                : subi.b #$0,d0
00401a : 0700                     : btst d3,d0
00401c : 0000 0724                : ori.b #$24,d0
004020 : 0700                     : btst d3,d0
004022 : 0400 0654                : subi.b #$54,d0
004026 : 0541                     : bchg d2,d1
004028 : 0430 0210 0772           : subi.b #$10,114(a0,d0.W)
00402e : 0650 0430                : addi.w #$430,(a0)
004032 : 0000 0200                : ori.b #$0,d0
004036 : 0400 0600                : subi.b #$0,d0
00403a : 0700                     : btst d3,d0
00403c : 0000 0460                : ori.b #$60,d0
004040 : 0050 0040                : ori.w #$40,(a0)
004044 : 0741                     : bchg d3,d1
004046 : 0631 0431 0321           : addi.b #$31,33(a1,d0.W)
00404c : 0772 0650                : bchg d3,80(a2,d0.W)
004050 : 0430 0000 0200           : subi.b #$0,0(a0,d0.W)
004056 : 0400 0600                : subi.b #$0,d0
00405a : 0700                     : btst d3,d0
00405c : 0000 0764                : ori.b #$64,d0
004060 : 0320                     : btst d1,-(a0)
004062 : 0420 0530                : subi.b #$30,-(a0)
004066 : 0640 0651                : addi.w #$651,d0
00406a : 0761                     : bchg d3,-(a1)
00406c : 0772 0650                : bchg d3,80(a2,d0.W)
004070 : 0430 0000 0200           : subi.b #$0,0(a0,d0.W)
004076 : 0400 0600                : subi.b #$0,d0
00407a : 0700                     : btst d3,d0
00407c : 0000 0752                : ori.b #$52,d0
004080 : 0731 0631                : btst d3,49(a1,d0.W)
004084 : 0511                     : btst d2,(a1)
004086 : 0510                     : btst d2,(a0)
004088 : 0400 0300                : subi.b #$0,d0
00408c : 0772 0650                : bchg d3,80(a2,d0.W)
004090 : 0430 0000 0200           : subi.b #$0,0(a0,d0.W)
004096 : 0400 0600                : subi.b #$0,d0
00409a : 0700                     : btst d3,d0
00409c : 0000 0500                : ori.b #$0,d0
0040a0 : 0611 0733                : addi.b #$33,(a1)
0040a4 : 0300                     : btst d1,d0
0040a6 : 0766                     : bchg d3,-(a6)
0040a8 : 0531 0640                : btst d2,64(a1,d0.W)
0040ac : 0000 0551                : ori.b #$51,d0
0040b0 : 0322                     : btst d1,-(a2)
0040b2 : 0521                     : btst d2,-(a1)
0040b4 : 0666 0545                : addi.w #$545,-(a6)
0040b8 : 0434 0322 0000           : subi.b #$22,0(a4,d0.W)
0040be : 0742                     : bchg d3,d2
0040c0 : 0610 0500                : addi.b #$0,(a0)
0040c4 : 0646 0535                : addi.w #$535,d6
0040c8 : 0423 0322                : subi.b #$22,-(a3)
0040cc : 0000 0633                : ori.b #$33,d0
0040d0 : 0511                     : btst d2,(a1)
0040d2 : 0300                     : btst d1,d0
0040d4 : 0560                     : bchg d2,-(a0)
0040d6 : 0350                     : bchg d1,(a0)
0040d8 : 0140                     : bchg d0,d0
0040da : 0030 0000 0342           : ori.b #$0,66(a0,d0.W)
0040e0 : 0110                     : btst d0,(a0)
0040e2 : 0221 0331                : andi.b #$31,-(a1)
0040e6 : 0704                     : btst d3,d4
0040e8 : 0453 0464                : subi.w #$464,(a3)
0040ec : 0000 0730                : ori.b #$30,d0
0040f0 : 0620 0500                : addi.b #$0,-(a0)
0040f4 : 0723                     : btst d3,-(a3)
0040f6 : 0613 0402                : addi.b #$2,(a3)
0040fa : 0300                     : btst d1,d0
0040fc : 0000 0000                : ori.b #$0,d0
004100 : 0436 0610 0720           : subi.b #$10,32(a6,d0.W)
004106 : 0741                     : bchg d3,d1
004108 : 0762                     : bchg d3,-(a2)
00410a : 0776 0000                : bchg d3,0(a6,d0.W)
00410e : 0000 0000                : ori.b #$0,d0
004112 : 0000 0677                : ori.b #$77,d0
004116 : 0356                     : bchg d1,(a6)
004118 : 0135 0014                : btst d0,20(a5,d0.W)
00411c : 0000 0000                : ori.b #$0,d0
004120 : 0000 0000                : ori.b #$0,d0
004124 : 0000 0000                : ori.b #$0,d0
004128 : 0000 0000                : ori.b #$0,d0
00412c : 0000 0000                : ori.b #$0,d0
004130 : 0000 0000                : ori.b #$0,d0
004134 : 0000 0000                : ori.b #$0,d0
004138 : 0000 0000                : ori.b #$0,d0
00413c : 0111                     : btst d0,(a1)
00413e : 0022 0221                : ori.b #$21,-(a2)
004142 : 0000 0677                : ori.b #$77,d0
004146 : 035c                     : bchg d1,(a4)+
004148 : 0135 0014                : btst d0,20(a5,d0.W)
00414c : 0111                     : btst d0,(a1)
00414e : 0022 0221                : ori.b #$21,-(a2)
004152 : 0000 0770                : ori.b #$70,d0
004156 : 0650 0531                : addi.w #$531,(a0)
00415a : 0400 0111                : subi.b #$11,d0
00415e : 0022 0221                : ori.b #$21,-(a2)
004162 : 0000 0770                : ori.b #$70,d0
004166 : 0650 0531                : addi.w #$531,(a0)
00416a : 0400 0111                : subi.b #$11,d0
00416e : 0022 0221                : ori.b #$21,-(a2)
004172 : 0000 0674                : ori.b #$74,d0
004176 : 0770 0740                : bchg d3,64(a0,d0.W)
00417a : 0611 0111                : addi.b #$11,(a1)
00417e : 0022 0221                : ori.b #$21,-(a2)
004182 : 0000 0770                : ori.b #$70,d0
004186 : 0650 0531                : addi.w #$531,(a0)
00418a : 0400 0111                : subi.b #$11,d0
00418e : 0022 0221                : ori.b #$21,-(a2)
004192 : 0000 0473                : ori.b #$73,d0
004196 : 0350                     : bchg d1,(a0)
004198 : 0600 0230                : addi.b #$30,d0
00419c : 0111                     : btst d0,(a1)
00419e : 0022 0221                : ori.b #$21,-(a2)
0041a2 : 0667 0447                : addi.w #$447,-(a7)
0041a6 : 0234 0124 0112           : andi.b #$24,18(a4,d0.W)
0041ac : 0111                     : btst d0,(a1)
0041ae : 0022 0221                : ori.b #$21,-(a2)
0041b2 : 0776 0771                : bchg d3,113(a6,d0.W)
0041b6 : 0674 0563 0452           : addi.w #$563,82(a4,d0.W)
0041bc : 0111                     : btst d0,(a1)
0041be : 0022 0221                : ori.b #$21,-(a2)
0041c2 : 0776 0750                : bchg d3,80(a6,d0.W)
0041c6 : 0730 0710                : btst d3,16(a0,d0.W)
0041ca : 0700                     : btst d3,d0
0041cc : 0111                     : btst d0,(a1)
0041ce : 0022 0221                : ori.b #$21,-(a2)
0041d2 : 0733 0453                : btst d3,83(a3,d0.W)
0041d6 : 0142                     : bchg d0,d2
0041d8 : 0132 0311                : btst d0,17(a2,d0.W)
0041dc : 0111                     : btst d0,(a1)
0041de : 0022 0221                : ori.b #$21,-(a2)
0041e2 : 0733 0453                : btst d3,83(a3,d0.W)
0041e6 : 0141                     : bchg d0,d1
0041e8 : 0032 0300 0111           : ori.b #$0,17(a2,d0.W)
0041ee : 0022 0221                : ori.b #$21,-(a2)
0041f2 : 0733 0453                : btst d3,83(a3,d0.W)
0041f6 : 0141                     : bchg d0,d1
0041f8 : 0032 0300 0111           : ori.b #$0,17(a2,d0.W)
0041fe : 0022 0221                : ori.b #$21,-(a2)
004202 : 0733 0453                : btst d3,83(a3,d0.W)
004206 : 0141                     : bchg d0,d1
004208 : 0032 0300 0111           : ori.b #$0,17(a2,d0.W)
00420e : 0022 0221                : ori.b #$21,-(a2)
004212 : 0542                     : bchg d2,d2
004214 : 0665 0600                : addi.w #$600,-(a5)
004218 : 0421 0300                : subi.b #$0,-(a1)
00421c : 0111                     : btst d0,(a1)
00421e : 0022 0221                : ori.b #$21,-(a2)
004222 : 0646 0525                : addi.w #$525,d6
004226 : 0007 0413                : ori.b #$13,d7
00422a : 0302                     : btst d1,d2
00422c : 0111                     : btst d0,(a1)
00422e : 0022 0221                : ori.b #$21,-(a2)
004232 : 0700                     : btst d3,d0
004234 : 0544                     : bchg d2,d4
004236 : 0530 0411                : btst d2,17(a0,d0.W)
00423a : 0311                     : btst d1,(a1)
00423c : 0111                     : btst d0,(a1)
00423e : 0022 0221                : ori.b #$21,-(a2)
004242 : 0700                     : btst d3,d0
004244 : 0544                     : bchg d2,d4
004246 : 0530 0411                : btst d2,17(a0,d0.W)
00424a : 0311                     : btst d1,(a1)
00424c : 0111                     : btst d0,(a1)
00424e : 0022 0221                : ori.b #$21,-(a2)
004252 : 0700                     : btst d3,d0
004254 : 0544                     : bchg d2,d4
004256 : 0530 0411                : btst d2,17(a0,d0.W)
00425a : 0311                     : btst d1,(a1)
00425c : 0000 0000                : ori.b #$0,d0
004260 : 0000 0000                : ori.b #$0,d0
004264 : 0000 0000                : ori.b #$0,d0
004268 : 0000 0000                : ori.b #$0,d0
00426c : 0000 0000                : ori.b #$0,d0
004270 : 0000 0000                : ori.b #$0,d0
004274 : 0000 0000                : ori.b #$0,d0
004278 : 0000 0000                : ori.b #$0,d0
00427c : 0000 0000                : ori.b #$0,d0
004280 : 0000 0000                : ori.b #$0,d0
004284 : 0000 0000                : ori.b #$0,d0
004288 : 0000 0000                : ori.b #$0,d0
00428c : 0000 0000                : ori.b #$0,d0
004290 : 0000 0000                : ori.b #$0,d0
004294 : 0000 0000                : ori.b #$0,d0
004298 : 0000 0000                : ori.b #$0,d0
00429c : 0000 0000                : ori.b #$0,d0
0042a0 : 0000 0000                : ori.b #$0,d0
0042a4 : 0000 0000                : ori.b #$0,d0
0042a8 : 0000 0000                : ori.b #$0,d0
0042ac : 0000 0000                : ori.b #$0,d0
0042b0 : 0000 0000                : ori.b #$0,d0
0042b4 : 0000 0000                : ori.b #$0,d0
0042b8 : 0000 0000                : ori.b #$0,d0
0042bc : 0013 0000                : ori.b #$0,(a3)
0042c0 : 0002 0003                : ori.b #$3,d2
0042c4 : 0677 0356 0135           : addi.w #$356,53(a7,d0.W)
0042ca : 0014 0013                : ori.b #$13,(a4)
0042ce : 0000 0002                : ori.b #$2,d0
0042d2 : 0003 0367                : ori.b #$67,d3
0042d6 : 0567                     : bchg d2,-(a7)
0042d8 : 0677 0777 0013           : addi.w #$777,19(a7,d0.W)
0042de : 0000 0002                : ori.b #$2,d0
0042e2 : 0003 0664                : ori.b #$64,d3
0042e6 : 0640 0721                : addi.w #$721,d0
0042ea : 0600 0013                : addi.b #$13,d0
0042ee : 0000 0002                : ori.b #$2,d0
0042f2 : 0003 0776                : ori.b #$76,d3
0042f6 : 0772 0731                : bchg d3,49(a2,d0.W)
0042fa : 0600 0013                : addi.b #$13,d0
0042fe : 0000 0002                : ori.b #$2,d0
004302 : 0003 0664                : ori.b #$64,d3
004306 : 0640 0721                : addi.w #$721,d0
00430a : 0600 0013                : addi.b #$13,d0
00430e : 0000 0002                : ori.b #$2,d0
004312 : 0003 0770                : ori.b #$70,d3
004316 : 0465 0245                : subi.w #$245,-(a5)
00431a : 0133 0013                : btst d0,19(a3,d0.W)
00431e : 0000 0002                : ori.b #$2,d0
004322 : 0003 0066                : ori.b #$66,d3
004326 : 0156                     : bchg d0,(a6)
004328 : 0136 0125                : btst d0,37(a6,d0.W)
00432c : 0013 0000                : ori.b #$0,(a3)
004330 : 0002 0003                : ori.b #$3,d2
004334 : 0456 0234                : subi.w #$234,(a6)
004338 : 0630 0510 0013           : addi.b #$10,19(a0,d0.W)
00433e : 0000 0002                : ori.b #$2,d0
004342 : 0003 0456                : ori.b #$56,d3
004346 : 0234 0630 0510           : andi.b #$30,16(a4,d0.W)
00434c : 0013 0000                : ori.b #$0,(a3)
004350 : 0002 0003                : ori.b #$3,d2
004354 : 0777 0455                : bchg d3,85(a7,d0.W)
004358 : 0244 0032                : andi.w #$32,d4
00435c : 0013 0000                : ori.b #$0,(a3)
004360 : 0002 0003                : ori.b #$3,d2
004364 : 0676 0363 0151           : addi.w #$363,81(a6,d0.W)
00436a : 0030 0013 0000           : ori.b #$13,0(a0,d0.W)
004370 : 0002 0003                : ori.b #$3,d2
004374 : 0766                     : bchg d3,-(a6)
004376 : 0443 0442                : subi.w #$442,d3
00437a : 0331 0013                : btst d1,19(a1,d0.W)
00437e : 0000 0002                : ori.b #$2,d0
004382 : 0003 0557                : ori.b #$57,d3
004386 : 0446 0335                : subi.w #$335,d6
00438a : 0324                     : btst d1,-(a4)
00438c : 0013 0000                : ori.b #$0,(a3)
004390 : 0002 0003                : ori.b #$3,d2
004394 : 0676 0464 0363           : addi.w #$464,99(a6,d0.W)
00439a : 0252 0013                : andi.w #$13,(a2)
00439e : 0000 0002                : ori.b #$2,d0
0043a2 : 0003 0456                : ori.b #$56,d3
0043a6 : 0345                     : bchg d1,d5
0043a8 : 0234 0012 0013           : andi.b #$12,19(a4,d0.W)
0043ae : 0000 0002                : ori.b #$2,d0
0043b2 : 0003 0456                : ori.b #$56,d3
0043b6 : 0345                     : bchg d1,d5
0043b8 : 0234 0012 0013           : andi.b #$12,19(a4,d0.W)
0043be : 0000 0002                : ori.b #$2,d0
0043c2 : 0003 0456                : ori.b #$56,d3
0043c6 : 0345                     : bchg d1,d5
0043c8 : 0234 0012 0013           : andi.b #$12,19(a4,d0.W)
0043ce : 0000 0002                : ori.b #$2,d0
0043d2 : 0003 0456                : ori.b #$56,d3
0043d6 : 0345                     : bchg d1,d5
0043d8 : 0234 0012 0000           : andi.b #$12,0(a4,d0.W)
0043de : 0000 0000                : ori.b #$0,d0
0043e2 : 0000 0000                : ori.b #$0,d0
0043e6 : 0000 0000                : ori.b #$0,d0
0043ea : 0000 0000                : ori.b #$0,d0
0043ee : 0000 0000                : ori.b #$0,d0
0043f2 : 0000 0000                : ori.b #$0,d0
0043f6 : 0000 0000                : ori.b #$0,d0
0043fa : 0000 0000                : ori.b #$0,d0
0043fe : 0000 0000                : ori.b #$0,d0
004402 : 0000 0000                : ori.b #$0,d0
004406 : 0000 0000                : ori.b #$0,d0
00440a : 0000 0000                : ori.b #$0,d0
00440e : 0000 0000                : ori.b #$0,d0
004412 : 0000 0000                : ori.b #$0,d0
004416 : 0000 0000                : ori.b #$0,d0
00441a : 0000 0000                : ori.b #$0,d0
00441e : 0000 0000                : ori.b #$0,d0
004422 : 0000 0000                : ori.b #$0,d0
004426 : 0000 0000                : ori.b #$0,d0
00442a : 0000 0000                : ori.b #$0,d0
00442e : 0000 0000                : ori.b #$0,d0
004432 : 0000 0000                : ori.b #$0,d0
004436 : 0000 0000                : ori.b #$0,d0
00443a : 0000 0300                : ori.b #$0,d0
00443e : 0403 0300                : subi.b #$0,d3
004442 : 0000 0677                : ori.b #$77,d0
004446 : 0356                     : bchg d1,(a6)
004448 : 0135 0014                : btst d0,20(a5,d0.W)
00444c : 0300                     : btst d1,d0
00444e : 0403 0300                : subi.b #$0,d3
004452 : 0000 0367                : ori.b #$67,d0
004456 : 0567                     : bchg d2,-(a7)
004458 : 0677 0777 0300           : addi.w #$777,0(a7,d0.W)
00445e : 0403 0300                : subi.b #$0,d3
004462 : 0750                     : bchg d3,(a0)
004464 : 0740                     : bchg d3,d0
004466 : 0620 0510                : addi.b #$10,-(a0)
00446a : 0400 0300                : subi.b #$0,d0
00446e : 0403 0300                : subi.b #$0,d3
004472 : 0000 0776                : ori.b #$76,d0
004476 : 0772 0731                : bchg d3,49(a2,d0.W)
00447a : 0600 0300                : addi.b #$0,d0
00447e : 0403 0300                : subi.b #$0,d3
004482 : 0070 0507 0407           : ori.w #$507,7(a0,d0.W)
004488 : 0307                     : btst d1,d7
00448a : 0207 0300                : andi.b #$0,d7
00448e : 0403 0300                : subi.b #$0,d3
004492 : 0600 0654                : addi.b #$54,d0
004496 : 0541                     : bchg d2,d1
004498 : 0430 0210 0300           : subi.b #$10,0(a0,d0.W)
00449e : 0403 0300                : subi.b #$0,d3
0044a2 : 0600 0654                : addi.b #$54,d0
0044a6 : 0541                     : bchg d2,d1
0044a8 : 0430 0210 0300           : subi.b #$10,0(a0,d0.W)
0044ae : 0403 0300                : subi.b #$0,d3
0044b2 : 0600 0654                : addi.b #$54,d0
0044b6 : 0541                     : bchg d2,d1
0044b8 : 0430 0210 0300           : subi.b #$10,0(a0,d0.W)
0044be : 0403 0300                : subi.b #$0,d3
0044c2 : 0600 0654                : addi.b #$54,d0
0044c6 : 0541                     : bchg d2,d1
0044c8 : 0430 0210 0300           : subi.b #$10,0(a0,d0.W)
0044ce : 0403 0300                : subi.b #$0,d3
0044d2 : 0400 0763                : subi.b #$63,d0
0044d6 : 0652 0531                : addi.w #$531,(a2)
0044da : 0321                     : btst d1,-(a1)
0044dc : 0300                     : btst d1,d0
0044de : 0403 0300                : subi.b #$0,d3
0044e2 : 0710                     : btst d3,(a0)
0044e4 : 0274 0361 0150           : andi.w #$361,80(a4,d0.W)
0044ea : 0030 0300 0403           : ori.b #$0,3(a0,d0.W)
0044f0 : 0300                     : btst d1,d0
0044f2 : 0700                     : btst d3,d0
0044f4 : 0463 0252                : subi.w #$252,-(a3)
0044f8 : 0132 0022                : btst d0,34(a2,d0.W)
0044fc : 0300                     : btst d1,d0
0044fe : 0403 0300                : subi.b #$0,d3
004502 : 0600 0364                : addi.b #$64,d0
004506 : 0254 0144                : andi.w #$144,(a4)
00450a : 0023 0300                : ori.b #$0,-(a3)
00450e : 0403 0300                : subi.b #$0,d3
004512 : 0740                     : bchg d3,d0
004514 : 0557                     : bchg d2,(a7)
004516 : 0327                     : btst d1,-(a7)
004518 : 0316                     : btst d1,(a6)
00451a : 0215 0300                : andi.b #$0,(a5)
00451e : 0403 0300                : subi.b #$0,d3
004522 : 0750                     : bchg d3,(a0)
004524 : 0740                     : bchg d3,d0
004526 : 0620 0510                : addi.b #$10,-(a0)
00452a : 0400 0300                : subi.b #$0,d0
00452e : 0403 0300                : subi.b #$0,d3
004532 : 0750                     : bchg d3,(a0)
004534 : 0740                     : bchg d3,d0
004536 : 0620 0510                : addi.b #$10,-(a0)
00453a : 0400 0300                : subi.b #$0,d0
00453e : 0403 0300                : subi.b #$0,d3
004542 : 0750                     : bchg d3,(a0)
004544 : 0740                     : bchg d3,d0
004546 : 0620 0510                : addi.b #$10,-(a0)
00454a : 0400 0300                : subi.b #$0,d0
00454e : 0403 0300                : subi.b #$0,d3
004552 : 0750                     : bchg d3,(a0)
004554 : 0740                     : bchg d3,d0
004556 : 0620 0510                : addi.b #$10,-(a0)
00455a : 0400 0300                : subi.b #$0,d0
00455e : 0403 0300                : subi.b #$0,d3
004562 : 0750                     : bchg d3,(a0)
004564 : 0740                     : bchg d3,d0
004566 : 0620 0510                : addi.b #$10,-(a0)
00456a : 0400 0300                : subi.b #$0,d0
00456e : 0403 0300                : subi.b #$0,d3
004572 : 0750                     : bchg d3,(a0)
004574 : 0740                     : bchg d3,d0
004576 : 0620 0510                : addi.b #$10,-(a0)
00457a : 0400 0300                : subi.b #$0,d0
00457e : 0403 0300                : subi.b #$0,d3
004582 : 0750                     : bchg d3,(a0)
004584 : 0740                     : bchg d3,d0
004586 : 0620 0510                : addi.b #$10,-(a0)
00458a : 0400 0300                : subi.b #$0,d0
00458e : 0403 0300                : subi.b #$0,d3
004592 : 0750                     : bchg d3,(a0)
004594 : 0740                     : bchg d3,d0
004596 : 0620 0510                : addi.b #$10,-(a0)
00459a : 0400 0300                : subi.b #$0,d0
00459e : 0403 0300                : subi.b #$0,d3
0045a2 : 0750                     : bchg d3,(a0)
0045a4 : 0740                     : bchg d3,d0
0045a6 : 0620 0510                : addi.b #$10,-(a0)
0045aa : 0400 0300                : subi.b #$0,d0
0045ae : 0403 0300                : subi.b #$0,d3
0045b2 : 0750                     : bchg d3,(a0)
0045b4 : 0740                     : bchg d3,d0
0045b6 : 0620 0510                : addi.b #$10,-(a0)
0045ba : 0400 0000                : subi.b #$0,d0
0045be : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
0045c4 : 0677 0356 0135           : addi.w #$356,53(a7,d0.W)
0045ca : 0014 0000                : ori.b #$0,(a4)
0045ce : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
0045d4 : 0000 0000                : ori.b #$0,d0
0045d8 : 0000 0000                : ori.b #$0,d0
0045dc : 0000 0030                : ori.b #$30,d0
0045e0 : 0020 0020                : ori.b #$20,-(a0)
0045e4 : 0747                     : bchg d3,d7
0045e6 : 0517                     : btst d2,(a7)
0045e8 : 0405 0204                : subi.b #$4,d5
0045ec : 0000 0030                : ori.b #$30,d0
0045f0 : 0020 0020                : ori.b #$20,-(a0)
0045f4 : 0750                     : bchg d3,(a0)
0045f6 : 0730 0610                : btst d3,16(a0,d0.W)
0045fa : 0500                     : btst d2,d0
0045fc : 0000 0030                : ori.b #$30,d0
004600 : 0020 0020                : ori.b #$20,-(a0)
004604 : 0747                     : bchg d3,d7
004606 : 0517                     : btst d2,(a7)
004608 : 0405 0204                : subi.b #$4,d5
00460c : 0000 0030                : ori.b #$30,d0
004610 : 0020 0020                : ori.b #$20,-(a0)
004614 : 0450 0140                : subi.w #$140,(a0)
004618 : 0030 0510 0000           : ori.b #$10,0(a0,d0.W)
00461e : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
004624 : 0570 0060                : bchg d2,96(a0,d0.W)
004628 : 0052 0032                : ori.w #$32,(a2)
00462c : 0000 0030                : ori.b #$30,d0
004630 : 0020 0020                : ori.b #$20,-(a0)
004634 : 0067 0037                : ori.w #$37,-(a7)
004638 : 0007 0600                : ori.b #$0,d7
00463c : 0000 0030                : ori.b #$30,d0
004640 : 0020 0020                : ori.b #$20,-(a0)
004644 : 0765                     : bchg d3,-(a5)
004646 : 0653 0542                : addi.w #$542,(a3)
00464a : 0330 0000                : btst d1,0(a0,d0.W)
00464e : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
004654 : 0765                     : bchg d3,-(a5)
004656 : 0653 0542                : addi.w #$542,(a3)
00465a : 0330 0000                : btst d1,0(a0,d0.W)
00465e : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
004664 : 0756                     : bchg d3,(a6)
004666 : 0653 0542                : addi.w #$542,(a3)
00466a : 0330 0000                : btst d1,0(a0,d0.W)
00466e : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
004674 : 0744                     : bchg d3,d4
004676 : 0542                     : bchg d2,d2
004678 : 0431 0320 0000           : subi.b #$20,0(a1,d0.W)
00467e : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
004684 : 0060 0700                : ori.w #$700,-(a0)
004688 : 0500                     : btst d2,d0
00468a : 0400 0000                : subi.b #$0,d0
00468e : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
004694 : 0737 0606                : btst d3,6(a7,d0.W)
004698 : 0504                     : btst d2,d4
00469a : 0403 0000                : subi.b #$0,d3
00469e : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
0046a4 : 0665 0452                : addi.w #$452,-(a5)
0046a8 : 0440 0320                : subi.w #$320,d0
0046ac : 0000 0030                : ori.b #$30,d0
0046b0 : 0020 0020                : ori.b #$20,-(a0)
0046b4 : 0665 0452                : addi.w #$452,-(a5)
0046b8 : 0440 0320                : subi.w #$320,d0
0046bc : 0000 0030                : ori.b #$30,d0
0046c0 : 0020 0020                : ori.b #$20,-(a0)
0046c4 : 0060 0700                : ori.w #$700,-(a0)
0046c8 : 0500                     : btst d2,d0
0046ca : 0400 0000                : subi.b #$0,d0
0046ce : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
0046d4 : 0067 0037                : ori.w #$37,-(a7)
0046d8 : 0007 0600                : ori.b #$0,d7
0046dc : 0000 0000                : ori.b #$0,d0
0046e0 : 0000 0000                : ori.b #$0,d0
0046e4 : 0000 0000                : ori.b #$0,d0
0046e8 : 0000 0000                : ori.b #$0,d0
0046ec : 0000 0000                : ori.b #$0,d0
0046f0 : 0000 0000                : ori.b #$0,d0
0046f4 : 0000 0000                : ori.b #$0,d0
0046f8 : 0000 0000                : ori.b #$0,d0
0046fc : 0000 0000                : ori.b #$0,d0
004700 : 0000 0000                : ori.b #$0,d0
004704 : 0000 0000                : ori.b #$0,d0
004708 : 0000 0000                : ori.b #$0,d0
00470c : 0000 0000                : ori.b #$0,d0
004710 : 0000 0000                : ori.b #$0,d0
004714 : 0000 0000                : ori.b #$0,d0
004718 : 0000 0000                : ori.b #$0,d0
00471c : 0000 0000                : ori.b #$0,d0
004720 : 0000 0000                : ori.b #$0,d0
004724 : 0000 0000                : ori.b #$0,d0
004728 : 0000 0000                : ori.b #$0,d0
00472c : 0000 0000                : ori.b #$0,d0
004730 : 0000 0000                : ori.b #$0,d0
004734 : 0000 0000                : ori.b #$0,d0
004738 : 0000 0000                : ori.b #$0,d0
00473c : 0000 0030                : ori.b #$30,d0
004740 : 0020 0020                : ori.b #$20,-(a0)
004744 : 0677 0356 0135           : addi.w #$356,53(a7,d0.W)
00474a : 0014 0000                : ori.b #$0,(a4)
00474e : 0030 0020 0020           : ori.b #$20,32(a0,d0.W)
004754 : 0747                     : bchg d3,d7
004756 : 0517                     : btst d2,(a7)
004758 : 0405 0204                : subi.b #$4,d5
00475c : 0000 0030                : ori.b #$30,d0
004760 : 0020 0041                : ori.b #$41,-(a0)
004764 : 0075 0447 0227           : ori.w #$447,39(a5,d0.W)
00476a : 0005 0000                : ori.b #$0,d5
00476e : 0030 0020 0444           : ori.b #$20,68(a0,d0.W)
004774 : 0777 0771                : bchg d3,113(a7,d0.W)
004778 : 0710                     : btst d3,(a0)
00477a : 0500                     : btst d2,d0
00477c : 0000 0030                : ori.b #$30,d0
004780 : 0020 0510                : ori.b #$10,-(a0)
004784 : 0741                     : bchg d3,d1
004786 : 0621 0500                : addi.b #$0,-(a1)
00478a : 0410 0000                : subi.b #$0,(a0)
00478e : 0030 0020 0510           : ori.b #$20,16(a0,d0.W)
004794 : 0741                     : bchg d3,d1
004796 : 0621 0500                : addi.b #$0,-(a1)
00479a : 0410 0000                : subi.b #$0,(a0)
00479e : 0030 0020 0320           : ori.b #$20,32(a0,d0.W)
0047a4 : 0763                     : bchg d3,-(a3)
0047a6 : 0651 0540                : addi.w #$540,(a1)
0047aa : 0430 0000 0030           : subi.b #$0,48(a0,d0.W)
0047b0 : 0020 0631                : ori.b #$31,-(a0)
0047b4 : 0764                     : bchg d3,-(a4)
0047b6 : 0752                     : bchg d3,(a2)
0047b8 : 0620 0410                : addi.b #$10,-(a0)
0047bc : 0000 0030                : ori.b #$30,d0
0047c0 : 0020 0470                : ori.b #$70,-(a0)
0047c4 : 0722                     : btst d3,-(a2)
0047c6 : 0711                     : btst d3,(a1)
0047c8 : 0602 0401                : addi.b #$1,d2
0047cc : 0000 0030                : ori.b #$30,d0
0047d0 : 0020 0041                : ori.b #$41,-(a0)
0047d4 : 0075 0447 0227           : ori.w #$447,39(a5,d0.W)
0047da : 0005 0000                : ori.b #$0,d5
0047de : 0030 0020 0251           : ori.b #$20,81(a0,d0.W)
0047e4 : 0474 0362 0130           : subi.w #$362,48(a4,d0.W)
0047ea : 0020 0000                : ori.b #$0,-(a0)
0047ee : 0030 0020 0710           : ori.b #$20,16(a0,d0.W)
0047f4 : 0762                     : bchg d3,-(a2)
0047f6 : 0760                     : bchg d3,-(a0)
0047f8 : 0740                     : bchg d3,d0
0047fa : 0500                     : btst d2,d0
0047fc : 0000 0030                : ori.b #$30,d0
004800 : 0020 0223                : ori.b #$23,-(a0)
004804 : 0777 0655                : bchg d3,85(a7,d0.W)
004808 : 0444 0122                : subi.w #$122,d4
00480c : 0000 0030                : ori.b #$30,d0
004810 : 0020 0770                : ori.b #$70,-(a0)
004814 : 0750                     : bchg d3,(a0)
004816 : 0730 0600                : btst d3,0(a0,d0.W)
00481a : 0400 0000                : subi.b #$0,d0
00481e : 0000 0000                : ori.b #$0,d0
004822 : 0000 0000                : ori.b #$0,d0
004826 : 0000 0000                : ori.b #$0,d0
00482a : 0000 0000                : ori.b #$0,d0
00482e : 0000 0000                : ori.b #$0,d0
004832 : 0000 0000                : ori.b #$0,d0
004836 : 0000 0000                : ori.b #$0,d0
00483a : 0000 0000                : ori.b #$0,d0
00483e : 0000 0000                : ori.b #$0,d0
004842 : 0000 0000                : ori.b #$0,d0
004846 : 0000 0000                : ori.b #$0,d0
00484a : 0000 0000                : ori.b #$0,d0
00484e : 0000 0000                : ori.b #$0,d0
004852 : 0000 0000                : ori.b #$0,d0
004856 : 0000 0000                : ori.b #$0,d0
00485a : 0000 0000                : ori.b #$0,d0
00485e : 0000 0000                : ori.b #$0,d0
004862 : 0000 0000                : ori.b #$0,d0
004866 : 0000 0000                : ori.b #$0,d0
00486a : 0000 0000                : ori.b #$0,d0
00486e : 0000 0000                : ori.b #$0,d0
004872 : 0000 0000                : ori.b #$0,d0
004876 : 0000 0000                : ori.b #$0,d0
00487a : 0000 0000                : ori.b #$0,d0
00487e : 0000 0000                : ori.b #$0,d0
004882 : 0000 0000                : ori.b #$0,d0
004886 : 0000 0000                : ori.b #$0,d0
00488a : 0000 0000                : ori.b #$0,d0
00488e : 0000 0000                : ori.b #$0,d0
004892 : 0000 0000                : ori.b #$0,d0
004896 : 0000 0000                : ori.b #$0,d0
00489a : 0000 0000                : ori.b #$0,d0
00489e : 0000 0000                : ori.b #$0,d0
0048a2 : 0000 0000                : ori.b #$0,d0
0048a6 : 0000 0000                : ori.b #$0,d0
0048aa : 0000 0000                : ori.b #$0,d0
0048ae : 0000 0000                : ori.b #$0,d0
0048b2 : 0000 0000                : ori.b #$0,d0
0048b6 : 0000 0000                : ori.b #$0,d0
0048ba : 0000 0012                : ori.b #$12,d0
0048be : 0001 0000                : ori.b #$0,d1
0048c2 : 0000 0677                : ori.b #$77,d0
0048c6 : 0356                     : bchg d1,(a6)
0048c8 : 0135 0014                : btst d0,20(a5,d0.W)
0048cc : 0012 0001                : ori.b #$1,(a2)
0048d0 : 0430 0220 0766           : subi.b #$20,102(a0,d0.W)
0048d6 : 0730 0620                : btst d3,32(a0,d0.W)
0048da : 0500                     : btst d2,d0
0048dc : 0012 0001                : ori.b #$1,(a2)
0048e0 : 0000 0220                : ori.b #$20,d0
0048e4 : 0766                     : bchg d3,-(a6)
0048e6 : 0730 0620                : btst d3,32(a0,d0.W)
0048ea : 0410 0012                : subi.b #$12,(a0)
0048ee : 0001 0430                : ori.b #$30,d1
0048f2 : 0000 0777                : ori.b #$77,d0
0048f6 : 0770 0730                : bchg d3,48(a0,d0.W)
0048fa : 0600 0012                : addi.b #$12,d0
0048fe : 0001 0700                : ori.b #$0,d1
004902 : 0220 0766                : andi.b #$66,-(a0)
004906 : 0720                     : btst d3,-(a0)
004908 : 0620 0400                : addi.b #$0,-(a0)
00490c : 0012 0001                : ori.b #$1,(a2)
004910 : 0410 0600                : subi.b #$0,(a0)
004914 : 0260 0251                : andi.w #$251,-(a0)
004918 : 0140                     : bchg d0,d0
00491a : 0020 0012                : ori.b #$12,-(a0)
00491e : 0001 0600                : ori.b #$0,d1
004922 : 0420 0553                : subi.b #$53,-(a0)
004926 : 0542                     : bchg d2,d2
004928 : 0431 0310 0012           : subi.b #$10,18(a1,d0.W)
00492e : 0001 0600                : ori.b #$0,d1
004932 : 0600 0777                : addi.b #$77,d0
004936 : 0566                     : bchg d2,-(a6)
004938 : 0345                     : bchg d1,d5
00493a : 0123                     : btst d0,-(a3)
00493c : 0012 0001                : ori.b #$1,(a2)
004940 : 0500                     : btst d2,d0
004942 : 0400 0654                : subi.b #$54,d0
004946 : 0643 0431                : addi.w #$431,d3
00494a : 0320                     : btst d1,-(a0)
00494c : 0012 0001                : ori.b #$1,(a2)
004950 : 0500                     : btst d2,d0
004952 : 0500                     : btst d2,d0
004954 : 0375 0262                : bchg d1,98(a5,d0.W)
004958 : 0240 0220                : andi.w #$220,d0
00495c : 0012 0001                : ori.b #$1,(a2)
004960 : 0500                     : btst d2,d0
004962 : 0500                     : btst d2,d0
004964 : 0375 0262                : bchg d1,98(a5,d0.W)
004968 : 0240 0220                : andi.w #$220,d0
00496c : 0012 0001                : ori.b #$1,(a2)
004970 : 0760                     : bchg d3,-(a0)
004972 : 0500                     : btst d2,d0
004974 : 0375 0262                : bchg d1,98(a5,d0.W)
004978 : 0240 0220                : andi.w #$220,d0
00497c : 0012 0001                : ori.b #$1,(a2)
004980 : 0760                     : bchg d3,-(a0)
004982 : 0760                     : bchg d3,-(a0)
004984 : 0375 0154                : bchg d1,84(a5,d0.W)
004988 : 0033 0210 0012           : ori.b #$10,18(a3,d0.W)
00498e : 0001 0750                : ori.b #$50,d1
004992 : 0760                     : bchg d3,-(a0)
004994 : 0375 0154                : bchg d1,84(a5,d0.W)
004998 : 0033 0210 0012           : ori.b #$10,18(a3,d0.W)
00499e : 0001 0600                : ori.b #$0,d1
0049a2 : 0750                     : bchg d3,(a0)
0049a4 : 0777 0635                : bchg d3,53(a7,d0.W)
0049a8 : 0520                     : btst d2,-(a0)
0049aa : 0514                     : btst d2,(a4)
0049ac : 0012 0001                : ori.b #$1,(a2)
0049b0 : 0600 0600                : addi.b #$0,d0
0049b4 : 0777 0566                : bchg d3,102(a7,d0.W)
0049b8 : 0345                     : bchg d1,d5
0049ba : 0123                     : btst d0,-(a3)
0049bc : 0000 0000                : ori.b #$0,d0
0049c0 : 0000 0000                : ori.b #$0,d0
0049c4 : 0000 0000                : ori.b #$0,d0
0049c8 : 0000 0000                : ori.b #$0,d0
0049cc : 0000 0000                : ori.b #$0,d0
0049d0 : 0000 0000                : ori.b #$0,d0
0049d4 : 0000 0000                : ori.b #$0,d0
0049d8 : 0000 0000                : ori.b #$0,d0
0049dc : 0000 0000                : ori.b #$0,d0
0049e0 : 0000 0000                : ori.b #$0,d0
0049e4 : 0000 0000                : ori.b #$0,d0
0049e8 : 0000 0000                : ori.b #$0,d0
0049ec : 0000 0000                : ori.b #$0,d0
0049f0 : 0000 0000                : ori.b #$0,d0
0049f4 : 0000 0000                : ori.b #$0,d0
0049f8 : 0000 0000                : ori.b #$0,d0
0049fc : 0000 0000                : ori.b #$0,d0
004a00 : 0000 0000                : ori.b #$0,d0
004a04 : 0000 0000                : ori.b #$0,d0
004a08 : 0000 0000                : ori.b #$0,d0
004a0c : 0000 0000                : ori.b #$0,d0
004a10 : 0000 0000                : ori.b #$0,d0
004a14 : 0000 0000                : ori.b #$0,d0
004a18 : 0000 0000                : ori.b #$0,d0
004a1c : 0000 0000                : ori.b #$0,d0
004a20 : 0000 0000                : ori.b #$0,d0
004a24 : 0000 0000                : ori.b #$0,d0
004a28 : 0000 0000                : ori.b #$0,d0
004a2c : 0000 0722                : ori.b #$22,d0
004a30 : 0502                     : btst d2,d2
004a32 : 0300                     : btst d1,d0
004a34 : 0453 0141                : subi.w #$141,(a3)
004a38 : 0032 0022 0772           : ori.b #$22,114(a2,d0.W)
004a3e : 0650 0430                : addi.w #$430,(a0)
004a42 : 0000 0200                : ori.b #$0,d0
004a46 : 0400 0600                : subi.b #$0,d0
004a4a : 0700                     : btst d3,d0
004a4c : 0000 0742                : ori.b #$42,d0
004a50 : 0610 0500                : addi.b #$0,(a0)
004a54 : 0646 0535                : addi.w #$535,d6
004a58 : 0423 0322                : subi.b #$22,-(a3)
004a5c : 0772 0650                : bchg d3,80(a2,d0.W)
004a60 : 0430 0750 0740           : subi.b #$50,64(a0,d0.W)
004a66 : 0620 0510                : addi.b #$10,-(a0)
004a6a : 0400 

loop.specific
		dc.w	draw.strip-loop.specific
		dc.w	draw.strip-loop.specific
		dc.w	loop2.update-loop.specific
		dc.w	draw.strip-loop-specific
004a74 : 0280 0100 0380           : andi.l #$1000380,d0
004a7a : 0f80                     : bclr d7,d0
004a7c : 0040 0fc0                : ori.w #$fc0,d0
004a80 : 0ea0                     : dc.w $ea0
004a82 : 0140                     : bchg d0,d0
004a84 : 0fe0                     : bset d7,-(a0)
004a86 : 1810                     : move.b (a0),d4
004a88 : 0140                     : bchg d0,d0
004a8a : 1ff0                     : dc.w $1ff0
004a8c : 1100                     : move.b d0,-(a0)
004a8e : 0040 1ff0                : ori.w #$1ff0,d0
004a92 : 1010                     : move.b (a0),d0
004a94 : 0140                     : bchg d0,d0
004a96 : 1ff0                     : dc.w $1ff0
004a98 : 0060 0100                : ori.w #$100,-(a0)
004a9c : 0fe0                     : bset d7,-(a0)
004a9e : 0980                     : bclr d4,d0
004aa0 : 0040 0fc0                : ori.w #$fc0,d0
004aa4 : 0280 0100 0380           : andi.l #$1000380,d0
004aaa : 0280 0100 0380           : andi.l #$1000380,d0
004ab0 : 0f80                     : bclr d7,d0
004ab2 : 0040 0fc0                : ori.w #$fc0,d0
004ab6 : 0ea0                     : dc.w $ea0
004ab8 : 0140                     : bchg d0,d0
004aba : 0fe0                     : bset d7,-(a0)
004abc : 1810                     : move.b (a0),d4
004abe : 0140                     : bchg d0,d0
004ac0 : 1ff0                     : dc.w $1ff0
004ac2 : 1100                     : move.b d0,-(a0)
004ac4 : 0040 1ff0                : ori.w #$1ff0,d0
004ac8 : 1010                     : move.b (a0),d0
004aca : 0140                     : bchg d0,d0
004acc : 1ff0                     : dc.w $1ff0
004ace : 0060 0100                : ori.w #$100,-(a0)
004ad2 : 0fe0                     : bset d7,-(a0)
004ad4 : 0980                     : bclr d4,d0
004ad6 : 0040 0fc0                : ori.w #$fc0,d0
004ada : 0280 0100 0380           : andi.l #$1000380,d0
004ae0 : 04c0                     : dc.w $4c0
004ae2 : 0320                     : btst d1,-(a0)
004ae4 : 07e0                     : bset d3,-(a0)
004ae6 : 0200 0d10                : andi.b #$10,d0
004aea : 0ff0 0f10                : bset d7,16(a0,d0.L)
004aee : 1080                     : move.b d0,(a0)
004af0 : 1ff0                     : dc.w $1ff0
004af2 : 1d90 0240                : move.b (a0),64(a6,d0.W)
004af6 : 1ff0                     : dc.w $1ff0
004af8 : 11c0 0030                : move.b d0,$30.w
004afc : 1ff0                     : dc.w $1ff0
004afe : 1060                     : dc.w $1060
004b00 : 0090 1ff0 1050           : ori.l #$1ff01050,(a0)
004b06 : 0020 1ff0                : ori.b #$f0,-(a0)
004b0a : 08c0 0020                : bset #$20,d0
004b0e : 0fe0                     : bset d7,-(a0)
004b10 : 0780                     : bclr d3,d0
004b12 : 0040 07c0                : ori.w #$7c0,d0
004b16 : 0780                     : bclr d3,d0
004b18 : 0040 07c0                : ori.w #$7c0,d0
004b1c : 08c0 0020                : bset #$20,d0
004b20 : 0fe0                     : bset d7,-(a0)
004b22 : 1050                     : dc.w $1050
004b24 : 0020 1ff0                : ori.b #$f0,-(a0)
004b28 : 1060                     : dc.w $1060
004b2a : 0090 1ff0 11c0           : ori.l #$1ff011c0,(a0)
004b30 : 0030 1ff0 1d90           : ori.b #$f0,-112(a0,d1.L)
004b36 : 0240 1ff0                : andi.w #$1ff0,d0
004b3a : 0f10                     : btst d7,(a0)
004b3c : 1080                     : move.b d0,(a0)
004b3e : 1ff0                     : dc.w $1ff0
004b40 : 0200 0d10                : andi.b #$10,d0
004b44 : 0ff0 04c0                : bset d7,-64(a0,d0.W)
004b48 : 0320                     : btst d1,-(a0)
004b4a : 07e0                     : bset d3,-(a0)
004b4c : 0280 0000 0380           : andi.l #$380,d0
004b52 : 0440 0000                : subi.w #$0,d0
004b56 : 07c0                     : bset d3,d0
004b58 : 0040 0fa0                : ori.w #$fa0,d0
004b5c : 0fe0                     : bset d7,-(a0)
004b5e : 1c30 0000                : move.b 0(a0,d0.W),d6
004b62 : 1ff0                     : dc.w $1ff0
004b64 : 0920                     : btst d4,-(a0)
004b66 : 16d0                     : move.b (a0),(a3)+
004b68 : 1ff0                     : dc.w $1ff0
004b6a : 1c10                     : move.b (a0),d6
004b6c : 0000 1ff0                : ori.b #$f0,d0
004b70 : 0c00 0000                : cmpi.b #$0,d0
004b74 : 0fe0                     : bset d7,-(a0)
004b76 : 0e20                     : dc.w $e20
004b78 : 0000 0fe0                : ori.b #$e0,d0
004b7c : 0380                     : bclr d1,d0
004b7e : 0000 0380                : ori.b #$80,d0
004b82 : 0380                     : bclr d1,d0
004b84 : 0000 0380                : ori.b #$80,d0
004b88 : 0e20                     : dc.w $e20
004b8a : 0000 0fe0                : ori.b #$e0,d0
004b8e : 0c00 0000                : cmpi.b #$0,d0
004b92 : 0fe0                     : bset d7,-(a0)
004b94 : 1c10                     : move.b (a0),d6
004b96 : 0000 1ff0                : ori.b #$f0,d0
004b9a : 0920                     : btst d4,-(a0)
004b9c : 16d0                     : move.b (a0),(a3)+
004b9e : 1ff0                     : dc.w $1ff0
004ba0 : 1c30 0000                : move.b 0(a0,d0.W),d6
004ba4 : 1ff0                     : dc.w $1ff0
004ba6 : 0040 0fa0                : ori.w #$fa0,d0
004baa : 0fe0                     : bset d7,-(a0)
004bac : 0440 0000                : subi.w #$0,d0
004bb0 : 07c0                     : bset d3,d0
004bb2 : 0280 0000 0380           : andi.l #$380,d0
004bb8 : 0640 0980                : addi.w #$980,d0
004bbc : 0fc0                     : bset d7,d0
004bbe : 0080 1160 1fe0           : ori.l #$11601fe0,d0
004bc4 : 11e0 0210                : move.b -(a0),$210.w
004bc8 : 1ff0                     : dc.w $1ff0
004bca : 1370 0480 1ff0           : move.b -128(a0,d0.W),+$1ff0(a1)
004bd0 : 0710                     : btst d3,(a0)
004bd2 : 1800                     : move.b d0,d4
004bd4 : 1ff0                     : dc.w $1ff0
004bd6 : 0c10 1200                : cmpi.b #$0,(a0)
004bda : 1ff0                     : dc.w $1ff0
004bdc : 1410                     : move.b (a0),d2
004bde : 0800 1ff0                : btst #$1ff0,d0
004be2 : 0620 0800                : addi.b #$0,-(a0)
004be6 : 0fe0                     : bset d7,-(a0)
004be8 : 03c0                     : bset d1,d0
004bea : 0400 07c0                : subi.b #$c0,d0
004bee : 03c0                     : bset d1,d0
004bf0 : 0400 07c0                : subi.b #$c0,d0
004bf4 : 0620 0800                : addi.b #$0,-(a0)
004bf8 : 0fe0                     : bset d7,-(a0)
004bfa : 1410                     : move.b (a0),d2
004bfc : 0800 1ff0                : btst #$1ff0,d0
004c00 : 0c10 1200                : cmpi.b #$0,(a0)
004c04 : 1ff0                     : dc.w $1ff0
004c06 : 0710                     : btst d3,(a0)
004c08 : 1800                     : move.b d0,d4
004c0a : 1ff0                     : dc.w $1ff0
004c0c : 1370 0480 1ff0           : move.b -128(a0,d0.W),+$1ff0(a1)
004c12 : 11e0 0210                : move.b -(a0),$210.w
004c16 : 1ff0                     : dc.w $1ff0
004c18 : 0080 1160 1fe0           : ori.l #$11601fe0,d0
004c1e : 0640 0980                : addi.w #$980,d0
004c22 : 0fc0                     : bset d7,d0
004c24 : 0280 0100 0380           : andi.l #$1000380,d0
004c2a : 03e0                     : bset d1,-(a0)
004c2c : 0400 07e0                : subi.b #$e0,d0
004c30 : 0ae0                     : dc.w $ae0
004c32 : 0500                     : btst d2,d0
004c34 : 0fe0                     : bset d7,-(a0)
004c36 : 1030 0500                : move.b 0(a0,d0.W),d0
004c3a : 1ff0                     : dc.w $1ff0
004c3c : 0110                     : btst d0,(a0)
004c3e : 0400 1ff0                : subi.b #$f0,d0
004c42 : 1010                     : move.b (a0),d0
004c44 : 0500                     : btst d2,d0
004c46 : 1ff0                     : dc.w $1ff0
004c48 : 0c00 0100                : cmpi.b #$0,d0
004c4c : 0fe0                     : bset d7,-(a0)
004c4e : 0320                     : btst d1,-(a0)
004c50 : 0400 07e0                : subi.b #$e0,d0
004c54 : 0280 0100 0380           : andi.l #$1000380,d0
004c5a : 0280 0100 0380           : andi.l #$1000380,d0
004c60 : 03e0                     : bset d1,-(a0)
004c62 : 0400 07e0                : subi.b #$e0,d0
004c66 : 0ae0                     : dc.w $ae0
004c68 : 0500                     : btst d2,d0
004c6a : 0fe0                     : bset d7,-(a0)
004c6c : 1030 0500                : move.b 0(a0,d0.W),d0
004c70 : 1ff0                     : dc.w $1ff0
004c72 : 0110                     : btst d0,(a0)
004c74 : 0400 1ff0                : subi.b #$f0,d0
004c78 : 1010                     : move.b (a0),d0
004c7a : 0500                     : btst d2,d0
004c7c : 1ff0                     : dc.w $1ff0
004c7e : 0c00 0100                : cmpi.b #$0,d0
004c82 : 0fe0                     : bset d7,-(a0)
004c84 : 0320                     : btst d1,-(a0)
004c86 : 0400 07e0                : subi.b #$e0,d0
004c8a : 0280 0100 0380           : andi.l #$1000380,d0
004c90 : 700e                     : moveq #14,d0
004c92 : e817                     : roxr.b #4,d7
004c94 : 8001                     : or.b d1,d0
004c96 : 8001                     : or.b d1,d0
004c98 : 8001                     : or.b d1,d0
004c9a : 8001                     : or.b d1,d0
004c9c : 8001                     : or.b d1,d0
004c9e : 0000 0000                : ori.b #$0,d0
004ca2 : 8001                     : or.b d1,d0
004ca4 : 0000 0000                : ori.b #$0,d0
004ca8 : 0000 0000                : ori.b #$0,d0
004cac : 0000 0000                : ori.b #$0,d0
004cb0 : 0000 0000                : ori.b #$0,d0
004cb4 : 0000 0000                : ori.b #$0,d0
004cb8 : 0000 0000                : ori.b #$0,d0
004cbc : 0000 8001                : ori.b #$1,d0
004cc0 : 8001                     : or.b d1,d0
004cc2 : 0000 8001                : ori.b #$1,d0
004cc6 : 8001                     : or.b d1,d0
004cc8 : 8001                     : or.b d1,d0
004cca : 8001                     : or.b d1,d0
004ccc : 700e                     : moveq #14,d0
004cce : e817                     : roxr.b #4,d7
LevelPalettes
004cd0 : 0006 7d00                : ori.b #$0,d6
004cd4 : 0000 0000                : ori.b #$0,d0
004cd8 : 0000 0000                : ori.b #$0,d0
004cdc : 0006 8a80                : ori.b #$80,d6
004ce0 : 0006 7d00                : ori.b #$0,d6
004ce4 : 0006 9080                : ori.b #$80,d6
004ce8 : 0006 9680                : ori.b #$80,d6
004cec : 0006 ad00                : ori.b #$0,d6
004cf0 : 0006 b300                : ori.b #$0,d6
004cf4 : 0006 b900                : ori.b #$0,d6
004cf8 : 0006 bf00                : ori.b #$0,d6
004cfc : 0006 c800                : ori.b #$0,d6
004d00 : 0006 d100                : ori.b #$0,d6
004d04 : 0006 da00                : ori.b #$0,d6
004d08 : 0006 e300                : ori.b #$0,d6
004d0c : 0006 ef00                : ori.b #$0,d6
004d10 : 0006 fc80                : ori.b #$80,d6
004d14 : 0006 fe00                : ori.b #$0,d6
004d18 : 0000 0000                : ori.b #$0,d0
004d1c : 0000 0000                : ori.b #$0,d0
004d20 : 0000 0000                : ori.b #$0,d0
004d24 : 0000 0000                : ori.b #$0,d0
004d28 : 0000 0000                : ori.b #$0,d0
004d2c : 0000 0000                : ori.b #$0,d0
004d30 : 0006 7d00                : ori.b #$0,d6
004d34 : 0000 0000                : ori.b #$0,d0
004d38 : 0000 0000                : ori.b #$0,d0
004d3c : 0006 8a80                : ori.b #$80,d6
004d40 : 0006 7d00                : ori.b #$0,d6
004d44 : 0006 9200                : ori.b #$0,d6
004d48 : 0006 9800                : ori.b #$0,d6
004d4c : 0006 9f80                : ori.b #$80,d6
004d50 : 0006 b600                : ori.b #$0,d6
004d54 : 0006 b900                : ori.b #$0,d6
004d58 : 0006 ba80                : ori.b #$80,d6
004d5c : 0006 c380                : ori.b #$80,d6
004d60 : 0006 cf80                : ori.b #$80,d6
004d64 : 0006 d580                : ori.b #$80,d6
004d68 : 0006 e180                : ori.b #$80,d6
004d6c : 0006 f980                : ori.b #$80,d6
004d70 : 0006 fb00                : ori.b #$0,d6
004d74 : 0006 fc80                : ori.b #$80,d6
004d78 : 0006 fe00                : ori.b #$0,d6
004d7c : 0000 0000                : ori.b #$0,d0
004d80 : 0000 0000                : ori.b #$0,d0
004d84 : 0000 0000                : ori.b #$0,d0
004d88 : 0000 0000                : ori.b #$0,d0
004d8c : 0000 0000                : ori.b #$0,d0
004d90 : 0006 7d00                : ori.b #$0,d6
004d94 : 0000 0000                : ori.b #$0,d0
004d98 : 0000 0000                : ori.b #$0,d0
004d9c : 0006 8900                : ori.b #$0,d6
004da0 : 0006 7d00                : ori.b #$0,d6
004da4 : 0006 9080                : ori.b #$80,d6
004da8 : 0006 9e00                : ori.b #$0,d6
004dac : 0006 a700                : ori.b #$0,d6
004db0 : 0006 b000                : ori.b #$0,d6
004db4 : 0006 b900                : ori.b #$0,d6
004db8 : 0006 c200                : ori.b #$0,d6
004dbc : 0006 ce00                : ori.b #$0,d6
004dc0 : 0006 db80                : ori.b #$80,d6
004dc4 : 0006 ed80                : ori.b #$80,d6
004dc8 : 0006 f980                : ori.b #$80,d6
004dcc : 0006 fe00                : ori.b #$0,d6
004dd0 : 0000 0000                : ori.b #$0,d0
004dd4 : 0000 0000                : ori.b #$0,d0
004dd8 : 0000 0000                : ori.b #$0,d0
004ddc : 0000 0000                : ori.b #$0,d0
004de0 : 0000 0000                : ori.b #$0,d0
004de4 : 0000 0000                : ori.b #$0,d0
004de8 : 0000 0000                : ori.b #$0,d0
004dec : 0000 0000                : ori.b #$0,d0
004df0 : 0006 7d00                : ori.b #$0,d6
004df4 : 0000 0000                : ori.b #$0,d0
004df8 : 0000 0000                : ori.b #$0,d0
004dfc : 0006 8900                : ori.b #$0,d6
004e00 : 0006 7d00                : ori.b #$0,d6
004e04 : 0006 9500                : ori.b #$0,d6
004e08 : 0006 9980                : ori.b #$80,d6
004e0c : 0006 a580                : ori.b #$80,d6
004e10 : 0006 ae80                : ori.b #$80,d6
004e14 : 0006 b300                : ori.b #$0,d6
004e18 : 0006 ba80                : ori.b #$80,d6
004e1c : 0006 c980                : ori.b #$80,d6
004e20 : 0006 d400                : ori.b #$0,d6
004e24 : 0006 d880                : ori.b #$80,d6
004e28 : 0006 de80                : ori.b #$80,d6
004e2c : 0006 ea80                : ori.b #$80,d6
004e30 : 0006 f500                : ori.b #$0,d6
004e34 : 0007 0280                : ori.b #$80,d7
004e38 : 0007 0880                : ori.b #$80,d7
004e3c : 0000 0000                : ori.b #$0,d0
004e40 : 0000 0000                : ori.b #$0,d0
004e44 : 0000 0000                : ori.b #$0,d0
004e48 : 0000 0000                : ori.b #$0,d0
004e4c : 0000 0000                : ori.b #$0,d0
004e50 : 0006 7d00                : ori.b #$0,d6
004e54 : 0000 0000                : ori.b #$0,d0
004e58 : 0000 0000                : ori.b #$0,d0
004e5c : 0006 8900                : ori.b #$0,d6
004e60 : 0006 7d00                : ori.b #$0,d6
004e64 : 0006 9380                : ori.b #$80,d6
004e68 : 0006 9f80                : ori.b #$80,d6
004e6c : 0006 ab80                : ori.b #$80,d6
004e70 : 0006 b480                : ori.b #$80,d6
004e74 : 0006 bd80                : ori.b #$80,d6
004e78 : 0006 d580                : ori.b #$80,d6
004e7c : 0006 e180                : ori.b #$80,d6
004e80 : 0006 ea80                : ori.b #$80,d6
004e84 : 0006 f680                : ori.b #$80,d6
004e88 : 0006 ff80                : ori.b #$80,d6
004e8c : 0000 0000                : ori.b #$0,d0
004e90 : 0000 0000                : ori.b #$0,d0
004e94 : 0000 0000                : ori.b #$0,d0
004e98 : 0000 0000                : ori.b #$0,d0
004e9c : 0000 0000                : ori.b #$0,d0
004ea0 : 0000 0000                : ori.b #$0,d0
004ea4 : 0000 0000                : ori.b #$0,d0
004ea8 : 0000 0000                : ori.b #$0,d0
004eac : 0000 0000                : ori.b #$0,d0
004eb0 : 0006 7d00                : ori.b #$0,d6
004eb4 : 0000 0000                : ori.b #$0,d0
004eb8 : 0000 0000                : ori.b #$0,d0
004ebc : 0006 8900                : ori.b #$0,d6
004ec0 : 0006 7d00                : ori.b #$0,d6
004ec4 : 0006 9800                : ori.b #$0,d6
004ec8 : 0006 9c80                : ori.b #$80,d6
004ecc : 0006 b480                : ori.b #$80,d6
004ed0 : 0006 c680                : ori.b #$80,d6
004ed4 : 0006 c980                : ori.b #$80,d6
004ed8 : 0006 d100                : ori.b #$0,d6
004edc : 0006 d880                : ori.b #$80,d6
004ee0 : 0006 dd00                : ori.b #$0,d6
004ee4 : 0006 e000                : ori.b #$0,d6
004ee8 : 0006 f200                : ori.b #$0,d6
004eec : 0006 f680                : ori.b #$80,d6
004ef0 : 0007 0a00                : ori.b #$0,d7
004ef4 : 0000 0000                : ori.b #$0,d0
004ef8 : 0000 0000                : ori.b #$0,d0
004efc : 0000 0000                : ori.b #$0,d0
004f00 : 0000 0000                : ori.b #$0,d0
004f04 : 0000 0000                : ori.b #$0,d0
004f08 : 0000 0000                : ori.b #$0,d0
004f0c : 0000 0000                : ori.b #$0,d0
004f10 : 2e23                     : move.l -(a3),d7
004f12 : 121e                     : move.b (a6)+,d1
004f14 : 1400                     : move.b d0,d2
bonus.samples
		dc.b	$80,$81,$84,$87,$85,$83,$86
MSG_Copyright
			dc.b		$3e,$1,"MENACE",0
			dc.b		$1b,$4,"CODE      GRAPHICS",0
			dc.b		$0e,$6,"BRIAN WATSON TONY SMITH",0
			dc.b		$0e,$8,"& DAVE JONES",0
			dc.b		$30,$a,"DMA DESIGN",0
			dc.b		$0e,$d,"PRESS F1 - NOVICE",0
			dc.b		$2c,$f,"F2 - EXPERT (X2 SCORE)",0
			dc.b		$20,$20,"1988 PSYGNOSIS",-1,0
MSG_50Hz
			dc.b		$14,$10,"F3 - 50HZ",-1
MSG_60Hz
			dc.b		$14,$11,"F3 - 60HZ",-1
MSG_Joystick
			dc.b		$55,$11,"F4 - JOYSTICK",-1
MSG_Mouse
			dc.b		$55,$11,"F4 - MOUSE",-1
MSG_Dead
			dc.b		$18,$06,"SHIELD ENERGY DEPLETED",0
			dc.b		$12,$08,"YOUR SHIP WAS DESTROYED",0
			dc.b		$12,$0c,"YOU HAVE PROVED NO MATCH",0
			dc.b		$1e,$0e,"FOR THE DEFENCES OF",0
			dc.b		$3a,$10,"DRACONIA",-1
MSG_Escape
			dc.b		$28,$02,"ESCAPE PRESSED",0
			dc.b		$14,$08,"PRESS ANY KEY TO EXIT",-1,0
MSG_GameOverTotals
			dc.b		$32,$02,"1000 POINT BONUS",0
			dc.b		$32,$05,"CANNONS & ENERGY",0
			dc.b		$32,$08,"LASERS & ENERGY",0
			dc.b		$32,$0b,"SPEEDUP - MAX X6",0
			dc.b		$32,$0e,"OUTRIDER - MAX X2",0
			dc.b		$32,$11,"FORCEFIELD",0
			dc.b		$32,$14,"FULL SHIELD POWER",0
			dc.b		$2d,$05,"PRESS FIRE TO",0
			dc.b		$1e,$0b,"RESTART THIS LEVEL",-1
00512a : ff32                     : line-F #$f32
00512c : 0253 4541                : andi.w #$4541,(a3)
005130 : 204f                     : movea.l a7,a0
005132 : 4620                     : not.b -(a0)
005134 : 4b41                     : dc.w $4b41
005136 : 524e                     : addq.w #1,a6
005138 : 4155                     : dc.w $4155
00513a : 4748                     : dc.w $4748
00513c : 0032 0656 414e           : ori.b #$56,78(a2,d4.W)
005142 : 4755                     : dc.w $4755
005144 : 4152                     : dc.w $4152
005146 : 4420                     : neg.b -(a0)
005148 : 5741                     : subq.w #3,d1
00514a : 525a                     : addq.w #1,(a2)+
00514c : 4f4e                     : dc.w $4f4e
00514e : 4500                     : dc.w $4500
005150 : 320a                     : move.w a2,d1
005152 : 4341                     : dc.w $4341
005154 : 524e                     : addq.w #1,a6
005156 : 4147                     : dc.w $4147
005158 : 4520                     : dc.w $4520
00515a : 5249                     : addq.w #1,a1
00515c : 4654                     : not.w (a4)
00515e : 0032 0e54 524f           : ori.b #$54,79(a2,d5.W)
005164 : 5049                     : addq.w #8,a1
005166 : 4353                     : dc.w $4353
005168 : 204f                     : movea.l a7,a0
00516a : 4620                     : not.b -(a0)
00516c : 4d41                     : dc.w $4d41
00516e : 4345                     : dc.w $4345
005170 : 0032 1252 5549           : ori.b #$52,73(a2,d5.W)
005176 : 4e53 204f                : link a3,#8271
00517a : 4620                     : not.b -(a0)
00517c : 4b52                     : dc.w $4b52
00517e : 5547                     : subq.w #2,d7
005180 : 4552                     : dc.w $4552
005182 : 0032 1650 4c41           : ori.b #$50,65(a2,d4.L)
005188 : 5445                     : addq.w #2,d5
00518a : 4155                     : dc.w $4155
00518c : 5320                     : subq.b #1,-(a0)
00518e : 4f46                     : dc.w $4f46
005190 : 2044                     : movea.l d4,a0
005192 : 5241                     : addq.w #1,d1
005194 : 434f                     : dc.w $434f
005196 : 4e49                     : trap #9
005198 : 41ff                     : dc.w $41ff
00519a : 2304                     : move.l d4,-(a1)
00519c : 434f                     : dc.w $434f
00519e : 4e47                     : trap #7
0051a0 : 5241                     : addq.w #1,d1
0051a2 : 5455                     : addq.w #2,(a5)
0051a4 : 4c41                     : dc.w $4c41
0051a6 : 5449                     : addq.w #2,a1
0051a8 : 4f4e                     : dc.w $4f4e
0051aa : 5321                     : subq.b #1,-(a1)
0051ac : 0004 0859                : ori.b #$59,d4
0051b0 : 4f55                     : dc.w $4f55
0051b2 : 2048                     : movea.l a0,a0
0051b4 : 4156                     : dc.w $4156
0051b6 : 4520                     : dc.w $4520
0051b8 : 4252                     : clr.w (a2)
0051ba : 4156                     : dc.w $4156
0051bc : 454c                     : dc.w $454c
0051be : 5920                     : subq.b #4,-(a0)
0051c0 : 464f                     : dc.w $464f
0051c2 : 5547                     : subq.w #2,d7
0051c4 : 4854                     : pea (a4)
0051c6 : 2059                     : movea.l (a1)+,a0
0051c8 : 4f55                     : dc.w $4f55
0051ca : 5200                     : addq.b #1,d0
0051cc : 0a0a                     : dc.w $a0a
0051ce : 5741                     : subq.w #3,d1
0051d0 : 5920                     : subq.b #4,-(a0)
0051d2 : 5448                     : addq.w #2,a0
0051d4 : 524f                     : addq.w #1,a7
0051d6 : 5547                     : subq.w #2,d7
0051d8 : 482c 2041                : nbcd +$2041(a4)
0051dc : 4e44                     : trap #4
0051de : 2044                     : movea.l d4,a0
0051e0 : 4553                     : dc.w $4553
0051e2 : 5452                     : addq.w #2,(a2)
0051e4 : 4f59                     : dc.w $4f59
0051e6 : 4544                     : dc.w $4544
0051e8 : 0030 0c44 5241           : ori.b #$44,65(a0,d5.W)
0051ee : 434f                     : dc.w $434f
0051f0 : 4e49                     : trap #9
0051f2 : 4100                     : dc.w $4100
0051f4 : 0510                     : btst d2,(a0)
0051f6 : 4e4f                     : trap #15
0051f8 : 5720                     : subq.b #3,-(a0)
0051fa : 5245                     : addq.w #1,d5
0051fc : 5455                     : addq.w #2,(a5)
0051fe : 524e                     : addq.w #1,a6
005200 : 2054                     : movea.l (a4),a0
005202 : 4f20                     : dc.w $4f20
005204 : 5448                     : addq.w #2,a0
005206 : 4520                     : dc.w $4520
005208 : 4d4f                     : dc.w $4d4f
00520a : 5448                     : addq.w #2,a0
00520c : 4552                     : dc.w $4552
00520e : 5348                     : subq.w #1,a0
005210 : 4950                     : dc.w $4950
005212 : 0039 1241 4e44 2052      : ori.b #$41,$4e442052
00521a : 4553                     : dc.w $4553
00521c : 542e ff26                : addq.b #2,-$da(a6)
005220 : 0457 4859                : subi.w #$4859,(a7)
005224 : 204e                     : movea.l a6,a0
005226 : 4f54                     : dc.w $4f54
005228 : 2043                     : movea.l d3,a0
00522a : 4f4e                     : dc.w $4f4e
00522c : 5449                     : addq.w #2,a1
00522e : 4e55 4500                : link a5,#17664
005232 : 0808                     : dc.w $808
005234 : 5448                     : addq.w #2,a0
005236 : 4953                     : dc.w $4953
005238 : 2054                     : movea.l (a4),a0
00523a : 494d                     : dc.w $494d
00523c : 4520                     : dc.w $4520
00523e : 5448                     : addq.w #2,a0
005240 : 4520                     : dc.w $4520
005242 : 4452                     : neg.w (a2)
005244 : 4143                     : dc.w $4143
005246 : 4f4e                     : dc.w $4f4e
005248 : 4941                     : dc.w $4941
00524a : 4e53 2057                : link a3,#8279
00524e : 494c                     : dc.w $494c
005250 : 4c00                     : dc.w $4c00
005252 : 1e0a                     : move.b a2,d7
005254 : 4245                     : clr.w d5
005256 : 204f                     : movea.l a7,a0
005258 : 5554                     : subq.w #2,(a4)
00525a : 2046                     : movea.l d6,a0
00525c : 4f52                     : dc.w $4f52
00525e : 2052                     : movea.l (a2),a0
005260 : 4556                     : dc.w $4556
005262 : 454e                     : dc.w $454e
005264 : 4745                     : dc.w $4745
005266 : 2021                     : move.l -(a1),d0
005268 : 0032 0d47 4f4f           : ori.b #$47,79(a2,d4.L)
00526e : 4420                     : neg.b -(a0)
005270 : 4c55                     : dc.w $4c55
005272 : 434b                     : dc.w $434b
005274 : ff1e                     : line-F #$f1e
005276 : 0654 4f20                : addi.w #$4f20,(a4)
00527a : 5245                     : addq.w #1,d5
00527c : 5354                     : subq.w #1,(a4)
00527e : 4152                     : dc.w $4152
005280 : 5420                     : addq.b #2,-(a0)
005282 : 5448                     : addq.w #2,a0
005284 : 4953                     : dc.w $4953
005286 : 204c                     : movea.l a4,a0
005288 : 4556                     : dc.w $4556
00528a : 454c                     : dc.w $454c
00528c : 0032 1050 5245           : ori.b #$50,69(a2,d5.W)
005292 : 5353                     : subq.w #1,(a3)
005294 : 2046                     : movea.l d6,a0
005296 : 4952                     : dc.w $4952
005298 : 45ff                     : dc.w $45ff
00529a : 400b                     : dc.w $400b
00529c : 2020                     : move.l -(a0),d0
00529e : 20ff                     : dc.w $20ff
0052a0 : 2807                     : move.l d7,d4
0052a2 : 494e                     : dc.w $494e
0052a4 : 5345                     : subq.w #1,d5
0052a6 : 5254                     : addq.w #1,(a4)
0052a8 : 204d                     : movea.l a5,a0
0052aa : 454e                     : dc.w $454e
0052ac : 4143                     : dc.w $4143
0052ae : 4520                     : dc.w $4520
0052b0 : 4449                     : dc.w $4449
0052b2 : 534b                     : subq.w #1,a3
0052b4 : 002a 0a20 4120           : ori.b #$20,+$4120(a2)
0052ba : 494e                     : dc.w $494e
0052bc : 544f                     : addq.w #2,a7
0052be : 2044                     : movea.l d4,a0
0052c0 : 5249                     : addq.w #1,a1
0052c2 : 5645                     : addq.w #3,d5
0052c4 : 2041                     : movea.l d1,a0
0052c6 : 3a00                     : move.w d0,d5
0052c8 : 280d                     : move.l a5,d4
0052ca : 5448                     : addq.w #2,a0
0052cc : 454e                     : dc.w $454e
0052ce : 2050                     : movea.l (a0),a0
0052d0 : 5245                     : addq.w #1,d5
0052d2 : 5353                     : subq.w #1,(a3)
0052d4 : 2041                     : movea.l d1,a0
0052d6 : 4e59                     : unlk a1
0052d8 : 204b                     : movea.l a3,a0
0052da : 4559                     : dc.w $4559
0052dc : ff28                     : line-F #$f28
0052de : 0749 4e53                : movep.l $4e53(a1),d3
0052e2 : 4552                     : dc.w $4552
0052e4 : 5420                     : addq.b #2,-(a0)
0052e6 : 4d45                     : dc.w $4d45
0052e8 : 4e41                     : trap #1
0052ea : 4345                     : dc.w $4345
0052ec : 2044                     : movea.l d4,a0
0052ee : 4953                     : dc.w $4953
0052f0 : 4b00                     : dc.w $4b00
0052f2 : 2a0a                     : move.l a2,d5
0052f4 : 2042                     : movea.l d2,a0
0052f6 : 2049                     : movea.l a1,a0
0052f8 : 4e54 4f20                : link a4,#20256
0052fc : 4452                     : neg.w (a2)
0052fe : 4956                     : dc.w $4956
005300 : 4520                     : dc.w $4520
005302 : 413a                     : dc.w $413a
005304 : 2000                     : move.l d0,d0
005306 : 280d                     : move.l a5,d4
005308 : 5448                     : addq.w #2,a0
00530a : 454e                     : dc.w $454e
00530c : 2050                     : movea.l (a0),a0
00530e : 5245                     : addq.w #1,d5
005310 : 5353                     : subq.w #1,(a3)
005312 : 2041                     : movea.l d1,a0
005314 : 4e59                     : unlk a1
005316 : 204b                     : movea.l a3,a0
005318 : 4559                     : dc.w $4559
00531a : ff00                     : line-F #$f00
00531c : 5000                     : addq.b #8,d0
00531e : 4449                     : dc.w $4449
005320 : 534b                     : subq.w #1,a3
005322 : 2052                     : movea.l (a2),a0
005324 : 4541                     : dc.w $4541
005326 : 4420                     : neg.b -(a0)
005328 : 4552                     : dc.w $4552
00532a : 524f                     : addq.w #1,a7
00532c : 52ff                     : dc.w $52ff
00532e : 0800 4c45                : btst #$4c45,d0
005332 : 5645                     : addq.w #3,d5
005334 : 4c20                     : dc.w $4c20
005336 : 3120                     : move.w -(a0),-(a0)
005338 : 5343                     : subq.w #1,d3
00533a : 4f52                     : dc.w $4f52
00533c : 452e                     : dc.w $452e
00533e : 2e2e 2e00                : move.l +$2e00(a6),d7
005342 : 0802 4c45                : btst #$4c45,d2
005346 : 5645                     : addq.w #3,d5
005348 : 4c20                     : dc.w $4c20
00534a : 3220                     : move.w -(a0),d1
00534c : 5343                     : subq.w #1,d3
00534e : 4f52                     : dc.w $4f52
005350 : 452e                     : dc.w $452e
005352 : 2e2e 2e00                : move.l +$2e00(a6),d7
005356 : 0804 4c45                : btst #$4c45,d4
00535a : 5645                     : addq.w #3,d5
00535c : 4c20                     : dc.w $4c20
00535e : 3320                     : move.w -(a0),-(a1)
005360 : 5343                     : subq.w #1,d3
005362 : 4f52                     : dc.w $4f52
005364 : 452e                     : dc.w $452e
005366 : 2e2e 2e00                : move.l +$2e00(a6),d7
00536a : 0806 4c45                : btst #$4c45,d6
00536e : 5645                     : addq.w #3,d5
005370 : 4c20                     : dc.w $4c20
005372 : 3420                     : move.w -(a0),d2
005374 : 5343                     : subq.w #1,d3
005376 : 4f52                     : dc.w $4f52
005378 : 452e                     : dc.w $452e
00537a : 2e2e 2e00                : move.l +$2e00(a6),d7
00537e : 0808                     : dc.w $808
005380 : 4c45                     : dc.w $4c45
005382 : 5645                     : addq.w #3,d5
005384 : 4c20                     : dc.w $4c20
005386 : 3520                     : move.w -(a0),-(a2)
005388 : 5343                     : subq.w #1,d3
00538a : 4f52                     : dc.w $4f52
00538c : 452e                     : dc.w $452e
00538e : 2e2e 2e00                : move.l +$2e00(a6),d7
005392 : 080a                     : dc.w $80a
005394 : 4c45                     : dc.w $4c45
005396 : 5645                     : addq.w #3,d5
005398 : 4c20                     : dc.w $4c20
00539a : 3620                     : move.w -(a0),d3
00539c : 5343                     : subq.w #1,d3
00539e : 4f52                     : dc.w $4f52
0053a0 : 452e                     : dc.w $452e
0053a2 : 2e2e 2e00                : move.l +$2e00(a6),d7
0053a6 : 2c0d                     : move.l a5,d6
0053a8 : 544f                     : addq.w #2,a7
0053aa : 5441                     : addq.w #2,d1
0053ac : 4c2e                     : dc.w $4c2e
0053ae : 2e2e 2e00                : move.l +$2e00(a6),d7
0053b2 : 0810 5350                : btst #$5350,(a0)
0053b6 : 4545                     : dc.w $4545
0053b8 : 4455                     : neg.w (a5)
0053ba : 5053                     : addq.w #8,(a3)
0053bc : 2e2e 2e00                : move.l +$2e00(a6),d7
0053c0 : 0812 4f55                : btst #$4f55,(a2)
0053c4 : 5452                     : addq.w #2,(a2)
0053c6 : 4944                     : dc.w $4944
0053c8 : 4552                     : dc.w $4552
0053ca : 532e 2e2e                : subq.b #1,+$2e2e(a6)
0053ce : 0008                     : dc.w $8
0053d0 : 1446                     : dc.w $1446
0053d2 : 2046                     : movea.l d6,a0
0053d4 : 4945                     : dc.w $4945
0053d6 : 4c44                     : dc.w $4c44
0053d8 : 532e 2e2e                : subq.b #1,+$2e2e(a6)
0053dc : 2e2e 0056                : move.l 86(a6),d7
0053e0 : 1043                     : dc.w $1043
0053e2 : 414e                     : dc.w $414e
0053e4 : 4f4e                     : dc.w $4f4e
0053e6 : 532e 2e2e                : subq.b #1,+$2e2e(a6)
0053ea : 0056 124c                : ori.w #$124c,(a6)
0053ee : 4153                     : dc.w $4153
0053f0 : 4552                     : dc.w $4552
0053f2 : 532e 2e2e                : subq.b #1,+$2e2e(a6)
0053f6 : 0056 1453                : ori.w #$1453,(a6)
0053fa : 4849                     : dc.w $4849
0053fc : 454c                     : dc.w $454c
0053fe : 4453                     : neg.w (a3)
005400 : 2e2e ff58                : move.l -$a8(a6),d7
005404 : 0058 0258                : ori.w #$258,(a0)+
005408 : 0458 0658                : subi.w #$658,(a0)+
00540c : 0858 0a58                : bchg #$a58,(a0)+
005410 : 0d3f                     : dc.w $d3f
005412 : 103f                     : dc.w $103f
005414 : 123f                     : dc.w $123f
005416 : 1481                     : move.b d1,(a2)
005418 : 1081                     : move.b d1,(a0)
00541a : 1281                     : move.b d1,(a1)
00541c : 1400                     : move.b d0,d2
00541e : 2212                     : move.l (a2),d1
005420 : 4100                     : dc.w $4100
005422 : 2a12                     : move.l (a2),d5
005424 : 4200                     : clr.b d0
005426 : 3212                     : move.w (a2),d1
005428 : 4300                     : dc.w $4300
00542a : 3a12                     : move.w (a2),d5
00542c : 4400                     : neg.b d0
00542e : 4212                     : clr.b (a2)
005430 : 4500                     : dc.w $4500
005432 : 4a12                     : tst.b (a2)
005434 : 4600                     : not.b d0
005436 : 5212                     : addq.b #1,(a2)
005438 : 4700                     : dc.w $4700
00543a : 5a12                     : addq.b #5,(a2)
00543c : 4800                     : nbcd d0
00543e : 6412                     : bcc.s +18
005440 : 4900                     : dc.w $4900
005442 : 6a12                     : bpl.s +18
005444 : 4a00                     : tst.b d0
005446 : 2214                     : move.l (a4),d1
005448 : 4b00                     : dc.w $4b00
00544a : 2a14                     : move.l (a4),d5
00544c : 4c00                     : dc.w $4c00
00544e : 3214                     : move.w (a4),d1
005450 : 4d00                     : dc.w $4d00
005452 : 3a14                     : move.w (a4),d5
005454 : 4e00                     : dc.w $4e00
005456 : 4214                     : clr.b (a4)
005458 : 4f00                     : dc.w $4f00
00545a : 4a14                     : tst.b (a4)
00545c : 5000                     : addq.b #8,d0
00545e : 5214                     : addq.b #1,(a4)
005460 : 5100                     : subq.b #8,d0
005462 : 5a14                     : addq.b #5,(a4)
005464 : 5200                     : addq.b #1,d0
005466 : 6214                     : bhi.s +20
005468 : 5300                     : subq.b #1,d0
00546a : 6a14                     : bpl.s +20
00546c : 5400                     : addq.b #2,d0
00546e : 2216                     : move.l (a6),d1
005470 : 5500                     : subq.b #2,d0
005472 : 2a16                     : move.l (a6),d5
005474 : 5600                     : addq.b #3,d0
005476 : 3216                     : move.w (a6),d1
005478 : 5700                     : subq.b #3,d0
00547a : 3a16                     : move.w (a6),d5
00547c : 5800                     : addq.b #4,d0
00547e : 4216                     : clr.b (a6)
005480 : 5900                     : subq.b #4,d0
005482 : 4a16                     : tst.b (a6)
005484 : 5a00                     : addq.b #5,d0
005486 : 5216                     : addq.b #1,(a6)
005488 : 5b00                     : subq.b #5,d0
00548a : 5a16                     : addq.b #5,(a6)
00548c : 5c00                     : addq.b #6,d0
00548e : 6216                     : bhi.s +22
005490 : 5d00                     : subq.b #6,d0
005492 : 6a16                     : bpl.s +22
005494 : 5eff                     : dc.w $5eff
005496 : 5448                     : addq.w #2,a0
005498 : 4520                     : dc.w $4520
00549a : 4849                     : dc.w $4849
00549c : 4748                     : dc.w $4748
00549e : 2053                     : movea.l (a3),a0
0054a0 : 434f                     : dc.w $434f
0054a2 : 5245                     : addq.w #1,d5
0054a4 : 2054                     : movea.l (a4),a0
0054a6 : 4142                     : dc.w $4142
0054a8 : 4c45                     : dc.w $4c45
0054aa : 2e2e 2e2e                : move.l +$2e2e(a6),d7
MSG_HighScores
0054ae : 1600                     : move.b d0,d3
0054b0 : 3120                     : move.w -(a0),-(a0)
0054b2 : 3235 3030                : move.w 48(a5,d3.W),d1
0054b6 : 3030 0044                : move.w 68(a0,d0.W),d0
0054ba : 002e 2e2e 2e42           : ori.b #$2e,+$2e42(a6)
0054c0 : 4d43                     : dc.w $4d43
0054c2 : 2057                     : movea.l (a7),a0
0054c4 : 4154                     : dc.w $4154
0054c6 : 534f                     : subq.w #1,a7
0054c8 : 4e00                     : dc.w $4e00
0054ca : 1402                     : move.b d2,d2
0054cc : 3220                     : move.w -(a0),d1
0054ce : 3230 3030                : move.w 48(a0,d3.W),d1
0054d2 : 3030 0044                : move.w 68(a0,d0.W),d0
0054d6 : 022e 2e2e 2e44           : andi.b #$2e,+$2e44(a6)
0054dc : 4156                     : dc.w $4156
0054de : 4520                     : dc.w $4520
0054e0 : 4a4f                     : dc.w $4a4f
0054e2 : 4e45                     : trap #5
0054e4 : 5300                     : subq.b #1,d0
0054e6 : 1404                     : move.b d4,d2
0054e8 : 3320                     : move.w -(a0),-(a1)
0054ea : 3137 3531                : move.w 49(a7,d3.W),-(a0)
0054ee : 3830 0044                : move.w 68(a0,d0.W),d4
0054f2 : 042e 2e2e 2e4d           : subi.b #$2e,+$2e4d(a6)
0054f8 : 4152                     : dc.w $4152
0054fa : 4c20                     : dc.w $4c20
0054fc : 2020                     : move.l -(a0),d0
0054fe : 2020                     : move.l -(a0),d0
005500 : 2000                     : move.l d0,d0
005502 : 1406                     : move.b d6,d2
005504 : 3420                     : move.w -(a0),d2
005506 : 3130 3937                : move.w 55(a0,d3.L),-(a0)
00550a : 3830 0044                : move.w 68(a0,d0.W),d4
00550e : 062e 2e2e 2e42           : addi.b #$2e,+$2e42(a6)
005514 : 4953                     : dc.w $4953
005516 : 4355                     : dc.w $4355
005518 : 4920                     : dc.w $4920
00551a : 2020                     : move.l -(a0),d0
00551c : 2000                     : move.l d0,d0
00551e : 1408                     : move.b a0,d2
005520 : 3520                     : move.w -(a0),-(a2)
005522 : 3137 3730                : move.w 48(a7,d3.W),-(a0)
005526 : 3430 0044                : move.w 68(a0,d0.W),d2
00552a : 082e 2e2e 2e4f           : btst #$2e2e,+$2e4f(a6)
005530 : 5a5a                     : addq.w #5,(a2)+
005532 : 2020                     : move.l -(a0),d0
005534 : 2020                     : move.l -(a0),d0
005536 : 2020                     : move.l -(a0),d0
005538 : 2000                     : move.l d0,d0
00553a : 140a                     : move.b a2,d2
00553c : 3620                     : move.w -(a0),d3
00553e : 3135 3030                : move.w 48(a5,d3.W),-(a0)
005542 : 3030 0044                : move.w 68(a0,d0.W),d0
005546 : 0a2e 2e2e 2e54           : eori.b #$2e,+$2e54(a6)
00554c : 4f4e                     : dc.w $4f4e
00554e : 5920                     : subq.b #4,-(a0)
005550 : 534d                     : subq.w #1,a5
005552 : 4954                     : dc.w $4954
005554 : 4800                     : nbcd d0
005556 : 140c                     : move.b a4,d2
005558 : 3720                     : move.w -(a0),-(a3)
00555a : 3130 3030                : move.w 48(a0,d3.W),-(a0)
00555e : 3030 0044                : move.w 68(a0,d0.W),d0
005562 : 0c2e 2e2e 2e44           : cmpi.b #$2e,+$2e44(a6)
005568 : 4d41                     : dc.w $4d41
00556a : 2044                     : movea.l d4,a0
00556c : 4553                     : dc.w $4553
00556e : 4947                     : dc.w $4947
005570 : 4e00                     : dc.w $4e00
005572 : 140e                     : move.b a6,d2
005574 : 3820                     : move.w -(a0),d4
005576 : 3038 3030                : move.w $3030.W,d0
00557a : 3030 0044                : move.w 68(a0,d0.W),d0
00557e : 0e2e                     : dc.w $e2e
005580 : 2e2e 2e52                : move.l +$2e52(a6),d7
005584 : 5553                     : subq.w #2,(a3)
005586 : 532d 2d4d                : subq.b #1,+$2d4d(a5)
00558a : 494b                     : dc.w $494b
00558c : 45ff                     : dc.w $45ff
00558e : 0000 0000                : ori.b #$0,d0
005592 : 3036 3030                : move.w 48(a6,d3.W),d0
005596 : 3030 0000                : move.w 0(a0,d0.W),d0
00559a : 0000 0000                : ori.b #$0,d0
00559e : 0041 4e44                : ori.w #$4e44,d1
0055a2 : 592d 2d47                : subq.b #4,+$2d47(a5)
0055a6 : 4f47                     : dc.w $4f47
0055a8 : 5300                     : subq.b #1,d0
0055aa : 0000 0000                : ori.b #$0,d0
0055ae : 0000 0000                : ori.b #$0,d0
0055b2 : 0000 0000                : ori.b #$0,d0
0055b6 : 0025 0000                : ori.b #$0,-(a5)
0055ba : 0020 0000                : ori.b #$0,-(a0)
0055be : 0015 0000                : ori.b #$0,(a5)
0055c2 : 0010 9780                : ori.b #$80,(a0)
0055c6 : 0010 0000                : ori.b #$0,(a0)
0055ca : 0008                     : dc.w $8
0055cc : 0000 0006                : ori.b #$6,d0
0055d0 : 0000 0004                : ori.b #$4,d0
0055d4 : 0000 0002                : ori.b #$2,d0
0055d8 : 0000 0002                : ori.b #$2,d0
**** START OF GLOBAL VARIABLES *****
