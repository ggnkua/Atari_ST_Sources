****************************************************************
* Assembly-playroutine for tunes composed with the -Megatizer- *
*      Coded by Jedi of Sector One from The Heavy Killers      *
*   If you use this kind of music in a public-domain program,  *
*    please credit me and my utility... If it's destined to    *
*          commercial stuff, you must get my agreement.        *
****************************************************************

	clr.l -(sp)
	move #$20,-(sp)
	trap #1
	move.l d0,2(sp)
	bsr.s music
	move.l #music+8,$4d2.w
	move #7,-(sp)
	trap #1
	addq.l #2,sp
	clr.l $4d2.w
	bsr.s music+4
	move.b #15,$484.w
	trap #1
	addq.l #4,sp
	clr (sp)
	trap #1
music	incbin dedicace.thk