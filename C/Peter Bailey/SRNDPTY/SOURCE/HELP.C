/* ==================================================================== */
/*	Serendipity: Help routines					*/
/* ==================================================================== */

#include	"globals.h"


/* -------------------------------------------------------------------- */
/*	Display a screenful of help					*/
/* -------------------------------------------------------------------- */

screen(t,s)
	char	*t,*s[];
{
	int	d,i,z,h,w;

	v_hide_c(handle);  fade_down();  get_screen();  clr_screen();

	vst_height(handle,8,&z,&z,&w,&h);  vst_color(handle,15);

	d = (320-strlen(t)*w)/2;  v_gtext(handle,d,45,t);

	do_screen(s);  put_screen();  fade_up();  v_show_c(handle,1);
}


/* -------------------------------------------------------------------- */
/*	Display text screen						*/
/* -------------------------------------------------------------------- */

do_screen(s)
	char	*s[];
{
	int	d,i,w,h,z;

	vst_height(handle,6,&z,&z,&w,&h);  vst_color(handle,14);  i=0;

	while (*s[i])
		{ d=(320-strlen(s[i])*w)/2; v_gtext(handle,d,50+h*i,s[i++]); }

	fade_up();  mouse(&z,&z);  fade_down();  clr_screen();
}


/* -------------------------------------------------------------------- */
/*	Global-level help						*/
/* -------------------------------------------------------------------- */

global_help()
{
	help_flag=1; screen("DEBATABLE HELP",help_1); help_flag=0;
}


/* -------------------------------------------------------------------- */
/*	Help during a game						*/
/* -------------------------------------------------------------------- */

game_help()
{
	help_flag=1; screen("AN ATTEMPT TO CONFUSE",help_2); help_flag=0;
}


/* -------------------------------------------------------------------- */
/*	The mug hit the "Don't click" button				*/
/* -------------------------------------------------------------------- */

trouble()
{
	help_flag=1; screen("NOW YOU'VE DONE IT!",panic_mess); help_flag=0;

	panic=1;
}


/* -------------------------------------------------------------------- */
/*	Extended game introduction					*/
/* -------------------------------------------------------------------- */

show_info()
{
	static char t[] = "INTRODUCTION";

	int	d,z,w,h;


	help_flag=1;

	v_hide_c(handle);  fade_down();  get_screen();  clr_screen();

	vst_height(handle,8,&z,&z,&w,&h);  vst_color(handle,15);

	d = (320-strlen(t)*w)/2;  v_gtext(handle,d,45,t);

	do_screen(info_1); do_screen(info_2);
	do_screen(info_3); do_screen(info_4);

	put_screen();  fade_up();  v_show_c(handle,1);  help_flag=0;

}
