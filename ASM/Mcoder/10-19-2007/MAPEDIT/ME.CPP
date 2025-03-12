#include <stdlib.h>
#include <stdio.h>
#include <process.h>
#include <string.h>
#include <iostream.h>
#include <fstream.h>
#include <dos.h>
#include <conio.h>
#include <alloc.h>

typedef unsigned char	uchar;
typedef unsigned int		uint;
typedef unsigned long	ulong;
const TRUE = 1;
const FALSE = 0;

const	TX = 320;
const TY = 200;
const	NCOL = 256;

int	nbutton;
int	mx, my, mk, curkey;

uchar	*blocs;
uchar	*image;
uchar	*ecran, *ecran1, *ecran2, *ecran3;
uchar	palette[3*NCOL];
uchar	font[6*256];

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
struct plan_struct
{
	uchar	*p;
	unsigned	int	tx, ty;
				int	curx, cury;
	char	name[32];
} plans[10], *cp = &plans[0];
int np = 0, cb = 1, hp = 9, ohp = 9;
char	petitbuffer[128];
int noaff = FALSE;

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
	cout << "Vous n'avez pas install‚ de souris!\n";
	return FALSE;
ok:
	asm {	// D‚finie les limites de la souris
	mov	ax, 7
	mov	cx, 0
	mov	dx, TX-1
	int	33H
	mov	ax, 8
	mov	cx, 0
	mov	dx, TY-1
	int	33H

	mov	ax,0fH
	mov	cx,4
	mov	dx,8
//	int	33H
	mov	ax,01aH
	mov	bx,255
	mov	cx,255
//	int	33H

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
	mx = _CX;
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

/*unwaitvbl:
	asm {

	in	al,dx
	test	al,8
	jnz	unwaitvbl

	} */
}

void setpage(char p)
{
	asm {
	mov ah,5
	mov al,[p]
	int 10H
	}
}

void plot(int x, int y, uchar col)
{
	uchar *a = ecran + (x >> 2) + y * (TX/4);
	asm {

	push	si
	push	di
	push	es

	mov	cl,BYTE PTR x
	and	cl,3
	mov	ah,1
	sal	ah,cl
	mov	dx,03c4H
	mov	al,2
	out	dx,ax
	mov	al,col
	les   di,[a]
//	stosb
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
	uchar	*a = ecran + y*(TX/4) + (x>>2), *b = font + car*6;
	int d = x&3;
	y = 6;
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
		x += 6;
	}
}

void affbloc(int x, int y, int nb)
{
	uchar *a = ecran2 + nb*16*4;
	uchar *b = ecran + long(y)*(TX/4) + x;
	asm {
	push	si
	push	di
	push	es
	push	ds

	mov	cx,16
	lds	si,[a]
	les	di,[b]
	cld

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

}loop:	asm {
	movsb
	movsb
	movsb
	movsb
	add	di,TX/4-4
	loop	loop

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

void TransferBlocs()
{
	uchar *a = blocs;
	uchar *b = ecran2;
	for(int y = 0 ; y < 12 ; y++)
	{
		for(int x = 0 ; x < 20 ; x++)
		{
			asm {
			push	si
			push	di
			push	es
			push	ds

			mov	cx,16
			lds	si,[a]
			les	di,[b]
			mov	dx,03c4H
			mov	al,2
			out	dx,al
			inc	dx
			mov	bx,3
}loop:	asm {
			mov	al,1
			out	dx,al
			movsb
			add	si,bx
			movsb
			add	si,bx
			movsb
			add	si,bx
			movsb
			sub	si,12
			sub	di,4

			mov	al,2
			out	dx,al
			movsb
			add	si,bx
			movsb
			add	si,bx
			movsb
			add	si,bx
			movsb
			sub	si,12
			sub	di,4

			mov	al,4
			out	dx,al
			movsb
			add	si,bx
			movsb
			add	si,bx
			movsb
			add	si,bx
			movsb
			sub	si,12
			sub	di,4

			mov	al,8
			out	dx,al
			movsb
			add	si,bx
			movsb
			add	si,bx
			movsb
			add	si,bx
			movsb

			add	si,320-16
			loop	loop

			pop	ds
			pop	es
			pop	di
			pop	si
			}
			a += 16;
			b += 4*16;
		}
		a += 15*20*16;
	}
	ecran = ecran3;
	box(0, 12*16, 319, 199, 0);
	int xx, yy;
	int n = 0;
	for(yy = 0 ; yy < 16*12 ; yy += 16)
		for(xx = 0 ; xx < 4*20 ; xx += 4)
			affbloc(xx, yy, n++);
	ecran = ecran1;
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

void addselect(int x1, int y1, int x2, int y2, int nbut, int key = 255)
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
void button(int x1, int y1, int x2, int y2, int nbut = 0, int key = 255)
{
	if(!noaff)
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
		plot(x2, y2, 1);
		plot(x1+1, y1+1, 6);
		plot(x2-1, y2-1, 2);
	}
	addselect(x1, y1, x2, y2, nbut, key);
}

void button2(int x1, int y1, int x2, int y2, int nbut = 0, int key = 255)
{
	if(!noaff)
	{
		box(x1, y1, x2, y2, 4);
		hline(x1+1, x2-1, y1, 6);
		hline(x1+1, x2-1, y2, 2);
		vline(y1+1, y2-1, x1, 6);
		vline(y1+1, y2-1, x2, 2);
		plot(x1, y1, 7);
		plot(x2, y2, 1);
	}
	addselect(x1, y1, x2, y2, nbut, key);
}

void butext(int x, int y, int l, char *t, int nbut = 0, int key = 255)
{
	button(x, y, x+l-1, y+10, nbut, key);
	if(!noaff)
		afftext(x+(l-strlen(t)*6)/2, y+3, t, 255);
}

int mouse()
{
	hidem();
	do
	{
/*		if(mk == 2)
		{
			M4++;
			while(release() == 2);
		} */
		uchar	*a = ecran + (my&0xfff0)*(TX/4) + ((mx&0xfff0) >> 2);
		int 	n, clipy = 32;
		if(my > 400-32)
			clipy = 400-my;
		asm {
		push	si
		push	di

		mov	cx,[clipy]
		push	es
		push	ds
		lds   si,[a]
		mov   di,64000
		mov   ax,0a000H
		mov   es,ax

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

}l:	asm {
		mov   ax,cx
		mov	cx,8
		rep	movsb
		add	si,TX/4-8
		mov   cx,ax
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

		if(my < hp*16)
		{
			hline(mx&0xfff0, (mx&0xfff0)+15, my&0xfff0, 255);
			hline(mx&0xfff0, (mx&0xfff0)+15, (my&0xfff0)+15, 255);
			vline(my&0xfff0+1, (my&0xfff0)+14, mx&0xfff0, 255);
			vline(my&0xfff0+1, (my&0xfff0)+14, (mx&0xfff0)+15, 255);
		}

		hline(mx+1, mx+15-1, my+1, 255);
		hline(mx+1, mx+15, my, 0);
		hline(mx+2, mx+15-2, my+2, 0);
		vline(my+1, my+15-1, mx+1, 255);
		vline(my+1, my+15, mx, 0);
		vline(my+2, my+15-2, mx+2, 0);

		Vsync();
		asm {
		push	si
		push	di

		push	es
		push	ds
		mov	cx,[clipy]
      les   di,[a]
      mov   si,64000
      mov   ax,0a000H
      mov   ds,ax

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

}ll:	asm {
		mov   ax,cx
		mov	cx,8
		rep	movsb
		add	di,TX/4-8
		mov   cx,ax
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
	while(!release() && !qkey());
	curkey = 0;
	while(qkey())
		curkey = getkey();
	if((curkey&0xff) == ' ')
		mk = 1;
	return mk;
}

void Transfer4Plans(int pal, int im)
{
	int m;
	box(0, 0, TX, TY, 0);
	for(m = 0 ; m < 16 ; m++)
		setcolor(m + 16, image[pal+m*3], image[pal+m*3+1], image[pal+m*3+2]);
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

void Load4Plans(char *c)
{
	ifstream in(c, ios::binary);
	if(!in)
		return;
	char *ext = c;
	while(*ext)
	{
		if(*ext >= 'A' && *ext <= 'Z')
			*ext += 'a' - 'A';
		ext++;
	}
	ext = c+strlen(c)-3;
	uchar *a = (unsigned char *) image;
	int n;
	if(!strcmp(ext, "pi1"))
	{
		in.read(image, 32700);
		for(n = 0 ; n < 16 ; n++)
		{
			a[32034+n*3] = (a[2+n*2]&7)<<3;
			a[32034+n*3+1] = (a[2+n*2+1]&0x70)>>1;
			a[32034+n*3+2] = (a[2+n*2+1]&7)<<3;
		}
		Transfer4Plans(32034, 34);
	}
	else if(!strcmp(ext, "lbm") || strcmp(ext,"iff"))
	{
		char b[5];
		b[4] = 0;

		in.seekg(16);
		do
		{
			long l = ((in.get() << 24)&0xff) + ((in.get() << 16)&0xff) + ((in.get() << 8)&0xff) + (in.get()&0xff);
			if(l & 1)
				l++;
			in.seekg(l, ios::cur);
			for(n = 0 ; n < 4 ; n++)
				b[n] = in.get();
			if(in.eof())
				return;
		}
		while(strcmp(b, "CMAP"));

		in.seekg(4, ios::cur);
		for(n = 0 ; n < 16*3 ; n++)
			*a++ = in.get()>>2;



		in.seekg(16);
		do
		{
			long l = ((in.get() << 24)&0xff000000) + ((in.get() << 16)&0xff0000) + ((in.get() << 8)&0xff00) + (in.get()&0xff);
			if(l & 1)
				l++;
			in.seekg(l, ios::cur);
			for(n = 0 ; n < 4 ; n++)
				b[n] = in.get();
			if(in.eof())
				return;
		}
		while(strcmp(b, "BODY"));

		in.seekg(4, ios::cur);
		int x, y, f = 0, m;
		uchar *c;
		for(y = 0 ; y < 200 ; y++)
		{
			for(n = 0 ; n < 4 ; n++)
			{
				c = a;
				x = 0;
				do
				{
					m = char(in.get());
					if(m > 0)
					{
						x += m+1;
						while((m--)>=0)
						{
							*c++ = in.get();
							if(f)
							{
								c += 6;
								f = 0;
							}
							else
								f = 1;
						}
					}
					else
					{
						x += -m+1;
						char mm = in.get();
						while((m++)<=0)
						{
							*c++ = mm;
							if(f)
							{
								c += 6;
								f = 0;
							}
							else
								f = 1;
						}
					}
				}
				while(x < 40);
				a += 2;
			}
			a += 160-8;
		}
		Transfer4Plans(0, 16*3);
	}

}

void init_video()
{
	asm {		// Passage en mode 13H (320*200 256 couleurs)

	push	si
	push	di

	mov	ax,00013H
	int	10H

	mov	dx,03c4H
	mov	ax,0604H
	out	dx,ax
/*	mov	dx,03ceH
	mov	ax,4005H
	out	dx,ax

	mov	al,06
	out	dx,al
	inc	dl
	in		al,dx
	and	al,0fdH
	out	dx,al */

	mov	dx,03d4H
	mov	al,014H
	out	dx,al
	inc	dl
	in		al,dx
	and	al,0bfH
//	or		al,00100000b
	out	dx,al

	dec	dl
	mov	al,017H
	out	dx,al
	inc	dl
	in		al,dx
	or		al,040H
	out	dx,al

/*	mov	dx,03ceH
	mov	al,08H
	out	dx,al
	inc	dl
	mov	al,0ffH
	out	dx,al */

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
	asm {
		mov	ax, 03H
		int	10H
	}

	cout << a << "\n";
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

int input(char *in)
{
	char a;
	button2(160-100, 100, 160+100, 109);
	do
	{
		box(160-99, 101, 160+99, 108, 4);
		afftext(160-96, 102, in, 0);
		a = getkey() & 0xff;
		int l = strlen(in);
		if(a == 27)
			return FALSE;
		if(a == 8)
		{
			if(l)
				in[l-1] = 0;
		}
		else
			if(l < 190/6 && a != 13)
			{
				in[l+1] = 0;
				in[l] = a;
			}
	}
	while(a != 13);
	return TRUE;
}

int box_manager()
{
	for(;;)
	{
		while(!mouse() && !curkey);
		if((curkey&0xff) <= 'Z' && (curkey&0xff) >= 'A')
			curkey += 'a' - 'A';
/*		char s[10];
		sprintf(s, "%x", curkey);
		butext(50, 50, 50, s); */
		for(int n = 0 ; n < curbut ; n++)
		{
			if(
			(mk &&
			mx >= buttonlist[n].x1 &&
			my >= buttonlist[n].y1 &&
			mx <= buttonlist[n].x2 &&
			my <= buttonlist[n].y2) ||
			(curkey &&
			((curkey & 0xff) == buttonlist[n].k || curkey == buttonlist[n].k))
			)
			{
				return buttonlist[n].n;
			}
		}
	}
}

void new_plan()
{
	if(cp->p)
		delete cp->p;
	cp->p = (uchar *) calloc(cp->tx, cp->ty);
	if(!cp->p)
		erreur("M‚moire insufisante pour le plan!");
}

int qsur()
{
	curbut = 0;
	button2(50, 155, 320-50, 195);
	afftext(160-14*6/2, 160, "ETES VOUS SUR?", 0);
	butext(70, 180, 320-70*2, "OUI!", 1, 13);
	addselect(0, 0, TX, TY, -1, 27);
	int a = box_manager();
	relmouse();
	return(a);
}

void affpos()
{
	if(ohp == 9)
	{
		box(4, 152, 120, 168, 4);
		sprintf(petitbuffer, "TX: %4d | X: %4d", cp->tx, cp->curx);
		afftext(4, 152, petitbuffer, 0);
		sprintf(petitbuffer, "TY: %4d | Y: %4d", cp->ty, cp->cury);
		afftext(4, 158, petitbuffer, 0);
		sprintf(petitbuffer, "MAP: %d", np);
		afftext(4, 164, petitbuffer, 0);
	}
	else
	{
		sprintf(petitbuffer, "X: %4d | Y: %4d | TX: %4d | TY: %4d | MAP: %d", cp->curx, cp->cury, cp->tx, cp->ty, np);
		box(4, 12*16+1, 300, 198, 4);
		afftext(4, 12*16+1, petitbuffer, 0);
	}
}

void affmap()
{
	int x, xx, y, yy;
	if(cp->curx < 0)
		cp->curx = 0;
	if(cp->cury < 0)
		cp->cury = 0;
	if(cp->curx >= int(cp-> tx))
		cp->curx = cp->tx-1;
	if(cp->cury >= int(cp-> ty))
		cp->cury = cp->ty-1;
	affpos();
	for(y = cp->cury, yy = 0 ; yy < 16*ohp ; y++, yy += 16)
		for(x = cp->curx, xx = 0 ; xx < 4*20 ; x++, xx += 4)
			if(x < cp->tx && y < cp->ty)
				affbloc(xx, yy, cp->p[x + y*cp->tx]);
			else
				affbloc(xx, yy, 0);
}

void mainbox()
{
	hp = ohp;
	curbut = 0;
	Vsync();
	if(hp == 9)
	{
		button2(0, 144, 319, 199);
		addselect(0, 0, 319, 143, 18);
		sprintf(petitbuffer, "MEMOIRE LIBRE: %dK", int(coreleft()/1024));
		afftext(4, 146, petitbuffer, 0);
		butext(210, 187, 40, "FULL", 19, 'f');
		noaff = FALSE;
	}
	else
	{
		addselect(0, 0, 319, 12*16-1, 18);
		addselect(0, 0, 0, 0, 19, 'f');
		addselect(0, 12*16, 319, 199, -1);
		button2(0, 12*16, 319, 199);
		noaff = TRUE;
	}
	butext(4, 187, 40, "QUIT", 1, 'q');
	butext(48, 187, 40, "LOAD", 2, 'l');
	butext(92, 187, 40, "SAVE", 7, 's');
	butext(136, 187, 70, "BLOC LOAD", 24, 'b');
	butext(138, 146, 10, "\001", 3, 0x4800);
	butext(138, 146+14, 10, "\002", 4, 0x5000);
	butext(123, 146+7, 10, "\004", 6, 0x4b00);
	butext(153, 146+7, 10, "\003", 5, 0x4d00);
	butext(4, 173, 10, "0", 8, 0x7800);
	butext(4+12*1, 173, 10, "1", 9, 0x7900);
	butext(4+12*2, 173, 10, "2", 10, 0x7a00);
	butext(4+12*3, 173, 10, "3", 11, 0x7b00);
	butext(4+12*4, 173, 10, "4", 12, 0x7c00);
	butext(4+12*5, 173, 10, "5", 13, 0x7d00);
	butext(4+12*6, 173, 10, "6", 14, 0x7e00);
	butext(4+12*7, 173, 10, "7", 15, 0x7f00);
	butext(4+12*8, 173, 10, "8", 16, 0x8000);
	butext(4+12*9, 173, 10, "9", 17, 0x8100);
	addselect(0, 0, 0, 0, 20, 0x4900);
	addselect(0, 0, 0, 0, 21, 0x5100);
	addselect(0, 0, 0, 0, 22, 0x4700);
	addselect(0, 0, 0, 0, 23, 0x4f00);
	addselect(0, 0, 319, 199, -1);
	noaff = FALSE;
	affmap();
	hp = 0;
}

main()
{
	int	n, m;

	if(!init_mouse())
		return 1;

	image = (uchar *) calloc(320, 200);
	blocs = (uchar *) calloc(320, 200);
	ecran1 = ecran = (uchar *) MK_FP(0xa000, 0000);
	ecran2 = (uchar *) MK_FP(0xa400, 0000);
	ecran3 = (uchar *) MK_FP(0xa800, 0000);
	ecran = (uchar *) MK_FP(0xa000, 0000);
	if(!image || !blocs)
	{
		cout << "m‚moire insufisante...\n";
		return 1;
	}

	ofstream out;
	ifstream in;
	in.open("c:\\c\\mapedit\\little2.fnt", ios::binary);
	in.read(font, 6*256);
	in.close();
	invert_font();

	init_video();
	Load4Plans("brique2.lbm");
	TransferBlocs();

	Vsync();
	setcolor(255, 63, 63, 63);
	setcolor(15, 48, 48, 48);
	setcolor(1, 10-5, 10, 10);
	setcolor(2, 20-5, 20, 20);
	setcolor(3, 30-5, 30, 30);
	setcolor(4, 40-5, 40, 40);
	setcolor(5, 50-5, 50, 50);
	setcolor(6, 60-5, 60, 60);
	setcolor(7, 63-5, 63, 63);

	for(n = 0 ; n < 10 ; n++)
	{
		plans[n].tx = 20;
		plans[n].ty = 10;
		plans[n].p = 0;
		cp = plans+n;
		new_plan();
	}
	cp = plans;

	setpage(0);
	ecran = ecran1;

	box(0, 0, 639, 399, 0);

	int x, y;
//	uchar *a = cp->p;
	mainbox();
//	affmap();
	int nb;
	char filename[32];
	do
	{
		hp = ohp;
		nb = box_manager();
		hp = 0;
		if((mk & 1) || curkey)
		{
			switch(nb)
			{
			case 1:
				relmouse();
				nb = qsur();
				mainbox();
				break;
			case 2:
				if(input(cp->name))
				{
					in.open(cp->name, ios::binary);
					if(in)
					{
						cp->tx = in.get()*256+in.get();
						cp->ty = in.get()*256+in.get();
						new_plan();
						in.read(cp->p, cp->tx*cp->ty);
/*						for(x = 0 ; x < cp->tx*cp->ty ; x++)
						{
							in.get();
							cp->p[x] = in.get();
						} */
						in.close();
					}
				}
				mainbox();
//				affmap();
				break;
			case 7:
				if(input(cp->name))
				{
					out.open(cp->name, ios::binary);
					if(out)
					{
						out.put(cp->tx>>8);
						out.put(cp->tx&0xff);
						out.put(cp->ty>>8);
						out.put(cp->ty&0xff);
						out.write(cp->p, cp->tx*cp->ty);
						out.close();
					}
				}
				mainbox();
//				affmap();
				break;
			case 3:
				cp->cury--;
				affmap();
				break;
			case 4:
				cp->cury++;
				affmap();
				break;
			case 6:
				cp->curx--;
				affmap();
				break;
			case 5:
				cp->curx++;
				affmap();
				break;

			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
				np = nb - 8;
				cp = plans+np;
//				mainbox();
				affmap();
				relmouse();
				break;
			case 18:
				x = mx / 16;
				y = my / 16;
				if(x+cp->curx < cp->tx && y+cp->cury < cp->ty)
				{
					affbloc(x*4, y*16, cb);
					x += cp->curx;
					y += cp->cury;
					cp->p[x+y*cp->tx] = cb;
				}
				break;
			case 19:
				if(ohp == 9)
					ohp = 12;
				else
					ohp = 9;
				mainbox();
				relmouse();
				break;
			case 20:
				cp->cury -= ohp/2;
				affmap();
				break;
			case 21:
				cp->cury += ohp/2;
				affmap();
				break;
			case 22:
				cp->curx -= 10;
				affmap();
				break;
			case 23:
				cp->curx += 10;
				affmap();
				break;
			case 24:
				filename[0] = 0;
				if(input(filename))
				{
					Load4Plans(filename);
					TransferBlocs();
				}
				mainbox();
				break;
			}
		}
		else
		{
			hp = 12;
			setpage(4);
			ecran = ecran3;
			relmouse();

			if(mouse() == 1)
				cb = mx/16 + (my/16)*20;

			setpage(0);
			ecran = ecran1;
			relmouse();
		}
	}
	while(nb != 1);

	asm {
		mov	ax, 03H
		int	10H
	}
	qkey();

	return 0;
}
