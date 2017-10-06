/* field.c */

/*********************************************/
/* you just keep on pushing my luck over the */
/*           BOULDER        DASH             */
/*                                           */
/*     Jeroen Houttuin, ETH Zurich, 1990     */
/*********************************************/

#include "header.h"
#include "bldrdash.h"

void
blink(i, j)
  int             i, j;
{
  field[i][j].changed = True;
}

void
move_cell(i, j, ii, jj)
  int             i, j, ii, jj;
{
  field[ii][jj] = field[i][j];
  field[ii][jj].speed = 1;
  field[ii][jj].changed = True;
  field[ii][jj].dir = ((ii - i) == 1) ? S : ((i - ii) == 1) ? N : ((jj - j) == 1) ? E : W;
  set_cell(i, j, SPACE);
}

void
explode(a, b, stage)
  int             a, b, stage;
{
  if (field[a][b].content != STEEL)
  {
    set_cell(a, b, EXPLOSION);
    field[a][b].stage = stage;	/* dirty fix, not what stage was meant for */
  }
}

Bool
move_nucbal(i, j, t)
  int             i, j, t;
{
  ii = (!t) ? (i + y - 1) % y : i;
  if (!t)
    jj = j;
  else
    switch (field[i][j].dir)
    {
    case E:
      jj = (t == 1) ? (j + x - 1) % x : (j + 1) % x;
      break;
    case W:
    default:
      jj = (t == 2) ? (j + x - 1) % x : (j + 1) % x;
      break;
    }
  switch (field[ii][jj].content)
  {
  case SPACE:
    move_cell(i, j, ii, jj);
    return (True);
  case NUCBAL:
    explode(i, j, DIAEXPLO);
    explode(ii, jj, DIAEXPLO);
    return (True);
  default:
    if (field[i][j].dir == N)
      field[i][j].dir = E;
    else
      field[i][j].dir = ((field[i][j].dir + 2) % 4);	/* turn around */
    return (False);
  }
}

Bool
move_monster(content, direction)
  char            content, direction;
{
  switch (direction)
  {
  case N:
    ii = (i + y - 1) % y;
    jj = j;
    break;
  case E:
    jj = (j + 1) % x;
    ii = i;
    break;
  case S:
    ii = (i + 1) % y;
    jj = j;
    break;
  default:
    jj = (j + x - 1) % x;
    ii = i;
    break;			/* default must be SOMEthing, West */
  }
  switch (field[ii][jj].content)
  {
  case SPACE:
    if (!field[ii][jj].changed)
    {
      move_cell(i, j, ii, jj);
      field[ii][jj].dir = direction;
      return (True);
    } else
      return (False);
  case BOULDER:
  case DIAMOND:
    if ((direction == N) && (field[ii][jj].speed != 0))
      if (content == RMONSTER)
      {
	explode(i, j, DIAEXPLO);
	return (True);
      } else if (content == LMONSTER)
      {
	explode(i, j, SPACEEXPLO);
	return (True);
      } else
	return (False);
    else
      return (False);
  default:
    return (False);
  }
}

Bool
search_destroy(content)
  char            content;
{
  ii = (i + y - 1) % y;
  jj = (j + x - 1) % x;
  if (field[i][jj].content == PLAYER || field[i][jj].content == BLOB)
  {
    set_cell(i, j, SPACE);
    if (field[i][jj].content == PLAYER)
    {
      lives--;
      scoreobs = True;
    }
    if (content == RMONSTER)
      explode(i, jj, DIAEXPLO);
    else
      explode(i, jj, SPACEEXPLO);
    return (True);
  } else if (field[ii][j].content == PLAYER || field[ii][j].content == BLOB)
  {
    set_cell(i, j, SPACE);
    if (field[ii][j].content == PLAYER)
    {
      lives--;
      scoreobs = True;
    }
    if (content == RMONSTER)
      explode(ii, j, DIAEXPLO);
    else
      explode(ii, j, SPACEEXPLO);
    return (True);
  } else
  {
    ii = (i + 1) % y;
    jj = (j + 1) % x;
    if (field[i][jj].content == PLAYER || field[i][jj].content == BLOB)
    {
      set_cell(i, j, SPACE);
      if (field[i][jj].content == PLAYER)
      {
	lives--;
	scoreobs = True;
      }
      if (content == RMONSTER)
	explode(i, jj, DIAEXPLO);
      else
	explode(i, jj, SPACEEXPLO);
      return (True);
    } else if (field[ii][j].content == PLAYER || field[ii][j].content == BLOB)
    {
      set_cell(i, j, SPACE);
      if (field[ii][j].content == PLAYER)
      {
	lives--;
	scoreobs = True;
      }
      if (content == RMONSTER)
	explode(ii, j, DIAEXPLO);
      else
	explode(ii, j, SPACEEXPLO);
      return (True);
    } else
      return (False);
  }
}

void
propagate(i, j, dias)
  int             i, j;
  Bool            dias;
{
  int             t, it, jt;
  if (dias)
    set_cell(i, j, DIAMOND);
  else
  {
    field[i][j].checked = PROPAGATED;
    field[i][j].caught = True;
  }
  for (t = 0; (t < 4); ++t)
  {
    it = (t == 1) ? (i + y - 1) % y : (t == 3) ? (i + 1) % y : i;	/* neigbour
									 * right,up,left,down */
    jt = (t == 2) ? (j + x - 1) % x : (t == 0) ? (j + 1) % x : j;	/* neigbour
									 * right,up,left,down */
    switch (field[it][jt].content)
    {
    case BLOB:
      if (field[it][jt].checked != PROPAGATED)
	propagate(it, jt, dias);
      break;
    case SPACE:
    case GRASS:
      if (!(randint() % (blobbreak + 1)))
      {
	set_cell(it, jt, BLOB);
	field[it][jt].checked = PROPAGATED;
	field[it][jt].caught = True;
      }
      break;
    default:
      break;
    }
  }
}

Bool
caught(i, j)
  int             i, j;
{
  Bool            Free;
  int             t, it, jt;

  field[i][j].checked = 1;
  Free = False;

  for (t = 0; ((t < 4) && !Free); ++t)
  {
    it = (t == 1) ? (i + y - 1) % y : (t == 3) ? (i + 1) % y : i;	/* neigbour
									 * right,up,left,down */
    jt = (t == 2) ? (j + x - 1) % x : (t == 0) ? (j + 1) % x : j;	/* neigbour
									 * right,up,left,down */

    switch (field[it][jt].content)
    {
    case SPACE:
    case GRASS:
    case RMONSTER:
    case LMONSTER:
    case EATER:
      Free = True;
      break;
    case BLOB:
      Free = (Free || ((field[it][jt].checked == 1) ? !field[i][j].caught
		       : !caught(it, jt)
		       )
	);
      break;
    default:
      break;
    }
  }
  field[i][j].caught = Free;
  return (!Free);
}

void
diaboulderproc(i, j)
  int             i, j;
{
  if (field[i][j].content == DIAMOND)
    blink(i, j);
  ii = (ii + 1) % y;
  field[i][j].dir = NODIR;
  switch (field[ii][j].content)
  {
  case SPACE:			/* directly underneath */
    move_cell(i, j, ii, j);
    field[ii][j].speed = 1;
    break;
  case PLAYER:
    if (field[i][j].speed)
    {
      set_cell(i, j, SPACE);
      explode(ii, j, SPACEEXPLO);
      lives--;
      scoreobs = True;
    }
    break;
  case LMONSTER:
  case EATER:
    if (field[i][j].speed)
    {
      set_cell(i, j, SPACE);
      explode(ii, j, SPACEEXPLO);
    }
    break;
  case RMONSTER:
    if (field[i][j].speed)
    {
      set_cell(i, j, SPACE);
      explode(ii, j, DIAEXPLO);
    }
    break;
  case TINKLE:
    if (field[i][j].speed)
    {
      tinkact = True;
      field[ii][j].stage = field[i][j].content;
      field[ii][j].speed = 1;
      set_cell(i, j, SPACE);
      break;
    }
    break;
  case WALL:
  case BOULDER:
  case DIAMOND:
  case EXPLOSION:
    jj = (j + 1) % x;
    if (field[i][jj].content == SPACE && field[ii][jj].content == SPACE)
    {
      move_cell(i, j, i, jj);
      field[i][jj].speed = 0;
    } else
    {
      jj = (j - 1) % x;
      if (field[i][jj].content == SPACE
	  && field[ii][jj].content == SPACE)
      {
	move_cell(i, j, i, jj);
	field[i][jj].speed = 0;
      } else
	field[i][j].speed = 0;
    }
    break;
  default:
    field[i][j].speed = 0;
    break;
  }
}


void
calculate_field()
{
  players = 0;
  /* Iterate through each horizontal line */
  if (!time__)
    curorder = KILL;
  for (i = y - 1; i >= 0; --i)
  {
    for (j = 0; j < x; ++j)
    {
      if (!(field[i][j].changed))
      {
	ii = i;
	jj = j;
	switch (field[i][j].content)
	{
	case PLAYER:
	  players++;
	  switch (curorder)	/* find cell player wants to go to */
	  {
	  case STAND:
	    break;
	  case UP:
	    ii = (i + y - 1) % y;
	    break;
	  case DOWN:
	    ii = (i + 1) % y;
	    break;
	  case LEFT:
	    jj = (j + x - 1) % x;
	    break;
	  case RIGHT:
	    jj = (j + 1) % x;
	    break;
	  }
	  if (!(curorder == STAND) && !(field[i][j].changed))
	  {
	    if (curorder == KILL)
	    {
	      set_cell(i, j, EXPLOSION);
	      lives--;
	      scoreobs = True;
	      break;
	    }
	    switch (field[ii][jj].content)	/* check cell player wants to
						 * go to */
	    {
	    case SPACE:
	    case GRASS:
	    case DIAMOND:
	      if (field[ii][jj].content == DIAMOND)
	      {
		if (curorder == UP && field[ii][jj].speed)
		  break;
		score += diapoints;
		if (diareq)
		  diareq--;
		scoreobs = True;
	      }
	      if (steal)
		set_cell(ii, jj, SPACE);
	      else
		move_cell(i, j, ii, jj);		
	      break;
	    case BOULDER:
	      jjj = (2 * jj - j + x) % x;	/* the cell behind the
						 * boulder */
	      if (field[i][jjj].content == SPACE && 
		  !(field[ii][jj].dir == E))
	      {
		move_cell(i, jj, i, jjj);
		field[i][jjj].speed = 0;
		if (!steal)
		  move_cell(i, j, i, jj);
	      }
	      break;
	    case EXIT:
	      if (diareq < 1)
	      {
		if (!steal)
		  move_cell(i, j, ii, jj);
		else
		  set_cell(ii, jj, SPACE);
		if (!levincreased)
		{
		  levelnum++;
		  save_hall();
		  lives++;
		  levincreased = True;
		  for (jj = time__ / 10; jj > 0; --jj)
		  {
		    score += 10;
		  }
		}
		gamestop = False;
		stoplevel = True;
	      }
	      break;
	    }
	  }
	  blink(i, j);
	  break;
	case DIAMOND:
	case BOULDER:
	  diaboulderproc(i, j);
	  break;
	case EATER:
	  if (!field[i][j].speed)
	  {
	    for (jjj = 0; ((!field[i][j].changed) && (jjj < 4)); ++jjj)
	    {
	      ii = (jjj == 2) ? (i + 1) % y : (jjj == 0) ? (i + y - 1) % y : i;
	      jj = (jjj == 1) ? (j + 1) % x : (jjj == 3) ? (j + x - 1) % x : j;
	      switch (field[ii][jj].content)
	      {
	      case PLAYER:
		lives--;
		scoreobs = True;
	      case DIAMOND:
		if (field[ii][jj].speed && (ii == i - 1) && (jj == j))
		  break;
	      case BLOB:
	      case LMONSTER:
	      case RMONSTER:
	      case NUCBAL:
		move_cell(i, j, ii, jj);
		break;
	      default:
		break;
	      }
	    }
	  } else
	  {
	    jjj = field[i][j].dir;
	    ii = (jjj == 2) ? (i + 1) % y : (jjj == 0) ? (i + y - 1) % y : i;
	    jj = (jjj == 1) ? (j + 1) % x : (jjj == 3) ? (j + x - 1) % x : j;
	    switch (field[ii][jj].content)
	    {
	    case LMONSTER:
	    case BLOB:
	    case SPACE:
	    case GRASS:
	    case DIAMOND:
	    case RMONSTER:
	    case PLAYER:
	    case NUCBAL:
	      if (field[ii][jj].content == PLAYER)
	      {
		lives--;
		scoreobs = True;
	      }
	      move_cell(i, j, ii, jj);
	      break;
	    case BOULDER:
	      jjj = (2 * jj - j + x) % x;	/* the cell behind the
						 * boulder */
	      if (field[i][jjj].content == SPACE && !(field[ii][jj].dir == E))
	      {
		move_cell(i, jj, i, jjj);
		move_cell(i, j, i, jj);
	      } else
		field[i][j].speed = 0;
	      break;
	    default:
	      field[i][j].speed = 0;
	      break;
	    }
	  }
	  blink(i, j);
	  break;
	case RMONSTER:
	  blink(i, j);
	  if (search_destroy(RMONSTER))
	    break;
	  jjj = 3;
	  while (jjj >= 0 && !move_monster(RMONSTER, (field[i][j].dir + jjj + 2) % 4))
	    jjj--;
	  break;
	case LMONSTER:
	  blink(i, j);
	  if (search_destroy(LMONSTER))
	    break;
	  jjj = 0;
	  while (jjj <= 4 && !move_monster(LMONSTER, (field[i][j].dir + jjj + 3) % 4))
	    jjj++;
	  break;
	case EXPLOSION:
	  jjj = field[i][j].stage;
	  if (!(jjj % 5))	/* this is the initiating explosion */
	  {
	    jjj++;		/* use jjj for setting new stage */
	    ii = (i + 1) % y;
	    jj = (j + 1) % x;
	    explode(i, j, jjj);
	    explode(i, jj, jjj);
	    explode(ii, j, jjj);
	    explode(ii, jj, jjj);
	    ii = (i + y - 1) % y;
	    explode(ii, j, jjj);
	    explode(ii, jj, jjj);
	    jj = (j + x - 1) % x;
	    explode(ii, jj, jjj);
	    explode(i, jj, jjj);
	    ii = (i + 1) % y;
	    explode(ii, jj, jjj);
	  } else
	  {
	    if (jjj % 10 < 3)
	      field[i][j].stage++;
	    else if (jjj > DIAEXPLO)
	    {
	      set_cell(i, j, DIAMOND);
	    } else if (jjj > BOULDEXPLO)
	    {
	      set_cell(i, j, BOULDER);
	    } else if (jjj > SPACEEXPLO)
	    {
	      set_cell(i, j, SPACE);
	    } else
	      field[i][j].stage++;
	  }
	  break;
	case EXIT:
	  blink(i, j);
	  break;
	case BLOB:
	  blobcells++;
	  if (blobcollapse)
	    set_cell(i, j, BOULDER);
	  else
	  {
	    if (blobcells > critical)
	      blobcollapse = True;
	    else
	    {
	      if (!field[i][j].checked)
	      {
		if (caught(i, j))
		  propagate(i, j, DIAMOND);
		else
		  propagate(i, j, False);
	      }
	      field[i][j].checked = False;
	      field[i][j].caught = True;
	    }
	  }
	  blink(i, j);
	  break;
	case NUCBAL:
	  for (jjj = 0; ((jjj < 3) && !move_nucbal(i, j, jjj)); ++jjj);
	  blink(i, j);
	  break;
	case MAGICWALL:
	  jj = (j + x - 1) % x;
	  if (field[i][jj].content == SPACE)
	    set_cell(i, jj, MAGICWALL);
	  jj = (j + 1) % x;
	  if (field[i][jj].content == SPACE)
	    set_cell(i, jj, MAGICWALL);
	  break;
	case TINKLE:
	  if (tinkact)
	  {
	    blink(i, j);
	    if (tinkdur > 0)
	    {
	      switch (field[i][j].stage)
	      {
	      case BOULDER:
		{
		  field[i][j].content = DIAMOND;
		  diaboulderproc(i, j);
		  break;
		}
	      case DIAMOND:
		{
		  field[i][j].content = BOULDER;
		  diaboulderproc(i, j);
		  break;
		}
	      default:
		break;
	      }
	    }
	  }
	  set_cell(i, j, TINKLE);	/* reset to empty tinkle wall */
	  break;
	default:
	  break;
	}
      }
    }
  }
  curorder = STAND;		/* reset orders */
  blobcells = 0;
  pgc = (pgc == pgc1) ? ((randint() % 2) == 0) ? pgc2 : pgc1 :
    pgc1;
  dgc = (dgc == dgc1) ? dgc2 : dgc1;
  lgc = (lgc == lgc1) ? lgc2 : lgc1;
  rgc = (rgc == rgc1) ? rgc2 : rgc1;
  egc = (egc == egc1) ? egc2 : egc1;
  BBgc = (BBgc == BBgc1) ? BBgc2 : BBgc1;
  if (tinkact)
    tgc = (tgc == tgc1) ? tgc2 : tgc1;
  if (!diareq)
  {
    EEgc = (EEgc == EEgc1) ? EEgc2 : EEgc1;
    if (diareq == 0)
    {
      diapoints = extradiapoints;
      scoreobs = True;
    }
  }
}
