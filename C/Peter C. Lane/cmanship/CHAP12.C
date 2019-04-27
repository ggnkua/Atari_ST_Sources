/*********************************************************/
/*                 C-MANSHIP, Listing 1                  */
/*                     CHAPTER 12                        */
/*               Developed with Megamax C                */
/*********************************************************/

#include <aes.h>
#include <vdi.h>

#define TRUE 1
#define FALSE 0
#define FINGER 3
/* Required GEM global arrays */
int work_in[11],
    work_out[57],
    pxyarray[10],
    contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];

/* A couple of global int variables */
int handle, dum;
MFORM mouse_dummy;

/* Mouse form definition block */
typedef struct mfrmstr
  {
int x_hot;    /* x-coordinate of pointer hot spot. */
int y_hot;    /* y-coordinate of pointer hot spot. */
int planes;   /* number of bit planes.             */
int fg_color; /* mouse form color.                 */
int bg_color; /* mouse mask color.                 */
int mask[16]; /* Data for mouse mask.              */
int data[16]; /* Data for mouse form.              */
  } MOUSEFORM;
MOUSEFORM mouse;

/* Data for the new mouse form */
int mouse_data[] = {0x0000,0x07C0,0x0FE0,0x1930,
                    0x3118,0x610C,0x600C,0x7C7C,
                    0x600C,0x610C,0x3118,0x1930,
                    0x0FE0,0x07C0,0x0000,0x0000};

int mouse_mask[] = {0x07C0,0x0820,0x1010,0x26C8,
                    0x4AA4,0x9292,0x9D72,0x8282,
                    0x9D72,0x9292,0x4AA4,0x26C8,
                    0x1010,0x0820,0x07C0,0x0000};

void open_vwork(void);
void do_alert(void);
void new_mouse(void);
void button_wait (void);

void main() /* Main program */
{
   appl_init();  /* Initialize our application. */
   open_vwork(); /* Go set up our workstation.  */
   do_alert();   /* Go to the main loop.        */
   appl_exit();  /* Back to the desktop.        */
}

void open_vwork(void) /* Initialize a virtual workstation */
{
    int i;
    handle = graf_handle(&dum,&dum,&dum,&dum);
    for (i=0; i<10; work_in[i++] = 1);
    work_in[10] = 2;
    v_opnvwk(work_in, &handle, work_out);
}

void do_alert(void) /* This is the main loop.  It calls the alert box */
{          /* function and the functions to change the mouse */
           /* form. The loop repeats until REPEAT == false. */

  int choice,  /* Will hold button choice.     */
      repeat,  /* Loop control variable.       */
      deflt;   /* Holds default button choice. */

  repeat = TRUE;  /* We set this so the loop will repeat.    */
  deflt = 3;      /* Set default button to Quit (see below). */
  while (repeat) {
    choice = form_alert (deflt,
      "[1][    MOUSE FORM DEMO    |    C-manship|\
    Chapter Twelve][New|System|Quit]"); /* Draw alert box. */
    if (choice == 1) {  /* CHOICE contains the button pressed. */
      new_mouse();      /* If button was NEW, show new form. */
      button_wait();
      deflt = 2;        /* Change default button to 2. */
    }
    if (choice == 2) {  /* If the second button was pressed, */
      graf_mouse (FINGER,&mouse_dummy); /* then change to Hand icon. */
      button_wait();
             deflt = 1;        /* Change default button to 1. */
    }
    if (choice == 3)
      repeat = FALSE;  /* When REPEAT == false (0), we get out */
  }                    /* of the while loop and go to main(). */
}

void new_mouse(void) /* Changes mouse form to the user-defined form */
{           /* found in the global arrays at top of listing */
   int x;

   mouse.x_hot = 8;    /* These two assignments set "hot spot" */
   mouse.y_hot = 8;    /* to the center of the mouse form. */
   mouse.planes = 4;   /* Set to 1 for high res and 2 for med. */
   mouse.fg_color = 0; /* Mouse form drawn with color 0. */
   mouse.bg_color = 2; /* Mouse mask drawn in color 2. */
   for (x=0; x<16; ++x) {    /* This loop moves the data from */
      mouse.mask[x] = mouse_mask[x]; /* global arrays into the */
      mouse.data[x] = mouse_data[x]; /* mouse form def'n block */
   }
   graf_mouse(255,&mouse); /* Presto! Our new mouse lives. */
}

void button_wait(void) /* Waits for left button to be pressed and released. */
{
  int dum;

    evnt_button(1,1,1,&dum,&dum,&dum,&dum);
    evnt_button(1,1,0,&dum,&dum,&dum,&dum);
}
