#include "c_includes.h"
#ifdef LATTICE
#include "compat.h"
#endif
/*
 * Cbzone - xbzone w/ improvements in C
 *
 * Version 1.0 in Fortran by Justin S. Revenaugh -- MIT (5/86)
 * C port and modifications by Todd W. Mummert -- CMU (12/90)
 *   email bugs and comments concerning this game to:
 *                 mummert+@sam.cs.cmu.edu
 *
 * Copyright Notice:  This program is freely distributable on a
 * nonprofit basis as long as this notice is maintained on all
 * copies. Inclusion of any program code or derivative thereof
 * for commercial purposes is expressly forbidden. 
 * December 10, 1990.
 *
 * ATARI Mods - Roland Givan Summer/Autumn 1993
 *
 * RCS Info
 *  $Header: c_main.c,v 1.1 91/01/12 02:03:34 mummert Locked $
 *
 * Bugs/Features:
 *   Tanks still pass through each other.  Missiles/copters don't
 *   collide with one another unless below 80 ft.  Consider these
 *   features for now.
 *
 * Enhancement Ideas:
 *  -Convert the graphics routines to general purpose routines...
 *   The graphics are either multiline(segments) or polyline(connected).
 *   Polyline lines can either be open or closed.  This could all be
 *   done in a single routine with the number of mlines and plines
 *   passed in...maybe too much bookkeeping involved.
 *  -Have the ability to have both tanks and missiles on the screen at
 *   the same time.  Never bothered to do it, for I initially thought
 *   it would be unplayable.  Not so sure now.
 *  -Make this multiplayer...two basic approaches.  The first is one
 *   program controlling two displays.  The second is running on
 *   different machines, passing the necessary objects back/forth.  Since
 *   you wouldn't need to pass graphics information, this is not
 *   a lot of information to update. Instead of a call to move<enemy>
 *   you would get back the changes made by your opponent.
 *
 *  -If you make any interesting changes, please send them to me and I'll
 *   incorporate them into the next release.
 */

Option option;
Optionp opt = &option;

#ifdef ATARI
char dummy[100];
extern char explode[];
extern char explode2[];
extern char shot[];
#endif

/*
 * Just initialize the array prior to starting play.  Associate
 * the salvos with the correct objects.  Set the cosines of some
 * of the angles to 1.
 */
void initarray(o)
     Genericp o;
{
  Genericp s;
  Genericp g;
  Genericp pl = o;
  int i, j;
  
  pl->type = IS_PLAYER;                 /* player is always the first */
  pl->attr = START_LIVING;              /* object.  Same size as the */
  pl->criticalx = 45.0;                 /* other tanks.  */
  pl->criticaly = 70.0;
#ifdef ATARI
  pl->azm=0.0;	/* doesn't appear to get set anywhere else - but needs
				to be - so do it here! */
#endif
  for (g=o; g<o+opt->mobjects; g++) {
    g->ca = 1.0;                        /* for those objects which */
    for (j=0; j<5; j++)                 /* have rotating parts, set */
      g->dc[j].ctp = g->dc[j].cta = 1.0;  /* the cos to 1.0 */
  }

  s = o+opt->sstart;                    /* player gets msalvos, each  */
  pl->salvo = s;                        /* enemy gets one.  the salvos */
  for (i=0; i<opt->msalvos; i++) {      /* must know who their owner */
    s->salvo = pl;                      /* is for a variety of reasons */
    s->type = IS_SALVO;                 /* first the player */
    s->lntype = LN_SALVO;
    s++;
  }
  for (g=o+opt->estart; g<o+opt->lstart; g++) {
    g->salvo = s;                       /* now the enemies */
    s->salvo = g;
    s->type = IS_SALVO;
    s->lntype = LN_SALVO;
    s++;
  }
}

/*
 * The main routine for cbzone.  Probably more complicated than it
 * need be...but it takes care of all the interobject dependencies.
 * Therefore other routines work on a single object (in general).
 * placeobjects() will place however many objects it can, while
 * scanner() needs to know where all the enemies are.
 */
void main(argc, argv)
     int argc;
     char* argv[];
{
  Genericp o;
  Genericp pl, g, g2, s;
  char key;
  float alpha, ddx2, ddx, ddy2, ddy, dif, diff, dx, dy, v, dist;
  float blocksize = 100.0;
  float blocksizesqrd = 10000.0;
  float check, testx, testy;
  float landerthreshold = 0.5;
  float threshold = 0.7;
  int deadcount, i, icheck, position[2];
  int nummissile = 0;
  int missilecount = 0;
  int nextmissile = 1200;
  int numleft = 3;
  int score = 0;
  int scorebase = 0;
  Bool new_salvo_flag, new_sight_flag, event, tank_stranded;
  Bool aligned = False;
  Bool blocked_flag = False;
  Bool dead = False;
  Bool first = True;
  Bool firstmissile = True;
  Bool keylast = True;
  Bool lander = False;
  Bool missilerun = False;
  Bool salvo_flag = False;
  Bool sens = False;
  Bool sight_flag = False;
  extern long time();
  struct timeval tstart;
  struct timeval tend;
  long tdiff, limit;
#ifdef DEVELOPER
  int passes = 0;
  struct timeval game_start;
  struct timeval game_end;
#endif
  
  gprinqconfig(&argc, argv);


#ifdef DEBUG
debug_log("opt->mtanks =%d\n",opt->mtanks);
debug_log("opt->mmissiles =%d\n",opt->mmissiles);
debug_log("opt->mlanders =%d\n",opt->mlanders);
debug_log("opt->mblocks =%d\n",opt->mblocks);
debug_log("opt->delay =%d\n",opt->delay);
debug_log("opt->msalvos =%d\n",opt->msalvos);
debug_log("opt->menemies =%d\n",opt->menemies);
#endif


  limit = opt->delay * 1.2e4;

  /* now that we have parsed the options, we know how large to */
  /* make the world.  Use calloc here as most of the array     */
  /* should start off 0.                                       */

  pl = o = (Genericp) calloc(opt->mobjects,sizeof(Generic));

  if (o == NULL) {
    printf("Malloc failed...trying to create too many objects?\n");
#ifdef ATARI
    gem_close_down();
#endif
    exit(1);
  }
  initarray(o);                         /* prepare the main array */
#ifndef LATTICE
  srandom(time((long *) 0));            /* start things off randomly */
#else
  srand(time((long *) 0));            /* start things off randomly */
#endif
  screeninit();
  updatedisplay(missilerun, lander, score, numleft, sens, False);
  xhairs(aligned);
  gprinqcursor(position);
  event = gprcondeventwait(&key, position);
  joystick(position, sens, pl);
  /* place the objects out there to start the game.  if the player is */
  /* is_new, then the objects are placed at a random distance, else   */
  /* the objects get placed on the horizon.                           */

  placeobjects(o, missilerun, score);
  pl->attr &= ~IS_NEW;                  /* now the objects can be */
                                        /* placed at the horizon. */

  /* now calculate ranges to all the objects and translate them */
  /* into a player-centric coordinate system                    */

  pl->ca = cos(pl->azm);
  pl->sa = sin(pl->azm);
  for (g=o+opt->estart; g<o+opt->mobjects; g++)
    if (g->attr & IS_ALIVE) {
      dx = g->x - pl->x;
      dy = g->y - pl->y;
      g->range = sqrt(dx*dx + dy*dy);
      g->proy = -dx * pl->sa + dy * pl->ca;
      g->prox = dx * pl->ca + dy * pl->sa;
    }

  scanner(o);
  drawhorizon(pl->azm); 

  /* now the work really starts....we just iterate through */
  /* the following loop until the player dies or quits     */
#ifdef DEVELOPER
  gettimeofday(&game_start, 0);
#endif
  while (1) {
#ifdef ATARI
	update_front();
	clearscreen();
#endif
    gettimeofday(&tstart, 0);
    gprinqcursor(position);
    event = gprcondeventwait(&key, position);

    if (event && key == 'Q') {
#ifdef DEBUG
debug_log("quit event event\n");
#endif
      free(o);
#ifndef ATARI
      exit(scores(score));
#else
	set_front();
	scores(score);
	gem_close_down();
	exit();
#endif
    }

    if (event && key == 'R') {
#ifdef DEBUG
debug_log("redraw screen event\n");
#endif
      clearentirescreen();
      staticscreen();
      updatedisplay(False, False, -1, 0, False, True);
      updatedisplay(missilerun, lander, score, numleft, sens, False);
      if (sight_flag)
        message(1, False);
      if (pl->attr & IS_BLOCKED)
        message(2, False);
      if (salvo_flag)
        message(3, False);
      scanner(o);
      xhairs(aligned);
      drawhorizon(pl->azm); 
    }

    joystick(position, sens, pl);
#ifndef ATARI
    if (paused){
      continue;
    }
#endif    
    for (i=0; i<opt->msalvos; i++) {    /* now find a shot we can use */
      s = pl->salvo+i;
      if (!(s->attr & STILL_THERE))
        break;
      s = NULL;
    }

    if (event && pl->attr & IS_ALIVE)
      if (keylast) {
        for (i=0; i<opt->msalvos; i++) { /* now find a shot we can use */
          s = pl->salvo+i;
          if (!(s->attr & STILL_THERE)){
            break;
	  }
          s = NULL;
        }
        if (key == 'a' && s!=NULL) {    /* fire up one shot */
#ifdef DEBUG
debug_log("salvo fired\n");
#endif
#ifdef ATARI
		  sound(shot);
#endif
          s->attr = START_LIVING;
          s->ecount = 0;
          s->x = pl->x;
          s->y = pl->y;
          s->z = 0.0;
          s->prox = 0;
          s->proy = 0;
          s->azm = pl->azm;
          s->speed = 40.0;
          keylast = False;
        }
        else if (key == 'b') {          /* center our joystick */
          position[0] = 500;
          position[1] = 355;
          gprsetcursorposition(position);
          joystick(position, sens, pl);
          keylast = False;
        }
        else if (key == 'c') {          /* toggle sensitivity */
          sens = !sens;
          joystick(position, sens, pl);
          keylast = False;
        }
      }
      else if (key == 'A' || key == 'B' || key == 'C')
        keylast = True;                 /* button released */
  
    /* if we can move, update our rotation, bearing (azimuth), and */
    /* position.                                                   */
    if (pl->attr & IS_ALIVE && !(pl->attr & IS_BLOCKED)) {
      pl->azm += pl->rotate;
      if (pl->azm > PI2)
        pl->azm -= PI2;
      if (pl->azm <= 0.0)
        pl->azm += PI2;
      pl->ca = cos(pl->azm);
      pl->sa = sin(pl->azm);
    }
    if (pl->attr & IS_ALIVE) {
      pl->x -=  pl->sa * pl->speed;
      pl->y +=  pl->ca * pl->speed;
    }
    else
      pl->speed = 0.0;

    /* now call the move generation routines for the objects */
    /* which require thought,  speed and/or rotation may be  */
    /* affected.                                             */

    for (g=o+opt->estart; g<o+opt->sstart; g++){
      if (g->attr & IS_ALIVE)
        switch (g->type) {
        case IS_TANK:
          movetank(g, pl); break;
        case IS_SUPER:
          movesuper(g, pl); break;
        case IS_MISSILE:
          movemissile(g, pl, first); break;
        case IS_COPTER:
          movecopter(g, pl); break;
        case IS_LANDER:
          movelander(g, pl); break;
        default:
          printf("Help! Something's alive and I don't know what...\n");
#ifdef ATARI
          gem_close_down();
#endif
          exit(1);
        }
    }
    /* now update their bearing and position */

    for (g=o+opt->estart; g<o+opt->lstart; g++) {
      if (g->attr & IS_ALIVE && !(g->attr & IS_BLOCKED)) 
        g->azm += g->rotate;
      g->ca = cos(g->azm);
      g->sa = sin(g->azm);
      g->x -=  g->sa * g->speed;
      g->y +=  g->ca * g->speed;
    }
    for (g=o+opt->lstart; g<o+opt->bstart; g++)
      if (g->attr & IS_ALIVE) {
        g->ca = cos(g->azm);
        g->sa = sin(g->azm);
        g->x -= g->sa * g->speed;
        g->y += g->ca * g->speed;
      }

    /* now compute ranges from objects to the player */

    for (g=o+opt->estart; g<o+opt->mobjects; g++) 
      if (g->attr & STILL_THERE)
        g->range = sqrt(DIST(g, pl));

    for (g=o; g<o+opt->lstart; g++)     /* assume all objects are */
      g->attr &= ~IS_BLOCKED;           /* unblocked              */

    /* now check to see if they really were unblocked.  If not, then */
    /* project them back along their path until they are.  This      */
    /* section just checks for being blocked by blocks.              */

    for (g=o+opt->bstart; g<o+opt->mobjects; g++) {
      if (g->range < blocksize) {
        pl->attr |= BLOCKED_BY_BLOCK;
        dx = pl->x - g->x;
        dy = pl->y - g->y;
        diff = dy * pl->ca - dx * pl->sa;
        if (pl->speed > 0.0)
          v = diff + sqrt(diff*diff + blocksizesqrd - g->range*g->range);
        else if (pl->speed < 0.0) 
          v = diff - sqrt(diff*diff + blocksizesqrd - g->range*g->range);
        pl->x += pl->sa * v;
        pl->y -= pl->ca * v;
      }
      for (g2=o+opt->estart; g2<o+opt->lstart; g2++)
        if (g2->attr & IS_ALIVE &&
            (dist = DIST(g, g2)) < blocksizesqrd) {
          g2->attr |= BLOCKED_BY_BLOCK;
          if (!(g2->type & (IS_MISSILE | IS_COPTER))) {
            dx = g2->x - g->x;
            dy = g2->y - g->y;
            diff = dy * g2->ca - dx * g2->sa;
            if (g2->speed > 0.0) 
              v = diff + sqrt(diff*diff + blocksizesqrd - dist);
            else if (g2->speed < 0.0) 
              v = diff - sqrt(diff*diff + blocksizesqrd - dist);
            g2->x += g2->sa * v;
            g2->y -= g2->ca * v;
          }
        }
    }

    /* if the player moved, or if an enemy did, we need to recompute */
    /* the range to that enemy.                                      */

    for (g=o+opt->estart; g<o+opt->lstart; g++)
      if (g->attr & IS_ALIVE &&
          (g->attr & IS_BLOCKED || pl->attr & IS_BLOCKED))
        g->range = sqrt(DIST(g, pl));

    /* now check to see if the player is blocked by any enemy.  */
    /* if so, project them back.                                */

    for (g=o+opt->estart; g<o+opt->lstart; g++) 
      if (g->attr & IS_ALIVE && g->range < blocksize)
        if (!(g->type & (IS_MISSILE | IS_COPTER))) {
          if (g->attr & IS_BLOCKED) {
            pl->speed = 0.0;
            if (fabs(g->speed) < 0.001)
              g->speed = sign(0.001, g->speed);
          }
          pl->attr |= BLOCKED_BY_ENEMY;
          g->attr |= BLOCKED_BY_ENEMY;
          ddx = pl->speed * pl->sa - g->speed * g->sa;
          ddy = pl->speed * pl->ca - g->speed * g->ca;
          ddx2 = ddx*ddx;
          ddy2 = ddy*ddy;
          dx = pl->x - g->x;
          dy = pl->y - g->y;
          dif = ddy * dy - ddx * dx;
          alpha = (dif + sqrt(dif*dif + (blocksizesqrd - g->range*g->range)
                              * (ddx2 + ddy2))) / (ddx2 + ddy2);
          pl->x += alpha * pl->speed * pl->sa;
          pl->y -= alpha * pl->speed * pl->ca;
          g->x += alpha * g->speed * g->sa;
          g->y -= alpha * g->speed * g->ca;
        }

    /* if we've moved, recompute distance to all the salvos */

    if (pl->attr & IS_BLOCKED)
      for (g=o+opt->sstart; g<o+opt->bstart; g++)
        if (g->attr & IS_ALIVE)
          g->range = sqrt(DIST(g, pl));

    /* enemies disappear if their range is greater than 2200. */
    /* We check last[0] to see if they need to be erased.  In */
    /* most cases probably not, unless we really screw with   */
    /* their speed.                                           */

    tank_stranded = False;
    for (g=o+opt->estart; g<o+opt->lstart; g++) {
      g->ecount++;
      if (g->attr & IS_ALIVE)
        if (g->range > 2200.0) 
          if (g->dc[0].last)
            g->attr = ERASE;
          else
            g->attr = 0;
        else if (g->type & (IS_SUPER | IS_TANK) &&
                 g->ecount > TANK_STRAND_COUNT)
          tank_stranded = True;
    }

    /* landers are out of range at 2750 */


    for (g=o+opt->lstart; g<o+opt->sstart; g++) {
      g->ecount++;
      if (g->attr & IS_ALIVE && g->range > 2750.0)
        if (g->dc[0].last)
          g->attr = ERASE;
        else
          g->attr = 0;
    }

    /* blocks also at 2200 */

    for (g=o+opt->bstart; g<o+opt->mobjects; g++)
      if (g->range > 2200.0)
        if (g->dc[0].last)
          g->attr = ERASE;
        else
          g->attr = 0;

    /* salvos are never out of range, but their lifetime is limited */
    
    for (g=o+opt->sstart; g<o+opt->bstart; g++) {
      g->ecount++;
      if (g->attr & IS_ALIVE && g->ecount > 50)
        if (g->dc[0].last)
          g->attr = ERASE;
        else
          g->attr = 0;
    }

    /* we never set the 'salvo fired' message in this routine.  */
    /* however, we do have to turn it off.  if salvos are alive */
    /* we assume the message is on, once no enemy salvos are    */
    /* alive we turn it off.                                    */
    
    new_salvo_flag = False;
    for (g=o+opt->sstart; g<o+opt->bstart; g++) 
      if (g->attr & IS_ALIVE) {         /* if salvo exist and   */
        if (g->salvo != pl)             /* not owned by player  */
          new_salvo_flag = True;        /* then the flag is set */
        
        /* check to see if a salvo hits a block */

        for (g2=o+opt->bstart; g2<o+opt->mobjects; g2++)
          if (fabs(g2->x - g->x) < g2->criticalx &&
              fabs(g2->y - g->y) < g2->criticaly) {
            g->attr = START_EXPLODING;
            g->ecount = 0;
          }
        
        /* now check to see if the salvo kills a lander. */
        /* If so, and the player fired the salvo, update */
        /* the score.                                    */
        
        for (g2=o+opt->lstart; g2<o+opt->sstart; g2++)
          if (g2->attr & IS_ALIVE)
            if (DIST(g, g2) < g2->criticalx) {
              g->attr = START_EXPLODING;
              g2->attr = START_EXPLODING;
              g->ecount = 0;
              g2->ecount = 0;
              if (g->salvo == pl) {
                score += 10000;
                icheck = score / 100000;
                if (icheck > scorebase) {
                  numleft++;
                  if (numleft > 4)
                    numleft = 4;
                  scorebase = icheck;
                }
              }
            }

        /* now check to see if the salvo hit any enemy.   The salvo */
        /* cannot hit the one who fired it.  This prevents range    */
        /* checking problems when first fired.                      */
        
        for (g2=o+opt->estart; g2<o+opt->lstart; g2++)
          if (g2->attr & IS_ALIVE && g->salvo != g2) {
            dx = g->x - g2->x;
            dy = g->y - g2->y;
            testx = fabs( dx * g2->ca + dy * g2->sa);
            testy = fabs(-dx * g2->sa + dy * g2->ca);
            if (testx < g2->criticalx && testy < g2->criticaly &&
                (!(g2->type & (IS_MISSILE | IS_COPTER)) || g2->z < 80.0)) {
              g->attr = START_EXPLODING;
              g2->attr = START_EXPLODING;
#ifdef ATARI
			  if (g2->type != IS_LANDER){
				sound(explode);
			  }
#endif
              g->ecount = 0;
              g2->ecount = 0;

              /* if the player fired, give him credit */
              
              if (g->salvo == pl) {
                if (g2->type & IS_SUPER) 
                  score += 5000;
                else if (g2->type & (IS_MISSILE | IS_COPTER)) {
                  score += 5000;
                  nummissile--;
                }
                else
                  score += 3000;
                icheck = score / 100000;
                if (icheck > scorebase) {
                  numleft++;
                  if (numleft > 4)
                    numleft = 4;
                  scorebase = icheck;
                }
              }
            }
          }
      }

    /* check to see if a missile or copter rams a lander */

    for (g=o+opt->estart; g<o+opt->lstart; g++)
      if (g->type & (IS_MISSILE | IS_COPTER) && g->attr & IS_ALIVE)
        for (g2=o+opt->lstart; g2<o+opt->sstart; g2++)
          if (g2->attr & IS_ALIVE &&
              DIST(g, g2) < g2->criticalx && g->z < 80) {
            nummissile--;
            g->attr = START_EXPLODING;
            g2->attr = START_EXPLODING;
#ifdef ATARI
			sound(explode);
#endif
            g->ecount = 0;
            g2->ecount = 0;
          }
    
    /* now check if we need to draw the object.  */
    /* convert into player-centric coordinates   */
    /* and project a cone forward to see if the  */
    /* enemy is within it. Also align the gun    */
    /* gun sights if necessary.                  */

    new_sight_flag = False;
    aligned = False;
    lander = False;
    for (g=o+opt->estart; g<o+opt->mobjects; g++) 
      if (g->attr & (IS_ALIVE|IS_EXPLODING)) {
        g->dc[0].seen = False;
        if (g->range < 2000.0) {
          dx = g->x - pl->x;
          dy = g->y - pl->y;
          g->proy = -dx * pl->sa + dy * pl->ca;
          g->prox =  dx * pl->ca + dy * pl->sa;
          check = g->proy / (fabs(g->prox) + 1.0);
          if (check > threshold) {
            g->dc[0].seen = True;
            if (g->type & IS_ENEMY && g->attr & IS_ALIVE)
              new_sight_flag = True;
            if (fabs(g->prox) < 50 && g->attr & IS_ALIVE &&
                !(g->type & (IS_ABLOCK | IS_SALVO)))
              aligned = True;
          }
          if (g->type & IS_LANDER && g->attr & IS_ALIVE
              && check > landerthreshold) {
            lander = True;
            if (fabs(g->prox) < 60)
              aligned = True;
          }
        }
      }
    
    /* change the various messages, if necessary.  Never use */
    /* the bell, unless opt->loud is True.                   */
    
    if (sight_flag && !new_sight_flag) {
      message(-1, False);
      sight_flag = False;
    }
    else if (!sight_flag && new_sight_flag) {
      message(1, False);
      sight_flag = True;
    }
    if (pl->attr & IS_BLOCKED && !blocked_flag) {
      message(2, True);
      blocked_flag = True;
    }
    else if (!(pl->attr & IS_BLOCKED) && blocked_flag) {
      message(-2, False);
      blocked_flag = False;
    }
    if (salvo_flag && !new_salvo_flag) {
      message(-3, False);
      salvo_flag = False;
    }
    else if (!salvo_flag && new_salvo_flag)
      salvo_flag = True;
    
    scanner(o);
    updatedisplay(missilerun, lander, score, numleft, sens, False);
    xhairs(aligned);
    drawhorizon(pl->azm); 

    /* now draw all the objects */

    for (g=o+opt->estart; g<o+opt->mobjects; g++) {
      if (g->attr & (IS_ALIVE | ERASE)){
        drawobject(g, pl);
      }else if (g->attr & (IS_EXPLODING | EXERASE))
        switch (g->type) {
        case IS_SALVO:
          explodesalvo(g, pl); break;
        case IS_COPTER:
        case IS_MISSILE:
        case IS_LANDER:
        case IS_TANK:
        case IS_SUPER:{
          explodeobject(g, pl);
	  break;
	}
        default:
          printf("Help! Cannot explode what doesn't exist.\n");
#ifdef ATARI
          gem_close_down();
#endif
          exit(1);
        }
      g->attr &= ~(ERASE | EXERASE);
    }

    /* now start checking for player death.  if there is a missile, */
    /* check to see if it rammed the player.                        */
    
    if (missilerun)
      for (g=o+opt->estart; g<o+opt->lstart; g++)
        if (g->attr & IS_ALIVE && g->type & (IS_MISSILE | IS_COPTER) && 
            g->range < blocksize && g->z < 80) {
          g->attr = START_EXPLODING;
          drawcracks();
          pl->attr &= ~IS_ALIVE;
          dead = True;
#ifdef ATARI
		  sound(explode2);
#endif
          deadcount = 0;
        }

    /* check to see if any salvos hit. */

    for (g=o+opt->sstart; g<o+opt->bstart; g++)
      if (g->attr & IS_ALIVE && g->salvo != pl &&
          g->range < 100.0 && fabs(g->prox) < pl->criticalx &&
          fabs(g->proy) < pl->criticaly) {
        drawobject(g, pl);
        g->attr = 0;
        drawcracks();
        pl->attr &= ~IS_ALIVE;
        dead = True;
#ifdef ATARI
		sound(explode2);
#endif
        deadcount = 0;
      }

    /* if we are dead, redraw the cracks every five turns.  after 50 */
    /* turns, we can start playing again if we have any lives left.  */
    
    if (dead) {
#ifndef ATARI			/* one of the 'downs' of screen buffering */
      if (deadcount%5 == 0){

      }
#else
        drawcracks();
#endif
      if (deadcount > 50) {
        dead = False;
        numleft--;
        if (numleft < 0) {
#ifdef DEVELOPER
          gettimeofday(&game_end, 0);
#ifndef ATARI
            printf("The game took an average %10.8f secs.\n",
                   (game_end.tv_sec-game_start.tv_sec +
                    (game_end.tv_usec-game_start.tv_usec)*1.0e-6)/passes);
#else
            debug_log("The game took an average %10.8f secs.\n",
                   (game_end.tv_sec-game_start.tv_sec +
                    (game_end.tv_usec-game_start.tv_usec)*1.0e-6)/passes);
#endif
#endif
          free(o);
#ifndef ATARI
          exit(scores(score));
#else
	  set_front();
	  scores(score);
	  gem_close_down();
	  exit();
#endif
        }
        if (missilerun) {
          nummissile -= 2;
          if (nummissile <= 0 && opt->mtanks) {
            missilerun = False;
            nextmissile = 750 * frand() + 750;
          }
        }
        clearscreen();
        pl->x = 0.0;                    /* reset all our attributes */
        pl->y = 0.0;
        pl->speed = 0.0;
        pl->azm = 0.0;
        pl->ca = 1.0;
        pl->sa = 0.0;
        pl->attr = START_LIVING;
        message(-1, False);             /* turn off all the messages */
        sight_flag = False;
        message(-2, False);
        blocked_flag = False;
        message(-3, False);
        salvo_flag = False;
        for (g=o+opt->estart; g<o+opt->mobjects; g++) 
          g->attr = 0;                  /* remove all objects */
      }
    }

    /* Now schedule the missile runs.  There will be a missile run if */
    /* mtanks==0 or we are in copter practice or if a tank has been   */
    /* around too long or we haven't had a missile in a while.        */

    if (pl->attr & IS_ALIVE && opt->mmissiles &&
        (!opt->mtanks || opt->copters ||
         tank_stranded || missilecount > nextmissile))
      if (!missilerun) {
        missilecount = 0;
        for (g=o+opt->estart; g<o+opt->bstart; g++)
          if (!(g->type & (IS_LANDER | IS_MISSILE | IS_COPTER)))
            if (g->attr & IS_ALIVE)
              g->attr = ERASE;
            else if (g->attr & IS_EXPLODING)
              g->attr = EXERASE;
        nummissile = frand() * 3 * opt->mmissiles + 1;
        if (firstmissile)
          nummissile = 1;
        first = firstmissile;
        firstmissile = False;
        missilerun = True;
      }

    /* once this run is over, schedule another one for a later date */

    if (missilerun && opt->mtanks && nummissile <= 0) {
      missilerun = False;
      nextmissile = 750 * frand() + 750;
    }

    /* now place whatever objects need to be placed.  */

    if (!dead)
      placeobjects(o, missilerun, score);
    pl->attr &= ~IS_NEW;                /* in case the player was new */

    deadcount++;
    if (!missilerun) missilecount++;

/* use timeclock here instead of gettimeofday to get a sync(d, 0)
 * just in case there are graphics we need to draw.
 */
    timeclock(&tend); 
    tdiff = limit -
      ((tend.tv_sec-tstart.tv_sec)*1e6+tend.tv_usec-tstart.tv_usec);
    if (tdiff > 0) {
      tend.tv_sec = 0;
      tend.tv_usec = tdiff;
#ifndef LATTICE
      select(0, 0, 0, 0, &tend);
#else
      delay(ldiv(tend.tv_usec,1000));
#endif
    }
#ifdef DEVELOPER
    passes++;
#endif
  }
}
