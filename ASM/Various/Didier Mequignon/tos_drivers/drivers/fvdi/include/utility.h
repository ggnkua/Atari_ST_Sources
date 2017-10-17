#ifndef UTILITY_H
#define UTILITY_H
/*
 * fVDI utility function declarations
 *
 * $Id: utility.h,v 1.6 2005/07/10 00:13:55 johan Exp $
 *
 * Copyright 2003, Johan Klockars 
 * This software is licensed under the GNU General Public License.
 * Please, see LICENSE.TXT for further information.
 */

long init_utility(void);

/*
 * Memory access
 */
long get_protected_l(long addr);
void set_protected_l(long addr, long value);
long get_l(long addr);
void set_l(long addr, long value);

/*
 * Cookie and XBRA access
 */
long get_cookie(const unsigned char *cname, long super);
long set_cookie(const unsigned char *name, long value);
long remove_xbra(long vector, const unsigned char *name);
void check_cookies(void);

/*
 * Memory pool allocation (from set of same sized blocks)
 */
long initialize_pool(long size, long n);
char *allocate_block(long size);
void free_block(void *addr);


/*
 * Memory/string operations
 */
void copymem(const void *s, void *d, long n);
void setmem(void *d, long v, long n);
void copy(const char *src, char *dest);
void cat(const char *src, char *dest);
long length(const char *text);
long equal(const char *str1, const char *str2);

/*
 * Character numerics
 */
long numeric(long ch);
long check_base(char ch, long base);
long atol(const char *text);
void ltoa(char *buf, long n, unsigned long base);
long str2long(const unsigned char *text);

/*
 * General memory allocation
 */
void *fmalloc(long size, long type);
void *malloc(long size);
void *realloc(void *addr, long new_size);
long free(void *addr);
long free_all(void);

/*
 * Text output
 */
int puts(const char *text);
void error(const char *text1, const char *text2);
#define puts_nl(text)	{ puts(text); puts("\x0a\x0d"); }

/*
 * Token handling
 */
const char *next_line(const char *ptr);
const char *skip_space(const char *ptr);
const char *skip_only_space(const char *ptr);
const char *get_token(const char *ptr, char *buf, long n);

/*
 * Miscellaneous
 */
long misc(long func, long par, const char *token);
void flip_words(void *addr, long n);
void flip_longs(void *addr, long n);
void initialize_palette(Virtual *vwk, long start, long n,
                        short colours[][3], Colour *palette);
void cache_flush(void);
long get_size(const char *name);

/*
 * VDI/AES
 */
short appl_init(void);
short appl_exit(void);
long wind_get(void);
short graf_handle(void);
short call_v_opnwk(long handle, short *int_out, short *pts_out);
short scall_v_opnwk(long handle, short *int_out, short *pts_out);
short call_v_opnvwk(long handle, short *int_out, short *pts_out);
short call_v_clsvwk(long handle);
void vq_extnd(long handle, long info_flag, short *int_out, short *pts_out);
void vq_color(long handle, long colour, long flag, short *int_out);
void set_inout(short *int_in, short *pts_in, short *int_out, short *pts_out);
void vdi(long handle, long func, long pts, long ints);
void sub_vdi(long handle, long func, long pts, long ints);
void fvdi(long handle, long func, long pts, long ints);
long get_sub_call(void);
long vq_gdos(void);
short call_other(VDIpars *pars, long handle);

/*
 * Fonts
 */
long fixup_font(Fontheader *font, char *buffer, long flip);
long unpack_font(Fontheader *header, long format);
long insert_font(Fontheader **first_font, Fontheader *new_font);
Fontheader *load_font(const char *name);

/*
 * Maths
 */
short Isin(short angle, long rad);
short Icos(short angle, long rad);
#define ABS(x)    (((x) >= 0) ? (x) : -(x))
#define MIN(x,y)  (((x) < (y)) ? (x) : (y))
#define MAX(x,y)  ((x) > (y) ? (x) : (y))

#endif

