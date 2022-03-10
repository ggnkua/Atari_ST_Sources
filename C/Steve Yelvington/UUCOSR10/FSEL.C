#include <string.h>
#include <stdio.h>


/*
 * function: fsel
 * description:  Display the GEM file selector, including a prompt if
 *               one is supplied. The path and default filename will
 *               be shown, if supplied. Convert the user's input into
 *               a complete filename and copy the result into the
 *               supplied buffer.
 *
 * side effects: fsel remembers the previous values of inpath and default
 *               filename and uses them if those args are NULL
 * 
 * returned value: 0 if [CANCEL], 1 if [OK]
 *
 * warning: this will not work under TOS before 1.4 unless you use
 *          Ian Lepore's GEMFAST bindings to fake the fsel_exinput call.
 */


static char xpath[128], xinsel[14];

fsel(prompt, path, insel, filename)
	char *prompt, /* message to user, or NULL */
	     *path,  /* initial path, or NULL */
             *insel, /* initial filename, or NULL */
             *filename;    /* 128-byte buffer for full selected name */
	{
	char *p;
	int button;
	if (!prompt)
		prompt = "Please choose a file";
	if (!path)
		fullpath(xpath,"*.*");
	else
		fullpath(xpath,path);
	if (insel)
		strcpy(xinsel,insel);
	strupr(xpath);
	strupr(xinsel);
	fsel_exinput(xpath,xinsel,&button,prompt);
	if (xinsel[0] == '\0')
		button = FALSE;	/* don't let user select a blank file */
	strcpy(filename,xpath);
	if (p = strrchr(filename,'\\'))
		*++p = '\0';
	else if (p = strrchr(filename,':'))
		*++p = '\0';
	strcat(filename,xinsel);
	return button;
	}

#if TESTVERSION
#include <stdio.h>
main()
	{
	int button;
	char full_filename[128];
	appl_init();
	button = fsel("Hello there",NULL,"FUBAR.TOS",full_filename);
	printf("\nSelected file = [%s]; button = %d\n", full_filename, button);
	printf("RETURN to exit.\n");
	getchar();
	appl_exit();
	}

#endif

