/* graphics.c */

/*********************************************/
/* you just keep on pushing my luck over the */
/*          BOULDER        DASH              */
/*                                           */
/*     Jeroen Houttuin, ETH Zurich, 1990     */
/*********************************************/

#include "header.h"
#include "bldrdash.h"

int nxview=0;
int nyview=0;
int xview=0;
int yview=0;
int lost=0;

#define noir         0
#define bleu         1
#define cyan_fonce   2
#define cyan         3
#define rouge_fonce  4
#define rouge        5
#define gris_fonce   6
#define gris         7
#define jaune_fonce  8
#define jaune        9
#define vert_fonce   10
#define vert         11
#define violet_fonce 12
#define violet       13
#define blanc_casse  14
#define blanc        15

unsigned int gamepal[16]=
{
	0x0000,0x400f,0x4088,0x88ff,
	0x4800,0x8f00,0x4888,0x8ccc,
	0x4880,0x8ff0,0x4080,0x88f8,
	0x4808,0x8f8f,0x4eee,0x8fff
};


char **levels;
extern char *levels1[];
extern char *levels2[];

bloc backup;

int gmode=0;
unsigned char t[32][32];

int RATIO=2;

void getbackup()
{
	getbloc(&backup,0,0,320,200);
}

void putbackup()
{
	putbloc(&backup,0,0);
}


bloc createbloc(s,width,height,c0,c1)
char *s;
int width,height,c1,c0;
{
   int x , y , n , m ;
   int w2=width/RATIO;
   int h2=height/RATIO;
   int w3=16*((w2+15)/16);
   bloc result;
   
	initbloc(&result);

	pbox(0,0,w2,h2,c0);

	
      for ( y = 0 ; y < h2+1 ; y ++ )
         for ( x = 0 ; x < w2+1 ; x ++ )
			t[y][x]=0;

      n = m = 0 ;
      for ( y = 0 ; y < height ; y ++ )
      {
         if ( m != 0 )
         {
            n ++ ;
         }
         m = 0 ;
         for ( x = 0 ; x < width ; x ++ )
         {
            if ( s [ n ] & ( 1 << m ) )
            {
            }
            else
            {
               t[y/RATIO][x/RATIO]++;
            }
            m ++ ;
            if ( m == 8 )
            {
               m = 0 ;
               n ++ ;
            }
         }
      }

      for ( y = 0 ; y < h2 ; y ++ )
         for ( x = 0 ; x < w2 ; x ++ )
         {
			if ((int)t[y][x]>2) plot(x,y,c1);
			else
			if ((int)t[y][x]>1) plot(x,y,c1&14);
		 }
   
   getbloc(&result,0,0,w3,h2);

	return result;
}


bloc
makegc(bits,col)
  char            bits[];	/* Bits describing fill pattern.  Produced in
				 * an X11 */
/* bitmap file usually. */
  int col;
{
  bloc pmap;

  pmap = createbloc( bits, 32, 32, noir, col );
  
  return pmap;
}



void
make_gcs()
{
	initbloc(&backup);

  pgc = 
  pgc1 = makegc(player_bits,cyan);
  pgc2 = makegc(player2_bits,cyan);
  wgc = 
  WWgc = makegc(wall_bits,gris);
  WWgc2 = makegc(wall2_bits,blanc);
  sgc = makegc(space_bits,blanc);
  ggc = makegc(grass_bits,vert);
  dgc =
  dgc1 = makegc(diamond_bits,jaune);
  dgc2 = makegc(diamond2_bits,jaune);
  SSgc = makegc(steel_bits,gris);
  bgc = makegc(boulder_bits,rouge);
  xgc = makegc(explosion_bits,rouge);
  lgc =
  lgc1 = makegc(lmonster_bits,bleu);
  lgc2 = makegc(lmonster2_bits,bleu);
  rgc =
  rgc1 = makegc(rmonster_bits,violet);
  rgc2 = makegc(rmonster2_bits,violet);
  egc =
  egc1 = makegc(eater_bits,violet);
  egc2 = makegc(eater2_bits,violet);
  EEgc =
  EEgc1 = makegc(steel_bits,cyan);
  EEgc2 = makegc(exit2_bits,cyan);
  ngc = makegc(nucbal_bits,rouge);
  BBgc =
  BBgc1 = makegc(blob_bits,rouge);
  BBgc2 = makegc(blob2_bits,rouge);
  tgc =
  tgc1 = makegc(wall_bits,gris);
  tgc2 = makegc(tinkle1_bits,bleu);
  tgc3 = makegc(tinkle2_bits,bleu);
}


void
kill_gcs()
{
	freebloc(&backup);

  freebloc(&pgc1);
  freebloc(&pgc2);
  freebloc(&WWgc);
  freebloc(&WWgc2);
  freebloc(&sgc);
  freebloc(&ggc);
  freebloc(&dgc1);
  freebloc(&dgc2);
  freebloc(&SSgc);
  freebloc(&bgc);
  freebloc(&xgc);
  freebloc(&lgc1);
  freebloc(&lgc2);
  freebloc(&rgc1);
  freebloc(&rgc2);
  freebloc(&egc1);
  freebloc(&egc2);
  freebloc(&EEgc1);
  freebloc(&EEgc2);
  freebloc(&ngc);
  freebloc(&BBgc1);
  freebloc(&BBgc2);
  freebloc(&tgc1);
  freebloc(&tgc2);
  freebloc(&tgc3);
}





void
init_level(lv)
  int             lv;
{
	int no=0;
	int n;
	int nv;

	levelnum=nv=lv;

	if (nv>=MAXTABLEAUX)
	{
		levelnum=nv=MAXTABLEAUX-1;
		cls();
		setcolor(blanc);
		afftext(160-7*8,80,"felicitations!");
		afftext(160-15*8-4,120,"vous avez termine boulder dash!");
		swap();
		waitdelay(5000);
		swap();
		copyscreen();
	}

	levels=levels1;
	if (nv>=25)
	{
		nv-=25;
		levels=levels2;
	}

	while(nv)
	{
		sscanf(levels[no],"%d",&n);
		no+=n+1;
		nv--;
	}

	EEgc = EEgc1;			
	/* don't blink EXIT */

  blobcollapse = False;
  blobcells = 0;
  scoreobs = True;
  tinkact = False;
  levincreased = False;
  strcpy(levname, "No-name-for-this-level-yet");


  {
    x = w;
    y = h;
    speed = 15;
    diareq = 12;
    diapoints = 0;
    extradiapoints = 0;
    blobbreak = 200;
    time__ = 1000;
  }


  {
    /* Extract the level parameters */
    sscanf(levels[no], "%d %d %d %d %d %d %d %d %d %s", &y, &x, &speed, &diareq,
	 &diapoints, &extradiapoints, &blobbreak, &tinkdur, &time__, levname);
	no++;



	time__*=2;
  
  }

  if (xin && yin)
  {
    x = xin;
    y = yin;
  }				/* read in from editor command line */
  /*
   * if (x > w) x = w; if (y > h) y = h; if (x < 2) x = 2; if (y < 1) y = 1;
   * 
   *
   * Iterate through each horizontal line
   */
  for (i = 0; i < y; ++i)
  {
    /* Load the next line from the file */
    {
      /* Go through each horizontal position and copy the data into */
      /* the level array. */
      for (j = 0; j < x; ++j)
      {
	/* Break out if line ends prematurely */
	if (levels[no][j] == '\n' || levels[no][j] == '\0')
	  field[i][j].content = STEEL;	/* break; */
	field[i][j].content = levels[no][j];
	field[i][j].changed = True;
	field[i][j].dir = N;
	field[i][j].speed = 0;
	field[i][j].stage = 0;
	field[i][j].caught = True;
	field[i][j].checked = False;
      }
    } 
    
    for (; j < x; ++j)
      field[i][j].content = STEEL;

	no++;
  }
}


static oldlevelnum,olddiareq,oldtime__;

/* Draw the score and level number */
void
draw_score(redrawall)
  short           redrawall;
{
  char            buf[40];

if (redrawall)
{
  oldlevelnum=levelnum;
  olddiareq=diareq;
  oldtime__=(time__/10);


  /* Build the output string */
  sprintf(buf, " niveau %02d  diamants %03d temps %03d", levelnum,
	  diareq, time__ / 10);
  /* Clear the current score line */

  pbox(0,0,320,8,0);
  pbox(0,192,320,8,0);
  setcolor(blanc);
  afftext(160-4*strlen(levname),0,levname);
  afftext(24,192,buf);

}
else
{
  if (oldlevelnum!=levelnum)
  {
  oldlevelnum=levelnum;
  pbox(11*8,192,16,8,0);
  setcolor(blanc);
  sprintf(buf,"%02d",levelnum);
  afftext(11*8,192,buf);
  }

  if (olddiareq!=diareq)
  {
  olddiareq=diareq;
  pbox(24*8,192,24,8,0);
  setcolor(blanc);
  sprintf(buf,"%03d",diareq);
  afftext(24*8,192,buf);
  }

  if (oldtime__!=(time__/10))
  {
  oldtime__=(time__/10);
  pbox(34*8,192,24,8,0);
  setcolor(blanc);
  sprintf(buf,"%03d",time__/10);
  afftext(34*8,192,buf);
  }

}

  /* Actually draw the text */
  scoreobs = False;
}



void
draw_field(redrawall)
  short           redrawall;
{
  char            c;
  int xd,yd,ok,bons;
	
	if (lost) redrawall=True;

	if (redrawall) cls();
	else
	if (!redrawall) waitdelay(50);

	lost=0;
	bons=0;

	xview=nxview;
	yview=nyview;

	nxview=0;
	nyview=0;

  /* Iterate through each horizontal line */
  for (i = y - 1; i >= 0; --i)
  {
    for (j = 0; j < x; ++j)
    {
      if (field[i][j].changed || redrawall)	/* only redraw changed cells */
      {
	c = field[i][j].content;
	xd=(j-xview)<<4;
	yd=((i-yview)<<4)+12;

	if ((!bons)&&(c==PLAYER))
	{
	  ok=1;
	  	nxview=0;
		nyview=0;

	  if (xd<5*16) { nxview= -8; ok=0; }
	  if (yd-12<3*16) { nyview= -4; ok=0; }
	  if (xd>320-6*16) { nxview=8; ok=0; }
	  if (yd>200-12-4*16) { nyview=4; ok=0; }
	  if (ok) bons++;
	}

	if ((xd>=0)&&(yd>=8)&&(xd+16<321)&&(yd+16<192))
	switch (c)
	{
	case GRASS:
	  putbloc(&ggc,xd,yd);
	  break;
	case SPACE:
	  if (!redrawall) putbloc(&sgc,xd,yd);
	  break;
	case PLAYER:
	  putbloc(&pgc,xd,yd);
	  break;
	case WALL:
	  putbloc(&wgc,xd,yd);
	  break;
	case MAGICWALL:
	  putbloc(&WWgc,xd,yd);
	  break;
	case DIAMOND:
	  putbloc(&dgc,xd,yd);
	  break;
	case BOULDER:
	  putbloc(&bgc,xd,yd);
	  break;
	case EXPLOSION:
	  putbloc(&xgc,xd,yd);
	  break;
	case LMONSTER:
	  putbloc(&lgc,xd,yd);
	  break;
	case RMONSTER:
	  putbloc(&rgc,xd,yd);
	  break;
	case NUCBAL:
	  putbloc(&ngc,xd,yd);
	  break;
	case BLOB:
	  putbloc(&BBgc,xd,yd);
	  break;
	case TINKLE:
	  putbloc(&tgc,xd,yd);
	  break;
	case EATER:
	  putbloc(&egc,xd,yd);
	  break;
	case EXIT:
	  putbloc(&EEgc,xd,yd);
	  break;
	case STEEL:
	default:
	  field[i][j].content = STEEL;
	  putbloc(&SSgc,xd,yd);
	  break;
	}
	field[i][j].changed = False;
      }
    }
  }
  if (scoreobs||redrawall)
    draw_score(redrawall);
    
    if (!bons)
    {
    	xview+=nxview;
    	yview+=nyview;
    	lost=1;
    }

    nxview=xview;
    nyview=yview;
}

void
set_cell(i, j, content)
  int             i, j;
  char            content;
{
  field[i][j].content = content;
  field[i][j].speed = 0;
  field[i][j].changed = True;
  field[i][j].stage = 0;
  field[i][j].caught = True;
  field[i][j].checked = False;
}
