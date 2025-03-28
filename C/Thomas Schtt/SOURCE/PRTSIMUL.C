/*
    PRTSIMUL.C
    ----------

    Druckersimulator zur Mustergenerierung

    Pure C 1.1

    Thomas SchÅtt    1994
*/

#include <vdi.h>
#include <aes.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

typedef struct
{
    int pix_w;
    int pix_h;
    int w;
    int h;
    unsigned char matrix[1024];
} RASTER;

int handle, work_in[11], work_out[57];

RASTER raster;
double x_dis, y_dis, siz;
char infile[128], outfile[128];

unsigned char matrix[1024];

int mat_w, mat_h;

double finput (const char *s)
{
    double v;

    do
    {
        printf ("\r%s ", s);
        scanf ("%lf", &v);
    } while (v == 0.0);

    if (v == floor (v))
        v = 25.7 / v; /* dpi -> mm */
    return (v);
}/* finput */

void input (void)
{
    char jn[2];
    do
    {
        printf ("\33E\33eDruckersimulation "
                "1.0\n\n\r");
        printf ("Eingabedatei (Matrix): ");
        scanf ("%s", infile);
        x_dis = finput ("\nPunktabstand (X) [mm]"
                        " oder [dpi]:");
        y_dis = finput ("Punktabstand (Y) [mm] "
                        "oder [dpi]:");
        siz = finput ("Punktgrîûe [mm] oder "
                      "[dpi]      :");
        printf ("Ausgabedatei (Matrix): ");
        scanf ("%s", outfile);
        printf ("\33EAusgangswerte\n\n\r");
        printf ("Punktabstand (X) %.4lfmm\n\r",
                x_dis);
        printf ("Punktabstand (Y) %.4lfmm\n\r",
                y_dis);
        printf ("Punktgrîûe %.4lfmm\n\r", siz);
        printf ("Eingabedatei: '%s'\n\r",
                infile);
        printf ("Ausgabedatei: '%s'"
                "\n\n\rEingaben ok? [j/n]",
                outfile);
        scanf ("%1s", jn);
    } while (jn[0] != 'j' && jn[0] != 'J');
    printf ("\33E\33f");
}/* input */

int getnumber (FILE *file)
{
    char buffer[20];
    int c, i;

    do
    {
        if ((c = fgetc (file)) == EOF)
            return (-1);
    } while (!isdigit (c));
    i = 0;
    do
    {
        buffer[i++] = c;
        c = fgetc (file);
    } while (isdigit (c));
    buffer[i] = '\0';
    return (atoi (buffer));
}/* getnumber */

int read_matrix (const char *fname)
{
    unsigned char *inptr;
    int count, n;
    FILE *file;

    if ((file = fopen (fname, "r")) == NULL)
        return (0);
    if ((mat_w = getnumber (file)) < 0)
        return (-1);
    if ((mat_h = getnumber (file)) < 0)
        return (-1);

    inptr = matrix;
    for (count=mat_w*mat_h; count>0; count--)
        if ((n = getnumber (file)) >= 0)
            *inptr++ = n;
        else
            return (-1);
    fclose (file);
    return (1);
}/* read_matrix */

int write_pattern (const char *fname)
{
    FILE *file;

    raster.pix_w = x_dis * 1000.0;
    raster.pix_h = y_dis * 1000.0;
    raster.w = mat_w;
    raster.h = mat_h;
    if ((file = fopen (fname, "wb")) == NULL)
        return (0);
    if (fwrite (&raster, sizeof (RASTER),
                1, file) < 1)
        return (0);
    fclose (file);
    return (1);
}/* write_pattern */

void prtsimul (void)
{
    int cx, cy, cw, ch, xd, yd, xp, yp, r, fac,
        pxy[8], i, x, y, pel, d, button, new,
        nx, ny;
    long maxsum, sum;

    fac = 150.0 / ((mat_h + 1) * y_dis);
    xd = x_dis * fac;
    yd = y_dis * fac;
    r = siz * fac / 2;
    cw = xd * mat_w;
    ch = yd * mat_h;
    cx = (work_out[0] - cw) / 2;
    cy = (work_out[1] - ch) / 2;
    v_clrwk (handle);
    vsf_perimeter (handle, 0);
    pxy[0] = cx;            pxy[1] = cy;
    pxy[2] = cx + cw - 1;   pxy[3] = cy + ch - 1;
    vs_clip (handle, 1, pxy);
    xp = cx + xd / 2;
    yp = cy + yd / 2;
    maxsum = cw * ch;

    for (i=1; i<=mat_w*mat_h; i++)
    {
        for (y=0; y<mat_h; y++)
            for (x=0; x<mat_w; x++)
                if (i == matrix[y*mat_w+x])
                {
                    nx = x;
                    ny = y;
                    v_ellipse (handle, xp+xd*x,
                               yp+yd*y, r, r);
                }/* if, for, for */
        sum = 0L;
        for (y=cy; y<cy+ch; y++)
            for (x=cx; x<cx+cw; x++)
            {
                v_get_pixel (handle, x, y,
                             &pel, &d);
                vq_mouse (handle, &button,
                          &d, &d);
                if (pel)
                    sum++;
                if (button == 3)
                    exit (1);
            }/* for, for */
            new = (double) sum /
                  (double) maxsum * 255.0 + 0.5;
            raster.matrix[ny*mat_w+nx] = new;
            printf ("\33HGraustufe %d: %d   ",
                    i, new);
    }/* for */
}/* prtsimul */

int main    ()
{
    int d, i, ok;

    appl_init ();

    handle = graf_handle (&d, &d, &d, &d);

    for (i=0;   i<10; work_in[i++] = 1);

    work_in[10] =   2;

    v_opnvwk (work_in, &handle, work_out);

    v_hide_c (handle);
    v_clrwk (handle);
    input ();
    ok = read_matrix (infile);
    if (ok <= 0)
    {
        if (ok == 0)
            puts ("\rKann Eingabedatei "
                  "nicht finden.");
        else
            puts ("\rFehler in Eingabedatei.");
        return (0);
    }/* if */
    prtsimul ();
    if (!write_pattern (outfile))
        puts ("\rFehler beim schreiben.");

    v_show_c (handle, 0);
    v_clsvwk (handle);
    appl_exit ();
    return (0);
}/* main */