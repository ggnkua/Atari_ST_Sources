/* CRABS-Programm (1989 von J”rg Ramb) */

/* ..<><>..<><><>.. */
/* <><><><>..<><><> */
/* <>............<> */
/* <>..<><><><>..<> */
/* ..<><><><><><>.. */
/* ..<><><><><><>.. */
/* <>..<><><><>..<> */
/* ..<>........<>.. */

#include	<stddef.h>
#define cdecl
#include	<aes.h>
#undef cdecl
#include	<linea.h>
#include	<tos.h>
#include	<stdlib.h>

#define ANZ 10

void	*screen;
int		scrn[8],mask;

struct {
	int x,y;
	int richt;
} crabs[ANZ];

int crab[4][8]={
	{0x6e<<8,0xf7<<8,0x81<<8,0xbd<<8,0x7e<<8,0x7e<<8,0xbd<<8,0x42<<8},/*^*/
	{0x42<<8,0xbd<<8,0x7e<<8,0x7e<<8,0xbd<<8,0x81<<8,0xef<<8,0x76<<8},/*v*/
	{0x4e<<8,0xb3<<8,0x7b<<8,0x7a<<8,0x79<<8,0x7b<<8,0xb3<<8,0x4e<<8},/*>*/
	{0x72<<8,0xcd<<8,0xde<<8,0x9e<<8,0x5e<<8,0xde<<8,0xcd<<8,0x72<<8} /*<*/
};

void get_block(int x,int y,int *targ,char mode)
{
	static BITBLT blt={
		8,8,1,1,1,
		0,0,0,0,
		0,0,
		NULL,
		2,80,2,
		0,0,
		NULL,
		2,2,2,	/*1*/
		NULL
	};
	blt.op_tab[0]=blt.op_tab[1]=blt.op_tab[2]=blt.op_tab[3]=mode;
	blt.s_xmin=x;
	blt.s_ymin=y;
	blt.s_form=screen;
	blt.d_form=targ;
	bit_blt(&blt);
}

void put_block(int x,int y,int *sour,char mode)
{
	static BITBLT blt={
		8,8,1,1,1,
		0,0,0,0,
		0,0,
		NULL,
		2,2,2, /*1*/
		0,0,
		NULL,
		2,80,2,
		NULL,
	};
	blt.op_tab[0]=blt.op_tab[1]=blt.op_tab[2]=blt.op_tab[3]=mode;
	blt.d_xmin=x;
	blt.d_ymin=y;
	blt.d_form=screen;
	blt.s_form=sour;
	bit_blt(&blt);
}

#define	set_crab(x,y,field)		put_block(x,y,field,7)

void cls_crab(int x,int y,int *field)
{
	int t,*s=scrn;
	get_block(x,y,scrn,3);
	mask=(x+y)%2?0xaaaa:0x5555;
	for(t=0;t<8;t++) {
		*(s++)=(*s&~*field)|((mask=~mask)&*(field++));
	}
	put_block(x,y,scrn,3);
}

int crab_eat(int x,int y,int *field)
{
	int t,*s=scrn;
	get_block(x,y,scrn,3);
	mask=(x+y)%2?0xaaaa:0x5555;
	for(t=0;t<8;t++) {
		if((*(s++)^(mask=~mask))&*(field++)) return(1);
	}
	return(0);
}

void move_crab(int nr)
{
	int nx,ny,w;
	cls_crab(crabs[nr].x,crabs[nr].y,crab[crabs[nr].richt]);
	w=(int)(rand()%11)+1;
	if(w>7) crabs[nr].richt=w-8;
	else {
		switch(crabs[nr].richt) {
			case 0:	ny=crabs[nr].y-w;	nx=crabs[nr].x;	break;
			case 1:	ny=crabs[nr].y+w;	nx=crabs[nr].x;	break;
			case 2:	nx=crabs[nr].x+w;	ny=crabs[nr].y;	break;
			case 3:	nx=crabs[nr].x-w;	ny=crabs[nr].y;	break;
		}
		if(nx>632 || ny>392 || nx<0 || ny<0)
			{	nx=crabs[nr].x; ny=crabs[nr].y;	}
		if(crab_eat(nx,ny,crab[crabs[nr].richt])) {
			cls_crab(nx,ny,crab[crabs[nr].richt]);
			nx=crabs[nr].x; ny=crabs[nr].y;
		}
		crabs[nr].x=nx;	crabs[nr].y=ny;
	}
	set_crab(crabs[nr].x,crabs[nr].y,crab[crabs[nr].richt]);
}

void main(void)
{
	int nr;
	linea_init();
    if(appl_init()!=-1) {
    	evnt_timer(0,1);	/* Warten, bis aktiv! */
		screen=Physbase();
		for(nr=0;nr<ANZ;nr++) {
			crabs[nr].x=(int)(Random()%632);
			crabs[nr].y=(int)(Random()%392);
			crabs[nr].richt=(int)(Random()%4);
			set_crab(crabs[nr].x,crabs[nr].y,crab[crabs[nr].richt]);
		}
		while(1) {
			evnt_timer(100,0);	/* HI,LOW */
			screen=Physbase();
			for(nr=0;nr<ANZ;nr++)	move_crab(nr);
		}
	}
}