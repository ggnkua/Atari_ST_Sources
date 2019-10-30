/* ==================================================================== */
/*   Nova Command Line Interpreter			V 1.2		*/
/* ==================================================================== */

/* -------------------------------------------------------------------- */
/*	Mod History							*/
/* -------------------------------------------------------------------- */
/*									*/
/*	V1.2	i)	Build command tails for Pexec correctly, with	*/
/*			count byte at head of string			*/
/*		ii)	Fix building of target file name in copy	*/
/*			command; no longer includes source drive id	*/
/*			as part of new file name			*/
/*		iii)	Allow multiple file names on erase command, and	*/
/*			don't bother reporting an error if the file	*/
/*			isn't there to delete				*/
/*									*/
/* -------------------------------------------------------------------- */

#include	"lib\gem.h"
#include	"lib\stdio.h"
#include	"lib\tos.h"

#define	CR	13
#define	LF	10

char	version[]="1.2";		/* Program version number	*/

struct 	{				/* Terminal input buffer	*/
	char	max_length;		/* Maximum no of characters	*/
	char	length;			/* Number of characters read	*/
	char	in[128];		/* Character buffer		*/
	}	input;

struct	{				/* Disc transfer address buffer	*/
	char	os[21];			/* Gemdos reserved		*/
	char	attributes;		/* File attributes		*/
	int	timestamp;		/* Time stamp			*/
	int	datestamp;		/* Date stamp			*/
	long	filesize;		/* Size of file in bytes	*/
	char	filename[14];		/* Name.extension of file	*/
	}	*dta;

char	macros[1024];			/* Macro buffer			*/
int	rez;				/* Screen resolution 0,1 or 2	*/
char	*arg_ptr[8];			/* Pointers to cmd arguments	*/
int	arg_count;			/* Number of arguments		*/
int	cmd_length;			/* Length of cmd name string	*/
char	output_buffer[64];		/* Console output		*/
char	last_file[14];			/* Previous file in generic set */
char	current_path[64];		/* Current access path name	*/
char	select[64];			/* Generic file selector	*/
char	cmd_image[128];			/* Packed case-shifted command	*/
char	current_drive;			/* Current drive id - alpha	*/
int	exit_flag;			/* Set to 1 by quit command	*/
int	macro_mode;			/* Set to 1 during macro execn	*/
int	count;				/* Number of names per line	*/
int	max_count=4;			/* Maximum names per line	*/

char	commands[80]			/* Command string		*/

int	work_in[12];			/* VDI workspace in		*/
int	work_out[57];			/* VDI workspace out		*/
int	handle;				/* VDI screen handle		*/


/* ==================================================================== */
/*   Main								*/
/* ==================================================================== */

main()  {

	char *ptr,*cmd,*tail;

	initialise();

	while (!exit_flag) {
		get_command_line();
		upshift(input.in);
		execute_command_line(input.in,&ptr,&cmd,&tail);
		}

	return 0;

	}


/* -------------------------------------------------------------------- */
/*	Initialise at start of run					*/
/* -------------------------------------------------------------------- */

initialise() {

	char *x;
	int n;

	for (n=0; n<10; work_in[n++]=1); work_in[10]=2;

	v_opnvwk(work_in,&handle,work_out);
	v_hide_c(handle);
	v_clrwk(handle);
	v_enter_cur(handle);
	v_curhome(handle);

	c_conws("----------------------------------------");
	c_conws("----------------------------------------"); newline();
	c_conws("  NOVA -- Version "); c_conws(version); newline();
	c_conws("----------------------------------------");
	c_conws("----------------------------------------");

	newline(); newline(); newline();

	if ((trap(14,23)&0xffffL)==0L)
		set_time();

	exit_flag = 0;  macro_mode = 0;

	current_drive = (char)d_getdrv() + 65;
	d_getpath(current_path,0);

	dta=f_getdta();

	max_count = (rez=getrez()) ? 4 : 2;

	move_string("COPY:DIRECTORY:ERASE:HELP:KILL:MAKE:",commands);
	extd_string("PATH:QUIT:RENAME:STATUS:TIME:XECUTE:",commands);
	x = commands;
	while (*x) {
		if (*x==':')
			*x='\0';
		x++;
		}

	load_macros();

	}


/* -------------------------------------------------------------------- */
/*	Load macro file (if it's there!)				*/
/* -------------------------------------------------------------------- */

load_macros() {

	char *buffer;
	char *i,*j,*k;
	long size;

	if (load_file("NOVA\\MACROS",&buffer,&size)<0) {
		c_conws("Macros not loaded"); newline();
		return;
		}

	i = buffer; j = macros;

	while (*i!='#') i++;

	while (*i!='@') {
		k = j; *k = 1; i++; j++;
		while (*i!='#' && *i!='@') {
			if (*i!=CR) {
				*j = (*i==LF) ? 0 : *i;
				j++; (*k)++;
				}
			i++;
			}
		*j++ = 0; (*k)++;
		}

	*j=0;

	m_free(buffer);

	}


/* -------------------------------------------------------------------- */
/*	Issue prompt and get response					*/
/* -------------------------------------------------------------------- */
	
get_command_line() {

	newline();
	output_buffer[0] = current_drive;
	output_buffer[1] = 175;
	output_buffer[2] = 32;
	output_buffer[3] = '\0';

	c_conws(output_buffer);

	input.max_length = 128;  input.length = 0;  input.in[0] = '\0';

	c_conrs(&input);

	input.in[input.length] = '\0';

	newline();

	}


/* -------------------------------------------------------------------- */
/*	Execute keyboard or macro command line				*/
/* -------------------------------------------------------------------- */

execute_command_line(line,ptr,cmd,tail) char *line,**ptr,**cmd,**tail; {

	*ptr = line;

	while (parse(ptr,cmd,tail)) {
		if (!check_for_macro(*cmd,*tail)) {
			if (!execute_internal(*cmd,*tail)) {
				execute_external(*cmd,*tail);
				}
			}
		}
	}


/* -------------------------------------------------------------------- */
/*	Parse command line returning command/tail pointers		*/
/* -------------------------------------------------------------------- */

parse(ptr,cmd,tail) char **ptr,**cmd,**tail; {

	char *x;

	x=*ptr; cmd_length=0;
	while (*x==' ') x++;
	if (*x=='\0') return 0;
	*cmd = x; *tail = NULL;
	while (*x && !one_of(" ;\r",*x)) { cmd_length++; x++; }
	if (*x=='\0' || *x=='\r') {*ptr=x; return 1; }
	if (*x==';')  {*x='\0'; *ptr=x+1; return 1; }
	*x++='\0';
	while (*x==' ') x++;
	*tail=x;
	while (*x && *x!=';') x++;
	if (*x=='\0') {*ptr=x; return 1; }
	*x='\0'; *ptr=x+1; return 1;

	}


/* -------------------------------------------------------------------- */
/*	Check whether entered command is a macro			*/
/* -------------------------------------------------------------------- */

check_for_macro(cmd,tail) char *cmd,*tail; {

	char *m;

	if (macro_mode) return 0;

	m = macros;

	while (*m) {
		if (comp_string(cmd,m+1)) {
			macro_mode = 1;	
			execute_macro(m+1,tail);
			macro_mode = 0;
			return 1;
			}
		m = m+*m;
		}

	return 0;

	}


/* -------------------------------------------------------------------- */
/*	Execute a macro command						*/
/* -------------------------------------------------------------------- */

execute_macro(m,tail) char *m,*tail; {

	char *x,*ptr,*cmd,*arg;

	x = m;  while(*x) x++; x++;

	extract_parameters(tail);

	while (*x) {
		expand_line(&x);
		execute_command_line(cmd_image,&ptr,&cmd,&arg);
		}

	}


/* -------------------------------------------------------------------- */
/*	Set up pointers to macro parameters				*/
/* -------------------------------------------------------------------- */

extract_parameters(tail) char *tail; {

	char *x;

	for (arg_count=0; arg_count<8; arg_count++)
		arg_ptr[arg_count] = NULL;

	arg_count = 0; x = tail;

	if (x==NULL)
		return;

	while (*x) {
		arg_ptr[arg_count++] = x;
		if (arg_count<8) {
			while (*x && *x!=' ') x++;
			while (*x == ' ') x++;
			}
		else {
			c_conws("Too many arguments");
			newline();
			x="";
			}
		}

	}


/* -------------------------------------------------------------------- */
/*	Expand macro line inserting parameters				*/
/* -------------------------------------------------------------------- */

expand_line(m) char **m; {

	char *x,*y,*z;

	x = *m; y = cmd_image;

	while (*x) {
		while (*x && *x!='%') *y++ = *x++;
		if (*x) {
			z = arg_ptr[(int)(*(++x)-49)];
			if (z!=NULL)
				while (*z && *z!=' ') *y++ = *z++;
			x++;
			}
		}
	*y = 0;
	*m = ++x;

	}


/* -------------------------------------------------------------------- */
/*	Execute an internal command					*/
/* -------------------------------------------------------------------- */
	
execute_internal(cmd,tail) char *cmd,*tail; {

	if (cmd_length==2 && *(cmd+1)==':' && tail==NULL) {
		change_drive(*cmd);
		return 1;
		}

	switch (decode_command(cmd)) {

		case 'C':	copy_file(tail);
				return 1;
		case 'D':	list_directory(tail);
				return 1;
		case 'E':	delete_file(tail);
				return 1;
		case 'H':	display_help();
				return 1;
		case 'K':	kill_directory(tail);
				return 1;
		case 'M':	create_directory(tail);
				return 1;
		case 'P':	set_default_path(tail);
				return 1;
		case 'Q':	setup_exit();
				return 1;
		case 'R':	rename_file(tail);
				return 1;
		case 'S':	show_status();
				return 1;
		case 'T':	set_time();
				return 1;
		case 'X':	execute_program(tail);
				return 1;
		
		}

	return 0;

	}


/* -------------------------------------------------------------------- */
/*	Reduce command to single letter if internal			*/
/* -------------------------------------------------------------------- */

char * decode_command(cmd) char *cmd; {

	char *x,*y,*z;

	if (cmd_length==1)
		return (*cmd);

	x=commands;

	while (*x) {
		y=x; z=cmd;
		while (*z && *z==*y) {
			y++; z++;
			}
		if (!*z)
			return (*cmd);
		while (*x) x++;
		x++;
		}

	return ('\0');

	}


/* -------------------------------------------------------------------- */
/*	Display standard format error message				*/
/* -------------------------------------------------------------------- */

error(message) char *message; {

	newline();

	move_string("*!*---\?  ",output_buffer);
	char_string(7,output_buffer);
	extd_string(message,output_buffer);
	char_string(7,output_buffer);

	c_conws(output_buffer); newline();

	}


/* -------------------------------------------------------------------- */
/*	Change current drive						*/
/* -------------------------------------------------------------------- */

change_drive(x) char x; {

	if (!range(x,'A','P')) {
		error("Drive identifier out of range");
		return;
		}

	d_setdrv((int)x-65);
	current_drive = (char)d_getdrv()+65;
	d_getpath(current_path,0);
	
	}


/* -------------------------------------------------------------------- */
/*	Copy command							*/
/* -------------------------------------------------------------------- */

copy_file(tail) char *tail; {

	char *x,*buffer;
	long size;
	int  flag;

	x=tail; unpack(&x);

	if (flag=load_file(tail,&buffer,&size)) {
		switch (flag) {
			case -1: error("No such file");
				 break;
			case -2: error("Insufficient memory");
				 break;
			case -3: error("Error reading file");
				 break;
			}
		return;
		}

	move_string(x,output_buffer);

	if (length(x)==2 && *(x+1)==':')
		if (*(tail+1)==':')
			extd_string(tail+2,output_buffer);
		else
			extd_string(tail,output_buffer);

	if (flag=save_file(output_buffer,&buffer,&size)) {
		switch (flag) {
			case -1: error("Unable to create file");
				 break;
			case -2: error("Error writing file");
				 break;
			}
		}

	}


/* -------------------------------------------------------------------- */
/*	Exit command							*/
/* -------------------------------------------------------------------- */

setup_exit() {

	v_exit_cur(handle); v_show_c(handle,0); v_clsvwk(handle);

	exit_flag = 1;

	}


/* -------------------------------------------------------------------- */
/*	Directory command						*/
/* -------------------------------------------------------------------- */

list_directory(tail) char *tail; {

	int i;
	char *c;

	if (tail!=NULL)
		move_string(tail,select);
	else
		move_string("*.*",select);

	if (f_sfirst(select,0x10)<0)
		return;

	last_file[0] = '\0';  count=0;  newline();

	while (!same_name()) {
		display_file();
		f_snext();
		}

	newline();

	}


same_name() {
	int i;

	i=0;
	while (dta->filename[i]!=0 && dta->filename[i]==last_file[i]) i++;
	return (dta->filename[i]==last_file[i]? 1 : 0);
	}


display_file() {
	int i,j,k,z;

	i = j = k = 0;

	z = rez ? 13 : 12;

	while ((last_file[j]=dta->filename[i++])!='\0') {
		if (last_file[j]=='.') {
			while (k<8) output_buffer[k++]=' ';
			}
		output_buffer[k++]=last_file[j++];
		}

	while (k<z) output_buffer[k++]=' ';

	output_buffer[z] = '\0';

	if (count>max_count) {
		count=0;
		newline();
		}

	count++;

	if (dta->attributes==0x10)
		if (rez==2)
			v_rvon(handle);
		else
			colour_text(1);

	c_conws(output_buffer);

	if (dta->attributes==0x10)
		if (rez==2)
			v_rvoff(handle);
		else
			colour_text(15);

	if (rez)
		c_conws("  ");
	else
		c_conws(" ");

	}


colour_text(c) {

	char x[4];

	x[0]=27; x[1]='b'; x[2]=(char)c; x[3]=0; c_conws(x);

	}


/* -------------------------------------------------------------------- */
/*	Make command							*/
/* -------------------------------------------------------------------- */

create_directory(tail) char *tail; {

	if (tail==NULL)
		error("Directory name?");
	else
		if (d_create(tail)<0)
			error("Invalid directory specification");

	}


/* -------------------------------------------------------------------- */
/*	Kill command							*/
/* -------------------------------------------------------------------- */

kill_directory(tail) char *tail; {

	if (tail==NULL)
		error("Directory name?");
	else
		if (d_delete(tail)<0)
			error("Invalid directory specification");

	}


/* -------------------------------------------------------------------- */
/*	Help command							*/
/* -------------------------------------------------------------------- */

display_help() {

	char *i,*j,*k;
	int c,l;

	newline();
	newline(); c_conws("Commands:-"); newline(); newline();

	i=commands; l=4;

	while (*i) {
		j=output_buffer; c=0;
		while (*i) {
			*j++=*i++; c++;
			}
		if (l>1)
			while (c++<10) *j++=' ';
		*j='\0';
		c_conws(output_buffer);
		if (!--l) {
			l=4; newline();
			}
		i++;
		}
	newline();

	if (macros[0]==0) return;

	newline(); c_conws("Macros:-"); newline(); newline();

	i=macros; l=4;

	while (*i) {
		j = i+1; k=output_buffer; c=0;
		while (*j) {
			*k++=*j++; c++;
			}
		if (l>1)
			while (c++<10) *k++=' ';
		*k='\0';
		c_conws(output_buffer);
		if (!--l) {
			l=4; newline();
			}
		i = (i+*i);
		}

	newline();

	}


/* -------------------------------------------------------------------- */
/*	Path command							*/
/* -------------------------------------------------------------------- */

set_default_path(tail) char *tail; {
	
	if (tail==NULL)
		move_string("..",current_path);
	else
		move_string(tail,current_path);

	move_string("*.*",select);

	if (d_setpath(current_path)<0)
		error("Unable to set requested path");
	if (d_getpath(current_path,0)<0)
		error("Unable to get path");

	}


/* -------------------------------------------------------------------- */
/*	Rename command							*/
/* -------------------------------------------------------------------- */

rename_file(tail) char *tail; {

	char *p;
	
	if (tail==NULL) {
		error("File name missing");
		return;
		}

	p=tail; while (*p!=' ') p++; *p++='\0';
	while (*p==' ') p++;

	if (*p=='\0') {
		error("New name missing");
		return;
		}

	if (f_rename(0,tail,p)) error("Command rejected");

	}


/* -------------------------------------------------------------------- */
/*	Time command							*/
/* -------------------------------------------------------------------- */

set_time() {

	int  date,time;

	get_current_time(&date,&time);

	get_time(&time);
	get_date(&date);

	newline();

	settime(((date<<16)|time));

	t_settime(time);
	t_setdate(date);

	}


get_current_time(d,t) int *d,*t; {

	long current;

	current = gettime();

	*t = (int) (current & 0xffff);
	*d = (int) ((current>>16) & 0xffff);

	}


get_time(t) int *t; {

	int h,m;

	struct {
		char	ml;
		char	l;
		char	x[8];
	}		buf;

	newline();

	m = (*t>>5)  & 0x3f;
	h = (*t>>11) & 0x1f;

	output_buffer[0] = (h/10)+48;
	output_buffer[1] = (h%10)+48;
	output_buffer[2] = ':';
	output_buffer[3] = (m/10)+48;
	output_buffer[4] = (m%10)+48;
	output_buffer[5] = 0;

	c_conws("    Time: "); c_conws(output_buffer); c_conws("     ");

	buf.ml=8; buf.l=0; c_conrs(&buf);

	if (buf.l!=4)
		return;

	h = (buf.x[0]-48)*10+(buf.x[1]-48);
	m = (buf.x[2]-48)*10+(buf.x[3]-48);

	*t= ((h<<6)|m)<<5;

	}


get_date(t) int *t; {

	int d,m,y;

	struct {
		char	ml;
		char	l;
		char	x[8];
	}		buf;

	newline();

	d = *t & 0x1f;
	m = (*t>>5) & 0xf;
	y = (d) ? (((*t>>9) & 0x7f) + 80) : 0;

	output_buffer[0] = (d/10)+48;
	output_buffer[1] = (d%10)+48;
	output_buffer[2] = '.';
	output_buffer[3] = (m/10)+48;
	output_buffer[4] = (m%10)+48;
	output_buffer[5] = '.';
	output_buffer[6] = (y/10)+48;
	output_buffer[7] = (y%10)+48;
	output_buffer[8] = 0;

	c_conws("    Date: "); c_conws(output_buffer); c_conws("  ");

	buf.ml=8; buf.l=0; c_conrs(&buf);

	if (buf.l!=6)
		return;

	d = (buf.x[0]-48)*10+(buf.x[1]-48);
	m = (buf.x[2]-48)*10+(buf.x[3]-48);
	y = (buf.x[4]-48)*10+(buf.x[5]-48);

	*t= ((((y-80)<<4)|m)<<5)|d;

	}
	
	
/* -------------------------------------------------------------------- */
/*	Status command							*/
/* -------------------------------------------------------------------- */

show_status() {

	char	string[8];
	long	memory,
		factor,
		free_space,
		used_space;
	char	*s;

	struct {
		long	free_clusters;
		long	total_clusters;
		long	bytes_per_sector;
		long	sectors_per_cluster;
	}		info;

	newline();

	memory=(long)trap(1,72,-1L); s=&string[7]; *s=0;

	d_free(&info,0);

	factor = info.sectors_per_cluster * info.bytes_per_sector;
	free_space = factor * info.free_clusters;
	used_space = factor * info.total_clusters - free_space;

	string[0]=current_drive; string[1]=string[2]=' ';
	string[3]=':'; string[4]=string[5]=' '; string[6]=0;

	c_conws("  Path...... "); c_conws(string); c_conws(current_path);

	newline(); newline();

	convert(memory,string,&s);
	c_conws("  Memory.... "); c_conws(s);

	newline(); newline();

	convert(used_space,string,&s);
	c_conws("  Bytes used "); c_conws(s);

	convert(free_space,string,&s);
	c_conws("  Free space "); c_conws(s);

	newline();
	
	}


/* -------------------------------------------------------------------- */
/*	Erase command							*/
/* -------------------------------------------------------------------- */

delete_file(tail) char *tail; {

	char *x,*y;

	if (tail==NULL) {
		error("Argument missing");
		return;
		}

	x=tail;

	while (*x) {
		y=x;
		unpack(&x);
		f_delete(y);
		}

	}


/* -------------------------------------------------------------------- */
/*	Xecute command							*/
/* -------------------------------------------------------------------- */

execute_program(tail) char *tail; {

	char *p;

	p=tail;
	while (*p && *p!=' ') p++;
	if (*p==' ') *p++=0;
	while (*p==' ') p++;

	execute_external(tail,p);

	}


/* -------------------------------------------------------------------- */
/*	Execute external program					*/
/* -------------------------------------------------------------------- */

execute_external(cmd,tail) char *cmd,*tail; {

	int i,program_type;
	char *x,*y;

	move_string(cmd,select);

	x=select; i=1;

	while (*x) {
		if (*x=='.') {
			i=0;
			break;
			}
		x++;
		}

	if (i)
		extd_string(".*",select);

	dta->filename[0]=0;

	if (f_sfirst(select,0)<0) {
		error("Unrecognised command");
		return;
		}

	last_file[0] = '\0';

	while (!(program_type=executable())) {
		f_snext();
		if (same_name()) {
			error("Unrecognised command");
			return;
			}
		for (i=0; (last_file[i]=dta->filename[i]); i++);
		}

	x=y=select;

	while (*x) {
		if (*x=='\\')
			y=x+1;
		x++;
		}

	move_string(dta->filename,y);

	if (tail==NULL) {
		output_buffer[0]=output_buffer[1]=0;
		}
	else {
		output_buffer[0]=(char)(length(tail));
		move_string(tail,output_buffer+1);
		}

	if (program_type==1) {
		v_exit_cur(handle);
		v_clrwk(handle);
		v_show_c(handle,0);
		}

	if (p_exec(0,select,output_buffer,0L)==0xd9L)
		error("Insufficient memory");

	if (program_type==1) {
		v_hide_c(handle);
		v_clrwk(handle);
		v_enter_cur(handle);
		v_curhome(handle);
		}

	}


/* -------------------------------------------------------------------- */
/*	Check file extension to see whether its executable		*/
/* -------------------------------------------------------------------- */

executable() {

	char *p;

	p = dta->filename;

	while (*p && *p!='.') p++;

	if (!*p)
		return 0;

	if (comp_string(p,".PRG")) return 1;
	if (comp_string(p,".TOS")) return 2;
	if (comp_string(p,".TTP")) return 2;

	return 0;

	}


/* ******************************************************************** */
/*	Subroutines							*/
/* ******************************************************************** */

newline() {
	char string[3];

	string[0]=13; string[1]=10; string[2]=0;
	c_conws(string);
	}


move_string(from,to) char *from,*to; {

	while (*to++=*from++);

	}


extd_string(from,to) char *from,*to; {

	while (*to) to++;
	while (*to++=*from++);

	}


char_string(c,s) char c,*s; {

	while (*s) s++;
	*s++=c; *s++=0;

	}


comp_string(s1,s2) char *s1,*s2; {

	while (*s1 && (*s1==*s2)) { s1++; s2++; }

	if (*s1==*s2)
		return 1;
	else
		return 0;

	}


one_of(s1,s2) char *s1,s2; {

	while (*s1) if (*s1++==s2) return 1;
	return 0;

	}


range(s1,s2,s3) char s1,s2,s3; {

	return ((s1<s2)||(s1>s3)?0:1);

	}


upshift(s) char *s; {

	while (*s) {
		if (range(*s,'a','z')) *s-=32;
		s++;
		}
	}


convert(n,s,p) long n; char *s,**p; {

	char *x;

	x = s+7; *x = 0;

	while (n) {
		*(--x) = (char) (n%10+48); n/=10;
		}

	*p = x;

	}


unpack(s) char **s; {

	char *t;

	t=*s;

	while (*t && *t!=' ') t++;

	if (*t) {
		*t=0; t++;
		}

	if (*t==' ') t++;

	*s=t;

	}


length(s) char *s; {

	int n;

	n=0; while (*s++) n++;

	return n;

	}


/* -------------------------------------------------------------------- */
/*	File handling							*/
/* -------------------------------------------------------------------- */

load_file(path,buf,size) char *path,**buf; long *size; {

	int  file_handle;
	long count;
	char *buffer;

	if ((file_handle=(int)f_open(path,0))<0)
		return -1;

	f_sfirst(path,0); count=dta->filesize;

	buffer=m_alloc(count);

	if (buffer==NULL)
		return -2;

	*size=f_read(file_handle,count,buffer);

	if (*size<0)
		return -3;

	f_close(file_handle);

	*buf=buffer;

	return 0;

	}


save_file(path,buf,size) char *path,**buf; long *size; {

	int  file_handle;

	if ((file_handle=f_create(path,0))<0) 
		return -1;

	if (f_write(file_handle,*size,*buf)!=*size)
		return -2;

	f_close(file_handle);

	m_free(*buf);

	}
