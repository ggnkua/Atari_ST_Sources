/* Crude program to grab heads bit maps */

#include <stdio.h>

#define inp_file    "heads.pc1"
#define out_file    "heads.bit"

static char bitmap[32768];              /* Atari 32k bit map */
static int text_len;                    /* no. characters outputted */
static FILE *inp_fp, *out_fp;

main()

{
    unsigned int i;
    char *bit_ptr;
    int picture_type, line, plane, offset, step, count, data_byte;

    printf("HEADS V1.0 (c) 1988 Mr. Micro Ltd.\n\n");

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
    make("h_human1", 0, 4, 32);
    make("h_slimy", 4*8, 4, 32);
    make("h_horned", 12*8, 4, 32);
    make("h_fat", 160*40, 4, 32);
    make("h_furry", 160*40+4*8, 4, 32);
    make("h_mutant", 160*40+8*8, 4, 32);
    make("h_boney", 160*40+12*8, 4, 32);
    make("h_human2", 160*80, 4, 32);
    make("h_weird", 160*80+4*8, 4, 32);
    make("h_bug_eyed", 160*80+8*8, 4, 32);
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