#define INF_VERSION	"0042"

#define DEF_BUTT_MENU				1
#define DEF_BUTT_SHOW				2
#define DEF_BUTT_ICON				3
#define DEF_BUTT_ICON_ALL		4
#define DEF_BUTT_DEICON			5
#define DEF_BUTT_FREEZY			6
#define DEF_BUTT_KILL				7
#define DEF_BUTT_NIX				8
#define DEF_BUTT_UNFREEZY		9
#define DEF_BUTT_SHOW_ALL		10
#define DEF_BUTT_HIDE				11
#define DEF_BUTT_HIDE_OTHER	12
#define DEF_BUTT_QUIT				13
#define DEF_BUTT_TERMINATE	14
#define DEF_BUTT_VER_VOR		15
#define DEF_BUTT_VER_DAU		16
#define DEF_BUTT_PRIORITY		17
#define DEF_BUTT_TOP				18
#define DEF_NAME						-1
#define DEF_MEMORY					-2
#define DEF_FENSTER					-3
#define DEF_SEPARATOR				-4

#ifndef MAX_BENUTZER_POPUP
	#define MAX_BENUTZER_POPUP	25
	struct _popup_menu
		{
		char *text;				/* Tekst do wyswietlenia w popup	*/
		int aktion;				/* Nr akcji do przeprowadzenia:
											-1 - nazwa
											-2 - ilosc pamieci
											-3 - spis okien
											-4 - separator		*/
		};
#endif

struct _options
	{
	char language;
	char savelinks;
	char noquitalert;
	char dhstcookie;
	char html_separat;
	char autohide;
	char avnoacc;
	char drives;
	char documents;
	char tosmultistart;
	char magxfadeout;
	char avignore;
	char avnotos;
	char vaprotostatus;
	char acc_in_system_tray;					/* Czy ACC pokazywac w System Tray	*/
	char autotop;
	char rsc[128];										/* Sciezka dostepu do zewn. pliku RSC		*/
	int start_rsc_obj;								/* Nr obiektu w pliku RSC dla START			*/
	int app_rsc_obj;									/* Nr obiektu w pliku RSC dla aplikacji	*/
	int time_rsc_obj;									/* Nr obiektu w pliku RSC dla zegarka		*/
	int main_rsc_obj;									/* Nr obiektu w pliku RSC dla MyTask		*/
	char start_icon_text;							/* Tekst w ikonce w przycisku START?		*/
	char app_icon_text;								/* Tekst w ikonce w przycisku aplikacji?*/
	char klicks[4][3];								/* [0][1.2] - Bez dodatkowego przycisku
																			 [1][1.2] - + Shift
																			 [2][1.2] - + Alt
																			 [3][1.2] - + Control
																		*/
	char doppel_klicks[4][3];					/* j.w. tylko dla podwojnego tupniecia myszka :)
																			 [0][1.2] - Bez dodatkowego przycisku
																			 [1][1.2] - + Shift
																			 [2][1.2] - + Alt
																			 [3][1.2] - + Control
																		*/
	int w, h;
	char col_app, col_acc, col_sys, col_shell;
	char col_b_app, col_b_acc, col_b_sys, col_b_shell;
	char col_caps_on, col_caps_off;
	char col_t_caps_on, col_t_caps_off;
	char tex_app, tex_acc, tex_sys, tex_shell;
	char tex_caps_on, tex_caps_off;
	char frezzy_effect, hidden_effect;
	char frezzy_txt_color, frezzy_back_color;
	char hidden_txt_color, hidden_back_color;
	int loop_time;
	char fenster_name_mit_handler;		/* Czy w nazwie okienka pokazywac tez nr okienka?							*/
	char draw_obj;										/* Czy rysowac ramki tego co bedzie przerysowywane?
																			 Standardowo MUSI to byc ustawione na 0,
																			 jezeli MyTask jest uruchamiane z wcisnietym CONTROL ustawia sie to na 1	*/
	char stic;												/* Czy uzywac ikonek StIc czy firmowych MyTask w APP_TRAY			*/
	char stic_app_button;							/* Czy wyswietlac ikonki na przyciskach aplikacji?
																				0 - tylko tekst
																				1 - tekst + ikonki
																				2 - tylko ikonki
																		*/
	char stic_popup;									/* Czy wyswietlac ikonki w popup?															*/
	char time_mode_1[15], time_mode_2[15];			/* time_mode_1 - co wypisac w gornej linijce
																						 time_mode_2 - co wypisac w dolnej linijce
																						 %t - [t]ime
																						 %d - [d]ay
																						 %D - [D]ay as text
																						 %m - [m]onth
																						 %M - [M]onth as text
																						 %y - [y]ear
																						 %r - memo[r]y
																						*/

	char myconf_path[1000];
	char doppelklick_time;
	char doppelklick_time_path[1000];
	char name[20];
	struct _popup_menu popup_app_menu[MAX_BENUTZER_POPUP];
	};
extern struct _options options;
extern short wx,wy,ww,wh;
extern	int       system_,
            menu_id,
            ap_id,
            colors,
            extmagxmenu,
            helpid,
            avserver,
            gsapp,
            appline,
            applinepos,
            wmclosed,
            btnidx,
/*            extrsc,	*/
            broadcast,
            dobroadcast,
            shuttimeout,
            docmax,
            docmaxperapp,
            nowindow,
            applications,
            cpx,
            appmax,
            desktop,
            apterm,
            untop,
            hidden,
            show_all_app,
            transparent;
extern int language;
extern  int deskcol;
