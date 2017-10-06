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
				  "TEX_NUM Demo OpenGL : Olivier Landemarre 15 july 2000",	/* Chaine d'information */
				  LDG_NOT_SHARED   		/* Not shared (easy to use in this case!)*/
				};


static GLuint TexObj[2];
static GLfloat Angle = 0.0f;

static int cnt=0,v=0;

static void draw(void)
{
  glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

  glColor3f(1.0, 0.5, 0.2);
  
  /* draw first polygon */
  glPushMatrix();
  glTranslatef(-1.0, 0.0, 0.0);
  glRotatef(Angle, 0.0, 0.0, 1.0);
  glBindTexture(GL_TEXTURE_2D, TexObj[v]);

  glEnable(GL_TEXTURE_2D);
  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 0.0);
  glVertex2f(-1.0, -1.0);
  glTexCoord2f(1.0, 0.0);
  glVertex2f(1.0, -1.0);
  glTexCoord2f(1.0, 1.0);
  glVertex2f(1.0, 1.0);
  glTexCoord2f(0.0, 1.0);
  glVertex2f(-1.0, 1.0);
  glEnd();
  glDisable(GL_TEXTURE_2D);
  glPopMatrix();

  /* draw second polygon */
  glPushMatrix();
  glTranslatef(1.0, 0.0, 0.0);
  glRotatef(Angle - 90.0, 0.0, 1.0, 0.0);

  glBindTexture(GL_TEXTURE_2D, TexObj[1-v]);

  glEnable(GL_TEXTURE_2D);
  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 0.0);
  glVertex2f(-1.0, -1.0);
  glTexCoord2f(1.0, 0.0);
  glVertex2f(1.0, -1.0);
  glTexCoord2f(1.0, 1.0);
  glVertex2f(1.0, 1.0);
  glTexCoord2f(0.0, 1.0);
  glVertex2f(-1.0, 1.0);
  glEnd();
  glDisable(GL_TEXTURE_2D);

  glPopMatrix();

}

void bind_texture(int texobj,int image)
{
  static int width = 8, height = 8;
  static int color[2][3]={
    {255,0,0},
    {0,255,0},
  };
  GLubyte tex[64][3];
  int colorfond=255;
  
  static GLubyte texchar[2][8*8] = {
  {
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 1, 0, 0, 0,
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 0, 0, 1, 0, 0, 0,
    0, 0, 0, 0, 1, 0, 0, 0,
    0, 0, 0, 0, 1, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0},
  {
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 2, 2, 0, 0, 0,
    0, 0, 2, 0, 0, 2, 0, 0,
    0, 0, 0, 0, 0, 2, 0, 0,
    0, 0, 0, 0, 2, 0, 0, 0,
    0, 0, 0, 2, 0, 0, 0, 0,
    0, 0, 2, 2, 2, 2, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0}};

  int i,j;
  if(image==1) colorfond=200;
  glBindTexture(GL_TEXTURE_2D, texobj);

  /* red on white */
  for (i = 0; i < height; i++) {
    for (j = 0; j < width; j++) {
      int p = i * width + j;
      if (texchar[image][(height - i - 1) * width + j]) {
        tex[p][0] = color[image][0];
        tex[p][1] = color[image][1];
        tex[p][2] = color[image][2];
      } else {
        tex[p][0] = colorfond;
        tex[p][1] = colorfond;
        tex[p][2] = colorfond;
      }
    }
  }
  glTexImage2D(GL_TEXTURE_2D, 0, 3, width, height, 0,
    GL_RGB, GL_UNSIGNED_BYTE, tex);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  /* end of texture object */
}

static void init(void)
{
  glEnable(GL_DEPTH_TEST);

  /* Setup texturing */
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

  /* generate texture object IDs */
  glGenTextures(2, TexObj);
  bind_texture(TexObj[0],0);
  bind_texture(TexObj[1],1);  
  
}

static void idle(void)
{
  
  Angle += 2.0;

  if (++cnt==5) {
    cnt=0;
    v=!v;
  }
}
      
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
long old_width=0L,old_height=0L;
void __CDECL ogl_do_3D( world3D *todo) 
{ 
	if(flag_init)
	{
		if(todo->flag&1)
		{
			

	/*		glViewport(0, 0, (GLint) todo->width, (GLint) todo->height);  */
  		glMatrixMode(GL_PROJECTION);
  		glLoadIdentity();
  		/* glOrtho( -3.0, 3.0, -3.0, 3.0, -10.0, 10.0 ); */
  		glFrustum(-2.0, 2.0, -2.0, 2.0, 6.0, 20.0);
  		glMatrixMode(GL_MODELVIEW);
  		glLoadIdentity();
  		glTranslatef(0.0, 0.0, -8.0);
  		glDisable(GL_CULL_FACE);
  		old_width=todo->width;
  		old_height=todo->height;
  		
  		/*  because Tiny_demo close the context for resize (for the moment) we need reiinit the textures */
  	  init();
  	}
  	glClearColor(todo->bottom_RED,todo->bottom_GREEN,todo->bottom_BLUE,0.000000);
		draw();
		idle();
	}
	else Cconws("Please init this OGL lib!\015\012");
}

void __CDECL ogl_quit( void) 
{
	old_width=0L;
	old_height=0L;
	
}

/*
 *	boucle principale: communication de la librairie avec les clients
 */

int main( void)
{
	ldg_init( LibLdg);
	return 0;
}
