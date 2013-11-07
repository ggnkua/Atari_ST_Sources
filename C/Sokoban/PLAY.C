#include <stdio.h>
#include <ctype.h>
#include <curses.h>
#include "sokoban.h"

/* defining the types of move */
#define MOVE           1
#define PUSH           2
#define SAVE           3
#define UNSAVE                 4
#define STOREMOVE      5
#define STOREPUSH      6

/* defines for control characters */
#define CNTL_L         '\014'
#define CNTL_K         '\013'
#define CNTL_H         '\010'
#define CNTL_J         '\012'
#define CNTL_R         '\022'
#define CNTL_U         '\025'

extern char map[MAXROW+1][MAXCOL+1];
extern short rows, cols, level, moves, pushes, savepack, packets;
extern short scorelevel, scoremoves, scorepushes;
extern POS ppos;

POS tpos1, tpos2;      /* test positions: 1/2 pos. over/under/left/right */
#if 0
POS    lastppos,          /* the last player position (for undo) */
    lasttpos1, lasttpos2; /* last test positions (for undo) */
char lppc, ltp1c, ltp2c;  /* the char for these positions (for undo) */
short lastaction;
#endif
short action;

soko_state state[2000];		/* All the moves user has made */
int state_num = 0;			/* Last (+1) action in state */

int tmp_statenum;			/* State number of temporary save */
char tmp_map[MAXROW+1][MAXCOL+1];
short tmp_pushes, tmp_moves, tmp_savepack;
POS tmp_ppos;

#if ATARIST
char shifted[128], unshifted[128];
#endif

int play() {

   short c;
   short ret;
   short testmove();
   short undolock = 1;         /* locked for undo */

#if ATARIST			/* Mess up keyboard to make cursor keys work */
KEY_TABLES *kbt;
KEY_TABLES old_kbt;
int i;

	kbt = Keytbl(-1, -1, -1);
	old_kbt = *kbt;

	for (i = 0; i < 128; i++) {
		unshifted[i] = kbt->unshifted[i];
		shifted[i] = kbt->shifted[i];
	}

	unshifted[0x48] = 'k';	/* Up */
	unshifted[0x50] = 'j';	/* Down */
	unshifted[0x4b] = 'h';	/* Left */
	unshifted[0x4d] = 'l';	/* Right */
	unshifted[0x61] = 'u';	/* Undo */
	unshifted[0x62] = '?';	/* Help */

	shifted[0x48] = '\013';	/* Up ^K */
	shifted[0x50] = '\012';	/* Down ^J */
	shifted[0x4b] = '\010';	/* Left ^H */
	shifted[0x4d] = '\014';	/* Right ^L */
	shifted[0x61] = 'q';	/* Undo */

	Keytbl(unshifted, shifted, -1);
#endif

   showscreen();
   tmpsave();
   ret = 0;
   while( ret == 0) {
      switch( (c = get_char())) {
        case 'q':    /* quit the game                                  */
				ret = E_ENDGAME;
				break;
        case 's':    /* save the games                                 */
                     if( (ret = savegame()) == 0)
                        ret = E_SAVED;
                     break;
        case '?':    /* show the help file                             */
                     showhelp();
                     showscreen();
                     break;
        case CNTL_R: /* refresh the screen                             */
                     clear();
                     showscreen();
                     break;
        case 'c':    /* temporary save                                 */
                     tmpsave();
                     break;
        case CNTL_U: /* reset to temporary save                        */
                     tmpreset();
                     undolock = 1;
                     showscreen();
                     break;
        case 'U':    /* undo this level                                */
                     moves = pushes = 0;
                     if( (ret = readscreen()) == 0) {
                        showscreen();
                        undolock = 1;
                     }
                     break;
        case 'u':    /* undo last move                                 */
                     if(state_num > 0) {
                        undomove();
                        undolock = 0;	/*1*/
                     }
                     break;
        case 'k':    /* up                                             */
        case 'K':    /* run up                                         */
        case CNTL_K: /* run up, stop before object                     */
        case 'j':    /* down                                           */
        case 'J':    /* run down                                       */
        case CNTL_J: /* run down, stop before object                   */
        case 'l':    /* right                                          */
        case 'L':    /* run right                                      */
        case CNTL_L: /* run right, stop before object                  */
        case 'h':    /* left                                           */
        case 'H':    /* run left                                       */
        case CNTL_H: /* run left, stop before object                   */
                     do {
                        if( (action = testmove( c)) != 0) {
						soko_state *s;
							s = &state[state_num];

                        	s->action = action;
							s->ppos = ppos;
                        	s->lppc = map[ppos.x][ppos.y];
							s->tpos1 = tpos1;
                        	s->ltp1c = map[tpos1.x][tpos1.y];
							s->tpos2 = tpos2;
                        	s->ltp2c = map[tpos2.x][tpos2.y];
                           domove( s->action);
                           undolock = 0;
						   state_num++;
                        }
                     } while( (action != 0) && (! islower( c))
                             && (packets != savepack));
                     break;
        default:     helpmessage(); break;
      }
      if( (ret == 0) && (packets == savepack)) {
        scorelevel = level;
        scoremoves = moves;
        scorepushes = pushes;
        break;
      }
   }
#if ATARIST
	kbt = Keytbl(-1, -1, -1);
	kbt->unshifted = old_kbt.unshifted;
	kbt->shifted = old_kbt.shifted;
/*	Keytbl(old_kbt.unshifted, old_kbt.shifted, old_kbt.capslock);*/
#endif
	return ret;
}

short testmove( action)
short action;
{
   short ret;
   char tc;
   short stop_at_object;

   if( (stop_at_object = iscntrl( action))) action = action + 'A' - 1;
   action = (isupper(action) ? tolower( action) : action);
   if( (action == 'k') || (action == 'j')) {
      tpos1.x = (action == 'k') ? ppos.x-1 : ppos.x+1;
      tpos2.x = (action == 'k') ? ppos.x-2 : ppos.x+2;
      tpos1.y = tpos2.y = ppos.y;
   }
   else {
      tpos1.y = (action == 'h') ? ppos.y-1 : ppos.y+1;
      tpos2.y = (action == 'h') ? ppos.y-2 : ppos.y+2;
      tpos1.x = tpos2.x = ppos.x;
   }
   tc = map[tpos1.x][tpos1.y];
   switch( tc) {
      case C_PACKET:
      case C_SAVE:   if( ! stop_at_object) {
                       if( map[tpos2.x][tpos2.y] == C_GROUND)
                          ret = (tc == C_SAVE) ? UNSAVE : PUSH;
                        else if( map[tpos2.x][tpos2.y] == C_STORE)
                          ret = (tc == C_SAVE) ? STOREPUSH : SAVE;
                       else ret = 0;
                    }
                    else ret = 0;                                      break;
      case C_GROUND: ret = MOVE;                                       break;
      case C_STORE:  ret = STOREMOVE;                                  break;
      default:       ret = 0;                                          break;
   }
   return( ret);
}

domove( moveaction)
short moveaction;
{
   map[ppos.x][ppos.y] = (map[ppos.x][ppos.y] == C_PLAYER)
                              ? C_GROUND
                              : C_STORE;
   switch( moveaction) {
      case MOVE:      map[tpos1.x][tpos1.y] = C_PLAYER;                break;
      case STOREMOVE: map[tpos1.x][tpos1.y] = C_PLAYERSTORE;           break;
      case PUSH:      map[tpos2.x][tpos2.y] = map[tpos1.x][tpos1.y];
                     map[tpos1.x][tpos1.y] = C_PLAYER;
                     pushes++;                                         break;
      case UNSAVE:    map[tpos2.x][tpos2.y] = C_PACKET;
                     map[tpos1.x][tpos1.y] = C_PLAYERSTORE;
                     pushes++; savepack--;                             break;
      case SAVE:      map[tpos2.x][tpos2.y] = C_SAVE;
                     map[tpos1.x][tpos1.y] = C_PLAYER;
                     savepack++; pushes++;                             break;
      case STOREPUSH: map[tpos2.x][tpos2.y] = C_SAVE;
                     map[tpos1.x][tpos1.y] = C_PLAYERSTORE;
                     pushes++;                                         break;
   }
   moves++;
   dispmoves(); disppushes(); dispsave();
   mapchar( map[ppos.x][ppos.y], ppos.x, ppos.y);
   mapchar( map[tpos1.x][tpos1.y], tpos1.x, tpos1.y);
   mapchar( map[tpos2.x][tpos2.y], tpos2.x, tpos2.y);
   move( MAXROW+1, 0);
   refresh();
   ppos.x = tpos1.x; ppos.y = tpos1.y;
}

undomove() {
soko_state *s;
	state_num--;
	s = &state[state_num];

   map[s->ppos.x][s->ppos.y] = s->lppc;
   map[s->tpos1.x][s->tpos1.y] = s->ltp1c;
   map[s->tpos2.x][s->tpos2.y] = s->ltp2c;
   ppos.x = s->ppos.x; ppos.y = s->ppos.y;
   switch(s->action) {
      case MOVE:      moves--;                         break;
      case STOREMOVE: moves--;                         break;
      case PUSH:      moves--; pushes--;               break;
      case UNSAVE:    moves--; pushes--; savepack++;   break;
      case SAVE:      moves--; pushes--; savepack--;   break;
      case STOREPUSH: moves--; pushes--;               break;
   }
   dispmoves(); disppushes(); dispsave();
   mapchar( map[s->ppos.x][s->ppos.y], s->ppos.x, s->ppos.y);
   mapchar( map[s->tpos1.x][s->tpos1.y], s->tpos1.x, s->tpos1.y);
   mapchar( map[s->tpos2.x][s->tpos2.y], s->tpos2.x, s->tpos2.y);
   move( MAXROW+1, 0);
   refresh();
}

tmpsave() {

   short i, j;
   for( i = 0; i < rows; i++) for( j = 0; j < cols; j++)
      tmp_map[i][j] = map[i][j];
	tmp_statenum = state_num;
   tmp_pushes = pushes;
   tmp_moves = moves;

   tmp_savepack = savepack;
   tmp_ppos.x = ppos.x; tmp_ppos.y = ppos.y;
}

tmpreset() {

   short i, j;

   for( i = 0; i < rows; i++) for( j = 0; j < cols; j++)
      map[i][j] = tmp_map[i][j];
	state_num = tmp_statenum;
   pushes = tmp_pushes;
   moves = tmp_moves;
   savepack = tmp_savepack;
   ppos.x = tmp_ppos.x; ppos.y = tmp_ppos.y;
}
