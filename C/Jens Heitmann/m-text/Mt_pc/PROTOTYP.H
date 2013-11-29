void d_format(void);
void do_calc(void);
int file_del(void);
void swtch_edt(void);
void swtch_brf(void);
void edit(int key);
unsigned char *go_back(unsigned char *line_adr);
void get_eline(void);
int skip_control(void);
int skip_cont_ab(int j, int i);
void set_checks(void);
void set_eline(void);
void calc_align(void);
void new_note(void);
void remove_one(unsigned char *kil_adr, long len);
void writ_time(void);
void writ_date(void);
void set_inhlt(void);
int calc_bytes(int t, int s, int sd);
void do_dformat(int drv, int trks, int sect, int sid);
void do_search(void);
void set_font(void);
void show_testtext(int xpos, int ypos, int font_nr, int font_hg);
int load_font(int font_nr);
int load_font_in(char *font_path, int font_nr);
void inst_font(void);
void set_pfont(void );
void remove_font(int font_nr);
void remove_allf(int id);
void text_info(void);
void jmp_line(void);
void setsonder(void);
void set_frmt(void);
void set_einr(void);
void set_kfuss(void);
void prg_info(void);
long calc_words(unsigned char *adr, long len);
int dialog(int f_edit);
void form_end(void);
void form_draw(void);
void f_dial(int type);

/* MT_EDIT.C */
void swtch_edt(void);
void swtch_brf(void);
void edit(int key);
unsigned char *go_back(unsigned char *line_adr);
void get_eline(void);
int skip_control(void);
int skip_cont_ab(int j, int i);
void set_checks(void);
void set_eline(void);
void calc_align(void);
void line_redundanz(void);
void add_empty(void);
void insert_bytes(int des, char *src, int len);
move_mem(char *von, int dif);
move_meml(char *von, long dif);
void calc_ccol(void);
void set_sstyle(int type);
void set_fontd(int fontnr, int fonthg);
int calc_clen(char *adr);
int note_len(unsigned char *line_adr);
int line_len(unsigned char *line_adr);
void calc_slider(void);
void do_slider_calc(void);
void set_cursor(void);
void note_click(int p);
void inhlt_click(int p);
void calc_cofx(int xd);
void new_note(void);
void remove_one(unsigned char *kil_adr, long len);
void set_inhlt(void);
void writ_date(void);
void writ_time(void);

/* MT_FUNKT.C */
void set_flosk(void);
void set_funkt(void);

/* MT_IFF.C */
void get_iff(void);
void packed(char *two);
void normal(char *two);
void add_iffbyt(unsigned char *b_adr, int b_anz);

/* MT_IMG.C */
void get_img(void);
void first_zero(void);
void v_rep(void);
void pattern(unsigned char anz);
void n_bytes(void);
void solid_run(char sol);
void add_imgbyt(unsigned char *b_adr, int b_anz);

/* MT_IO.C */
int load_text(void);
void restyle_notes(void);
void load_txt_fonts(void);
void open_txtw(int i);
void init_new(int index);
void save_tsva(void);
void save_text(void);
void lock_notes(void);
void unlock_notes(void);
void load_info(char *string, int typ);

/* MT_LASER.C */
int min(int a, int b);
int max(int a, int b);
int pt_inrect(int x, int y, int x1, int y1, int w1, int h1);
int rect_intersect(int wx, int wy, int ww, int wh, GRECT r_rec, GRECT *red_rc);

/* MT_MAIN.C */
void open_vwork(void);
void cls_vwork(void);
void main(void);
void button_mesag(void);
void key_mesag(void);
void send_floskel(void);
void send_funkt(void);
void mn_action(void);
void look_alternate(unsigned int key);
void look_control(int key);
void funk_blink(int ind);
void redraw_w0(int ind);
void install_prg(void);
void leave_prg(void);
void init_mtext(void);
void init_rsc(void);
int fsel(char *st_path, char *ext);
int get_whandle(int w_handle);
void load_cfg(void);
void menu_on(void);
void quit_prg(void);
void get_date(char *s_adr);
void get_time(char *s_adr);
void make_asc(long zahl, long teiler, char *adr);
void make_rasc(long zahl_r, long teiler_r, char *adr_r);
void mouse_off(void);
void mouse_on(void);
void get_work(int handle);

/* MT_NOTE.C */
void dsp_notes(void);
get_notes(unsigned char *array[12], long *line_num, unsigned char *start, long l, short dir);
void note_dialog(unsigned char *line_adr);

/* MT_PACK.C */
unsigned int bin_len(int word);
long bitting(unsigned char *mem1, unsigned char *mem2, long len1);
long pack_b(unsigned char *mem1, unsigned char *mem2, int (*byt_map)[2], long len1);
void set_bits(unsigned char *mem2, long *akt_bit, unsigned int wert);
long packing(unsigned char *mem1, unsigned char *mem2, long len1);
void pack_a(unsigned char *mem1, unsigned char *mem2, long *len2, long len1);
int count_folge(unsigned char *mem1, long ab, long len1);
int count_same(unsigned char *mem1, long ab, long len1);
int count_words(unsigned char *mem1, long ab, long len1);
void clear_bytes(int (*byt_map)[2]);
void count_bytes(unsigned char *adr, long num, int (*byt_map)[2]);
void sort_bytes(int (*byt_map)[2]);
void write_pack(unsigned char *in, long in_len, int f_handle);

/* MT_PAINT.C */
void draw_a_line(int flg, int *xy);
void draw_a_box(int flg, int *xy);
void draw_a_circle(int flg, int *xy);
void draw_a_ellip(int flg, int *xy);
void do_paint(void);
void draw(void (*rout)(), int flg);

/* MT_PIC.C */
unsigned char *search_pic(int *height, int *width, int *y);
void move_pic(void);
void load_pictures(void);
void load_picin(char *pic_block, int inf_typ);
void add_pic(void);
void kill_pic(void);
void remove_pic(unsigned char *pic_adr);
void remove_all(int id);

/* MT_PRINT.C */
void print_txt(void);

/* MT_RULER.C */
void rul_onoff(void);
void edit_ruler(unsigned char *lineal_adr);
void get_lineal(char *adr);
void search_lineal(unsigned char *adr);
unsigned char *searchl_it(unsigned char *adr);
void add_ruler(unsigned char *l_adr);
void pack_ruler(unsigned char *p_adr);
void set_tab(void);
void new_ruler(void);
void edit_aktruler(void);
void del_ruler(void);

/* MT_SCREN.C */
void erase_wind(int w_handle);
void redraw(int w_handle, int rx, int ry, int rw, int rh);
void clr_wind(GRECT rc);
void clip(GRECT rc);
void draw_lineal(int w_id, int wx, int wy, int ww);
void draw_backl(int w_id, int wx, int wy);
void draw_backp(unsigned char *l_adr, int wx, int w_id);
void text_out(int w_id, int wx, int wy, int wh);
unsigned char *show_oneline(unsigned char *adr, unsigned char *text_end, int mod, int w_id);
void show_notemark(void);
void show_inhaltmark(void);
void show_char(unsigned char chr);
void draw_border(int w_id, int dx, int dy, int dh);
void show_cursor(int wx, int wy, int w_id);
void show_eline(void);
void show_eline_ab(int ab);
void set_fullclip(void);
void push_down(void);
void copy_block(int x1, int y1, int w, int h, int x2, int y2);
void show_pic(unsigned char *adr);
void full_redraw(void);

/* MT_TOPER.C */
void kill_line(void);
void go_vpos(int pos);
void go_end(void);
void beg_pgup(void);
void beg_pgdwn(void);
void beg_oneup(void);
void beg_onedown(void);
void set_paragraph(void);
void del_char(void);
void write_char(int key);
void go_textbeg(void);
void go_screenb(void);
void goto_line(long ln);
void line_down(void);
void line_up(void);
void char_right(void);
void char_left(void);
void cursor_toend(void);
void cursor_tobeg(void);
void set_bold(void);
void set_ital(void);
void set_under(void);
void set_light(void);
void set_outl(void);
void set_sub(void);
void set_super(void);

/* MT_UNPCK.C */
long un_bit_it(unsigned char *mem1, unsigned char *mem2, long len, int *ubyt_map);
long un_bit(unsigned char *mem1, unsigned char *mem2, long in_len);
int get_bits(unsigned char *mem1, long *akt_bit, long max);
long same_words(unsigned char *mem1, unsigned char *mem2, long ab, long len1);
long same_most(unsigned char *mem1, unsigned char *mem2, long ab, long len1);
long same(unsigned char *mem1, unsigned char *mem2, long ab, long len1);
long do_folge(unsigned char *mem1, unsigned char *mem2, long ab, long len1);
long unpack_a(unsigned char *mem2, unsigned char *mem1, long anz);
long unpack(unsigned char *mem1, unsigned char *mem2, long in_len);
long read_pack(char *out, int f_handle);



