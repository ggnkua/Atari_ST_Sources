/**************************************************************
*************    I M A G E    L I B R A R Y     ***************
***************************************************************
******* by Martin Hejral ****** last update 26.Feb.1996 *******
***************************************************************
** - prototypes for all global procedures in IMAGE LIBRARY - **
**************************************************************/

/* ========== functions defined in colours.c ========== */
/* -palette in REAL-not VDI-order is used (val.0-1000)- */
/* read current video palette and save it to rgb_old[]  */
void save_palette(void);
void restore_palette(void);
/* scale palette (colour *= a/b) */
void scale_palette(int a, int b, IMAGE *img);
/* set palette for image *img (RGB colours in range 0-1000) */
void set_palette(int handle, IMAGE *img);
/* colours are getting light or dark */
void fade_in(int handle, IMAGE *img);
void fade_out(int handle, IMAGE *img);

/* ========== functions defined in conv.c ========== */
/* !!! initialize Image Library - call at programm start !!! */
int init_imglib(void);
/* bitmap format conversion */
int nat2spec(IMAGE *img);
/* drawing */
void show_image(int x,int y,int w,int h,int x2,int y2,IMAGE *img);
void show_palette(int x, int y);
/* allocate memory for image */
int alloc_colour_map(IMAGE *img);
int alloc_map(IMAGE *img);
/* delete image and free used memory */
void delete_colour_map(IMAGE *img);
void delete_data(IMAGE *img);
void delete_map(IMAGE *img);
void delete_image(IMAGE *img);
/* info about ST compatibles - return cookie value -> */
/* -> -3 .. COOKIE STRUCTURE or ID. STRING NOT EXIST  */
/*    (on MagicMAC for example "_MCH" contain -1 !?!) */
long get_cookie(char *a);

/* ========== functions defined in crackart.c ========== */
/* read CrackArt images */
int read_ca(char *filename, IMAGE *img);

/* ========== functions defined in falcon.c ========== */
/* convert RGB colour in 24bit format to Falcon 16bit format */
WORD rgb2falc(int col[3]);
/* convert Falcon 16bit format to RGB colour in 24bit format */
void falc2rgb(WORD f, int col[3]);
/* switch ON/OFF Falcon 16bit graphic mode */
int true_colour(int mode);

/* ========== functions defined in font.c ========== */
/* print antialiased font (need 16bit 5-6-5 gr.mode) */
void aprint(char *text, int x, int y);
/* create antialiased font (from normal bitmap font) */
int  create_afont(int num);
void delete_font(int num);
/* print loaded font in any resolution */
void gprint(char *text, int x, int y);
/* load a standard GEM bitmap font to memory */
int  read_font(char *file, int num);
void text_color(int num);
void text_font(int num);

/* ========== functions defined in gif.c ========== */
int out_line(unsigned char *pixels, int linelen);
int get_byte(void);
int read_gif(char *filename, IMAGE *Image);

/* ========== functions defined in gifdecod.c ========== */
void cleanup_gif_decoder(void);
int init_exp(int i_size);
int get_next_code(void);
int decoder(int i_linewidth);

/* ========== functions defined in iff.c ========== */
int read_byte(FILE *f);
int read_word(FILE *f);
long read_long(FILE *f);
int read_iff(char *filename, IMAGE *Image);

/* ========== functions defined in img.c ========== */
int read_img(char *filename, IMAGE *img);
int write_img(int x, int y, int w, int h, char* filename, IMAGE *img);

/* ========== functions defined in JOYSTICK.S ========== */
int stick(int num); 	/* read joystick status */
void stick_on(void);	/* switch joystick ON  */
void stick_off(void);	/* switch joystick OFF */

/* ========== functions defined in raw.c ========== */
/* read picture in raw format to img->map */
int read_raw(int w, int h, int bpp, char *filename, IMAGE *img);

/* ========== functions defined in seq.c ========== */
/* play Cyber Paint SEQ animation */
int read_seq(int x, int y, int speed, char *filename, IMAGE *img);

/* ========== functions defined in tga.c ========== */
/* read the 24 or 16 bit uncompressed truecolour Targa image */
int read_tga(char *filename, IMAGE *img);
/* write 24 bit Targa image */
int write_tga(char *filename, IMAGE *img);

/* ========== functions defined in true_col.c ========== */
/* -- this module need 16bit (5-6-5) TRUE COLOUR mode -- */
/* set drawing colour */
WORD g_color(WORD c);
/* show RGB value of pixel on mouse position */
void measure_pixel(void);
/* antialiased line */
void aline(int x0, int y0, int x1, int y1);
/* draw Bezier curve */
void bezier(int *xy);
void shaded_box(int start_col, int end_col, int angle, IMAGE *img);

/********************** end of IMGPROC.H ************************/
