														/***** DFHT Definitionen *****/
int error(char *s1, char *s2, int but);
void load_sinus(void);
void dfht(long *pdaten, int stellen, int richtung, int inf);
long power(long *sfeld, long *dfeld);
void to_calcd(char *o_bytes, int len);
void to_chars(char *o_bytes, int len);
void init_stage(int all_stages);
void set_stage(void);
void filter(void);

void kill_bads(long *p_data, long *o_data, int len);
void frq_sink(long *p_data, long *o_data, int len);
void flatten(long *p_data, long *o_data, int len);
void reduce_freq(long *p_data, long *o_data, int len);
void analyse_maxsmp(void);

void do_oversam(void);
void oversamp3(void);
void oversamp2(void);

int sgn(char val);
void init_field(void);
void do_filter(char *mem, long len);
int srch_best(int start, int step, char c1, char c2);
void pack2(char *in_d, char *out_d);
void pack(char *in_d, char *out_d);
void set_pcksld(long akt, long all, long size);
void kompakt(int flg);

long unpack4(char *in_d, char *out_d);
long unpack4p(char *in_d, char *out_d);
void unkompakt(void);

void open_vwork(void);

int select_sample(void);
void load(int flg);
void save_part(int flg, char *start, long len);
void save_file(char *fname, char *start, long len);
void analyse_sample(int flg);

void convert(void);
void set_loud(void);
void vol_calc(int val);

void set_dirpath(OBJECT *tree, char *p);
void dir_edit(void);
void start_edit(void);

void exec_batch(char *bat);
void do_batch(void);

void panel_koor(void);
void panel_window(void);
void panel_redraw(int wind_id);
int open_window(int kind, int w_x, int w_y, int w_w, int w_h, char *t);
void sample_window(void);
void sample_redraw(int wind_id);
void sample_name(char *nam_p);
int first_rect(int wind_id, int typ);
int next_rect(int wind_id, int typ);

int next_index(OBJECT *tree, int obj, int *d, int deepth);
int find_obj(OBJECT *tree, int start_obj);
int fm_inifld(OBJECT *tree, int start_fld);
int win_formdo(OBJECT *tree, int start_fld, int wind_id);
int dialog_window(int wind_id, OBJECT *dialog, int action, int ext);
int dialog(OBJECT *dial);
void redraw_obj(OBJECT *tree, int idx);
void press_button(OBJECT *tree, int idx);

void cookie_chk(void);
int get_cookie(unsigned long cookie, unsigned long *value);

void dma_play(char *from, char *to);
void play(char *play_mem, long len);
void start_psg(long timer);

void select_rate(void);
void select_output(void);
void select_cval(void);
int ask_sndtype(void);
void do_info(void);
void send_mwire(void);
void mw_move(OBJECT *tree, int hndl, int inx);
void set_mwsld(OBJECT *tree, int inx);
void set_mwire(void);

void check_sample(void);

long get_wave(long pos);
void sequencer(void);

void sequenz_cmp(void);
void load_plan(void);

int check_list(int obj, int *name_idc, long akt_pos, long max_pos);
void seqs_work(int mx, int my, int clicks);
void set_seqs(int direction, int flg);
void seqs_redraw(int wind_id);
void seqs_close(int wind_id);
void seq_list(void);
void seqs_koor(void);
