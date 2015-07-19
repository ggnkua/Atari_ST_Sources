#include <iostream.h>
#include <fstream.h>
#include <dos.h>
#include <conio.h>
#include <alloc.h>

const TRUE = 1;
const FALSE = 0;

const	TX = 640;
const TY = 400;
const	NCOL = 256;

int	nbutton;
int	mx, my, mk;

char	*blocs;
char	*image;
char	*ecran;
char	palette[3*NCOL];

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
	mov	dx, TX*2-1
	int	33H
	mov	ax, 8
	mov	cx, 0
	mov	dx, TY-1
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
	mx = _CX / 2;
	my = _DX;
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

void setcolor(unsigned char ncol, unsigned char r, unsigned char g, unsigned char b)
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

void plot(int x, unsigned char y, unsigned char col)
{
	asm {

	push	si
	push	di
	push	es

	mov	di,x
	mov	cl,BYTE PTR x
	and	cl,3
	mov	ah,1
	sal	ah,cl
	sar	di,2
	mov	dx,03c4H
	mov	al,2
	out	dx,ax
	mov	al,y
	mov	dl,TX/4
	mul	dl
	add	di,ax
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

	char *a = ecran + long(y)*TX/4 + x1;

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

	char *a = ecran + long(y1)*TX/4 + (x >> 2);
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
		a += TX/4;
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

	char *a = ecran + long(y1)*TX/4 + x1;
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
			a = a+TX/4-x2;
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
			a = a+TX/4;
		}
	}
	showm();
}

const char
	M1 = 0x01,
	M2 = 0x02,
	M3 = 0x04,
	M4 = 0x08;

int mouse()
{
	hidem();
	while(!release())
	{
		int	a = (my-8)*(TX/4) + ((mx-8) >> 2);
		int 	n;
		asm {
		mov	ax,[a]
		push	si
		push	di

		mov	si,ax
		mov	di,64000
		push	es
		push	ds

		mov	ax,0a000H
		mov	es,ax
		mov	ds,ax
		mov	cx,16
}l:	asm {
		push	cx
		mov	ah,0
		mov	al,4
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M1
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		mov	cx,5
		rep	movsb
		sub	si,5
		mov	ah,1
		mov	al,4
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M2
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		mov	cx,5
		rep	movsb
		sub	si,5
		mov	ah,2
		mov	al,4
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M3
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		mov	cx,5
		rep	movsb
		sub	si,5
		mov	ah,3
		mov	al,4
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M4
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		mov	cx,5
		rep	movsb
		add	si,TX/4-5
		pop	cx
		loop	l

		pop	ds
		pop	es
		pop	di
		pop	si
		}
		hline(mx-8, mx+8-1, my, 15);
		vline(my-8, my+8-1, mx, 15);
		Vsync();
		asm {
		mov	ax,[a]
		push	si
		push	di

		mov	di,ax
		mov	si,64000
		push	es
		push	ds

		mov	ax,0a000H
		mov	es,ax
		mov	ds,ax
		mov	cx,16
}ll:	asm {
		push	cx
		mov	ah,0
		mov	al,4
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M1
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		mov	cx,5
		rep	movsb
		sub	di,5
		mov	ah,1
		mov	al,4
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M2
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		mov	cx,5
		rep	movsb
		sub	di,5
		mov	ah,2
		mov	al,4
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M3
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		mov	cx,5
		rep	movsb
		sub	di,5
		mov	ah,3
		mov	al,4
		mov	dx,03ceH
		out	dx,ax
		mov	ah,M4
		mov	al,2
		mov	dx,03c4H
		out	dx,ax
		mov	cx,5
		rep	movsb
		add	di,TX/4-5
		pop	cx
		loop	ll

		pop	ds
		pop	es
		pop	di
		pop	si
		}
	}
	return mk;
}

void Transfer4Plan(int pal, int im)
{
	int m;
	for(m = 0 ; m < 16 ; m++)
		setcolor(m + 16, image[pal+m*2] << 3, (image[pal+m*2+1] & 0x070) >> 1, (image[pal+m*2+1] & 0x007) << 3);
	char *a = blocs + 64000L;
	unsigned char *b = (unsigned char *)image + 32000 + im;
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
;	in	al,dx
;	and	al,0fdH
;	out	dx,al

	mov	dx,03d4H
	mov	al,014H
	out	dx,al
	inc	dl
	in	al,dx
	and	al,0bfH
;	or	al,00100000b
	out	dx,al

	dec	dl
	mov	al,017H
	out	dx,al
	inc	dl
	in	al,dx
	or	al,040H
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

	pop	di
	pop	si

	}
}

main()
{
	int	m;

	if(!init_mouse())
		return 1;

	image = (char *) calloc(320, 200);
	blocs = (char *) calloc(320, 200);
	ecran = (char *) MK_FP(0xa000, 0000);
	if(!image || !blocs)
	{
		cout << "m‚moire insufisante...\n";
		return 1;
	}

	ifstream in("brique2.pi1", ios::binary);
	in.read(image, 32000);
	in.close();

	init_video();

	Vsync();
	Transfer4Plan(2, 34);

/*	for(m = 0 ; m < 255 ; m++)
	{
		asm push si
		asm push di
		asm push cx

		_SI = palette[m*3];
		_DI = palette[m*3+1];
		_CL = palette[m*3+2];
		asm push dx
		_DX = 0x3c8;
		_AL = m;
		asm out dx, al
		asm inc dl
		_AL = _SI;
		asm out dx, al
		_AL = _DI;
		asm out dx, al
		_AL = _CL;
		asm out dx, al

		asm pop dx
		asm pop cx
		asm pop di
		asm pop si
	} */
	setcolor(255, 63, 63, 63);
	setcolor(15, 48, 48, 48);

	showm();
	hline(0, 639, 0, 15);
	vline(0, 399, 0, 14);
	hline(0, 639, 399, 13);
	vline(0, 399, 639, 12);
	box(1, 1, 638, 398, 11);
	for(m=0 ; m<100 ; m++)
		hline(320-m, 320+m, m, m);

/*	plot(0, 0, 1);
	plot(1, 0, 2);
	plot(2, 0, 3);
	plot(3, 0, 4);
	int col;

	for(unsigned char n = 0 ; n < 255 ; n++)
	{
		asm {
		push	ax
		push	dx
		mov	ah,[n]
		mov	al,8
		mov	dx,03ceH
		out	dx,ax
		pop	dx
		pop	ax
		}
		if((col = *ecran) != 1)
			break;
	} */
	mouse();

	asm {
		mov	ax, 03H
		int	10H
	}

//	cout << col << "\n" << (int) n << "\n";

	return 0;
}

