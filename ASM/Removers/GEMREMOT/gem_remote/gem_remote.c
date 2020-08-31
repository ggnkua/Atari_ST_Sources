#include "generic_list.h"
#include <string.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include <sys/time.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <X11/keysymdef.h>
#include <X11/keysym.h>
#include <X11/extensions/XTest.h>
//static char reponse[256];
static int lg=sizeof(struct sockaddr_in);

#define bool int
#define true 1
#define false 0

#define MOUSE_MOTION 0
#define BUTTON_PRESSED 1
#define BUTTON_RELEASED 2
#define KBD_PRESS 3
#define KBD_RELEASE 4

#define MAX_LENGTH_MSG 16

#define USEC_WAIT 20000

#define BORD 50

unsigned int QuitKey = 9; // Escape

char msg[MAX_LENGTH_MSG];

typedef struct gem_remote_event {
  int type;
  int rel_x;
  int rel_y;
  int button;
  int scan_code;
} gem_remote_event;

typedef struct kbd_assoc {
  char *keysymstring;
  int scan_code;
} kbd_assoc;

PROTOLIST(struct kbd_assoc *,kbd_assoc_list)

DEFLIST(struct kbd_assoc *,kbd_assoc_list)

kbd_assoc_list scancodes;

/*******************************************
 * ecrit un entier 16 bits dans une chaine *
 *******************************************/
char *int_to_msg(int n,char *msg) {
  *msg++ = (n >> 8) & 0xff;
  *msg++ = n & 0xff;
  return msg;
}

/**************************************
 * transforme un gem_event en message *
 **************************************/
int gem_event_to_msg(char *msg,struct gem_remote_event *gem_event) {
  char *start = msg;
  switch(gem_event->type) {
  case MOUSE_MOTION:
    msg = int_to_msg(4*2,msg);
    msg = int_to_msg(gem_event->type,msg);
    msg = int_to_msg(gem_event->rel_x,msg);
    msg = int_to_msg(gem_event->rel_y,msg);
    break;
  case BUTTON_PRESSED:
  case BUTTON_RELEASED:
    msg = int_to_msg(3*2,msg);
    msg = int_to_msg(gem_event->type,msg);
    msg = int_to_msg(gem_event->button,msg);
    break;
  case KBD_PRESS:
  case KBD_RELEASE:
    msg = int_to_msg(3*2,msg);
    msg = int_to_msg(gem_event->type,msg);
    msg = int_to_msg(gem_event->scan_code,msg);
    break;
  }
  return (msg-start);
}

#define SHIFTL 0x2a
#define SHIFTR 0x36
#define ALT 0x38

#define SHIFTL_BIT 0x1
#define SHIFTR_BIT 0x2
#define ALT_BIT 0x4

void set_special_keys(int scan_code,int *special_keys) {
  int scan;
  scan = scan_code & 0xff;
  switch(scan) {
  case SHIFTL:
    (*special_keys)|=SHIFTL_BIT;
    break;
  case SHIFTR:
    (*special_keys)|=SHIFTR_BIT;
    break;
  case ALT:
    (*special_keys)|=ALT_BIT;
    break;
  }
}

void clear_special_keys(int scan_code,int *special_keys) {
  int scan;
  scan = scan_code & 0xff;
  switch(scan) {
  case SHIFTL:
    (*special_keys)&=~SHIFTL_BIT;
    break;
  case SHIFTR:
    (*special_keys)&=~SHIFTR_BIT;
    break;
  case ALT:
    (*special_keys)&=~ALT_BIT;
    break;
  }
}

/**************************
 * ouvre le display local *
 **************************/
Display * localDisplay () {
  // open the display
  Display * D = XOpenDisplay ( 0 );
  // did we get it?
  if ( ! D ) {
        // nope, so show error and abort
    fprintf(stderr,"can't open display %s \n",XDisplayName(0));
    exit(EXIT_FAILURE);
  }
  // return the display
  return D;
}

/***********************************
 * envoie un message sur le réseau *
 ***********************************/
void send_msg(int sock,struct sockaddr_in *adresse,char *msg,int len) {
  if(len > 0) {
    sendto(sock,msg,len,0,(struct sockaddr *)adresse,lg);
  }
}

void press_special_keys(int sock,struct sockaddr_in *adresse,int code,int special_keys) {
  int len=0;
  struct gem_remote_event aux_event;
  if(code & 0x1) {
    if(!(special_keys & SHIFTL_BIT)) {
      aux_event.type = KBD_PRESS;
      aux_event.scan_code = SHIFTL;
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);
    }
  } else {
    if(special_keys & SHIFTL_BIT) {
      aux_event.type = KBD_RELEASE;
      aux_event.scan_code = SHIFTL; /* shift gauche */
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);      
    }
    if(special_keys & SHIFTR_BIT) {
      aux_event.type = KBD_RELEASE;
      aux_event.scan_code = SHIFTR; /* shift droit */
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);      
    }
  }
  if(code & 0x2) {
    if(!(special_keys & ALT_BIT)) {
      aux_event.type = KBD_PRESS;
      aux_event.scan_code = ALT; /* alt */
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);
    }
  } else {
    if(special_keys & ALT_BIT) {
      aux_event.type = KBD_RELEASE;
      aux_event.scan_code = ALT; /* alt */
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);
    }
  }
}

void release_special_keys(int sock,struct sockaddr_in *adresse,int code,int special_keys) {
  int len=0;
  struct gem_remote_event aux_event;
  if(code & 0x1) {
    if(!(special_keys & SHIFTL_BIT)) {
      aux_event.type = KBD_RELEASE;
      aux_event.scan_code = SHIFTL;
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);
    }
  } else {
    if(special_keys & SHIFTL_BIT) {
      aux_event.type = KBD_PRESS;
      aux_event.scan_code = SHIFTL; /* shift gauche */
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);      
    }
    if(special_keys & SHIFTR_BIT) {
      aux_event.type = KBD_PRESS;
      aux_event.scan_code = SHIFTR; /* shift droit */
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);      
    }
  }
  if(code & 0x2) {
    if(!(special_keys & ALT_BIT)) {
      aux_event.type = KBD_RELEASE;
      aux_event.scan_code = ALT; /* alt */
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);
    }
  } else {
    if(special_keys & ALT_BIT) {
      aux_event.type = KBD_PRESS;
      aux_event.scan_code = ALT; /* alt */
      len=gem_event_to_msg(msg,&aux_event);
      send_msg(sock,adresse,msg,len);
    }
  }
}

/**********************************************
 * affiche un évènement tel qu'il sera envoyé *
 **********************************************/
void show_gem_remote_event(struct gem_remote_event *gem_event) {
  switch(gem_event->type) {
  case MOUSE_MOTION:
    fprintf(stdout,"mouse motion %d %d\n",gem_event->rel_x,gem_event->rel_y);
    break;
  case BUTTON_PRESSED:
    fprintf(stdout,"mouse button pressed %d\n",gem_event->button);
    break;
  case BUTTON_RELEASED:
    fprintf(stdout,"mouse button released %d\n",gem_event->button);
    break;
  case KBD_PRESS:
    fprintf(stdout,"key pressed %d\n",gem_event->scan_code);
    break;
  case KBD_RELEASE:
    fprintf(stdout,"key released %d\n",gem_event->scan_code);
    break;
  }
}

/***********************************************
 * traduction vers les boutons de souris Atari *
 ***********************************************/
int translate_button(int button) {
  switch(button) {
  case 1:
    return 1;
    break;
  case 2:
    return 3;
    break;
  case 3:
    return 2;
    break;
  default:
    return 0;
    break;
  }
}

/*************************************
 * obtient le scan code d'une touche *
 *************************************/
int get_scan_code(XKeyEvent *Event,Display *LocalDpy,const unsigned int Code) {
  KeySym keysym;
  char Buffer[64];
  char *keysymstring;
  kbd_assoc_list scans;
  struct kbd_assoc *assoc;

  // perform lookup of the keycode
  XLookupString ( Event, Buffer, 64, &keysym, 0 );

  // map the keysym to a string. The string is from <X11/keysymdef.h> and is without the
  // prefix XK_, thus being suitable for saving
  keysymstring = XKeysymToString ( keysym );
  
  scans=scancodes;
  while(!is_empty_kbd_assoc_list(scans)) {
    assoc=kbd_assoc_list_car(scans);
    scans=kbd_assoc_list_cdr(scans);
    if(strcmp(keysymstring,assoc->keysymstring) == 0) {
      return assoc->scan_code;
    }
  }
  return -1;
}

/*********************
 * boucle principale *
 *********************/
void eventLoop(int sock,struct sockaddr_in *adresse,Display *LocalDpy,int LocalScreen) {
  int Status1, Status2;
  bool Loop = true;
  XEvent Event;
  Window Root;
  XButtonEvent EButton;
  XMotionEvent EMotion;
  XKeyEvent EKey;
  struct gem_remote_event gem_event;
  int special_keys = 0;
  int len=0;

  bool old_coords_initialized = false;
  int delta_x=0;
  int delta_y=0;
  int old_x=0;
  int old_y=0;

  struct timeval tempo;
  int microsec,sec;

  int screen_width;
  int screen_height;

  gettimeofday(&tempo,NULL);
  microsec=tempo.tv_usec;
  sec=tempo.tv_sec;

  // get the root window and set default target
  Root = RootWindow(LocalDpy,LocalScreen);
  screen_width = DisplayWidth(LocalDpy,LocalScreen);
  screen_height = DisplayHeight(LocalDpy,LocalScreen);

  // grab the pointer
  Status1 = XGrabPointer(LocalDpy,Root,False,PointerMotionMask|ButtonPressMask|ButtonReleaseMask,GrabModeSync,GrabModeAsync,Root,None,CurrentTime);

  // grab the keyboard
  Status2 = XGrabKeyboard(LocalDpy,Root,False,GrabModeSync,GrabModeAsync,CurrentTime);
  // did we succeed in grabbing the pointer?
  if(Status1 != GrabSuccess) {
    // nope, abort
    fprintf(stderr,"can't grab the local mouse, aborting.\n");
    exit(EXIT_FAILURE);
  }

  // did we succeed in grabbing the keyboard?
  if (Status2 != GrabSuccess) {
    // nope, abort
    fprintf(stderr,"can't grab the local keyboard, aborting.\n");
    exit(EXIT_FAILURE);
  }

  XSync(LocalDpy,True);

  // let the user select a window...
  while (Loop) {
    // allow one more event
    XAllowEvents(LocalDpy,SyncPointer,CurrentTime);
    // get an event matching the specified mask
    XWindowEvent (LocalDpy,Root,KeyPressMask|KeyReleaseMask|PointerMotionMask|ButtonPressMask|ButtonReleaseMask,&Event);

    // what did we get?
    switch (Event.type) {
    case ButtonPress:
      // button pressed, create event
      EButton = Event.xbutton;
      gem_event.type = BUTTON_PRESSED;
      gem_event.button = translate_button(EButton.button);
      show_gem_remote_event(&gem_event);
      len=gem_event_to_msg(msg,&gem_event);
      send_msg(sock,adresse,msg,len);
      //XTestFakeButtonEvent ( RemoteDpy, EButton.button, True, Delay );
      break;
    case ButtonRelease:
      // button released, create event
      EButton = Event.xbutton;
      gem_event.type = BUTTON_RELEASED;
      gem_event.button = translate_button(EButton.button);
      show_gem_remote_event(&gem_event);
      len=gem_event_to_msg(msg,&gem_event);
      send_msg(sock,adresse,msg,len);
      //XTestFakeButtonEvent ( RemoteDpy, EButton.button, False, Delay );
      break;
    case MotionNotify:
      // motion-event, create event
      gettimeofday(&tempo,NULL);
      if((tempo.tv_usec - microsec >= USEC_WAIT) || (tempo.tv_sec != sec)) {
	microsec = tempo.tv_usec;
	sec=tempo.tv_sec;
	
	EMotion = Event.xmotion;
	if(!old_coords_initialized) {
	  old_x = EMotion.x;
	  old_y = EMotion.y;
	  old_coords_initialized = true;
	} else {
	  delta_x = EMotion.x - old_x;
	  delta_y = EMotion.y - old_y;
	  old_x = EMotion.x;
	  old_y = EMotion.y;
	}
	if(old_x > screen_width - BORD) {
	  old_x = BORD;
	} else if (old_x < BORD) {
	  old_x = screen_width - BORD;
	}
	if(old_y > screen_height - BORD) {
	  old_y = BORD;
	} else if (old_y < BORD) {
	  old_y = screen_height - BORD;
	}
	XTestFakeMotionEvent(LocalDpy,LocalScreen,old_x,old_y,0);
	gem_event.type = MOUSE_MOTION;
	gem_event.rel_x = delta_x;
	gem_event.rel_y = delta_y;
	show_gem_remote_event(&gem_event);
	len=gem_event_to_msg(msg,&gem_event);
	send_msg(sock,adresse,msg,len);
      }

      break;
    case KeyRelease:
      // a key was released
      EKey = Event.xkey;
      gem_event.type = KBD_RELEASE;
      gem_event.scan_code = get_scan_code(&EKey,LocalDpy,EKey.keycode);
      if(gem_event.scan_code != -1) {
	clear_special_keys(gem_event.scan_code,&special_keys);
	show_gem_remote_event(&gem_event);
	len=gem_event_to_msg(msg,&gem_event);
	send_msg(sock,adresse,msg,len);
      }
      //sendKey  ( &EKey, LocalDpy, RemoteDpy, EKey.keycode, false );
      break;
    case KeyPress:
      // a key was pressed, don't loop more
      EKey = Event.xkey;
   // should we stop looping, i.e. did the user press the quitkey?
      if ( EKey.keycode == QuitKey ) {
	// yep, no more loops
	Loop = false;
      } else {
	// send the keycode to the remote server
	//sendKey  ( &EKey, LocalDpy, RemoteDpy, EKey.keycode, true );
	gem_event.type = KBD_PRESS;
	gem_event.scan_code = get_scan_code(&EKey,LocalDpy,EKey.keycode);
	if(gem_event.scan_code != -1) {
	  set_special_keys(gem_event.scan_code,&special_keys);
	  if(gem_event.scan_code & 0x8000) {
	    press_special_keys(sock,adresse,(gem_event.scan_code & 0xff00) >> 8,special_keys);
	  }
	  show_gem_remote_event(&gem_event);
	  len=gem_event_to_msg(msg,&gem_event);
	  send_msg(sock,adresse,msg,len);
	  if(gem_event.scan_code & 0x8000) {
	    release_special_keys(sock,adresse,(gem_event.scan_code & 0xff00) >> 8,special_keys);
	  }
	}
      }
      break;
    }
  }
  // we're done with pointer and keyboard
  XUngrabPointer  ( LocalDpy, CurrentTime );
  XUngrabKeyboard ( LocalDpy, CurrentTime );
}

/*******************************************
 * crée une association chaine<->scan code *
 *******************************************/
struct kbd_assoc *new_assoc(char *s,int code) {
  int size=strlen(s);
  char *p;
  struct kbd_assoc *m;
  p=malloc(sizeof(char)*(size+1));
  assert(p != NULL);
  strcpy(p,s);
  m=malloc(sizeof(struct kbd_assoc));
  assert(m != NULL);
  m->keysymstring=p;
  m->scan_code=code;
  return m;
}

/*****************************
 * scan code pour le clavier *
 * idéalement, il faut lire  *
 * la config dans un fichier *
 *****************************/
void init_kbd_assoc_list(int argc,char *argv[]) {
  scancodes=empty_kbd_assoc_list();
  if(argc >= 1) {
    FILE *fd;
    char *keysymstring;
    int scancode;
    int ret;
    fd=fopen(argv[0],"r");
    assert(fd != NULL);
    keysymstring=NULL;
    while((ret = fscanf(fd,"%as %x",&keysymstring,&scancode)) != EOF) {
      if(ret == 2) {
	if(keysymstring != NULL) {
	  fprintf(stderr,"binding %s to %d\n",keysymstring,scancode);
	  scancodes=kbd_assoc_list_cons(new_assoc(keysymstring,scancode),scancodes);
	  free(keysymstring);
	} else {
	  fprintf(stderr,"error while fscanf\n");
	}
      } else {
	fprintf(stderr,"error while fscanf\n");
      }
    }
    fclose(fd);
  } else {
    fprintf(stderr,"no assoc list found\n");
  }
}

int findQuitKey (Display * display, int Screen) {
  XEvent    event;
  XKeyEvent EKey;
  Window    Target, Root;
  KeySym    keysym;
  int       Error;
  char      Buffer [64];
  char *    keysymstring;

  // get the root window and set default target
  Root   = RootWindow ( display, Screen );
  Target = None;

  // grab the keyboard
  Error = XGrabKeyboard ( display, Root, False, GrabModeSync, GrabModeAsync, CurrentTime );

  // did we succeed in grabbing the keyboard?
  if ( Error != GrabSuccess) {
        // nope, abort
    fprintf(stderr,"could not grab the keyboard, aborting.\n");
    exit ( EXIT_FAILURE );
  }

  // print a message to the user informing about what's going on
  fprintf(stdout,"\n"
	  "Press the key you want to use to end the application.\n"
	  "This key can be any key,\n"
	  "as long as you don't need it while working with the remote display.\n"
	  "A good choice is Escape.\n\n");

  // discard all X events before we start. This should get rid of the possible 'release'
  // event for the Return key that was generated when this application was started from
  // the command line. If started from within some other application I have no clue what
  // evil this will cause.
  XSync ( display, True );

  // loop until we get the quitting key
  while ( true ) {
    // allow one more event
    XAllowEvents ( display, SyncPointer, CurrentTime);
    XWindowEvent ( display, Root, KeyPressMask, &event);

    // what did we get?
    if ( event.type == KeyPress ) {
      // a key was pressed, don't loop more and store the key
      EKey = event.xkey;
      break;
    }
  }

  // we're done with pointer and keyboard
  XUngrabPointer  ( display, CurrentTime );
  XUngrabKeyboard ( display, CurrentTime );

  // perform lookup of the keycode
  XLookupString ( &EKey, Buffer, 64, &keysym, 0 );
  
  // map the keysym to a string. The string is from <X11/keysymdef.h> and is without
  // prefix XK_, thus being suitable for saving
  keysymstring = XKeysymToString ( keysym );

  // show the user what was chosen
  fprintf(stdout,"chosen quit-key: '%s', keycode: %d\n",keysymstring,EKey.keycode);

  // return the found key
  return EKey.keycode;
}

/********************************
 * Service offert par le client *
 ********************************/
void client_service(int sock,struct sockaddr_in *adresse,int argc,char *argv[]) {
  Display *LocalDpy;
  XKeyboardState kbd_state;
  int LocalScreen;

  LocalDpy = localDisplay();
  LocalScreen = DefaultScreen(LocalDpy);

  QuitKey = findQuitKey(LocalDpy,LocalScreen);

  XGetKeyboardControl(LocalDpy,&kbd_state);
  XAutoRepeatOff(LocalDpy);

  init_kbd_assoc_list(argc,argv);               // initialise la liste d'association key<->scan code

  eventLoop(sock,adresse,LocalDpy,LocalScreen);

  if(kbd_state.global_auto_repeat) {
    XAutoRepeatOn(LocalDpy);
  }

  XCloseDisplay(LocalDpy);
}
