/*-------------------------------------------------------------------------

			 3D2 to Raytracer File Converter
		       Copyright (c) 1992 by Steve Anger

   Converts files from Cyber Sculpt 3D2 format (Atari) to POV-Ray or Vivid
 raytracer formats. This file may be freely modified and distributed.

					   CompuServe: 70714,3113
					    YCCMR BBS: (708)358-5611

--------------------------------------------------------------------------*/

#ifndef __GNUC__
#include <alloc.h>
#endif

#include <stdio.h>
/* #include <portab.h> */
#include <stdlib.h>
#include <string.h>
#include <math.h>


#include "rayopt.h"



#ifdef __TURBOC__
extern unsigned _stklen = 16384;
#endif

#define VERSION "v1.8"

#define ASPECT 1.333

#define POV10  0
#define POV20  1
#define VIVID  2
#define RAW    99

typedef struct
{
    float  x, y, z;
} Vector;


typedef struct
{
    int  x, y, z;
} IVector;


typedef struct
{
    float red;
    float green;
    float blue;
} Palette;


typedef struct
{
    int    vert_a;       /* Vertex A of the triangle */
    int    vert_b;       /*   "    B  "  "      "    */
    int    vert_c;       /*   "    C  "  "      "    */
    int    colour;       /* Colour of triangle */
} Triangle;


typedef unsigned char byte;
typedef signed int word;


/* Function prototype definitions */
void process_args (int argc, char *argv[]);
byte read_byte (FILE *f);
word read_word (FILE *f);
void read_3d2_header (void);
void convert_object (void);
void write_intro (void);
void write_triangle (Vector a, Vector b, Vector c, Palette pal);
void write_summary (void);
void write_light (Vector pos, float red, float green, float blue);
void write_camera (Vector pos, Vector target, float lens);
char upcase (char c);
void fswap (float *a, float *b);

/* Global variables */
FILE      *in;            /* Input file */
FILE      *out;           /* Output file */
char      infile[64];     /* Input file name */
char      outfile[64];    /* Output file name */
Vector    look_at;        /* Location to look at */
Vector    view_point;     /* Location of view_point */
int       verbose;        /* Verbose messages flag */
int       format;         /* Output format */
float     smooth;         /* Smooth triangles who's normals differ by */
			  /* less than this angle (degrees) */

/* 3D2 Header infomation */
int       obj_count;       /* Number of objects contained in file */
int       light_on[3];     /* 1 = Light source is on, 0 = off */
float     light_bright[3]; /* Light source brightness */
Vector    light_pos[3];    /* Light source position */
Palette   pal[16];         /* Colour palette for objects */

/* 3D2 Object information */
char      obj_name[12];   /* Name of current object */
int       vert_count;     /* Number of vertices in object */
IVector   *vert;          /* Pointer to array of vertices */
int       tri_count;      /* Number of triangular faces in object */
int       degen_count;    /* Degenerate triangles */



int main (int argc, char* argv[])
{
    int i, total_vert, total_tri, total_degen, total_bounds;

    process_args (argc, argv);

    if (format != RAW) {
	opt_set_format (format);
	opt_set_quiet (!verbose);
	opt_set_smooth (smooth);
	opt_set_dec (2);
	opt_set_fname (outfile, "");
    }

    in = fopen (infile, "rb");
    if (in == NULL)
	abortmsg ("Error opening input file.", 1);

    out = fopen (outfile, "w");
    if (out == NULL)
	abortmsg ("Error opening output file.", 1);

    total_vert   = 0;
    total_tri    = 0;
    total_degen  = 0;
    total_bounds = 0;

    read_3d2_header();
    write_intro();

    printf ("  Object    Vertices    Triangles   Degen Tri   Bounds   Bnd Index\n");
    printf ("---------- ----------- ----------- ----------- -------- -----------\n");

    for (i = 0; i < obj_count; i++) {
	convert_object();

	printf ("     %6d      %6d      %6d   %6d    %8.2f\n",
		vert_count, tri_count, degen_count,
		opt_get_bounds(), opt_get_index());

	total_vert   += vert_count;
	total_tri    += tri_count;
	total_degen  += degen_count;
	total_bounds += opt_get_bounds();
    }

    write_summary();   /* Finish off the file */

    printf ("           =========== =========== =========== ========\n");
    printf (" Totals       %6d      %6d      %6d   %6d\n",
	    total_vert, total_tri, total_degen, total_bounds);

    printf ("\nConverted %d object(s), ", obj_count);
    printf ("%d light source(s).\n\n", light_on[0] + light_on[1] + light_on[2]);

    fclose(in);
    fclose(out);

    return 0;
}

void process_args (int argc, char *argv[])
{
    int i;

    printf ("\n");
    printf ("3D2 to POV-Ray/Vivid Converter %s, ", VERSION);
    printf ("Copyright (c) 1993 Steve Anger\n");
#if defined(__GNUC__) && defined(i386)
    printf ("32 bit version. DOS Extender Copyright (c) 1991 DJ Delorie\n");
#endif
    printf ("This program is freely distributable\n\n");

    if (argc < 2) {
	printf ("Usage: 3d2-pov inputfile[.3d2] [outputfile] [options]\n\n");
	printf ("Options: -lxnnn - Set look_at x coord to nnn\n");
	printf ("         -lynnn -  '     '    y   '   '   ' \n");
	printf ("         -lznnn -  '     '    z   '   '   ' \n");
	printf ("         -vxnnn - Set view_point x coord to nnn\n");
	printf ("         -vynnn -  '       '     y   '   '   ' \n");
	printf ("         -vznnn -  '       '     z   '   '   ' \n");
	printf ("         -snnn  - Smooth triangle boundaries with angles < nnn\n");
	printf ("         -op    - Output to POV-Ray 1.0 format (default)\n");
	printf ("         -op2   - Output to POV-Ray 2.0 format\n");
	printf ("         -ov    - Output to Vivid 2.0 format\n");
	printf ("         -or    - Output to RAW triangle format\n");
	printf ("\n   e.g. 3d2-pov car.3d2 car.pov -s60.0\n\n");
	exit(1);
    }

    strcpy (infile, "");
    strcpy (outfile, "");

    smooth  = 60.0;
    verbose = 0;
    format  = POV10;

    view_point.x = +50.0;
    view_point.y = -50.0;
    view_point.z = +50.0;

    look_at.x = 0.0;
    look_at.y = 0.0;
    look_at.z = 0.0;

    for (i = 1; i < argc; i++) {
	if (argv[i][0] == '-' || argv[i][0] == '/') {
	    switch (upcase(argv[i][1])) {
		case 'S': if (argv[i][2] == '\0')
			      smooth = 60.0;
			  else
			      sscanf (&argv[i][2], "%f", &smooth);
			  break;

		case 'L': switch (upcase(argv[i][2])) {
			    case 'X': sscanf (&argv[i][3], "%f", &look_at.x);
				      break;
			    case 'Y': sscanf (&argv[i][3], "%f", &look_at.y);
				      break;
			    case 'Z': sscanf (&argv[i][3], "%f", &look_at.z);
			  }
			  break;

		case 'V': switch (upcase(argv[i][2])) {
			    case 'X': sscanf (&argv[i][3], "%f", &view_point.x);
				      break;
			    case 'Y': sscanf (&argv[i][3], "%f", &view_point.y);
				      break;
			    case 'Z': sscanf (&argv[i][3], "%f", &view_point.z);
			  }
			  break;

	        case 'O': switch (upcase(argv[i][2])) {
			      case 'P': if (argv[i][3] == '2')
					    format = POV20;
				        else
					    format = POV10;
				        break;

			      case 'V': format = VIVID;
				        break;

			      case 'R': format = RAW;
				        break;
		          }
		          break;

		default:  printf ("Invalid option -%c, ignored.\n\n", argv[i][1]);
	    }
	}
	else if (strlen(infile) == 0) {
	    strcpy (infile, argv[i]);
	    add_ext (infile, "3d2", 0);
	}
	else if (strlen (outfile) == 0) {
	    strcpy (outfile, argv[i]);

	    switch (format) {
		case POV10:
		case POV20: add_ext (outfile, "pov", 0); break;
		case VIVID: add_ext (outfile, "v",   0); break;
		case RAW:   add_ext (outfile, "raw", 0); break;
	    }
	}
	else
	    abortmsg ("Too many file names", 1);
    }

    if (strlen (infile) == 0)
	abortmsg ("No input file specified", 1);

    /* Prevent a division by zero error later on */
    if ((view_point.x - look_at.x) == 0.0 && (view_point.z - look_at.z) == 0.0)
	view_point.z -= 0.01;

    if (strlen (outfile) == 0) {
	strcpy (outfile, infile);

	switch (format) {
            case POV10:
	    case POV20: add_ext (outfile, "pov", 1); break;
	    case VIVID: add_ext (outfile, "v",   1); break;
	    case RAW:   add_ext (outfile, "raw", 1); break;
	}
    }

    if (format == POV10 || format == POV20)
	fswap (&view_point.y, &view_point.z);
}


byte read_byte (FILE *f)
{
    return fgetc(f);
}


word read_word (FILE *f)
{
    byte bh, bl;
    word res;

    bh = fgetc(f);
    bl = fgetc(f);

    res = 256*bh + bl;

    /* A sign adjustment for non-16 bit machines. */
    if (sizeof(word) > 2  &&  (res & 0x8000) != 0)
	res = ((-1) << 16) | res;

    return (res);
}


void read_3d2_header()
{
    int i;
    word temp;

    if (read_word(in) != 0x3D02)
	abortmsg ("Input file is not 3D2 format.", 1);

    obj_count = read_word(in);

    light_on[0] = read_word(in);
    light_on[1] = read_word(in);
    light_on[2] = read_word(in);

    light_bright[0] = read_word(in)/7.0;
    light_bright[1] = read_word(in)/7.0;
    light_bright[2] = read_word(in)/7.0;

    read_word(in);       /* Skip the ambient light level */

    light_pos[0].z = (float)read_word(in);
    light_pos[1].z = (float)read_word(in);
    light_pos[2].z = (float)read_word(in);

    light_pos[0].y = (float)read_word(in);
    light_pos[1].y = (float)read_word(in);
    light_pos[2].y = (float)read_word(in);

    light_pos[0].x = (float)read_word(in);
    light_pos[1].x = (float)read_word(in);
    light_pos[2].x = (float)read_word(in);

    if (format == POV10 || format == POV20) {
	fswap (&light_pos[0].y, &light_pos[0].z);
	fswap (&light_pos[1].y, &light_pos[1].z);
	fswap (&light_pos[2].y, &light_pos[2].z);
    }

    for (i = 0; i < 16; i++) {
	temp = read_word(in);
	pal[i].red   = ((temp & 0x0700) >> 8)/7.0;
	pal[i].green = ((temp & 0x0070) >> 4)/7.0;
	pal[i].blue  = (temp & 0x0007)/7.0;
    }

    for (i = 0; i < 188; i++)
	read_byte(in);
}


void convert_object()
{
    int    i, va, vb, vc, col;
    Vector a, b, c;

    for (i = 0; i < 9; i++)
	obj_name[i] = read_byte(in);

    cleanup_name (obj_name);

    printf (" %-8s", obj_name);
    fflush (stdout);

    if (format == RAW)
	fprintf (out, "%s\n", obj_name);

    vert_count = read_word(in);

    if (vert_count > 0) {
	vert = malloc (vert_count * sizeof(*vert));
	if (vert == NULL)
	    abortmsg ("Insufficient memory for vertices.", 1);
    }

    for (i = 0; i < vert_count; i++) {
	vert[i].x = read_word(in);
	vert[i].y = read_word(in);
	vert[i].z = read_word(in);
    }

    /* Tell optimizer how many vertices to expect */
    if (format != RAW)
	opt_set_vert (vert_count);

    tri_count = read_word(in);
    degen_count = 0;

    for (i = 0; i < tri_count; i++) {
	va = read_word(in);
	vb = read_word(in);
	vc = read_word(in);
	read_byte(in);
	col = read_byte(in);

	a.x = vert[va].x / 100.0;
	a.y = vert[va].y / 100.0;
	a.z = vert[va].z / 100.0;

	b.x = vert[vb].x / 100.0;
	b.y = vert[vb].y / 100.0;
	b.z = vert[vb].z / 100.0;

	c.x = vert[vc].x / 100.0;
	c.y = vert[vc].y / 100.0;
	c.z = vert[vc].z / 100.0;

	if (format == POV10 || format == POV20) {
	    fswap (&a.y, &a.z);
	    fswap (&b.y, &b.z);
	    fswap (&c.y, &c.z);
	}

	write_triangle (a, b, c, pal[col]);
    }

    if (vert_count > 0)
	free (vert);

    if (format != RAW) {
	fclose(out);
	opt_write_file (obj_name);
	out = fopen (outfile, "a");
    }
}



void write_intro()
{
    switch (format) {
	case POV10:
        case POV20:
	    fprintf (out, "/* Converted from file %s with 3D2-POV %s */\n\n",
		     infile, VERSION);
	    fprintf (out, "#include \"colors.inc\"\n");
	    fprintf (out, "#include \"textures.inc\"\n\n");
	    break;

	case VIVID:
	    fprintf (out, "/* Converted from file %s with 3D2-POV %s */\n\n",
		     infile, VERSION);
	    fprintf (out, "#include color.vc\n\n");
	    break;
    }
}


void write_triangle (Vector a, Vector b, Vector c, Palette pal)
{
    switch (format) {
        case POV10:
	case POV20:
	case VIVID:
	    opt_set_color (pal.red, pal.green, pal.blue);

	    if (opt_add_tri (a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z) < 0)
		++degen_count;

	    break;

	case RAW:
	    fprintf (out, "%.2f %.2f %.2f  %.2f %.2f %.2f  %.2f %.2f %.2f\n",
		     a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z);
	    break;
    }
}


void write_summary()
{
    int   i;

    switch (format) {
        case POV10:
	case POV20:
	case VIVID:
	    fclose(out);
	    opt_finish();
	    out = fopen (outfile, "a");

	    for (i = 0; i < 3; i++) {
		if (light_on[i])
		    write_light (light_pos[i], light_bright[i], light_bright[i], light_bright[i]);
	    }

	    write_camera (view_point, look_at, 35.0);
	    break;
    }
}


void write_light (Vector pos, float red, float green, float blue)
{
    switch (format) {
	case POV10:
	    fprintf (out, "object {\n");
	    fprintf (out, "    light_source { <%.4f %.4f %.4f> color red %4.2f green %4.2f blue %4.2f }\n",
			  pos.x, pos.y, pos.z, red, green, blue);
	    fprintf (out, "}\n\n");
	    break;

	case POV20:
	    fprintf (out, "light_source {\n");
	    fprintf (out, "    <%.4f, %.4f, %.4f> color red %4.2f green %4.2f blue %4.2f\n",
		           pos.x, pos.y, pos.z, red, green, blue);
	    fprintf (out, "}\n\n");
	    break;

	case VIVID:
	    fprintf (out, "light {\n");
	    fprintf (out, "    type point\n");
	    fprintf (out, "    position %.4f %.4f %.4f\n",
			  pos.x, pos.y, pos.z);
	    fprintf (out, "    color %4.2f %4.2f %4.2f\n",
			     red, green, blue);
	    fprintf (out, "}\n\n");
	    break;
    }
}


void write_camera (Vector pos, Vector target, float lens)
{
    switch (format) {
	case POV10:
	    fprintf (out, "camera {\n");
	    fprintf (out, "   location <%.4f %.4f %.4f>\n",
			      pos.x, pos.y, pos.z);
	    fprintf (out, "   direction <0 0 %.2f>\n", lens/35.0);
	    fprintf (out, "   up <0 1 0>\n");
	    fprintf (out, "   sky  <0 1 0>\n");
	    fprintf (out, "   right <%.3f 0 0>\n", ASPECT);
	    fprintf (out, "   look_at <%.4f %.4f %.4f>\n",
			      target.x, target.y, target.z);
	    fprintf (out, "}\n\n");
	    break;

	case POV20:
	    fprintf (out, "camera {\n");
	    fprintf (out, "   location <%.4f, %.4f, %.4f>\n",
			      pos.x, pos.y, pos.z);
	    fprintf (out, "   direction <0, 0, %.2f>\n", lens/35.0);
	    fprintf (out, "   up <0, 1, 0>\n");
	    fprintf (out, "   sky  <0, 1, 0>\n");
	    fprintf (out, "   right <%.3f, 0, 0>\n", ASPECT);
	    fprintf (out, "   look_at <%.4f, %.4f, %.4f>\n",
			      target.x, target.y, target.z);
	    fprintf (out, "}\n\n");
	    break;

	case VIVID:
	    fprintf (out, "studio {\n");
	    fprintf (out, "    from %.4f %.4f %.4f\n", pos.x, pos.y, pos.z);
	    fprintf (out, "    at %.4f %.4f %.4f\n",
			       target.x, target.y, target.z);
	    fprintf (out, "    up 0 0 1\n");
	    fprintf (out, "    angle %.2f\n",
			       2.0 * (180.0/M_PI) * atan (35.0/lens) / ASPECT);
	    fprintf (out, "    aspect %.3f\n", ASPECT);
	    fprintf (out, "    resolution 320 200\n");
	    fprintf (out, "    antialias none\n");
	    fprintf (out, "}\n\n");
	    break;
    }
}


char upcase (char c)
{
    if (c >= 'a' && c <= 'z')
	c = c - 'a' + 'A';

    return c;
}


void fswap (float *a, float *b)
{
    float temp;

    temp = *a;
    *a = *b;
    *b = temp;
}
