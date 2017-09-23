#define M_POINTS 68
int menu_id[] = {	MN_INFO, 	MN_TLOAD, MN_TSAVE, MN_TSVAS, MN_TPRNT, MN_PLOAD,
								  MN_LLOAD, MN_FKILL, MN_DFMT, 	MN_EXIT, 	MN_BLANF, MN_BLEND,
									MN_BLUMK, MN_BLCPY, MN_BLMOV, MN_BLHID, MN_BLCUT, MN_BLPST,
									MN_BLDEL, MN_BLLOD, MN_BLSAV, MN_REPL, 	MN_AGAIN, MN_GOTO,
									MN_CALC, 	MN_RULER, MN_RLNEW, MN_RLDEL, MN_TINFO, MN_NOTE,
									MN_NOTSH,	MN_KFUSS, MN_FNOTE, MN_BOLD, 	MN_ITALC, MN_UNDER,
									MN_LIGHT,	MN_OUTL, 	MN_SUBS, 	MN_SUPER, MN_SONDR, MN_INDEX,
								 	MN_INHLT,	MN_PLATZ,	MN_DATE,	MN_TIME,	MN_CFONT,	MN_CPFNT,
									MN_PAINT, MN_KILLP, MN_BRIEF, MN_EDIT,	MN_TRENN, MN_LEFT,
									MN_RIGHT,	MN_CENTR,	MN_BLOCK,	MN_FORMT, MN_EINR,	MN_FLOSK,
									MN_FTAST,	MN_LAYO, 	MN_LEXON,	MN_LXBEA, MN_LXLOD, MN_LXSAV,
									MN_FLXLD,	MN_FLXSV};

extern int load_text();
extern int quit_prg();
extern int text_info();
extern int save_text();
extern int save_tsva();
extern int prg_info();
extern int set_bold();
extern int set_ital();
extern int set_under();
extern int set_light();
extern int set_outl();
extern int set_sub();
extern int set_super();
extern int falseback();
extern int file_del();
extern int jmp_line();
extern int setsonder();
extern int set_font();
extern int do_paint();
extern int set_pfont();
extern int set_frmt();
extern int set_einr();
extern int do_search();
extern int new_ruler();
extern int do_calc();
extern int set_kfuss();
extern int set_flosk();
extern int set_funkt();
extern int add_pic();
extern int print_txt();
extern int d_format();
extern int rul_onoff();
extern int new_note();
extern int dsp_notes();
extern int kill_pic();
extern int del_ruler();
extern int swtch_brf();
extern int swtch_edt();
extern int set_inhlt();
extern int writ_date();
extern int writ_time();

int (*rout[])() = {prg_info, load_text,save_text,save_tsva,print_txt,	 add_pic,
												 0L,	file_del, d_format, quit_prg,				0L,				0L,
												 0L,				0L,				0L,				0L,				0L,				0L,
												 0L,				0L,				0L,do_search,				0L, jmp_line,
										do_calc, rul_onoff,new_ruler,del_ruler,text_info,	new_note,
									dsp_notes, set_kfuss,				0L,	set_bold,	set_ital,set_under,
									set_light,  set_outl,	 set_sub,set_super,setsonder,				0L,
									set_inhlt,	 		  0L,writ_date,writ_time,	set_font,set_pfont,
									 do_paint,	kill_pic,swtch_brf,swtch_edt,				0L,				0L,
												 0L,			  0L,			  0L, set_frmt,	set_einr,set_flosk,
									set_funkt,				0L,  			0L,  			0L,				0L,				0L,
												 0L,        0L};
