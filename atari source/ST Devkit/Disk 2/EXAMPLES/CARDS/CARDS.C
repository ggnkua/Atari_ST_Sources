/************************************************************************/
/*									*/
/* cards.c	by John Feagans		01 APR 86	01 APR  86	*/
/*									*/
/* An example program which uses a RCS created dialog box and accesses  */
/* the strings of text pointed to by the tedinfo structure.  The program*/
/* prints author, title, subject cards for a home library.		*/
/************************************************************************/

#include "cards.h"
#include "osbind.h"
#include "define.h"
#include "ctype.h"
#include "card.h"	/* include file from RCS */
#include "gemdefs.h"
#include "obdefs.h"

/* Global arrays */

int	contrl[12];
int	intin[256];
int	ptsin[256];
int	intout[256];
int	ptsout[256];
int	pxyarray[4];

int	xdesk,ydesk,wdesk,hdesk;	/*size of the desktop		*/
int	charw, charh, boxw, boxh;	/*global character definitions	*/
int	handle;				/*handle of the workstation	*/

OBJECT	*dialog1;	/* pointer to objects in our dialog box		*/
char	*string;	/* a te_ptext from a tedinfo			*/
char	*strings[8];	/* holder of pointers to all our strings	*/
char	**tedptr;	/* pointer to a te_ptext in the tedinfo		*/

main()
{

	int	done;	/* flag to stay in dialog until exit button */
	int	i;	/* index */
	int	ret;	/* return flag for testing		*/

	/* Set the system up to do GEM calls*/
	appl_init();

	/* Get the handle of the desktop */
	handle=graf_handle(&charw,&charh,&boxw,&boxh);

	/* Open the workstation. */
	for (i=1; i<10; ++i) intin[i] = 1; intin[10] = 2;
	v_opnvwk(intin, &handle, intout);

	/* Load resource file */
	rsrc_load("CARD.RSC");

	/* Get the address of our dialog box data*/
	rsrc_gaddr(0,CARD,&dialog1);

	/* Copy pointers to our strings out of the tedinfo structures and
	   into our array.  Null out our strings.			*/
	for (i=INDEXNO;i<=SUBJECT;i++)	/* named objects RCS order	*/
	{
		tedptr=dialog1[i].ob_spec;
		string=strings[i-INDEXNO]= *tedptr;
		string[0]=0;
	}

	/* grab the screen */
	wind_update(0);

	done=FALSE;
	while (done==FALSE)
	{
		/* Reset mouse form to arrow */
		graf_mouse(ARROW,0x0L);

		dialog1[PRINT].ob_state=NORMAL;
		dialog1[EXIT].ob_state=NORMAL;

		/* subroutine displays dialog, returns exit causing obj.*/
		ret = do_dialog(dialog1,INDEXNO);

		/* mouse form to busy */
		graf_mouse(HOURGLASS,0x0L);

		/* PRINT is a name for the exit button created in RCS 	*/
		if (ret==PRINT)
		  print();
		else
		  done = TRUE;	/* EXIT because only other exit button	*/

	} /*while done==FALSE	*/

	/* release the screen */
	wind_update(1);

	/* free the resource */
	rsrc_free();

	/* Close the workstation. */
	v_clsvwk(handle);
 
	 /* Release GEM calls */
	appl_exit();
}

/************************************************************************/
/* display a dialog box							*/
/************************************************************************/
do_dialog(which,where)
	long	which;
	int	where;
	{
		int	ob_drxclip,ob_dryclip,ob_drwclip,ob_drhclip;
		int	fo_doreturn;

		form_center(which,
			&ob_drxclip,
			&ob_dryclip,
			&ob_drwclip,
			&ob_drhclip);
		form_dial(0,
			0,0,36,36,
			ob_drxclip,
			ob_dryclip,
			ob_drwclip,
			ob_drhclip);
		form_dial(1,
			0,0,36,36,
			ob_drxclip,
			ob_dryclip,
			ob_drwclip,
			ob_drhclip);
		objc_draw(which,
			0,
			10,
			ob_drxclip,
			ob_dryclip,
			ob_drwclip,
			ob_drhclip);
		fo_doreturn=form_do(which,where);
		form_dial(2,
			0,0,36,36,
			ob_drxclip,
			ob_dryclip,
			ob_drwclip,
			ob_drhclip);
		form_dial(3,
			0,0,36,36,
			ob_drxclip,
			ob_dryclip,
			ob_drwclip,
			ob_drhclip);
		return (fo_doreturn);
	}

unsigned	card[18][50];	/* card image	*/

#define	NORM	0
#define UNDER	1
#define BOLD	2

/* generate three cards and print them out	*/
print()
	{
		int	i;

		/* make subject all caps*/
		string=strings[7];
		i=0;
		while (string[i]!=0) string[i++]=toupper(string[i]);

		clear_card();
		build_author();
		dump_card();

		clear_card();
		build_title();
		dump_card();

		clear_card();
		build_subject();
		dump_card();

	}

/* clear the card image	*/
clear_card()
	{
		int	i,j;
		for (i=0;i<18;i++) for (j=0;j<50;j++) card[i][j]=0x20;
	}

/* dump card image to our print device	*/
dump_card()
	{
		int	i,j,device;
		char	control,data,last_control;

		device=AUX;
		if ((Setprt(-1)&16)==0)  device=PRT;

		last_control=0;

		for (i=0;i<18;i++)
		{
			for (j=0;j<50;j++)
			{
				control=card[i][j]/256;
				data= card[i][j] & 0xff;
				if (last_control!=control) 
				{
					if (control==UNDER) 
					{ /*underline on*/
						Bconout(device,27);
						Bconout(device,'-');
						Bconout(device,1);
					}
					if (control==BOLD) 
					{ /*bold on*/
						Bconout(device,27);
						Bconout(device,'E');
					}
					if (last_control==UNDER) 
					{ /*underline off*/
						Bconout(device,27);
						Bconout(device,'-');
						Bconout(device,0);
					}
					if (last_control==BOLD) 
					{ /*bold off*/
						Bconout(device,27);
						Bconout(device,'F');
					}
					last_control=control;
				}

				Bconout(device,data);
			}

			Bconout(device,13);
			Bconout(device,10);
		}
	}

build_author()
	{
		copy_card(NORM,&card[3][25],"Index No.:");	
		copy_card(BOLD,&card[3][36],strings[0]); 
		copy_card(NORM,&card[1][4],"Author:");	
		copy_card(BOLD,&card[1][12],strings[1]);
		copy_card(NORM,&card[5][4],"Title:");	
		copy_card(UNDER,&card[5][11],strings[2]);
		copy_card(NORM,&card[7][4],"Publisher:");	
		copy_card(BOLD,&card[7][15],strings[3]);
		copy_card(NORM,&card[8][4],"Date published:");	
		copy_card(BOLD,&card[8][20],strings[4]);
		copy_card(NORM,&card[10][4],"Book type:");	
		copy_card(BOLD,&card[10][15],strings[5]);
		copy_card(NORM,&card[10][29],"No. of pages:");	
		copy_card(BOLD,&card[10][43],strings[6]);
		copy_card(NORM,&card[12][4],"Subject:");	
		copy_card(BOLD,&card[12][13],strings[7]);
	}

build_title()
	{
		copy_card(NORM,&card[3][25],"Index No.:");	
		copy_card(BOLD,&card[3][36],strings[0]);
		copy_card(NORM,&card[5][4],"Author:");	
		copy_card(BOLD,&card[5][12],strings[1]);
		copy_card(NORM,&card[1][4],"Title:");	
		copy_card(UNDER,&card[1][11],strings[2]);
		copy_card(NORM,&card[7][4],"Publisher:");	
		copy_card(BOLD,&card[7][15],strings[3]);
		copy_card(NORM,&card[8][4],"Date published:");	
		copy_card(BOLD,&card[8][20],strings[4]);
		copy_card(NORM,&card[10][4],"Book type:");	
		copy_card(BOLD,&card[10][15],strings[5]);
		copy_card(NORM,&card[10][29],"No. of pages:");	
		copy_card(BOLD,&card[10][43],strings[6]);
		copy_card(NORM,&card[12][4],"Subject:");	
		copy_card(BOLD,&card[12][13],strings[7]);
	}

build_subject()
	{
		copy_card(NORM,&card[3][25],"Index No.:");	
		copy_card(BOLD,&card[3][36],strings[0]);
		copy_card(NORM,&card[12][4],"Author:");	
		copy_card(BOLD,&card[12][12],strings[1]);
		copy_card(NORM,&card[5][4],"Title:");	
		copy_card(UNDER,&card[5][11],strings[2]);	
		copy_card(NORM,&card[7][4],"Publisher:");	
		copy_card(BOLD,&card[7][15],strings[3]);	
		copy_card(NORM,&card[8][4],"Date published:");	
		copy_card(BOLD,&card[8][20],strings[4]);	
		copy_card(NORM,&card[10][4],"Book type:");	
		copy_card(BOLD,&card[10][15],strings[5]);	
		copy_card(NORM,&card[10][29],"No. of pages:");	
		copy_card(BOLD,&card[10][43],strings[6]);	
		copy_card(NORM,&card[1][4],"Subject:");	
		copy_card(BOLD,&card[1][13],strings[7]);	
	}

/* copy string into card image	*/
copy_card(print_flags,string1,string2)
	unsigned	print_flags;
	unsigned	*string1;
	char	*string2;
	{
		int	i;
		unsigned flag;
		i=0;
		while (string2[i] != 0)
		{
			flag=print_flags;
			if ((flag==UNDER) && (string2[i]==' '))  flag=0;
			string1[i]=string2[i]+(flag*256);		
			i++;
		}
	}
