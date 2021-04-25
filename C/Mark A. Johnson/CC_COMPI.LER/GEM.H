/* gem definitions and structures */

struct object {
	int	next;		/* index of next object in the tree	*/
	int	start;		/* index of first subordinate		*/
	int	last;		/* index of last subordinate		*/
	int 	type;		/* type of the object			*/
	int	flags;		/* selectability of the objects		*/
	int	status;		/* state of the object			*/
	int	*spec;		/* pointer to object data structure	*/
	int	x;		/* x coord relative to parent		*/
	int	y;		/* y coord relative to parent		*/
	int	w;		/* width of the object			*/
	int	h;		/* height of the object			*/
};

/* object types */

#define BOX	20
#define TEXT	21
#define BOXTEXT	22
#define IMAGE	23
#define PROGDEF	24
#define IBOX	25
#define BUTTON	26
#define BOXCHAR	27
#define STRING	28
#define FTEXT	29
#define FBOXT	30
#define ICON	31
#define TITLE	32

/* object flags */

#define NONE	0x00
#define SELECT	0x01
#define DEFAULT	0x02
#define EXIT	0x04
#define EDIT	0x08
#define RBUTTON	0x10
#define LASTOBJ	0x20
#define TOUCHX	0x40
#define HIDE	0x80
#define INDIR	0x100

/* object status */

#define CROSSED	0x02
#define CHECKED	0x04
#define DISABLE	0x08
#define OUTLINE	0x10
#define SHADOW	0x20

struct tedinfo {
	char	*text;		/* string to be output			*/
	char	*tmplt;		/* template for the string		*/
	char	*valid;		/* permission string for input		*/
	int	font;		/* character set (normal 3, small 5)	*/
	int	res1;		/* reserved				*/
	int 	just;		/* justify (left 0, right 1, center 2)	*/
	int	color;		/* text color				*/
	int	res2;		/* reserved				*/
	int	thick;		/* border thickness -127 to 128		*/
	int 	txtlen;		/* length of the string			*/
	int	tmplen;		/* length of the template		*/
};

