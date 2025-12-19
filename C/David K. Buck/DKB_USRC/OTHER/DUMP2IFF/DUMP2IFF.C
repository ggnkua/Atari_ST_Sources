/*****************************************************************************
*
*                                   dump2iff.c
*
*   from DKBTrace (c) 1990  David Buck
*
*  This file converts the raw output from the ray tracer into HAM files.
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
*  You Can Call Me Ray: (708) 358-5611
*
*
*****************************************************************************/


#define PARAMS(x) x

#include <stdio.h>
#include <exec/types.h>
#include <intuition/intuition.h>
#include <graphics/display.h>
#include <libraries/dos.h>
#include <proto/all.h>
#include "iff.h"
#include "dump2iff.h"
#include "dumproto.h"

#include <dos.h>

void main (int, char**);
void exit(int);
void *malloc(int);
void free(void *);

extern int _bufsiz;

int amiga_close_all(void);
extern char *getenv PARAMS((char *str));

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Screen *s;

#define extract_red(x) ((x & 0xF00) >> 8)
#define extract_green(x) ((x & 0x0F0) >> 4)
#define extract_blue(x) (x & 0x00F)

struct NewScreen MyScreen =
   {
   0, 0,
   SCREEN_WIDTH, SCREEN_HEIGHT,
   6,
   0, 1,
   INTERLACE | HAM,
   0,
   NULL,
   (UBYTE *) "dump2iff",
   NULL,
   NULL
   };

UWORD ColourTbl[16] = { 0x000, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666,
                        0x777, 0x888, 0x999, 0xaaa, 0xbbb, 0xccc, 0xddd,
                        0xeee, 0xfff };

LONG last_y = -1;
IMAGE Raw_Image;

FILE *fp, *palette_file, *output_palette_file;
char input_filename[100], palette_filename[100], output_filename[100];
char output_palette_filename[100];


int output_file, read_palette, write_palette, dithering;
void get_parameters(int argc, char **argv);

void main (argc, argv) 
   int argc;
   char **argv;
   {
   unsigned int red, green, blue, i;
   unsigned int x, y, index;

   if (argc < 2)
     {
     printf ("\nUsage:  dump2iff [options] <dump_filename> <iff_file_name> [<palette_filename>]\n");
     printf ("            Options:\n");
     printf ("               -d           - No dithering\n");
     printf ("               -pfilename   - Write a palette file\n");
     exit(0);
     }

   Close_Threshold = 5;

   fp = NULL;
   read_palette = FALSE;
   write_palette = FALSE;
   output_file = FALSE;
   dithering = TRUE;

   IntuitionBase = (struct IntuitionBase *)
                    OpenLibrary ("intuition.library",INT_REV);
   if (IntuitionBase == NULL)
      exit(FALSE);

   GfxBase = (struct GfxBase *)
                      OpenLibrary ("graphics.library", GR_REV);
   if (GfxBase == NULL)
      exit(FALSE);

   get_parameters(argc, argv);

   printf ("Reading raw file\n");
   read_raw_image (&Raw_Image, input_filename);


   if (dithering) {
      printf ("Dithering...\n");
      dither(&Raw_Image);
      }

   printf ("Processing...\n");
   if (read_palette) {
      if ((palette_file = fopen (palette_filename, "r")) == NULL) {
         display_close();
         exit(FALSE);
         }

      for (i = 0 ; i < 16 ; i++) {
         if (fscanf (palette_file, "%d %d %d", &red, &green, &blue) != 3) {
            printf ("Error reading palette file\n");
            exit (1);
            }

         ColourTbl[i] = ((red & 0x0f) << 8) |
                        ((green & 0x0f) << 4) | (blue & 0x0f);
         }
      }
   else {
      start_recording_colours();

      for (y = 0 ; y < Raw_Image.height ; y++) {
         for (x = 0 ; x < Raw_Image.width ; x++) {
            index = y*Raw_Image.width + x;
            process (x, y, Raw_Image.red[index],
                           Raw_Image.green[index],
                           Raw_Image.blue[index]);
         
            }
         }
      choose_palette();
      }

   /* Write out the palette file */
   if (write_palette) {
      if ((output_palette_file = fopen (output_palette_filename, "w")) == NULL)
         {
         printf ("Cannot create palette file\n");
         exit (1);
         }

      
      for (i = 0 ; i < 16 ; i++)
         fprintf (output_palette_file, "%d %d %d\n",
                  extract_red(ColourTbl[i]),
                  extract_green(ColourTbl[i]),
                  extract_blue(ColourTbl[i]));


      fclose(output_palette_file);
      }

   printf ("Displaying...\n");

   MyScreen.Width = Raw_Image.width;
   MyScreen.Height = Raw_Image.height;
   if ((s = (struct Screen *) OpenScreen (&MyScreen))
          == NULL)
      exit (FALSE);

   ShowTitle (s, FALSE);


   SetAPen (&(s->RastPort), 7L);
   RectFill (&(s -> RastPort), 0L, 0L, SCREEN_WIDTH-1, SCREEN_HEIGHT-1);

   LoadRGB4 (&(s->ViewPort), ColourTbl, 16L);

   for (y = 0 ; y < Raw_Image.height ; y++) {
      for (x = 0 ; x < Raw_Image.width ; x++) {
            index = y*Raw_Image.width + x;
            display_plot (x, y, Raw_Image.red[index],
                                Raw_Image.green[index],
                                Raw_Image.blue[index]);
         }
      }

   if (output_file)
      ConvertToIFF(output_filename);

   printf ("Finished\n");
   display_close();
   }

void get_parameters (argc, argv)
   int argc;
   char **argv;
   {
   int i, filename_number;

   filename_number = 0;
   for (i = 1 ; i < argc ; i++) {
      if (argv[i][0] == '-')
         switch (argv[i][1]) {
            case 'd':  dithering = FALSE;
                       break;

            case 'p':  strcpy (output_palette_filename, &argv[i][2]);
                       write_palette = TRUE;
                       break;

            default:   printf ("Unknown option\n");
                       break;
            }
      else
         switch (filename_number) {
            case 0: strcpy (input_filename, argv[i]);
                    filename_number++;
                    break;

            case 1: strcpy (output_filename, argv[i]);
                    output_file = TRUE;
                    filename_number++;
                    break;

            case 2: strcpy (palette_filename, argv[i]);
                    filename_number++;
                    read_palette = TRUE;
                    break;

            default: printf ("Too many filenames in commandline\n");
                     exit(1);
            }
      }
   if (filename_number == 0) {
      printf ("No input file specified\n");
      exit(1);
      }
   }


void display_close ()
   {
   if (fp != NULL)
      fclose (fp);
   CloseScreen (s);
   CloseLibrary (GfxBase) ;
   CloseLibrary (IntuitionBase) ;
   }

void display_plot (x, y, new_red, new_green, new_blue)
   LONG x, y, new_red, new_green, new_blue;
   {
   LONG colour, newline;

   new_red &= 0xFF;
   new_green &= 0xFF;
   new_blue &= 0xFF;

   new_red /= 16;
   new_green /= 16;
   new_blue /= 16;

   newline = 0;
   if (last_y != y) {
      newline = 1;
      last_y = y;
      reset_colours();
      SetAPen (&(s -> RastPort), 0);
      WritePixel (&(s -> RastPort), 0, y);
      }

   colour = best_colour (new_red, new_blue, new_green);
   SetAPen (&(s -> RastPort), colour);
   WritePixel (&(s -> RastPort), x, y);
   }


void dither (Image)
   IMAGE *Image;
   {
   long index;
   short i, j, new_red, new_green, new_blue,
       red_error, green_error, blue_error;

   red_error = 0;
   green_error = 0;
   blue_error = 0;

   for (j = 0 ; j < Image->height ; j++)
      for (i = 0 ; i < Image->width ; i++) {
         index = j * Image->width + i;
         red_error = Image->red[index] % 16;
         green_error = Image->green[index] % 16;
         blue_error = Image->blue[index] % 16;

         if (i < Image->width-1) {
            new_red = Image->red[index+1] + red_error * 7 / 16;
            new_green = Image->green[index+1] + green_error * 7 / 16;
            new_blue = Image->blue[index+1] + blue_error * 7 / 16;
            Image->red[index+1] = (new_red>255) ? 255 : new_red;
            Image->green[index+1] = (new_green>255) ? 255 : new_green;
            Image->blue[index+1] = (new_blue>255) ? 255 : new_blue;
            }

         if (j < Image->height-1) {
            index += Image->width;
            if (i != 0) {
               new_red = Image->red[index-1] + red_error * 3 / 16;
               new_green = Image->green[index-1] + green_error * 3 / 16;
               new_blue = Image->blue[index-1] + blue_error * 3 / 16;
               Image->red[index-1] = (new_red>255) ? 255 : new_red;
               Image->green[index-1] = (new_green>255) ? 255 : new_green;
               Image->blue[index-1] = (new_blue>255) ? 255 : new_blue;
               }


            new_red = Image->red[index] + red_error * 5 / 16;
            new_green = Image->green[index] + green_error * 5 / 16;
            new_blue = Image->blue[index] + blue_error * 5 / 16;
            Image->red[index] = (new_red>255) ? 255 : new_red;
            Image->green[index] = (new_green>255) ? 255 : new_green;
            Image->blue[index] = (new_blue>255) ? 255 : new_blue;

            if (i < Image->width-1) {
               new_red = Image->red[index+1] + red_error / 16;
               new_green = Image->green[index+1] + green_error / 16;
               new_blue = Image->blue[index+1] + blue_error / 16;
               Image->red[index+1] = (new_red>255) ? 255 : new_red;
               Image->green[index+1] = (new_green>255) ? 255 : new_green;
               Image->blue[index+1] = (new_blue>255) ? 255 : new_blue;
               }
            }
         }
   }


void process (x, y, new_red, new_green, new_blue)
   LONG x, y, new_red, new_green, new_blue;
   {
   LONG newline;

   new_red &= 0xFF;
   new_green &= 0xFF;
   new_blue &= 0xFF;

   new_red /= 16;
   new_green /= 16;
   new_blue /= 16;

   newline = 0;
   if (last_y != y) {
     newline = 1;
     last_y = y;
     reset_colours();
     }

   record_colours (new_red, new_green, new_blue);
   }


void ConvertToIFF(file_name)
   char *file_name;
   {
   char *buffer;
   BPTR file;
   BOOL PutPict();

   if ((file = Open (file_name, MODE_NEWFILE)) == 0) {
      printf ("\nCannot open IFF file\n");
      exit (0);
      }

   buffer = malloc(BUFFER_SIZE);
   if (PutPict (file, &(s->ViewPort), buffer, BUFFER_SIZE))
      printf ("\nIFF write error\n");
   Close (file);
   }

int read_raw_byte(f)
   FILE *f;
   {
   int c;
   if ((c = getc(f)) == EOF)
      return (-1);
   return (c);
   }

int read_raw_word(f)
   FILE *f;
   {
   int byte1, byte2;

   byte1 = read_raw_byte(f);
   if (byte1 == -1)
      return(-1);

   byte2 = read_raw_byte(f);
   if (byte2 == -1)
      return(-1);

   return (byte1 + byte2*256);
   }

void read_raw_image(Image, filename)
   IMAGE *Image;
   char *filename;
   {
   FILE *f;
   int byte, i, index, row, pixels;

   if ((f = fopen(filename, "rb")) == NULL) {
      printf ("Cannot open raw file %s\n", filename);
      exit(1);
      }

   Image->width = read_raw_word(f);
   if (Image->width == -1) {
      printf ("Cannot read size in dump file\n");
      exit(1);
      }

   Image->height = read_raw_word(f);
   if (Image->height == -1) {
      printf ("Cannot read size in dump file: %s\n", filename);
      exit(1);
      }

   pixels = Image->width * Image->height;

   if (((Image->red = (unsigned char *) malloc(pixels))==NULL) ||
       ((Image->green = (unsigned char *) malloc(pixels))==NULL) ||
       ((Image->blue = (unsigned char *) malloc(pixels))==NULL)) {
      printf ("Cannot allocate memory for picture: %s\n", filename);
      exit(1);
      }

   for (i = 0 ; i < pixels ; i++) {
      Image->red[i] = 0;
      Image->green[i] = 0;
      Image->blue[i] = 0;
      }

   row = read_raw_word(f);
   while (row != -1) {
      for (i = 0 ; i < Image->width ; i++) {
         index = row*Image->width + i;

         byte = read_raw_byte(f);
         if (byte == -1) {
            printf ("Unexpected end of file in raw image: %s\n", filename);
            exit(1);
            }
         Image->red[index] = byte;
         }

      for (i = 0 ; i < Image->width ; i++) {
         index = row*Image->width + i;

         byte = read_raw_byte(f);
         if (byte == -1) {
            printf ("Unexpected end of file in raw image: %s\n", filename);
            exit(1);
            }
         Image->green[index] = byte;
         }

      for (i = 0 ; i < Image->width ; i++) {
         index = row*Image->width + i;

         byte = read_raw_byte(f);
         if (byte == -1) {
            printf ("Unexpected end of file in raw image: %s\n", filename);
            exit(1);
            }
         Image->blue[index] = byte;
         }
      row = read_raw_word(f);
      }
   fclose (f);
   }
