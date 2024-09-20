/* Crude program to grab cargo bit maps */

#include <stdio.h>

#define inp_file    "cargo.pc1"
#define out_file    "cargo.bit"

static char bitmap[32768];              /* Atari 32k bit map */
static int text_len;                    /* no. characters outputted */
static FILE *inp_fp, *out_fp;

main()

{
    unsigned int i;
    char *bit_ptr;
    int picture_type, line, plane, offset, step, count, data_byte;

    printf("CARGO V1.0 (c) 1988 Mr. Micro Ltd.\n\n");

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
    make("food", 0*160+0*8, 3, 32);
    make("textiles", 0*160+3*8, 3, 32);
    make("radioactives", 0*160+6*8, 3, 32);
    make("slaves", 0*160+9*8, 3, 32);
    make("wines", 0*160+12*8, 3, 32);
    make("luxuries", 0*160+15*8, 3, 32);
    make("narcotics", 40*160+0*8, 3, 32);
    make("computers", 40*160+3*8, 3, 32);
    make("machinery", 40*160+6*8, 3, 32);
    make("alloys", 40*160+9*8, 3, 32);
    make("firearms", 40*160+12*8, 3, 32);
    make("furs", 40*160+15*8, 3, 32);
    make("minerals", 80*160+0*8, 3, 32);
    make("gold", 80*160+6*8, 3, 32);
    make("platinum", 80*160+9*8, 3, 32);
    make("gem_stones", 80*160+3*8, 3, 32);
    make("alien_items", 80*160+12*8, 3, 32);
    make("refugees", 80*160+15*8, 3, 32);
    make("documents", 120*160+15*8, 3, 32);
    make("medical", 160*160+15*8, 3, 32);
    make("pulse_sight", 160*160+9*8, 2, 30);
    make("military_sight", 160*160+11*8, 2, 26);
    make("beam_sight", 160*160+13*8, 2, 20);
    make("mining_sight", 160*160+18*8, 2, 20);
    make("error_box", 120*160, 8, 8*8);
    make("input_panel", 192*160, 20, 8);
    make("cursor1", 120*160+9*8,2 , 18);
    make("cursor2", 120*160+11*8, 2, 18);
    make("cursor3", 120*160+13*8, 2, 18);
    make("cursor4", 136*160+13*8, 2, 15);
    make("block_cursor", 144*160+9*8, 1, 8);
    make("rubout", 144*160+10*8, 1, 8);
    make("infront", 144*160+11*8, 1, 5);
    make("behind", 152*160+11*8, 1, 5);
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