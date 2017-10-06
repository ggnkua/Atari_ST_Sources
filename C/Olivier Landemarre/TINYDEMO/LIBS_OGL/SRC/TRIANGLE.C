/*
 * Exemple of library of OGL based on LDG system
 *
 * 
 */                                           

#include <portab.h>
#include <osbind.h>
#include <ldg.h>         
#include <math.h>
#undef APIENTRY
#define APIENTRY __CDECL 
#include "mesa_ldg.h" 

#include "initiny.c"

/* Un type pour ‚viter les conflicts avec Purec */

typedef struct real {
		float X_degree;       /* angle of rotations (absolute) */
		float Y_degree;
		float Z_degree;
		long width;
		long height;
		long flag;       /* bit 0 to 1 init your OpenGL context */
		float bottom_RED;          /* colors from 0.0 to 1.0 for the bollom */
		float bottom_GREEN;
		float bottom_BLUE;
		long model; /* GL_FILL, GL_POINT, BL_LINE */
		char *path_texture;  /* path to find textures */
		long reserved1;
		long reserved2;
		long reserved3;
		long reserved4;
		long reserved5;
	} world3D;

/* prototypages */


void __CDECL ogl_init(LDG *tiny_gl);
void __CDECL ogl_do_3D( world3D *todo);
void __CDECL ogl_quit( void);

/*
 * tableau de taille … modifier pour mettre toutes 
 * les addresses des proc‚dures … pr‚senter 
 */

PROC LibFunc[] = { "ogl_init", "void CDECL ogl_init(LDG *tiny_gl)", ogl_init,
				   "ogl_do_3D", "void CDECL do_3D( world3D *todo);", ogl_do_3D,
				   "ogl_quit", "void CDECL quit( void);", ogl_quit };

LDGLIB LibLdg[]={ 
				  0x0100,	/* version of the lib */
				  3,		/* number of functions in lib (for .OGL only 3, always: 
				  				void CDECL ogl_init(LDG *tiny_gl),
				  				void CDECL do_3D( world3D *todo),
				  				void CDECL quit( void)) */
				  LibFunc,	/* Functions adress */
				  "Triangle Demo OpenGL : Olivier Landemarre 15 july 2000",	/* Chaine d'information */
				  LDG_NOT_SHARED   		/* Not shared (easy to use in this case!)*/
				};





      
/*
 *	functions for that use the client
 */
int flag_init=0;

void __CDECL ogl_init(LDG *tiny_gl) 
{
	if(tiny_gl) 
	{
		init_tiny(tiny_gl);
		if(glEnable)
		{
			flag_init=1;			
		}
		else Cconws("Erreur initiation\015\012"); 
	}
}


void __CDECL ogl_do_3D( world3D *todo) 
{ float x=0.5,y=0.2,z=0.5; 
	if(flag_init)
	{
		if(todo->flag&1)
		{               /* a good init is need here because other draw can be done by other calculus !!! */
			glMatrixMode((long)GL_PROJECTION);
    	glLoadIdentity();  /* Identity matrix */
    	glOrtho(-1.0,       1.0,   -1.0,    1.0,  -1.0,    1.0);  /* the space of calculation*/
    	
    	
    	glClear( (long)(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) );   /* to clear */
    	glEnable(GL_DEPTH_TEST);    /* test of position of course */
    	glMatrixMode(GL_MODELVIEW);
  	}
		 glPolygonMode(GL_FRONT_AND_BACK,todo->model);
		 glClearColor(todo->bottom_RED,todo->bottom_GREEN,todo->bottom_BLUE,0.000000);
		 glLoadIdentity();
		 if(todo->X_degree) glRotatef(todo->X_degree, 1.0, 0., 0.);
		 if(todo->Y_degree) glRotatef(todo->Y_degree, 0.0, 1., 0.);
		 if(todo->Z_degree) glRotatef(todo->Z_degree, 0.0, 0., 1.);
		 
   	 glClear( (long)(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) );   /* clear */
     glBegin(GL_TRIANGLES);  /* to use triangle 3point for each */
		                      
	   glColor3f(0.0, 0.0, 1.0);   /* each point can have there own color (blue)*/
	   glVertex3f(-0.5, 0.0, 0.0);  /* first point */
		 glColor3f(1.0, 1.0, 1.0);   /* white */
		 glVertex3f(0.0, 0.5, 0.2);  /* second point */ 
		 glColor3f(1.0, 0.0, 0.0);   /* red */
		 glVertex3f(0.5, 0.0, 0.0);  /* third point */
		
		 glColor3f(0.0, 1.0, 0.0);     /* a triangle all green */	 
		 glVertex3f(-x, y, -z);  /* first point */
		 glVertex3f(x, y, -z);   /* second point */		 	
		 glVertex3f(0.0, -0.1, z);   /* third point */
		 
     glEnd();   /* end for triangles */
     glBegin(GL_LINES);
     glVertex3f(0.0, 0.0, 0.0); 
     glVertex3f(0.0, 0.5, 0.0);
     glEnd();
	}
	else Cconws("Please init this OGL lib!\015\012");
}

void __CDECL ogl_quit( void) 
{
	
	
}

/*
 *	boucle principale: communication de la librairie avec les clients
 */

int main( void)
{
	ldg_init( LibLdg);
	return 0;
}
