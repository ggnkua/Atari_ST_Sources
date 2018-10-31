/* PUNSSi, my first 'Arcade' game in C :-)
 *
 * Punssi works in ST hi-rez ie.  monochrome.  Game should be easily
 * adaptable to other screen sizes and with a little more effort to
 * different color modes (preferably chunky).  Only functions init_game(),
 * exit_game(), main(), delay() and JoyISR() contain ST spesific functions
 * like Logbase and Physbase (get screen addresses), Get_rez (the current
 * rezolution), Kbdvbase (get keyboard vector table address), Ikbdws (ask
 * IKBD to report joystick state updates), Cursconf (dis/enable text
 * cursor), Supexec (exec function in processor Supervisor mode to access
 * system vector(s)), Setscreen (swap logical and physical screens), Vsync
 * (wait for vertical sync (screen refresh)), Dosound (sound effects with
 * the sound chip) system calls.
 *
 * Notice that the empty space right of the pre-sifted images is used for
 * temporarily storing the part of the screen(s) that will be obscured by
 * the image and for composing the image put onto the screen.  This will
 * take two additional longs (lenght of all the object images, masks etc.
 * is one long.  This is for easing the screen output.  Height could be any
 * size).  Chunky mode graphics would be much easier as they wouldn't need
 * all that shifting stuff...
 *
 * Current image format is a monochrome bitmap data dump without a header.
 * Co-ordinate calculations are done in fixed point arithmetics for speed.
 *
 *	Punssi (C) 1995, 1997 by Eero Tamminen (t150315@cc.tut.fi)
 */

#include <stdio.h>
#ifdef __SOZOBONX__
#include <bios.h>
typedef KBDVECS _KBDVECS;
#else
#include <ostruct.h>	/* OS structures (_KBDVECS) */
#endif
#include <osbind.h>	/* OS calls */
#include <sysvars.h>	/* system variables (_hz_200) */
#include <malloc.h>
#include <mintbind.h>	/* signal handling */
#include <signal.h>	/* signal IDs */
#include "dosound.h"	/* sound effects */
#include "punssi.h"	/* game definitions */
#include "device.h"	/* io definitions */

#define MAX(x,y)   	(((x)>(y))?(x):(y))
#define	MIN(x,y)   	(((x)<(y))?(x):(y))

/* GLOBAL VARIABLES:
 *   key_handler:original key handler address
 *   font:       game font address
 *   logical:    screen where things are drawn
 *   physical:   screen that is shown on monitor
 *   original:   original screen adddress(es)
 *   pics:       adress of game object images
 *   screen:     which screen
 */
static void (*key_handler);
static long *logical = NULL, *physical, *original, *pics = NULL;
static char *font = NULL;
static int Screen;

/* GCC assembly code for receiving IKBD packets */
volatile long InputValue[2] = {0, 0};
extern long KeyISR(void);

/* FUNCTION PROTOTYPES */
static int game_event(int event);
static int game_messages(char **msg);
static char *mk_score(int score);
static void write_msg(char *msg, int offset);
static void delay(unsigned long sec);

static void init_game(void);
static void err_exit(int error);
static void quit_game(int sig);
static void init_object(Object *object, int w, int h, int min, int max);

static void position(Object *object, short x, short y, short sx, short sy);
static void get_bg(Object *object);
static void put_bg(Object *object);
static void put_object(Object *object);
static void switch_screens(void);

static void speed_to(Object *hunter, Object *target);
static void slow_down(Object *object);

static void direction(Object *object, int device);
static int button(int device);
static int ifexit(void);

static int collision(Object *object1, Object *object2);
static int collide(Object *object1, Object *object2);
static int check_walls(Object *object);

static void next_move(Object *object);
static void backup_pos(Object *object);
static void new_pos(Object *object);


/* MAIN LOOP */
int main(int argc, char *argv[])
{
#define GOALS 2
#define OBJECTS	5
  Object object[OBJECTS + GOALS];

  /* Init globals, load images etc. */
  init_game();

  /* Image, mask, backup image addresses, size and speed limits NOTICE:
   * images have to be initialized in the order that they are on the pics
   * picture (everything followed with masks) and speed values have to
   * fulfill:  abs(value) <= (1 << DIGITS).
   */
  init_object(&object[0], PLAYER, PLAYER, MIN_PLAYER, MAX_PLAYER);
  init_object(&object[1], PLAYER, PLAYER, MIN_PLAYER, MAX_PLAYER);
  init_object(&object[2], DROID, DROID, MIN_DROID, MAX_DROID);
  init_object(&object[3], DROID, DROID, MIN_DROID, MAX_DROID);
  init_object(&object[4], BALL, BALL, MIN_PLAYER, MAX_PLAYER);
  /* bogus image addresses (real ones on the backround) */
  init_object(&object[5], GOAL, GOAL, 0, 0);
  init_object(&object[6], GOAL, GOAL, 0, 0);

  while(1)
  {
    int i, game_over, goal0, goal1, players, speedball = 0;

    /* clear scores, show messages */
    players = game_event(GAME_START) - 1;

    /* initial x&y positions and speeds */
    position(&object[0], PLAYER0_X, PLAYER0_Y, 0, 0);
    position(&object[1], PLAYER1_X, PLAYER1_Y, 0, 0);
    position(&object[2], DROID0_X, DROID0_Y, 0, 0);
    position(&object[3], DROID1_X, DROID1_Y, 0, 0);
    position(&object[4], BALL_X, BALL_Y, 0, 0);
    position(&object[5], GOAL0_X, GOAL0_Y, 0, 0);
    position(&object[6], GOAL1_X, GOAL1_Y, 0, 0);

    /* get initial background images */
    Screen = 1;
    for(i = players; i < OBJECTS; i++)
    {
      new_pos(&object[i]);
      backup_pos(&object[i]);
      get_bg(&object[i]);
    }
    Screen = 0;
    for(i = players; i < OBJECTS; i++)
    {
      backup_pos(&object[i]);
      get_bg(&object[i]);
    }

    game_over = 0;
    do
    {
      /* construct new objects onto the work screen */
      for(i = players; i < OBJECTS; i++)
	put_bg(&object[i]);
      for(i = players; i < OBJECTS; i++)
	get_bg(&object[i]);
      for(i = players; i < OBJECTS; i++)
	put_object(&object[i]);

      /* swap work / display screens */
      switch_screens();

      /* Do object vertical and horizontal speed adjustments according to
       * the game logic (it) and user input (player joystick movements).
       */
      if(players == 0)				/* player 0 too */
      {
        direction(&object[0], DEVICE_0);
        speed_to(&object[2], &object[0]);
      }
      else					/* only one player */
        speed_to(&object[2], &object[3]);	/* droid follows droid */
      direction(&object[1], DEVICE_1);
      speed_to(&object[3], &object[1]);
      speedball = (speedball + 1) % 8;
      if(!speedball)
	slow_down(&object[4]);

      /* new fixed point object position for collision testing */
      for(i = players; i < OBJECTS + GOALS; i++)
	next_move(&object[i]);

      /* goals */
      if((goal0 = collision(&object[4], &object[5])) ||
	 (goal1 = collision(&object[4], &object[6])))
      {
	Dosound(snd_Pieuw);
        position(&object[4], BALL_X, BALL_Y, 0, 0);
	if(goal0)
	  game_event(GAME_GOAL0);
	else
	  game_event(GAME_GOAL1);
      }
      /* bouncing from other objects */
      collide(&object[2], &object[3]);
      if(players == 0 && collide(&object[0], &object[1]))
	Dosound(snd_Klink);
      if(collide(&object[2], &object[4]) ||
         collide(&object[3], &object[4]) ||
         collide(&object[1], &object[4]) ||
	(players == 0 && collide(&object[0], &object[4])))
	Dosound(snd_Bumb);

      /* fatal collisions between player & droid */
      if(players == 0)
      {
	if(collision(&object[0], &object[2]))
	{
	  Dosound(snd_Pox);
	  game_over |= game_event(GAME_CRASH0);
	  position(&object[0], PLAYER0_X, PLAYER0_Y, 0, 0);
	  position(&object[2], object[3].x, object[3].y, 0, 0);
	}
	if(collision(&object[0], &object[3]))
	{
	  Dosound(snd_Pox);
	  game_over |= game_event(GAME_CRASH0);
	  position(&object[0], PLAYER0_X, PLAYER0_Y, 0, 0);
	  position(&object[3], object[2].x, object[2].y, 0, 0);
	}
      }
      if(collision(&object[1], &object[2]))
      {
        Dosound(snd_Pox);
	game_over |= game_event(GAME_CRASH1);
        position(&object[1], PLAYER1_X, PLAYER1_Y, 0, 0);
	position(&object[2], object[3].x, object[3].y, 0, 0);
      }
      if(collision(&object[1], &object[3]))
      {
        Dosound(snd_Pox);
	game_over |= game_event(GAME_CRASH1);
        position(&object[1], PLAYER1_X, PLAYER1_Y, 0, 0);
	position(&object[3], object[2].x, object[2].y, 0, 0);
      }
      /* new fixed point object positions, backup position on current
       * buffer, check wall collisions and calculate new pixel positions.
       */
      for(i = players; i < OBJECTS; i++)
      {
	next_move(&object[i]);
        backup_pos(&object[i]);
	if(check_walls(&object[i]))
	  Dosound(snd_Ding);
	new_pos(&object[i]);
      }
      if(ifexit())
        quit_game(0);
    }
    /* until game over */
    while(!game_over);

    /* show the winner */
    game_event(GAME_OVER);

    /* restore backround */
    for(i = players; i < OBJECTS; i++)
      put_bg(&object[i]);
    switch_screens();
    for(i = players; i < OBJECTS; i++)
      put_bg(&object[i]);
    switch_screens();
  }
  return 0;

#undef OBJECTS
#undef GOALS
}

/* INTRO / SCORE STUFF */

/* increase and show / clear player scores */
static int game_event(int event)
{
  static int score0, lives0, score1, lives1;
  char *live = "0\0", *msg[MESSAGES];
  int butt = 0;

  switch(event)
  {
    case GAME_GOAL0:
      score0 += 3;
      write_msg(mk_score(score0), OFF_S0);
      break;
    case GAME_GOAL1:
      score1 += 3;
      write_msg(mk_score(score1), OFF_S1);
      break;
    case GAME_CRASH0:
      lives0--;
      live[0] = '0' + lives0;
      write_msg(live, OFF_L0);
      score1++;
      write_msg(mk_score(score1), OFF_S1);
      break;
    case GAME_CRASH1:
      lives1--;
      live[0] = '0' + lives1;
      write_msg(live, OFF_L1);
      score0++;
      write_msg(mk_score(score0), OFF_S0);
      break;
    case GAME_START:
      /* wait until game started or quit */
      msg[0] = MSG_COPYRIGHT;
      msg[1] = MSG_HELP;
      butt = game_messages(msg);

      score0 = score1 = 0;
      lives0 = lives1 = LIVES;
      live[0] = '0' + LIVES;
      write_msg(live, OFF_L0);
      write_msg(live, OFF_L1);
      write_msg(CLEAR_SCORE, OFF_CLEAR);
      break;
    case GAME_OVER:
      /* who won / lost */
      score0 = score0 + lives0;
      score1 = score1 + lives1;
      write_msg(mk_score(score0), OFF_S0);
      write_msg(mk_score(score1), OFF_S1);
      if((score0 > score1) || (score0 == score1 && lives0))
      {
	msg[0] = MSG_WINNER0;
	msg[1] = MSG_LOSER1;
      }
      else
      {
	msg[0] = MSG_WINNER1;
	msg[1] = MSG_LOSER0;
      }
      game_messages(msg);
      break;
  }
  return (!(lives0 && lives1) | butt);
}

/* convert a number to three digits. return the string. */
static char *mk_score(int score)
{
  static char *string = "000\0";
  string[0] = score / 100 + '0';
  string[1] = score % 100 / 10 + '0';
  string[2] = score % 10 + '0';
  return string;
}

/* write a message 'msg' at line MSG_LINE centered in 'font' */
static void write_msg(char *msg, int offset)
{
  char *address;
  int i, c, row, len;

  len = strlen(msg);
  /* to both screens */
  for(i = 0; i < 2; i++)
  {
    for(row = 0; row < 16; row++)
    {
      address = (char *)(logical + (row + MSG_LINE) * SCREEN_L) + offset;
      for(c = 0; c < len; c++)
        *(address++) = *(font + msg[c] + 256 * row);
    }
    switch_screens();
  }
}

/* tell the rules & other stuff */
static int game_messages(char *msg[])
{
  int msg_num = 0, butt = 0;

  /* wait for button/key press to start */
  while(!((butt |= button(DEVICE_0)) || (butt |= button(DEVICE_1))))
  {
    write_msg(msg[msg_num], SCREEN_W - (strlen(msg[msg_num]) >> 1));
    delay(3UL);

    /* ESC quits */
    if(ifexit())
      quit_game(0);

    /* next message */
    msg_num = (msg_num + 1) % MESSAGES;
  }

  while(button(DEVICE_0) || button(DEVICE_1));
  return butt;
}

/* wait until given amount of seconds has passed or button/key is pressed.
 */
static unsigned long hz200;
static void GetHz200(void) {hz200=*_hz_200;}

static void delay(unsigned long sec)
{
  Supexec(GetHz200);
  sec = hz200 + sec * 200;
  while(hz200 < sec && !(ifexit() || button(DEVICE_0) || button(DEVICE_1)))
    Supexec(GetHz200);
}

/* INITIALIZATION AND EXIT FUNCTIONS */

/* allocate memory, load images, disable cursor */
static void init_game(void)
{
  FILE *fp0 = NULL, *fp1 = NULL, *fp2 = NULL;
  _KBDVECS *table_addr;

  if(Getrez() != RESOLUTION)
    err_exit(ERR_REZ);

  /* screen bitmap address */
  original = physical = Logbase();
  if(physical != Physbase())
    err_exit(ERR_SCREEN);

  /* allocate memory for the game images */
  if(!((font = malloc(FONT_SIZE)) && (pics = malloc(PICS_SIZE))
    && (logical = malloc(SCREEN_SIZE + 256))))
  {
    free(pics);
    free(font);
    free(logical);
    err_exit(ERR_MEM);
  }
  /* onto 256 byte boundary */
  logical = (long *)((long)(logical + 256) & 0xffffff00L);

  /* read game font, images and background */
  if(!((fp0 = fopen(FONT_FILE, "rb")) && (fp1 = fopen(PICS_FILE, "rb"))
    && (fp2 = fopen(BG_FILE, "rb"))))
  {
    fclose(fp2);
    fclose(fp1);
    fclose(fp0);
    free(logical);
    free(pics);
    free(font);
    err_exit(ERR_FILE);
  }
  fread(font, 1, FONT_SIZE, fp0);
  fread(pics, 1, PICS_SIZE, fp1);
  fread(logical, 1, SCREEN_SIZE, fp2);
  fclose(fp2);
  fclose(fp1);
  fclose(fp0);

  /* cursor off, backround (void cast just to prevent warning) */
  (void)Cursconf(0, 0);

  /* MiNT: on a case of an exiting request, restore system variables */
  signal(SIGHUP, quit_game);
  signal(SIGINT, quit_game);
  signal(SIGQUIT, quit_game);
  signal(SIGTERM, quit_game);

  /* Install new joystick packet handler into keyboard vector table.
   * Turn mouse off and tell IKBD to send joystick packets.
   */
  table_addr = Kbdvbase();
  key_handler = table_addr->ikbdsys;	/* earlier handler: ->joyvec */
  table_addr->ikbdsys = KeyISR;
  Ikbdws(1, "\022\024");

  memcpy(physical, logical, SCREEN_SIZE);
}

static void err_exit(int error)
{
  char *msg;

  switch(error)
  {
    case ERR_REZ:
      msg = "Not ST hi-rez\n";
      break;
    case ERR_MEM:
      msg = "Not enough memory\n";
      break;
    case ERR_FILE:
      msg = "File error\n";
      break;
    case ERR_SCREEN:
      msg = "Can't switch screens\n";
      break;
    default:
      msg = "Unknown error\n";
  }
  fputs(msg, stderr);
  exit(1);
}

/* free memory, reset screen, enable cursor, reset repeat rate */
static void quit_game(int sig)
{
  _KBDVECS *table_addr;

  if(logical == original)
    free(physical);
  else
    free(logical);
  free(pics);
  free(font);
  Setscreen(original, original, -1);

  table_addr = Kbdvbase();
  table_addr->ikbdsys = key_handler;	/* earlier handler: ->joyvec */
  Ikbdws(1, "\025\010");

  (void)Cursconf(1, 0);
  Dosound(snd_off);
  exit(0);
}

/* OBJECT INITIALIZATIONS */

/* initalize game object image addresses, speed, co-ordinates etc. */
static void init_object(Object *object, int h, int w, int min, int max)
{
  static int offset = 0;

  object->address = pics + PICS_L * offset;
  object->background = pics + PICS_L * offset + 16;
  offset += h;
  object->mask = pics + PICS_L * offset;
  offset += h;
  object->w = w;
  object->h = h;
  object->f_w = w << DIGITS;
  object->f_h = h << DIGITS;
  object->min = min;
  object->max = max;
}

static void position(Object *object, short x, short y, short sx, short sy)
{
  object->f_px = x << DIGITS;
  object->f_py = y << DIGITS;
  object->f_sx = sx;
  object->f_sy = sy;
}

/* FUNCTIONS DEALING WITH SCREEN(S) */

/* backup the area that will be left under the image */
static void get_bg(Object *object)
{
  long *src, *dst;
  int i;

  src = (long *)((short *)logical + object->y * SCREEN_W + (object->x >> 4));
  dst = object->background + Screen;
  for(i = 0;i < object->h; i++)
  {
    *dst = *src;
    src += SCREEN_L;
    dst += PICS_L;
  }
}

/* store current place for backround restoring. */
static void backup_pos(Object *object)
{
  if(Screen)
  {
    object->x0 = object->x;
    object->y0 = object->y;
  }
  else
  {
    object->x1 = object->x;
    object->y1 = object->y;
  }
}

/* put back the area that was under the image */
static void put_bg(Object *object)
{
  long *src, *dst;
  int i;

  src = object->background + Screen;
  if(Screen)
    dst = (long *)((short *)logical + object->y1 * SCREEN_W + (object->x1 >> 4));
  else
    dst = (long *)((short *)logical + object->y0 * SCREEN_W + (object->x0 >> 4));

  for(i = 0;i < object->h; i++)
  {
    *dst = *src;
    src += PICS_L;
    dst += SCREEN_L;
  }
}

/* put the image bitmap onto the work work screen */
static void put_object(Object *object)
{
  long *src, *msk, *img;
  int i;

  /* get backround, mask it and add the pre-sifted image */
  src = (long *)((short *)logical + object->y * SCREEN_W + (object->x >> 4));
  img = object->address + (object->x % 16);
  msk = object->mask + (object->x % 16);
  for(i = 0;i < object->h; i++)
  {
    *src = (*src & *msk) | *img;
    img += PICS_L;
    msk += PICS_L;
    src += SCREEN_L;
  }
}

static void switch_screens(void)
{
  long *temporal;

  /* Wait for the vertical blanc and switch work / displayed screens */
  if(Screen)
    Screen = 0;
  else
    Screen = 1;
  Setscreen(physical, logical, -1);
  Vsync();
  temporal = logical;
  logical  = physical;
  physical = temporal;
}

/* FUNCTIONS DEALING WITH BOTH THE PIXEL AND FIXED POINT CO-ORDINATES */

/* OBJECT MOVEMENTS */

/* speeds hunter towards the target with the simple 'zombie' algorithm */
static void speed_to(Object *hunter, Object *target)
{
  int check;

  /* if away from target (check from center point), move closer.
   * will bounce along ;-)
   */
  check = hunter->x + (hunter->w >> 1) -
          target->x - (target->w >> 1);
  if(check)
    if(check < 0)
      hunter->f_sx += hunter->min;
    else
      hunter->f_sx -= hunter->min;

  check = hunter->y + (hunter->h >> 1) -
          target->y - (target->h >> 1);
  if(check)
    if(check < 0)
      hunter->f_sy += hunter->min;
    else
      hunter->f_sy -= hunter->min;

  /* keep speed within defined limits */
  hunter->f_sx = MIN(hunter->max, hunter->f_sx);
  hunter->f_sx = MAX(-hunter->max, hunter->f_sx);
  hunter->f_sy = MIN(hunter->max, hunter->f_sy);
  hunter->f_sy = MAX(-hunter->max, hunter->f_sy);
}

/* slow down the object if it moves */
static void slow_down(Object *object)
{
  if(object->f_sx)
    if(object->f_sx < 0)
      object->f_sx += object->min;
    else
      object->f_sx -= object->min;
  if(object->f_sy)
    if(object->f_sy < 0)
      object->f_sy += object->min;
    else
      object->f_sy -= object->min;
}

/* INPUT/DEVICE HANDLING */

/* if fire, return the button index */
static int button(int device)
{
  return (InputValue[device] & jBUTTON ? ++device : 0);
}

/* if exit key pressed... */
static int ifexit(void)
{
  return (InputValue[DEVICE_0] == jEXIT || InputValue[DEVICE_1] == jEXIT);
}

/* change object speed according to the device */
static void direction(Object *object, int device)
{
  if(InputValue[device] & jUP)
    object->f_sy -= object->min;
  if(InputValue[device] & jDOWN)
    object->f_sy += object->min;
  if(InputValue[device] & jLEFT)
    object->f_sx -= object->min;
  if(InputValue[device] & jRIGHT)
    object->f_sx += object->min;

  /* keep speed within defined limits */
  object->f_sx = MIN(object->max, object->f_sx);
  object->f_sx = MAX(-object->max, object->f_sx);
  object->f_sy = MIN(object->max, object->f_sy);
  object->f_sy = MAX(-object->max, object->f_sy);
}

/* COLLISION DETECTIONS */

/* check collisions between objects.  accurate only if objects are round.
 * return 1 for collision, 0 for miss.
 */
static int collision(Object *object1, Object *object2)
{
  long hx, hy, r;

  /* difference between _centers_ = vector h */
  hx = object1->f_nx - object2->f_nx + ((object1->f_w - object2->f_w) >> 1);
  hy = object1->f_ny - object2->f_ny + ((object1->f_h - object2->f_h) >> 1);

  /* border value: summed 1&2 radiuses */
  r = (object1->f_w + object2->f_w) >> 1;

  /* check distance between centers */
  if(hx * hx + hy * hy <= (r * r))
    return 1;
  else
    return 0;
}

/* check collisions between objects and Calculate new speed vectors.
 * accurate only if objects are round.  return 1 for collision, 0 for miss.
 */
static int collide(Object *object1, Object *object2)
{
  long hx, hy, h2, a, b, c;

  /* difference between _centers_ = vector h */
  hx = object1->f_nx - object2->f_nx + ((object1->f_w - object2->f_w) >> 1);
  hy = object1->f_ny - object2->f_ny + ((object1->f_h - object2->f_h) >> 1);
  /* |h|^2 for vector h */
  h2 = hx * hx + hy * hy;

  /* border value: summed 1&2 radiuses */
  a = (object1->f_w + object2->f_w) >> 1;

  /* check distance between centers */
  if(h2 <= (a * a))
  {
    /* totally bouncy :-)
     * project object 1&2 vectors to h (O1h & O2h),
     * new direction / speed: O1 = O1 + O2h - O1h
     */
    a = (object1->f_sx * hx + object1->f_sy * hy);
    b = (object2->f_sx * hx + object2->f_sy * hy);
    c = b - a;
    /* make sure the vector is away
     * from the collision!
     */
    if(c < 0)
      c = -c;
    object1->f_sx +=  c * hx / h2;
    object1->f_sy +=  c * hy / h2;
    object2->f_sx += -c * hx / h2;
    object2->f_sy += -c * hy / h2;
    return 1;
  }
  else
    return 0;
}

/* check wall collisions */
static int check_walls(Object *object)
{
  short collide = 0;

  /* collisions with walls */
  if(object->f_nx < SX1)
  {
    object->f_sx = -object->f_sx;
    object->f_px = SX1;
    slow_down(object);
    collide = 1;
  }
  else if(object->f_nx > SX2 - object->f_w)
  {
    object->f_sx = -object->f_sx;
    object->f_px = SX2 - object->f_w;
    slow_down(object);
    collide = 1;
  }
  if(object->f_ny < SY1)
  {
    object->f_sy = -object->f_sy;
    object->f_py = SY1;
    slow_down(object);
    collide = 1;
  }
  else if(object->f_ny > SY2 - object->f_h)
  {
    object->f_sy = -object->f_sy;
    object->f_py = SY2 - object->f_h;
    slow_down(object);
    collide = 1;
  }
  return collide;
}

/* calculate new pixel position for testing it's validity and backup the old
 * position on the screen
 */
static void next_move(Object *object)
{
  /* calculate new pos for collision checking */
  object->f_nx = object->f_px + object->f_sx;
  object->f_ny = object->f_py + object->f_sy;
}

static void new_pos(Object *object)
{
  /* new object place in fixed point */
  object->f_px += object->f_sx;
  object->f_py += object->f_sy;

  /* new object place in pixels (with rounding) */
  object->x = (object->f_px + (1 << (DIGITS >> 1))) >> DIGITS;
  object->y = (object->f_py + (1 << (DIGITS >> 1))) >> DIGITS;
}
