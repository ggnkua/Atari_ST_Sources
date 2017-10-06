/* bldrdash.c */

/*********************************************/
/* you just keep on pushing my luck over the */
/*          BOULDER        DASH              */
/*                                           */
/*     Jeroen Houttuin, ETH Zurich, 1990     */
/*********************************************/

#include "header.h"
#include "bldrdash.h"

extern int lost;
extern unsigned int gamepal[];

bloc            whitegc, scoregc, BBgc, BBgc1, BBgc2, ngc, egc, egc1,
                egc2, EEgc1, WWgc, WWgc2, EEgc2, EEgc, lgc, lgc1, lgc2, rgc,
                rgc1, rgc2, xgc, SSgc, bgc,
                dgc, dgc1, dgc2, wgc, pgc, pgc1, pgc2, sgc, ggc, tgc, tgc1,
                tgc2, tgc3;
char            levname[64];	/* Levelname */
int             i, j, ii, jj, jjj;
int             blobbreak;
int             critical;
int             time__;		/* Current clock tick number */
int             blobcells;
int             tinkdur;	/* Tinkle duration */
Bool            tinkact;	/* Tinkle active   */
Bool            levincreased;
int             x, y, xin, yin, players,  levelstart,
                diareq, diapoints, extradiapoints;
Bool            stoplevel, blobcollapse , steal;

int				curorder;

/* Current order which player has */
/* typed at the keyboard. */

struct cell			field[h][w];

Bool            gamestop;
Bool            scoreobs;	/* is score line obsolete ? */
int             levelnum;	/* Current level number */
int             lives;		/* Current number of lives */
int             score;		/* Total score */
int             speed;		/* Speed of game.  1 is slowest, 15 is
				 * default */
char            filename[300];	/* Current file name of this level */



#define GAUCHE '<'
#define DROITE '>'
#define BAS 'v'
#define HAUT '^'

extern int nxview,nyview;


void
init_vars()
{
  blobbreak = 100;
  critical = 100;
  blobcells = 0;
  curorder = STAND;
  gamestop = False;
  scoreobs = True;
  stoplevel = False;
  levelnum = 1;
  speed = 1;
  lives = 4;
  xin = 0;
  yin = 0;
  players = 1;
}

 
/* Handle a key stroke by the user. */
void
handle_key(keyh)
int keyh;
{
  if (players <= 0)
  {
    init_level(levelnum);
    stoplevel = False;
    draw_field(True);
    gamestop = False;
    players = 1;
    return;
  }
  switch (keyh)
  {
  case 'h':
  case 'H':
  	cls();
  	putbackup();
  	setcolor(15);
  	print("");
  	print("");
  	print("");
  	print("");
  	print("");
  	print("");
  	print("");
  	print("");
  	print(" pave numerique : deplacer fenetre");
    print(" deplacements : touches flechees");
    print(" barre espace : prendre sans bouger");
    print(" p : podium");
    print(" q : quitter le jeu");
    print(" i : redemarrer le tableau");
    print(" +,: tableau suivant");
    print(" - : tableau precedent");
    swap();
    putbackup();
    getch();
    empty();
    swap();
    putbackup();
    break;
  case 'p':
  case 'P':
  	cls();
  	putbackup();
  	setcolor(15);
  	podium();
    swap();
    putbackup();
    getch();
    empty();
    swap();
    putbackup();
    break;
  case GAUCHE:
    curorder=LEFT;
    gamestop = False;
    break;
  case HAUT:
    curorder=UP;
    gamestop = False;
    break;
  case BAS:
    curorder=DOWN;
    gamestop = False;
    break;
  case DROITE:
    curorder=RIGHT;
    gamestop = False;
    break;
  }
}



void
ticker()
{
  if (time__)
    time__--;
  if (tinkact)
    tinkdur--;
  if (time__ % 10 == 1)
    scoreobs = True;

  if (!gamestop)
  {
    calculate_field();
    draw_field(0);

  }
  if (stoplevel)
  {
    init_level(levelnum);
    gamestop = False;
    stoplevel = False;
  }
  
    getbackup();
    swap();
    putbackup();
}




int main()
{
  int	keycount;
  int	xev;

if (initsystem())
{
	setpalette(gamepal);

  init_vars();

	get_username();
	

	setcolor(15);
	afftext(160-6*8-4,80,"boulder dash!");
	afftext(8,200-40-16, " documentation dans \"bldrdash.txt\"");
	afftext(8,200-40, " touches:");
	afftext(8,200-24, " h: aide");
	afftext(8,200-16, " q: quitter le jeu");
	swap();

  levelstart = levelnum;
  init_level(levelnum);
  make_gcs();
 
 cls();
 
  draw_field(True);
  draw_score();

	getbackup();
	swap();
	putbackup();

	keycount=0;

  while ((keycount!='q')&&(keycount!='Q'))
  {

	xev=0;
	buthit();

	if (!keymap[' ']) steal=0; else steal=1;

	if (kbhit()) xev=getch();

	if (keymap[GAUCHE]) xev=GAUCHE;
	if (keymap[DROITE]) xev=DROITE;
	if (keymap[BAS]) xev=BAS;
	if (keymap[HAUT]) xev=HAUT;

	switch(xev)
	{
		case ' ':
			steal=1;
			xev=0;
			if (kbhit()) xev=getch();
			break;
		case '1':
			lost=1;
			nxview-=10;
			nyview+=6;
			break;
		case '2':
			lost=1;
			nyview+=6;
			break;
		case '3':
			lost=1;
			nxview+=10;
			nyview+=6;
			break;
		case '4':
			lost=1;
			nxview-=10;
			break;
		case '6':
			lost=1;
			nxview+=10;
			break;
		case '7':
			lost=1;
			nxview-=10;
			nyview-=6;
			break;
		case '8':
			lost=1;
			nyview-=6;
			break;
		case '9':
			lost=1;
			nxview+=10;
			nyview-=6;
			break;			
	}

    if (xev)
    {
      keycount = xev;
      
	switch (keycount)
	{
	case '+':
	case ',':
		inclev();
		init_level(levelnum);
		lost=1;
		break;
	case '-':
		if (levelnum) levelnum--;
		init_level(levelnum);
		lost=1;
		break;
	case 'i':
	case 'I':
	  	init_level(levelnum);
	  	lost=1;
	  break;
	default:
	  handle_key(keycount);
	  break;
	}

    }
    
    ticker();
    
    
  }
	killsystem();
}

	return 0;
}
