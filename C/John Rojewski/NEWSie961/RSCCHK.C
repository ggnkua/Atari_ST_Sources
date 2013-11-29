/*
 * rscchk.c - compare resources for NEWSie
 *
 * Written: 02/04/97		John Rojewski
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include <dos.h>
#include <aes.h>
#include <vdi.h>

/* global variables */
OBJECT *menu_ptr;
short screenx,screeny,screenw,screenh;
int finished=0;
int handle;
RSHDR rsh;
char program_path[FMSIZE];
char resource[FMSIZE]="D:\\LC\\STIKCOVL\\NEWSIE.RSC";

struct x {
	char rsc_name[FMSIZE];
	int ntree;
	int nobs;
	int	objs[200];			/* support up to 200 trees */
} rsc[8];					/* up to 8 resource files */
int num=-1;					/* number of resources loaded */


void show_rsc(char *filename)
{
	FILE *fid;

	graf_mouse( M_OFF, NULL );
	if ((fid=fopen( filename, "rb"))!=NULL) {
		fread( &rsh, 1, sizeof(rsh), fid);
		fclose( fid );
		printf( "Resource file     %s\n", filename );
		printf( "Version           %u\n", rsh.rsh_vrsn );
		printf( "Number of trees   %u\n", rsh.rsh_ntree );
		printf( "Number of objects %u\n", rsh.rsh_nobs );
	}
	graf_mouse( M_ON, NULL );
}

int dummy( OBJECT *tree, int cur )
{
	static int count=0;
	int tmp;

	if( tree==NULL) { tmp=count; count=0; return(tmp); }
	count++;
	return(1);
}

void initialize(void)
{
	int c,d;

	if (appl_init()<0)
		exit(EXIT_FAILURE);
	getcd( 0, program_path );
	for (c=0;c<8;c++) {
		for (d=0;d<200;d++) { rsc[c].objs[d]=0; }
	}
	wind_get(DESK,WF_WORKXYWH,&screenx,&screeny,&screenw,&screenh);
	graf_mouse(ARROW,NULL);
}

void check_resource(char *filename)
{
	OBJECT *tree;
	int c,o;

	if (!rsrc_load( filename ))
	{
		form_alert(1,"[1][Resource file error][ Quit ]");
		return;
	}
/*	rsrc_gaddr(R_TREE,Menu1,&menu_ptr); */
/*	menu_bar(menu_ptr,1); */

	graf_mouse( M_OFF, NULL );
	show_rsc( filename );
	for (c=0;c<rsh.rsh_ntree;c++) {
		if (rsrc_gaddr(R_TREE,c,&tree)) {
			printf( "Walking tree    %d, ", c );
			objc_walk( tree, ROOT, NIL, 0, dummy );
		}
		o=dummy( NULL, 0 );
		printf( "Contains %d objects\n", o );
	}
	rsrc_free();
	graf_mouse( M_ON, NULL );
}

void store_resource(char *filename)
{
	OBJECT *tree;
	int c;

	if (!rsrc_load( filename ))
	{
		form_alert(1,"[1][Resource file error][ Quit ]");
		return;
	}
	num++;
	show_rsc( filename );
	strcpy( rsc[num].rsc_name, filename );
	rsc[num].nobs =rsh.rsh_nobs;
	rsc[num].ntree=rsh.rsh_ntree;
	for (c=0;c<rsh.rsh_ntree;c++) {
		if (rsrc_gaddr(R_TREE,c,&tree)) {
			objc_walk( tree, ROOT, NIL, 0, dummy );
		}
		rsc[num].objs[c]=dummy( NULL, 0 );
	}
	rsrc_free();
}

void deinitialize(void)
{
/*	menu_bar(menu_ptr,0); */
	appl_exit();
}

int get_resource(void)
{
	char path[FMSIZE],dirname[FMSIZE],select[FNSIZE];
	int button;

	strcpy( select, "*.RSC" );
	sprintf( dirname, "%s\\%s", program_path, select );
	fsel_exinput( dirname, select, &button, "Compare Resource?" );
	if (button) {
		stcgfp( path, dirname );
		sprintf( resource, "%s\\%s", path, select );
		return(1);
	/*	fprintf( log, "dir %s, sel %s, filename %s\n", path, select, dirname ); */
	} else { return(0); }
}

void compare_resources()
{
	int c,d,same=0;

	if (num<0) {form_alert(1,"[1][No Resources Loaded][ Done ]"); return; }
	if (num==0) {form_alert(1,"[1][Only 1 Resource Loaded][ Done ]"); return; }

	for (c=0;c<num;c++) { same += ((rsc[c].ntree==rsc[c+1].ntree)&&(rsc[c].nobs==rsc[c+1].nobs)); }
	if (same==num)  {form_alert(1,"[1][Resources are Identical][ Done ]"); return; }

	graf_mouse( M_OFF, NULL );
	for (c=0;c<num+1;c++) { printf( "%5d ", rsc[c].ntree); } printf("\n");
	for (c=0;c<num+1;c++) { printf( "%5d ", rsc[c].nobs); } printf("\n");
	for (d=0;d<rsc[0].ntree;d++) {
		printf( "Tree %3d: ", d );	
		for (c=0;c<num+1;c++) { printf( "%5d ", rsc[c].objs[d]); } printf("\n");
	}
	graf_mouse( M_ON, NULL );
}

void handle_events(void)
{
	short buff[8];
	int res, mx, my, btn, shft, keycode, clicks;
	int flags=MU_KEYBD|MU_BUTTON|MU_MESAG;

	for (; !finished;)
	{
	/*	res = evnt_multi( flags, 2, 1, 1, */
		res = evnt_multi( flags, 0x0102, 3, 0,	/* left or right mouse */
					0, 0, 0, 0, 0,
					0, 0, 0, 0, 0,
					buff, 0, 0,
					&mx, &my, &btn, &shft, &keycode, &clicks );
	/*	if (res & MU_MESAG)  { do_message_events( buff ); }
		if (res & MU_KEYBD)  { do_keyboard_events(shft, keycode); }
		if (res & MU_BUTTON) { do_mouse_events(mx, my, btn, clicks); } */
		finished=1;
	} 
}

int main(void)
{
	initialize();
	while( get_resource() )
	{
		store_resource( resource );
	/*	check_resource( resource ); */
	}
	compare_resources();
	handle_events();
	deinitialize();
	return EXIT_SUCCESS;
}
