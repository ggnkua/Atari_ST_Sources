
	; This file just contains a table for doing a 4x zoom.  Basically you
	; take a byte in and convert it to a long word (4 bytes) on output.
	; However I could write the routine to zoom on the ST a little faster
	; if the low and hi-order words were reversed ... so they are.

	dseg
	public _zoomtab
_zoomtab
	dc.l	$00000000,$000f0000,$00f00000,$00ff0000
	dc.l	$0f000000,$0f0f0000,$0ff00000,$0fff0000
	dc.l	$f0000000,$f00f0000,$f0f00000,$f0ff0000
	dc.l	$ff000000,$ff0f0000,$fff00000,$ffff0000
	dc.l	$0000000f,$000f000f,$00f0000f,$00ff000f
	dc.l	$0f00000f,$0f0f000f,$0ff0000f,$0fff000f
	dc.l	$f000000f,$f00f000f,$f0f0000f,$f0ff000f
	dc.l	$ff00000f,$ff0f000f,$fff0000f,$ffff000f
	dc.l	$000000f0,$000f00f0,$00f000f0,$00ff00f0
	dc.l	$0f0000f0,$0f0f00f0,$0ff000f0,$0fff00f0
	dc.l	$f00000f0,$f00f00f0,$f0f000f0,$f0ff00f0
	dc.l	$ff0000f0,$ff0f00f0,$fff000f0,$ffff00f0
	dc.l	$000000ff,$000f00ff,$00f000ff,$00ff00ff
	dc.l	$0f0000ff,$0f0f00ff,$0ff000ff,$0fff00ff
	dc.l	$f00000ff,$f00f00ff,$f0f000ff,$f0ff00ff
	dc.l	$ff0000ff,$ff0f00ff,$fff000ff,$ffff00ff
	dc.l	$00000f00,$000f0f00,$00f00f00,$00ff0f00
	dc.l	$0f000f00,$0f0f0f00,$0ff00f00,$0fff0f00
	dc.l	$f0000f00,$f00f0f00,$f0f00f00,$f0ff0f00
	dc.l	$ff000f00,$ff0f0f00,$fff00f00,$ffff0f00
	dc.l	$00000f0f,$000f0f0f,$00f00f0f,$00ff0f0f
	dc.l	$0f000f0f,$0f0f0f0f,$0ff00f0f,$0fff0f0f
	dc.l	$f0000f0f,$f00f0f0f,$f0f00f0f,$f0ff0f0f
	dc.l	$ff000f0f,$ff0f0f0f,$fff00f0f,$ffff0f0f
	dc.l	$00000ff0,$000f0ff0,$00f00ff0,$00ff0ff0
	dc.l	$0f000ff0,$0f0f0ff0,$0ff00ff0,$0fff0ff0
	dc.l	$f0000ff0,$f00f0ff0,$f0f00ff0,$f0ff0ff0
	dc.l	$ff000ff0,$ff0f0ff0,$fff00ff0,$ffff0ff0
	dc.l	$00000fff,$000f0fff,$00f00fff,$00ff0fff
	dc.l	$0f000fff,$0f0f0fff,$0ff00fff,$0fff0fff
	dc.l	$f0000fff,$f00f0fff,$f0f00fff,$f0ff0fff
	dc.l	$ff000fff,$ff0f0fff,$fff00fff,$ffff0fff
	dc.l	$0000f000,$000ff000,$00f0f000,$00fff000
	dc.l	$0f00f000,$0f0ff000,$0ff0f000,$0ffff000
	dc.l	$f000f000,$f00ff000,$f0f0f000,$f0fff000
	dc.l	$ff00f000,$ff0ff000,$fff0f000,$fffff000
	dc.l	$0000f00f,$000ff00f,$00f0f00f,$00fff00f
	dc.l	$0f00f00f,$0f0ff00f,$0ff0f00f,$0ffff00f
	dc.l	$f000f00f,$f00ff00f,$f0f0f00f,$f0fff00f
	dc.l	$ff00f00f,$ff0ff00f,$fff0f00f,$fffff00f
	dc.l	$0000f0f0,$000ff0f0,$00f0f0f0,$00fff0f0
	dc.l	$0f00f0f0,$0f0ff0f0,$0ff0f0f0,$0ffff0f0
	dc.l	$f000f0f0,$f00ff0f0,$f0f0f0f0,$f0fff0f0
	dc.l	$ff00f0f0,$ff0ff0f0,$fff0f0f0,$fffff0f0
	dc.l	$0000f0ff,$000ff0ff,$00f0f0ff,$00fff0ff
	dc.l	$0f00f0ff,$0f0ff0ff,$0ff0f0ff,$0ffff0ff
	dc.l	$f000f0ff,$f00ff0ff,$f0f0f0ff,$f0fff0ff
	dc.l	$ff00f0ff,$ff0ff0ff,$fff0f0ff,$fffff0ff
	dc.l	$0000ff00,$000fff00,$00f0ff00,$00ffff00
	dc.l	$0f00ff00,$0f0fff00,$0ff0ff00,$0fffff00
	dc.l	$f000ff00,$f00fff00,$f0f0ff00,$f0ffff00
	dc.l	$ff00ff00,$ff0fff00,$fff0ff00,$ffffff00
	dc.l	$0000ff0f,$000fff0f,$00f0ff0f,$00ffff0f
	dc.l	$0f00ff0f,$0f0fff0f,$0ff0ff0f,$0fffff0f
	dc.l	$f000ff0f,$f00fff0f,$f0f0ff0f,$f0ffff0f
	dc.l	$ff00ff0f,$ff0fff0f,$fff0ff0f,$ffffff0f
	dc.l	$0000fff0,$000ffff0,$00f0fff0,$00fffff0
	dc.l	$0f00fff0,$0f0ffff0,$0ff0fff0,$0ffffff0
	dc.l	$f000fff0,$f00ffff0,$f0f0fff0,$f0fffff0
	dc.l	$ff00fff0,$ff0ffff0,$fff0fff0,$fffffff0
	dc.l	$0000ffff,$000fffff,$00f0ffff,$00ffffff
	dc.l	$0f00ffff,$0f0fffff,$0ff0ffff,$0fffffff
	dc.l	$f000ffff,$f00fffff,$f0f0ffff,$f0ffffff
	dc.l	$ff00ffff,$ff0fffff,$fff0ffff,$ffffffff

