/*
  vq_color()
*/

#include <gemdefs.h>

int contrl[12];
int intin[256],  ptsin[256];
int intout[256], ptsout[256];

/*
	This is for saving and restoring color values
*/
int tmp_rgb[16][3];

main()
{
	MFDB	source;
	int		handle;

	/*
		Start up ROM.
	*/
	appl_init();
	handle = open_workstation(&source);

	/*
		Do neat things.
	*/
	save_colors(handle);
	fade_to_black(handle);
	restore_colors(handle);

	/*
		Wait & Close the virtual workstation.
	*/
	wait(handle);
	v_clsvwk(handle);
	appl_exit();
}

#define SET  1
#define ACTUAL   1

#define RED   0
#define GREEN 1
#define BLUE  2

fade_to_black(handle)
int handle;
{
    int rgb[3];
    int color;

	/*
		For each color
	*/
    for (color=0; color<16; color++) {
        vq_color(handle, color, ACTUAL, rgb);
       
        /*
            Fade each color gun value
        */
        while(rgb[RED] | rgb[GREEN] | rgb[BLUE]) {
            if (rgb[RED])   rgb[RED]--;
            if (rgb[GREEN]) rgb[GREEN]--;
            if (rgb[BLUE])  rgb[BLUE]--;

            vs_color(handle, color, rgb);
        }
    }   
}

save_colors(handle)
	int handle;
{
    int color;

	/*
		Save current values for Red, Green, and Blue
	*/
    for (color=0; color<16; color++)
		vq_color(handle, color, SET, tmp_rgb[color]);

}

restore_colors(handle)
	int handle;
{
    int color;

	/*
		Restore previous values
	*/
    for (color=0; color<16; color++)
		vs_color(handle, color, tmp_rgb[color]);

}

