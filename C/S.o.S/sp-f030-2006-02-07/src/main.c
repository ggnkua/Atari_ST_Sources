/*
    Copyright (c) 2005 Peter Persson

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
/*
    Changelog
    2005-11-20	Created (Peter Persson)
    2005-12-03 Misc. minor changes (Peter Persson)
    2006-01-15 Rewrote main emulation loop (Peter Persson)
    2006-02-07 Updated to SMS+ v1.2

*/

#include "osd.h"

/* Options */
int frameskip =1;
int state_slot = 0;

/* Game file name */
char game_name[PATH_MAX];

int main(int argc, char **argv)
{

	int i;
	
	/* Print help if no game specified */
	if(argc < 2)
	{
		printf("\n%s\n", APP_NAME);
		printf("Copyright (C) Charles MacDonald 1998-2003\n");
		printf("Version %s, build date: %s, %s\n", APP_VERSION, __DATE__, __TIME__);
		printf("F030 port by Peter Persson (pedda_pirat@hotmail.com)\n");
		printf("Video init/exit code from DHS demosystem\n");
		printf("IKBD stuff by Patrice Mandin\n");		
		printf("C2P stuff by Mikael Kalms\n\n");		

		printf("Usage: sp.ttp <filename.ext> [-options]\n");
		printf("Type 'sp.ttp -help' for a summary of the available options\n");
		exit(1);
	}
	
	/* Show option list */
	if(stricmp(argv[1], "-help") == 0)
	{
		printf("Options:\n");
		printf(" -jp          \t use Japanese console type.\n");
		printf(" -fskip <n>   \t specify frameskip value.\n");
		printf(" -depth <n>   \t specify color depth. (8, 16)\n");
		printf(" -codies      \t force Codemasters mapper.\n");
		printf(" -pal         \t force PAL (50Hz) operation (experimental).\n");
		printf(" -ntsc        \t force NTSC (60Hz) operation.\n");
		exit(1);
	}
	
	/* set defaults */
	sms.use_fm = 0;
	sms.save = 0;
	memset(&bitmap, 0, sizeof(bitmap_t));
	bitmap.depth = 8;

	/* Make copy of game filename */
	strcpy(game_name, argv[1]);

	/* Attempt to load game off commandline */
	if(load_rom(game_name) == 0)
	{
		printf("Error loading `%s'.\n", game_name);
		exit(1);
	}
	
	/* Parse options */
	for(i = 0; i < argc; i++)
	{
		int left = argc - i - 1;

		if(stricmp(argv[i], "-fskip") == 0 && left)
		{
			frameskip = atoi(argv[i+1]);
			if(frameskip<1) frameskip = 1;
		}
	
		if(stricmp(argv[i], "-depth") == 0 && left)
		{
			bitmap.depth = atoi(argv[i+1]);
		}

		if(stricmp(argv[i], "-jp") == 0)
		{
			sms.territory = TERRITORY_DOMESTIC;
		}
		
		if(stricmp(argv[i], "-codies") == 0)
		{
			cart.mapper = MAPPER_CODIES;
			sms.territory = TERRITORY_EXPORT;
		}
		if(stricmp(argv[i], "-pal") == 0)
		{
			sms.display = DISPLAY_PAL;
		}
		if(stricmp(argv[i], "-ntsc") == 0)
		{
			sms.display = DISPLAY_NTSC;
		}
	}

	/* Initialise screen stuff */

	switch(bitmap.depth)
		{
			case 8:
				frameskip = 1;
				Open_screendriver = &OpenVIDEL5;
				Close_screendriver = &CloseVIDEL5;
				Update_screendriver = &UpdateVIDEL5;
				Palette_screendriver = &PaletteVIDEL5;
				break;

			case 16:
				frameskip = 2;
				Open_screendriver = &OpenVIDEL16;
				Close_screendriver = &CloseVIDEL16;
				Update_screendriver = &UpdateVIDEL16;
				Palette_screendriver = &PaletteVIDEL16;
				break;
				
			default:
				printf("Error, illegal -bpp <value>.\n");
				exit(1);
		}		

	/* Set up video, audio & I/O */
	if(IS_GG)	i = 1; else i = 0;
	if(sms.display==DISPLAY_NTSC) i |=2;
	
	Open_screendriver(i,(unsigned char*) &bitmap);
	Supexec(psg_open);
	input_open();

	/* Initialize the virtual console emulation */
	system_init();
	system_poweron();

	/* Call emulation loop */
	Supexec(run_emulation);
	
	/* turn off virtual console */
	system_poweroff();
	system_shutdown();

	/* Restore video, audio, input etc. */
	input_close();
	Supexec(psg_close);
	Close_screendriver();

	return 0;
}


void run_emulation(void)
{
	int framecounter=frameskip-1;
	
	while(!input_poll())
	{
	
		if(framecounter)
		{
			system_frame(1);
			framecounter--;
		} else
		{
			system_frame(0);
			if(bitmap.pal.update)
				Palette_screendriver((unsigned char*)&bitmap.pal.color);
				
			Update_screendriver(frameskip);

			framecounter = frameskip-1;
		}
	}
}


/* Load system state */
int load_state(void)
{
    char name[PATH_MAX];
    FILE *fd = NULL;
    strcpy(name, game_name);
    sprintf(strrchr(name, '.'), ".st%d", state_slot);
    fd = fopen(name, "rb");
    if(!fd) return 0;
    system_load_state(fd);
    fclose(fd);
    return 1;
}

/* Save system state */
int save_state(void)
{
    char name[PATH_MAX];
    FILE *fd = NULL;
    strcpy(name, game_name);
    sprintf(strrchr(name, '.'), ".st%d", state_slot);
    fd = fopen(name, "wb");
    if(!fd) return 0;
    system_save_state(fd);
    fclose(fd);
    return 1;
}

/* Save or load SRAM */
void system_manage_sram(uint8 *sram, int slot, int mode)
{
    char name[PATH_MAX];
    FILE *fd;
    strcpy(name, game_name);
    strcpy(strrchr(name, '.'), ".sav");

    switch(mode)
    {
        case SRAM_SAVE:
            if(sms.save)
            {
                fd = fopen(name, "wb");
                if(fd)
                {
                    fwrite(sram, 0x8000, 1, fd);
                    fclose(fd);
                }
            }
            break;

        case SRAM_LOAD:
            fd = fopen(name, "rb");
            if(fd)
            {
                sms.save = 1;
                fread(sram, 0x8000, 1, fd);
                fclose(fd);
            }
            else
            {
                /* No SRAM file, so initialize memory */
                memset(sram, 0x00, 0x8000);
            }
            break;
    }
}

/* Dump RAM to disk */
void dump_wram(void)
{
    static int count = 0;
    char path[PATH_MAX];
    FILE *fd;
    sprintf(path, "wram.%03d", count);
    fd = fopen(path, "wb");
    if(!fd)
    {
//        add_msg("Error saving WRAM to `%s'", path);
    } else
    {
//        add_msg("WRAM saved to `%s'", path);
        fwrite(sms.wram, sizeof(sms.wram), 1, fd);
        fclose(fd);
        ++count;
    }
}

/* Dump VRAM to disk */
void dump_vram(void)
{
    static int count = 0;
    char path[PATH_MAX];
    FILE *fd;
    sprintf(path, "vram.%03d", count);
    fd = fopen(path, "wb");
    if(!fd)
    {
//        add_msg("Error saving VRAM to `%s'", path);
    } else
    {
//        add_msg("VRAM saved to `%s'", path);
        fwrite(vdp.vram, sizeof(vdp.vram), 1, fd);
        fclose(fd);
        ++count;
    }
}
