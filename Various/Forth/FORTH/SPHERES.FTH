( Spheres.fth
  Forth equivalent of Don Krell's article Aug '86 ST Applications)

decimal
72 user TaskWindow	( will be used for getting valid coords)

variable cliprect 4 vallot

: SetClipping ( using current window, set a clipping rectangle. Also
		sets up the min and max dimensions for drawing.)

	{ | xy wh addr }
	TaskWindow @ 20 + -> addr	( addr of work area dimensions)
	addr @ -> xy		( get the work area dimensions of window)
	addr 4 + @ -> wh	( width/height of work area)
	xy clipRect !
	xy clipRect 4 + !
	wh clipRect 4 + +!	( clipRect is now a rectangle record)
	clipRect 1 call vsClip	( so set clipping to it)
				
	;

: drawSphere { xc yc r | rd dec }
	1 call vsfcolor	drop	( sets perimeter to black)
	0 call vsfinterior drop	( hollow fill)
	xc yc 0 0 r 0 call vcircle	( first blot out anything behind)
	2 call vswrmode drop	( now draw overlapping ellipses)
	r 4 / negate -> dec
	r -> rd
	4 0 do
		dec add-> rd
		xc yc rd r call vellipse
		xc yc r rd call vellipse
	loop
	1 call vswrmode drop	( restore to good writing mode)
	;

: nextX ( - x )
	clipRect 4 + w@ ( maxx)
	clipRect w@ ( minx)
	-
	call random 1023 and	( random number from 0-1023)
	1024 */
	clipRect w@ +
	;

: nextY ( - y )
	clipRect 6 + w@ ( maxx)
	clipRect 2+ w@ ( minx)
	-
	call random 1023 and	( random number from 0-1023)
	1024 */
	clipRect 2+ w@ +
	;

: nextR ( - r )
	call random 127 and
	;

: go 	setClipping	( so drawing isn't outside of current window)
	20 0 do		( now draw 20 random 'spheres')
		nextX	( get a random x in the window)
		nextY	( get a random y in the window)
		nextR	( get a random radius)
		drawSphere
	loop
	clipRect 0 call vsClip	( turn clipping back off)
	;

CR .( Type 'go' to run)
CR