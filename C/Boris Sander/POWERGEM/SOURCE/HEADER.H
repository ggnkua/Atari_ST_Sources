#define OWNMSG 0x500

void empfaenger(int msgbuff[8]);
void exit_prg(void);
void draw_desk_box(int x, int y, int mb, int ks);
void draw_win_box(struct WINDOW *win, int x, int y, int mb, int ks);
void show_info(void);
void show_dial(void);
void show_beep(void);
void show_grafik(void);
void show_text(void);
void init_text(void);

