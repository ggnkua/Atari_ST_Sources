
#ifndef __main_h
#define __main_h


#define MAXAA 512

#define CMDMAX 4096

#include "datatypes.h"

extern char packer_fn[MAXAA];	// = "arjbeta.exe";
extern char arj_arg1[MAXAA];	//	= " a";
extern char arj_arg2[MAXAA];	//	= " -m4";
extern char archive_name[MAXAA];	//= "1.ARJ";	// archive filename
extern char input_name[MAXAA];		//= "1.PRG";	// input filename
extern char space[];				// = " ";


extern char image_fn[MAXAA];
extern char boot_fn[MAXAA];
extern char kernel_fn[MAXAA];


extern char commandline[CMDMAX];


#endif