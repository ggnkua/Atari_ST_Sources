al/****************************************************************/
/*																*/
/*	STGA_SW  Initialisierung einer Tseng-ET-4000-VGA			*/
/*  und ggf. Anmeldung beim VDI (geht nur SW)					*/
/*																*/
/*	(c) 1992  Till Harbaum										*/
/*																*/
/****************************************************************/

/* Wenn hier TEST definiert ist wird das VDI nicht vom Vorhandensein 
   der VGA informiert, dann wird nur der Modus eingestellt.
*/
/*
#define		TEST
*/
#define		VIDBASE			0xC00000l
#define		IOBASE			0xCF0000l

#define		FALSE			0
#define		FALS			FALSE
#define 	TRUE			!FALSE

#define		NEL				-1
#define		EOL				-2

#define		SHIFT_MD		0xff8260l

#include	<stdio.h>
#include    <stdlib.h>
#include    <ext.h>
#include    <tos.h>
#include    "stga_sw.h"

extern	int		adapter_ist_da(void);
extern	void	clear_mem(ULONG *adr, long anz);
extern	void	inst_vdi(void);
extern	int		hor_rez,ver_rez,hor_byte;

void	poke(WORD adr, UBYTE dat);
UBYTE	peek(WORD adr);

void	allg_init(void);
char	*init_mode(int mode);
void	write_list(int ptr,int *list, int atc_flag);
void 	wait_vret(void);
void	screen_off(void);
long	gettimer(void);
char 	get_shift_md(void);
void 	set_shift_md(char wert);

main()
{
	char	*name,shift_md;
	int		mode,mode_neu,old_rez;
	long	dist200;
	void	*old_log;

	#ifdef TEST
		putc(27,stdout);	putc('E',stdout);
	#endif

	fputs("\nSTGA-Treiber V1.0 - (c)1992 by Till\n",stdout);
	fputs("-----------------------------------\n",stdout);

	if(adapter_ist_da()==0)
	{
		fputs("Da ist kein Adapter!!!\n",stdout);
		exit(-1);
	}	

	/* zuerst mit MCLK testen */
	ts[1][7]=0x88;
	dist200=gettimer();
	init_mode(1);
	wait_vret();
	dist200=gettimer()-dist200;

	if(dist200<50l)
	{
		/* Frequenz der VSYNC-Signale hat nicht gestimmt	*/
		/* also MCLK/2 einstellen 							*/
		mode=0;
		while(nam[mode++][0]!='*')
			ts[mode][7]=0xc8;
		init_mode(1);
		fputs("MCLK/2 wurde eingeschaltet.\n",stdout);
	}
	else
		fputs("MCLK/2 wurde nicht eingeschaltet.\n",stdout);

	/* ab jetzt auf VGA weitermachen */
	old_rez=Getrez();
	old_log=Logbase();

	/*  Inhalt des SHIFT_MD-Registers merken und restaurieren,
		verhinderdert Reset, falls sich der Rechner nicht in der
		hohen Auflîsung befand und jetzt in diese schaltet.		*/
	shift_md=get_shift_md();
	/*  VGA als Bildschirm anmelden */
	Setscreen((void*)VIDBASE,(void*)-1l,2);
	set_shift_md(shift_md);

	fputs("Bitte Modus auswÑlen:\n",stdout);
	mode=0;
	while(nam[mode++][0]!='*')
	{
		putc('a'+mode-1,stdout);
		fputs(") ",stdout);
		fputs(nam[mode-1],stdout);
		fputs("\n",stdout);
	}

	do
		mode_neu=getch()-'a';
	while((mode_neu<0)||(mode_neu>(mode-2)));

	shift_md=get_shift_md();
	Setscreen(old_log,(void*)-1l,old_rez);
	set_shift_md(shift_md);
	
	name=init_mode(mode_neu);
	fputs("Modus: ",stdout);
	fputs(name,stdout);
	fputs("\n",stdout);

	clear_mem((ULONG*)VIDBASE,768000l);

	#ifndef TEST
		hor_rez=x_rez[mode_neu]-1;
		ver_rez=y_rez[mode_neu]-1;
		hor_byte=x_byte[mode_neu];

		if(!col[mode_neu])
		{
			inst_vdi();
			fputs("\033ESTGA-Schwarz-Weiû-VDI V1.0 installiert\n",stdout);
			Ptermres(_PgmSize,0);
		}
		else
			fputs("Farb-Modi verarbeitet das VDI nicht!\n",stdout);
	#endif
	
	return(0);
}

void	allg_init()
{
	poke(0x3c3,0x01);              	/* enable video subsystem	*/
	poke(0x3c2,0x63);               /* D - Color		        */

	poke(0x3bf,0x03);              	/* Hercules komp.			*/
	poke(0x3d8,0xa0);              	/* Key						*/

	poke(0x3c4,0x06);
	poke(0x3c5,0x00);           	/* state control            */
	poke(0x3c4,0x07);
	poke(0x3c5,0xbc);           	/* auxiliary mode           */

	poke(0x3d4,0x32);              	/* CRTC RCCONF				*/
	poke(0x3d5,0x70);              	/* use -10 memory			*/
	poke(0x3d4,0x33);
	poke(0x3d5,0x00);           	/* extended start address   */
	poke(0x3d4,0x34);
	poke(0x3d5,0x00);           	/* 6845 compatibility       */
	poke(0x3d4,0x35);
	poke(0x3d5,0x00);           	/* overflow high            */

	poke(0x3d4,0x36);              	/* CRTC VSCONF1				*/
	poke(0x3d5,0xf1);     		   	/* enable 16-Bit Mem/IO		*/
								   	/* Linear-RAM				*/
	poke(0x3d4,0x37);
	poke(0x3d5,0x0f);           	/* video configuration 2    */

	poke(0x3cd,0x00);             	/* Segment 0 benutzen       */

	poke(0x3ce,0x06);			   	/* GDC - Misc				*/
	poke(0x3cf,0x03);			   	/* enable Graph-Mode / 128k */
}

char	*init_mode(int mode)
{
	int	i;

	allg_init();

	poke(0x3c4,0x00); poke(0x3c5,0x01);	/* Sequenzer stoppen	*/
	write_list(0x3c4,ts[mode],FALSE);	/* Timing Sequencer		*/
	poke(0x3c2,misc[mode]);             /* Misc-Output			*/
	poke(0x3c4,0x00); poke(0x3c5,0x03);	/* Sequenzer starten	*/

	poke(0x3d4,0x11); poke(0x3d5,0x20);	/* CRTC freigeben	    */
	write_list(0x3d4,crtc[mode],FALSE);	/* CRTC - Controller	*/

	write_list(0x3ce,gdc[mode],FALSE);	/* GDC - Controller		*/

	peek(0x3da);						/* ATC-Index-Reset		*/
	peek(0x3ba);						/*      -"-				*/
	write_list(0x3c0,atc[mode],TRUE);	/* ATC - Controller		*/
	poke(0x3c0,0x20);					/* Palette freigeben	*/

	poke(0x3c6,0xff);               	/* alle Farben erlauben */

	if(col[mode])
	{
		poke(0x3c8,0);
		for (i=0; i<256; i++)
		{
  			poke(0x3c9,palette[i].red);
  			poke(0x3c9,palette[i].green);
  			poke(0x3c9,palette[i].blue);    /* alle Werte setzen    */
		}
	}
	else
	{
		poke(0x3c8,0x00);					/* Weiû		*/
		poke(0x3c9,0x3f);
		poke(0x3c9,0x3f);
		poke(0x3c9,0x3f);

		poke(0x3c8,0x0f);					/* Schwarz	*/
		poke(0x3c9,0x00);
		poke(0x3c9,0x00);
		poke(0x3c9,0x00);
	}

	return(nam[mode]);
}

void	write_list(int ptr, int *list, int atc_flag)
{
	int	cnt=0,data,dist=1;
	
	if(atc_flag)
		dist=0;

	do
	{
  		data=list[cnt];
  		
	  	if(data>=0)
  		{
   		 	poke(ptr,(UBYTE)cnt);
   		 	poke(ptr+dist,(UBYTE)data);
    	}
  		cnt+=1;
	}
	while(data!=EOL);
}

/* Screen_Off schaltet die VGA wieder aus */
void screen_off(void)
{
	poke(0x3c4,0x01); poke(0x3c5,32);	/* Sequenzer stoppen	*/
}

/* 	wait_vret wartet 20mal auf den		*/
/*	nÑchsten vertikalen StrahlrÅcklauf 	*/
void	wait_vret(void)
{
	/* Bit 3 des 'Input Status Register One' geht wÑhrend 	*/
	/* des RÅcklaufs auf 1									*/

	register int b;
	register char *inp=(char*)(IOBASE+0x3da);
	
	while((*inp)&8);
	while(!(*inp&8));

	for(b=0;b<20;b++)
	{
		while(*inp&8);

		while(!(*inp&8));
	}
}

/* gettimer liefert den aktuellen Stand des 200Hz-Systemtimers */
long 	gettimer(void)
{
	long	stack,*_hz_200=((long*)0x4bal),ret;
	
	stack=Super(NULL);
	ret=*_hz_200;
	Super((void*)stack);
	return(ret);
}

char 	get_shift_md(void)
{
	long	stack;
	char	*shift_md=(char*)SHIFT_MD,ret;
	
	stack=Super(NULL);
	ret=*shift_md;
	Super((void*)stack);

	return(ret);
}

void 	set_shift_md(char wert)
{
	long	stack;
	char	*shift_md=(char*)SHIFT_MD;
	
	stack=Super(NULL);
	*shift_md=wert;
	Super((void*)stack);
}

/* poke schreibt ein Byte in ein VGA-Register */
void	poke(WORD adr, UBYTE dat)
{
  	*((UBYTE*)adr+IOBASE)=dat;
}

/* peek liest ein Byte aus einem VGA-Register */
UBYTE	peek(WORD adr)
{
	return(*((UBYTE*)adr+IOBASE));
}