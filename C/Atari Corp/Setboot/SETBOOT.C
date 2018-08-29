/*
 *	Name:		SETBOOT
 *	Version:	1.0
 *	Date:		07/23/91
 *	Author:		Hans-Martin Kroeber
 *	Description:	
 *		Utility to set the boot preference on a TT to boot
 *		either TOS, Atari System V or to have no boot preference.
 *
 *	Developed using Mark Williams C 3.01
 *
 *
 */
 
/*
 *	Include Files
 */
 
#include "setbtgem.h"		/* GEM stuff */
#include "setboot.h"		/* GEM resource definitions */
#include "setbtmsg.h"		/* Dialog and error messages */

#ifndef SUCCESS
#define SUCCESS 0
#define FAILURE	-1
#endif

/*
 *	Sysbase [system varibale] (used for reset)
 */
#ifndef _sysbase
#define _sysbase 0x4f2
#endif
 
/*
 *	Ptr to Cookie Jar
 */
#ifndef _p_cookies
#define _p_cookies	0x5a0
#endif

/*
 *	Cookie to find machine
 */
long *MCH_COOKIE = (long *) "_MCH";

#define	TT	2

/*
 *	File name of the resource file
 */
#define RCSNAME	"SETBOOT.RSC"

/*
 *	Boot preferences in NVRAM
 */
#define	BOOT_NO		0x0000
#define BOOT_ASV	0x0040
#define BOOT_TOS	0x0080

/*
 *	NVMaccess xbios call
 *
 *	NVMaccess(op, start, count, buffer)
 */
#define	xNVRAM	0x2e

#define NVMREAD		0
#define NVMWRITE	1
#define NVMINIT		2

WORD	buffer[24];		/* 48 bytes of NVRAM */

/*
 *	Function Declarations
 */
 
WORD	handle_menu();		/* handle menu events */
WORD	do_set_box();		/* display the set boot preference dialog box */
WORD	det_tt();		/* determine if running on a TT */
WORD	getcookie();		/* get a cookie */
WORD	init_strings();		/* init message strings */

/*
 *	:main()
 *	let's go...
 */
 
WORD	main(argc, argv)
WORD	argc;
BYTE	**argv;
{
	static GEMBUF	*a;	/* Buffer holding information about GEM env. */

	
	/*
	 *	Init gemlib. (RC = Raster Coordinates)
	 */
	a = init_appl(RC, RCSNAME);
	
	/*
	 *	Init strings for dialog boxes. Get their addresses.
	 *	Strings were loaded with the RSC file.
	 */
	init_strings();
	
	/*
	 *	Check wether we're running on a TT
	 */
	if (det_tt() == FAILURE) {
#ifndef DEBUG
		exit_appl(a);	/* sorry, no TT */
#endif
		;
	}
	
	/*
	 *	Display the menu bar
	 */
	init_menu(a, MENU);
	/*
	 *	Start application and wait for user input.
	 */
	evnt(a);
}

/*
 *	:handle_menu()
 *
 *	Handle GEM menu events
 */
 
WORD	handle_menu(a, title, entry)
GEMBUF	*a;
WORD	title;	/* Selected menu title */
WORD	entry;	/* Selected menu entry */
{
	switch (title) {
	case MDESK:
		/*
		 *	copyright box
		 */
		if (entry == MABOUT) 
			do_form(a, ABOUT, 0);	
		break;
	case MFILE:
		/*
		 *	Quit
		 */
		if (entry == MQUIT) {
			if (form_alert(1, quitmsg) == 1)
				exit_appl(a);
		}
		break;
	case MBOOT:
		switch (entry) {
		case MSET: 
			do_set(a);	/* set boot preference */
			break;
		case MDISPLAY:
			do_display(a);	/* display boot preference */
			break;
		case MINIT:
			do_init(a);	/* initialize nvram */
			break;
		}
		break;		
	case MHELP:
 		switch (entry) {
 		case MHGEN:		/* General Help */
			do_form(a, HELP, 0);
			break;
		case MHSET:		/* Help on Set boot preference */
			do_form(a, HSET, 0);
			break;
		case MHDISPL:		/* Help on Display boot preference */
			do_form(a, HDISP, 0);
			break;
		case MHNVRAM:		/* Help on Initializing NVRAM */
			do_form(a, HINIT, 0);
			break;
		}
			
		break;
	}
}

/*
 *	:do_set()
 *	Pop up dialog box 'Set preferred Operating System'. Allows user
 *	to change the boot preference.
 */
 
WORD	do_set(a)
GEMBUF	*a;
{
	OBJECT	*asvdialog;	/* dialog box */
	
	rsrc_gaddr(R_TREE, SET, &asvdialog);
	
	
#ifndef DEBUG
	/*
	 *	Read NVRAM once with a count of zero to see if
	 *	the checksum is good
	 */
	if (xbios(xNVRAM, NVMREAD, 0, 0, buffer) < 0) {
		form_alert(1, checksummsg);
		return FAILURE;
	}
	/*
	 *	read NVRAM to get current boot preference
	 */
	if (xbios(xNVRAM, NVMREAD, 0, 2, buffer) < 0) {
		form_alert(1, readfailedmsg);
		return FAILURE;
	}
		
#endif
	/*
	 *	Set radio buttons to current state state
	 */
	if (buffer[0] == BOOT_TOS) {
		sel_obj(asvdialog, TOSBOX);	
		desel_obj(asvdialog, ASVBOX);
		desel_obj(asvdialog, NOBOX);
	} else if (buffer[0] == BOOT_ASV) {
		desel_obj(asvdialog, TOSBOX);	
		sel_obj(asvdialog, ASVBOX);
		desel_obj(asvdialog, NOBOX);
	} else if (buffer[0] == BOOT_NO) {
		desel_obj(asvdialog, TOSBOX);	
		desel_obj(asvdialog, ASVBOX);
		sel_obj(asvdialog, NOBOX);
	}
	
	/*
	 *	Now pop up the dialog box.
	 */
	if (do_form(a, SET, 0) == SETOK) {	/* OK button selected */
#ifdef DEBUG
		if (asvdialog[TOSBOX].ob_state & SELECTED)
			form_alert(1, "[1][TOS][OK]");
		if (asvdialog[ASVBOX].ob_state & SELECTED)
			form_alert(1, "[1][ASV][OK]");
		if (asvdialog[NOBOX].ob_state & SELECTED)
			form_alert(1, "[1][NO][OK]");
#endif
		
#ifndef DEBUG
		/*
	 	 *	Read NVRAM once with a count of zero to see if
	 	 *	the checksum is good
	 	 */
		if (xbios(xNVRAM, NVMREAD, 0, 0, buffer) < 0) {
			form_alert(1, checksummsg);
			return FAILURE;
		}
		
		/*
		 *	Get selected boot preference
		 */
		if (asvdialog[TOSBOX].ob_state & SELECTED)
			buffer[0] = BOOT_TOS;
		else if (asvdialog[ASVBOX].ob_state & SELECTED)
			buffer[0] = BOOT_ASV;
		else if (asvdialog[NOBOX].ob_state & SELECTED)
			buffer[0] = BOOT_NO;
				
		/*
		 *	Write boot preference to NVRAM
		 */
		if (xbios(xNVRAM, NVMWRITE, 0, 2, buffer) < 0) {
			form_alert(1, writefailedmsg);
			return FAILURE;
		}
#endif			
		/*
		 *	Ask user to reboot system to boot new OS
		 */
		if (form_alert(2, rebootmsg) == 1) { /* reboot system */
			LONG	oldsp;
			LONG	*base;
			WORD	(*resetvec)();
			
			oldsp = Super(0L);
			base = *((LONG *) _sysbase);
			resetvec = (WFCTP) *(base + 4);
			(*resetvec)();			/* reset system */
			
			Super(oldsp);			/* just in case ... */
		}
		
	
	}
	return SUCCESS;
}

/*
 *	:do_display()
 *	Display current boot preference in dialog box.
 */
WORD	do_display(a)
GEMBUF	*a;
{
	OBJECT	*displaybox;
	
	rsrc_gaddr(R_TREE, DISPLAY, &displaybox);
	
#ifndef DEBUG
	/*
	 *	Read NVRAM once with a count of zero to see if
	 *	the checksum is good
	 */
	if (xbios(xNVRAM, NVMREAD, 0, 0, buffer) < 0) {
		form_alert(1, checksummsg);
		return FAILURE;
	}
	/*
	 *	read NVRAM to get current boot preference
	 */
	if (xbios(xNVRAM, NVMREAD, 0, 2, buffer) < 0) {
		form_alert(1, readfailedmsg);
		return FAILURE;
	}
		
#endif
	/*
	 *	Get boot preference message
	 */
	if (buffer[0] == BOOT_TOS) 
		displaybox[BOOTINFO].ob_spec = (LONG) boottosmsg;
	else if (buffer[0] == BOOT_ASV) 
		displaybox[BOOTINFO].ob_spec = (LONG) bootasvmsg;
	else if (buffer[0] == BOOT_NO) 
		displaybox[BOOTINFO].ob_spec = (LONG) bootnomsg;
	
	/*
	 *	Display boot preference
	 */			
	do_form(a, DISPLAY, 0);
	
	return SUCCESS;
}

/*
 *	:do_init()
 *	Initialize NVRAM.
 */
WORD	do_init(a)
{
	/*
	 *	Confirm action by user (Dialog box)
	 */
	if (form_alert(2, initmsg) == 1) {	/* OK button selected */
#ifndef DEBUG
		/*
		 *	init NVRAM
		 */
	xbios(xNVRAM, NVMINIT, 0, 0, buffer);
#endif
		;
	}
}

/*
 *	:det_tt()
 *	Determine machine the program is running on.
 *	Returns Success if it's a TT and FAILURE if it's not.
 *	If it's not a TT, an alert box pops up, informing the user.
 */

WORD	det_tt()
{
	long	machine;
	
	if (getcookie(*MCH_COOKIE, &machine) != 0)
		if ((machine >> 16) == TT)
			return SUCCESS;		/* OK, it's a TT */
	form_alert(1, nottmsg);			/* Not a TT message */
	return FAILURE;
}			

/*
 *	:getcookie()
 *	See Atari's developer guide
 */
 
struct cookie {
	long	c;
	long	v;
};
	
int	getcookie(target, p_value)
long	target;
long	*p_value;
{
	long	oldssp;
	struct	cookie	*cookie_ptr;
	
	if (Super(1L) == 0) oldssp = Super(0L);
	else oldssp = 0L;
	
	cookie_ptr = *(struct cookie **) _p_cookies;
	
	if (oldssp) Super(oldssp);
	if (cookie_ptr != NULL) {
		do {
			if (cookie_ptr->c == target) {	/* found it */
				if (p_value != NULL) *p_value = cookie_ptr->v;
				
				return 1;
			}
		} while ((cookie_ptr++)->c != 0);
	}
	return 0;	/* failed to find it */
}	

/*
 *	:init_strings()
 *	Get strings which were loaded with the RSC file.
 *	This is done for initernationalization, so that the
 *	message string can be edited in the resource file. The
 *	only two hard coede strings are NOGEM and NORSC.
 */
 
WORD	init_strings()
{
	char	*tmp1, *tmp2;
	
	rsrc_gaddr(R_STRING, NOMEMMSG, &nomemmsg);
	rsrc_gaddr(R_STRING, QUITMSG, &quitmsg);
	rsrc_gaddr(R_STRING, REBTMSG, &rebootmsg);
	rsrc_gaddr(R_STRING, NOTTMSG, &nottmsg);
	rsrc_gaddr(R_STRING, NOMENMSG, &nomenu);
	rsrc_gaddr(R_STRING, INITMSG, &initmsg);
	rsrc_gaddr(R_STRING, BTTOSMSG, &boottosmsg);
	rsrc_gaddr(R_STRING, BTASVMSG, &bootasvmsg);
	rsrc_gaddr(R_STRING, BTNOMSG, &bootnomsg);
	rsrc_gaddr(R_STRING, CSUMMSG1, &tmp1);
	rsrc_gaddr(R_STRING, CSUMMSG2, &tmp2);
	if ((checksummsg = malloc(strlen(tmp1) + strlen(tmp2) + 1)) == NULL) {
		form_alert(1, nomemmsg);
		exit_appl();
	}
	strcpy(checksummsg, tmp1);
	strcat(checksummsg, tmp2);
	
	rsrc_gaddr(R_STRING, READMSG, &readfailedmsg);
	rsrc_gaddr(R_STRING, WRITMSG1, &tmp1);
	rsrc_gaddr(R_STRING, WRITMSG2, &tmp2);
	if ((writefailedmsg = malloc(strlen(tmp1) + strlen(tmp2) + 1)) 
	== NULL) {
		form_alert(1, nomemmsg);
		exit_appl();
	}
	strcpy(writefailedmsg, tmp1);
	strcat(writefailedmsg, tmp2);
}
