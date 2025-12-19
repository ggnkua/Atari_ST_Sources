/*-------------------------------------------------------------------------

			   3D2 to DKB File Converter
			 Copyright 1991 by Steve Anger

  This file may be freely modified and distributed so long as the original
copyright notice is included.

V1.2 05/09/91 Minor MSC compatibility modifications made by Aaron A. Collins

--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#ifdef __TURBOC__
#include <stdlib.h>
#include <ext.h>
#include <graphics.h>
#define min(a, b)   ((a) < (b) ? (a) : (b))
#define max(a, b)   ((a) > (b) ? (a) : (b))
#endif

const char Ver[] = "v1.2";

#ifndef M_PI
#define M_PI	3.14159265358979323846
#endif

typedef struct
{
    float x, y, z;
} Vector;


typedef struct
{
    float Red;
    float Green;
    float Blue;
} Palette;


typedef struct
{
    int    VertA;        /* Vertex A of the triangle */
    int    VertB;        /*   "    B  "  "      "    */
    int    VertC;        /*   "    C  "  "      "    */
    int    Colour;       /* Colour of triangle */
    int    EdgeFlag;     /* Which edges are to be drawn (not used) */
} Triangle;


typedef struct TriNode
{
    int  TriNo;
    struct TriNode *Next;
} TriangleNode;


typedef unsigned char byte;
typedef signed int word;
typedef int boolean;
const int true = 1;
const int false = 0;

/* Function prototype definitions */
void Read3D2Header(void);
void Read3D2Object(void);

void WriteDKBHeader(void);
void WriteDKBObject(void);
void WriteDKBSummary(void);

void ProcessArgs (int argc, char *argv[]);
void PrintVector (FILE *g, Vector *V);
void AddExt (char *FileName, char *Ext, boolean Force);
byte ReadByte(FILE *f);
word ReadWord(FILE *f);
void Abort (char* Msg, int ExitCode);
void MinVector (Vector *V1, Vector *V2);
void MaxVector (Vector *V1, Vector *V2);
void VertNormal (Triangle *T, Vector *NormA, Vector *NormB, Vector *NormC);
void BuildTriIndex (void);
void DumpTriIndex (void);
void TriNormal (Triangle *T, Vector *Normal);

void InitDisplay(void);
void PlotTriangle (Triangle *Tri);
void CloseDisplay(void);

void  VectAdd (Vector *V1, Vector *V2, Vector *V3);
void  VectSub (Vector *V1, Vector *V2, Vector *V3);
void  VectScale (Vector *V1, float k);
float VectMag (Vector *V);
float DotProd (Vector *V1, Vector *V2);
void  CrossProd (Vector *V1, Vector *V2, Vector *V3);
void  VectCopy (Vector *V1, Vector *V2);
void  VectInit (Vector *V, float x, float y, float z);
float VectAngle (Vector *V1, Vector *V2);

/* Global variables */
FILE      *f;             /* Input file */
FILE      *g;             /* Output file */
char      InFile[64];     /* Input file name */
char      OutFile[64];    /* Output file name */
boolean   Display;        /* Screen preview flag */
Vector    LookAt;         /* Location to look at */
Vector    ViewPoint;      /* Location of viewpoint */
Vector    Nx, Ny, Nz;     /* Co-ord system for rotated space */
float     Smooth;         /* Smooth triangles who's normals differ by */
			  /* less than this angle (degrees) */

/* 3D2 Header infomation */
int       ObjCount;       /* Number of objects contained in file */
int       LightOn[3];     /* 1 = Light source is on, 0 = off */
float     LightBright[3]; /* Light source brightness */
Vector    LightPos[3];    /* Light source position */
float     Ambient;        /* Ambient light brightness */
Palette   Pal[16];        /* Colour palette for objects */
int       GBase[16];      /* Colour group base array (not used) */
int       PalType;        /* Colour palette type (not used) */
int       WColour;        /* Wireframe colour (not used) */
int       OColour;        /* Outline colour (not used) */

/* 3D2 Object information */
char      ObjName[9];     /* Name of current object */
int       VertCount;      /* Number of verticies in object */
Vector    *Vert;          /* Pointer to array of verticies */
int       TriCount;       /* Number of triangular faces in object */
Triangle  *Tri;           /* Pointer to array of triangles */
int       DegenTri;       /* Degenerate triangles */

Vector    ObjMin, ObjMax;
TriangleNode **TriList;   /* List of triangles touching each vertex */



int main (int argc, char* argv[])
{
    int i;
    int  Verticies[40], Triangles[40], Degens[40];
    char Names[40][9];
    int  TotalTri, TotalVert, TotalDegen;

    ProcessArgs (argc, argv);

    if (Display)
	InitDisplay();

    Read3D2Header();                  /* Read 3D2 file header */
    WriteDKBHeader();                 /* Write DKB file header info */

    for (i = 0; i < ObjCount; i++) {
	Read3D2Object();              /* Read an object from 3D2 file */
	WriteDKBObject();             /* Write object to DKB file */

	strcpy (Names[i], ObjName);   /* Keep a list of the object names, */
	Verticies[i] = VertCount;     /* vertex counts, etc. */
	Triangles[i] = TriCount;
	Degens[i] = DegenTri;
    }

    WriteDKBSummary();

    fclose(f);
    fclose(g);

    if (Display)
	CloseDisplay();

    /* Print summary of objects converted */
    printf ("\nConverted %d object(s), ", ObjCount);
    printf ("%d light source(s).\n\n", LightOn[0] + LightOn[1] + LightOn[2]);

    printf ("  Object    Verticies   Triangles   Degen Tri \n");
    printf ("---------- ----------- ----------- -----------\n");

    TotalVert = 0;
    TotalTri = 0;
    TotalDegen = 0;

    for (i = 0; i < ObjCount; i++) {
	printf (" %-8s     %6d      %6d      %6d\n",
		Names[i], Verticies[i], Triangles[i], Degens[i]);
	TotalVert += Verticies[i];
	TotalTri += Triangles[i];
	TotalDegen += Degens[i];
    }

    printf ("           =========== =========== ===========\n");
    printf (" Total        %6d      %6d      %6d\n", TotalVert, TotalTri, TotalDegen);

    return 0;
}


void ProcessArgs (int argc, char *argv[])
{
    int i;

    printf ("         3D2 to DKB Data File Converter %s\n", Ver);
    printf ("             Copyright 1991 Steve Anger\n\n");

    if (argc < 2) {
	printf ("Usage: 3d2-dkb inputfile [outputfile] [[-/]options]\n\n");
	printf ("Options: -d     - Preview object on screen.\n");
	printf ("         -lxnnn - Set LOOK_AT x coord to nnn\n");
	printf ("         -lynnn -  '     '    y   '   '   ' \n");
	printf ("         -lznnn -  '     '    z   '   '   ' \n");
	printf ("         -vxnnn - Set VIEW_POINT x coord to nnn\n");
	printf ("         -vynnn -  '       '     y   '   '   ' \n");
	printf ("         -vznnn -  '       '     z   '   '   ' \n");
	printf ("         -snnn  - Smooth triangle boundaries with angles < nnn\n");
	exit(1);
    }

    InFile[0] = '\0';
    OutFile[0] = '\0';
    Display = false;

    VectInit (&LookAt, 0.0, 0.0, 0.0);
    VectInit (&ViewPoint, 50.0, 50.0, -50.0);

    Smooth = 0.0;

    for (i = 1; i < argc; i++) {
	if (argv[i][0] == '-' || argv[i][0] == '/') {
	    switch (argv[i][1]) {
		case 'd': Display = true;
			  break;

		case 's': sscanf (&argv[i][2], "%f", &Smooth);
			  break;

		case 'l': switch (argv[i][2]) {
			    case 'x': sscanf (&argv[i][3], "%f", &LookAt.x);
				      break;
			    case 'y': sscanf (&argv[i][3], "%f", &LookAt.y);
				      break;
			    case 'z': sscanf (&argv[i][3], "%f", &LookAt.z);
			  }
			  break;

		case 'v': switch (argv[i][2]) {
			    case 'x': sscanf (&argv[i][3], "%f", &ViewPoint.x);
				      break;
			    case 'y': sscanf (&argv[i][3], "%f", &ViewPoint.y);
				      break;
			    case 'z': sscanf (&argv[i][3], "%f", &ViewPoint.z);
			  }
	    }
	}
	else if (InFile[0] == '\0') {
	    strcpy (InFile, argv[i]);
	    AddExt (InFile, "3D2", false);
	}
	else if (OutFile[0] == '\0') {
	    strcpy (OutFile, argv[i]);
	    AddExt (OutFile, "DAT", false);
	}
	else
	    Abort ("Too many file names.", 1);
    }

    /* Prevent a division by zero error later on */
    if ((ViewPoint.x - LookAt.x) == 0.0 && (ViewPoint.z - LookAt.z) == 0.0)
	ViewPoint.z -= 0.01;

    if (OutFile[0] == '\0') {
	strcpy (OutFile, InFile);
	AddExt (OutFile, "DAT", true);
    }

    f = fopen (InFile, "rb");
    if (f == NULL)
	Abort ("Error opening input file.", 2);

    g = fopen (OutFile, "w");
    if (g == NULL)
	Abort ("Error opening output file.", 2);
}


void AddExt (char *FileName, char *Ext, boolean Force)
{
    int i;

    for (i = 0; i < strlen(FileName); i++)
	if (FileName[i] == '.') break;

    if (FileName[i] == '\0' || Force) {
	FileName[i] = '.';
	strcpy (&FileName[i+1], Ext);
    }
}


byte ReadByte(FILE *f)
{
    return fgetc(f);
}


word ReadWord(FILE *f)
{
    byte bh, bl;

    bh = fgetc(f);  /* Read a Motorola format word */
    bl = fgetc(f);

    return (256*bh + bl);
}


void Abort (char *Msg, int ExitCode)
{
    if (Display)
	CloseDisplay();

    puts (Msg);
    exit (ExitCode);
}


void PrintVector (FILE *g, Vector *V)
{
    fprintf (g, "<%.2f %.2f %.2f> ", V->x, V->y, V->z);
}


void MinVector (Vector *V1, Vector *V2)
{
    V1->x = (V1->x < V2->x) ? V1->x : V2->x;
    V1->y = (V1->y < V2->y) ? V1->y : V2->y;
    V1->z = (V1->z < V2->z) ? V1->z : V2->z;
}


void MaxVector (Vector *V1, Vector *V2)
{
    V1->x = (V1->x > V2->x) ? V1->x : V2->x;
    V1->y = (V1->y > V2->y) ? V1->y : V2->y;
    V1->z = (V1->z > V2->z) ? V1->z : V2->z;
}


int Degenerate (Triangle *Tri)
{
    Vector a, b, c;
    Vector ab, bc, Temp;

    VectCopy (&a, &Vert[Tri->VertA]);
    VectCopy (&b, &Vert[Tri->VertB]);
    VectCopy (&c, &Vert[Tri->VertC]);

    VectSub (&ab, &a, &b);
    VectSub (&bc, &b, &c);
    CrossProd (&Temp, &ab, &bc);

    return (VectMag(&Temp) == 0.0);
}


void Read3D2Header()
{
    int i;
    word Temp;

    if (ReadWord(f) != 0x3D02)
	Abort ("Input file is not 3D2 format.", 3);

    ObjCount = ReadWord(f);

    LightOn[0] = ReadWord(f);
    LightOn[1] = ReadWord(f);
    LightOn[2] = ReadWord(f);

    LightBright[0] = ReadWord(f)/7.0;
    LightBright[1] = ReadWord(f)/7.0;
    LightBright[2] = ReadWord(f)/7.0;

    Ambient = ReadWord(f)/7.0;

    LightPos[0].y = (float)ReadWord(f);
    LightPos[1].y = (float)ReadWord(f);
    LightPos[2].y = (float)ReadWord(f);

    LightPos[0].z = (float)ReadWord(f);
    LightPos[1].z = (float)ReadWord(f);
    LightPos[2].z = (float)ReadWord(f);

    LightPos[0].x = (float)ReadWord(f);
    LightPos[1].x = (float)ReadWord(f);
    LightPos[2].x = (float)ReadWord(f);

    for (i = 0; i < 16; i++) {
	Temp = ReadWord(f);
	Pal[i].Red   = ((Temp & 0x0700) >> 8)/7.0;
	Pal[i].Green = ((Temp & 0x0070) >> 4)/7.0;
	Pal[i].Blue  = (Temp & 0x0007)/7.0;
    }

    for (i = 0; i < 16; i++)
	GBase[i] = ReadWord(f);

    PalType = ReadWord(f);
    WColour = ReadWord(f);
    OColour = ReadWord(f);

    for (i = 0; i < 150; i++)
	ReadByte(f);
}


void Read3D2Object()
{
    int i;

    for (i = 0; i < 9; i++)
	ObjName[i] = ReadByte(f);

    VertCount = ReadWord(f);

    Vert = malloc (VertCount * sizeof(*Vert));
    if (Vert == NULL)
	Abort ("Insufficient memory for verticies.", 4);

    for (i = 0; i < VertCount; i++) {
	Vert[i].x = ReadWord(f)/100.0;
	Vert[i].z = ReadWord(f)/100.0;
	Vert[i].y = ReadWord(f)/100.0;
    }

    TriCount = ReadWord(f);

    Tri = malloc (TriCount * sizeof(*Tri));
    if (Tri == NULL)
	Abort ("Insufficient memory for triangles.", 4);

    for (i = 0; i < TriCount; i++) {
	Tri[i].VertA    = ReadWord(f);
	Tri[i].VertB    = ReadWord(f);
	Tri[i].VertC    = ReadWord(f);
	Tri[i].EdgeFlag = ReadByte(f);
	Tri[i].Colour   = ReadByte(f);
    }
}


void WriteDKBHeader()
{
    fprintf (g, "{ Converted from file %s with 3D2-DKB %s }\n\n", InFile, Ver);
    fprintf (g, "DECLARE DefaultTexture = TEXTURE\n");
    fprintf (g, "    AMBIENT %.3f\n", Ambient);
    fprintf (g, "    DIFFUSE 0.7\n");
    fprintf (g, "END_TEXTURE\n\n");
    fprintf (g, "COMPOSITE\n");
}


void BuildTriIndex()
{
    int Vert, i;
    TriangleNode *Temp;

    /* Build a table containing a list of the triangles that use */
    /* each vertex (ie. TriList[n] = List of triangles touching vertex n) */
    TriList = malloc (VertCount * sizeof(TriList));
    if (TriList == NULL)
	Abort ("Insufficient memory for smooth triangles.", 4);

    for (i = 0; i < VertCount; i++)
	TriList[i] = NULL;

    for (i = 0; i < TriCount; i++) {
	Vert = Tri[i].VertA;
	Temp = TriList[Vert];
	TriList[Vert] = malloc (sizeof (*TriList));
	if (TriList[Vert] == NULL)
	    Abort ("Insufficient memory for smooth triangles.", 4);
	TriList[Vert]->TriNo = i;
	TriList[Vert]->Next = Temp;

	Vert = Tri[i].VertB;
	Temp = TriList[Vert];
	TriList[Vert] = malloc (sizeof (*TriList));
	if (TriList[Vert] == NULL)
	    Abort ("Insufficient memory for smooth triangles.", 4);
	TriList[Vert]->TriNo = i;
	TriList[Vert]->Next = Temp;

	Vert = Tri[i].VertC;
	Temp = TriList[Vert];
	TriList[Vert] = malloc (sizeof (*TriList));
	if (TriList[Vert] == NULL)
	    Abort ("Insufficient memory for smooth triangles.", 4);
	TriList[Vert]->TriNo = i;
	TriList[Vert]->Next = Temp;
    }
}


void DumpTriIndex()
{
    int i;

    for (i = 0; i < VertCount; i++)
	free (TriList[i]);

    free (TriList);
}


void VertNormal (Triangle *T, Vector *NormA, Vector *NormB, Vector *NormC)
{
    TriangleNode  *p;
    Vector  Normal, CurrNorm;

    VectInit (NormA, 0.0, 0.0, 0.0);
    VectInit (NormB, 0.0, 0.0, 0.0);
    VectInit (NormC, 0.0, 0.0, 0.0);

    TriNormal (T, &CurrNorm);

    for (p = TriList[T->VertA]; p != NULL; p = p->Next) {
	TriNormal (&Tri[p->TriNo], &Normal);
	if (VectAngle (&CurrNorm, &Normal) < Smooth)
	    VectAdd (NormA, NormA, &Normal);
    }

    for (p = TriList[T->VertB]; p != NULL; p = p->Next) {
	TriNormal (&Tri[p->TriNo], &Normal);
	if (VectAngle (&CurrNorm, &Normal) < Smooth)
	    VectAdd (NormB, NormB, &Normal);
    }

    for (p = TriList[T->VertC]; p != NULL; p = p->Next) {
	TriNormal (&Tri[p->TriNo], &Normal);
	if (VectAngle (&CurrNorm, &Normal) < Smooth)
	    VectAdd (NormC, NormC, &Normal);
    }

    VectScale (NormA, 1.0/VectMag (NormA));
    VectScale (NormB, 1.0/VectMag (NormB));
    VectScale (NormC, 1.0/VectMag (NormC));
}


void TriNormal (Triangle *T, Vector *Normal)
{
    Vector AB, AC;
    float Mag;

    VectSub (&AB, &Vert[T->VertB], &Vert[T->VertA]);
    VectSub (&AC, &Vert[T->VertC], &Vert[T->VertA]);
    CrossProd (Normal, &AC, &AB);

    Mag = VectMag (Normal);
    if (Mag > 0.0)
	VectScale (Normal, 1.0/Mag);
    else
	VectInit (Normal, 0.0, 0.0, 0.0);
}


void WriteDKBObject()
{
    int i, j;
    boolean Start;
    Vector NormA, NormB, NormC;

    if (Smooth > 0.0)
	BuildTriIndex();

    DegenTri = 0;

    for (i = 0; i < 16; i++) {
	Start = false;
	VectInit (&ObjMin, +1e8, +1e8, +1e8);
	VectInit (&ObjMax, -1e8, -1e8, -1e8);

	for (j = 0; j < TriCount; j++) {
	    if (Tri[j].Colour == i) {
		if (!Start) {
		    Start = true;
		    fprintf (g, "    OBJECT {%s, Pal #%d}\n", ObjName, i);
		    fprintf (g, "        UNION\n");
		}

		if (Degenerate (&Tri[j]))
		    ++DegenTri;  /* Exclude degenerate triangles */
		else {
		    if (Smooth > 0.0) {
			/* Compute vertex normals for smooth triangle */
			VertNormal (&Tri[j], &NormA, &NormB, &NormC);

			fprintf (g, "            SMOOTH_TRIANGLE ");
			PrintVector (g, &Vert[Tri[j].VertA]);
			PrintVector (g, &NormA);
			PrintVector (g, &Vert[Tri[j].VertB]);
			PrintVector (g, &NormB);
			PrintVector (g, &Vert[Tri[j].VertC]);
			PrintVector (g, &NormC);
			fprintf (g, "END_TRIANGLE\n");
		    }
		    else {
			fprintf (g, "            TRIANGLE ");
			PrintVector (g, &Vert[Tri[j].VertA]);
			PrintVector (g, &Vert[Tri[j].VertB]);
			PrintVector (g, &Vert[Tri[j].VertC]);
			fprintf (g, "END_TRIANGLE\n");
		    }

		    MinVector (&ObjMin, &Vert[Tri[j].VertA]);
		    MinVector (&ObjMin, &Vert[Tri[j].VertB]);
		    MinVector (&ObjMin, &Vert[Tri[j].VertC]);

		    MaxVector (&ObjMax, &Vert[Tri[j].VertA]);
		    MaxVector (&ObjMax, &Vert[Tri[j].VertB]);
		    MaxVector (&ObjMax, &Vert[Tri[j].VertC]);

		    if (Display)
			PlotTriangle (&Tri[j]);
		}
	    }
	}

	if (Start) {
	    fprintf (g, "        END_UNION\n\n");

	    fprintf (g, "        BOUNDED_BY\n");
	    fprintf (g, "            INTERSECTION\n");
	    fprintf (g, "                PLANE <+1.0 0.0 0.0> %.2f END_PLANE\n", +ObjMax.x);
	    fprintf (g, "                PLANE <-1.0 0.0 0.0> %.2f END_PLANE\n", -ObjMin.x);
	    fprintf (g, "                PLANE <0.0 +1.0 0.0> %.2f END_PLANE\n", +ObjMax.y);
	    fprintf (g, "                PLANE <0.0 -1.0 0.0> %.2f END_PLANE\n", -ObjMin.y);
	    fprintf (g, "                PLANE <0.0 0.0 +1.0> %.2f END_PLANE\n", +ObjMax.z);
	    fprintf (g, "                PLANE <0.0 0.0 -1.0> %.2f END_PLANE\n", -ObjMin.z);
	    fprintf (g, "            END_INTERSECTION\n");
	    fprintf (g, "        END_BOUND\n\n");

	    fprintf (g, "        TEXTURE\n");
	    fprintf (g, "            DefaultTexture\n");
	    fprintf (g, "            COLOUR RED %.3f GREEN %.3f BLUE %.3f\n",
				     Pal[i].Red, Pal[i].Green, Pal[i].Blue);
	    fprintf (g, "        END_TEXTURE\n");
	    fprintf (g, "        COLOUR RED %.3f GREEN %.3f BLUE %.3f\n",
				 Pal[i].Red, Pal[i].Green, Pal[i].Blue);

	    fprintf (g, "    END_OBJECT {%s, Pal #%d}\n\n", ObjName, i);
	}
    }

    if (Smooth > 0.0)
	DumpTriIndex();

    free (Vert);    /* Free memory used by vertex/triangle lists */
    free (Tri);
}


void WriteDKBSummary()
{
    Vector Sky, Right, Direction;
    int i;

    fprintf (g, "END_COMPOSITE\n\n");

    for (i = 0; i < 3; i++) {
	if (LightOn[i]) {
	    fprintf (g, "OBJECT\n");
	    fprintf (g, "    SPHERE <0.0 0.0 0.0> 1.0 END_SPHERE\n");
	    fprintf (g, "    TRANSLATE <%.2f %.2f %.2f>\n", LightPos[i].x, LightPos[i].y, LightPos[i].z);
	    fprintf (g, "    TEXTURE\n");
	    fprintf (g, "        COLOUR RED %.3f GREEN %.3f BLUE %.3f\n",
			     LightBright[i], LightBright[i], LightBright[i]);
	    fprintf (g, "        DIFFUSE 0.0\n");
	    fprintf (g, "        AMBIENT 1.0\n");
	    fprintf (g, "    END_TEXTURE\n");
	    fprintf (g, "    LIGHT_SOURCE\n");
	    fprintf (g, "    COLOUR RED %.3f GREEN %.3f BLUE %.3f\n",
			     LightBright[i], LightBright[i], LightBright[i]);
	    fprintf (g, "END_OBJECT\n\n");
	}
    }

    VectInit (&Sky, 0.0, 1.0, 0.0);
    VectSub (&Direction, &LookAt, &ViewPoint);
    CrossProd (&Right, &Sky, &Direction);
    VectScale (&Right, 1.33333/VectMag(&Right));

    fprintf (g, "VIEW_POINT\n");
    fprintf (g, "    LOCATION "); PrintVector (g, &ViewPoint); fprintf (g, "\n");
    fprintf (g, "    LOOK_AT "); PrintVector (g, &LookAt); fprintf (g, "\n");
    fprintf (g, "    SKY "); PrintVector (g, &Sky); fprintf (g, "\n");
    fprintf (g, "    RIGHT "); PrintVector (g, &Right); fprintf (g, "\n");
    fprintf (g, "END_VIEW_POINT\n\n");
}



void VectAdd (Vector *V1, Vector *V2, Vector *V3)
{
    V1->x = V2->x + V3->x;
    V1->y = V2->y + V3->y;
    V1->z = V2->z + V3->z;
}


void VectSub (Vector *V1, Vector *V2, Vector *V3)
{
    V1->x = V2->x - V3->x;
    V1->y = V2->y - V3->y;
    V1->z = V2->z - V3->z;
}


void VectScale (Vector *V, float k)
{
    V->x = k*V->x;
    V->y = k*V->y;
    V->z = k*V->z;
}


float VectMag (Vector *V)
{
    return sqrt((V->x * V->x) + (V->y * V->y) + (V->z * V->z));
}


float DotProd (Vector *V1, Vector *V2)
{
    return (V1->x*V2->x + V1->y*V2->y + V1->z*V2->z);
}


void CrossProd (Vector *V1, Vector *V2, Vector *V3)
{
    V1->x = (V2->y * V3->z) - (V2->z * V3->y);
    V1->y = (V2->z * V3->x) - (V2->x * V3->z);
    V1->z = (V2->x * V3->y) - (V2->y * V3->x);
}


void VectCopy (Vector *V1, Vector *V2)
{
    V1->x = V2->x;
    V1->y = V2->y;
    V1->z = V2->z;
}


void VectInit (Vector *V, float x, float y, float z)
{
    V->x = x;
    V->y = y;
    V->z = z;
}


float VectAngle (Vector *V1, Vector *V2)
{
    float Mag1, Mag2, Angle;

    Mag1 = VectMag(V1);
    Mag2 = VectMag(V2);

    if (Mag1 > 0.0 && Mag2 > 0.0)
	Angle = (180.0/M_PI) * acos(min(1.0, DotProd(V1,V2)/(Mag1 * Mag2)));
    else
	Angle = 0.0;


    return Angle;
}


void InitDisplay()
{
#ifdef __TURBOC__
    int graphdriver = DETECT, graphmode;

    Vector Temp;

    VectSub (&Nz, &LookAt, &ViewPoint);
    VectScale (&Nz, 1.0/VectMag(&Nz));

    VectCopy (&Temp, &Nz);
    VectScale (&Temp, Nz.y/DotProd(&Nz, &Nz));
    VectInit (&Ny, 0.0, 1.0, 0.0);
    VectSub (&Ny, &Ny, &Temp);
    VectScale (&Ny, 1.0/VectMag(&Ny));

    CrossProd (&Nx, &Ny, &Nz);

    if (Display) {
	initgraph (&graphdriver, &graphmode, "");
	if (graphresult() != grOk) {
	    printf ("Error initializing graphics display.\n");
	    Display = false;
	}
    }
#endif
}


void PlotTriangle (Triangle *Tr)
{
#ifdef __TURBOC__
    Vector a, b, c, T;
    int ax, ay, bx, by, cx, cy, Shade;
    float rd, gr, bl;

    VectCopy (&a, &Vert[Tr->VertA]);
    VectCopy (&b, &Vert[Tr->VertB]);
    VectCopy (&c, &Vert[Tr->VertC]);

    VectSub (&a, &a, &ViewPoint);
    T.x = DotProd (&a, &Nx);
    T.y = DotProd (&a, &Ny);
    T.z = DotProd (&a, &Nz);
    VectCopy (&a, &T);

    VectSub (&b, &b, &ViewPoint);
    T.x = DotProd (&b, &Nx);
    T.y = DotProd (&b, &Ny);
    T.z = DotProd (&b, &Nz);
    VectCopy (&b, &T);

    VectSub (&c, &c, &ViewPoint);
    T.x = DotProd (&c, &Nx);
    T.y = DotProd (&c, &Ny);
    T.z = DotProd (&c, &Nz);
    VectCopy (&c, &T);

    /* Don't plot anything that's behind you */
    if (a.z <= 0.0 || b.z <= 0.0 || c.z <= 0.0)
	return;

    ax = (0.75*a.x/a.z + 0.5)*getmaxx();
    bx = (0.75*b.x/b.z + 0.5)*getmaxx();
    cx = (0.75*c.x/c.z + 0.5)*getmaxx();
    ay = (0.5 - a.y/a.z)*getmaxy();
    by = (0.5 - b.y/b.z)*getmaxy();
    cy = (0.5 - c.y/c.z)*getmaxy();

    Shade = 0;
    bl = Pal[Tr->Colour].Blue;
    gr = Pal[Tr->Colour].Green;
    rd = Pal[Tr->Colour].Red;
    Shade = 1*(bl > 0.3) + 2*(gr > 0.3) + 4*(rd > 0.3) + 8*(bl+gr+rd > 1.5);

    if (Shade == 0)
	Shade = 8;

    setcolor (Shade);

    moveto (ax, ay);
    lineto (bx, by);
    lineto (cx, cy);
    lineto (ax, ay);
#endif
}


void CloseDisplay()
{
#ifdef __TURBOC__
    printf ("Conversion complete.\nPress any key.");
    getch();
    closegraph();
#endif
}
