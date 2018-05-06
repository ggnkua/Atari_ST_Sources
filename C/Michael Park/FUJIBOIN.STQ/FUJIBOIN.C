/***************************************************************************/
/*                                                                         */
/*  FujiBoink!  Written by Xanth Park.  23 Apr 86 (START mod: 27 Jun 86)   */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/***************************************************************************/

/* link: apstart,fujiboin,fujistuf,vdibind,aesbind,osbind */

#include <osbind.h>

#define GRID            1
#define SHADOW          2
#define FACE            4
#define NEARSIDE        6
#define BARSIDE         8
#define FARSIDE         10
#define MAXBOT          198
#define MAXRIGHT        19

extern int
  moov(),kleer(),
  inton(),intoff(),fujiy,fflag;

int
  contrl[12],intin[128],ptsin[128],intout[128],ptsout[128], /* GEM globals */
  dummy,
  gfh;  /* G.F.Handle */

static int
  pixel[]={ 0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 1 },
  advertising=0;        /* flag: re-display commercial?
                         *  -1 => always; 0 => not this time; 1 => this time
                         */
int
  kolors[32][144],      /* 32views * 72lines * 2colors */
  rnbow[512],           /* 512 colors */
  kolbak,               /* color of fuji's back. See also fflag */
  fhandle;              /* File handle */

long kolptr;            /* pointer to color table for current view */

static int couleurs[5][10]={
/* color table to fade title screen to red and white... */
  {0x777, 0x766, 0x056, 0x056, 0x700, 0x700, 0x740, 0x740, 0x005, 0x005},
  {0x777, 0x755, 0x256, 0x245, 0x722, 0x700, 0x752, 0x730, 0x225, 0x204},
  {0x777, 0x744, 0x466, 0x434, 0x744, 0x700, 0x764, 0x720, 0x446, 0x403},
  {0x777, 0x722, 0x667, 0x622, 0x766, 0x700, 0x776, 0x710, 0x667, 0x602},
  {0x777, 0x700, 0x777, 0x700, 0x777, 0x700, 0x777, 0x700, 0x777, 0x700}
};

main(){
  int
    intin[11],intout[57],savepalette[16],
    view,
    rez,
    i;
  appl_init();
  if( (rez = xbios( 4 )) == 2){ /* save and check resolution */
    form_alert( 1, "[3][|Monochrome FujiBoink!?|    Sacrilege!!][Sorry]" );
  }else{
    if( (fhandle = Fopen( "FUJIBOIN.D8A", 0 )) < 0 ){
      form_alert( 1, "[3][|Can't open|FUJIBOIN.D8A][Uh-oh]" );
    }else{
      graf_mouse( 256, 0L );    /* hide mouse */
      Setscreen( -1L, -1L, 0 ); /* lorez */
      gfh = graf_handle( &dummy, &dummy, &dummy, &dummy );
      for( i=0; i<10; i++ ) intin[i] = 1;
      intin[10] = 2;
      v_opnvwk( intin, &gfh, intout );
      v_clrwk( gfh );
      for( i=0; i<16; i++) savepalette[i] = Setcolor( i, -1 );
      iniz();           /* initialize */
      inton();  /* enable interrupts */
      intro();  /* put up title */
      soundiniz();
      boink();  /* do the bounce... */
      soundoff();
      intoff(); /* turn off interrupts */
      Fclose( fhandle );
      v_clrwk( gfh );
      Setpallete( savepalette );
      v_clsvwk( gfh );
      Setscreen( -1L, -1L, rez );       /* restore resolution */
    }
  }
  appl_exit();  /* say good-night, Gracie */
}/* main */

static int
  left[]=
    {0,0,0,1,1,1,2,2,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3},
  right[]=
    {6,6,6,6,6,6,6,6,6,5,5,5,5,6,6,7,7,7,8,8,8,9,9,9,9,10,10,10,10,10,10,10},
  bot[]={
    88,89,89,90,90,90,91,91,91,91,91,91,91,90,90,90,
    89,89,88,88,87,86,86,85,84,83,84,85,86,86,87,88},
  screenbuff[16128],    /* 32000+ bytes for alternate screen */
  fujistuff[54798],     /* 109596 bytes */
  work;                 /* flag: current work screen (0,1) */

static long
  pix[32],      /* pointers to 32 views of fuji */
  screen[2];    /* 2 screens. */

iniz(){         /* initializer */
  int i,j,prev;

  screen[0]=Physbase();
  screen[1]=(((long)screenbuff + 255)>>8)<<8;/* 256-byte boundary */
  Setcolor( 0, 0x777 );                 /* white */
  Setcolor( GRID, 0x700 );              /* red */
  Setcolor( SHADOW, 0x444 );            /* grey */
  Setcolor( SHADOW|GRID, 0x400 );       /* not-so red */
  drawgrid();
  gettitle();
  settitle(); fadein();

  Fread( fhandle, 109596L, fujistuff );

  pix[25]=fujistuff;
  for( j=1; j<32; j++ ){
    i=(j+25)&31; prev=(i-1)&31;
    pix[i]=pix[prev]+(right[prev]-left[prev]+1)*6*(bot[prev]+1);
  }
  fujiy = 0;
  setrnbow(); setkolors();
  copyscreen( screen[0], screen[1] );
  return;
}/* iniz */

static int titlepic[3400];      /* 6800 bytes for title pic */

gettitle(){
/*      Get commercial.
 *      Just read in picture fragment, store in titlepic[].
 */
  Fread( fhandle, 6800L, titlepic );
}/* gettitle */

settitle(){
/*      Put up commercial in work screen.
 */
  register int *s,*d,i,j;
  titlecolor( 4 );
  s = titlepic; d = screen[ work ] + 105*160 + 40;
  for( i=105; i<190; i++ ){
    for( j=40; j; j-- ){
      *d++ = *s++;
    }
    d += 40;
  }
}/* settitle */

setrnbow(){
/*      Setup rnbow array with 512 colors.
 *      Red component multiplied by 3 for a little more
 *      variety in the rainbow... probably unnecessary
 *      but what the heck?
 */
  int
    i,j,k,r,g,b,n;
  n=0;
  for( r=0; r<8; r++ ){
    for( g=0; g<8; g++ ){
      for( b=0; b<8; b++ ){
        rnbow[ n++ ] = ((r*3)&7)*256 + b*16 + g;
      }
    }
  }
}/* setrnbow */

static int barkolor[32];

setkolors(){
/*      Setup kolor array.
 *      Read in 2304 bytes from file (generated by FUJISHAD)
 *      (2304 = 32view * 72lines); each byte converted to a
 *      color word (0-> dk. blue, 255-> lt. blue).
 */
  int iz,view,i,j;
  char *z;
  z = screen[1];        /* use screen1 temporarily */
  Fread( fhandle, 2304L, z );
  iz = 0; view=25;
  for( i=0; i<32; i++ ){
    barkolor[view] = shade( ((z[iz]&255)*100)/512 );
    for( j=0; j<72; j++ ){
      kolors[view][j+j+1] = shade( ((z[iz++]&255)*100)/256 );
    }
    if( ++view == 32 ) view = 0;
  }
  kolors[26][1] = couleurs[0][1];       /* !!! */
}/* setkolors */

#define NUMSHADES       19
int shade( s )
int s;  /* s in 0..99 */
{
  static int
    shades[]={
      0x003, 0x113, 0x114, 0x115, 0x116, 0x117, 0x027, 0x037, 0x047,
      0x057, 0x157, 0x267, 0x367, 0x377, 0x477, 0x577, 0x677, 0x677, 0x777};
  return( shades[ (s*NUMSHADES)/100 ] );
}/* shade */

boink(){
/*      Make the fuji bounce.
 */
  int
    i,
    x,
    dx,         /* dx=0: moving left, dx=1: right, dx=-1: straight down */
    p=0,        /* y=p^2, p counts up and down so fuji bounces parabolically */
    dp=1,       /* dp=1: p counts up (fuji falls) */
    drapeau=1,  /* a flag */
    boom=0,     /* noize flag */
    y,view;

  x = 57; dx = -1;
  while( qui() == 0 ){  /* key not pressed... */
    y=15+(110L * p * p)/1600;
    view = x & 31;
    movit( x, y );
    scrollkolors( view );
    if( boom ){
      boom = 0; thud();
    }
    drapeau = (!drapeau) && (x==57) && (p==0) && advertising;
    if( dx == 1 ){
      if( ++x==114 ){
        dx=0; boom = 1;
      }
    }else if( dx == 0 ){
      if( --x==0 ){
        dx=1; boom = 1;
      }
    }
    if( dp ){
      if( ++p==40 ){/* hitting bottom? */
        dp=0; boom = 1;
        if( dx < 0 ){/* falling straight down? */
          dx = 0;
          Setcolor( FARSIDE, shade(10) );/* set far side color to a dk blue */
          Setcolor( FARSIDE|GRID, shade(10) );
        }
      }
    }else{
      if( --p==0 ){
        dp=1;
      }
    }
    Setscreen( -1L, screen[work], -1 ); /* these statements     */
    if( view==9 ) fflag ^= 1;           /* should all execute   */
    fujiy = y;                          /* within the same      */
    kolptr = kolors[view];              /* video frame (i.e. no */
    Setcolor( BARSIDE, barkolor[view] );/* VBLANK in between    */
    Setcolor( BARSIDE|GRID, barkolor[view] );/*         .       */
    kolbak = kolors[(view+16)&31][1];   /*              .       */
    xbios( 37 );        /* vsync: wait for vblank.      .       */

    if( drapeau ){
      if( advertising == 1) advertising = 0;
      titlecolor( 4 );
      settitle(); fadein();
      for( i=0; i<300; i++ ){
        scrollkolors( view );
        xbios( 37 );
      }
      fadeout();
      dx = -1; x = 57;
      clear( 5, 105, 14, 189 );
    }
    work ^= 1;
  }
  Setscreen( -1L, screen[0], -1 );
}/* boink */

thud(){
/*      make thud noize
 */
  Giaccess( 0, 13|128 );        /* envelope shape */
}/* thud */

titlecolor( n )
/*      Set title colors
 *      use nth row of couleurs
 */
int n;
{
  int i;
  for( i=0; i<10; i++ ) Setcolor( i+6, couleurs[n][i] );
  kolors[26][1] = couleurs[n][1];       /* !!! */
  for( i=0; i<3; i++ ){
    scrollkolors( 25 ); xbios( 37 );
  }
}/* titlecolor */

intro(){
/*      Introduction.
 *      Leave fuji scrolling for 300 jiffies, fade out title.
 */
  int i,j,k;
  work = 0;
  fflag = 1;            /* start with rainbow face */
  fujiy = 15;
  kolptr = kolors[25];  /* fuji view 25 at middle of screen */
  movit( 57, 15 );
  for( i=0; i<300; i++ ){
    scrollkolors( 25 );
    xbios( 37 );
  }
  fadeout();
  clear( 5, 105, 14, 189 );
  work = 1;
  clear( 5, 105, 14, 189 );
  if( Bconstat( 2 ) ){  /* key pressed => always advertise */
    Bconin( 2 ); advertising = -1;
  }
}/* intro */

fadein(){
/*      fade title in
 *      using colors in couleurs[]
 */
  int i;
  for( i=3; i>=0; i-- ){
    titlecolor( i );
  }
}/* fadeout */

fadeout(){
/*      fade title out
 *      using colors in couleurs[]
 */
  int i;
  for( i=1; i<=4; i++ ){
    titlecolor( i );
  }
}/* fadeout */

movit( x, y )
/*      Move the fuji.
 *      Move fuji image into the current work screen
 *      at the proper x,y location (image # depends on x).
 *      Clear out leftovers from last move.
 */
int x, y;
{
  int
    view,disp,
    srcinc,dstinc,
    newtop,newbot,newleft,newright,
    i,j;
  static int
    oldtop[]={999,999},oldbot[]={0,0},oldleft[]={999,999},oldright[]={0,0};
  int
    *src,*dst;
  view = x & 31; disp = ( x>>5 ) << 2;
  src = pix[view];
  newtop = y;
  newbot = y + bot[view]; if( newbot>MAXBOT ) newbot = MAXBOT;
  newleft = left[view] + disp; newright = right[view] + disp;
  if( newright<=MAXRIGHT ){
    srcinc = 0;
  }else{
    srcinc = (newright - MAXRIGHT) * 3; newright = MAXRIGHT;
  }
  dst = screen[work] + (newleft<<3) + y*160;
  dstinc = 80 - ((newright - newleft + 1) << 2);
  moov( src, dst, srcinc, dstinc,
    (int)(newbot-newtop), (int)(newright-newleft) );
  --newtop; ++newbot; --newleft; ++newright;

  if( newtop > oldtop[work] )
    clear( oldleft[work], oldtop[work], oldright[work], newtop );
  oldtop[work] = newtop;
  if( newbot < oldbot[work] )
    clear( oldleft[work], newbot, oldright[work], oldbot[work] );
  oldbot[work] = newbot;
  if( newleft > oldleft[work] )
    clear( oldleft[work], oldtop[work], newleft, oldbot[work] );
  oldleft[work] = newleft;
  if( newright < oldright[work] )
    clear( newright, oldtop[work], oldright[work], oldbot[work] );
  oldright[work] = newright;
}/* movit */

clear( u0, v0, u1, v1 )
/*      clear a rectangle
 *      u0,u1 in xpixels/16, v0,v1 in ypixels
 */
int u0, v0, u1, v1;
{
  register int *dst,i,j,dstinc;

  dst = screen[work] + (u0<<3) + v0*160;
  dstinc = 80 - ((u1 - u0 + 1) << 2);
  kleer( dst, dstinc, (int)(v1-v0), (int)(u1-u0) );
}/* clear */

#define KKK     512
scrollkolors( view )
/*      Move the appropriate part of the rainbow table
 *      into the color table for the current view
 */
int view;
{
  register int i,j;
  static int
    irnbow=0;   /* rainbow index: gets decremented so rainbow scrolls */
  j = irnbow;
  for( i=0; i<72; i++ ){
    kolors[view][i<<1] = rnbow[j++];
    if( j == KKK ) j = 0;
  }
  if( irnbow == 0 ) irnbow = KKK;
  irnbow--;
}/* scrollkolors */

drawgrid(){
/*      Guess what this does..
 */
  int pxy[4],i,j,k;
  vsf_color( gfh, pixel[GRID] ); vsf_interior( gfh, 1 );
  for( i=0; i<3; i++ ){
    for( j=0; j<4; j++ ){
      pxy[0] = j * 64 + 32; pxy[1] = i * 50 + 25;
      pxy[2] = pxy[0]+31; pxy[3] = pxy[1]+24;
      v_bar( gfh, pxy );
      for( k=0; k<2; k++ ){
        pxy[k+k] += 32; pxy[k+k+1] += 25;
      }
      v_bar( gfh, pxy );
    }
  }
}/* drawgrid */

copyscreen( s, d )
/*      Another mysterious routine
 */
long *s,*d;
{
  int i;
  for( i=0; i<8000; i++ ) *d++ = *s++;
}

static int soundsave[14];       /* save sound chip registers */

soundiniz(){
/*      initialize sound chip...
 */
  int i;
  for( i=0; i<14; i++ ) soundsave[i] = Giaccess( 0, i );
  Giaccess( 63-9, 7|128 );              /* voice A: tone & noize  */
  Giaccess( 16, 8|128 );                /* volume A */
  Giaccess( 255, 0|128 );               /* fine tune A */
  Giaccess( 15, 1|128 );                /* coarse tune A */
  Giaccess( 31, 6|128 );                /* noize period */
  Giaccess( 0, 11|128 );                /* fine tune envelope */
  Giaccess( 16, 12|128 );               /* coarse tune envelope */
}/* soundiniz */

soundoff(){
/*      kill sound
 */
  int i;
  for( i=0; i<14; i++ ) Giaccess( soundsave[i], i|128 );
}/* soundoff */

int qui(){
/*      check qui-board
 *      if space bar pressed, return -1;
 *      if function key pressed, wait until another key pressed;
 *      any other key: set advertising flag, return 0
 */
  int ret=0,key;
  if( Bconstat( 2 ) ){  /* qui pressed? */
    if( advertising == 0 ) advertising = 1;
    if( (key = (Bconin( 2 )&255)) == ' ' ) ret = -1;
    if( key == 0 ){     /* fn key... */
      while( Bconstat( 2 ) == 0 );      /* wait for key */
      Bconin( 2 );
    }
  }
  return( ret );
}/* qui */

