/*****************************************************************************
*
*                                    sa2dkb.c
*
*   from DKBTrace (c) 1990  David Buck
*
*  This program reads a Sculpt-Animate 3D format scene file and generates an
*  output file that may be read in to DKBTrace.
*
*
* This software is freely distributable. The source and/or object code may be
* copied or uploaded to communications services so long as this notice remains
* at the top of each file.  If any changes are made to the program, you must
* clearly indicate in the documentation and in the programs startup message
* who it was who made the changes. The documentation should also describe what
* those changes were. This software may not be included in whole or in
* part into any commercial package without the express written consent of the
* author.  It may, however, be included in other public domain or freely
* distributed software so long as the proper credit for the software is given.
*
* This software is provided as is without any guarantees or warranty. Although
* the author has attempted to find and correct any bugs in the software, he
* is not responsible for any damage caused by the use of the software.  The
* author is under no obligation to provide service, corrections, or upgrades
* to this package.
*
* Despite all the legal stuff above, if you do find bugs, I would like to hear
* about them.  Also, if you have any comments or questions, you may contact me
* at the following address:
*
*     David Buck
*     22C Sonnet Cres.
*     Nepean Ontario
*     Canada, K2H 8W7
*
*  I can also be reached on the following bulleton boards:
*
*     OMX              (613) 731-3419
*     Mystic           (613) 596-4249  or  (613) 596-4772
*
*  Fidonet:   1:163/109.9
*  Internet:  dbuck@ccs.carleton.ca
*  The "You Can Call Me RAY" BBS    (708) 358-5611
*
*  IBM Port by Aaron A. Collins. Aaron may be reached on the following BBS'es:
*
*     The "You Can Call Me RAY" BBS (708) 358-5611
*     The Information Exchange BBS  (708) 945-5575
*
*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>		/* contains "malloc" and "exit" prototypes */
#include <string.h>

#define DBL double

typedef struct {
   unsigned short Red, Green, Blue, Alpha;
   } IMAGE_COLOUR;

IMAGE_COLOUR *iff_colour_map;
int colourmap_size;
FILE *f, *out, *out2, *texture_file;

struct Chunk_Header_Struct {
   long name;
   long size;
   };

typedef struct Chunk_Header_Struct CHUNK_HEADER;

static CHUNK_HEADER Chunk_Header;


/* function prototypes */

/* char *malloc(unsigned int size);	(defined in stdlib.h) */
void read_iff_file(void);
void close_all(void);
void add_texture(unsigned int, unsigned int, unsigned int, unsigned int);
void iff_error (void);
int read_byte (FILE *);
int read_word (FILE *);
long read_long (FILE *);
void Read_Chunk_Header (FILE *, CHUNK_HEADER *);


DBL *vertices_x, *vertices_y, *vertices_z;
DBL max_x, max_y, max_z, min_x, min_y, min_z;
#define FABS(x) ((x<0.0)?-x:x)

#define FORM 0x464f524dL
#define SC3D 0x53433344L
#define VERT 0x56455254L
#define FACE 0x46414345L

#define CMPNONE 0

char *Textures[7] = {"Dull", "Shiny", "Mirror", "Luminous", "Glass", "Metal", "Glass2"};

#define TEXTURE_TABLE_SIZE 16300
unsigned long *texture_table;
unsigned int texture_table_size = 0;

char outfile[80];

void close_all()
   {
   if (out != NULL) {
      fclose (out);
      unlink ("triangle.tmp");
      }

   if (out2 != NULL) {
      fclose (out2);
      unlink (outfile);
      }

   if (texture_file != NULL) {
      fclose (texture_file);
      unlink ("textures.tmp");
      }

   if (f != NULL) {
      fclose (f);
      }
   }

void add_texture (texture, red, green, blue)
   unsigned int texture, red, green, blue;
   {
   unsigned long texture_id;
   int i;

   texture_id = ((unsigned long)texture << 24) | ((unsigned long)red << 16) | (green << 8) | blue;

   for (i = 0; (unsigned) i < texture_table_size; i++)
      if (texture_id == texture_table[i])
         return;

   texture_table[texture_table_size++] = texture_id;

   if (texture_table_size >= TEXTURE_TABLE_SIZE) {
      fprintf (stderr, "Colour table overflow\n");
      close_all();
      exit(1);
      }

   fprintf (texture_file, "DECLARE %s_%d_%d_%d = TEXTURE %s COLOUR RED %f GREEN %f BLUE %f END_TEXTURE\n",
            Textures[texture], red, green, blue, 
            Textures[texture], red/255.0, green/255.0, blue/255.0);
   }

void iff_error ()
   {
   fprintf (stderr, "Invalid iff file\n");
   close_all();
   exit(1);
   }

int read_byte(f)
   FILE *f;
   {
   int c;
   if ((c = getc(f)) == EOF)
      iff_error();
   return (c);
   }

int read_word(f)
   FILE *f;
   {
   int result;

   result = read_byte(f)*256;
   result += read_byte(f);
   return (result);
   }

long read_long(f)
   FILE *f;
   {
   int i;
   long result;

   result = 0;
   for (i = 0 ; i < 4 ; i++)
      result = result * 256 + read_byte(f);

   return (result);
   }

void Read_Chunk_Header (f, dest)
   FILE *f;
   CHUNK_HEADER *dest;
   {
   dest->name = read_long(f);
   dest->size = (int) read_long(f);
   }

void read_iff_file()
   {
   int i;
   int vert1, vert2, vert3;
   unsigned int texture;
   unsigned int red_int, green_int, blue_int;

   max_x = max_y = max_z = -10000000.0;
   min_x = min_y = min_z = 10000000.0;

   while (1) {
      Read_Chunk_Header(f, &Chunk_Header);
      switch ((int) Chunk_Header.name) {
         case FORM: if (read_long(f) != SC3D)
                       iff_error();
                    break;

         case VERT:
					if ((vertices_x = (DBL *)
                        malloc ((unsigned)Chunk_Header.size * (sizeof(DBL)/sizeof(long)))) == NULL) {
						fprintf (stderr, "Cannot allocate memory for vertices_x array\n");
						close_all();
						exit(1);
						}
                    if ((vertices_y = (DBL *)
                        malloc ((unsigned)Chunk_Header.size * (sizeof(DBL)/sizeof(long)))) == NULL) {
						fprintf (stderr, "Cannot allocate memory for vertices_y array\n");
						close_all();
						exit(1);
						}
                    if ((vertices_z = (DBL *)
                        malloc ((unsigned)Chunk_Header.size * (sizeof(DBL)/sizeof(long)))) == NULL) {
						fprintf (stderr, "Cannot allocate memory for vertices_z array\n");
						close_all();
						exit(1);
						}
                    for (i = 0 ; (long) i < Chunk_Header.size/12L ; i++) {
                       vertices_x[i] = read_long(f) / 10000.0;
                       if (vertices_x[i] < min_x)
                          min_x = vertices_x[i];
                       if (vertices_x[i] > max_x)
                          max_x = vertices_x[i];

                       vertices_y[i] = read_long(f) / 10000.0;
                       if (vertices_y[i] < min_y)
                          min_y = vertices_y[i];
                       if (vertices_y[i] > max_y)
                          max_y = vertices_y[i];

                       vertices_z[i] = read_long(f) / 10000.0;
                       if (vertices_z[i] < min_z)
                          min_z = vertices_z[i];
                       if (vertices_z[i] > max_z)
                          max_z = vertices_z[i];
                       }
                    break;

         case FACE: for (i = 0 ; (long) i < Chunk_Header.size/16L ; i++) {
                       vert1 = (int) read_long(f);
                       vert2 = (int) read_long(f);
                       vert3 = (int) read_long(f);
                       red_int = read_byte(f);
                       green_int = read_byte(f);
                       blue_int = read_byte(f);

					   texture = read_byte(f);
					   texture &= 0x07;		/* mask upper bits */
                       add_texture (texture, red_int, green_int, blue_int);

					   fprintf (out, "TRIANGLE <%f %f %f> <%f %f %f> <%f %f %f> TEXTURE %s_%d_%d_%d END_TEXTURE END_TRIANGLE\n",
                          vertices_x[vert1], vertices_y[vert1], vertices_z[vert1],
                          vertices_x[vert2], vertices_y[vert2], vertices_z[vert2],
                          vertices_x[vert3], vertices_y[vert3], vertices_z[vert3],
                          Textures[texture], red_int, green_int, blue_int);
                       }
                    return;

         default:
            for (i = 0 ; (long) i < Chunk_Header.size ; i++)
               if (getc(f) == EOF)
                  iff_error();
            break;
         }
      }
   }

void main (argc, argv)
   int argc;
   char **argv;
   {
   int c;

   if (argc != 3) {
      fprintf (stderr, "Usage: %s <scene-file> <output-file>\n", argv[0]);
      exit (1);
      }
   
   f = out = out2 = texture_file = NULL;

   strcpy(outfile, argv[2]);

   if ((texture_table = (unsigned long *) malloc((unsigned int)TEXTURE_TABLE_SIZE * sizeof (unsigned long))) == NULL) {
      fprintf (stderr, "Cannot allocate memory for texture table\n");
      exit(1);
      }

   if ((f = fopen(argv[1], "rb")) == NULL) {
      fprintf (stderr, "Cannot open IFF file %s\n", argv[1]);
      exit(1);
      }

   if ((out = fopen("triangle.tmp", "w")) == NULL) {
      fprintf (stderr, "Cannot open temporary file triangle.tmp\n");
      close_all();
      exit(1);
      }
   
   if ((texture_file = fopen("textures.tmp", "w")) == NULL) {
      fprintf (stderr, "Cannot open temporary file textures.tmp\n");
      close_all();
      exit(1);
      }

   fprintf(out, "\nOBJECT\n   UNION\n");
   read_iff_file();
   fprintf(out, "   END_UNION\n");
   fprintf(out, "   BOUNDED_BY\n      INTERSECTION\n");
   fprintf(out, "         PLANE <1.0  0.0  0.0> %1.02f END_PLANE\n", FABS(max_x) * 1.01);
   fprintf(out, "         PLANE <-1.0 0.0  0.0> %1.02f END_PLANE\n", FABS(min_x) * 1.01);
   fprintf(out, "         PLANE <0.0  1.0  0.0> %1.02f END_PLANE\n", FABS(max_y) * 1.01);
   fprintf(out, "         PLANE <0.0 -1.0  0.0> %1.02f END_PLANE\n", FABS(min_y) * 1.01);
   fprintf(out, "         PLANE <0.0  0.0  1.0> %1.02f END_PLANE\n", FABS(max_z) * 1.01);
   fprintf(out, "         PLANE <0.0  0.0 -1.0> %1.02f END_PLANE\n", FABS(min_z) * 1.01);
   fprintf(out, "      END_INTERSECTION\n   END_BOUND\n   \nEND_OBJECT\n");
   printf ("X values range from %f to %f\n", min_x, max_x);
   printf ("Y values range from %f to %f\n", min_y, max_y);
   printf ("Z values range from %f to %f\n", min_z, max_z);
   fclose(f);
   fflush(out);
   fclose(out);
   fflush(texture_file);
   fclose(texture_file);
   
   if ((out2 = fopen (argv[2], "w")) == NULL) {
      fprintf (stderr, "Cannot open output file %s\n", argv[2]);
      exit(1);
      }

   if ((out = fopen("triangle.tmp", "r")) == NULL) {
      fprintf (stderr, "Cannot open temporary file triangle.tmp\n");
      close_all();
      exit(1);
      }
   
   if ((texture_file = fopen("textures.tmp", "r")) == NULL) {
      fprintf (stderr, "Cannot open temporary file textures.tmp\n");
      close_all();
      exit(1);
      }
   
   while ((c = getc(texture_file)) != EOF)
      putc (c, out2);

   while ((c = getc(out)) != EOF)
      putc (c, out2);

   fflush(out2);
   fclose(out2);
   out2 = NULL;		/* make sure close_all doesn't delete out2 file */
   close_all();
   exit(0);
   }
