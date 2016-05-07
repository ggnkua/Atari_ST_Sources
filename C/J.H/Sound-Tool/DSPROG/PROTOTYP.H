/* ANA_SAM.c */
long check_sam(char *o_bytes, long total);

/* COOKIE.c */
void cookie_chk(void);
int get_cookie(unsigned long cookie, unsigned long *value);

/* DHFT.c */
void load_sinus(void);
void init_dfht(int new_stages);
int sinus(int step);
int cosinus(int step);
void bit_reverse(long *pfeld);
void stage_1(long *sfeld, long *dfeld);
void stage_2(long *sfeld, long *dfeld);
int stage_x(long *sfeld, long *dfeld, int ist_x, int flg);
void dfht(long *pdaten, int stellen, int richtung);
long power(long *sfeld, long *dfeld);

/* DHFT_ADD.s */
long dhft_add(int sin, int cos, long c, long b, long a);
long dhft_pow(long a, int div);

/* DIALOG.c */
int search_dw(int w_handle);
int exclusiv_dialog(DIALOG *new_dia);
void new_diaset(DIALOG *new_dia, int x, int y);
void new_dialog(DIALOG *new_dia);
void new_dialog2(DIALOG *new_dia, int w_handle);
void dialog_redraw(int w_handle, int start, int r_x, int r_y, int r_w, int r_h);
void force_oredraw(int w_handle, int obj);
void dialog_reopen(int i_handle);
int dialog_close(int w_handle);
void dialog_delete(int i_handle);
void dialog_move(int w_handle, int flg);
void dialog_button(void);
void dialog_default(void);
void dialog_edit(int key);
void get_curstate(DIALOG *new_dia);
void set_curstate(DIALOG *new_dia);
int okay_but(void);
int cancel_but(void);
void dialog_update(void);
int error(char *s1, char *s2, int but);

/* FOPTIONS.c */
void set_foptions(void);

/* ICONS.c */
void init_icons(void);
void new_icon(int no, char *text, int ic_no, int x, int y);
void set_iconpos(int no, int x, int y);
void delete_icon(int no);
int search_freeicon(void);
void icon_use(void);
void unmark_icons(void);

/* INIT.c */
void initialize(void);

/* IO.c */
int select_sample(char *fname, char *title, char *ext);
int getfree_entry(char *o_bytes, char *fname, long total);
void open_sample(int idx, long total);
void load_sample(void);
void load_in_sample(char *fname);
void save_sample(void);
void save_out_sample(char *fname, char *o_bytes, long total);
void save_avr(void);
void save_smp_avr(char *fname, char *o_bytes, long total);

/* MAIN.c */
void open_vwork(void);
void set_options(void);
int menu_action(void);
int action_key(int kr, int *ex);
int check_action(void);
void main(int argc, char *argv[]);

/* MWIRE.c */
int mvol_scale(void);
int lvol_scale(void);
int rvol_scale(void);
int treb_scale(void);
int bass_scale(void);
void init_mwdia(void);
void set_mwsld(int inx);
void mw_move(int inx);
void send_mwire(void);

/* NOISE.c */
void kill_bads(long *p_data, long *o_data, int len);
void analyse_maxsmp(char *o_bytes, long total);
void frq_sink(long *p_data, long *o_data, int len);
void flatten(long *p_data, long *o_data, int len);
void reduce_freq(long *p_data, long *o_data, int len);

/* OBJCDRAW.c */
void init_rsrc(void);
void obj_out(OBJECT *tree, int start, int r_x, int r_y, int r_w, int r_h);
void xobjc_draw(OBJECT *tree, int start, int level, int r_x, int r_y, int r_w, int r_h);
void xdraw_level(OBJECT *tree, int start, int level, int r_x, int r_y, int r_w, int r_h);

/* OPT_IO.c */
void load_options(void);
void save_options(void);

/* OVSM.c */
void do_oversam(void);
void oversamp3(char *o_bytes, long total);
void oversamp2(char *o_bytes, long total);
void overshift(char *o_bytes, long total);

/* PACK.c */
int pkor_dwn(void);
int pkor_up(void);

/* PCK_6K.c */
void init_field(void);
int sgn(char val);
void do_filter(char *mem, long len);
int srch_best(int start, int step, char c1, char c2);
void pack2(char *in_d, char *out_d);
void pack(char *in_d, char *out_d);
void kompakt(int flg);

/* PLAY.c */
void check_play(void);
int popt_psg(void);
int popt_dma(void);
int popt_codec(void);
int popt_ovon(void);
int popt_ovoff(void);
int spd_down(void);
int spd_up(void);
void play_one(void);
void play_onpsg(void);
void play_ondma(void);
void play_oncodec(void);
long codec_connect(long play_spd);
long dma_connect(long play_spd);
void set_dma(long from, long to);
int fill_play_buffer(char **data_poi, long *len_poi, char *buffer, long one_step, int two);

/* PLAY_PSG.s */
start_psg(long timer_tick);

/* SAMPLE.c */
int search_topsw(void);
int search_sw(int w_handle);
int sample_close(int w_handle);
void sample_delete(int i_handle);
void sample_reopen(int i_handle);
void sample_redraw(int wind_id, int rx, int ry, int rw, int rh);
void sample_convert(void);
void change_volume(void);
void sample_statistik(void);
int multi_statistik(void);

/* SND_TYPE.c */
long analyse_sample(char **o_bytes, long total, int flg);
int ask_sndtype(char *o_bytes);

/* SPECTRUM.c */
void to_calcd(char *o_bytes, int len);
void to_chars(char *o_bytes, int len);
void filter(void);
int flt_iconize(void);
void close_flttask(void);
void new_slidlevel(void);
int cdecl power_draw(PARMBLK *paras);
void draw_power(long *pow_dat, int n, int grey);
int flt_task(void);

/* ST_STE.c */
void st_convert(char *snd, long size);

/* TASK.c */
void start_slider(MULTI *adr);
void do_task(void);
void task_delete(MULTI *del_task);

/* UPCK_6K.c */
long unpack4(char *in_d, char *out_d, long cnt);
long unpack4p(char *in_d, char *out_d, long cnt);
char *unkompakt(long *len, char *o_bytes);

/* VOLUME.s */
void vol_calc(char *o_bytes, long len, int vol);

/* WINDOW.c */
int rect_intersect(int x1, int y1, int w1, int h1,
									 int x2, int y2, int w2, int h2,
									 int *rx, int *ry, int *rw, int *rh);
int first_rect(int wind_id, int r_x, int r_y, int r_w, int r_h, int typ);
int next_rect(int wind_id, int typ);
void force_wredraw(int w_handle);
