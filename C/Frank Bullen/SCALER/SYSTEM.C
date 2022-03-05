/* Functions which save/restore system state */

#include "include/system.h"
#include <stdio.h>
#include <assert.h>
#include <tos.h>

void system_save (System_Restore *system)
{
	u_char  *vidHi  = (u_char *)DBASEH;
	u_char  *vidM   = (u_char *)DBASEM;
	u_char  *vidL   = (u_char *)DBASEL;

	u_char  *rez    = (u_char *)SHIFTMD;

	u_short *color0 = (u_short *)COLOR0;
	u_int   i;

	/* screen */
	system->vbaseHigh = *vidHi;
	system->vbaseMed  = *vidM;
	system->vbaseLow  = *vidL;
	/* palette */
	for (i=0; i<COLREGCOUNT;i++)
	{
		system->palette[i]=*color0++;
	}

	/* screen mode */
	system->rez = *rez;


}

void system_restore (System_Restore *system)
{
	Vsync();
	{
		u_char *vidHi = (u_char *)DBASEH;
		u_char *vidM =  (u_char *)DBASEM;
		u_char *vidL =  (u_char *)DBASEL;

		u_char  *rez    = (u_char *)SHIFTMD;
		u_short *color0 = (u_short *)COLOR0;

		u_int   i;

		*vidHi = system->vbaseHigh;
		*vidM  = system->vbaseMed;
		*vidL  = system->vbaseLow;

		for (i=0; i<COLREGCOUNT;i++)
		{
			*color0++ = system->palette[i] ;
		}

		*rez = system->rez;

		printf("system_restore\n");
	}
}



void system_screen_show (System_screen *screen,int type)
{
	Vsync();
	{
		u_char *vidHi = (u_char *)DBASEH;
		u_char *vidM =  (u_char *)DBASEM;
		u_char *vidL =  (u_char *)DBASEL;

		u_short *scrn = NULL;
		u_int    p;
		switch (type)
		{
			case ScreenFront:
				scrn=screen->front;
				break;

			case ScreenBack:
				scrn=screen->back;
				break;

			default:
				assert(1); /* something way wrong */

		}
		p= (u_int)scrn;

		*vidHi = (u_char)(p>>16)&0xff;
		*vidM  = (u_char)(p>>8)&0xff;
		*vidL  = (u_char) p&0xff;

	}
}


/* sets screen mode, allocs screens and set initial palette */
int system_screen_init (u_char         inRez,
                        u_short       *palette,
                        System_screen *screen)
{
	u_char  *rez    = (u_char *)SHIFTMD;
    *rez = inRez;

	if (palette!=NULL)
		memcpy(COLOR0,(u_short *)palette,
		       COLREGCOUNT*sizeof(u_short));
	
	assert(screen->front == NULL);
	assert(screen->back == NULL);
	
	printf("Hitting system screen init\n");
	screen->front = (u_short *)malloc(32000);
	if (screen->front == NULL)
	{
		printf("Malloc of front failed\n");
		sleep_frames(50*4);
		return OUT_OF_MEMORY;
	}
	screen->back = (u_short *)malloc(32000);
	if (screen->front == NULL)
	{
		free(screen->front);
		screen->front=NULL;
		printf("Malloc of back failed\n");
		sleep_frames(50*4);

		return OUT_OF_MEMORY;
	}
	return SUCCESS;
}


void system_screen_finalise(System_screen *screen)
{

	if (screen->front != NULL)
	{
		free(screen->front);
		screen->front = NULL;
	}

	if (screen->back != NULL)
	{
		free(screen->back);
		screen->back = NULL;
	}
}

int gfx_ctx_init_file(char *fname, gfxCtx *inCtx)
{

	FILE *in;
	uint read;
	assert (inCtx != NULL);

	in = fopen(fname,"rb");

	if (in == NULL)
	{
		printf("failed to open file\n");
		sleep_frames(50*4);
		return -1;
	}
	if (fseek(in, 2,SEEK_SET))
	{
		printf("fseek failed\n");
		sleep_frames(50*4);
		fclose(in);
		return -2;
	}

	if (fread(&inCtx->palette[0], sizeof(u_short), 16, in)<16)
	{
		printf("fread 1 failed\n");
		sleep_frames(50*4);

		fclose(in);
		return -3;
	}

#define COUNT (16000)

    read=fread(inCtx->screen,sizeof(u_short),COUNT, in);
	if (read < COUNT)
	{
		printf("fread 2failed, only read %d words\n",read);
		//perror ("The following error occurred");
		sleep_frames(50*4);

		fclose(in);
		return -3;
	}

	system_palette_init(&inCtx->palette[0]);
	fclose(in);

	return 1;
}


int system_palette_init(u_short *in)
{
	int i;
	u_short *color0 = (u_short *)COLOR0;

	for (i=0; i<COLREGCOUNT;i++)
	{
		*color0++= *in++;
	}
}

void gfx_ctx_set_palette(gfxCtx *ctx, u_int *palette)
{
	memcpy(&ctx->palette[0],palette,sizeof(u_short)*16);
}

gfxCtx *gfx_ctx_init(u_int width, u_int height)
{
	u_int buffSize;
	gfxCtx *ctx = (gfxCtx *)calloc( 1,sizeof(gfxCtx));
	if (ctx == NULL)
	{
		printf("Failed to alloc screen context\n");
		return NULL;
	}

	buffSize = (width/16)*8*height;
	printf("buffSize == %d\n",buffSize);
	ctx->screen = (u_short *)calloc( 1,buffSize);
	if (ctx->screen == NULL)
	{
		printf("Failed to alloc screen context-.screen\n");
		sleep_frames(50*4);
		free(ctx);
		return NULL;
	}
	ctx->width    = width;
	ctx->height   = height;
	return ctx;
}


void gfx_ctx_destroy(gfxCtx *in)
{
	if (in != NULL)
	{
		if (in->screen != NULL)
		{
			free(in->screen);
		}
		free(in);
	}
}



void gfx_ctx_to_screen(gfxCtx *in, System_screen *screen, int type)
{

	u_short *scrn = NULL;

	switch (type)
	{
		case ScreenFront:
			scrn=screen->front;
			break;

		case ScreenBack:
			scrn=screen->back;
			break;

		default:
			assert(1);

	}

	memcpy(scrn,in->screen,sizeof(u_char)*32000);
	system_palette_init(&in->palette[0]);

}

