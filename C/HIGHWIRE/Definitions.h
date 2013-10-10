/* ******* Type Definitions ********* */

enum bool {false,true};
enum word_codes {none,br};
enum paragraph_alignment {left,center,right};
enum vertical_alignment {above,top,middle,bottom,below};
enum paragraph_codes {p_none,hr,ol,ul};
enum bullets {disc,square,circle,Number,alpha,Alpha,roman,Roman};
enum direction {d_up,d_down,d_left,d_right};
enum link_mode {href,name};
enum possible_message_types {to_do_load_frame,to_do_parse_frame};

/* ********** Consts ************** */
#define POINT_SIZE 12
#define background_colour 0
#define Space_Code 561
#define normal_font 0
#define header_font 1
#define pre_font 2
#define scroll_bar_width 15
#define scroll_step 24
#define DOMAIN_MINT 1

/* ********** Structures ***************** */

typedef struct 
{
	short handle;
	short dev_id;
	short wchar;
	short hchar;
	short wbox;
	short hbox;
	short xres;
	short yres;
	short noscale;
	short xpixel;
	short hpixel;
	short cheights;
	short linetypes;
	short linewidths;
	short markertypes;
	short markersizes;
	short faces;
	short patterns;
	short hatches;
	short colours;
	short ngdps;
	short cangdps[10];
	short gdpattr[10];
	short cancolour;
	short cantextrot;
	short canfillarea;
	short cancellarray;
	short palette;
	short locators;
	short valuators;
	short choicedevs;
	short stringdevs;
	short wstype;
	short minwchar;
	short minhchar;
	short maxwchar;
	short maxhchar;
	short minwline;
	short zero5;
	short maxwline;
	short zero7;
	short minwmark;
	short minhmark;
	short maxwmark;
	short maxhmark;
	short screentype;
	short bgcolours;
	short textfx;
	short canscale;
	short planes;
	short lut;
	short rops;
	short cancontourfill;
	short textrot;
	short writemodes;
	short inputmodes;
	short textalign;
	short inking;
	short ruberbanding;
	short maxvertices;
	short maxintin;
	short mousebuttons;
	short widestyle;
	short widemode;
	short reserved[38];
} VDI_Workstation;


struct xattr {
	unsigned short mode;
	long index;
	unsigned short dev;
	unsigned short reserved1;
	unsigned short nlink;
	unsigned short uid;
	unsigned short gid;
	long size;
	long blksize;
	long nblocks;
	short mtime;
	short mdate;
	short atime;
	short adate;
	short ctime;
	short cdate;
	short attr;
	short reserved2;
	long reserved3;
	long reserved4;
};

/* ************ Parsing Constructs ************************ */

struct font_step {
	short step;
	struct font_step *previous_font_step;
};

struct font_style {
	unsigned italic;
	unsigned bold;
	unsigned underlined;
	unsigned strike;
	unsigned font;
	short font_size;
};

struct word_changed {
	enum bool font;
	enum bool style;
	enum bool colour;
};

struct word_item {
	short *item;
	struct font_style styles;
	struct word_changed changed;
	enum word_codes word_code;
	short word_width;
	short word_height;
	short word_tail_drop;
	short colour;
	short space_width;
	enum vertical_alignment vertical_align;
	struct url_link *link;
	struct word_item *next_word;
};

struct paragraph_item {
	struct word_item *item;
	enum paragraph_alignment alignment;
	enum paragraph_codes paragraph_code;
	short left_border;
	short right_border;
	short eop_space;
	short current_paragraph_height;
	struct paragraph_item *next_paragraph;
};


struct clipping_area {
	short x;
	long y;
	short w;
	short h;
};

struct frame_item {
	struct paragraph_item *item;
	short frame_width;
	short frame_height;
	short frame_left;
	short frame_top;
	short horizontal_scroll;
	long vertical_scroll;
	short frame_page_width;
	enum bool v_scroll_on;
	enum bool h_scroll_on;
	enum bool border;
	long current_page_height;
	struct clipping_area clip;
	struct clipping_area frame;
	struct clickable_area *first_clickable_area;
	struct named_location *first_named_location;
	struct frame_item *next_frame;
	char *frame_filename;
	char *frame_named_location;
};

struct list_stack_item {
	enum bullets bullet_style;
	short current_list_count;
	struct list_stack_item *next_stack_item;
};

/* ******************** Action Constructs ************************* */

struct clickable_area {
	short x;
	long y;
	short w;
	short h;
	struct url_link *link;
	struct clickable_area *next_area;
};

struct named_location {
	long position;
	struct url_link *link;
	struct named_location *next_location;
};

struct url_link {
	char *address;
	enum link_mode mode;
};

/* ******************* Flow Control Constructs ********************* */


struct to_do_item {
	enum possible_message_types message_type;
	void *message;
	struct to_do_item *next_to_do;
};

extern struct to_do_item *add_to_do;
extern struct to_do_item *read_to_do;

struct load_to_do {
	short sub_type;
	char *filename;
	char *named_location;
	struct frame_item *frame;
};

struct parse_to_do {
	char *file;
	struct frame_item *frame;
};
