#if  !defined( __EXPORT__ )
#define __EXPORT__

#include <fiodef.h>

typedef struct _EXP_FORM
{
	int		f_id;			/* Id des Exportformats */
	char name[26];	/* Name des Formats, max 24 Zeichen */
	
	long	base_id;	/* ID des Basisformat-Moduls */
	int		depth;		/* Farbtiefe:
											0=1 Bit S/W
											1=4 Bit 16 Farben
											2=8 Bit 256 Graustufen
											3=8 Bit 256 Farben
											4=24 Bit RGB
											5=24 Bit CMY
											6=32 Bit CMYK
									*/
	int		compress;	/* Kompressionsmethode -1 oder Index
											in das Array des Moduls */
											
	int		opts[8];	/* Jeweils -1 oder Optionswert
											0=nicht selektiert, 1=selektiert
											oder Popupindex */
	
	struct _EXP_FORM	*next;
}EXP_FORM;


void dial_export(int ob);
void export_window(void);
void dial_fexport(int ob);
void fexport_window(void);
void dial_fxsave(int ob);
void fxsave_window(void);

void check_what_export(void);

void exp_form_popup(WINDOW *root, int ob);

void init_fexport(void);
void redraw_formatbox(void);
int	 first_support(uchar formats);
void set_act_sel(void);

void base_pop(void);
void bit_pop(void);
void comp_pop(void);
void opt_pop(int opt);
int  do_popup(WINDOW *root, int parent, OBJECT *pop);

void new_format(void);
void new_baseform(void);
void delete_format(void);
void get_format(int a);
void set_format(int a);

void copy_list2set(int a);
void copy_set2list(int a);

int	count_formats(void);
EXP_FORM *get_format_by_index(int ix);



extern OBJECT *oexport, *ofexport, *ofxsave;
extern WINDOW wexport, wfexport, wfxsave;
extern DINFO dexport, dfexport, dfxsave;

extern EXP_FORM *first_expf;

extern int expf_id;
#endif