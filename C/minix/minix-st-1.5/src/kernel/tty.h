#define NR_CONS            1	/* how many consoles can system handle */

#if (CHIP == M68000)
#define CONSOLE            0	/* line number for console */
#define SERIAL1		   1	/* line number for serial port */
#define OPERATOR        (-1)	/* handle CTRL-ALT-PFX sequences */
#endif

#define	NR_RS_LINES	   1	/* how many rs232 terminals can system handle*/
#define TTY_IN_BYTES    1000	/* input queue size */
#define TTY_RAM_WORDS    320	/* ram buffer size */
#define TTY_BUF_SIZE     256	/* unit for copying to/from queues */
#define TAB_SIZE           8	/* distance between tabs */
#define TAB_MASK          07	/* mask for tty_column when tabbing */
#define WORD_MASK     0xFFFF	/* mask for 16 bits */
#define OFF_MASK      0x000F	/* mask for  4 bits */
#define MAX_OVERRUN      500	/* size of overrun input buffer */
#define MAX_ESC_PARMS      2	/* number of escape sequence params allowed */

#define ERASE_CHAR      '\b'	/* default erase character */
#define KILL_CHAR        '@'	/* default kill character */
#define INTR_CHAR (char)0177	/* default interrupt character */
#define QUIT_CHAR (char) 034	/* default quit character */
#define XOFF_CHAR (char) 023	/* default x-off character (CTRL-S) */
#define XON_CHAR  (char) 021	/* default x-on character (CTRL-Q) */
#define EOT_CHAR  (char) 004	/* CTRL-D */

/*
 * This MARKER is used as an unambiguous flag for an unescaped end of
 * file character.  It is meaningful only in cooked mode.  0200 should
 * never be used in cooked mode, since that is supposed to be used only
 * for 7-bit ASCII.  Be careful that code only checks
 * for MARKER in cooked mode.  This kludge is needed because
 * chars are stored in char arrays, so there's no way to have a
 * completely out of band value.
 */
#define MARKER   (char) 0200	/* non-escaped CTRL-D stored as MARKER */
#define SCODE1            71	/* scan code for Home on numeric pad */
#define SCODE2            81	/* scan code for PgDn on numeric pad */
#define DEL_CODE   (char) 83	/* DEL for use in CTRL-ALT-DEL reboot */
#define ESC       (char) 033	/* escape */
#define BRACKET          '['	/* Part of the ESC [ letter escape seq */

/* The following macro is introduced since PC's must enable their interrupt
 * controller, whereas Atari's don't. Since this happens on several places I
 * found a macro cleaner than zillions of #ifdef's
 */
#if (CHIP == M68000)
#define	INT_CTL_ENABLE	
#else
#define	INT_CTL_ENABLE  port_out(INT_CTL, ENABLE)
			/* re-enable 8259A controller */
#endif

#if (CHIP == M68000)
#define F1                1	/* scan code for function key F1 */
#define F2                2	/* scan code for function key F2 */
#define F3                3	/* scan code for function key F3 */
#define F4                4	/* scan code for function key F4 */
#define F5                5	/* scan code for function key F5 */
#define F6                6	/* scan code for function key F6 */
#define F7                7	/* scan code for function key F7 */
#define F8                8	/* scan code for function key F8 */
#define F9                9	/* scan code for function key F9 */
#define F10               10	/* scan code for function key F10 */
#else
#define F1                59	/* scan code for function key F1 */
#define F2                60	/* scan code for function key F2 */
#define F3                61	/* scan code for function key F3 */
#define F4                62	/* scan code for function key F4 */
#define F5                63	/* scan code for function key F5 */
#define F6                64	/* scan code for function key F6 */
#define F7                65	/* scan code for function key F7 */
#define F8                66	/* scan code for function key F8 */
#define F9                67	/* scan code for function key F9 */
#define F10               68	/* scan code for function key F10 */
#endif
#define TOP_ROW           14	/* codes below this are shifted if CTRL */

#define IBM_PC		   1	/* Standard IBM keyboard */
#define OLIVETTI	   2	/* Olivetti keyboard	 */
#define DUTCH_EXT	   3	/* Dutch extended IBM keyboard */
#define US_EXT		   4	/* U.S. extended keyboard */
#define NR_SCAN_CODES   0x69	/* Number of scan codes */

EXTERN struct tty_struct {
  /* Input queue.  Typed characters are stored here until read by a program. */
  char tty_inqueue[TTY_IN_BYTES];    /* array used to store the characters */
  char *tty_inhead;		/* pointer to place where next char goes */
  char *tty_intail;		/* pointer to next char to be given to prog */
  int tty_incount;		/* # chars in tty_inqueue */
  int tty_lfct;			/* # line feeds in tty_inqueue */

  /* Output section. */
  int tty_ramqueue[TTY_RAM_WORDS];	/* buffer for video RAM */
  int tty_rwords;		/* number of WORDS (not bytes) in outqueue */
  int tty_org;			/* location in RAM where 6845 base points */
  int tty_vid;			/* current position of cursor in video RAM */
  char tty_esc_state;		/* 0=normal, 1=ESC, 2=ESC[ */
  char tty_esc_intro;		/* Distinguishing character following ESC */
  int tty_esc_parmv[MAX_ESC_PARMS];	/* list of escape parameters */
  int *tty_esc_parmp;		/* pointer to current escape parameter */
#if (CHIP != M68000)
  int tty_attribute;		/* current attribute byte << 8 */
#endif
  int (*tty_devstart)();	/* routine to start actual device output */

  /* Terminal parameters and status. */
  int tty_mode;			/* terminal mode set by IOCTL */
  int tty_speed;		/* low byte is ispeed; high byte is ospeed */
  int tty_column;		/* current column number (0-origin) */
  int tty_row;			/* current row (0 at top of screen) */
  char tty_busy;		/* 1 when output in progress, else 0 */
  char tty_escaped;		/* 1 when '\' just seen, else 0 */
  char tty_inhibited;		/* 1 when CTRL-S just seen (stops output) */
  char tty_makebreak;		/* 1 for terminals that interrupt twice/key */
  char tty_waiting;		/* 1 when output process waiting for reply */

  /* User settable characters: erase, kill, interrupt, quit, x-on; x-off. */
  char tty_erase;		/* char used to erase 1 char (init ^H) */
  char tty_kill;		/* char used to erase a line (init @) */
  char tty_intr;		/* char used to send SIGINT  (init DEL) */
  char tty_quit;		/* char used for core dump   (init CTRL-\) */
  char tty_xon;			/* char used to start output (init CTRL-Q)*/
  char tty_xoff;		/* char used to stop output  (init CTRL-S) */
  char tty_eof;			/* char used to stop output  (init CTRL-D) */

  /* Information about incomplete I/O requests is stored here. */
  char tty_incaller;		/* process that made the call (usually FS) */
  char tty_inproc;		/* process that wants to read from tty */
  char *tty_in_vir;		/* virtual address where data is to go */
  int tty_inleft;		/* how many chars are still needed */
  char tty_otcaller;		/* process that made the call (usually FS) */
  char tty_outproc;		/* process that wants to write to tty */
  char *tty_out_vir;		/* virtual address where data comes from */
  phys_bytes tty_phys;		/* physical address where data comes from */
  int tty_outleft;		/* # chars yet to be copied to tty_outqueue */
  int tty_cum;			/* # chars copied to tty_outqueue so far */
  int tty_pgrp;			/* slot number of controlling process */

  /* Miscellaneous. */
  int tty_ioport;		/* I/O port number for this terminal */

} tty_struct[NR_CONS+NR_RS_LINES];


/* Values for the fields. */
#define NOT_ESCAPED        0	/* previous character on this line not '\' */
#define ESCAPED            1	/* previous character on this line was '\' */
#define RUNNING            0	/* no CRTL-S has been typed to stop the tty */
#define STOPPED            1	/* CTRL-S has been typed to stop the tty */
#define INACTIVE           0	/* the tty is not printing */
#define BUSY               1	/* the tty is printing */
#define ONE_INT            0	/* regular terminals interrupt once per char */
#define TWO_INTS           1	/* IBM console interrupts two times per char */
#define NOT_WAITING        0	/* no output process is hanging */
#define WAITING            1	/* an output process is waiting for a reply */
#define COMPLETED          2	/* output done; send a completion message */

EXTERN char tty_driver_buf[2*MAX_OVERRUN+4]; /* driver collects chars here */
#define tty_buf_count(p) (((int *)(p))[0])
#define tty_buf_max(p) (((int *)(p))[1])
EXTERN char tty_copy_buf[2*MAX_OVERRUN];  /* copy buf used to avoid races */
EXTERN char tty_buf[TTY_BUF_SIZE];	/* scratch buffer to/from user space */
EXTERN int shift1, shift2, capslock, numlock;	/* keep track of shift keys */
EXTERN int control, alt;	/* keep track of key statii */
EXTERN int caps_off;		/* 1 = normal position, 0 = depressed */
EXTERN int num_off;		/* 1 = normal position, 0 = depressed */
EXTERN int softscroll;		/* 1 = software scrolling, 0 = hardware */
EXTERN int output_done;		/* number of RS232 output messages to be sent*/
EXTERN int char_height;		/* number of scan lines for a char */
EXTERN int keyb_type;		/* type of keyboard attached */
EXTERN int minus_code;		/* numeric minus on dutch extended keyboard */
EXTERN int num_slash;		/* scan code of numeric slash */
