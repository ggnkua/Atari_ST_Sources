/* zu exportierende Makros */

#define MIN(A,B) ((A) < (B) ? (A) : (B))
#define MAX(A,B) ((A) > (B) ? (A) : (B))

#define MAUS_EIN graf_mouse(257,0)
#define MAUS_AUS graf_mouse(256,0)
#define MAUS_HAND graf_mouse(3,0)

/* zu exportierende Prototypen */

int  graf_init(void);
void recht_eck(int xanf, int yanf, int breite, int hoehe,int rahmen);
int  video_mode(void);
void save_rechteck(int x_pos, int y_pos, int breite, int hoehe);
void restore_rechteck(int x_pos, int y_pos, int breite, int hoehe);
