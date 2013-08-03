/*
 * BDY READER BY NO/ESCAPE
 *
 * This is a routine to read information about a bdy 3D object.
 * Its arguments are:
 * - a pointer the the bdy data
 * - a destination buffers structure
 * The calling program has to provide a buffer for the
 * output of this program. The advantage is that this program
 * has no global variables (no bss segment) which makes it
 * easier to include it into other programs.
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <tos.h>

/*** FILE FORMAT DESCRIPTION OF BDY FILES ***/

#define ushort unsigned short
#define uchar  unsigned char

struct bdy_header {
	char	format_ident[10];	/* format identifier "RIP OBJ.:\O" */
	char	version;			/* must be 6 */
	char	reserved;
	ushort 	byteorder;			/* 0x0100 -> intel format */
	ushort 	num_of_points;
	ushort	num_of_polys;
	ushort	num_of_materials;
	ushort	num_of_morphs;
	ushort	curr_morph_phase;
};

struct bdy_point {
	uchar	sel;
	uchar	reserved;
	float	x;
	float	y;
	float	z;
};

struct bdy_poly {
	uchar 	num_of_points;
	uchar 	status;				/* 0:FrontVis, 1:Backvis, 2:Flat */
	uchar	sel;				/* 0:Selected, 1:reserved, 2:Hide */
	uchar	reserved1;
	ushort	body;				/* sub-body number */
	int		material;			/* index of material */
	long	reserved2;	
	ushort	points[8];			/* point indices of the polygon */	
};

/*** DESTINATION STRUCTURE ***/

struct objhead_struct {
	long num_of_points;
	long *x_buf;
	long *y_buf;
	long *z_buf;
	long *nx_buf;
	long *ny_buf;
	long *nz_buf;
	long num_of_polys;
	long *polygons;
};


/*** FUNCTION PARSES BDY DATA AND RETURNS EASIER STRUCTURED DATA ***/
void parse_bdy_data(void *bdy_buf,struct objhead_struct *dst) {
	struct bdy_header 	*header = bdy_buf;
	struct bdy_point  	*point,*pointdata;
	struct bdy_poly		*poly,*polydata;
	long i,j;
	double nx,ny,nz,nv;
	long p1,p2,p3;
	double ax,ay,az,bx,by,bz;
	long num_of_points;
	long num_of_polys;
	long *x_buf,*y_buf,*z_buf;
	long *nx_buf,*ny_buf,*nz_buf;
/*	long *polycount;*/
	
	num_of_points = header->num_of_points;
	
	/* init destination buffer adresses */
	x_buf  = (long *)((long)dst + sizeof(struct objhead_struct));
	y_buf  =  x_buf + num_of_points;
	z_buf  =  y_buf + num_of_points;
	nx_buf =  z_buf + num_of_points;
	ny_buf = nx_buf + num_of_points;
	nz_buf = ny_buf + num_of_points;
/*	polycount = nz_buf + num_of_points;*/
	
	/* convert 3d floating point data to 32bit 3d fixpoint data */	
	point = (struct bdy_point *)((long)header + sizeof(struct bdy_header));
	pointdata=point;
	for (i=0;i<num_of_points;i++) {
		*(x_buf+i)=(long)(point->x*65536);
		*(y_buf+i)=(long)(point->y*65536);
		*(z_buf+i)=(long)(point->z*65536);
		point++;
	}

	/* calculate normal vectors */	
	poly = (struct bdy_poly *)point;
	polydata=poly;
	num_of_polys=header->num_of_polys;
	for (i=0;i<num_of_polys;i++) {		
	
		/* calculate normal vector of polygon */
		p1=poly->points[0];
		p2=poly->points[1];
		p3=poly->points[2];
		ax=(pointdata+p2)->x - (pointdata+p1)->x;
		ay=(pointdata+p2)->y - (pointdata+p1)->y;
		az=(pointdata+p2)->z - (pointdata+p1)->z;
		bx=(pointdata+p3)->x - (pointdata+p1)->x;
		by=(pointdata+p3)->y - (pointdata+p1)->y;
		bz=(pointdata+p3)->z - (pointdata+p1)->z;
		nx=ay*bz - az*by;
		ny=az*bx - ax*bz;
		nz=ax*by - ay*bx;
		nv=sqrt(nx*nx + ny*ny + nz*nz);
		
		/* accumulate normal vectors of the poly points */
		for (j=0;j<poly->num_of_points;j++) {
			if (nv>0) {
				*(nx_buf+poly->points[j])+=(long)((256*nx)/nv);
				*(ny_buf+poly->points[j])+=(long)((256*ny)/nv);
				*(nz_buf+poly->points[j])+=(long)((256*nz)/nv);
/*
				*(nx_buf+poly->points[j])+=(long)(256*nx);
				*(ny_buf+poly->points[j])+=(long)(256*ny);
				*(nz_buf+poly->points[j])+=(long)(256*nz);
				*/
			}
			/*(*(polycount+poly->points[j]))++;*/
		}
		poly++;
	}
	
	/* normalize normals */
	for (i=0;i<num_of_points;i++) {
		nx=*(nx_buf+i);
		ny=*(ny_buf+i);
		nz=*(nz_buf+i);
		nv=sqrt(nx*nx + ny*ny + nz*nz);
		
		*(nx_buf+i)=(long)(256.0*nx/nv);
		*(ny_buf+i)=(long)(256.0*ny/nv);
		*(nz_buf+i)=(long)(256.0*nz/nv);
		
		/*
		if (*(polycount+i)) {
			*(nx_buf+i)=(*(nx_buf+i))/(*(polycount+i));
			*(ny_buf+i)=(*(ny_buf+i))/(*(polycount+i));
			*(nz_buf+i)=(*(nz_buf+i))/(*(polycount+i));
		}
		*/
		
	}
	
	/* fill header of destination buffer */
	dst->num_of_points=num_of_points;
	dst->x_buf=x_buf;
	dst->y_buf=y_buf;
	dst->z_buf=z_buf;
	dst->nx_buf=nx_buf;
	dst->ny_buf=ny_buf;
	dst->nz_buf=nz_buf;
	dst->num_of_polys=num_of_polys;
	dst->polygons=(long *)polydata;
}


/* PRINT OUT HEADER INFORMATION ABOUT THE BDY FILE */
void print_header_info(struct bdy_header *header) {
	printf("BDY FILE INFORMATION:\n");
	printf("format_ident:     ");
	printf((char *)&header->format_ident);
	printf("\n");

	printf("version:          %u\n",(unsigned int)header->version);
	printf("byteorder:        %u\n",header->byteorder);
	printf("num_of_points:    %u\n",header->num_of_points);
	printf("num_of_polys:     %u\n",header->num_of_polys);
	printf("num_of_morphs:    %u\n",header->num_of_morphs);
	printf("curr_morph_phase: %u\n",header->curr_morph_phase);

}


long bdy_buffer[100000];
long dst_buffer[100000];

int main (int argc, char **argv) {
	long fh;
	long i;
	struct objhead_struct *dst_adr=(struct objhead_struct *)&dst_buffer;
	
	if (argc<3) {
		printf("Usage: bdyconv.ttp <source.bdy> <dest.e3d>\n");
		Cconin();
		return 0;
	}
	printf("loading %s...\n",*(argv+1));
	
	fh=Fopen(*(argv+1),FO_READ);
	if (fh<0) return 0;
	
	Fread(fh,153600,&bdy_buffer);
	Fclose(fh);

	print_header_info((struct bdy_header *)&bdy_buffer);
	parse_bdy_data(&bdy_buffer,dst_adr);

	printf("saving %s...",*(argv+2));
	
	fh=Fcreate(*(argv+2),0);
	if (fh<0) return 0;
	Fwrite(fh,4,&dst_adr->num_of_points);
	Fwrite(fh,dst_adr->num_of_points*4,dst_adr->x_buf);
	Fwrite(fh,dst_adr->num_of_points*4,dst_adr->y_buf);
	Fwrite(fh,dst_adr->num_of_points*4,dst_adr->z_buf);
	Fwrite(fh,dst_adr->num_of_points*4,dst_adr->nx_buf);
	Fwrite(fh,dst_adr->num_of_points*4,dst_adr->ny_buf);
	Fwrite(fh,dst_adr->num_of_points*4,dst_adr->nz_buf);
	Fwrite(fh,4,&dst_adr->num_of_polys);
	Fwrite(fh,sizeof(struct bdy_poly)*dst_adr->num_of_polys,dst_adr->polygons);
	Fclose(fh);
	printf("done.\n");

	return 0;
}
