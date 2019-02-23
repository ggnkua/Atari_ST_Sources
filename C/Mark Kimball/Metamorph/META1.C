/***********************************/
/* CAD-3D Metamorphic Animation    */
/*        Desk Accessory           */
/*    Written by Mark Kimball      */
/* Copyright 1990 Antic Publishing */
/*                                 */
/***********************************/

#include <stdio.h>
#include <define.h>
#include <caddefs.h> /* some useful defines for CAD-3D pipeline commands */
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>

/* floating point externals for printf output, mostly. ALCYON needs 'em. */
extern int gl_apid;
extern float etoa,ftoa;
extern float atof();

/* MEM sets size of buffer used by META for objects */

#define MEM 200000
#define NULLPTR (int *) 0L

/* globals   */

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

int whand,windx,windy,windw,windh;
int handle,gr_1,gr_2,gr_3,gr_4,dum;

int menu_id,cad_id;
int mgbuf[8],mgin[8],event;
long lwork;


/* Object load/unload structure */

struct obj_str
{
char os_name[9];
int os_vertices;
int os_faces;
int *os_x;	/* these are pointers to arrays for vertex storage */
int *os_y;
int *os_z;
int *os_a;	/* these are pointers to arrays of indices to vertices */
int *os_b;
int *os_c;
int *os_color;	/* pointer to object-color information */
};
struct obj_str obstrc;	/* eventually define array of max# objects */


/* .3D2 file structure */
struct obfile
{
int id;
int numobs;
int a_state;
int b_state;
int c_state;
int a_inten;
int b_inten;
int c_inten;
int amb_inten;
int a_z;
int b_z;
int c_z;
int a_y;
int b_y;
int c_y;
int a_x;
int b_x;
int c_x;
int palette[16];  /* Hudson's docs indicate 32 WORDS but it's BYTES */
int group[16];	  /* how palette #'s are grouped */
int paltype;	/* 0 = 7 shade 1 = fourteen 2 = custom */
int wfcolor;	/* wireframe line color 1-15 */
int outline;	/* outline line color 0-15 */
int spare[75];  /* future expansion -- makes header exactly 256 bytes long */
};

struct obfile obheads[10];	/* reserve room for 10 .3D2 file-headers */

long ob_body[10];		/* array of pointers into vertex/face store */

/* the rest of the .3D2 file depends on the object itself
   but will look like this:
   name -- 9 characters including null terminator (makes filesize ODD)
   int: number of vertices in object
   x,y,z coordinates of vertices
   int: number of faces in object..
    vertex # for A  this info is repeated #faces times
    vertex # for B
    vertex # for C
    color/edge flag indicator
      low byte = 0-15 == face color (palette #)
      hi byte, bits 0-2 == line visibility. bit 0= AB 1= BC 2 = CA */
 
/* some global fixed point values */

int value;	/* for prefix notation, ie 66 FRAMES */
int keys;	/* number of key objects loaded */
int ani_flag;
int *next_ob();	/*	 define routine to return pointer to int */
int *find_obj();	/* returns pointer to named object's data */
int *add();		/* to fix cad-3d file format problem: always odd */
 
long free,startfree;	/* for my memory management routines */
float interpolate();
float ui[10];		/* interpolation-calculation array */

/* Alert dialog strings */

char noCAD[]=
"[1][CAD-3D is not present!][ OK ]";
char cadfail[]=
"CAD-3D is not present!";

char myMSG[]=
"[0][Metamorphic Animator| By Mark Kimball|(c) 1990 Antic Publishing ][ OK ]";

char noOBJ[]=
" I Can't find|that object!";

char noOP[]=
"Unknown Command|line:|";

char syntax[]=
"Syntax error!";

char args[]=
"Argument(s) out of range";

char notIMP[]=
"Not implemented yet!";

int *ob_buff;  /* pointer to Malloc'ed memory */

FILE *f_in,*fopen();			/* stream input definitions */

static int oldpal[16];
static long oldsc,supersc,newsc;
int numverts,numface,numobs;


/**************************************************************/
/* Init accessory, store accessory title in system's menu bar */
/* then wait for a message using evnt_mesag().  When we get   */
/* an open (message type 40), we ask CAD-3D for various       */
/* information, then do our thing.  If CAD-3D 2.0 is not      */
/* running, the accessory goes to sleep until called again    */
/* by waiting for another evnt_mesag.                         */
/**************************************************************/

main()
{
register int ix;

appl_init();
handle=graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

menu_id=menu_register(gl_apid,"  Metamorph  ");

/* request memory for object buffer. */

free = MEM;
ob_buff = (int *) Malloc(free);
startfree = (long) ob_buff;

for(;;)		/* do forever */
 {
 evnt_mesag(mgbuf);

 if(mgbuf[0]==40 && mgbuf[4]==menu_id)
  {
   cad_id=appl_find("CAD3D2  ");

   if(cad_id<0)
    form_alert(1,myMSG);
   else
   {
   if(commtime(mgin,RAMSTATUS,0,0,0,0,0) == TRUE)
    do_acc();
   else
    form_alert(1,myMSG);
   }
  }
 }	/* end of forever loop */
}

/* CAD-3D is present.  perform Meta. */

do_acc()
{
	char param[8];

/* open window to cover all CAD3D controls.  This prevents
   clicks from dropping through and causing problems later. */

	wind_get(0,4,&windx,&windy,&windw,&windh);
	whand = wind_create(0,windx,windy,windw,windh);
	wind_open(whand,windx,windy,windw,windh);

	if(f_init() == TRUE)	/* initialize error-handler */
	goto exit_acc;

	if(open_script() == FALSE)	/* attempt to open .CTL file */
	{
	 form_alert(1,"[1][File access failed!][Sorry!]");
	 goto exit1;
	}

/* successful script access.  initialize meta environment. */
	value = -1;
	keys = 0;
	do_line();	/* interpret the .CTL file */

exit_acc:
	fclose(f_in);	/* close the .CTL file */
exit1:
	wind_close(whand);	/* remove window */
	wind_delete(whand);

	if( ani_flag == TRUE)	/* just in case we forgot to close the ani. */
	stop();
}

/* routines to perform file I/O */

char path_name[80],file_name[10];

/*  select_file returns OK or CANCEL */
int select_file()
{
	int button;

	path_name[0]=Dgetdrv() + 'A';	/* setup current drive as prefix */
	path_name[1]=':';			/* append necessary stuff */
	Dgetpath(&path_name[2],0);	/* get pathname into current drive */
	strcat(path_name,"\\*.CTL");
	fsel_input(path_name,file_name,&button);
	return(button);
}

/* opens input file for interpretation */
int open_script()
{
	int i;
	
	file_name[0] = '\0';

	if (select_file() == 0 )
	return(FALSE);

/* now put together path and file for full specification in
   fopen() call */

	i = 0;
	while(path_name[i] != '*')  /* advance to first asterisk */
	i++;

	path_name[i] = '\0';
	strcat(path_name,file_name);

	f_in = (FILE *) fopen(path_name,"r");
	if(f_in ==  NULLPTR )
	return(FALSE);

	return(TRUE);
}


/* command interpreter, called from do_acc */

do_line()
{
	char param[8];
	char temp[10];
	int opcode;

/* interpret and execute input command(s)	*/
	while( parse(param) )
	{
	  /* search for command-word */
	  if( (opcode = lookup(param)) == -1 ) /* not a recognized cmd. */
	  {
	   if( number(param,&value) == FALSE)  /* is it a number? */
	   {
	    disp_err(noOP);	/* no, it's nothing we recognize */
	    goto bye_bye;
	   }
	   else
	   goto bottom;		/* yes, a number.  command may follow. */
	  }

/* simple switch string to act on each main command */

	switch(opcode)
	{

	case 0:		/* N FRAMES */
	frames();
	break;
	
	case 1:		/* MOVE (camera) */
	disp_err(notIMP);
	break;

	case 2:		/* CAMERA N */
	disp_err(notIMP);
	break;

	case 3:		/* LOAD  .3d2 file */
	load();
	break;

	case 4:		/* BEGIN  filespec */
	begin();
	break;

	case 5:		/* DOIT */
	doit();
	break;

	case 6:		/* STOP the animation */
	stop();
	break;

	case 7:		/* END the animation */
	stop();
	break;

	default:		/* syntax error */
	disp_err(syntax);
	}	/* end of switch statements */

bottom:
	opcode = 0;	/* to fix megamax bug */
	}	/* end of forever loop */
bye_bye:
	opcode = 0;		/* same thing */

}

/* parse a word from the input stream.  Use space, comma or newline
   as delimiter   */
int parse(out)
char *out;
{
	char temp[50],c;
	int i;

	/* advance past delimiters */

	if(feof(f_in))
	{
	return(FALSE);
	}

	do
	c = (char) getc(f_in);
	while( c  == ' ' ||  c == ',' || c == '\r' || c == '\n' );

	if( c == EOF)
	{
	return(FALSE);
	}

	temp[0] = c;
/* read word, up to next space or comma or newline */

	i = 1;

/* here's an apparent bad unstructured code example, but nothing
   else seems to work without a whole lot of messing around  */

char1:

	c = (char) getc(f_in);

	if( c == ' ' || c == ',' || c == EOF || c == '\r' || c == '\n' )
	goto char2;

	temp[i++] = c;
	goto char1;

char2:

	temp[i] = '\0';	/* null-term the string */

/* place temp[] into destination-string */
	strcpy(out,temp);
	return(TRUE);
}


/* a very simple lookup routine to scan for acceptable commands */

int lookup(in)
register char *in;
{
	register int i;

	static char ops[20][3] = {
	"fr",	/* n FRAMES for n frames in animation */
	"mo",	/* MOVE data (currently selected camera) */
	"ca",	/* CAMERA n for which camera to use */
	"lo",	/* LOAD filespec... for key objects.  Loads from disk. */
	"be",	/* BEGIN filespec.  animation stops after n frames */
	"do",	/* DOIT */
	"st",	/* STOP */
	"en",	/* END  */
	"\0",	/* finish the set of entrys */
	};

	i=0;

	while( ops[i][0] != '\0' )
	 {
	 if( ops[i][0] == *in && ops[i][1] == *(in+1) )
	  return(i);
	 i++;
	 }
	return(-1);
}

/* routine to convert a string to a number.  It returns FALSE if
   it encounters a character that is not a number, else TRUE. */

int number(in,v)
register char *in;
int *v;
{
	int work;

	work = 0;

	while(*in != '\0')
	{

	 if( *in < '0' || *in > '9' )	/* check if still a number */
	  return(FALSE);

	 work = work*10 + ( *in - '0' );
	 in++;
	}
	*v =  work;
	return(TRUE);
}

/* load.  called from interpreter, will load .3D2 file */
load()
{
	char param[80];

	if(parse(param) == FALSE)
	abort("Load What!?");

	if( !loadfile(param))
	abort("Loadfile failed!");
}

/* loadfile routine for .3D2 files */
int loadfile(string)
char string[];
{
	int fd,dta[22];
	long size;
	int num,i,k;
	int *data;
	char err[20];
	Fsetdta(dta);
	if( Fsfirst(string,0) != 0 )
	return(FALSE);

	
	setlong(&size,&dta[13]);	/* get filesize */

        size -= 256L;      /* reduce by 256 because header goes elsewhere */

/* check if buffer has enough room for it */
	if(size > free)
	abort("Out of Memory!");

/* open the file */

	fd = Fopen(string,0);

/* read the header into obheads[] array */

	Fread(fd,(long) sizeof(obheads)/10, &obheads[keys]);

	ob_body[keys] = startfree;	/* store start-addr of data */
	keys++;				/* one more key-frame */

	Fread(fd,size,startfree);	/* read the rest */

	free -= size;			/* adjust freemem amount */
	startfree += size;		/* adjust pointer to freemem */
	startfree = (startfree + 1L) & 0xfffffffeL;	/* make it even */
	Fclose(fd);			/* close the file */

/* now just check if object struct is OK */

	num = obheads[0].numobs;

	if( keys != 1 )
	{
	 data = (int *) ob_body[0];
	 for(i = 0; i< num; i++)
	 {
	  if( (k = vfy_ob(keys-1,data,num)) < 0  )
	   {
	    sprintf(err,".3D2 file Inconsistent|%s %d",data,k);
	    abort(err);
	   }
	  data = next_ob(data);
	 }
	}

	return(TRUE);

}

/* frames()  is a "null" word, just checks syntax */
frames()
{
	if(value == -1 )
	abort("N FRAMES is the|correct syntax");
}

/* begin()  expects a filename in the input stream and
            does the animation production. For now, it
            will use camera 1 with whatever settings it
            had from cad-3d.  Ditto for zoom, perspective
            and lights.  */

begin()
{
	int i;
	char temp[80];
	float u,du;	/* interpolation parameters */
	long dfree,memx;

/* check if we have loaded any key-obs and defined #frames */

	if( keys == 0 )
	abort("No objects loaded!");

	if( value == -1 )
	abort("You must specify|the number of frames|for this animation");

/* get filename.  Check if it can be a filename or perhaps
   is another command. */

	if( !parse(temp) )
	abort("No output filename!");

	if( lookup(temp) != -1 )
	disp_err("You may not have|specified a filename|for this animation");

/* now start the animation... strip path & filename as needed by
   cad-3d start-recording function.  Non-stereo Cybermate ani. */

/* check to see if we have enough room to create the metamorphosed
   object */
	memx = (MEM - free)/( (long) keys); /* amount of memory used per key */

	if(memx > free)
	abort("Not enough memory for|temporary objects!");
	
	setup(temp);

/* upload palette stuff to cad-3d */
	del_temp();		  /* delete all objects in CAD-3D */

/* upload object-colors to CAD3D */
	comm_it(mgin,LOADCOLOR,obheads[0].palette,obheads[0].group,0);
/* upload line color to CAD3D */
	comm_it(mgin,LINECOLOR,obheads[0].wfcolor,obheads[0].outline,0,0,0);
	meta(0.0);	/* create starting object collection */
/* select all objects we uploaded */
	comm_it(mgin,SLCTALL,0,0,0,0,0);
/* show the image */
	comm_it(mgin,SUPER,0,0,0,0,0);
/* tell CAD3D to start the ani */
	comm_it(mgin,STARTANI,path_name,file_name,1);
	setlong(&dfree,&mgin[3]);	/* get amount of freemem on disk */

	if( dfree == 0L)
	{
	 abort("CAD-3D error|Can't start ani");
	}

	ani_flag = TRUE;
}

/* doit()  simply does the animation. */

doit()
{
	float u,du;
	int i,c;

	if( ani_flag == FALSE)
	abort("You must BEGIN|The animation first!");

/* fill interpolation array for evenly spaced tweening.  This could be
   changed to produce variable speeds */

	du = 1.0/( (float) keys-1);
	u = 0.0;
	
	for( i = 0; i < keys; i++)
	{
	ui[i] = u;
	u += du;
	}

	du = 1.0/( (float) value);
	u = 0.0;

/* metamorphosis loop */

	for(i = 0; i < value; i++)	/* repeat for # FRAMES */
	{
	 u += du;

	 if(Crawio(0xff) != 0)	/* check keyboard.  If struck, exit */
	  {
	   if( form_alert(1,"[2][Abort Animation?][Yes|No]") == 1)
	   {
	    fatal();
	    stop();
	   }
	  }

	 del_temp();	/* delete temporary object in cad-3d, if there */
	 meta(u);	/* create new object(s) */
	 comm_it(mgin,SLCTALL,0,0,0,0,0);
	 comm_it(mgin,RECORD,0,0,0,0,0);
	}

/* restore anim params for next animation sequence  */
	keys = 0;
	value = -1;
	startfree = (long) ob_buff;
	free = MEM;
}

/* tell CAD3D to delete all objects.  This technique does NOT reset any
   of CAD3D's other settings, unlike the NEW command */

del_temp()
{
	int deletes[80],i;

	for(i = 0; i < 80; i++)
	deletes[i] = 1;		/* delete any & all objects, #0 - 79 */

	comm_it(mgin,0x3d07,deletes,0,0,0);
}

/* stop() just ends the animation */

stop()
{
	if(ani_flag == TRUE)
	{
	 comm_it(mgin,STOPANI,0,0,0,0,0);
	 ani_flag = FALSE;
	}
}


/* meta is the heart of the metamorphosis concept.  It takes
   all the key-object descriptions and produces interpolated
   vertex coordinates for a given u.  It also creates the complete
   object for uploading into cad-3d. */

meta(u)
float u;
{

	float verts[10],temp;
	int n,i,j,k,t,vertex,offset;
	int *obj,*this,*x,*y,*z,*a,*b,*c,*d;
	char err[20];

	obj = (int *) ob_body[0];	/* pointer to primary object desc */
	n = obheads[0].numobs;

 
	for(i = 0; i < n; i++)		/* main object-creation loop */
	{

	 this = find_obj(0,obj,n);	/* pointer to object data */

	 j = num_verts(this);
	 obstrc.os_vertices = j;
	 offset = j;
	 x = (int *) startfree;		/* init output locations */
	 y = x + offset;	/* and cad-3d upload structure */
	 z = y + offset;
	 a = z + offset;
	 k = num_faces(this);
	 obstrc.os_faces = k;

	 offset = k;
	 b = a + offset;
	 c = b + offset;
	 d = c + offset;

	 obstrc.os_x = x;
	 obstrc.os_y = y;
	 obstrc.os_z = z;
	 obstrc.os_a = a;
	 obstrc.os_b = b;
	 obstrc.os_c = c;
	 obstrc.os_color = d;
	 
	 strcpy(obstrc.os_name,this);	/* copy object-name to struct  */

	 t = 0;				/* index into vertex-data */
	 for( k = 0; k < j; k++ )	/* vertex-interpolation loop */
	  {

/* do x */

	   init_array(verts,i,t++);	/* place vertex values into array */
	   temp = interpolate(u,verts);
	   vertex = (int) ( temp*100.0 );
	   *x++ = vertex;

/* do y */
	   init_array(verts,i,t++);	/* place vertex values into array */
	   temp = interpolate(u,verts);
	   vertex = (int) ( temp*100.0 );
	   *y++ = vertex;

/* do z */

	   init_array(verts,i,t++);	/* place vertex values into array */
	   temp = interpolate(u,verts);
	   vertex = (int) ( temp*100.0 );
	   *z++ = vertex;

	   
	  }	/* end of vertex loop */

/* now we must move face data to those arrays */

	k = num_verts(this);
	j = num_faces(this);
	this = add(this,13L + 6L * (long) k);	/* set pointer to face-data */

	 for(k = 0; k < j; k++)
	 {
	 *a++ = wfetch(this++);
	 *b++ = wfetch(this++);
	 *c++ = wfetch(this++);
	 *d++ = wfetch(this++);
	 }
	 upload();		/* upload object to cad-3d */
	 obj = next_ob(obj);	/* do next object */
	}	/* end of objects loop */
}

/* init_array(verts,n,k)  sets up the interpolation array */
init_array(verts,n,k)
float verts[];
int n,k;	/* nth object, kth entry */
{
	int *vpt,*npt;
	int numobs,i,j;
	long offset;
	float temp;

	numobs = obheads[0].numobs;
	vpt = (int *) ob_body[0];	/* ptr to first ob-body */
	offset = 11L + 2L * (long) k;	/* precalculate offset */
	
	if(n != 0)
	{
	 for(j = 0; j < n; j++)		/* skip to nth object */
	 vpt = next_ob(vpt);
	}

	if( vpt == NULLPTR)
	abort("skipped too far|in init_array");
	
	for(i = 0; i < keys; i++) /* make keys-number of entrys in verts[] */
	{

	 npt = find_obj(i,vpt,numobs);	/* find Ith instance of object */

	 if(npt == NULLPTR)
	 abort("couldn't find object|in init_array");
	 
	 npt = add(npt,offset);
	 temp = (float) wfetch(npt);
	 verts[i] = temp/100.0;		/* convert from fixed point */
	}
}

/* float interpolate(u,verts)  does the LaGrange interpolation.  ui[]
   must be initialized before calling this routine! */

float interpolate(u,verts)
float u,verts[];
{
	register float sum,product;
	register int i,j;

	sum = 0.0;
	for(i = 0; i < (keys); i++)
	{
	 product = verts[i];
	 for(j = 0; j < (keys); j++)
	  {

	    if( j != i )
	     product *= ( u - ui[j] )/( ui[i]-ui[j] );
	  }
	 sum += product;
	}
	return(sum);
}

/* upload()  This command will upload one object into cad-3d.  No
             status is returned; upload() checks on its own and
             aborts if cad-3d reports an error */

upload()
{
	char err[40];
	int faces,verts,i,j,t,u,v,w;
	char *name;
	int *x,*y,*z,*a,*b,*c,*d;
	float t1,t2,t3;

	comm_it(mgin,SENDOBJ,&obstrc,0,0,0);
	if(mgin[3] < 0 )
	{
/* do object dump */
	name = obstrc.os_name;

	x = obstrc.os_x;
	y = obstrc.os_y;
	z = obstrc.os_z;
	a = obstrc.os_a;
	b = obstrc.os_b;
	c = obstrc.os_c;
	d = obstrc.os_color;

	disp_err(name);
	verts = obstrc.os_vertices;
	sprintf(err,"#vertices: %d",verts);
	disp_err(err);

	for(i = 0; i < verts; i++)
	{
	 t1 = (*x++)/100.0;
	 t2 = (*y++)/100.0;
	 t3 = (*z++)/100.0;
	 sprintf(err,"x = %f|y = %f|z = %f",t1,t2,t3);
	 disp_err(err);
	}

	faces = obstrc.os_faces;
	sprintf(err,"#faces: %d",faces);
	disp_err(err);

	for(i = 0; i < faces; i++)
	{
	 t = *a++;
	 u = *b++;
	 v = *c++;
	 w = *d++;
	 sprintf(err,"face# %d|%d %d %d|color: $%x",i,t,u,v,w);
	 disp_err(err);
	}
	abort("CAD-3D error|Can't load object");
	}
}

/*  some utility routines to access object-info */

/*   find_obj returns the address of the named object in the
     keyth  file.  This will allow us to mix up the order
     of objects in key files, if needed.  n is max# objects. */

int *find_obj(key,string,n)
int key,n;
char string[];
{
	int i,*data;
	long verts,faces;

	data = (int *) ob_body[key];	/* get pointer to first ob in list */

/* object-finder loop */
	for(i = 0; i < n; i++)
	{
	 if( strcmp(data,string) == 0 )
	 return(data);

	 data = next_ob(data); /* advance to next object in frame */
	}

	return(NULLPTR);	/* return NULL pointer if we didn't find it */
}

/* next_ob(ptr) advances pointer to next object in file.  No error
   check is done, so it COULD advance into forbidden terrority if
   not handled correctly! */

int *next_ob(data)
long data;
{
	long temp;

	data = data + 9L;	/* go past obname section */
	temp = (long) wfetch(data);	/* get # verts */
	data = data + temp*6L + 2L;
	temp = (long) wfetch(data);	/* get #faces */
	return( (int*) ( data + temp*8L + 2L) );
}

/* num_verts(data)	returns #vertices in an object */
int num_verts(data)
long data;
{
	return( wfetch(data+9L) );
}

/* num_faces(data)	returns #faces in an object */
int num_faces(data)
long data;
{
	long temp;

	temp = (long) num_verts(data);
	data = data + temp*6L + 11L;
	return( wfetch(data) );
}
	
/*  int vfy_ob(obj,key,n)
		  checks structure of keyth object for
                  proper metamorphosis.  Since coordinates
		  can be different, it just checks ob-name and face
		  for the object.  N = maxnum objects in file
*/

int vfy_ob(key,obj,n)
int *obj;
int key,n;
{

	int *data;
	int f1,f2,i,j,t1,t2;
	long temp;

/* see if we can find the object */
	data = find_obj(key,obj,n);
	if(data == NULLPTR)
	return(-1);	/* couldn't find obj name */

/* now, we need to get vertex data on original object! */

	f1 = num_verts(data);
	f2 = num_verts(obj);

	if( f1 != f2)	/* check number of vertices */
	return(-2);	/* #faces don't agree */

	temp = 13L + 6L * (long) f1;	/* offset pointers to face-info */
	data = add(data,temp);
	obj  = add(obj,temp);

	/* compare each face's vertex assignments */
	for(i = 0; i < f1; i++)  /* each face */
	{
	 for(j = 0; j < 3; j++)	/* 3 indices/face */
	 {
	  if( wfetch(data) != wfetch(obj) )
	  return(-3);

	  data = add(data,2L);	/* advance to next index */
	  obj  = add(obj,2L);
	 }
	 data = add(data,2L); /* skip face & edge color word */
	 obj  = add(obj,2L);
	}

	return(TRUE);

}


/* routine to offset pointers properly for .3D2 file structure.  */

int *add(v1,v2)
register long v1,v2;
{
	return( (int*) (v1+v2) );
}
	
/*****************/
/* Copy a string */
/*****************/

strcpy(to,from)
char *from;
char *to;
{
while(*to++ = *from++);
}

/***********************************/
/* Concatenate string onto another */
/***********************************/

strcat(to, from)
char *to,*from;
{
while(*to) ++to;
while(*to++ = *from++);
}

/*********************************/
/* Return the length of a string */
/*********************************/

strlen(string)
char *string;
{
register int  ix;

for (ix=0; *string++; ++ix);
return(ix);
}

/* setup(string)  sets up path_name and file_name for CAD-3D
   record initiation */
setup(in)
char in[];
{
	int i,j;

/* first, check if input string has path designator */
	if( in[2] != '\\')	/* no, get drive */
	{
	 path_name[0] = Dgetdrv() + 'A';
	 path_name[1] = ':';
	 path_name[2] = '\\';
	 path_name[3] = '\0';
	 strcat(path_name,in);	/* copy rest of filename to path */
	}
	else
	strcpy(path_name,in);

/* now identify filename part of input string */
	i = strlen(path_name);
	j = strlen(in);
	while( path_name[i] != '\\' ) /* find last  \ */
	{
	 i--;
	 j--;
	}
	i += 1;		/* advance past the backslash */
	j += 1;		
	path_name[i] = '\0';	/* terminate path here */
	strcpy(file_name,&in[j]);  /* copy filename over */

}

/*********************************************************
   Communicate with CAD-3D 2.0 -- send message, get reply 
**********************************************************/

comm_it(rbuf,command,v1,v2,v3,v4,v5)
int rbuf[],command,v1,v2,v3,v4,v5;
{
	toCAD(command,v1,v2,v3,v4,v5);

	do
	 {
	  evnt_mesag(rbuf);
	 }
	 while(rbuf[0] != ( command | 0x0080) );
}

/* modified version of comm_it, to integrate a timeout function in case
   cad-3d really isn't present */

int commtime(rbuf,command,v1,v2,v3,v4,v5)
int rbuf[],command,v1,v2,v3,v4,v5;
{
	int event;

toCAD(command,v1,v2,v3,v4,v5);

do
{
/* wait for timeout OR event_mesag */
event = evnt_multi(0x0030,-1,-1,-1,
		    0,0,0,0,0,
		    0,0,0,0,0,
		    rbuf,500,0,
		    &dum,&dum,&dum,&dum,&dum,&dum);
	if(event & 0x0020)  /* if timeout, return FALSE to caller */
	return(FALSE);
}
while(rbuf[0] != (command | 0x0080));  /* repeat until handshake */
return(TRUE);

}

/***************************************/
/* Send standard message to CAD-3D 2.0 */
/***************************************/

toCAD(command,v1,v2,v3,v4,v5)
int command,v1,v2,v3,v4,v5;
{
mgbuf[0]=command;
mgbuf[1]=gl_apid;
mgbuf[2]=0;
mgbuf[3]=v1;
mgbuf[4]=v2;
mgbuf[5]=v3;
mgbuf[6]=v4;
mgbuf[7]=v5;
appl_write(cad_id,16,mgbuf);
}

/*********************************/
/* Set a long to a pair of words */
/*********************************/

setlong(l1,l2)
long *l1,*l2;
{
*l1= *l2;
}

/********************************************/
/* Display an error message in an alert box */
/********************************************/

disp_err(string)
char string[];
{
char errstr[80];

strcpy(errstr,"[1][");
strcat(errstr,string);
strcat(errstr,"][ OK ]");

graf_mouse(0,&dum);

form_alert(1,errstr);
}


/* abort interpretation and return to cyber-control */

abort(string)
char string[];
{
disp_err(string);
startfree = (long) ob_buff;
free = MEM;
fatal();		/* go back to code following f_init() call? */
}
