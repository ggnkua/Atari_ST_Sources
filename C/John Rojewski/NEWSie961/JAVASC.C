/* JavaScript Ideas

Is it possible to create a JavaScript interpreter to interface with NEWSie, CAB, etc.?
Assuming this is possible, how much effort will it take?
Assuming I undertake this project, how much time will it take?

Needs:
Tiny-C (or C++) interpreter:
	This would provide parsing and memory management routines, etc.
Interface structures:
	Structures with properties, methods, and event handlers.
	Invocation method (i.e VA_Start, w/possible some special AES message id(s))
	Callback interface if/as required.

Ideas:
1.	Recognize <SCRIPT LANGUAGE=JavaScript SRC=script.js><!-- script --></SCRIPT>,
	and pass it to Interpreter.
2.	Implement Object structure and pass to interpreter.  This can be actual structure,
	or copy.  Pass address in memory, handle memory protection (Global, etc.)
3.	Requires Multi-tasking.  Interpreter is separate program w/AES id, etc.
4.	Can be run locally, without Network connection.
5.	Minimal implementation required for NEWSie, because Forms are not (yet) supported.
6.	methods are identified (parsed) via presence of '(' and ')'.  Properties do not use 
	parentheses.

/* Object structures */

/* Form related */
typedef struct element {
	struct element *next;		/* next element in form */
} ELEMENT;

/* from <FORM></FORM> */
typedef struct form {
	struct form *next;		/* next form in document */
	struct element *elements;	/* list of elements in form */
/* Properties */
	char action[256];
/*	char elements[]; */
	char encoding[80];
	char method[20];
	char target[0];
/* Methods */
	void * submit();
/* Event Handlers */
	void * onSubmit();
} FORM;

/* from <INPUT> (TYPE=) */
struct reset BUTTON;	/* see Reset structure */

typedef struct checkbox {
	struct element *next;		/* next element in form */
/* Properties */
	char checked[0];
	char defaultChecked[0];
	char name[20];
	char value[0];
/* Methods */
	void * click();
/* Event Handlers */
	void * onClick();
} CHECKBOX;

typedef struct hidden {
	struct element *next;		/* next element in form */
/* Properties */
	char checked[0];
	char defaultValue[0];
	char name[20];
	char value[];
/* NO Methods */
/* NO Event Handlers */
} HIDDEN;

typedef struct password {
	struct element *next;		/* next element in form */
/* Properties */
	char password[0];
	char defaultValue[0];
	char name[20];
	char value[];
/* Methods */
	void * blur();
	void * focus();
	void * select();
/* Event Handlers */
	void * onBlur();
	void * onFocus();
	void * onSelect();
} PASSWORD;

typedef struct checkbox {
	struct element *next;		/* next element in form */
/* Properties */
	char checked[0];
	char defaultChecked[0];
	char index[0];
	char length[0];
	char name[20];
	char value[0];
/* Methods */
	void * click();
/* Event Handlers */
	void * onClick();
} RADIO;

typedef struct text {
	struct element *next;		/* next element in form */
/* Properties */
	char defaultValue[0];
	char name[20];
	char value[0];
/* Methods */
	void * blur();
	void * focus();
	void * select();
/* Event Handlers */
	void * onBlue();
	void * onChange();
	void * onFocus();
	void * onSelect();
} TEXT;

struct text TEXTAREA;	/* see Text structure */

/* from <OPTION> */
typedef struct text {
	struct element *next;		/* next element in form */
/* Properties - select */
	char length[20];
	char name[20];
	char options[0];
	char selectedIndex[20];
/* Properties - options */
	char defaultSelected[0];
	char index;
	char selected[0];
	char text[0];
	char value[0];
/* NO Methods */
/* Event Handlers */
	void * onBlue();
	void * onChange();
	void * onFocus();
} SELECT;

/* from <RESET> */
typedef struct reset {
	struct element *next;		/* next element in form */
/* Properties */
	char name[20];
	char value[20];
/* Methods */
	void * click();
/* Event Handlers */
	void * onClick();
} RESET;

/* from <SUBMIT> */
typedef struct submit {
	struct element *next;		/* next element in form */
/* Properties */
	char value[20];
/* Methods */
	void * click();
/* Event Handlers */
	void * onClick();
} SUBMIT;

typedef struct textbuff {
	struct textbuff *next;	/* next textbuff */
	long size;		/* size of buffer */
	char buffer[0];		/* variable length */
} TEXTBUFF;

typedef struct anchor {
	struct anchor *next;	/* next possible document anchor */
} ANCHOR;

typedef struct link {		/* next possible document link */
	struct link *next;
/* Properties */
	char target[256];
/* NO Methods */
/* Event Handlers */
	void * onClick();
	void * onMouseOver();
} LINK;

typedef struct document {
	struct document *next;		/* next document fragment */
	struct textbuff *script;	/* input to interpreter */
	struct textbuff *output; 	/* output from interpreter */
	struct anchor	*anchors;	/* possible document anchors */
	struct link	*links;		/* possible document links */
	struct form	*forms;		/* possible document forms */
/* Properties */
	char alinkColor[20];
/*	char anchors[]; */
	char bgColor[20];
	char cookie[0];
	char fgColor[20];
/*	char forms[0]; */
	char lastModified[];
	char linkColor[20];
/*	char links[0]; */
	char location[256];
	char referrer[0];
	char title[80];
	char vlinkColor[20];
/* Methods */
	void * clear();
	void * close();
	void * open();
	void * write();
	void * writeln();
/* NO Event Handlers */
} DOCUMENT;

typedef struct frame {		/* address of possible Frame object */
	struct frame *next;	/* next frame object */
	struct document *document;
/* Properties */
	char defaultStatus[80];
	char frames[0];
	char parent[0];
	char self[0];
	char status[80];
	char top;
	char window;
/* Methods */
	void * alert();
	void * close();
	void * confirm();
	void * open();
	void * prompt();
	void * setTimeout();
	void * clearTimeout();
/* NO Event Handlers */
} FRAME;

typedef struct location {
/* Properties */
	char hash[20];
	char host[80];
	char hostname[40];
	char href[256];
	char pathname[128];
	char port[10];
	char protocol[10];
	char search[];
/* NO Methods */
/* NO Event Handlers */
} LOCATION;

typedef struct history {
/* Properties */
	char length[20];
/* Methods */
	void * back();
	void * forward();
	void * go();
/* NO Event Handlers */
} HISTORY;

typedef struct window {		/* address of Window  object */
	struct window *next;
	struct frame  *frame;
	struct document *document;
	struct location *location;
	struct history *history;
/* Properties */
	char defaultStatus[80];
	char frames[0];
	char parent[0];
	char self[0];
	char status[80];
	char top;
/* Methods */
	void * alert();
	void * close();
	void * confirm();
	void * open();
	void * prompt();
	void * setTimeout();
	void * clearTimeout();
/* Event Handlers */
	void * onLoad();
	void * onUnload();
} WINDOW;

typedef struct navigator {	/* address of Navigator (aka Browser) object */
/* Properties - ready-only */
	char appName[20];
	char appVersion[20];
	char appCodeName[20];
	char userAgent[128];
/* NO Methods */
/* NO Event Handlers */
} NAVIGATOR;

/* Callback functions to browser - as required */
typedef struct callback {
/* NO Properties */
/* NO Methods */
/* NO Event Handlers */
} CALLBACK;

#def JvSc 0x4a765363		/* 'JvSc' */

typedef struct js {
	long	magic;		/* magic identifier 'JvSc' = 0x4a765363 */
	NAVIGATOR *navigator;	/* address of Navigator (aka Browser) object */
	WINDOW *window;		/* address of Window  object */
	DOCUMENT *document;	/* address of Document object */
	CALLBACK *callback;	/* address of Callback object - as required */
} JavaScript *root;		/* passed via VA_Start... */


/* Common Objects - local to interpreter */
typedef struct date {
/* NO Properties */
/* Methods */
	void * getDate();
	void * getDay();
	void * getHours();
	void * getMinutes();
	void * getMonth();
	void * getSeconds();
	void * getTime();
	void * getTimeZoneoffset();
	void * getYear();
	void * parse();
	void * setDate();
	void * setHours();
	void * setMinutes();
	void * setMonth();
	void * setSeconds();
	void * setYear();
	void * toString();
	void * toGMTStringr();
	void * toLocalString();
	void * UTC();
} DATE;

typedef struct math {
/* Properties */
	char E[20];
	char LN10[20];
	char LN2[20];
	char PI[20];
	char SQRT1_2[20];
	char SQRT2[20];
/* Methods */
	void * abs();
	void * acos();
	void * asin();
	void * atan();
	void * ceil();
	void * cos();
	void * exp();
	void * floor();
	void * log();
	void * max();
	void * pow();
	void * random();
	void * round();
	void * sin();
	void * sqrt();
	void * tan();
/* NO Event Handlers */
} MATH;

typedef struct string {
/* Properties */
	char length[20];
/* Methods */
	void * anchor();
	void * big();
	void * blink();
	void * bold();
	void * charAT();
	void * fixed();
	void * fontcolor();
	void * fontsize();
	void * indexOf();
	void * italics();
	void * lastIndexOf();
	void * link();
	void * small();
	void * strike();
	void * sub();
	void * substring();
	void * sup();
	void * toLowerCase();
	void * toUpperCase();
/* NO Event Handlers */
} STRING;


/* overview of JavaScript interpreter */
...
#define MT _AESglobal[1]!=1		/* Multi-tasking OS */

char *focus=NULL;	/* current focus data */

int window_alert( char *text )
{
	char temp[200];

	sprintf( temp, "[1][JavaScript Alert:|%s][ OK ]", text );
	form_alert( temp );
	return(1);
}

int window_confirm( char *text )
{
	int rc=0;
	char temp[200];

	sprintf( temp, "[2][JavaScript Confirm:|%s][ No, Yes ]", text );
	rc = form_alert( temp );
	return(rc-1);
}

char * window_prompt( char *text )
{
	char temp[200];
	OBJECT *dlog;

	sprintf( temp, "[1][JavaScript Prompt:|%s]", text );
	rc = form_dial( dlog );
	return( "" );
}

void send_VA_Start( int aes_id, void *path )
{
	int mbuff[8];
	long *p;

	mbuff[0] = VA_START;
	mbuff[1] = _AESglobal[2];
	mbuff[2] = 0;
	p=(long *)&mbuff[3];	/* command line in mbuff[3 & 4] */
	*p=(long)path;
	appl_write( aes_id, 16, &mbuff );	/* send message */
}

interpret_VA_Start( int *mbuff )
{
	long *p;

	window_alert( "VA_Start Received" );
	p=(long *)&mbuff[3];	/* command line in mbuff[3 & 4] */
	p=(long *)*p;
	if (p==NULL) { return; }
	root = (JavaScript *)p;
	if (root.magic!=JvSc) {
		window_alert( "Magic is Missing" );
		return;
	}
/*	do something with input structure */
	send_VA_Start( mbuff[1], root );	/* reply back to caller */
}

int main( int argc, char *argv[] )
{
	int rc,mbuff[8];

	appl_init();
	if ( MT ) {
	/*	if (argc>1) {		/* recognize possible paramenters */
			fprintf( log, "Parameter: %s\n", argv[1] );
	 	}
	*/
	/*	initialize_tables(); */
		while(!finished) {
			rc = event_msg( &mbuff);
			if (mbuff[0]==VA_START) { interpret_VA_Start(); }
			if (mbuff[0]==AP_TERM) { finished++; }
		}
	} else {
		window_alert( "Must be Multi-Tasking System" );
	}
	appl_exit();
	exit( SUCCESS );
}
/* end of JavaSc.c */

