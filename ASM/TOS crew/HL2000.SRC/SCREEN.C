/***********************************************************************************/
/* Hland screen routines */

/* game defines */
#define OK 0
#define STOP 1
#define FULL_LINES 10 /* aantal sprite lines */
#define MAPLEN 540 /* maplengte is 540 words */
#define MAPHEIGHT 100UL /* map hoogte */
#define ANI_LEN 56 /* animatie lengte is 56 stappen */
#define X_BASE 3 /* x-offset die we nul noemen */
#define JUMP_HEIGHT 4 /* sprong hoogte in sprites */
#define JOY_UP 1
#define JOY_LEFT 4
#define JOY_RIGHT 8
#define JOY_DOWN 2
#define JOY_FIRE 128

#if 0 /* allemaal assembley */
void draw_main_sprite0(unsigned long *scr, unsigned long **list, unsigned long* sprite)
{
  unsigned long mask;
  unsigned long sprite_data;
  unsigned long scherm_data;
  unsigned long *mpa;
  unsigned long *mpb;
  list+=2; /* eerste twee data blokken zijn voor als sprite lager ligt */
  mpa=*list++;
  mpb=*list++;
  mpa+=16; /* sla 16 lijnen over */
  /* lijn 0 */
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 1 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 2 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 3 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 4 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 5 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 6 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 7 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 8 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 9 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 10 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 11 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 12 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 13 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 14 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 15 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  /* lijn 16 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 17 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 18 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 19 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 20 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 21 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* einde eerste helft */
  list+=2; /* skip twee masks */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr+=21*40; /* terug naar het begin */
  /* lijn 0 */
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 1 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 2 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 3 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 4 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 5 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 6 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 7 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 8 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 9 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 10 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 11 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 12 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 13 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 14 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 15 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  /* lijn 16 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 17 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 18 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 19 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 20 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 21 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* done */
}

void draw_main_sprite1(unsigned long *scr, unsigned long **list, unsigned long* sprite)
{
  unsigned long mask;
  unsigned long sprite_data;
  unsigned long scherm_data;
  unsigned long *mpa;
  unsigned long *mpb;
  mpa=*list++;
  mpb=*list++;
  mpa+=16+12; /* sla 16+12 lijnen over */
  mpb+=12;
  /* lijn 0 */
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 1 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 2 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 3 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 4 */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 5 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 6 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 7 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 8 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 9 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 10 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 11 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 12 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 13 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 14 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 15 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 16 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 17 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 18 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 19 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 20 */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 21 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* einde eerste helft */
  mpa=*list++;
  mpb=*list++;
  mpa+=16+12;
  mpb+=12;
  scr+=21*40; /* terug naar het begin */
  /* lijn 0 */
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 1 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 2 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 3 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 4 */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 5 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 6 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 7 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 8 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 9 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 10 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 11 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 12 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 13 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 14 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 15 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 16 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 17 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 18 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 19 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 20 */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 21 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* done */
}

void draw_main_sprite2(unsigned long *scr, unsigned long **list, unsigned long* sprite)
{
  unsigned long mask;
  unsigned long sprite_data;
  unsigned long scherm_data;
  unsigned long *mpa;
  unsigned long *mpb;
  mpa=*list++;
  mpb=*list++;
  mpa+=16+8; /* sla 16 lijnen over */
  mpb+=8;
  /* lijn 0 */
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 1 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 2 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 3 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 4 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 5 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 6 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 7 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 8 */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 9 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 10 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 11 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 12 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 13 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 14 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 15 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 16 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 17 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 18 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 19 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 20 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 21 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* einde eerste helft */
  mpa=*list++;
  mpb=*list++;
  mpa+=16+8;
  mpb+=8;
  scr+=21*40; /* terug naar het begin */
  /* lijn 0 */
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 1 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 2 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 3 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 4 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 5 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 6 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 7 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 8 */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 9 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 10 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 11 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 12 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 13 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 14 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 15 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 16 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 17 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 18 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 19 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 20 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 21 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* done */
}

void draw_main_sprite3(unsigned long *scr, unsigned long **list, unsigned long* sprite)
{
  unsigned long mask;
  unsigned long sprite_data;
  unsigned long scherm_data;
  unsigned long *mpa;
  unsigned long *mpb;
  mpa=*list++;
  mpb=*list++;
  mpa+=16+4; /* sla 16 lijnen over */
  mpb+=4;
  /* lijn 0 */
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 1 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 2 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 3 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 4 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 5 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 6 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 7 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 8 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 9 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 10 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 11 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 12 */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 13 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 14 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 15 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 16 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 17 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 18 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 19 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 20 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 21 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* einde eerste helft */
  list+=2; /* skip twee masks */
  mpa=*list++;
  mpb=*list++;
  mpa+=16+4;
  mpb+=4;
  scr+=21*40; /* terug naar het begin */
  /* lijn 0 */
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 1 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 2 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 3 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 4 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 5 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 6 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 7 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 8 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 9 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 10 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 11 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 12 */
  mpa=*list++;
  mpb=*list++;
  mpa+=16;
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 13 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 14 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 15 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 16 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 17 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 18 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 19 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 20 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* lijn 21 */
  scr-=42;
  mask=(*mpa++ | *mpb++) & *sprite++;
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* eerste twee bitplanes */
  sprite_data=mask & *sprite++;
  scherm_data=mask | *scr;
  *scr++=scherm_data^sprite_data;       /* tweede set bitplanes */
  /* done */
}
#endif

#if 0
void update_screen(unsigned long *scr, unsigned long **list, int offset)
{
  /*
    scr wijst naar scherm adres waar de data moet komen
    list is een lijst van sprite adressen die moeten worden getekend
    int offset is de lijn offset voor de sprites
  */
  int i;
  unsigned long* p;
  /*
    eerst de bovenste partiele sprites tekenen
    offset=0: 16 lines
    offset=1: 12 lines
    offset=2:  8 lines
    offset=3:  4 lines
  */
  switch(offset)
  {
    case 0:
		{
		  /* start line 1 */
		  p=*list++;
		  /* sprite 1 */
		  *scr++=*p++;*scr++=*p++;                  /* line 0 */
		  scr[0x01*40-2]=*p++;scr[0x01*40-1]=*p++;  /* line 1 */
		  scr[0x02*40-2]=*p++;scr[0x02*40-1]=*p++;  /* line 2 */
		  scr[0x03*40-2]=*p++;scr[0x03*40-1]=*p++;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 2 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 3 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 4 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 5 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 6 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 7 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 8 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 9 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 10 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 11 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 12 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 13 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 14 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 15 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 16 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 17 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 18 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 19 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  p=*list++;
		  /* sprite 20 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
		  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
		  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
		  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
		  /* einde sprite lijn */
		  scr+=600; /* 15*160/4 */
	    break;
		}
    case 1:
    {
		  /* start line 1 */
		  p=*list++;
		  p+=8;
		  /* sprite 1 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 2 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 3 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 4 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 5 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 6 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 7 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 8 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 9 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 10 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 11 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 12 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 13 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 14 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 15 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 16 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 17 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 18 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 19 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 20 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  /* einde sprite lijn */
		  scr+=440; /* (16-1-4)*160/4 */
	    break;
		}
    case 2:
    {
		  /* start line 1 */
		  p=*list++;
		  p+=16;
		  /* sprite 1 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 2 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 3 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 4 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 5 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 6 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 7 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 8 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 9 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 10 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 11 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 12 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 13 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 14 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 15 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 16 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 17 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 18 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 19 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  p+=16;
		  /* sprite 20 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  /* einde sprite lijn */
		  scr+=280; /* (16-1-4)*160/4 */
	    break;
		}
    case 3:
    {
		  /* start line 1 */
		  p=*list++;
		  p+=24;
		  /* sprite 1 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 2 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 3 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 4 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 5 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 6 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 7 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 8 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 9 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 10 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 11 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 12 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 13 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 14 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 15 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 16 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 17 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 18 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 19 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  p+=24;
		  /* sprite 20 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  /* einde sprite lijn */
		  scr+=120; /* (16-1-4)*160/4 */
	    break;
		}
  }
  /*
    ram main sprites in mem
  */
  i=FULL_LINES-4;
  do
  {
  /* start line 1 */
  p=*list++;
  /* sprite 1 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 2 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 3 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 4 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 5 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 6 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 7 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 8 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 9 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 10 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 11 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 12 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 13 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 14 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 15 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 16 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 17 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 18 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 19 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  p=*list++;
  /* sprite 20 */
  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
  scr[0x0c*40-2]=*p++ ;scr[0x0c*40-1]=*p++ ;  /* line c */
  scr[0x0d*40-2]=*p++ ;scr[0x0d*40-1]=*p++ ;  /* line d */
  scr[0x0e*40-2]=*p++ ;scr[0x0e*40-1]=*p++ ;  /* line e */
  scr[0x0f*40-2]=*p++ ;scr[0x0f*40-1]=*p++ ;  /* line f */
  /* einde sprite lijn */
  scr+=600; /* 15*160/4 */
  }
  while(--i>=0);
  switch(offset)
  {
    case 3:
    {
		  /* start line 1 */
		  p=*list++;
		  /* sprite 1 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 2 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 3 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 4 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 5 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 6 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 7 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 8 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 9 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 10 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 11 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 12 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 13 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 14 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 15 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 16 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 17 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 18 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  p+=8;
		  /* sprite 19 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  p=*list++;
		  /* sprite 20 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  scr[0x08*40-2]=*p++ ;scr[0x08*40-1]=*p++ ;  /* line 8 */
		  scr[0x09*40-2]=*p++ ;scr[0x09*40-1]=*p++ ;  /* line 9 */
		  scr[0x0a*40-2]=*p++ ;scr[0x0a*40-1]=*p++ ;  /* line a */
		  scr[0x0b*40-2]=*p++ ;scr[0x0b*40-1]=*p++ ;  /* line b */
		  /* einde sprite lijn */
	    break;
		}
    case 2:
    {
		  /* start line 1 */
		  p=*list++;
		  /* sprite 1 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 2 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 3 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 4 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 5 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 6 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p+=16;
		  /* sprite 7 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 8 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p+=16;
		  /* sprite 9 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 10 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p+=16;
		  /* sprite 11 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 12 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p+=16;
		  /* sprite 13 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 14 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p+=16;
		  /* sprite 15 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 16 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p+=16;
		  /* sprite 17 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 18 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p+=16;
		  /* sprite 19 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  p=*list++;
		  /* sprite 20 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  scr[0x04*40-2]=*p++ ;scr[0x04*40-1]=*p++ ;  /* line 4 */
		  scr[0x05*40-2]=*p++ ;scr[0x05*40-1]=*p++ ;  /* line 5 */
		  scr[0x06*40-2]=*p++ ;scr[0x06*40-1]=*p++ ;  /* line 6 */
		  scr[0x07*40-2]=*p++ ;scr[0x07*40-1]=*p++ ;  /* line 7 */
		  /* einde sprite lijn */
	    break;
		}
    case 1:
    {
		  /* start line 1 */
		  p=*list++;
		  p+=32; /* eerste helft sprite overslaan... */
		  /* sprite 1 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 2 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 3 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 4 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 5 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 6 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 7 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 8 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 9 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 10 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 11 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 12 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 13 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 14 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 15 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 16 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 17 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 18 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p+=24;
		  /* sprite 19 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  p=*list++;
		  /* sprite 20 */
		  *scr++=*p++ ;*scr++=*p++ ;                  /* line 0 */
		  scr[0x01*40-2]=*p++ ;scr[0x01*40-1]=*p++ ;  /* line 1 */
		  scr[0x02*40-2]=*p++ ;scr[0x02*40-1]=*p++ ;  /* line 2 */
		  scr[0x03*40-2]=*p++ ;scr[0x03*40-1]=*p++ ;  /* line 3 */
		  /* einde sprite lijn */
	    break;
	    case 0:
	    default:
	    ;
		}
  }
}
#endif
