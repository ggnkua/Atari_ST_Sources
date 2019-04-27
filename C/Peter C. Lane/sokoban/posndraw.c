#include "posndraw.h"

/* Draw game position on screen.
   offset_x/offset_y indicate scrollbar place.
   if type == MOVE, then only update the squares in posn->last_move
 */
void position_draw (int app_handle, struct position * posn, int x, int y, int w, int h, int offset_x, int offset_y, int type, int cell_h, int cell_w, int num_colours) {
	int i, j;

	/* draw the fixed cells */
	for (i = 0; i < posn->width; i += 1) {
		for (j = 0; j < posn->height; j += 1) {
			int cx = (i+1-offset_x)*cell_w+x;
			int cy = (j+1-offset_y)*cell_h+y;

			/* if updating after a move, only do the cells in last_move */
			if (type == MOVE &&
				(i != posn->last_move[0] || j != posn->last_move[1]) &&
				(i != posn->last_move[2] || j != posn->last_move[3]) &&
				(i != posn->last_move[4] || j != posn->last_move[5])) {
				continue;
			}

			if (cx >= x-cell_w && cx <= x + w && cy >= y-cell_h && cy <= y + h) { /* make sure is visible */
				int pxy[4];
				pxy[0] = cx;
				pxy[1] = cy;
				pxy[2] = cx + cell_w - 1;
				pxy[3] = cy + cell_h - 1;

				switch (position_cell (posn, i, j)) {

					case WALL:
						if (num_colours >= 16) {
							vsf_color (app_handle, RED);
						} else {
							vsf_color (app_handle, BLACK);
						}
						vsf_interior (app_handle, 2);
						vsf_style (app_handle, 4);
						v_bar (app_handle, pxy);
						break;

					case GOAL:
						if (num_colours >= 16) {
							vsf_color (app_handle, LGREEN);
							vsf_interior (app_handle, SOLID);
							v_bar (app_handle, pxy);

							vsf_color (app_handle, YELLOW);
							v_ellipse (app_handle, (pxy[2]+pxy[0])/2, (pxy[3]+pxy[1])/2, cell_w/6, cell_h/6);
						} else {
							int cx = (pxy[2]+pxy[0])/2;
							int cy = (pxy[3]+pxy[1])/2;
							int sx = cell_w/4;
							int sy = cell_h/4;

							vsf_interior (app_handle, SOLID);
							vsf_color (app_handle, WHITE);
							v_bar (app_handle, pxy); /* clear the cell */

							vsl_color (app_handle, BLACK);
							pxy[0] = cx-sx;
							pxy[1] = cy-sy;
							pxy[2] = cx+sx;
							pxy[3] = cy+sy;
							v_pline (app_handle, 2, pxy);
							pxy[0] = cx+sx;
							pxy[1] = cy-sy;
							pxy[2] = cx-sx;
							pxy[3] = cy+sy;
							v_pline (app_handle, 2, pxy);
						}
						break;

					case EMPTY:
						if (num_colours >= 16) {
							vsf_color (app_handle, GREEN);
							vsf_interior (app_handle, SOLID);
						} else {
							vsf_color (app_handle, WHITE);
							vsf_interior (app_handle, SOLID);
						}
						v_bar (app_handle, pxy);
						break;
				}

			}
		}
	}

	/* draw the boxes */
	for (i = 0; i < posn->num_boxes; i += 1) {
		int cx = (posn->boxes[2*i]+1-offset_x)*cell_w+x;
		int cy = (posn->boxes[2*i+1]+1-offset_y)*cell_h+y;

		/* if updating after a move, only do the cells in last_move[4], last_move[5] */
		if (type == MOVE && (posn->boxes[2*i] != posn->last_move[4] || posn->boxes[2*i+1] != posn->last_move[5])) continue;

		if (cx >= x-cell_w && cx <= x + w && cy >= y-cell_h && cy <= y + h) { /* make sure is visible */
			int pxy[4];
			pxy[0] = cx + cell_w/8;
			pxy[1] = cy + cell_h/8;
			pxy[2] = cx + 7*cell_w/8 - 1;
			pxy[3] = cy + 7*cell_h/8 - 1;

			if (num_colours >= 16) {
				if (position_cell (posn, posn->boxes[2*i], posn->boxes[2*i+1]) == GOAL) {
					vsf_color (app_handle, LGREEN);
				} else {
					vsf_color (app_handle, LYELLOW);
				}
				vsf_interior (app_handle, 3);
				vsf_style (app_handle, 3);
			} else {
				vsf_color (app_handle, BLACK);
				if (position_cell (posn, posn->boxes[2*i], posn->boxes[2*i+1]) == GOAL) {
					vsf_interior (app_handle, 2);
					vsf_style (app_handle, 23);
				} else {
					vsf_interior (app_handle, 3);
					vsf_style (app_handle, 3);
				}
			}

			v_bar (app_handle, pxy);
		}
	}

	/* draw the player: player always moves, so don't check last_move */
	{
		int cx = (posn->player_x+1-offset_x)*cell_w+x;
		int cy = (posn->player_y+1-offset_y)*cell_h+y;
		int pxy[4];

		if (cx >= x-cell_w && cx <= x + w && cy >= y-cell_h && cy <= y + h) { /* make sure is visible */
			vsf_color (app_handle, (num_colours < 16 ? BLACK : BLUE));
			vsf_interior (app_handle, SOLID);
			v_ellipse (app_handle, cx+cell_w/2, cy+cell_h/2, cell_w/3, cell_h/3);
			vsl_color (app_handle, (num_colours < 16 ? WHITE : YELLOW));
			pxy[0] = cx+cell_w/2-cell_w/4;
			pxy[1] = cy+cell_h/2;
			pxy[2] = cx+cell_w/2+cell_w/4;
			pxy[3] = cy+cell_h/2;
			v_pline (app_handle, 2, pxy);
			pxy[0] = cx+cell_w/2;
			pxy[1] = cy+cell_h/2-cell_h/4;
			pxy[2] = cx+cell_w/2;
			pxy[3] = cy+cell_h/2+cell_h/4;
			v_pline (app_handle, 2, pxy);
		}
	}
	/* tidy up the last_move values */
	if (type == MOVE) {
		for (i = 0; i < 6; i += 1) {
			posn->last_move[i] = -1;
		}
	}
}

