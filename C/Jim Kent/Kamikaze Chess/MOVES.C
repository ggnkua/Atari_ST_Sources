
#include "kamikaze.h"


struct move *history[HSZ];
ushort move_count;
int living[2];
WORD move_color = WHITE;

int kings_row[2] = {0, 7};
int enp_row[2] = {5, 2};

backup2()
{
register Move *m;
int i;

if (move_count < 2)
	return;
i = 2;
while (--i >= 0)
	{
	m = history[move_count-1];
	unboard_move(m);
	freemem(m);
	}
find_legal_moves();
hide_mouse();
draw_board();
show_mouse();
}

unboard_move(m)
register Move *m;
{
register char c;
register struct piece *p;
register int x, y;

if (move_count <= 0)	/* Shouldn't happen... */
	{
	puts("error - going before beginning");
	return;
	}
move_color ^= 1;

/* find current square and  remove piece from that square */
p = m->piece;
x = p->column;
y = p->row;
board[y][x].piece = NULL;

/* move piece and put it on new place in board */
x -= m->dx;
y -= m->dy;
p->column = x;
p->row = y;
p->move_count-=1;
board[y][x].piece = p;

/* check castling */
if (m->flags & MCASTLING)
	{
	y = kings_row[move_color];
	if (m->dx > 0)	/* queens side? */
		{
		p += 4;	/* piece goes from king to queen's rook */
		board[y][4].piece = NULL;	/* remove rook from middle */
		board[y][7].piece = p;
		p->column = 7;
		}
	else
		{
		p -= 3;	/* goes from king to king's rook */
		board[y][2].piece = NULL;	/* remove rook from king's side */
		board[y][0].piece = p;
		p->column = 0;
		}
	p->move_count-=1;
	}
if (m->flags & MQUEENING)
	{
	repawn(p);
	}

/* If a piece was took flag it alive again and put it on board where it
   last was */
if ((p = m->took_piece) != NULL)
	{
	living[1-move_color]+=1;
	p->flags &= ~PDEAD;
	board[p->row][p->column].piece = p;
	}

/* update move history and toggle move color */
move_count -= 1;
}

board_move(m)
register Move *m;
{
register char c;
register struct piece *p;
register struct square *sq;
register int x, y;

/* If a piece was took flag it dead and remove from board */
if ((p = m->took_piece) != NULL)
	{
	living[1-move_color]-=1;
	p->flags |= PDEAD;
	board[p->row][p->column].piece = NULL;
	}

/* find current square and remove piece from that square */
p = m->piece;
x = p->column;
y = p->row;
board[y][x].piece = NULL;

/* move piece and put it on new place in board */
x += m->dx;
y += m->dy;
p->column = x;
p->row = y;
board[y][x].piece = p;
p->move_count += 1;

/* check castling */
if (m->flags & MCASTLING)
	{
	y = kings_row[move_color];
	if (m->dx > 0)	/* queens side? */
		{
		p += 4;	/* p points to queen's rook */
		board[y][7].piece = NULL;	/* remove from corner */
		board[y][4].piece = p;		/* put next to king */
		p->column = 4;
		}
	else
		{
		p -= 3;	/* p points to king's rook */
		board[y][0].piece = NULL;	/* remove from corner */
		board[y][2].piece = p;		/* put next to king */
		p->column = 2;
		}
	p->move_count += 1;
	}
if (m->flags & MQUEENING)
	{
	retype_piece(p, m->promotion);
	}
move_color ^= 1;
if (move_count < HSZ)
	{
	history[move_count] = m;
	move_count++;
	}
else
	{
	puts("Too many moves!");
	return(0);
	}
return(1);
}

Move *
make_legal_move(p, ncol, nrow)
register Piece *p;
WORD ncol, nrow;
{
struct move m, *mpt;
Square *newsq;
register Piece *newp;
WORD ocol, orow;
WORD x;

m.dx = ncol - p->column;
m.dy = nrow - p->row;
if (!possible_move(p, &m, 1))
	{
	return(NULL);
	}
if ((mpt = clone_structure(&m, sizeof(m))) == NULL)
	return(NULL);
if (!board_move(mpt))
	{
	freemem(mpt);
	return(NULL);
	}
return(mpt);
}

move_piece(p, ncol, nrow)
register Piece *p;
WORD ncol, nrow;
{
struct move *m;
WORD ocol, orow;

orow = p->row;
ocol = p->column;
if ((m = make_legal_move(p, ncol, nrow)) != NULL)
	{
	hide_mouse();
	draw_square(&board[orow][ocol]);
	draw_square(&board[nrow][ncol]);
	if (m->flags & MCASTLING)
		{
		if (ncol == 1)	/* king's side */
			{
			draw_square(&board[orow][0]);	/* erase old rook */
			draw_square(&board[orow][2]);	/* draw new rook */
			}
		else
			{
			draw_square(&board[orow][7]);	/* erase old rook */
			draw_square(&board[orow][4]);	/* draw new rook */
			}
		}
	if (m->flags & MENPASSANT)
		{
		draw_psquare(m->took_piece);
		}
	show_mouse();
	return(1);
	}
return(0);
}


check_pawn(p, m)
register Piece *p;
register struct move *m;
{
if (c_pawn(p, m))
	{
	if (kings_row[1-p->color] == p->row + m->dy)
		{
		m->flags |= MQUEENING;
		}
	return(1);
	}
else
	return(0);
}

/* c_pawn() - check everything about pawn except promotion */
c_pawn(p, m)
register Piece *p;
register struct move *m;
{
Square *os;
Piece *op;
WORD newcol, newrow;
struct move *enm;
register WORD dx, dy;

dx = m->dx;
dy = m->dy;
newcol = p->column + dx;
newrow = p->row + dy;
/* if black invert y position */
if (p->color)
	dy = -dy;
/* now return 0 unless moving one or two pieces forward */
if (dy <= 0 || dy > 2 || dx > 1 || dx < -1)
	return(0);
if (dy == 2)
	{
	if (dx != 0)	/* make sure no diagonal move with 2 forward */
		return(0);
	if (p->color == WHITE)
		{
		if (p->row != 1)
			return(0);
		os = &board[2][newcol];
		}
	else
		{
		if (p->row != 6)
			return(0);
		os = &(board[5][newcol]);
		}
	if (os->piece != NULL)
		return(0);
	}
/* moving on a diagonal */
os = &(board[newrow][newcol]);
op = os->piece;
if (dx == 0)
	{
	return(op == NULL);
	}
if (op != NULL)
	return(1);
/* have to check for en-passent */
if (newrow != enp_row[p->color])
	return(0);
os = &(board[p->row][newcol]);
op = os->piece;
if (op == NULL)
	return(0);
if (op->color == p->color)
	return(0);
enm = history[move_count-1];
if (enm->dx != 0)
	return(0);
if (enm->dy != -2 && enm->dy != 2)
	return(0);
if (enm->piece != op)
	return(0);
m->flags |= (MENPASSANT|MTAKING);
m->took_piece = op;
return(1);
}

check_knight(p,m)
Piece *p;
Move *m;
{
register WORD dx, dy;

dx = m->dx;
dy = m->dy;
if (dx < 0)
	dx = -dx;
if (dy < 0)
	dy = -dy;
if (dx == 2 && dy == 1)
	return(1);
if (dx == 1 && dy == 2)
	return(1);
return(0);
}

check_br(p, dx, dy, rook)
register Piece *p;
register WORD dx, dy;
WORD rook;
{
register WORD incx, incy;
WORD count;
WORD cx, cy;

cx = p->column;
cy = p->row;
incx = incy = 1;
if (dx < 0)
	{
	dx = -dx;
	incx = -1;
	}
if (dy < 0)
	{
	dy = -dy;
	incy = -1;
	}
count = dx;
if (rook)
	{
	if (dx != 0 && dy != 0)
		return(0);
	if (dx == 0)
		{
		incx = 0;
		count = dy;
		}
	else
		{
		incy = 0;
		}
	}
else
	{
	if (dx != dy)
		return(0);
	}
count -= 1;	/* don't have to check starting or ending positions */
while (--count >= 0)
	{
	cx += incx;
	cy += incy;
	if (board[cy][cx].piece)
		return(0);
	}
return(1);
}

check_bishop(p, m)
Piece *p;
Move *m;
{
return(check_br(p, m->dx, m->dy, 0));
}

check_rook(p, m)
Piece *p;
Move *m;
{
return(check_br(p, m->dx, m->dy, 1));
}

check_queen(p, m)
Piece *p;
Move *m;
{
return(check_br(p, m->dx, m->dy, 0) || check_br(p, m->dx, m->dy, 1));
}

check_king(p, m)
Piece *p;
Move *m;
{
register WORD dx, dy;

dx = m->dx;
dy = m->dy;
if (dy == 0)
	{
	if (dx == 2)
		{
		if (p->move_count != 0)	/* has king moved ? */
			return(0);
		p += 4;
		if (p->move_count != 0)	/* has rook moved ? */
			return(0);
		if (check_br(p, -3, 0, 1))	/* check rook path clear */
			{
			m->flags |= MCASTLING;
			return(1);
			}
		else
			return(0);
		}
	if (dx == -2)
		{
		if (p->move_count != 0)	/* has king moved ? */
			return(0);
		p -= 3;
		if (p->move_count != 0)	/* has rook moved ? */
			return(0);
		if (check_br(p, 2, 0, 1))	/* rook path clear? */
			{
			m->flags |= MCASTLING;
			return(1);
			}
		else
			return(0);
		}
	}
return(dx >= -1 && dx <= 1 && dy >= -1 && dy <= 1);
}

extern Piece *in_check(), *in_danger();

probable_move(p, m, showit)
register struct piece *p;
register struct move *m;
WORD showit;
{
Piece *newp;
Piece *ret;
register int px, py;
int ok;
register int color;


ok = 1;
px = p->column + m->dx;
py = p->row + m->dy;
if (!(px >= 0 && px <= 7 && py >= 0 && py <= 7))	/* off board! */
	return(0);
m->flags = 0;
m->piece = p;
m->value = 0;
color = p->color;
if ((newp = board[py][px].piece) != NULL)			/* onto another piece */
	{
	if (newp->color == color)					/* can't move onto self */
		return(0);
	else
		{
		m->flags |= MTAKING;
		m->took_piece = newp;
		}
	}
else
	{
	m->took_piece = NULL;
	}
if (!(*p->legal)(p, m))
	return(0);
if (m->flags & MQUEENING)
	{
	m->promotion = QUEEN_IX;	/* always a queen for now... */
	}
if (!board_move(m))
	return(0);
if ((ret = in_check(color)) != NULL)
	{
	m->flags |= MCHECKED;
	ok = 0;
	}
if (showit)
	{
	if (ret != NULL)
		{
		short_message("In Check!", color+2);
		flash_pieces(ret, pieces[color]+KING_IX);
		}
	}
unboard_move(m);
return(ok);
}

possible_move(p, m, showit)
Piece *p;
Move *m;
WORD showit;
{
int ok;

if (!probable_move(p, m, showit))
	return(0);
ok = ((!must_take) || (m->flags & MTAKING));
if (showit)
	{
	if (!ok)
		{
		short_message("Must Take", p->color+2);
		flash_taking_moves();
		}
	else if (m->flags & MQUEENING)
		{
		short_message("Queening!", p->color+2);
		flash_color(0x407);
		wait_a_jiffy(30);
		}
	else if (m->flags & MENPASSANT)
		{
		short_message("En Passent", p->color+2);
		flash_color(0x007);
		wait_a_jiffy(30);
		}
	}
return(ok);
}


Piece *
in_check(color)
WORD color;
{
if (living[color] == 1)	/* last piece left it's ok */
	return(NULL);
return(in_danger( pieces[color]+KING_IX) );
}

Piece *
in_danger(king)
register Piece *king;
{
WORD color;
register Piece *p;
register WORD i;
struct move m;

if (king->flags & PDEAD)
	return(-1);
p = pieces[1-king->color];
for (i=0; i<16; i++)
	{
	m.dx = king->column-p->column;
	m.dy = king->row - p->row;
	if (!(p->flags & PDEAD))
		{
		if ((*p->legal)(p, &m))
			return(p);
		}
	p++;
	}
return(NULL);
}
