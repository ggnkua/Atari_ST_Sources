/* 'Virtual screen' Image-viewer (C) 1994 by Eero Tamminen.
 *
 * Notice that this differs from the GEM version in where image widths
 * are word aligned and there are some additional allocation because
 * GEM version can work on other than mono resolutions too.
 */

#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include <macros.h>
#include <vt52.h>
#ifdef __GNUC__
#define lalloc  malloc
#include <memory.h>
#endif
#ifdef __SOZOBONX__
#include <malloc.h>
#endif
#include "dmatrix.h"

#ifndef FALSE
#define FALSE 0
#define TRUE  !FALSE
#endif

/* how many bytes one scanline can be */
#define LINEBUF   2048
static unsigned char buf[LINEBUF];	/* has to be on even location */

/* machine / resolution dependent variables */
static int screen_w = 80, screen_h = 400;	/* width in bytes & height */
static char *screen;

/* ------------------------------------------- */
/* error codes */
#define ERR_HEADER      1
#define ERR_ALLOC       2
#define ERR_FILE        3
#define ERR_DEPACK      4
#define ERR_COLOR	5
#define ERR_SUPPORT	6
#define ERR_TYPE	7
#define ERR_DITHER	8

/* 'cursor' keys */
#define PREV		'-'
#define NEXT		'+'
#define UP		'8'
#define DOWN		'2'
#define LEFT		'4'
#define RIGHT		'6'
#define UP_LEFT		'7'
#define UP_RIGHT	'9'
#define DOWN_LEFT	'1'
#define DOWN_RIGHT	'3'
#define INTERRUPT	'\03'	/* Ctrl-C */
#define QUIT		' '

/* ------------------------------------------- */
#define XIMG      0x58494D47

typedef struct IMG_HEADER
{                 /* Header of GEM Image Files   */
  short version;  /* Img file format version (1) */
  short length;   /* Header length in words  (8) */
  short planes;   /* Number of bit-planes    (1) */
  short pat_len;  /* length of Patterns      (2) */
  short pix_w;    /* Pixel width in 1/1000 mmm  (372)    */
  short pix_h;    /* Pixel height in 1/1000 mmm (372)    */
  short img_w;    /* Pixels per line (=(x+7)/8 Bytes)    */
  short img_h;    /* Total number of lines               */
  long  magic;    /* Contains "XIMG" if standard color   */
  short paltype;  /* palette type (0 = RGB (short each)) */
  short *palette; /* palette etc.                        */
  char *addr;     /* Address for the depacked bit-planes */
} IMG_header;

/* ------------------------------------------- */
/* Function prototypes. */
static int init(int *idx, int argc, char *argv[]);
static void reset(void);
static void show_error(int error);
static int load_pbm(FILE *fp, IMG_header *info);
static int load_img(FILE *fp, IMG_header *info);
/* the only machine / resolution dependent function */
static int show_img(IMG_header *info);
static void dither_img(unsigned char *addr, short xx, short yy, short planes, short *palette);
static void dither_pgm(unsigned char *addr, short xx, short yy, short grays);

/* ------------------------------------------- */
int main(int argc, char *argv[])
{
  FILE *fp;
  IMG_header img;
  static IMG_header null_img = {0, 0, 0, 0, 0, 0, 0, 0, 0L, 0, NULL, NULL};
  int error = FALSE, type, low, idx;
  long ext;
  short i;

  if(init(&low, argc, argv))
    return(1);

  idx = low;
  while(idx < argc && !error)
  {
    puts(argv[idx]);
    type = strlen(argv[idx]) - 4;
    if(type < 0 || (fp = fopen(argv[idx], "rb")) == NULL)
    {
      show_error((error = ERR_FILE));
    }
    else
    {
      img = null_img;
      /* for even alignment needed by long */
      ((char *)&ext)[0] = argv[idx][type++];
      ((char *)&ext)[1] = argv[idx][type++];
      ((char *)&ext)[2] = argv[idx][type++];
      ((char *)&ext)[3] = argv[idx][type];
      /* check which image type from the filename extension */
      switch(ext)
      {
        case 0x2E696D67:		/* .img */
        case 0x2E494D47:		/* .IMG */
          error = load_img(fp, &img);
          break;
        case 0x2E70626D:		/* .pbm */
        case 0x2E50424D:		/* .PBM */
        case 0x2E70676D:		/* .pgm */
        case 0x2E50474D:		/* .PGM */
        case 0x2E70706D:		/* .ppm */
        case 0x2E50504D:		/* .PPM */
          error = load_pbm(fp, &img);
          break;
        default:
          error = ERR_TYPE;
      }
      fclose(fp);

      /* dither image if it's in color */
      if(!error && img.planes > 1)
      {
	/* img width in bytes */
        puts("Dithering...");
	if(img.magic == XIMG)
	{
          i = (img.img_w + 7) >> 3;
          dither_img((unsigned char *)img.addr, i, img.img_h,
	              img.planes, img.palette);
	}
	else
          dither_pgm((unsigned char *)img.addr,
	    img.img_w, img.img_h, img.paltype);
      }
      if(error)
        show_error(error);
      else
      {
        puts(CLEAR_HOME);		/* cls */
        /* exit if not ok */
        i = show_img(&img);
        if(i)
        {
          idx = min(argc - 1, idx + i);
          idx = max(low, idx);
        }
        else
          idx = argc;
      }
      free(img.palette);
      free(img.addr);
    }
  }
  reset();
  return(error);
}

int init(int *idx, int argc, char *argv[])
{
  FILE *fp;
  static char dit_header[] = {'B', '&', 'W', '2', '5', '6',
                              '\0', '\020', '\0', '\020'};
  if(Getrez() != 2)
  {
    puts("Not ST-hi.");
    return(1);
  }
  screen = Logbase();
  *idx = 1;

  /* Read a new dither pattern */
  if(argc > 2 && argv[1][0] == '-' && argv[1][1] == 'd')
  {
    *idx += 2;
    puts(argv[2]);
    if((fp = fopen(argv[2], "rb")))
    {
      fread(buf, 1, 10, fp);
      if(!(memcmp(buf, dit_header, 10)))
        fread(dmatrix, 1, 256, fp);
      else
        show_error(ERR_DITHER);
      fclose(fp);
    }
    else
      show_error(ERR_FILE);
  }

  if(*idx >= argc)
  {
    puts("TOS img / ximg / pbm / pgm viewer.");
    puts("Usage: view [-d dither-matrix] file1 [file2...].\n");
    puts("Use keypad to scroll the picture (more precision with shift).");
    puts("'+' for the next and '-' for the previous image.");
    puts("'s' for screen dump and space to quit.");
    return(1);
  }
  puts(C_OFF);			/* disable cursor */
  return(0);
}

static void reset()
{
  puts(C_ON);			/* enable cursor */
}

/* show error alert */
static void show_error(int error)
{
  char *message;

  switch(error)
  {
    case ERR_FILE:
      message = "File error.";
      break;
    case ERR_HEADER:
      message = "Bogus image header.";
      break;
    case ERR_ALLOC:
      message = "Not enough memory.";
      break;
    case ERR_DEPACK:
      message = "Depacking error.";
      break;
    case ERR_COLOR:
      message = "Strange palette.";
      break;
    case ERR_SUPPORT:
      message = "Unsupported image format.";
      break;
    case ERR_TYPE:
      message = "Unknown image type.";
      break;
    case ERR_DITHER:
      message = "Unknown dither file type.";
      break;
    default:
      message = "Unknown error.";
  }
  puts(message);
}

static int load_pbm(FILE *fp, IMG_header *pic)
{
  int width, i = 0;

  fgets(buf, 4, fp);
  if(buf[0] != 'P')
    return(ERR_TYPE);
  switch(buf[1])
  {
    case '0':		/* ascii pbm */
    case '1':
    case '2':
    case '3':
    case '6':		/* color */
      return(ERR_SUPPORT);
      break;
    case '5':		/* grey scale */
      pic->planes = 8;
      break;
    case '4':
      pic->planes = 1;
      break;
    default:
      return(ERR_TYPE);
  }
  /* pbm size */
  fgets(buf, 16, fp);
  pic->img_w = atoi(buf);
  while(buf[i++] > ' ' && i < 16);
  pic->img_h = atoi(&buf[i]);
  if(pic->img_w == 0 || pic->img_h == 0)
    return(ERR_HEADER);

  if(pic->planes)
  {
    /* number of grayscales used */
    fgets(buf, 16, fp);
    pic->paltype = atoi(buf);
    width = pic->img_w;
  }
  else
    /* mono */
    width = pic->img_w / 8;

  /* allocate memory and load pic */
  if(!(pic->addr = (char *)malloc((long)width * pic->img_h)))
    return(ERR_ALLOC);
  fread(pic->addr, 1, (size_t)width * pic->img_h, fp);
  return(0);
}

/* Loads & depacks IMG (0 if succeded, else error). */
/* Bitplanes are one after another at IMG_HEADER.addr. */
static int load_img(FILE *fp, IMG_header *pic)
{
  int   a, b, line, plane, width, opcode, patt_len, pal_size,
        byte_repeat, patt_repeat, scan_repeat, error = FALSE;
  char  pattern[16], *address, *to, *endline;
  long  size;

  /* read header info (bw & ximg) into image structure */
  fread((char *)&(pic->version), 2, 8 + 3, fp);

  /* only 2-256 color imgs */
  if(pic->planes < 1 || pic->planes > 8)
  {
    error = ERR_COLOR;
    goto end_depack;
  }

  /* if XIMG, read info */
  if(pic->magic == XIMG && pic->paltype == 0)
  {
    pal_size = (1 << pic->planes) * 3 * 2;
    if((pic->palette = (short *)malloc(pal_size)))
    {
      fread((char *)pic->palette, 1, pal_size, fp);
    }
  }
  else
  {
    pic->palette = NULL;
  }
  /* width byte aligned */
  width = (pic->img_w + 7) >> 3;

  /* allocate memory for the picture */
  free(pic->addr);
  size = (long) width * pic->img_h * pic->planes;

  /* check for header validity & malloc long... */
  if (pic->length > 7 && pic->planes < 33 && pic->img_w > 0 && pic->img_h > 0)
    pic->addr = (char *) lalloc(size);
  else
  {
    error = ERR_HEADER;
    goto end_depack;
  }

  /* if allocation succeded, proceed with depacking */
  if(pic->addr == NULL)
  {
    error = ERR_ALLOC;
    goto end_depack;
  }
  else
  {
    patt_len = pic->pat_len;
    endline = buf + width;

    /* jump over the header and possible (XIMG) info */
    fseek(fp, (long) pic->length * 2, SEEK_SET);

    /* depack whole img */
    for(line = 0; line < pic->img_h; line += scan_repeat)
    {
      scan_repeat = 1;

      /* depack one scan line */
      for(plane = 0; plane < pic->planes; plane ++)
      {
        to = buf;

        /* depack one line in one bitplane */
        do
        {
          opcode = fgetc(fp);
          switch(opcode)
          {
            /* pattern or scan repeat */
            case 0:

              patt_repeat = fgetc(fp);
              /* repeat a pattern */
              if(patt_repeat)
              {
                /* read pattern */
                for(b = 0; b < patt_len; b ++)
                  pattern[b] = fgetc(fp);

                /* copy pattern */
                for(a = 0; a < patt_repeat; a ++)
                {
                  /* in case it's odd amount... */
                  for(b = 0; b < patt_len; b ++)
                    *(to ++) = pattern[b];
                }
              }

              /* repeat a line */
              else
              {
                if(fgetc(fp) == 0xFF)
                  scan_repeat = fgetc(fp);
                else
                {
                  error = ERR_DEPACK;
                  goto end_depack;
                }
              }
              break;

            /* repeat 'as is' */
            case 0x80:
              byte_repeat = fgetc(fp);
              for(; byte_repeat > 0; byte_repeat --)
                *(to ++) = fgetc(fp);
              break;

            /* repeat black or white */
            default:
              byte_repeat = opcode & 0x7F;
              if(opcode & 0x80)
                opcode = 0xFF;
              else
                opcode = 0x00;
              for(; byte_repeat > 0; byte_repeat --)
                *(to ++) = opcode;
          }
        }
        while(to < endline);

        if(to == endline)
        {
          /* ensure that lines aren't repeated past the end of the img */
          if(line + scan_repeat > pic->img_h)
            scan_repeat = pic->img_h - line;

          /* calculate address of a current line in a current bitplane */
          address = pic->addr  +
                  (long) line  * width +
                  (long) plane * width * pic->img_h;

          /* copy line to image buffer */
          for(a = 0; a < scan_repeat; a ++)
          {
            memcpy(address, buf, width);
            address += width;
          }
        }
        else
        {
          error = ERR_DEPACK;
          goto end_depack;
        }
      }
    }
  }
  end_depack:
  return(error);
}

/* machine / resolution image showing routine */
static int show_img(IMG_header *pic)
{
  int i, x, y, xed, yed, xx, yy, width, key, speedx, speedy;
  char *place;
  FILE *fp;

  width = (pic->img_w + 7) >> 3;	/* img width in bytes */

  x = y = 0;				/* image pos on screen */
  xed = yed = i = 0;
  xx = min(width, screen_w);		/* movable data lenght */
  yy = min(pic->img_h, screen_h);	/*  -"-         height */

  /* center pic onto the screen */
  place = screen + ((screen_h - yy) >> 1) * screen_w + ((screen_w - xx) >> 1);
  while(TRUE)
  {
    x = min(x, width - xx);
    y = min(y, pic->img_h - yy);
    if(x < 0) x = 0;
    if(y < 0) y = 0;
    if(x != xed || y != yed || i != yy)
      for(i = 0; i < yy; i++)
      {
        if(Cconis())		/* Check for a keypress */
	  i = yy + 1;
	else
          memcpy(place + i * screen_w, pic->addr + (y + i) * width + x, xx);
      }
    xed = x;
    yed = y;
    key = Crawcin() & 0xFF;	/* ASCII-code of key press   */
    if(Kbshift(-1))		/* more precision with shift */
    {
      speedx = 1;
      speedy = 8;
    }
    else
    {
      speedx = 4;
      speedy = 32;
    }
    switch(key)
    {
      case UP:
        y -= speedy;
        break;
      case DOWN:
        y += speedy;
        break;
      case LEFT:
        x -= speedx;
        break;
      case RIGHT:
        x += speedx;
        break;
      case UP_LEFT:
        x -= speedx;
        y -= speedy;
        break;
      case UP_RIGHT:
        x += speedx;
        y -= speedy;
        break;
      case DOWN_LEFT:
        x -= speedx;
        y += speedy;
        break;
      case DOWN_RIGHT:
        x += speedx;
        y += speedy;
        break;
      case NEXT:
        return(1);
        break;
      case PREV:
        return(-1);
        break;
      case 's':
      case 'S':
        if((fp = fopen("dump.doo", "wb")))
        {
          for(i = 0; i < yy; i++)
            fwrite(pic->addr + (y + i) * width + x, 1, xx, fp);
          fclose(fp);
        }
        break;
      case QUIT:
      case INTERRUPT:
        return(0);
    }
  }
}

/* dither 2-8 (byte aligned) bitplanes into mono 'on place' */
static void dither_img(unsigned char *addr, short width, short height,
                       short planes, short *palette)
{
  unsigned char *plane, *mat, *intensity, *offset, *last_p, first_p[8];
  short i, bit, color, x, y, row, odd, result, colors;
  short *color_val, col_min = 255, col_max = 0;
  long size;

  color_val = intensity = buf;
  last_p = &first_p[planes - 1];
  size = (long)width * height;
  colors = (1 << planes);

  /* scan palette */
  for(i = 0; i < colors; i ++)
  {
    color_val[i] = 0;
    /* add register values together to get the grey level */
    for(bit = 0; bit < 3; bit ++)
      color_val[i] += *(palette + 3 * i + bit);

    col_min = min(col_min, color_val[i]);
    col_max = max(col_max, color_val[i]);
  }
  /* scale color values to 0 - 255 range */
  for(i = 0; i < colors; i ++)
    intensity[i] = (long)(color_val[i] - col_min) * 255 / (col_max - col_min);


  /* remake the first bitplane */
  colors >>= 1;
  for(y = 0; y < height; y++)
  {
    odd = FALSE;
    row = y % 16;
    for(x = 0; x < width; x++)
    {
      if(odd)
      {
        mat = &dmatrix[row][8];
	odd = FALSE;
      }
      else
      {
        mat = dmatrix[row];
	odd = TRUE;
      }
      offset = addr;
      plane = first_p;
      for(i = 0; i < planes; i++)
      {
	/* get one char from a bitplane into the array */
	*(plane ++) = *(offset);
	offset += size;
      }

      /* go through one byte on all bitplanes (max. 8) */
      result = 0;
      for(bit = 128; bit > 0; bit >>= 1)
      {
	color = 0;
	plane = last_p;

	/* planar->chunky */
	for(i = colors; i > 0; i >>= 1)
	  if((*(plane --) & bit))
	    color |= i;

	/* set bit in resulting bitplane if its' intensity demands it */
	if(intensity[color] < *(mat ++))
	  result |= bit;
      }
      *(addr++) = result;
    }
  }
}

/* dither a chunky byte aligned 8-bit greyscale 'on place' to monochrome */
static void dither_pgm(unsigned char *addr, short xx, short yy, short grays)
{
  unsigned char *mat, *intensity, *idx, bit, result, clear;
  short x, y, width, row, odd, less;
  width = (xx + 7) >> 3;	/* byte aligned width */
  less = (width << 3) - xx;	/* number of pixels short from aligning */
  clear = 0xff ^ ((1 << less) - 1);	/* mask for them */
  idx = addr;
  addr--;

  /* grayscale conversion array */
  intensity = buf;
  for(y = 0; y <= grays; y++)
    intensity[y] = y * 255 / grays;

  /* remake first bitplane */
  for(y = 0; y < yy; y++)
  {
    odd = FALSE;
    row = y % 16;
    for(x = 0; x < width; x++)
    {
      if(odd)
      {
        mat = &dmatrix[row][8];
	odd = FALSE;
      }
      else
      {
        mat = dmatrix[row];
	odd = TRUE;
      }
      result = 0;

      /* go through one byte's worth of pixels */
      for(bit = 128; bit > 0; bit >>= 1)
        /* color/matrix->black? */
        if(intensity[*(idx++)] < *(mat ++))
          result |= bit;

      addr++;
      *(addr) = result;
    }
    idx -= less;
    *(addr) &= clear;
  }
}
