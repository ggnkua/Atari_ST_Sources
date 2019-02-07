
/***  Kamikaze Chess

      Copyright 1988 Jim Kent

      February, 1989 START Magazine 


***/

#include "kamikaze.h"

#define NOMOVE NULL
#define SQSZX 28
#define SQSZY 24 
#define MXOFF (9+SQSZX*8)

extern Piece white_pieces[16], black_pieces[16], w_pieces[16], b_pieces[16];

extern unsigned WORD
    iwhite_pawn[], iwhite_knight[], iwhite_bishop[], iwhite_rook[], 
    iwhite_queen[], iwhite_king[],
    iblack_pawn[], iblack_knight[], iblack_bishop[], iblack_rook[], 
    iblack_queen[], iblack_king[];
extern check_pawn();

extern WORD randseed;

extern Piece_move bpawn_moves[4], wpawn_moves[4];


WORD break_game;	/* done with game (pressed 'q') ? */
WORD curx, cury;	/* cursor position for keyboard control */
 
/* convert a promoted pawn back to a pawn */
repawn(p)
register Piece *p;
{
p->type = PAWN;
p->name = "Pn";
if (p->color == BLACK)
    {
    p->image = iblack_pawn;
    p->lmoves = bpawn_moves;
    }
else
    {
    p->image = iwhite_pawn;
    p->lmoves = wpawn_moves;
    }
p->legal = check_pawn;
p->lmove_count = Array_els(bpawn_moves);
}

/* promote a pawn to a new type */
retype_piece(p, piece_ix)
register Piece *p;
int piece_ix;
{
register Piece *qp;

qp = pieces[p->color]+piece_ix;
p->type = qp->type;
p->name = qp->name;
p->image = qp->image;
p->legal = qp->legal;
p->lmoves = qp->lmoves;
p->lmove_count = qp->lmove_count;
p->value = qp->value;
}

/* Fill in the xy locations of the squares of board and their colors. */
init_board()
{
extern ushort move_count;
extern int living[2];
extern WORD move_color;
int i, j;
register int color;
register Square *b;

color = 1;
for (i=0; i<8; i++)
    {
    for (j=0; j<8; j++)
        {
        b = &(board[i][j]);
        b->x = 2+SQSZX*j+1;
        b->y = 2+SQSZY*i+1;
        b->width = SQSZX;
        b->height = SQSZY;
        b->color = (color&1);
        b->piece = NULL;
        color += 1;
        }
    color += 1;
    }
}

/* Draw a single square of chess board, and the piece on it if any */
draw_square(sq)
register Square *sq;
{
register Piece *p;

colored_block(sq->color, sq->x, sq->y, sq->width, sq->height);
if (p = sq->piece)
    {
    show_piece(p->image, sq->x, sq->y, p->color+2);
    }
}

/* Given a piece draw the square its on. */
draw_psquare(p)
struct piece *p;
{
draw_square(&board[p->row][p->column]);
}

/* Draw the whole board */
draw_board()
{
int i;
register Square *sq;

vswr_mode(handle, 2);
/* Draw the outline around chess squares */
colored_block(1, 1, 1, MXOFF-6, 1);
colored_block(1, 1, YMAX-4, MXOFF-6, 1);
colored_block(1, 1, 1, 1, YMAX-4);
colored_block(1, MXOFF-5, 1, 1, YMAX-4);
/* and the squares themselves */
sq = &board[0][0];
i = 8*8;
while (--i >= 0)
    {
    draw_square(sq);
    sq++;
    }
}



/* short line of text on top right */
short_message(c, color)
char *c;
int color;
{
smessage(c, color, 0);
}

/* Message on 2nd line of right side */
message2(c, color)
char *c;
int color;
{
smessage(c, color, 1);
}

/* A short line of text on the right.  Y is vertical location from 0-19 */
smessage(c, color, y)
char *c;
int color;
int y;
{
y*=10;
y += 1;
hide_mouse();
colored_block(0, 6+SQSZX*8, y, XMAX-(6+SQSZX*8), 10);
gtext(c, MXOFF-2, y, color);
show_mouse();
}


/* Put the pieces on the board */
init_pieces(p)
register Piece *p;
{
int i;

i = 16;
while (--i >= 0)
    {
    board[p->row][p->column].piece = p;
    p++;
    }
}


/* Figure out which square the mouse is over */
find_square()
{
curx = (mouse_x - board[0][0].x) / board[0][0].width;
cury = (mouse_y - board[0][0].y) / board[0][0].height;
return(curx <= 7 && curx >= 0 && cury <= 7 && cury >= 0);
}

/* Xor a square to hilight it and show user where he is */
xor_sq(sq)
register Square *sq;
{
xor_block(15, sq->x, sq->y, sq->width, sq->height);
}

/* Draw a red frame around square to show that's what piece is being
   moved. */
frame_square(sq)
register Square *sq;
{
colored_block(5, sq->x, sq->y, 1, sq->height);
colored_block(5, sq->x+sq->width-1, sq->y, 1, sq->height);
colored_block(5, sq->x, sq->y, sq->width, 1);
colored_block(5, sq->x, sq->y+sq->height-1, sq->width, 1);
}

/* Flash 2 pieces, perhaps to show that 'you must take' this with that. */
flash_pieces(p1, p2)
struct piece *p1, *p2;
{
fpieces(p1, p2, 4);
}

fpieces(p1, p2, i)
struct piece *p1, *p2;
int i;
{

hide_mouse();
while (--i >= 0)
    {
    xor_sq(&board[p1->row][p1->column]);
    if (p2 != NULL)
        xor_sq(&board[p2->row][p2->column]);
    wait_a_jiffy(20);
    }
show_mouse();
}

/* Move a piece using the mouse */
mouse_move_piece(color)
int color;
{
Square *sq, *newsq, *lastsq;
register Piece *p;

if (!find_square())
    {
    return(0);
    }
lastsq = newsq = sq = &board[cury][curx];
if ((p = sq->piece) == NULL)
    {
    return(0);
    }
if (p->color != color)
    {
    return(0);
    }
hide_mouse();
frame_square(sq);
xor_sq(newsq);
show_mouse();
for (;;)
    {
    check_input();
    if (mouse_moved)
        {
        if (find_square())
            {
            newsq = &board[cury][curx];
            if (lastsq != newsq)
                {
                hide_mouse();
                xor_sq(lastsq);
                xor_sq(newsq);
                show_mouse();
                lastsq = newsq;
                }
            }
        }
    if (!PDN)
        break;
    }
hide_mouse();
xor_sq(newsq);
draw_square(sq);
show_mouse();
return(move_piece(p, curx, cury));
}


/* Move the 'chess square cursor' in response to the arrow keys */
key_move_cur()
{
hide_mouse();
xor_sq(&board[cury][curx]);
switch (key_in)
    {
    case LARROW:    /* left arrow */
        if (curx > 0)
            curx -= 1;
        break;
    case RARROW:    /* right arrow */
        if (curx < 7)
            curx += 1;
        break;
    case DARROW: /* down arrow */
        if (cury < 7)
            cury += 1;
        break;
    case UARROW: /* up arrow */
        if (cury > 0)
            cury -= 1;
        break;
    }
xor_sq(&board[cury][curx]);
show_mouse();
}

/* Let user select a square with keyboard. */
kfind_square()
{
for (;;)
    {
    check_input();
    if (key_hit)
        {
        switch (key_in&0xff)
            {
            case '\r':
                return(1);
            case ' ':
                return(0);
            case 'x':
            case 'q':
                break_game = 1;
                return(0);
            default:
                key_move_cur();
                break;
            }
        }
    if (RJSTDN)
        return(0);
    }
}

/* Hide mouse xor */
hmxor()
{
hide_mouse();
xor_sq(&board[cury][curx]);
show_mouse();
}


/* Move a piece using the keyboard */
key_move_piece(color)
int color;
{
Square *sq;
register Piece *p;

hmxor();
if (!kfind_square())
    {
    hmxor();
    return(0);
    }
sq = &board[cury][curx];
hide_mouse();
frame_square(sq);
show_mouse();
if ((p = sq->piece) == NULL)
    {
    hmxor();
    hide_mouse();
    draw_square(sq);
    show_mouse();
    return(0);
    }
if (p->color != color)
    {
    hmxor();
    hide_mouse();
    draw_square(sq);
    show_mouse();
    return(0);
    }
if (!kfind_square())
    {
    hmxor();
    hide_mouse();
    draw_square(sq);
    show_mouse();
    return(0);
    }
hmxor();
hide_mouse();
draw_square(sq);
show_mouse();
return(move_piece(p, curx, cury));
}


char *whomove[2] = {"White Move", "Black Move"};
/* Ok it's a human player's turn.  Let them move with either keyboard or
   mouse. */
human_move_piece(color)
WORD color;
{
for (;;)
    {
    check_input();
    if (key_hit)
        {
        switch (key_in&0xff)
            {
            case 'x':
            case 'q':
                outta_here();
                break;
            case '\b':
                backup2();
                break;
            default:
                if (key_move_piece(move_color))
                    return;
                break;
            }
        }
    if (PJSTDN)
        {
        if (mouse_move_piece(move_color))
            return;
        }
    }
}


/* Somebody's moving.  ST parameter tells us whether it's man or machine. */
some_move(st)
int st;    /* st or human??? */
{
if (check_for_mate())
    return(0);
hide_mouse();
if (st)
    bee_cursor();
else
    {
    if (move_color)
        black_hand();
    else
        white_hand();
    }
show_mouse();
short_message(whomove[move_color], move_color+2);
if (st)
    {
    if (!droid_move_piece(move_color, 500L))
        {
        short_message("I'm confused", move_color+2);
        return(0);    /* wierd error condition, "shouldn't" happen */
        }
    }
else
    human_move_piece(move_color);
return(1);
}

int wst, bst;    /* white and black played by ST ?? */

/* Put up that bunch of words to the right of the chessboard and
    patiently wait for user(s) to tell us how they want to play this game. */
do_menu()
{
int i;

/* draw up credits and menu options */
big_font();
italic_font();
smessage("KAMI-",15,2);
smessage("KAZE", 15, 4);
smessage("CHESS", 15, 6);
unitalic_font();
small_font();
smessage("COPYRIGHT 1988", 15, 8);
smessage("JIM KENT", 15, 9);
smessage("START MAGAZINE",15, 10);
smessage("FEBRUARY 1989",15,11);
smessage(" PLAY CHOICES:",15, 13);
smessage("0  ST vs PLAYER", 15, 14);
smessage("1  PLAYER vs ST", 15, 15);
smessage("2  2 PLAYERS", 15, 16);
smessage("3  ST vs ST", 15, 17);
smessage("Q  QUIT", 15, 18);
normal_font();
hide_mouse();
/* wait for user to hit the right key */
for (;;)
    {
    check_input();
    if (key_hit)
        {
        switch (key_in&0xff)
            {
            case '0':
                wst = 1;
                bst = 0;
                goto OUT;
            case '1':
                wst = 0;
                bst = 1;
                goto OUT;
            case '2':
                wst = 0;
                bst = 0;
                goto OUT;
            case '3':
                wst = 1;
                bst = 1;
                goto OUT;
            case 'q':
            case 'Q':
                outta_here();
            }
        }
    }
OUT:
/* erase menu part... */
for (i=13; i<19; i++)
    smessage("", 0, i);
show_mouse();
}


do_a_game()
{
hide_mouse();        /* Micky go bye-bye while drawing on screen */
clear_screen();        /* It all get's to be solid grey at first */
move_color = WHITE;    /* White will move first */
living[0] = living[1] = 16;    /* Both sides start with 16 pieces */
move_count = 0;        /* And no moves yet... */
init_board();
copy_structure(w_pieces, white_pieces, sizeof(white_pieces) );
copy_structure(b_pieces, black_pieces, sizeof(black_pieces) );
init_pieces(white_pieces);
init_pieces(black_pieces);
draw_board();
do_menu();
randseed = time_peek();    /* initialize randomizer with time so not always same*/
break_game = 0;
for (;;)
    {
    if (!some_move(wst))
        return;
    if (break_game)
        break;
    if (!some_move(bst))
        return;
    if (break_game)
        break;
    }
}


/* Heya, let's bail.  Cleanup mess we've made and return control to
   desktop or your favorite shell. */
outta_here()
{
uninit_sys();
exit(0);
}

main()
{
if (init_sys()< 0)
    outta_here();
for (;;)
    {
    do_a_game();
    }
}



