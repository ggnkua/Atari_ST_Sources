
struct neo_head
{
	int type;  /* 0 for neo, 1 for programmed pictures, 2 for cels? */
	int resolution; /*0 lores, 1 medium, 2 hires*/
	int colormap[16];
	char filename[8+1+3];
	int ramp_seg; /*hibit active, bits 0-3 left arrow, 4-7 right arrow*/
	char ramp_active;  /*hi bit set if actively cycled*/
	char ramp_speed;  /*60hz ticks between cycles*/
	int slide_time;  /*60hz ticks until next picture*/
	int xoff, yoff;  /*upper left corner of cel*/
	int width, height; /*dimensions of cel*/
	char	op;		/* xor this one, copy it? */
	char	compress;	/* compressed? */
	long	data_size;		/* size of data */
	char reserved[30];	/* Please leave this zero, I may expand later */
	char pad[30]; /* You can put some extra info here if you like */
};

struct degas_head
	{
	int res;
	int colormap[16];
	};
extern char *get_fname();	/* request file name from user */

