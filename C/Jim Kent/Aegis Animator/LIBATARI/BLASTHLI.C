
#include "..\\include\\lists.h"
#include "asm.i"

extern WORD *cscreen;

unsigned WORD lmasks[16] = 
	{
	0xffff, 0x7fff, 0x3fff, 0x1fff,
	0xfff, 0x7ff, 0x3ff, 0x1ff,
	0xff, 0x7f, 0x3f, 0x1f,
	0xf, 0x7, 0x3, 0x1,
	};

unsigned WORD rmasks[16] =
	{
	0x8000, 0xc000, 0xe000, 0xf000,
	0xf800, 0xfc00, 0xfe00, 0xff00,
	0xff80, 0xffc0, 0xffe0, 0xfff0,
	0xfff8, 0xfffc, 0xfffe, 0xffff,
	};

extern blast_hlines();

extern hline0();
extern hline1();
extern hline2();
extern hline3();
extern hline4(), hline5(), hline6(), hline7();
extern hline8(), hline9(), hlinea(), hlineb();
extern hlinec(), hlined(), hlinee(), hlinef();

(*hline_table[])() = {
	hline0, hline1, hline2, hline3,
	hline4, hline5, hline6, hline7,
	hline8, hline9, hlinea, hlineb,
	hlinec, hlined, hlinee, hlinef,
	};

#define first_param 7*4
#define thread1 first_param
#define thread2 first_param+4
#define highy	first_param+8
#define count	first_param+10
#define color	first_param+12

/*
blast_hlines(thread1, thread2, highy, count, color)
register WORD *thread1, *thread2;
WORD highy;
register WORD count;
WORD color;
{
register WORD *yaddr;
register (*hln)();
register WORD x1, x2;

hln = hline_table[color];
yaddr = cscreen + highy * 80;
thread2 += count;
while (--count >= 0)
	{
	x1 = *thread1++;
	x2 = *(--thread2);
	if (x1 > x2)
		(*hln)(yaddr, x2, x1);
	else
		(*hln)(yaddr, x1, x2);
	yaddr += 80;
	}
}
*/

asm	{

blast_hlines:
	movem.l	a2/a3/a4/a5/a6/d4,-(sp)

		;set a1 = screen address of first hline
	move.l	cscreen(a4),a1
	move.w	highy(sp),d0
	mulu	#160,d0
	adda	d0,a1

		;a2 and a3 go to the mask tables
	lea	lmasks(a4),a2
	lea	rmasks(a4),a3

		;a4 points to the hline associated with this color
	lea	hline_table(a4),a4	;cannabilize static data pointer
	move.w	color(sp),d0
	asl.w	#2,d0			;pointer addressing ... *4
	move.l	0(a4,d0),a4		; a4-> color based hline routine

	move.l	thread1(sp),a5
	move.l	thread2(sp),a6
	move.w	count(sp),d4
	adda	d4,a6	;	thread2 is backwards so skip to end of it
	adda	d4,a6
	bra	zblast_loop
blast_loop:	move.w	(a5)+,d2
	move.w	-(a6),d3
	cmp.w	d2,d3
	bgt	blast_noswap
	exg	d2,d3

blast_noswap:
		;a1 = line_addr + ((x1>>1)&0xfff8)
	move.l	a1,a0
	move.w	d2,d0
	asr.w	#1,d0
	and.w	#0xfff8,d0
	adda	d0,a0
	
		;d0 = count = (x2>>4) - (x1>>4)
	move.w	d3,d0
	asr.w	#4,d0
	move.w	d2,d1
	asr.w	#4,d1
	sub.w	d1,d0

		;mask out where in word endpoints are
	and.w	#0xf,d2
	and.w	#0xf,d3
		;word addressing of mask tables
	asl	#1,d2
	asl	#1,d3

	subq.w	#1,d0	;test for within one word (zero count)
	jsr	(a4)	;and jump to color specific routine

	adda	#160,a1
zblast_loop:	dbf	d4,blast_loop	
	movem.l (sp)+,a2/a3/a4/a5/a6/d4
	rts


hline0:	
		;if it's all in one word and the masks together and set it!
	bpl	hwords0
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hwords0:
			;set first word
	move.w	0(a2,d2.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	bra	hloopz0

hloop0:
	clr.l	(a0)+
	clr.l	(a0)+
hloopz0: dbf	d0,hloop0

	move.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hline1: 
		;if it's all in one word and the masks together and set it!
	bpl	hwords1
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hwords1:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+

	move.l	#0xffff0000,d1
	bra	hloopz1
hloop1:
	move.l	d1,(a0)+
	clr.l	(a0)+
hloopz1: dbf	d0,hloop1

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hline2: 
		;if it's all in one word and the masks together and set it!
	bpl	hwords2
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,4(a0)
	and.w	d1,6(a0)
	rts

hwords2:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	addq	#4,a0
	and.w	d1,(a0)+
	and.w	d1,(a0)+

	move.l	#0x0000ffff,d1
	bra	hloopz2
hloop2:
	move.l	d1,(a0)+
	clr.l	(a0)+
hloopz2: dbf	d0,hloop2
/*
hloopz2: subq #1,d0
	bgt	hloop2
*/
	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	addq	#4,a0
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts


hline3:
		;if it's all in one word and the masks together and set it!
	bpl	hwords3
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hwords3:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+

	move.l	#0xffffffff,d1
	bra	hloopz3
hloop3:
	move.l	d1,(a0)+
	clr.l	(a0)+
hloopz3: dbf	d0,hloop3

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts


hline4:
		;if it's all in one word and the masks together and set it!
	bpl	hwords4
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)
	addq	#4,a0
	and.w	d1,(a0)
	rts

hwords4:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	addq	#2,a0
	and.w	d1,(a0)+

	move.l	#0xffff0000,d1
	bra	hloopz4
hloop4:
	clr.l	(a0)+
	move.l	d1,(a0)+
hloopz4: dbf	d0,hloop4

	move.w	0(a3,d3.w),d1
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	addq	#2,a0
	and.w	d1,(a0)+
	rts


hline5:
		;if it's all in one word and the masks together and set it!
	bpl	hwords5
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,2(a0)
	and.w	d1,6(a0)
	rts

hwords5:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,2(a0)
	and.w	d1,6(a0)
	addq	#8,a0

	move.l	#0xffff0000,d1
	bra	hloopz5
hloop5:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
hloopz5: dbf	d0,hloop5

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,2(a0)
	and.w	d1,6(a0)
	rts


hline6:
		;if it's all in one word and the masks together and set it!
	bpl	hwords6
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,6(a0)
	rts

hwords6:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,6(a0)
	addq	#8,a0

	move.l	#0x0000ffff,d1
	move.l	#0xffff0000,d2
	bra	hloopz6
hloop6:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopz6: dbf	d0,hloop6

	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,6(a0)
	rts


hline7:
		;if it's all in one word and the masks together and set it!
	bpl	hwords7
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	rts

hwords7:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+

	move.l	#0xffffffff,d1
	move.l	#0xffff0000,d2
	bra	hloopz7
hloop7:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopz7: dbf	d0,hloop7

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	rts


hline8:	
		;if it's all in one word and the masks together and set it!
	bpl	hwords8
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)
	rts

hwords8:
			;set first word
	move.w	0(a2,d2.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)+

	move.l	#0x0000ffff,d1
	bra	hloopz8
hloop8:
	clr.l	(a0)+
	move.l	d1,(a0)+
hloopz8: dbf	d0,hloop8

	move.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)
	rts

hline9: 
		;if it's all in one word and the masks together and set it!
	bpl	hwords9
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts

hwords9:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)
	addq	#4,a0

	move.l	#0xffff0000,d1
	move.l	#0x0000ffff,d2
	bra	hloopz9
hloop9:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopz9: dbf	d0,hloop9

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts

hlinea: 
		;if it's all in one word and the masks together and set it!
	bpl	hwordsa
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,4(a0)
	rts

hwordsa:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,4(a0)
	addq	#8,a0

	move.l	#0x0000ffff,d1
	bra	hloopza
hloopa:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
hloopza: dbf	d0,hloopa
	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,4(a0)
	rts


hlineb:
		;if it's all in one word and the masks together and set it!
	bpl	hwordsb
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	rts

hwordsb:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	addq	#4,a0

	move.l	#0xffffffff,d1
	move.l	#0x0000ffff,d2
	bra	hloopzb
hloopb:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopzb: dbf	d0,hloopb

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	rts


hlinec:
		;if it's all in one word and the masks together and set it!
	bpl	hwordsc
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)+
	or.w	d1,(a0)
	rts

hwordsc:
			;set first word
	move.w	0(a2,d2.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+

	move.l	#0xffffffff,d1
	bra	hloopzc
hloopc:
	clr.l	(a0)+
	move.l	d1,(a0)+
hloopzc: dbf	d0,hloopc

	move.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)+
	or.w	d1,(a0)
	rts

hlined:
		;if it's all in one word and the masks together and set it!
	bpl	hwordsd
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,2(a0)
	rts

hwordsd:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,2(a0)
	addq	#8,a0

	move.l	#0xffff0000,d1
	move.l	#0xffffffff,d2
	bra	hloopzd
hloopd:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopzd: dbf	d0,hloopd

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,2(a0)
	rts


hlinee:
		;if it's all in one word and the masks together and set it!
	bpl	hwordse
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	rts

hwordse:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	addq	#8,a0

	move.l	#0x0000ffff,d1
	move.l	#0xffffffff,d2
	bra	hloopze
hloope:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopze: dbf	d0,hloope

	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	rts


hlinef:
		;if it's all in one word and the masks together and set it!
	bpl	hwordsf
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)
	rts

hwordsf:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+

	move.l	#0xffffffff,d1
	bra	hloopzf
hloopf:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
hloopzf: dbf	d0,hloopf

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)
	rts


}



/*
hline0(line_addr, x1, x2)
register unsigned WORD *line_addr;
register WORD x1, x2;
{
register WORD count;
register WORD data;

line_addr += ((x1>>4)<<2);
count = (x2>>4) - (x1>>4);
x1 &= 0xf;
x2 &= 0xf;
if (count == 0)
	{
	data = ~(lmasks[x1] & rmasks[x2]);
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	}
else
	{
	data = ~lmasks[x1];
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	while (--count > 0)
		{
		*line_addr++ = 0;	
		*line_addr++ = 0;	
		*line_addr++ = 0;	
		*line_addr++ = 0;	
		}
	data = ~rmasks[x2];
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	}
}
*/
