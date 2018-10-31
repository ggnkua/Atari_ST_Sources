#ifndef _EXTRAS_H_
#define _EXTRAS_H_

#define MagX_cookie		0x4D616758
#define	AES_single	0
#define	AES_MagiC	1
#define	AES_Geneva	2
#define	AES_MTOS	3
#define	AES_nAES	4

#define	_cookies	((long **) 0x5A0L)

/* cookie jar entry struct */
typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

extern void construct_path(char *dest,const char *path,const char *name);
extern long getcookie(long cookie_name);
extern int identify_AES(void);
extern void save_colors(RGB1000 *colortab);
extern void reset_colors(RGB1000 *colortab);
extern void iconify(int window_info, GRECT *new_size);
extern void un_iconify(int window_info,GRECT *new_size);
extern void set_tedinfo(OBJECT *tree,int obj,char *source);
extern void get_tedinfo(OBJECT *tree,int obj,char *dest);
extern void set_edits(OBJECT *tree, int object,char *source);
extern void paste_text(int w_info);

#endif