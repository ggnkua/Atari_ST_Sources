#include <stdio.h>

/* #define IBM TRUE */

#define PARAMS(x) x

struct Image_Line
   {
   unsigned char *red, *green, *blue;
   };

struct Image_Struct
   {
   int iwidth, iheight;
   IMAGE_LINE *rgb_lines;
   };

typedef struct Image_Struct IMAGE;

IMAGE Raw_Image;

FILE *fp, *palette_file, *output_palette_file;
FILE *fred, *fgrn, *fblu;
char input_filename[100], master_filename[100], output_filename[100];
int image_width, image_height;

#ifdef IBM
#define REDNAME "%s.r8"
#define GRNNAME "%s.g8"
#define BLUNAME "%s.b8"
#define DEFAULT_WIDTH  320
#define DEFAULT_HEIGHT 200
#else
#define REDNAME "%s.red"
#define GRNNAME "%s.grn"
#define BLUNAME "%s.blu"
#define DEFAULT_WIDTH  320
#define DEFAULT_HEIGHT 400
#endif

int read_raw_byte PARAMS((FILE *f));
int read_raw_word PARAMS((FILE *f));
void read_raw_image PARAMS((IMAGE *Image));
void get_parameters PARAMS((int argc, char **argv));
void OpenRGB PARAMS((void));
void SaveRGB PARAMS((int red, int grn, int blu));

void main (argc, argv) 
   int argc;
   char **argv;
   {
   unsigned int x, y, index;

   if (argc < 2)
     {
     printf ("\nUsage:  DumpToRGB [-wxxx -hxxx] <filename>\n   .dis extension is assumed for <filename>\n   default image size: %d x %d", DEFAULT_WIDTH, DEFAULT_HEIGHT);
     exit(0);
     }

   fp = NULL;

   get_parameters(argc, argv);

   printf ("Reading raw file\n");
   read_raw_image (&Raw_Image);

   printf ("Converting...\n");

   OpenRGB();
   for (y = 0 ; y < Raw_Image.height ; y++) {
      for (x = 0 ; x < Raw_Image.width ; x++) {
         index = y*Raw_Image.width + x;
         SaveRGB((int)Raw_Image.red[index],(int)Raw_Image.green[index],(int)Raw_Image.blue[index]);
         }
      for (; x < image_width ; x++)
	SaveRGB(0, 0, 0);
      }
   for (; y < image_height ; y++)
      for (; x < image_width; x++)
	SaveRGB(0, 0, 0);
   fclose(fred);
   fclose(fgrn);
   fclose(fblu);
   }

void get_parameters (argc, argv)
   int argc;
   char **argv;
   {
   int i, filename_number;

   image_height = DEFAULT_HEIGHT;
   image_width = DEFAULT_WIDTH;

   filename_number = 0;
   for (i = 1 ; i < argc ; i++) {

      if (argv[i][0] == '-')
	 switch (argv[i][1]) {
	    case 'w': sscanf(&argv[i][2], "%d", &image_height);
		      break;
	    case 'h': sscanf(&argv[i][2], "%d", &image_height);
		      break;
	    default : printf("Unknown option %s - proceeding...\n");
	    }
      else
         switch (filename_number) {
            case 0: strcpy (master_filename, argv[i]);
		    sprintf (input_filename, "%s.dis", master_filename);
		    filename_number++;
                    break;

            default: printf ("Too many filenames in commandline\n");
                     exit(1);
            }
      }
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

void OpenRGB()
{
   char nmbuff[200];

   sprintf( nmbuff, REDNAME, master_filename );
   if ((fred = fopen(nmbuff, "wb")) == NULL) {
      printf ("Cannot open red output file for %s\n", master_filename);
      exit(1);
      }

   sprintf( nmbuff, GRNNAME, master_filename );
   if ((fgrn = fopen(nmbuff, "wb")) == NULL) {
      printf ("Cannot open green output file for %s\n", master_filename);
      exit(1);
      }

   sprintf( nmbuff, BLUNAME, master_filename );
   if ((fblu = fopen(nmbuff, "wb")) == NULL) {
      printf ("Cannot open blue output file for %s\n", master_filename);
      exit(1);
      }
}

void SaveRGB(red, grn, blu)
int red, grn, blu;
{
   fputc( red, fred );
   fputc( grn, fgrn );
   fputc( blu, fblu );
}

void read_raw_image(Image)
   IMAGE *Image;
   {
   FILE *f;
   unsigned int i, index, pixels;
   int byte, row;

   if ((f = fopen(input_filename, "rb")) == NULL) {
      printf ("Cannot open raw file %s\n", input_filename);
      exit(1);
      }

   Image->width = read_raw_word(f);
   if (Image->width == -1) {
      printf ("Cannot read size in dump file\n");
      exit(1);
      }

   Image->height = read_raw_word(f);
   if (Image->height == -1) {
      printf ("Cannot read size in dump file: %s\n", input_filename);
      exit(1);
      }

   pixels = Image->width * Image->height;

   if (((Image->red = (unsigned char *) malloc(pixels))==NULL) ||
       ((Image->green = (unsigned char *) malloc(pixels))==NULL) ||
       ((Image->blue = (unsigned char *) malloc(pixels))==NULL)) {
      printf ("Cannot allocate memory for picture: %s\n", input_filename);
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
            printf ("Unexpected end of file in raw image: %s\n", input_filename);
            exit(1);
            }
         Image->red[index] = byte;
         }

      for (i = 0 ; i < Image->width ; i++) {
         index = row*Image->width + i;

         byte = read_raw_byte(f);
         if (byte == -1) {
            printf ("Unexpected end of file in raw image: %s\n", input_filename);
            exit(1);
            }
         Image->green[index] = byte;
         }

      for (i = 0 ; i < Image->width ; i++) {
         index = row*Image->width + i;

         byte = read_raw_byte(f);
         if (byte == -1) {
            printf ("Unexpected end of file in raw image: %s\n", input_filename);
            exit(1);
            }
         Image->blue[index] = byte;
         }
      row = read_raw_word(f);
      }
   fclose (f);
   }
