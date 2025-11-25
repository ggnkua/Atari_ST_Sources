/* PUNSSi, my first 'Arcade' game in C :-)
 * Compile with: gcc -O punssi.c joyisr.s -o punssi.tos
 *
 * Punssi works in ST hi-rez ie.  monochrome.  Game should be easily
 * adaptable to other screen sizes and with a little more effort to
 * different color modes (preferably chunky).  Only functions init_game(),
 * exit_game(), main(), Get_key(), delay() and JoyISR() contain ST spesific
 * functions like Logbase and Physbase (get screen addresses), Get_rez (the
 * current rezolution), Kbdvbase (get keyboard vector table address), Ikbdws
 * (ask IKBD to report joystick state updates), Cursconf (dis/enable text
 * cursor), Supexec (exec function in processor Supervisor mode to access
 * system vector(s)), Cconis (check for a keypress), Crawcin (get a 'raw'
 * keycode), Setscreen (swap logical and physical screens), Vsync (wait for
 * vertical sync (screen refresh)), Dosound (sound effects with the sound
 * chip) system calls.
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
 *	Punssi (C) 1995 by Eero Tamminen (t150315@cc.tut.fi)
 */

#include <stdio.h>
#include <osbind.h>	/* OS calls */
#include <ostruct.h>	/* OS structures (_KBDVECS) */
#include <sysvars.h>	/* system variables (_hz_200) */
#include <memory.h>
#include <macros.h>	/* integer max() & min() */
#include "dosound.h"	/* sound effects */
#include "punssi.h"	/* definitions */

/* GLOBAL VARIABLES:
 *   joy_handle: original joystick handler address
 *   font:       game font address
 *   logical:    screen where things are drawn
 *   physical:   screen that is shown on monitor
 *   original:   original screen adddress(es)
 *   pics:       adress of game object images
 *   screen:     which screen
 */
void (*joy_handler);
char *font = NULL;
long *logical = NULL, *physical, *original, *pics = NULL;
int Screen;

/* GCC assembly code for receiving IKBD packets (joystick) */
volatile int JoyFlags[2] = {0, 0};
extern void JoyISR(void *);

/* FUNCTION PROTOTYPES */
int Get_key(void);
int game_event(int event);
char *mk_score(int score);
void write_msg(char *msg, int offset);
void game_messages(char **msg);
void delay(unsigned long sec);
void init_game(void);
void err_exit(int error);
void quit_game(void);
void init_object(Object *object, int w, int h, int min, int max);

void position(Object *object, short x, short y, short sx, short sy);
void get_bg(Object *object);
void put_bg(Object *object);
void put_object(Object *object);
void switch_screens(void);

void speed_to(Object *hunter, Object *target);
void slow_down(Object *object);
void direction(Object *object, int device);
short button(int device);

short collision(Object *object1, Object *object2);
short collide(Object *object1, Object *object2);
short check_walls(Object *object);

void next_move(Object *object);
void backup_pos(Object *object);
void new_pos(Object *object);


/* MAIN LOOP */
int main()
{
#define GOALS 2
#define OBJECTS	5
  Object object[OBJECTS + GOALS];
  short game_over, goal0, goal1;
  short i, speedball = 0;

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
    /* clear scores, show messages */
    game_event(GAME_START);

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
    for(i = 0; i < OBJECTS; i++)
    {
      new_pos(&object[i]);
      backup_pos(&object[i]);
      get_bg(&object[i]);
    }
    Screen = 0;
    for(i = 0; i < OBJECTS; i++)
    {
      backup_pos(&object[i]);
      get_bg(&object[i]);
    }

    game_over = 0;
    do
    {
      /* construct new objects onto the work screen */
      for(i = 0; i < OBJECTS; i++)
	put_bg(&object[i]);
      for(i = 0; i < OBJECTS; i++)
	get_bg(&object[i]);
      for(i = 0; i < OBJECTS; i++)
	put_object(&object[i]);

      /* swap work / display screens */
      switch_screens();

      /* Do object vertical and horizontal speed adjustments according to
       * the game logic (it) and user input (player joystick movements).
       */
      direction(&object[0], DEVICE_0);
      direction(&object[1], DEVICE_1);
      speed_to(&object[2], &object[0]);
      speed_to(&object[3], &object[1]);
      speedball = (speedball + 1) % 8;
      if(!speedball)
	slow_down(&object[4]);

      /* new fixed point object position for collision testing */
      for(i = 0; i < OBJECTS + GOALS; i++)
	next_move(&object[i]);

      /* goals */
      if((goal0 = collision(&object[4], &object[5])) ||
	 (goal1 = collision(&object[4], &object[6])))
      {
	Dosound(snd_Pieuw);
        position(&object[4], BALL_X, BALL_Y, +0, +0);
	if(goal0)
	  game_event(GAME_GOAL0);
	else
	  game_event(GAME_GOAL1);
      }
      /* bouncing from other objects */
      collide(&object[2], &object[3]);
      if(collide(&object[0], &object[1]))
	Dosound(snd_Klink);
      if(collide(&object[0], &object[4]) || collide(&object[1], &object[4]) ||
	 collide(&object[2], &object[4]) || collide(&object[3], &object[4]))
	Dosound(snd_Bumb);

      /* fatal collisions between player & droid */
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
      for(i = 0; i < OBJECTS; i++)
      {
	next_move(&object[i]);
        backup_pos(&object[i]);
	if(check_walls(&object[i]))
	  Dosound(snd_Ding);
	new_pos(&object[i]);
      }
    }
    /* until game over or key pressed */
    while(!(game_over || Cconis()));

    /* show the winner */
    game_event(GAME_OVER);

    /* restore backround */
    for(i = 0; i < OBJECTS; i++)
      put_bg(&object[i]);
    switch_screens();
    for(i = 0; i < OBJECTS; i++)
      put_bg(&object[i]);
    switch_screens();
  }
  return(0);

#undefine OBJECTS
#undefine GOALS
}

/* INTRO / SCORE STUFF */

/* return ASCII-keycode if available or zero */
int Get_key()
{
  return(Cconis() ? (Crawcin() & 0xFF) : 0);
}

/* increase and show / clear player scores */
int game_event(int event)
{
  static int score0, lives0, score1, lives1;
  char *live = "0\0", *msg[MESSAGES];

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
      game_messages(msg);

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
  return(!(lives0 && lives1));
}

/* convert a number to three digits. return the string. */
char *mk_score(int score)
{
  static char *string = "000\0";
  string[0] = score / 100 + '0';
  string[1] = score % 100 / 10 + '0';
  string[2] = score % 10 + '0';
  return(string);
}

/* write a message 'msg' at line MSG_LINE centered in 'font' */
void write_msg(char *msg, int offset)
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
void game_messages(char *msg[])
{
  int msg_num = 0;

  /* wait for button/key press to start */
  while(!(button(DEVICE_0) || button(DEVICE_1)))
  {
    write_msg(msg[msg_num], SCREEN_W - (strlen(msg[msg_num]) >> 1));
    delay(3UL);

    /* ESC quits */
    if(Get_key() == '\033')
      quit_game();

    /* next message */
    msg_num = (msg_num + 1) % MESSAGES;
  }
  while(button(DEVICE_0) || button(DEVICE_1));
}

/* wait until given amount of seconds has passed or button/key is pressed.
 */
unsigned long hz200;
void GetHz200() {hz200=*_hz_200;}

void delay(unsigned long sec)
{
  Supexec(GetHz200);
  sec = hz200 + sec * 200;
  while(hz200 < sec && !(Cconis() || button(DEVICE_0) || button(DEVICE_1)))
    Supexec(GetHz200);
}

/* INITIALIZATION AND EXIT FUNCTIONS */

/* allocate memory, load images, disable cursor */
void init_game()
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
  logical = (long *)((long)(logical + 256) & 0xffffff00);

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

  /* Install new joystick packet handler into keyboard vector table.  Tell
   * IKBD to send joystick packets.
   */
  table_addr = Kbdvbase();
  joy_handler = table_addr->joyvec;
  table_addr->joyvec = JoyISR;
  Ikbdws(0, "\024");

  /* cursor off, backround */
  Cursconf(0,0);
  memcpy(physical, logical, SCREEN_SIZE);
}

void err_exit(int error)
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
void quit_game()
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
  table_addr->joyvec = joy_handler;
  Ikbdws(0, "\010");

  Cursconf(1,0);
  exit(0);
}

/* OBJECT INITIALIZATIONS */

/* initalize game object image addresses, speed, co-ordinates etc. */
void init_object(Object *object, int h, int w, int min, int max)
{
  static int offset = 0;

  object->address = pics + PICS_L * offset;
  object->background = pics + PICS_L * offset + 16;
  offset += h;
  object->mask = pics + PICS_L * offset;
  object->masked = pics + PICS_L * offset + 16;
  offset += h;
  object->w = w;
  object->h = h;
  object->f_w = w << DIGITS;
  object->f_h = h << DIGITS;
  object->min = min;
  object->max = max;
}

void position(Object *object, short x, short y, short sx, short sy)
{
  object->f_px = x << DIGITS;
  object->f_py = y << DIGITS;
  object->f_sx = sx;
  object->f_sy = sy;
}

/* FUNCTIONS DEALING WITH SCREEN(S) */

/* backup the area that will be left under the image */
void get_bg(Object *object)
{
  long *src, *dst;
  int i;

  src = (long *)((short *)logical + object->y * SCREEN_W + object->x / 16);
  dst = object->background + Screen;
  for(i = 0;i < object->h; i++)
  {
    *dst = *src;
    src += SCREEN_L;
    dst += PICS_L;
  }
}

/* put back the area that was under the image */
void put_bg(Object *object)
{
  long *src, *dst;
  int i;

  src = object->background + Screen;
  if(Screen)
    dst = (long *)((short *)logical + object->y1 * SCREEN_W + object->x1 / 16);
  else
    dst = (long *)((short *)logical + object->y0 * SCREEN_W + object->x0 / 16);

  for(i = 0;i < object->h; i++)
  {
    *dst = *src;
    src += PICS_L;
    dst += SCREEN_L;
  }
}

/* put the image bitmap onto the work work screen */
void put_object(Object *object)
{
  long *src, *msk, *img;
  int i;

  /* get backround, mask it and add the pre-sifted image */
  src = (long *)((short *)logical + object->y * SCREEN_W + object->x / 16);
  img = object->address + object->x % 16;
  msk = object->mask + object->x % 16;
  for(i = 0;i < object->h; i++)
  {
    *src = (*src & *msk) | *img;
    img += PICS_L;
    msk += PICS_L;
    src += SCREEN_L;
  }
}

void switch_screens()
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

/* OBJECT MOVEMENTS: */

/* speeds hunter towards the target with the simple 'zombie' algorithm */
void speed_to(Object *hunter, Object *target)
{
  short check;

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
  hunter->f_sx = min(hunter->max, hunter->f_sx);
  hunter->f_sx = max(-hunter->max, hunter->f_sx);
  hunter->f_sy = min(hunter->max, hunter->f_sy);
  hunter->f_sy = max(-hunter->max, hunter->f_sy);
}

/* slow down the object if it moves */
void slow_down(Object *object)
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

/* return the state of the device button */
short button(int device)
{
  return(JoyFlags[device] & jBUTTON);
}

/* change object speed according to the device */
void direction(Object *object, int device)
{
  if(JoyFlags[device] & jUP)
    object->f_sy -= object->min;
  if(JoyFlags[device] & jDOWN)
    object->f_sy += object->min;
  if(JoyFlags[device] & jLEFT)
    object->f_sx -= object->min;
  if(JoyFlags[device] & jRIGHT)
    object->f_sx += object->min;

  /* keep speed within defined limits */
  object->f_sx = min(object->max, object->f_sx);
  object->f_sx = max(-object->max, object->f_sx);
  object->f_sy = min(object->max, object->f_sy);
  object->f_sy = max(-object->max, object->f_sy);
}

/* COLLISION DETECTIONS: */

/* check collisions between objects.  accurate only if objects are round.
 * return 1 for collision, 0 for miss.
 */
short collision(Object *object1, Object *object2)
{
  long hx, hy, r;

  /* difference between _centers_ = vector h */
  hx = object1->f_nx - object2->f_nx + ((object1->f_w - object2->f_w) >> 1);
  hy = object1->f_ny - object2->f_ny + ((object1->f_h - object2->f_h) >> 1);

  /* border value: summed 1&2 radiuses */
  r = (object1->f_w + object2->f_w) >> 1;

  /* check distance between centers */
  if(hx * hx + hy * hy <= (r * r))
    return(1);
  else
    return(0);
}

/* check collisions between objects and Calculate new speed vectors.
 * accurate only if objects are round.  return 1 for collision, 0 for miss.
 */
short collide(Object *object1, Object *object2)
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
    object1->f_sx += +c * hx / h2;
    object1->f_sy += +c * hy / h2;
    object2->f_sx += -c * hx / h2;
    object2->f_sy += -c * hy / h2;
    return(1);
  }
  else
    return(0);
}

/* check wall collisions */
short check_walls(Object *object)
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
    collide = 1;
  }
  else if(object->f_ny > SY2 - object->f_h)
  {
    object->f_sy = -object->f_sy;
    object->f_py = SY2 - object->f_h;
    collide = 1;
  }
  return(collide);
}

/* calculate new pixel position for testing it's validity and backup the old
 * position on the screen
 */
void next_move(Object *object)
{
  /* calculate new pos for collision checking */
  object->f_nx = object->f_px + object->f_sx;
  object->f_ny = object->f_py + object->f_sy;
}

/* store current place for backround restoring. */
void backup_pos(Object *object)
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

void new_pos(Object *object)
{
  /* new object place in fixed point */
  object->f_px += object->f_sx;
  object->f_py += object->f_sy;

  /* new object place in pixels (with rounding) */
  object->x = (object->f_px + (1 << (DIGITS >> 1))) >> DIGITS;
  object->y = (object->f_py + (1 << (DIGITS >> 1))) >> DIGITS;
}
