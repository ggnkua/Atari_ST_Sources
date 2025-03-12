/* Crude program to grab equipment bit maps */

#include <stdio.h>

#define inp_file    "equip.pc1"
#define out_file    "equip.bit"

static char bitmap[32768];              /* Atari 32k bit map */
static int text_len;                    /* no. characters outputted */
static FILE *inp_fp, *out_fp;

main()

{
    unsigned int i;
    char *bit_ptr;
    int picture_type, line, plane, offset, step, count, data_byte;

    printf("EQUIP V1.0 (c) 1988 Mr. Micro Ltd.\n\n");

    if ((inp_fp = fopen(inp_file, "rb")) == NULL)
        {
	printf("%cUnable to find %s", 7, inp_file);
	exit(0);
	}
    if ((out_fp = fopen(out_file, "w")) == NULL)
        {
	printf("%cUnable to open %s", 7, out_file);
	exit(0);
	}
	
    /* Read the bit map */

    printf("Reading bitmap .. ");
    picture_type = getc(inp_fp);        /* picture type */
    getc(inp_fp);                       /* zero byte */
    for (i = 0; i < 32; ++i)            /* ignore palette */
        getc(inp_fp);
    if (picture_type == 0x80)           /* compressed */
        {
	bit_ptr = bitmap; step = 1;
        line = plane = offset = 0;
	while (line != 200)
	    {
	    if ((count = getc(inp_fp)) & 128)
	        {
		count = 257 - count;
		offset += count;
		data_byte = getc(inp_fp);
		while (count--)
		    {
		    *bit_ptr = data_byte;
		    bit_ptr += step;
		    step    ^= 6;
		    }
		}
	    else
	        {
		++count;
		offset += count;
		while (count--)
		    {
		    *bit_ptr = getc(inp_fp);
		    bit_ptr += step;
		    step    ^= 6;
		    }
		}
	    if (offset == 40)
	        {
		offset = 0;
		bit_ptr = bit_ptr - 160 + 2;
		if (++plane == 4)
		    {
		    plane = 0; ++line;
		    bit_ptr = bit_ptr + 160 - 8;
		    }
		}
	    }
	}
    else
        fread(bitmap, 16384, 2, inp_fp);
    fclose(inp_fp);
    puts("Done.");
    make("fuel", 0, 4, 41);
    make("missiles", 4*8, 4, 41);
    make("cargo_hold", 8*8, 4, 41);
    make("ecm", 12*8, 4, 41);
    make("pulse_laser", 16*8, 4, 41);
    make("beam_laser", 160*48, 4, 41);
    make("energy_unit", 160*48+4*8, 4, 41);
    make("escape_capsule", 160*48+8*8, 4, 41);
    make("energy_bomb", 160*48+12*8, 4, 41);
    make("fuel_scoop", 160*48+16*8, 4, 41);
    make("docking_computer", 160*96, 4, 41);
    make("hyperdrive", 160*96+4*8, 4, 41);
    make("mining_laser", 160*96+8*8, 4, 41);
    make("military_laser", 160*96+12*8, 4, 41);
    make("retro_rocket", 160*144+8*8, 4, 41);
    make("not_used", 160*144+12*8, 4, 41);
    make("keypad", 160*96+16*8, 4, 78);
    make("echar", 160*144+4*8, 1, 13);
    make("schar", 160*144+5*8, 1, 13);
    make("front_view", 160*144, 3, 7);
    make("rear_view", 160*160, 3, 7);
    make("right_view", 160*176, 3, 7);
    make("left_view", 160*192, 3, 7);
    make("magnify1", 160*160+4*8, 1, 7);
    make("magnify2", 160*168+4*8, 1, 7);
    make("icon_front", 160*192+4*8, 3, 7);
    fclose(out_fp);
}

int make(name, offset, width, depth)

char *name;
unsigned int offset;
int width, depth;

{
    unsigned x, y, i;
    char *bit_ptr;
    
    printf("Creating %s .. ", name);
    fprintf(out_fp, "%cxdef %s\n\n", 9, name);
    fprintf(out_fp, "%s:\n\n%cdc %d,%d\n", name, 9, width, depth);
    text_len = 0;
    for (y = 0; y < depth; ++y)
        {
	bit_ptr = &bitmap[offset + y * 160];
	for (x = 0; x < width; ++x)
	    {
	    for (i = 0; i < 4; ++i)
	        {
	        out_dc((*bit_ptr << 8) + *(bit_ptr+1));
		bit_ptr += 2;
		}
            }
	}
    printf("Done.\n");
    fprintf(out_fp, "\n\n");
}

int out_dc(word)

unsigned int word;

{
    char number[20];
    int number_len;
    
    sprintf(number, "%d%c", word, 0);
    number_len = strlen(number);
    if (text_len + number_len > 75)
        {
	putc('\n', out_fp);
	text_len = 0;
	}
    if (text_len == 0)
        {
	fprintf(out_fp, "%cdc ", 9);
	text_len = 11;
	}
    else
        {
	putc(',', out_fp);
	++text_len;
	}
    fprintf(out_fp, "%s", number);
    text_len += number_len;
}

