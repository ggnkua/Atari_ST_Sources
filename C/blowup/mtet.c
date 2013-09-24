/* MINI-TETRIS
 * Auf Wunsch von Georg Acher
 * von Michael Eberl am 17.7.1994
 *
 * Ich mužte ....
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <tos.h>
#include <ext.h>
#include <vdi.h>
#include <aes.h>

#define WIDTH 10
#define HEIGHT 30

#define SCBOUND 15
#define TIMEACC 0.8

#define max(A,B) ((A) > (B) ? (A) : (B))
#define min(A,B) ((A) < (B) ? (A) : (B))

static int work_in[16];
static int work_out[64];
static int xres,yres;
static long playfield[HEIGHT+10];
static int ende;
static int zeit=300;
static int handle;
static long stone;
static int mutation, stonex, stoney;
static int displayed=0;
static long score=0;
static long scorebound=SCBOUND;
static int highfile;
static long hiscore;
static char hiname[128];

static long stone1[4]={0x4444L, 0x00F0L, 0x2222L, 0x0F00L};
static long stone2[4]={0x0660L, 0x0660L, 0x0660L, 0x0660L};
static long stone3[4]={0x4620L, 0x0360L, 0x4620L, 0x0360L};
static long stone4[4]={0x2640L, 0x0C60L, 0x2640L, 0x0C60L};
static long stone5[4]={0x4640L, 0x04E0L, 0x2620L, 0x0720L};
static long stone6[4]={0x6440L, 0x0E20L, 0x2260L, 0x08E0L};
static long stone7[4]={0x6220L, 0x0740L, 0x4460L, 0x0170L};
static long *stones[7];

void init_tet( void )
{
	int i;
	char s[127];
	
	handle=graf_handle( &i, &i, &i, &i );
	
	work_in[0] = 0;
	work_in[1] = 1;
	work_in[2] = 1;
	work_in[3] = 1;
	work_in[4] = 1;
	work_in[5] = 1;
	work_in[6] = 1;
	work_in[7] = 1;
	work_in[8] = 1;
	work_in[9] = 1;
	work_in[10] = 2;
	v_opnvwk( work_in, &handle, work_out );
	v_clrwk( handle );
	v_hide_c( handle );
	puts("\033H");
	puts("Willkommen zum BLOWCONF-Cheatmodus,\ndem Mini TETris von Michael Eberl");
	puts("");
	puts("Dieses Programm entstand auf dringenden Wunsch von");
	puts("Georg Acher am 14.7.1994 und wurde am 27.9.96 von");
	puts("Michael Eberl in BlowConf integriert.");
	puts("");
	puts("Bedienung:");
	puts("Bewegung nach links  :  Linke Shift-Taste");
	puts("Bewegung nach rechts : Rechte Shift-Taste");
	puts("Drehung des Steins   : Alternate-Taste");
	puts("");
	puts("Aus praktischen Grnden ist eine y-Aufl”sung\nvon mind. 544 Punkten n”tig!!!");
	puts("");
	puts("Nach Spielende wird ein eventueller Highscore abgespeichert,");
	puts("dann wird zu BLOWCONF zurckgekehrt.");
	puts("");
	puts("Viel Spaž!");
	puts("");
	puts("Press <Return> to start...!");
	(void)gets(s);
	
	v_clrwk( handle );
	xres = 1+ work_out[0];
	yres = 1+ work_out[1];
	
	for (i=0; i<HEIGHT; i++)
		playfield[i]=0;
	
	stones[0]=stone1;
	stones[1]=stone2;
	stones[2]=stone3;
	stones[3]=stone4;
	stones[4]=stone5;
	stones[5]=stone6;
	stones[6]=stone7;
	if ((highfile=(int)Fopen("HISCORE.DAT", FO_READ))<0)
	{
		hiscore=0;
		strcpy(hiname,"");
	}
	else
	{
		Fread( highfile, 4, &hiscore );
		Fread( highfile, 128, hiname );
		Fclose( highfile );
	}
}

void done( void )
{
	v_show_c( handle, 0 );
	v_clsvwk( handle );
	if (score>hiscore)
	{
		puts("\033HSie haben einen neuen Highscore erreicht!");
		printf("Geben Sie Ihren Namen ein: ");
		scanf("%126s",hiname);
		highfile=(int)Fcreate("HISCORE.DAT",0);
		Fwrite(highfile, 4, &score );
		Fwrite(highfile, 128, hiname );
		Fclose(highfile);
	}
}

void display_field( void )
{
	int x, y;
	int parray[6];
	
	for( x=16; x<=(16+(16*WIDTH)); x+=16 )
	{
		parray[0] = x;	parray[1] = 16+16*HEIGHT;
		parray[2] = x;  parray[3] = 16;
		v_pline( handle, 2, parray );
	}
	for( y=16; y<=(16+(16*HEIGHT)); y+=16 )
	{
		parray[0] = 16;	parray[1] = y;
		parray[2] = 16+16*WIDTH;parray[3] = y;
		v_pline( handle, 2, parray );
	}
}

int collide_stone( void )
{
	int sl, sr, so, su;
	int x, y;
	long thestone;
	
/* Ist Stein ganz unten angekommen? */
	thestone=stones[stone][mutation];
	sl=4; sr=-1;
	so=4; su=-1;
	for (y=0; y<4; y++)
		for (x=0; x<4; x++)
		{
			thestone<<=1;
			if ( 0x10000L & thestone )
			{
				sl=min(x,sl);
				sr=max(x,sr);
				so=min(y,so);
				su=max(y,su);
			}
		}
	if (stoney+su==HEIGHT)
		return 1;
	if ((stonex+sr)>=WIDTH)
		return 1;
	if ((stonex+sl)<0)
		return 1;

/* Eigentlicher Kollisionscheck im playfield */
	thestone=stones[stone][mutation];
	for (y=0; y<4; y++)
		for (x=0; x<4; x++)
		{
			thestone<<=1;
			if ( 0x10000L & thestone )
			{
				if (playfield[stoney+y] & (1<<(stonex+x)))
					return 1;
			}
		}
	return 0;
}

void new_stone( void )
{
	stone=rand()%8;
	if (stone==7)
		stone=0;
	mutation=rand()%4;
	stonex=-2+(-WIDTH>>2)+random(WIDTH>>1)+(WIDTH>>1);
	stoney=-2;
	
	if (collide_stone())
		ende=1;
}

void move_stone( void )
{
	int move;
	
	move=(int)Kbshift(-1);
	if (move&0x0001)		/* Shift rechts: Rechts */
	{
		stonex+=1;
		if (collide_stone())
			stonex-=1;
	}
	else if (move & 0x0002)	/* Shift links: Links */
	{
		stonex-=1;
		if (collide_stone())
			stonex+=1;
	}
	if (move & 0x0008)		/* Alternate: Mutiere (Rotiere) */
	{
		int old_mutation;
		
		old_mutation=mutation;
		mutation=(mutation+1)&0x3;
		if (collide_stone())
			mutation=old_mutation;
	}
}

void display_stone( void )
{
	static int oldx, oldy;
	static long oldstone;
	int x, y;
	long thestone;
	int parray[4];
	
	
	if (displayed)
	{
		vsf_color( handle, 0 );
		for (y=0; y<4; y++)
			for (x=0; x<4; x++)
			{
				oldstone<<=1;
				if ( 0x10000L & oldstone )
				{
					parray[0]=17+(16*(oldx+x));
					parray[1]=17+(16*(oldy+y));
					parray[2]=parray[0]+14;
					parray[3]=parray[1]+14;
					vr_recfl( handle, parray );
				}
			}
		vsf_color( handle, 1 );
	}
	thestone= stones[stone][mutation];
	oldstone= thestone;
	oldx=stonex;
	oldy=stoney;
	displayed=1;
	for (y=0; y<4; y++)
		for (x=0; x<4; x++)
		{
			thestone<<=1;
			if ( 0x10000L & thestone )
			{
				parray[0]=17+(16*(stonex+x));
				parray[1]=17+(16*(stoney+y));
				parray[2]=parray[0]+14;
				parray[3]=parray[1]+14;
				vr_recfl( handle, parray );
			}
		}
}

void outplayfield( void )
{
	int i;
	
	printf("\033H\n");
	for (i=0; i<HEIGHT; i++);
		printf("\033C\033C\033C\033C\033C\033C\033C\033C\033C\033C\033C\033C\033C\033C\033C\033C\033C%ld\n",playfield[i]);
}

void replace_stone( void )
{
	displayed=0;
	new_stone();
}

void fall_stone( void )
{
	int x, y;
	long thestone;
	
	stoney+=1;
	if (!collide_stone())
		return;

	stoney-=1;
	thestone=stones[stone][mutation];
	for (y=0; y<4; y++)
		for (x=0; x<4; x++)
		{
			thestone<<=1;
			if ( 0x10000L & thestone )
			{
				playfield[stoney+y]|=1<<(stonex+x);
			}
		}
	replace_stone();
}

void clear_line( void )
{
	int i;
	int count=0;
	
	for( i=0; i<HEIGHT; i++ )
	{
		if (playfield[i]==((1<<WIDTH)-1))
		{
			int x,j;
			int parray[4];
			
			count++;
			for(j=i; j>=0; j--)
			{
				playfield[j]=playfield[j-1];
				for (x=0; x<WIDTH; x++)
				{
					if (playfield[j]&(1<<x))
						vsf_color( handle, 1 );
					else
						vsf_color( handle, 0 );
					parray[0]=17+(16*x);
					parray[1]=17+(16*j);
					parray[2]=parray[0]+14;
					parray[3]=parray[1]+14;
					vr_recfl( handle, parray );
				}
			}
			vsf_color( handle, 0 );
			parray[1]=17;
			parray[3]=parray[1]+14;
			for (x=0; x<WIDTH; x++)
			{
				parray[0]=17+(16*x);
				parray[2]=parray[0]+14;
				vr_recfl( handle, parray );
			}
			vsf_color( handle, 1 );
			playfield[0]=0;
		}
	}
	switch (count)
	{
	case 1:
		score+=1;
		break;
	case 2:
		score+=3;
		break;
	case 3:
		score+=7;
		break;
	case 4:
		score+=15;
		break;
	}
	if (score>scorebound)
	{
		scorebound+=SCBOUND;
		zeit=zeit*TIMEACC;
	}
}

void display_score( void )
{
	char s[256];
	
	sprintf(s, "Your Score: %8ld points",score );
	v_gtext( handle, 16, 40+(HEIGHT*16), s );
	sprintf(s, "Highscore : %8ld points by %s ",hiscore, hiname );
	v_gtext( handle, 16, 56+(HEIGHT*16), s );
}

void check_ende( void )
{
	if (4==Kbshift(-1))
		ende=1;
}

void play( void )
{
	ende=0;
	display_field();
	new_stone();
	display_stone();
	while (!ende)
	{
		move_stone();
		display_stone();
		fall_stone();
		clear_line();
		display_score();
		check_ende();
		delay(zeit);
	}
}

mtet_main()
{
	init_tet();
	play();
	delay(2000);
	done();
	
	return 0;
}