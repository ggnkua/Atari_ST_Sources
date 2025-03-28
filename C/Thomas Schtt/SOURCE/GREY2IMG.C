/*
    GREY2IMG.C

    Erzeugt druckbare GEM-Images
    aus B&W Graustufenbildern

    Pure C 1.1

    von Thomas SchÅtt 1994
*/

#include <tos.h>
#include <string.h>

#define NULL ((void *) (0L))
#define min(a,b)    ((a) < (b) ? (a) : (b))
#define LO_NAME "lo.pat"
#define HI_NAME "hi.pat"

typedef struct
{
    int pix_w;
    int pix_h;
    int w;
    int h;
    unsigned char matrix[1024];
} RASTER;

typedef struct
{
    int version;
    int headlen;
    int planes;
    int pat_run;
    int pix_width;
    int pix_height;
    int sl_width;
    int sl_height;
} IMG_HEADER;

typedef struct
{
    char magic [6];
    int w;
    int h;
} BW_HEADER;

IMG_HEADER image = {1, 8, 1, 2, 0, 0, 0, 0};

RASTER lo = {142, 142, 8, 8,
{ 252,230,192,150,169,216,240,246,
  236,185,113,83,105,141,177,223,
  206,129,73,26,57,65,125,202,
  166,101,45,6,16,41,88,154,
  159,93,36,20,12,49,97,162,
  199,121,61,53,31,69,133,209,
  220,181,137,109,78,117,189,233,
  249,243,212,173,145,195,226,255}
};

RASTER hi = {71, 71, 8, 8,
{   255,253,242,215,219,245,254,255,
    253,235,180,143,171,212,225,249,
    243,200,126,60,105,116,196,243,
    218,167,93,25,45,89,151,216,
    217,159,79,51,40,97,163,217,
    243,191,110,101,70,121,204,244,
    247,230,208,175,134,185,241,253,
    255,254,244,219,213,242,250,255}
};

long do_bitstr (int fh, unsigned char *ptr,
                int len)
{
    static unsigned char bit_str[] = {0x80,
                                      0x00};
    int cnt;
    long error;

    while (len)
    {
        cnt = min (len, 255);
        bit_str[1] = cnt;
        error = Fwrite (fh, 2, bit_str);
        error = Fwrite (fh, cnt, ptr);
        len -= cnt;
        ptr = &ptr[cnt];
    }/* while */

    return (error);
}/* do_bitstr */

int line_to_img (int fh, unsigned char *ptr,
                 int w)
{
    int i, j, bw, solid_flag, bsp, cnt;
    unsigned char solid_run;
    static unsigned char pattern_run[] =
                         {0, 0, 0, 0};
    long error;

    bw = (w + 7) / 8;

    for (bsp=i=0; i<bw; i++)
    {
        solid_flag = 128;
        for (j=0; j+i < bw && ptr[j+i] == 0xff;
             j++);
        if (j == 0)
        {
            solid_flag = 0;
            for (j=0;
                 j+i < bw && ptr[j+i] == 0x00;
                 j++);
        }/* if */
        if (j > 2)
        {
            error = do_bitstr (fh, &ptr[bsp],
                               i - bsp);
            i += j;
            bsp = i;
            while (j)
            {
                cnt = min (j, 127);
                solid_run = solid_flag | cnt;
                error = Fwrite(fh,1,&solid_run);
                j -= cnt;
            }/* while */
            continue;
        }/* if */

        for (j=2;
             j+i < bw-1 && ptr[i] == ptr[i+j]
             && ptr[i+1] == ptr[i+j+1]; j+=2);
        if (j > 4)
        {
            error = do_bitstr (fh, &ptr[bsp],
                               i - bsp);
            pattern_run[2] = ptr[i];
            pattern_run[3] = ptr[i+1];
            i += j;
            bsp = i;
            j >>= 1;
            while (j)
            {
                cnt = min (j, 255);
                pattern_run[1] = cnt;
                error = Fwrite (fh, 4,
                                pattern_run);
                j -= cnt;
            }/* while */
            continue;
        }/* if */
    }/* for */

    error = do_bitstr (fh, &ptr[bsp], bw-bsp);
    return (error > 0L);

}/* line_to_img */

int grey_to_img (const char *filename, int w,
                 int h, int mag, int shift,
                 unsigned char *pic,
                 RASTER *raster)
{
    unsigned char *line, *last_line;
    int x, y, pw, ph, rep, grey, fh, maty,
        matpos;
    long ypos;
    static unsigned char vert_rep[] =
                    {0x00, 0x00, 0xff, 0x00};

    pw = w * mag;
    ph = h * mag;

    if ((line = Malloc (pw)) == NULL)
        return (0);
    if ((last_line = Malloc (pw)) == NULL)
    {
        Mfree (line);
        return (0);
    }/* if */

    fh = (int) Fcreate (filename, 0);
    if (fh < 0)
        return (0);
    image.sl_width = pw;
    image.sl_height = ph;

    if (Fwrite (fh, sizeof (IMG_HEADER),
                &image) < 0L)
        return (0);

    for (rep=y=0; y<ph; y++)
    {
        memset (line, 0, pw);
        if (shift == 0)
            maty = + (y % raster->h)*raster->w;

        ypos = y / mag;
        ypos *= w;
        for (x=0; x<pw; x++)
        {
            grey = 255-pic[(long)(x/mag)+ypos];
            if (shift == 1)
            {
                if ((x / raster->w) & 1)
                    maty = + ((y + (raster->h
                             >> 2)) % raster->h)
                              * raster->w;
                else
                    maty = + (y % raster->h) *
                              raster->w;
            }/* if */
            matpos = maty + x % raster->w;

            if (grey >= raster->matrix[matpos])
                line[x >> 3] |= 128 >> (x & 7);
        }/* for */
        if (y > 0)
        {
            if (memcmp(line,last_line,pw) == 0)
                rep++;
            else
            {
                if (rep)
                    while (rep)
                    {
                        vert_rep[3] = min (rep+1
                                           ,255);
                        if (Fwrite (fh, 4,
                            vert_rep) < 4L)
                            return (0);
                        rep -= min (rep, 255);
                        if (!line_to_img (fh,
                                last_line, pw))
                            return (0);
                    }/* while, if */
                else
                    if (!line_to_img (fh,
                            last_line, pw))
                        return (0);
            }/* else */
        }/* if */
        memcpy (last_line, line, pw);
    }/* for */

    if (rep)
        while (rep)
        {
            vert_rep[3] = min (rep + 1, 255);
            if (Fwrite (fh, 4, vert_rep) < 0L)
                return (0);
            rep -= min (rep, 255);
            if (!line_to_img (fh,last_line,pw))
                return (0);
        }/* while, if */
    else
        if (!line_to_img (fh, last_line, pw))
            return (0);

    if (Fclose (fh) < 0L)
        return (0);

    Mfree (line);
    Mfree (last_line);

    return (1);
}/* grey_to_img */

unsigned char *read_grey (const char *file,
                          int *w, int *h)
{
    unsigned char *buffer;
    int fh;
    long size;
    BW_HEADER bw;

    if ((fh = (int) Fopen (file, FO_READ)) < 0)
        return (NULL);
    if (Fread (fh, sizeof (BW_HEADER),
               &bw) > 0L)
    {
        if (strncmp (bw.magic,"B&W256",6) == 0)
        {
            size = bw.w;
            size *= bw.h;

            if ((buffer = (unsigned char *)
                        Malloc (size)) != NULL)
            {
                if (Fread (fh,size,buffer) > 0L)
                {
                    *w = bw.w;
                    *h = bw.h;
                    Fclose (fh);
                    return (buffer);
                }/* if*/
                Mfree (buffer);
            }/* if */
        }/* if */
    }/* if */
    Fclose (fh);
    return (NULL);
}/* read_grey */

void read_raster (const char *fname,
                  RASTER *raster)
{
    int fh;

    if ((fh = (int) Fopen (fname, FO_READ)) > 0)
    {
        Fread (fh, sizeof (RASTER), raster);
        Fclose (fh);
    }/* if */
}/* read_raster */

int main (char **argv, int argc)
{
    RASTER *raster;
    unsigned char *pic;
    int i, w, h, mag, shift;

    raster = &lo;
    mag = 1;
    shift = 0;
    if (argc < 3)
    {
        Cconws ("using: grey2img "
                        "[-|mag|(1-9)] "
                        "[-l|h] [-s] "
                        "infile outfile\n\r");
        return (0);
    }/* if */

    read_raster (LO_NAME, &lo);
    read_raster (HI_NAME, &hi);

    for (i=1; i<argc-2; i++)
        if (argv[i][0] == '-')
        {
            if (argv[i][1] >= '1' &&
                argv[i][1] <= '9')
                mag = argv[i][1] - '0';
            if (argv[i][1] == 'h')
                raster = &hi;
            if (argv[i][1] == 's')
                shift = 1;
        }/* if, for */

    if ((pic = read_grey (argv[argc-2], &w, &h))
         == NULL)
    {
        Cconws ("Fehler beim Lesen.\n\r");
        return (0);
    }/* if */
    Cconws ("Erzeuge GEM Image...\n\r");
    if (!grey_to_img (argv[argc-1], w, h, mag,
                      shift, pic, raster))
        Cconws ("Fehler beim Schreiben.\n\r");

    return (0);
}/* main */