/* Streets and Alleys */
/* This is saa.c version 1.1 of 91/05/17. */

/* Streets and Alleys is a game of solitaire.  This implementation is
in ANSI C and uses the curses package.  You can play games with less
than fifty two cards by starting this program with a command line
argument giving the number of ranks to be used. */

static char copyright[] = "Copyright 1991 by John D. Ramsdell.";
/* Permission to use, copy, modify, and distribute this software and
its documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies.  John
Ramsdell makes no representations about the suitability of this
software for any purpose.  It is provided "as is" without express or
implied warranty.  */

static char what[] = "@(#)saa.c	1.1";

/* If your machine does not have an ANSI C compiler, but it does have
the curses package, there is a good chance you can get this program
running by defining NON_ANSI_C. */

#if defined NON_ANSI_C
#include <sys/types.h>
#else
#include <stdlib.h>
#endif
#include <time.h>
#include <curses.h>

/* If your compiler knows about inlining, don't define inline,
however, this program is so quick it really does not matter. */
#if !defined __GNU__ 
#define inline 
#endif

#define nranks 13
#define nsuits 4
#define ncards (nranks * nsuits)

#define minranks 5
/* Actual number of cards used in this game. */
int cards;
char *program_name;

/* Characters used to print suits. */
#define club 'C'
#define diamond 'D'
#define heart 'H'
#define spade 'S'

/* A card is a natural number less then fifty six. */
/* 0, 1, 2, and 3 are used for null cards. */

typedef int card_t;

static inline int card2rank(card)
     card_t card;
{
  return card / nsuits;
}
  
static inline int card2suit(card)
     card_t card;
{
  return card % nsuits;
}

card_t deck[ncards];

void shuffle()
{
  int i;
  time_t the_time;
  struct tm *now;
  unsigned int seed;
  if (time(&the_time) == (time_t) -1) {
    endwin();
    fprintf(stderr,
	    "%s:\tCannot initialize random number generator using the timer.\n",
	    program_name);
    exit (1);
  }
  now = localtime(&the_time);
  seed = now->tm_sec + 60 * now->tm_min + 60 * 60 * now->tm_hour;
  srand(seed);
  for (i = 0; i < cards; i++) deck[i] = i + nsuits;
  for (i = cards - 1; i > 0; i--) {
    int j = rand() % (i + 1);
    int k = deck[i];
    deck[i] = deck[j];
    deck[j] = k;
  }
}

/* A pile of cards is represented by a linked list. */
typedef struct card_cell {
  card_t card;
  struct card_cell *rest;
}  card_cell_t;

/* The card heap can be preallocated 
   because the number of cards is bounded. */
card_cell_t card_cell[ncards];

typedef card_cell_t *card_list_t;

#define NIL ((card_list_t) NULL)

card_list_t free_list;

void free_list_init()
{
  int i;
  free_list = card_cell;
  for (i = 0; i < ncards-1; i++)
    card_cell[i].rest = card_cell + i + 1;
  card_cell[ncards-1].rest = NIL;
}

card_list_t cons(card, list)
     card_t card;
     card_list_t list;
{
  card_list_t result = free_list;
  if (result == NIL) {
    endwin();
    fprintf(stderr, "%s:\tCannot get space.\n", program_name);
    exit (1);
  }
  else free_list = result->rest;
  result->card = card;
  result->rest = list;
  return result;
}

void dispose(list)
     card_list_t list;
{
  list->rest = free_list;
  free_list = list;
}

int length(list)
     card_list_t list;
{
  int len = 0;
  for(; list != NIL; list = list->rest, len++);
  return len;
}

/* The state of the game is given by the board. */ 
#define nstacks (2 * nsuits)

typedef struct {
  card_list_t stack[nstacks];
  card_t foundation[nsuits];
} board_t;
  
board_t board;

static inline void push_card(c, p)
     card_t c;
     int p;
{
  board.stack[p] = cons(c, board.stack[p]);
}

static inline int is_nil(p)
     int p;
{
  return board.stack[p] == NIL;
}

static inline card_t top_card(p)
     int p;
{
  return board.stack[p]->card;
}

static inline void pop_card(p)
     int p;
{
  card_list_t list = board.stack[p];
  board.stack[p] = list->rest;
  dispose(list);
}

static inline card_t foundation_ref(r)
     int r;
{
  return board.foundation[r];
}

static inline card_t foundation_set(r, c)
     int r;
     card_t c;
{
  board.foundation[r] = c;
}

void deal()
{
  int i; int j;
  free_list_init();
  shuffle();
  for (j = 0; j < nstacks; j++) board.stack[j] = NIL;
  for (j = 0; j < nsuits; j++) foundation_set(j, j);
  for (i = 0, j = 0; i < cards; i++, j = (j + 1) % nstacks)
    push_card(deck[i], j);
}

/* Procedures used in the display begin with "show_". */
  
void show_suit(suit)
  int suit;
{
  switch (suit) {
  case 0: addch(club); break;
  case 1: addch(diamond); break;
  case 2: addch(heart); break;
  case 3: addch(spade); break;
  default: addch('?'); break;
  }
}

void show_rank(rank)
     int rank;
{
  switch (rank) {
  case 0: addch('-'); break;
  case 1: addch('A'); break;
  case 2:
  case 3:
  case 4:
  case 5:
  case 6:
  case 7:
  case 8: 
  case 9: addch(rank+'0'); break;
  case 10: addch('T'); break;
  case 11: addch('J'); break;
  case 12: addch('Q'); break;
  case 13: addch('K'); break;
  default: addch('?');
  }
}

void show_card(card)
     card_t card;
{
  show_suit(card2suit(card));
  show_rank(card2rank(card));
}

/* Board display routines. */
#define prompt_height 1
#define status_height 1
#define command_height 2
#define board_height 19
#define title_height 1

#define stack_indent 12
#define card_size 6

int prompt_row, status_row, command_row, board_row, title_row;

void init_show()
{
  prompt_row = LINES - prompt_height;
  status_row = prompt_row - status_height;
  command_row = status_row - command_height;
  board_row = command_row - board_height;
  title_row = board_row - title_height;
}
  
void clear_status()
{
  move(status_row, stack_indent);
  clrtoeol();
}

void clear_prompt()
{
  move(prompt_row, stack_indent);
  clrtoeol();
}

void goto_stack_top(p, h)
     int p, h;
{
  move(command_row - h,
       stack_indent + card_size * (p + 1));
}

void goto_foundation(s)
     int s;
{
  goto_stack_top(-1, 2 * (s + 1));
}

void erase_top_of_stack(p)
     int p;
{
  int len = length(board.stack[p]);
  goto_stack_top(p, len);
  addstr("  ");
}

void show_top_of_stack(p)
     int p;
{
  int len = length(board.stack[p]);
  goto_stack_top(p, len);
  show_card(top_card(p));
}

void show_foundation(s)
     int s;
{
  goto_foundation(s);
  show_card(foundation_ref(s));
}

void show_board()
{
  int i; int len; card_list_t list;
  for (i = 0; i < nsuits; i++) show_foundation(i);
  for (i = 0; i < nstacks; i++) {
    list = board.stack[i];
    len = length(list);
    for (; list != NIL; list = list->rest, len--) {
      goto_stack_top(i, len);
      show_card(list->card);
    }
  }
}

int show_game()
{
  int i;
  clear();
  move(title_row, stack_indent);
  addstr("Streets and Alleys");
  show_board();
  move(command_row, 0);
  addstr("Commands:");
  for (i = -1; i < nstacks; i++) {
    goto_stack_top(i, 0);
    addch(i+'1');
    addch(',');
  }
  goto_stack_top(8, 0);
  addstr("q, r, or ?.");
  move(status_row, 0);
  addstr("Status:");
  clear_status();
  addstr("Fresh display.  Type ? for help.");
  move(prompt_row, 0);
  addstr("Prompt:");
  return 0;
}

char *help[] = {
  "\tStreets and Alleys version 1.1\n\n",
  "There are eight stacks of cards and a foundation for each suit.  A\n",
  "card may be moved from the top of a stack to its foundation or to\n",
  "the top of another stack.  The object of the game is to order the\n",
  "cards in each stack so that each card is covered only by cards of\n",
  "lesser rank. The ace has the smallest rank and the king has the\n",
  "greatest rank.\n",
  "\n",
  "A card may be moved to its foundation when the card's predecessor of\n",
  "the same suit is there.  A card may be moved to a stack when the top\n",
  "card of the stack has rank one greater than the card being moved.  A\n",
  "card can always be moved to an empty stack.\n",
  "\n",
  "Commands:\n",
  "\n",
  "  0\tSelect a foundation.\n",
  "  1-8\tSelect a stack.\n",
  "  q\tQuit the game.\n",
  "  r\tRefresh the display.\n",
  "  ?\tPrint this help.\n",
};
  
int show_help()
{
  char **h;
  clear();
  for (h = help; h < help + sizeof(help)/sizeof(char *); h++)
    addstr(*h);
  move(prompt_row, 0);
  addstr("Type any character to continue. ");
  refresh();
  (void) getch();
  return show_game();
}

int is_stack_done(p)
     int p;
{
  card_list_t list;
  if (is_nil(p)) return 1;
  for (list = board.stack[p]; list->rest != NIL; list = list->rest) 
    if (card2rank(list->card) >= card2rank(list->rest->card)) return 0;
  return 1;
}

int is_done()			/* The game is done when all cards */
{				/* have been moved to the foundation, */
  int i;			/* or every stack is ordered by rank. */
  for (i = 0; i < nstacks; i++)
    if (!is_stack_done(i)) return 0;
  return 1;
}

/* Procedures that read input and move cards. */

int move_to_foundation(from)
     int from;
{
  card_t c = top_card(from);
  int to = card2suit(c);
  if (c == nsuits + foundation_ref(to)) {
    erase_top_of_stack(from);
    pop_card(from);
    foundation_set(to, c);
    show_foundation(to);
    clear_status();
    addstr("The ");
    show_card(c);
    addstr(" was");
  }
  else {
    clear_status();
    addstr("The ");
    show_card(c);
    addstr(" cannot be");
  }
  addstr(" moved to the foundation.");
  return 0;
}

int move_to_stack(from, to)
     int from, to;
{
  card_t c = top_card(from);
  if (is_nil(to) || card2rank(top_card(to)) == 1 + card2rank(c)) {
    erase_top_of_stack(from);
    pop_card(from);
    push_card(c, to);
    show_top_of_stack(to);
    clear_status();
    addstr("Moved the ");
    show_card(c);
  }
  else {
    clear_status();
    addstr("The ");
    show_card(c);
    addstr(" cannot be moved");
  }
  addstr(" from stack ");
  addch(from+'1');
  addstr(" to stack ");
  addch(to+'1');
  addch('.');
  return 0;
}

int get_other_move(from)
     int from;
{
  int to;
  clear_prompt();
  addstr("Move ");
  show_card(top_card(from));
  addstr(" from stack ");
  addch(from+'1');
  addstr(" to ");
  refresh();
  to = getch();
  if (to == EOF || to == 'q') return 1;
  if (to == 'r') return show_game();
  if (to == '?') return show_help();
  to -= '1';
  clear_status();
  if (to < -1 || to >= 8) {
    addstr("Bad input.  Type ? for help.");
    return 0;
  }
  if (to == -1) return move_to_foundation(from);
  else return move_to_stack(from,to);
}

int get_move()
{
  int from;
  clear_prompt();
  addstr("Move from stack ");
  refresh();
  from = getch();
  if (from == EOF || from == 'q') return 1;
  if (from == 'r') return show_game();
  if (from == '?') return show_help();
  from -= '1';
  if (from < 0 || from >= 8) {
    clear_status();
    addstr("Bad input.  Type ? for help.");
    return 0;
  }
  if (is_nil(from)) {
    clear_status();
    addstr("There is no card in stack ");
    addch(from+'1');
    addch('.');
    return 0;
  }
  return get_other_move(from);
}

int play_one_game ()
{
  deal();
  (void) show_game();
  while (1)
    if (is_done()) return 0;
    else if (get_move()) return 1;
}      

void play()
{
  int ch, status;
  init_show();
  while (1) {
    status = play_one_game();
    clear_status();
    addstr(status == 0 ? "You won!" : "You lose.");
    clear_prompt();
    addstr("Press space to play again. ");
    refresh();
    ch = getch();
    if (ch != ' ') return;
  }
}

int usage()
{
  char **h;
  for (h = help; h < help + sizeof(help)/sizeof(char *); h++)
    fputs(*h, stderr);
  fprintf(stderr, "\nUsage:\t%s [number_of_ranks].\n", program_name);
  fprintf(stderr, "The number of ranks must be between %d and %d.\n",
	  minranks, nranks);
  return 1;
}
  
int main(argc, argv)
     int argc;
     char *argv[];
{
  program_name = argv[0];
  if (argc > 2) usage();
  if (argc == 2) {		/* Small game requested. */
    cards = atoi(argv[1]);
    if (cards < minranks || cards > nranks) return usage();
    cards *= nsuits;
  }
  else cards = ncards;
  if (ERR == initscr()) {
    fprintf(stderr, "%s:\tCannot initialize screen.\n", program_name);
    return 1;
  }
  cbreak();
  noecho();
  play();
  endwin();
  putchar('\n');
  return 0;
}
