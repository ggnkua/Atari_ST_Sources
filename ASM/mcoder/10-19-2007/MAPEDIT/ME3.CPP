#include	<stdio.h>
#include	<process.h>
#include <string.h>
#include <iostream.h>
#include <fstream.h>
#include <dos.h>
#include <conio.h>
#include <alloc.h>

typedef unsigned char	uchar;
typedef unsigned int		uint;
const TRUE = 1;
const FALSE = 0;

const	TX = 640;
const TY = 400;
const	NCOL = 256;

int	nbutton;
int	mx, my, mk, curkey;

uchar	*blocs;
uchar	*image;
uchar	*ecran;
uchar	palette[3*NCOL];
uchar	font[2048];

const char
	M1 = 0xf,
	M4 = 15,
	M3 = 16,
	M2 = 0;

const	MAXBUT = 32;
struct ButtonList
{
	int	x1, y1, x2, y2;
	int	n, k;
} buttonlist[MAXBUT];
int curbut;
uchar	*plan = 0;
int	tx = 20, ty = 10,
		curx, cury;
char	petitbuffer[128];

void mouse_xy(int x, int y)
{
	asm {
	mov	ax, 4
	mov	cx, x
	add	cx, cx
	mov	dx, y
	int	33H
	}
}
init_mouse()
{
	asm {
	mov	ax, 0
	int	33H
	cmp	ax, 0ffffH
	jz		ok
	}
	cout << "Vous n'avez pas de driver de souris!\n";
	return FALSE;
ok:
	asm {	// D‚finie les limites de la souris
	mov	ax, 7
	mov	cx, 0
	mov	dx, TX*2*4-1
	int	33H
	mov	ax, 8
	mov	cx, 0
	mov	dx, TY*4-1
	int	33H

	mov	ax,0fH
	mov	cx,4
	mov	dx,8
	int	33H
	mov	ax,01aH
	mov	bx,255
	mov	cx,255
	int	33H

	}
	mouse_xy(TX/2, TY/2);
	return TRUE;
}
release()
{
	asm {
	mov	ax, 3
	push	es
	push	ds
	int	033H
	pop	ds
	pop	es
	}
	mx = _CX / 2 / 4;
	my = _DX / 4;
	mk = _BX;
	return _BX;
}

void showm()
{
/*	asm {
	mov	ax,1
	int	33H
	} */
}
void hidem()
{
/*	asm {
	mov	ax,2
	int	33H
	} */
}

int qkey()
{
	asm {
	mov	ah,1
	int	016H
	jnz		nokey
	sub	ax,ax
}nokey:	asm {
	}
	return _AX;
}
int getkey()
{
	asm {
	mov	ah,0
	int	016H
	}
	return _AX;
}

void setcolor(uchar ncol, uchar r, uchar g, uchar b)
{
	asm {

	mov	dx,03c8H
	mov	al,[ncol]
	out	dx,al
	inc	dl
	mov	al,r
	out	dx,al
	mov	al,g
	out	dx,al
	mov	al,b
	out	dx,al

	}
}

void Vsync()
{
asm	mov	dx,03daH
waitvbl:
	asm {

	in	al,dx
	test	al,8
	jz	waitvbl

	}

unwaitvbl:
	asm {

	in	al,dx
	test	al,8
	jnz	unwaitvbl

	}
}

void plot(int x, int y, uchar col)
{
	int a = (x >> 2) + y * (TX/4);
	asm {

	push	si
	push	di
	push	es

	mov	di,a
	mov	cl,BYTE PTR x
	and	cl,3
	mov	ah,1
	sal	ah,cl
	mov	dx,03c4H
	mov	al,2
	out	dx,ax
	mov	ax,0a000H
	mov	es,ax
	mov	al,col
	mov	[es:di],al

	pop	es
	pop	di
	pop	si

	}
}

void hline(int x1, int x2, int y, int col)
{
	hidem();
	if(x1 > x2)
	{
		int temp = x1;
		x1 = x2;
		x2 = temp;
	}

	if(y < 0 || y >= TY || x1 >= TX || x2 < 0)
		return;
	if(x1 < 0)
		x1 = 0;
	if(x2 >= TX)
		x2 = TX-1;

	char	mask2 = (1 << ((x2 & 3)+1)) - 1,
			mask1 = ~((1 << ((x1 & 3))) - 1);

	x1 = x1 >> 2;
	x2 = x2 >> 2;

	uchar *a = ecran + long(y)*(TX/4) + x1;

	x2 -= x1;
	if(x2>0)
	{
		asm {
		mov	ah,[mask1]
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		}
		*a++ = col;
		asm {
		mov	ah,0ffH
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		}
		while(x2-- > 1)
			*a++ = col;
		asm {
		mov	ah,[mask2]
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		}
		*a = col;
	}
	else
	{
		asm {
		mov	ah,[mask1]
		and	ah,[mask2]
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		}
		*a = col;
	}
	showm();
}

void vline(int y1, int y2, int x, int col)
{
	hidem();
	if(y1 > y2)
	{
		int temp = y1;
		y1 = y2;
		y2 = temp;
	}

	if(x < 0 || x >= TX || y1 >= TY || y2 < 0)
		return;
	if(y1 < 0)
		y1 = 0;
	if(y2 >= TY)
		y2 = TY-1;

	char mask = 1 << (x & 3);

	uchar *a = ecran + long(y1)*(TX/4) + (x >> 2);
	y2 -= y1;
	asm {
	mov	ah,[mask]
	mov	al,2
	mov	dx,03c4H
	out	dx,ax
	}
	while(y2-- >= 0)
	{
		*a = col;
		a += (TX/4);
	}
	showm();
}

void box(int x1, int y1, int x2, int y2, int col)
{
	hidem();
	if(y1 > y2)
	{
		int temp = y1;
		y1 = y2;
		y2 = temp;
	}
	if(x1 > x2)
	{
		int temp = x1;
		x1 = x2;
		x2 = temp;
	}
	if(y2 < 0 || y1 >= TY || x1 >= TX || x2 < 0)
		return;
	if(x1 < 0)
		x1 = 0;
	if(x2 >= TX)
		x2 = TX-1;
	if(y1 < 0)
		y1 = 0;
	if(y2 >= TY)
		y2 = TY-1;

	char	mask2 = (1 << ((x2 & 3)+1)) - 1,
			mask1 = ~((1 << (x1 & 3)) - 1);

	x1 = x1 >> 2;
	x2 = x2 >> 2;

	y2 -= y1;

	uchar *a = ecran + long(y1)*(TX/4) + x1;
	x2 -= x1;
	if(x2>0)
	{
		while(y2-- >= 0)
		{
			asm {
			mov	ah,[mask1]
			mov	al,2
			mov	dx,03c4H
			out	dx,ax
			}
			*a++ = col;
			asm {
			mov	ah,0ffH
			mov	al,2
			mov	dx,03c4H
			out	dx,ax
			}
			int c = x2;
			while(c-- > 1)
				*a++ = col;
			asm {
			mov	ah,[mask2]
			mov	al,2
			mov	dx,03c4H
			out	dx,ax
			}
			*a = col;
			a = a+(TX/4)-x2;
		}
	}
	else
	{
		while(y2-- >= 0)
		{
			asm {
			mov	ah,[mask1]
			and	ah,[mask2]
			mov	al,2
			mov	dx,03c4H
			out	dx,ax
			}
			*a = col;
			a = a+(TX/4);
		}
	}
	showm();
}

void affcar(int x, unsigned int y, int car, char col)
{
	uchar	*a = ecran + y*(TX/4) + (x>>2), *b = font + car*8;
	int d = x&3;
	y = 8;
	while(y--)
	{
		unsigned int c = (*b++) << d;
		asm {
		push	dx
		push	ax
		mov	dx,03c4H
		mov	al,2
		mov	ah,BYTE PTR c
		out	dx,ax
		pop	ax
		pop	dx
		}
		*a++ = col;
		c = c >> 4;
		asm {
		push	dx
		push	ax
		mov	dx,03c4H
		mov	al,2
		mov	ah,BYTE PTR c
		out	dx,ax
		pop	ax
		pop	dx
		}
		*a++ = col;
		c = c >> 4;
		asm {
		push	dx
		push	ax
		mov	dx,03c4H
		mov	al,2
		mov	ah,BYTE PTR c
		out	dx,ax
		pop	ax
		pop	dx
		}
		*a++ = col;
		a = a+(TX/4)-3;
	}
}

void afftext(int x, int y, char *t, int c)
{
	uchar a;
	while((a = *t++) != 0)
	{
		affcar(x, y, a, c);
		x += 8;
	}
}

void affbloc(int x, int y, int nb)
{
	uchar *a = blocs + nb*16;
	uchar *b = ecran + long(y)*(32*TX/4) + (x<<3);
	asm {
	push	si
	push	di
	push	es
	push	ds

	mov	cx,16
	lds	si,[a]
	les	di,[b]
;	les	di,[ecran]
;	mov	di,[x]
;	add	di,di
;	add	di,di
;	add	di,di
;	mov	ax,[y]
;	mov	dx,32*TX/4
	mov	dx,03c4H
	mov	al,2
	out	dx,al
	inc	dx
}loop:	asm {
	mov	al,3
	out	dx,al

	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	sub	si,14
	sub	di,8

	mov	al,12
	out	dx,al

	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb

	sub	si,16
	add	di,TX/4-8

	mov	al,3
	out	dx,al

	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	sub	si,14
	sub	di,8

	mov	al,12
	out	dx,al

	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb
	inc	si
	movsb

	add	si,320-16
	add	di,TX/4-8
	loop	loop

	pop	ds
	pop	es
	pop	di
	pop	si
	}
}

void scroll(uchar *a, uchar *b, uint nloop, int sens)
{
	asm {
		push	es
		push	ds

		mov	ah,M2
		mov	al,8
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M3
		mov	al,3
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M1
		mov	al,2
		mov	dx,03c4H
		out	dx,ax

		mov	cx,[nloop]
		cld
		mov	ax,[sens]
		jnz		ok
		std
}ok:	asm {
		lds	si,[a]
		les	di,[b]
		rep	movsb

		mov	ah,0ffH
		mov	al,8
		mov	dx,03ceH
		out	dx,ax
		mov	ah,0
		mov	al,3
		mov	dx,03ceH
		out	dx,ax

		pop	ds
		pop	es
	}
}

void addselect(int x1, int y1, int x2, int y2, int nbut, int key = 0)
{
	if(nbut)
	{
		buttonlist[curbut].x1 = x1;
		buttonlist[curbut].y1 = y1;
		buttonlist[curbut].x2 = x2;
		buttonlist[curbut].y2 = y2;
		buttonlist[curbut].n = nbut;
		buttonlist[curbut].k = key;
		curbut++;
	}
}
void button(int x1, int y1, int x2, int y2, int nbut = 0, int key = 0)
{
	box(x1, y1, x2, y2, 4);
	hline(x1+1, x2-1, y1, 6);
	hline(x1+2, x2-2, y1+1, 5);
	hline(x1+1, x2-1, y2, 2);
	hline(x1+2, x2-2, y2-1, 3);
	vline(y1+1, y2-1, x1, 6);
	vline(y1+2, y2-2, x1+1, 5);
	vline(y1+1, y2-1, x2, 2);
	vline(y1+2, y2-2, x2-1, 3);
	plot(x1, y1, 7);
	plot(x2, y2, 2);
	plot(x1+1, y1+1, 6);
	plot(x2-1, y2-1, 2);
	addselect(x1, y1, x2, y2, nbut, key);
}

void button2(int x1, int y1, int x2, int y2, int nbut = 0, int key = 0)
{
	box(x1, y1, x2, y2, 4);
	hline(x1+1, x2-1, y1, 6);
	hline(x1+1, x2-1, y2, 2);
	vline(y1+1, y2-1, x1, 6);
	vline(y1+1, y2-1, x2, 2);
	plot(x1, y1, 7);
	plot(x2, y2, 2);
	addselect(x1, y1, x2, y2, nbut, key);
}

void butext(int x, int y, int l, char *t, int nbut = 0, int key = 0)
{
	button(x, y, x+l-1, y+13, nbut, key);
	afftext(x+(l-strlen(t)*8)/2, y+3, t, 255);
}

int mouse()
{
	int key;
	hidem();
	do
	{
/*		if(mk == 2)
		{
			M4++;
			while(release() == 2);
		} */
		int	a = (my)*(TX/4) + ((mx) >> 2);
		int 	n, clipy = 16;
		if(my > 400-16)
			clipy = 400-my;
		asm {
		mov	ax,[a]
		push	si
		push	di

		mov	si,ax
		mov	di,64000
		push	es
		push	ds

		mov	ah,M2
		mov	al,8
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M3
		mov	al,3
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M1
		mov	al,2
		mov	dx,03c4H
		out	dx,ax

		mov	cx,clipy
		mov	ax,0a000H
		mov	es,ax
		mov	ds,ax
}l:	asm {
		push	cx
		mov	cx,5
		rep	movsb
		add	si,TX/4-5
		pop	cx
		loop	l

		mov	ah,0ffH
		mov	al,8
		mov	dx,03ceH
		out	dx,ax
		mov	ah,0
		mov	al,3
		mov	dx,03ceH
		out	dx,ax
		pop	ds
		pop	es
		pop	di
		pop	si
		}

		hline(mx+1, mx+15-1, my+1, 255);
		hline(mx+1, mx+15, my, 0);
		hline(mx+2, mx+15-2, my+2, 0);
		vline(my+1, my+15-1, mx+1, 255);
		vline(my+1, my+15, mx, 0);
		vline(my+2, my+15-2, mx+2, 0);

		Vsync();
		asm {
		mov	ax,[a]
		push	si
		push	di

		mov	di,ax
		mov	si,64000
		push	es
		push	ds

		mov	ah,M2
		mov	al,8
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M3
		mov	al,3
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M1
		mov	al,2
		mov	dx,03c4H
		out	dx,ax

		mov	cx,clipy
		mov	ax,0a000H
		mov	es,ax
		mov	ds,ax
}ll:	asm {
		push	cx
		mov	cx,5
		rep	movsb
		add	di,TX/4-5
		pop	cx
		loop	ll

		mov	ah,0ffH
		mov	al,8
		mov	dx,03ceH
		out	dx,ax
		mov	ah,0
		mov	al,3
		mov	dx,03ceH
		out	dx,ax
		pop	ds
		pop	es
		pop	di
		pop	si
		}
	}
	while(release() != 1 && !(key = qkey()));
	curkey = 0;
	while(qkey())
		curkey = getkey();
	return mk;
}

void Transfer4Plan(int pal, int im)
{
	int m;
	for(m = 0 ; m < 16 ; m++)
		setcolor(m + 16, image[pal+m*2] << 3, (image[pal+m*2+1] & 0x070) >> 1, (image[pal+m*2+1] & 0x007) << 3);
	uchar *a = blocs + 64000L;
	uchar *b = (uchar *)image + 32000 + im;
	int x = 20*200, xx;
	while(x--)
	{
		xx = 16;
		int pl3 = *--b + (*--b << 8);
		int pl2 = *--b + (*--b << 8);
		int pl1 = *--b + (*--b << 8);
		int pl0 = *--b + (*--b << 8);
		while(xx--)
		{
			*--a = ((pl0 & 1) | ((pl1 & 1) << 1) | ((pl2 & 1) << 2) | ((pl3 & 1) << 3)) + 16;
			pl0 = pl0 >> 1;
			pl1 = pl1 >> 1;
			pl2 = pl2 >> 1;
			pl3 = pl3 >> 1;
		}
	}
}

void init_video()
{
	asm {		// Passage en mode 13H (320*200 256 couleurs)

	push	si
	push	di

	mov	ax,0005cH
	int	10H

	mov	dx,03c4H
	mov	ax,0604H
	out	dx,ax
;	mov	dx,03ceH
;	mov	ax,4005H
;	out	dx,ax

;	mov	al,06
;	out	dx,al
;	inc	dl
;	in		al,dx
;	and	al,0fdH
;	out	dx,al

	mov	dx,03d4H
	mov	al,014H
	out	dx,al
	inc	dl
	in		al,dx
	and	al,0bfH
;	or		al,00100000b
	out	dx,al

	dec	dl
	mov	al,017H
	out	dx,al
	inc	dl
	in		al,dx
	or		al,040H
	out	dx,al

;	mov	dx,03ceH
;	mov	al,08H
;	out	dx,al
;	inc	dl
;	mov	al,0ffH
;	out	dx,al

	mov	dx,03c4H
	mov	al,02H
	out	dx,al
	inc	dl
	mov	al,0fH
	out	dx,al

	mov	dx,03ceH
	mov	al,3
	out	dx,al
	inc	dx
	in		al,dx

	pop	di
	pop	si

	}
}

void erreur(char *a)
{
	butext(100, 170, 440, a);
	mouse();

	asm {
		mov	ax, 03H
		int	10H
	}

	exit(1);
}

void invert_font()
{
	int n;
	uchar *a = font;
	for(n = 0 ; n < 256*8 ; n++)
	{
		char b = *a, d = 0;
		int c = 8;
		while(c--)
		{
			d = d+d + (b&1);
			b = b>>1;
		}
		*a++ = d;
	}
}

void relmouse()
{
	while(release());
}

int box_manager()
{
	for(;;)
	{
		while(mouse() != 1 && !curkey);
		if((curkey&0xff) <= 'Z' && (curkey&0xff) >= 'A')
			curkey += 'a' - 'A';
		for(int n = 0 ; n < curbut ; n++)
		{
			if(
			(mk == 1 &&
			mx >= buttonlist[n].x1 &&
			my >= buttonlist[n].y1 &&
			mx <= buttonlist[n].x2 &&
			my <= buttonlist[n].y2) ||
			((curkey & 0xff) == buttonlist[n].k && (curkey & 0xff))
			)
			{
				return buttonlist[n].n;
			}
		}
	}
}

void new_plan()
{
	if(plan)
		delete plan;
	plan = (uchar *) calloc(tx, ty);
	if(!plan)
		erreur("M‚moire insufisante pour le plan!");
}

int qsur()
{
	curbut = 0;
	button2(250, 320, 639-250, 380);
	afftext(320-14*4, 330, "Etes vous sur?", 0);
	butext(290, 360, 640-290*2, "Oui!", 1, 13);
	addselect(0, 0, TX, TY, -1, 27);
	int a = box_manager();
	relmouse();
	return(a);
}

void mainbox()
{
	curbut = 0;
	Vsync();
	button2(0, 288, 639, 399);
	butext(4, 384, 70, "Quitter", 1, 'q');
	sprintf(petitbuffer, "M‚moire libre: %dK", int(coreleft()/1024));
	afftext(4, 292, petitbuffer, 0);
	sprintf(petitbuffer, "TX: %4d | TY: %4d", tx, ty);
	afftext(4, 302, petitbuffer, 0);
	sprintf(petitbuffer, " X: %4d |  Y: %4d", curx, cury);
	afftext(4, 312, petitbuffer, 0);
	butext(4, 364, 100, "Scrolling", 2, ' ');
}

main()
{
	int	n, m;

	if(!init_mouse())
		return 1;

	image = (uchar *) calloc(320, 200);
	blocs = (uchar *) calloc(320, 200);
	ecran = (uchar *) MK_FP(0xa000, 0000);
	if(!image || !blocs)
	{
		cout << "m‚moire insufisante...\n";
		return 1;
	}

	ifstream in("tableau2.pi1", ios::binary);
	in.read(image, 32000);
	in.close();
	in.open("8x8.set", ios::binary);
	in.read(font, 2048);
	in.close();
	invert_font();

	init_video();

	Vsync();
	Transfer4Plan(2, 34);

	setcolor(255, 63, 63, 63);
	setcolor(15, 48, 48, 48);
	setcolor(1, 10-5, 10, 10);
	setcolor(2, 20-5, 20, 20);
	setcolor(3, 30-5, 30, 30);
	setcolor(4, 40-5, 40, 40);
	setcolor(5, 50-5, 50, 50);
	setcolor(6, 60-5, 60, 60);
	setcolor(7, 63-5, 63, 63);

	new_plan();

	box(0, 0, 639, 399, 0);

	int x, y;
//	uchar *a = plan;
	for(x = 0 ; x < 20 ; x++)
		for(y = 0; y < 9 ; y++)
			affbloc(x, y, x + 20*16*y);

	mainbox();
	do
	{
		x = box_manager();
		switch(x)
		{
		case 1:
			relmouse();
			x = qsur();
			mainbox();
			break;
		case 2:
			scroll(ecran+8, ecran, 288*(TX/4), 0);
			break;
		}
	}
	while(x != 1);

	asm {
		mov	ax, 03H
		int	10H
	}
	qkey();

	return 0;
}

