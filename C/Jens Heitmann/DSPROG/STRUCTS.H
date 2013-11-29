typedef struct
							{
							int idx;
							int (*rout)(void);
							}ACTIVATOR;

typedef struct
							{
							int idx;
							int *flg;
							}INDICATOR;

typedef struct
							{
							int f_no;
							char *title;
							int indic_num;
							int activ_num;
							INDICATOR *indic_but;
							ACTIVATOR *activ_but;
							int center;
							int edit_obj;
							int icon_no;
							char *icon_txt;
							
							int crs_idx;
							int next_obj;
							OBJECT *tree;
							int w_handle;
							}DIALOG;

typedef struct
							{
							char *data;
							long len;
							int w_handle;
							char smp_name[MAXPATH];
							char smp_info[17];
							}SOUND;

typedef struct m_task
							{
							int (*task)(void);
							struct m_task *next;
							}MULTI;

typedef struct
							{
							long magic;									/* 2BIT */
							char sample_name[8];
							int modus;									/* 0 = Mono, -1 = Stereo */
							int resolution;							/* 8 = 8Bit, 16 = 16Bit  */
							int sgned;									/* 0 = signed, 1 = unsigned */
							int loop;										/* 0 = loopen, 1 = nicht */
							int midi;										/* -1 */
							long frequenz;							/* Samplefrequenz */
							long laenge;								/* Anzahl samples */
							long loop_anfang;
							long loop_ende;
							int res1;
							int res2;
							int res3;
							char ext[20];								/* Erweiterter Dateiname */
							char reserved[64];
							}AVR_FILE;

