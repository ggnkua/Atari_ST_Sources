/*
 *      3d routines for solid,light sourced, gouraud and phong shading
 *      (c) 1994 Martin Griffiths 
 *      University of Kent at Canterbury.
 *      Compile with : Watcom C/C++ 9.5. 
 */

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

typedef short INT16;
typedef int   INT32;

#define SHIFT 15
#define DIST  512                       /* perspective 'DISTANCE' */
#define MAX_CRDS 4096

INT16 translated_crds[MAX_CRDS][3];
INT16 perspected_crds[MAX_CRDS][3];

translate_crds (INT16 *, INT16* , INT32);
perspect_crds  (INT16 *, INT16* , INT32);

typedef struct obj 
        {       INT16 n;
                INT16 view_ang[3];
                INT16 *xyz_crds;
                INT16 n_polys;
                INT16 poly_list[128];
        } Obj;
/*

Obj cube = {    8,
                {0,0,0},
                { -100,-100,-100,
                  -100,100,-100,
                   100,-100,-100,
                   100,100,-100,
                  -100,-100,100,
                  -100,100,100,
                   100,-100,100,
                   100,100,100,
                },
                2,
                { 0,0,0 },
        };
*/
/* 
 *      Translate N points 
 */

void trans(INT16 *xyz,INT16 *new_xyz,int n)
{       int i;
        extern INT32 obj_matrix[9];
        for (i = 0 ; i < n ; i++)
        {       INT32 x,y,z;
                x = *xyz++; 
                y = *xyz++; 
                z = *xyz++; 
                *new_xyz++ = ( ((  x * obj_matrix[0] ) + 
                                 (   y * obj_matrix[1] ) +
                                 (   z * obj_matrix[2] )) >> SHIFT ); 
                *new_xyz++ = ( ((  x * obj_matrix[3] ) + 
                                 (   y * obj_matrix[4] ) +
                                 (   z * obj_matrix[5] )) >> SHIFT ); 
                *new_xyz++ = ( ((  x * obj_matrix[6] ) + 
                                 (   y * obj_matrix[7] ) +
                                 (   z * obj_matrix[8] )) >> SHIFT ); 
        }
}


/*
 *
 */

void pers(INT16 *xyz, INT16 *perspd_xyz,INT32 n)
{       int i;
        for (i = 0 ; i < n ; i++)
        {       INT16 x,y,z;
                x = *xyz++;
                y = *xyz++;
                z = *xyz++;
                *perspd_xyz++ = (x * DIST) / ( z + DIST);
                *perspd_xyz++ = (y * DIST) / ( z + DIST);
                *perspd_xyz++ = z;            /* store z for convenience */
        }

}

/*
 *
 */

void Draw_Dot_object(Obj *obj)
{       INT32 n = obj->n;
        
        make_viewmatrix(obj->view_ang);
        obj->view_ang[0] +=5;
        obj->view_ang[1] +=5;
        obj->view_ang[2] +=5;
        translate_crds (obj->xyz_crds, &translated_crds[0][0],n);
        perspect_crds (&translated_crds[0][0], &perspected_crds[0][0],n);
        //SetColour(0,40,40,40);
        //trans(obj->xyz_crds, &translated_crds[0][0],n);
        //pers (&translated_crds[0][0], &perspected_crds[0][0],n);
        //SetColour(0,50,50,50);
        {       INT16 i;
                INT16 *tmp = &(translated_crds[0][0]);
                for (i = 0 ; i < n ; i++)
                {       PlotPixelX( (*(tmp+0)) + 160,
                                   (*(tmp+1)) + 100,
                                   (10)          );
                        tmp +=3;
                }
        }
}

/*
 *
 */


void main()
{       int page;
        Obj my_obj;
        ModeX_320x240();
        {       INT16 i,j,k;
                INT16 *tmp;
                my_obj.n = 8*8*8;
                tmp = my_obj.xyz_crds = malloc (8*8*8 * sizeof (INT16));
                for (i = 0 ; i < 8 ; i++)
                {       for (j = 0 ; j < 8 ; j++)
                        {       for (k = 0 ; k < 8 ; k++)
                                {       *tmp++ = (i-4) * 10;
                                        *tmp++ = (j-4) * 10;
                                        *tmp++ = (k-4) * 10;
                                }
                        }
                }
        }
        
        WaitVbl();

        do
        {       SetDrawPage(page);
                SetViewPage(page+1);
                SetColour(0,0,0,0);
                WaitVbl();
                page++;
                SetColour(0,10,10,10);
                ClearScreen();
                SetColour(0,20,20,20);
                Draw_Dot_object(&my_obj);
        } while (!kbhit());
}

