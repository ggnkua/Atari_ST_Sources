#ifndef POSITION_H
#define POSITION_H

#include <stdbool.h>
#include <stdlib.h>

/* Data structure and functions for handling a single position,
   along with information on the current state of play.

   Each position holds the 'fixed' walls and goals in the cells array,
   and an array of box locations in boxes array,
   and the player location.
 */

enum obj { EMPTY, WALL, GOAL };
enum direction { UP, DOWN, LEFT, RIGHT };

struct move {
	int player_start_x;
	int player_start_y;
	int box_start_x;
	int box_start_y;
	int box_end_x;
	int box_end_y;

	struct move * prev;
};

struct position {
	int height;
	int width;
	enum obj * cells; /* array (height x width) */
	int num_boxes;
	int * boxes;  /* size num_boxes*2, with x at i*2, y at i*2+1 */
	int player_x;
	int player_y;
	int last_move[6]; /* x,y coords of last squares to change */

	struct move * move_list;
};

struct position * position_from_defn (char * defn);
enum obj position_cell (struct position * posn, int x, int y);
bool position_is_complete (struct position * posn);
bool position_can_move (struct position * posn, enum direction dirn);
void position_make_move (struct position * posn, enum direction dirn);
void position_undo_move (struct position * posn);
void position_free (struct position * posn);

#endif