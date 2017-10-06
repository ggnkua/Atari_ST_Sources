/*
 * Exemple of library of OGL based on LDG system
 *
 * 
 */                                           
#include <stdio.h>
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
				  "Cube Demo OpenGL : Olivier Landemarre 15 july 2000",	/* Chaine d'information */
				  LDG_NOT_SHARED   		/* Not shared (easy to use in this case!)*/
				};


static GLfloat xRot = 0.0, yRot = 0.0, zRot = 0.0;
GLuint nXray, nLightning, nFall, nCoins, nSand, nEye;

int LoadRaw(char *);

static void DrawCube(void)
{
	float fSize = 20.0f;

	// face avant
   	glCallList(nXray);
    glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
        glVertex3f(-fSize, fSize, fSize);
        glTexCoord2f(0.0f, 1.0f);
        glVertex3f(-fSize, -fSize, fSize);
        glTexCoord2f(1.0f, 1.0f);
        glVertex3f(fSize,-fSize, fSize);
        glTexCoord2f(1.0f, 0.0f);
        glVertex3f(fSize,fSize, fSize);
    glEnd();

    // face arriere
	glCallList(nCoins);
	glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
        glVertex3f(fSize,fSize, -fSize);
        glTexCoord2f(0.0f, 1.0f);
        glVertex3f(fSize,-fSize, -fSize);
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(-fSize, -fSize, -fSize);
		glTexCoord2f(1.0f, 0.0f);
		glVertex3f(-fSize, fSize, -fSize);
	glEnd();

	// face haute
  	glCallList(nEye); 
	glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f(-fSize, fSize, fSize);
		glTexCoord2f(0.0f, 1.0f);
		glVertex3f(fSize, fSize, fSize);
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(fSize, fSize, -fSize);
		glTexCoord2f(1.0f, 0.0f);
		glVertex3f(-fSize, fSize, -fSize);
	glEnd();

	// face basse
   	glCallList(nFall);
	glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f(-fSize, -fSize, -fSize);
		glTexCoord2f(0.0f, 1.0f);
		glVertex3f(fSize, -fSize, -fSize);
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(fSize, -fSize, fSize);
		glTexCoord2f(1.0f, 0.0f);
		glVertex3f(-fSize, -fSize, fSize);
	glEnd();

	// face gauche
   	glCallList(nSand);
	glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f(-fSize, fSize, -fSize);
		glTexCoord2f(0.0f, 1.0f);
		glVertex3f(-fSize, -fSize, -fSize);
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(-fSize, -fSize, fSize);
		glTexCoord2f(1.0f, 0.0f);
		glVertex3f(-fSize, fSize, fSize);
	glEnd();

	// face droite
	glCallList(nLightning);
	glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f(fSize, fSize, fSize);
		glTexCoord2f(0.0f, 1.0f);
		glVertex3f(fSize, -fSize, fSize);
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(fSize, -fSize, -fSize);
		glTexCoord2f(1.0f, 0.0f);
		glVertex3f(fSize, fSize, -fSize);
	glEnd();
}
// end DrawCube()

static void render(void)
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// On dessine notre cube mappé
	glPushMatrix();
		glRotatef(xRot, 1.0f, 0.0f, 0.0f);
		glRotatef(yRot, 0.0f, 1.0f, 0.0f);
		glRotatef(zRot, 0.0f, 0.0f, 1.0f);
		DrawCube();
	glPopMatrix();

/*	glutSwapBuffers(); */
}
// end render()


/* because glu subroutine are not inside Tiny_gl */

void APIENTRY gluPerspective( GLdouble fovy, GLdouble aspect,
                              GLdouble zNear, GLdouble zFar )
{
   GLdouble xmin, xmax, ymin, ymax;

   ymax = zNear * tan( fovy * M_PI / 360.0 );
   ymin = -ymax;

   xmin = ymin * aspect;
   xmax = ymax * aspect;

   glFrustum( xmin, xmax, ymin, ymax, zNear, zFar );
}


static void reshape(GLsizei width, GLsizei height)
{
	GLfloat h = (GLfloat) height / (GLfloat) width;

//	glViewport(0, 0,  width,  height);  
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//glFrustum(-1.0, 1.0, -h, h, 2.0, 300.0);
	gluPerspective(45.0f, h, 10, 300);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslatef(0.0, 0.0, -150.0);
}
// end reshape()


static void init(void)
{
	nXray = glGenLists(6);
	nLightning = nXray + 1;
	nFall = nLightning + 1;
	nCoins = nFall + 1;
	nSand = nCoins + 1;
	nEye = nSand + 1;

	glNewList(nXray,GL_COMPILE);
		LoadRaw("lightnin.raw");
	glEndList();
		
	glNewList(nLightning,GL_COMPILE);
		LoadRaw("marble.raw");  
	glEndList();

	glNewList(nFall,GL_COMPILE);
		LoadRaw("fall.raw");     
	glEndList();

	glNewList(nCoins,GL_COMPILE);
		LoadRaw("coins.raw");
	glEndList();

	glNewList(nSand,GL_COMPILE);
		LoadRaw("sand.raw");
	glEndList();

	glNewList(nEye,GL_COMPILE);
		LoadRaw("eye.raw");	
	glEndList();

	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	// Permet de mieux eliminer les faces cachees
	glFrontFace(GL_CCW);
	// Active la correction de perspective pour le mapping
	//glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
	glClearColor(0.2f, 0.2f, 0.7f, 0.0f);
}
// end init()


char *path_textures=NULL;
char toload[300];
typedef struct memory_alloc{
	void *next; /* prochain bloc CAD cette entˆte puis … la suite le bloc allou‚ */
	void *alloue; /* m‚moire retourn‚e pour l'utilisation*/
} memory_alloc;

void *memoire_allouee=NULL;

void Freeall() /* d‚salloue tous les blocs m‚moire allou‚s par my_Malloc()! ()
					tous les allocs sauf pour l'image RVB c'est le client charg‚ de 
					d‚sallouer ce bloc si il veut faire mumuse aprŠs avec l'image*/
{
	
	memory_alloc *pt,*pt2;
	pt=(memory_alloc *)memoire_allouee;
	while(pt!=NULL)
	{
		pt2=(memory_alloc *)pt->next;
		ldg_Free((void *)pt);
		pt=pt2;	
	}
	memoire_allouee=NULL;
}

void *my_Malloc(taille)	/* pour Garbage collecting de la m‚moire allou‚e */
long taille;
{ void *pt=NULL;
  memory_alloc *pt2;
	pt=(void *)ldg_Malloc(taille+sizeof(memory_alloc));
	if(pt!=NULL)
	{
		pt2=(memory_alloc *) pt;
		pt2->next=memoire_allouee;
		pt2->alloue=(void *)((long)pt+(long)sizeof(memory_alloc));
		memoire_allouee=(void *)pt;
		pt=(void *)((long)pt+(long)sizeof(memory_alloc));
		
	}
	return(pt);
}

int LoadRaw(char* FileName)
{
	long hRawFile;   
	unsigned long lBitSize = 256*256*3; // 256x256 en 24bits (16 millions de couleurs)
	unsigned char *pBitmapData;
	long lSize;

	// On ouvre le fichier contenant la bitmap
	strcpy(toload,path_textures);
	strcat(toload,FileName);
	hRawFile = Fopen(toload, 0);       /* use GEMDOS Fopen() because unix standard can failled under LDG ! */

	// test si le fichier est present...
	if(hRawFile < 0L)
	{
		Cconws("Impossible d'ouvrir le fichier : ");
		Cconws(toload);
		Cconws("\015\012");
		return 0;
	}
	// Alloue l'espace necessaire pour notre bitmap
	pBitmapData = (unsigned char *) my_Malloc(lBitSize);   /* idem fopen() */
	lSize = Fread(hRawFile,lBitSize,pBitmapData);
	if(lSize ==0 )
	{
		if(pBitmapData)
			ldg_Free(pBitmapData);
		pBitmapData = NULL;
		return 0;
	}
	Fclose(hRawFile);

	glTexImage2D(GL_TEXTURE_2D, 0, 3, 256, 256, 0,
                GL_RGB, GL_UNSIGNED_BYTE, pBitmapData);

	/*ldg_Free(pBitmapData);  because a bug in Tiny_GL.ldg no Free memory !!! */

	return 1;
}
// end LoadRaw()


      
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
			path_textures=todo->path_texture;
			Freeall(); /* desalloc all memory */
			init();
    	reshape(todo->width,todo->height);
  	}
		 glPolygonMode(GL_FRONT_AND_BACK,todo->model);
		 glClearColor(todo->bottom_RED,todo->bottom_GREEN,todo->bottom_BLUE,0.000000);
		 zRot=todo->Z_degree;
		 xRot=todo->X_degree;
		 yRot=todo->Y_degree;
		 render();   	 
	}
	else Cconws("Please init this OGL lib!\015\012");
}

void __CDECL ogl_quit( void) 
{
	Freeall();	
	
}

/*
 *	boucle principale: communication de la librairie avec les clients
 */

int main( void)
{
	ldg_init( LibLdg);
	return 0;
}
