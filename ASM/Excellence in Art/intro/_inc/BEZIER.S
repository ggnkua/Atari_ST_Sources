
;bezsteps equ 32 ; needs to be power of 2

bezfixpointdepth equ 10 ; sorry, you can't change this, it'll just bomb
	ifgt bezfixpointdepth-8
bezfixpointdepth1 equ 8
bezfixpointdepth2 equ bezfixpointdepth-bezfixpointdepth1
	endc
bezfixpointval equ 1024
bezfixpointstep equ 1024/bezsteps

bezfmul macro
	muls.w \1,\2
	ifgt bezfixpointdepth-8
	asr.l #bezfixpointdepth1,\2
	asr.l #bezfixpointdepth2,\2
	else
	asr.l #bezfixpointdepth,\2
	endc
	endm

bezfmuln macro    ; like fmul, but doesn`t shift down
	muls.w \1,\2
	endm


bezierpoint
; In: bezAx, bezAy, bezB,C,D (etc) - points forming cubic bezier curve
;     d5 - a
;     d6 - b
; Out:d0 - x, upshifted #bezfixpointdepth bits
;     d1 - y, also upshifted
; Destroys: d2-d3

		;		for(int i = 0; i <= 20; i++)
		;		{
		;		  // Get a point on the curve
		;		  X = Ax*a*a*a + Bx*3*a*a*b + Cx*3*a*b*b + Dx*b*b*b;
		;		  Y = Ay*a*a*a + By*3*a*a*b + Cy*3*a*b*b + Dy*b*b*b;
		;		  Z = Az*a*a*a + Bz*3*a*a*b + Cz*3*a*b*b + Dz*b*b*b;
		;  
		;		  // Draw the line from point to point (assuming OGL is set up properly)
		;		  glVertex3d(X, Y, Z);
		;
		;		  // Change the variable
		;		  a -= 0.05;
		;		  b = 1.0 - a;
		;		}

;---precalc a*a
	move.l d5,d0
	bezfmul d0,d0
	move.l d0,bezaa
;---precalc a*a*a
	bezfmul d5,d0
	move.l d0,bezaaa
;---precalc b*b
	move.l d6,d0
	bezfmul d0,d0
	move.l d0,bezbb
;---precalc b*b*b
	bezfmul d6,d0
	move.l d0,bezbbb
;---precalc 3*a*a*b
	move.l #3*bezfixpointval,d0
	move.l bezaa,d1
	bezfmul d1,d0
	bezfmul d6,d0
	move.l d0,bez3aab
;---precalc 3*a*b*b
	move.l #3*bezfixpointval,d0
	bezfmul d5,d0
	move.l bezbb,d1
	bezfmul d1,d0
	move.l d0,bez3abb

; X = Ax*a*a*a + Bx*3*a*a*b + Cx*3*a*b*b + Dx*b*b*b;

;---Ax*a*a*a
	move.l bezAx,d0
	move.l bezaaa,d1
	bezfmuln d1,d0
;---...+Bx*3*a*a*b
	move.l bezBx,d1
	move.l bez3aab,d2
	bezfmuln d2,d1
	add.l d1,d0
;---...+Cx*3*a*b*b
	move.l bezCx,d1
	move.l bez3abb,d2
	bezfmuln d2,d1
	add.l d1,d0
;---...+Dx*b*b*b
	move.l bezDx,d1
	move.l bezbbb,d2
	bezfmuln d2,d1
	add.l d1,d0

; Y = Ay*a*a*a + By*3*a*a*b + Cy*3*a*b*b + Dy*b*b*b;

;---Ay*a*a*a
	move.l bezAy,d1
	move.l bezaaa,d2
	bezfmuln d2,d1
;---...+By*3*a*a*b
	move.l bezBy,d2
	move.l bez3aab,d3
	bezfmuln d3,d2
	add.l d2,d1
;---...+Cy*3*a*b*b
	move.l bezCy,d2
	move.l bez3abb,d3
	bezfmuln d3,d2
	add.l d2,d1
;---...+Dy*b*b*b
	move.l bezDy,d2
	move.l bezbbb,d3
	bezfmuln d3,d2
	add.l d2,d1

	rts


bezAx	ds.l 1
bezAy	ds.l 1
bezBx	ds.l 1
bezBy	ds.l 1
bezCx	ds.l 1
bezCy	ds.l 1
bezDx	ds.l 1
bezDy	ds.l 1
bezCol ds.l 1
bezaa ds.l 1
bezbb	ds.l 1
bezaaa ds.l 1
bez3aab ds.l 1
bez3abb ds.l 1
bezbbb ds.l 1


