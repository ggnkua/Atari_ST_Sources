/* This is the message structure. xxx is the horizontal character position.
It ranges from 0 to 41 on a horizontal monitor and from 0 to 29 on a vertical
monitor.  yyy is the vertical character position of the message. It ranges from
0 to 29 on a horizontal monitor and from 0 to 41 on a vertical monitor.
*text is a pointer to a character string. This string is the text which is to
be printed on the screen. chain is the flag to indicate if this message is
to chain to another message. 0 means no chaining, 1 means chain if soft
chaining is enabled and 2 mean chain always. *nextname is the address of
the message to chain to. The structure is declared as a typedef with the 
name MT.
Example:
	MT mess2 = {1,2,"How are you?",0,0};
	MT mess1 = {1,1,"Hello, there",2,&mess2};

The name of the first message is mess2. This name will be used to refer
to this message in the routine calls. The X position of this message is
1. The Y position is 2. "How are you?" is the actual text to be displayed
on the screen. There is no chaining in this message so the next two fields
have 0 in them.
The name of the second message is mess1. Its X,Y position is 1,1. Its
text is "hello, there". This message will always chain so the next field
is 2. The message to chain to is mess2. the & sign is needed to indicate
the address of the other message.
There is a form of the MT structure which saves space if you do not wish
to chain. This is MT2. It is missing the nextname field. This saves 4 bytes
per message.
*/

typedef struct mt {
    char  xxx;
    char  yyy;
    char *text;
    char  chain;
    struct mt   *nextname;
}  MT;

typedef struct mt2 {
    char  xxx;
    char  yyy;
    char *text;
    char  chain;
}  MT2;

/* The CHAIN macro may be used if you wish to declare that a message is
to be chained to before you declare the actual message.
*/

#define CHAIN extern MT

/* 		standard message routine includes		*/

/* write - is the basic message routine. It displays the message
described in the message block on the screen. It requires two
parameters. The first is the address of the message block.
The second is the COLOR. The COLOR is ORed with each character
of the message. This allows the programmer to set any bits in
a message. In vertical screen mode an 0x80 is exclusive ORed in
this selects the other character set. Bits 15 and 14 of the color
are used to select the special capital sets. If bit 15 is set,
the bold capital set is selected. If bit 14 is set, the modern
capital set is selected.
*/
extern	int write();	/* ( &m_messlabel, COLOR )		*/

/* erase - erases the message pointed to by the message block.
It removes any type or blink information. The message will stop
blinking or typing or will terminate early if it was pulsed.
*/
extern	void erase();	/* ( &m_messlabel )			*/

/* type - is like write except there is a third parameter. This
parameter controls the rate in which the letters are placed on the
screen. If a message is typed, one letter of the message will appear
every n 60Hz frames. where n is set by the RATE. If RATE is 60 then
a character will appear every second until the message is completly
printed.
*/
extern	int type();		/* ( &m_messlabel, COLOR, RATE )	*/

/* pulse - is like write except that the message has a finite life
time. This life time is set in number of 60Hz frames. After RATE
frames the message is erased
*/
extern	int pulse();	/* ( &m_messlabel, COLOR, RATE )	*/

/* etype - is like type except that the message is erase instead
of typed. One letter of a message is removed every RATE frames. 
*/
extern	int etype();	/* ( &m_messlabel, RATE )		*/

/* blink - is like pulse except that the message will reappear again
after RATE frames and disappear again after RATE frames. This is
repeated until the message is erased.
*/
extern	int blink();	/* ( &m_messlabel, COLOR, RATE )	*/

/* hscroll - writes the message and scrolls is horizontally every
RATE frames. If rate is negative the message is scrolled right.
If rate is positive the message is scrolled left.
*/
extern	int hscroll();	/* ( &m_messlabel, COLOR, RATE ) + = L	*/

/* vscroll - writes the message. If the imvscrl flag is set, this
message will scroll from the bottom of the screen. The y position
of chained messages may be greater than the number of lines. They
will scroll onto the screen from the bottom.
*/
extern	int vscroll();	/* ( &m_messlabel, COLOR, RATE )	*/
/* delay - wait DELAY ticks. Avoid a 1 tick delay as it may be
possible to miss the first chance and then the delay could be
very very long indeed.
*/
extern	void delay();	/* ( DELAY )  vblank ticks 60 = 1 sec.	*/

/* initmess - initializes the message table and clears the screen.
Any messages which were pulsing, typing, scrolling, or blinking
will be erased.
*/
extern	void initmess();	/* clr alpha RAM and init message vars. */

/* message control flags. These flags control message features.
*/
extern	short imvscrl;	/* 1 = start vertical scrolling		*/
extern	short imchain;	/* 0 = only hard chaining		*/

extern	void wnum();	/* ( &m_num<1-8>, x, y, chain )		*/
extern	cnum();		/* ( #, c_num<1-8>, radix, form, length ) */
extern  cdec();		/* ( #,buffer,length,form)		*/
extern  chex();		/* ( #,buffer,length,form)		*/
extern  int bwrite();	/* ( &m_messlabel,COLOR)		*/
extern  int berase();	/* ( &m_messlabel)			*/
extern	void cwrite();	/* (x,y,letter,COLOR)			*/
extern	void cput();	/* (lwhere,what)			*/
extern  int tbigh();	/* (where,what,COLOR)			*/
extern	int tbigv();	/* (where,what,COLOR)			*/
extern  int *gwhere();	/* (x,y)				*/
extern	warmtst();	/* ()					*/

#define	APLT0		0X0000
#define	APLT1		0X1000
#define	APLT2		0X2000
#define	APLT3		0X3000
#define	APLT4		0X4000
#define	APLT5		0X5000
#define	APLT6		0X6000
#define	APLT7		0X7000
#define	BG_BIT		0X8000
#define	APLT_MASK	0x0FFF

#define	SET1	0X01
#define	SET2	0X02
