#include "position.h"

/* Calculate height/width of given defn */
void find_dimensions (char * defn, int * height, int * width) {
	int i;
	int curr_width;

	*height = 0;
	*width = 0;

	curr_width = 0;
	for (i = 0; defn[i] != 0; i += 1) {
		if (defn[i] == '\n') {
			*height += 1;
			if (curr_width > *width) *width = curr_width;
			curr_width = 0;
		} else {
			curr_width += 1;
		}
	}
	/* last check, in case defn does not end with '\n' */
	if (curr_width > *width) *width = curr_width;
	if (curr_width > 0) *height += 1;
}

/* Find the number of boxes in given defn */
int count_boxes (char * defn) {
	int count = 0;
	int i;

	for (i = 0; defn[i] != 0; i += 1) {
		if (defn[i] == '$' || defn[i] == 'o' || defn[i] == '*') {
			count += 1;
		}
	}

	return count;
}

/* From a given definition, create a new position */
struct position * position_from_defn (char * defn) {
	int i;
	int x, y;
	int bx;
	int cposn;
	struct position * posn = malloc (sizeof (struct position));

	find_dimensions (defn, &posn->height, &posn->width);
	posn->cells = malloc (sizeof(enum obj)*posn->height*posn->width);

	for (i=0; i<posn->height*posn->width; i += 1) {
		posn->cells[i] = EMPTY;
	}

	posn->num_boxes = count_boxes (defn);
	posn->boxes = malloc(sizeof(int)*2*posn->num_boxes);

	for (i = 0; i < 6; i += 1) {
		posn->last_move[i] = -1;
	}
	posn->move_list = NULL;

	/* walk through definition, completing locations of cells/boxes/player */
	x = y = 0;
	bx = 0; /* index of next box */
	for (i = 0; defn[i] != 0; i += 1) {
		/* cell contents */
		cposn = x + y*posn->width;
		if (defn[i] == ' ') {
			posn->cells[cposn] = EMPTY;
		} else if (defn[i] == '#') {
			posn->cells[cposn] = WALL;
		} else if (defn[i] == '.' || defn[i] == '+' || defn[i] == '*') {
			posn->cells[cposn] = GOAL;
		}

		/* box location */
		if (defn[i] == '$' || defn[i] == 'o' || defn[i] == '*') {
			posn->boxes[2*bx] = x;
			posn->boxes[2*bx+1] = y;
			bx += 1;
		}

		/* player location */
		if (defn[i] == '@' || defn[i] == '+') {
			posn->player_x = x;
			posn->player_y = y;
		}

		/* advance position */
		if (defn[i] == '\n') {
			y += 1;
			x = 0;
		} else {
			x += 1;
		}
	}

	return posn;
}

/* Return obj at given cell position: assumes (x,y) is valid */
enum obj position_cell (struct position * posn, int x, int y) {
	return posn->cells[x+y*posn->width];
}

/* Check if all boxes are on goals */
bool position_is_complete (struct position * posn) {
	int i;

	for (i = 0; i < posn->num_boxes; i += 1) {
		int bx = posn->boxes[2*i];
		int by = posn->boxes[2*i+1];

		if (position_cell(posn, bx, by) != GOAL) return false;
	}

	return true;
}

/* Check if there is a block in given location */
bool block_at (struct position * posn, int x, int y) {
	int i;

	for (i = 0; i < posn->num_boxes; i += 1) {
		int bx = posn->boxes[2*i];
		int by = posn->boxes[2*i+1];

		if (bx == x && by == y) return true;
	}

	return false;
}

/* Check if player can move in given direction */
bool position_can_move (struct position * posn, enum direction dirn) {
	int off_x = 0;
	int off_y = 0;
	int next_x;
	int next_y;

	if (dirn == UP) off_y = -1;
	if (dirn == DOWN) off_y = 1;
	if (dirn == LEFT) off_x = -1;
	if (dirn == RIGHT) off_x = 1;

	/* look at square aiming to move to */
	next_x = posn->player_x+off_x;
	next_y = posn->player_y+off_y;

	/* NB: Check player/block do not fall off position, as positions
	   can be loaded from a file */
	if (next_x < 0 || next_x >= posn->width) return false;
	if (next_y < 0 || next_y >= posn->height) return false;

	if (position_cell(posn, next_x, next_y) == WALL) {
	 	return false;
	} else if (block_at (posn, next_x, next_y)) {
		/* if there is a block in the next square, then see if we can push it */
		if ((next_x+off_x >= 0 && next_x+off_x < posn->width) &&
			(next_y+off_y >= 0 && next_y+off_y < posn->height) &&
			(position_cell(posn, next_x+off_x, next_y+off_y) != WALL) &&
			!(block_at(posn, next_x+off_x, next_y+off_y))) {
			/* Space after the block is free, so can push block */
			return true;
		}
	} else { /* no wall or block, so can move there */
		return true;
	}

	/* will only reach here if position is not surrounded by a wall */
	return false;
}

/* Assuming move is legal, make the given move */
void position_make_move (struct position * posn, enum direction dirn) {
	int off_x = 0;
	int off_y = 0;
	int next_x;
	int next_y;
	int i;
	struct move * lm = malloc (sizeof(struct move));

	if (dirn == UP) off_y = -1;
	if (dirn == DOWN) off_y = +1;
	if (dirn == LEFT) off_x = -1;
	if (dirn == RIGHT) off_x = 1;

	/* square player aiming to move to */
	next_x = posn->player_x+off_x;
	next_y = posn->player_y+off_y;

	/* record the squares that get changed */
	posn->last_move[0] = posn->player_x;
	posn->last_move[1] = posn->player_y;
	posn->last_move[2] = next_x;
	posn->last_move[3] = next_y;

	/* if there is a block in the next square, it must be pushable */
	for (i = 0; i < posn->num_boxes; i += 1) {
		int bx = posn->boxes[2*i];
		int by = posn->boxes[2*i+1];

		if (bx == next_x && by == next_y) {
			/* found a box in next square, so move it */
			posn->boxes[2*i] += off_x;
			posn->boxes[2*i+1] += off_y;
			posn->last_move[4] = posn->boxes[2*i];
			posn->last_move[5] = posn->boxes[2*i+1];
			/* record move */
			lm->box_start_x = bx;
			lm->box_start_y = by;
			lm->box_end_x = posn->boxes[2*i];
			lm->box_end_y = posn->boxes[2*i+1];
			break; /* exit the loop */
		}
	}

	/* move the player */
	lm->player_start_x = posn->player_x;
	lm->player_start_y = posn->player_y;

	posn->player_x = next_x;
	posn->player_y = next_y;

	/* record move */
	lm->prev = posn->move_list;
	posn->move_list = lm;
}

/* Undo last move */
void position_undo_move (struct position * posn) {
	struct move * lm = posn->move_list;

	if (lm == NULL) return;

	/* record the squares that get changed */
	posn->last_move[0] = posn->player_x;
	posn->last_move[1] = posn->player_y;
	posn->last_move[2] = lm->player_start_x;
	posn->last_move[3] = lm->player_start_y;

	posn->player_x = lm->player_start_x;
	posn->player_y = lm->player_start_y;

	if (lm->box_start_x != -1) {
		int i;
		for (i = 0; i < posn->num_boxes; i += 1) {
			if ((posn->boxes[2*i] == lm->box_end_x) &&
				(posn->boxes[2*i+1] == lm->box_end_y)) {
				posn->boxes[2*i] = lm->box_start_x;
				posn->boxes[2*i+1] = lm->box_start_y;
				/* change square - record end square, as player will be on start square before move */
				/* due to way posndraw works, put square of box in [4] [5] */
				posn->last_move[4] = posn->last_move[0];
				posn->last_move[5] = posn->last_move[1];
				posn->last_move[0] = lm->box_end_x;
				posn->last_move[1] = lm->box_end_y;

				break;
			}
		}
	}
	posn->move_list = lm->prev;
	free (lm);
}

/* Free memory used by given position */
void position_free (struct position * posn) {
	free (posn->cells);
	free (posn->boxes);
	free (posn);
}
