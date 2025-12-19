/* AutoCAD DXF file to DKB Data File Converter                        */
/* Version 1.0 By Aaron A. Collins.  Written 8/13/90                  */
/* Version 1.01 Modified to work with DKB 2.10 By Drew Wells 3/20/91  */
/* This program is released to the public domain.                     */
/*--------------------------------------------------------------------*/
/* Version History                                                    */	
/*--------------------------------------------------------------------*/ 
/*  8/19/90 AC Wrote original program.
 *  3/20/91 DW Put colors inside texture block for DKB 2.10.
 *          DW Removed line INCLUDE "Basicshapes.dat".
 *	        DW Added additional comment docs at top of DKB outfile.
 *          DW Added additional stats as to what DXF types were found.
 *  4/29/91 AC Modified usage message and header semantics a bit.
 *  5/15/91 AC Removed IBM-ness of filenames/extensions
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE	2048
#define FABS(x) ((x<0.0)?-x:x)

int getline (void);
void writeobj (void);
void finishobj (int color);
void lookupcolor (int color, double *red, double *green, double *blue);
int checkdegen(int a, int b, int c);

int groupcode;
char linbuf[BUFSIZE];
FILE *infile, *outfile;
long primitives = 0L, degenerates = 0L;
long num_triangles = 0L, num_points = 0L, num_circles = 0L, num_traces = 0L,
     num_solids = 0L, num_lines = 0L, num_3dlines = 0L, num_3dfaces = 0L;
char curobj[80];
int curcolor;
double curthick;
double xcoords[10];
double ycoords[10];
double zcoords[10];
double doubles[10];
double angles[10];
int ints[10];
double max_x, max_y, max_z, min_x, min_y, min_z;


void main(argc, argv)
int argc;
char *argv[];
{
	printf("\n\nAutoCad DXF to DKB Data file Translator\n");
	printf("Version 1.0  Written By Aaron A. Collins, 8/13/90\n");
	printf("Version 1.01 Modifications  By Drew Wells 3/20/91\n");
	printf("Version 1.02 Modifications By Aaron A. Collins 3/20/91\n");
	printf("Version 1.03 Modifications By Aaron A. Collins 5/15/91\n");
	printf("* Type DXF2DKB with no arguments for more info. *\n");
	printf("This program is released to the public domain.\n\n");
	if (argc != 3)
	{
		printf("Usage:  %s InputFile OutputFile\n\n", argv[0]);
                
		printf("DXF2DKB does a minimal conversion of AutoCad DXF files into DKB data format.\n");
		printf("The following DXF primitives are currently supported:\n");
		printf("\t3D Faces\tTriangles\tPoints\n");
		printf("\t3D Lines\tCircles  \tSolids\n");
		printf("\tLines   \tTraces\n");
		printf("The DKB Raytracer is available on Compuserve's COMART forum lib 16 and\n");
		printf("The \"You Can Call Me RAY\" Raytracing BBS at (708) 358-5611.\n");
		printf("C source code for this utility is also available at those locations.\n");

		exit(1);
	}
	if ((infile = fopen(argv[1], "r"))==NULL)
	{
		printf("Cannot open input file %s!\n", argv[1]);
		exit(1);
	}

	if ((outfile = fopen(argv[2], "w"))==NULL)
	{
		printf("Cannot create output file %s!\n", argv[2]);
		fclose(infile);
		exit(1);
	}

	printf("\nPlease wait; Processing...");
	fprintf(outfile, "{ This file is for use with the DKB Ray Tracer.}\n");
	fprintf(outfile, "{ %s: Converted from AutoCad DXF File: %s }\n\n", argv[2], argv[1]);
	fprintf(outfile, "{ This is a composite object description for use with the DKB }\n");
	fprintf(outfile, "{ Ray Tracer. It does not include viewpoint or light source desc-}\n");
	fprintf(outfile, "{ riptions. It uses the Dull texture from textures.dat and it }\n");
	fprintf(outfile, "{ may use Cylinder_Z from shapes.dat. }\n");
	fprintf(outfile, "{ To use this file as an include file uncomment the DECLARE line }\n");
	fprintf(outfile, "{ and change DxfObject to an appropriate name.}\n\n");
	fprintf(outfile, "INCLUDE \"shapes.dat\"\n");
	fprintf(outfile, "INCLUDE \"colors.dat\"\n");
	fprintf(outfile, "INCLUDE \"textures.dat\"\n\n");
	fprintf(outfile, "{ DECLARE DxfObject = }\n",argv[2]);
        
	fprintf(outfile, "COMPOSITE\n");

	curobj[0] = '\0';	/* not working on any object currently */
	curcolor = 7;		/* and it also doesn't have a color yet... */
	max_x = max_y = max_z =  -10000000.0;	/* init bounding limits */
	min_x = min_y = min_z =   10000000.0;

find:	while (!feof(infile))	/* run file up to the "ENTITIES" section */
	{
		if (getline())		/* get a group code and a line */
			goto stopit;
		if (groupcode == 0)	/* file section mark */
		{
			if (strstr(linbuf, "EOF"))
				goto stopit;
			if (strstr(linbuf, "SECTION"))
			{
				if (getline())
					goto stopit;
				if (groupcode != 2)
					continue;
				if (strstr(linbuf, "ENTITIES"))
					break;
			}
		}
	}
	while (!feof(infile))		/* scan ENTITIES section */
	{
		if (getline())		/* get a group code and a line */
			break;
		if (groupcode < 10)	/* cardinal group codes */
		{
			switch(groupcode)
			{
				case 0: /* start of entity, table, file sep */
					if (strstr(linbuf, "EOF"))
					{
						writeobj(); /* dump object */
						goto stopit;
					}
					if (strstr(linbuf, "ENDSEC"))
					{
						writeobj(); /* dump object */
						goto find;
					}
					writeobj();	/* dump old object */
					curobj[0] = '\0'; /* reset object */
					curcolor = 7;
					strcpy(curobj, linbuf);	/* get new */
					break;
				case 1:	/* primary text value for entity (?)*/
					break;
				case 2: /* block name, attribute tag, etc */
				case 3:	/* other names */
				case 4:
					break;
				case 5:	/* entity handle (hex string) */
					break;
				case 6: /* line type name */
					break;
				case 7: /* text style name */
					break;
				case 8: /* layer name */
					break;
				case 9: /* variable name ID (only in header)*/
					break;
			}
		}
		else if (groupcode >= 10 && groupcode < 19) /* Some X coord */
		{
			sscanf(linbuf, "%f", &(xcoords[groupcode-10]));
			if (xcoords[groupcode-10] > max_x)
				max_x = xcoords[groupcode-10];
			if (xcoords[groupcode-10] < min_x)
				min_x = xcoords[groupcode-10];
		}
		else if (groupcode >= 20 && groupcode < 29) /* Some Y coord */
		{
			sscanf(linbuf, "%f", &(ycoords[groupcode-20]));
			if (ycoords[groupcode-20] > max_y)
				max_y = ycoords[groupcode-20];
			if (ycoords[groupcode-20] < min_y)
				min_y = ycoords[groupcode-20];
		}
		else if (groupcode >= 30 && groupcode < 38) /* Some Z coord */
		{
			sscanf(linbuf, "%f", &(zcoords[groupcode-30]));
			if (zcoords[groupcode-30] > max_z)
				max_z = zcoords[groupcode-30];
			if (zcoords[groupcode-30] < min_z)
				min_z = zcoords[groupcode-30];
		}
		else if (groupcode == 38) /* entity elevation if nonzero */
		{
		}
		else if (groupcode == 39) /* entity thickness if nonzero */
		{
		}
		else if (groupcode >= 40 && groupcode < 49) /* misc doubles */
		{
			sscanf(linbuf, "%f", &(doubles[groupcode-40]));
		}
		else if (groupcode == 49) /* repeated value groups */
		{
		}
		else if (groupcode >= 50 && groupcode < 59) /* misc angles */
		{
			sscanf(linbuf, "%f", &(angles[groupcode-50]));
		}
		else if (groupcode == 62) /* Color number */
		{
			sscanf(linbuf, "%6d", &curcolor);
		}
		else if (groupcode == 66) /* "entities follow" flag */
		{
		}
		else if (groupcode >= 70 && groupcode < 79) /* misc ints */
		{
			sscanf(linbuf, "%f", &(ints[groupcode-70]));
		}
		else if (groupcode == 210 || groupcode == 220 || groupcode == 230)
		{	/* X, Y, Z components of extrusion direction */
		}
	}
stopit: fprintf(outfile, "  BOUNDED_BY\n    INTERSECTION\n");
	fprintf(outfile, "      PLANE <1.0  0.0  0.0> %1.04f END_PLANE\n", FABS(max_x) * 1.01);
	fprintf(outfile, "      PLANE <-1.0 0.0  0.0> %1.04f END_PLANE\n", FABS(min_x) * 1.01);
	fprintf(outfile, "      PLANE <0.0  1.0  0.0> %1.04f END_PLANE\n", FABS(max_y) * 1.01);
	fprintf(outfile, "      PLANE <0.0 -1.0  0.0> %1.04f END_PLANE\n", FABS(min_y) * 1.01);
	fprintf(outfile, "      PLANE <0.0  0.0  1.0> %1.04f END_PLANE\n", FABS(max_z) * 1.01);
	fprintf(outfile, "      PLANE <0.0  0.0 -1.0> %1.04f END_PLANE\n", FABS(min_z) * 1.01);
	fprintf(outfile, "    END_INTERSECTION\n  END_BOUND\nEND_COMPOSITE\n");
	fclose(infile);
	fflush(outfile);
	fclose(outfile);
	printf("Finished.\nTotal DKB objects written to output file: %ld\n\n", primitives);
	printf("Total degenerate triangles removed from scene: %ld\n\n", degenerates);
        
	printf ("X bounding values range from %f to %f\n", min_x, max_x);
	printf ("Y bounding values range from %f to %f\n", min_y, max_y);
	printf ("Z bounding values range from %f to %f\n", min_z, max_z);
	printf("\n\t\t\t--- DXF Stats ---\n");
	printf("3D Faces = \t%ld\tTriangles = \t%ld\tPoints = \t%ld\n",num_3dfaces,num_triangles,num_points);
	printf("3D Lines = \t%ld\tCircles   = \t%ld\tSolids = \t%ld\n",num_3dlines,num_circles,num_solids);
	printf("Lines    = \t%ld\tTraces    = \t%ld\n",num_lines,num_traces);
	exit(0);
}


int getline()		/* read a group code and the next line from infile */
{
	fgets(linbuf, BUFSIZE, infile);	/* get a line from .DXF */
	if (feof(infile))
		return(1);
	sscanf(linbuf, "%3d", &groupcode);  /* scan out group code */
	fgets(linbuf, BUFSIZE, infile);	/* get a line from .DXF */
	if (feof(infile))
		return(1);
	return(0);
}

void writeobj()	/* dump out current object we should have all info on */
{
	if (strstr(curobj, "LINE"))		/* a VERY skinny triangle! */
	{
		if (xcoords[0] == xcoords[1] && ycoords[0] == ycoords[1] && zcoords[0] == zcoords[1])
		{
			degenerates++;
			return;
		}

		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    TRIANGLE <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> END_TRIANGLE\n", xcoords[0], ycoords[0], zcoords[0], xcoords[1], ycoords[1], zcoords[1], xcoords[1]+0.01, ycoords[1], zcoords[1]);
		finishobj(curcolor);
                num_lines++;
		return;
	}
	else if (strstr(curobj, "POINT"))	/* an itty, bitty sphere! */
	{
		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    SPHERE <%1.06f %1.06f %1.06f> 0.1 END_SPHERE\n", xcoords[0], ycoords[0], zcoords[0]);
		finishobj(curcolor);
                num_points++;
		return;
	}
	else if (strstr(curobj, "CIRCLE"))	/* a VERY short cylinder! */
	{
		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    INTERSECTION\n");
		fprintf(outfile, "      QUADRIC Cylinder_Z SCALE <%1.06f %1.06f %1.06f> END_QUADRIC\n", doubles[0], doubles[0], doubles[0]);
		fprintf(outfile, "      PLANE <0.0 0.0 1.0>  0.1 END_PLANE\n");
		fprintf(outfile, "      PLANE <0.0 0.0 -1.0> 0.1 END_PLANE\n");
		fprintf(outfile, "    END_INTERSECTION\n");
		fprintf(outfile, "    TRANSLATE <%1.06f %1.06f %1.06f>\n", xcoords[0], ycoords[0], zcoords[0]);
		finishobj(curcolor);
                num_circles++;
		return;
	}
	else if (strstr(curobj, "ARC"))		/* not implemented for now */
	{
		return;
	}
	else if (strstr(curobj, "TRACE"))	/* 2 back-to-back triangles */
	{
		if (checkdegen(0, 1, 2))
		{
			degenerates++;
			return;
		}

		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    TRIANGLE <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> END_TRIANGLE\n", xcoords[0], ycoords[0], zcoords[0], xcoords[1], ycoords[1], zcoords[1], xcoords[2], ycoords[2], zcoords[2]);
                num_traces++;
		finishobj(curcolor);

		if (checkdegen(0, 3, 2))
		{
			degenerates++;
			return;
		}

		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    TRIANGLE <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> END_TRIANGLE\n", xcoords[0], ycoords[0], zcoords[0], xcoords[3], ycoords[3], zcoords[3], xcoords[2], ycoords[2], zcoords[2]);
		finishobj(curcolor);

		return;
	}
	else if (strstr(curobj, "SOLID"))	/* 1 or 2 triangles */
	{
		if (checkdegen(0, 1, 2))
		{
			degenerates++;
			return;
		}

		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    TRIANGLE <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> END_TRIANGLE\n", xcoords[0], ycoords[0], zcoords[0], xcoords[1], ycoords[1], zcoords[1], xcoords[2], ycoords[2], zcoords[2]);
		finishobj(curcolor);
                num_solids++;
		if (xcoords[2] == xcoords[3] && ycoords[2] == ycoords[3] && zcoords[2] == zcoords[3])
			return;	/* one triangle was enough... */

		if (checkdegen(0, 3, 2))
		{
			degenerates++;
			return;
		}

		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    TRIANGLE <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> END_TRIANGLE\n", xcoords[0], ycoords[0], zcoords[0], xcoords[3], ycoords[3], zcoords[3], xcoords[2], ycoords[2], zcoords[2]);
		finishobj(curcolor);
		return;
	}
	else if (strstr(curobj, "TEXT"))	/* not implemented for now */
	{
		return;
	}
	else if (strstr(curobj, "SHAPE"))	/* these look very hard */
	{
		return;
	}
	else if (strstr(curobj, "BLOCK"))	/* these look very hard */
	{
		return;
	}
	else if (strstr(curobj, "ENDBLK"))	/* these look very hard */
	{
		return;
	}
	else if (strstr(curobj, "INSERT"))	/* these look very hard */
	{
		return;
	}
	else if (strstr(curobj, "ATTDEF"))	/* not implemented for now */
	{
		return;
	}
	else if (strstr(curobj, "ATTRIB"))	/* not implemented for now */
	{
		return;
	}
	else if (strstr(curobj, "POLYLINE")) /* these look fairly hard */
	{
		return;
	}
	else if (strstr(curobj, "VERTEX"))	/* these look fairly hard */
	{
		return;
	}
	else if (strstr(curobj, "SEQEND"))	/* these look fairly hard */
	{
		return;
	}
	else if (strstr(curobj, "3DLINE"))	/* a VERY skinny triangle! */
	{
		if (xcoords[0] == xcoords[1] && ycoords[0] == ycoords[1] && zcoords[0] == zcoords[1])
		{
			degenerates++;
			return;
		}

		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    TRIANGLE <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> END_TRIANGLE\n", xcoords[0], ycoords[0], zcoords[0], xcoords[1], ycoords[1], zcoords[1], xcoords[1]+0.1, ycoords[1], zcoords[1]);
		finishobj(curcolor);
                num_3dlines++;

		return;
	}
	else if (strstr(curobj, "3DFACE"))	/* 1 or 2 triangles */
	{
		if (checkdegen(0, 1, 2))
		{
			degenerates++;
			return;
		}

		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    TRIANGLE <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> END_TRIANGLE\n", xcoords[0], ycoords[0], zcoords[0], xcoords[1], ycoords[1], zcoords[1], xcoords[2], ycoords[2], zcoords[2]);
		finishobj(curcolor);
                num_3dfaces++;
		if (xcoords[2] == xcoords[3] && ycoords[2] == ycoords[3] && zcoords[2] == zcoords[3])
			return;	/* one triangle was enough... */

		if (checkdegen(0, 3, 2))
		{
			degenerates++;
			return;
		}

		fprintf(outfile, "  OBJECT\n");
		fprintf(outfile, "    TRIANGLE <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> <%1.06f %1.06f %1.06f> END_TRIANGLE\n", xcoords[0], ycoords[0], zcoords[0], xcoords[3], ycoords[3], zcoords[3], xcoords[2], ycoords[2], zcoords[2]);
		finishobj(curcolor);
		return;
	}
	else if (strstr(curobj, "DIMENSION"))	/* not implemented for now */
	{
		return;
	}
	return;	/* no current object defined... */
}

void finishobj(color)	/* conclude a DKB-style object definition */
int color;
{
	double red, green, blue;

	lookupcolor(color, &red, &green, &blue);
	fprintf(outfile, "    TEXTURE Dull\n");  /* default surf. */
	fprintf(outfile, "      COLOR RED %1.06f GREEN %1.06f BLUE %1.06f\n", red, green, blue);
	fprintf(outfile, "    END_TEXTURE\n");  /* default surf. */
	fprintf(outfile, "  END_OBJECT\n\n");
	printf(".");		/* activity echo (happy dots) */
	primitives++;		/* count another output file primitive */
}

void lookupcolor(color, red, green, blue) /* basic AutoCAD 9-color pallette */
int color;
double *red, *green, *blue;
{
	switch (color)
	{
		case 0:	/* black */
			*red = *green = *blue = 0.0;
			break;
		case 1: /* red */
			*red = 1.0;
			*blue = *green = 0.0;
			break;
		case 2: /* yellow */
			*red = *green = 1.0;
			*blue = 0.0;
			break;
		case 3:	/* green */
			*green = 1.0;
			*red = *blue = 0.0;
			break;
		case 4: /* cyan */
			*blue = *green = 1.0;
			*red = 0.0;
			break;
		case 5: /* blue */
			*blue = 1.0;
			*red = *green = 0.0;
			break;
		case 6: /* magenta */
			*blue = *red = 1.0;
			*green = 0.0;
			break;
		case 8:	/* dk. grey */
			*red = *green = *blue = 0.5;
			break;
		case 9: /* lt. grey */
			*red = *green = *blue = 0.75;
			break;
		case 7: /* white */
		default: /* make anything else white (?) */
			*red = *green = *blue = 1.0;
	}
	return;
}

int checkdegen(a, b, c)		/* check for degenerate triangle structure */
int a, b, c;
{
	if (
	(xcoords[a] == xcoords[b] &&
	 ycoords[a] == ycoords[b] &&
	 zcoords[a] == zcoords[b]) || 
	(xcoords[b] == xcoords[c] &&
	 ycoords[b] == ycoords[c] &&
	 zcoords[b] == zcoords[c]) || 
	(xcoords[a] == xcoords[c] &&
	 ycoords[a] == ycoords[c] &&
	 zcoords[a] == zcoords[c]))
		return(1);
	return(0);
}
