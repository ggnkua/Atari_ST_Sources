/* Zoom-Hinweise: main_win.ox/oy sind Bildschirm-absolut!
   D.h. um ein 400-Pixel Bild in Normalmodus ab halber H”he
   zu sehen ost oy=200 n”tig, in zoomout=1 aber nur oy=100
*/

#define MZOP (zoomout+1) / (zoomin+1)
#define DZOP (zoomout+1) * (zoomin+1)
#define ZIP (zoomin+1)
#define ZOP (zoomout+1)

extern int zoomout, zoomin, first_zix, first_ziy, add_x, add_y;
extern int off8_x, off8_y;

extern OBJECT *ozoom, *ofzooms;
extern WINDOW wzoom, wfzooms;
extern DINFO dzoom, dfzooms;

void free_zoom_in(int wid);
void free_zoom_out(int wid);

void dial_zoom(int ob);
void zoom_window(void);
void dial_fzooms(int ob);
void fzooms_window(void);

void zoom_in(void);
void zoom_out(void);
void set_zoom(int in_out);
void fit_zoom(void);
void set_menu_zoom(int ob);

void fzooms_to_menu(void);
void menu_to_fzooms(void);
