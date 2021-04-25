/*********************************************************************/
/*       Written and compiled with Laser 'c'               */
/*********************************************************************/
/* ACCOUNT PROG	     v 4.15 */
/*********************************************************************/
/*  S.Hardy 1988*/
/**********************************************************************
/* INCLUDE FILES			*/			     
/*********************************************************************/
#include <stdio.h>
#include <ctype.h>
#undef EOF
#include <define.h>
#include <strings.h>
#include "account.h"
#include <gemdefs.h>
#include <obdefs.h>     
#include <osbind.h>  
/**********************************************************************/
/* DEFINES						   	     */
/*********************************************************************/


#define WI_KIND		(SIZER|MOVER|FULLER|CLOSER|NAME)
#define EOL '\n'
/*********************************************************************/

/* GLOBAL VARIABLES					   	     */
/*********************************************************************/
FILE *fp1;
FILE *fp2;
FILE *fp3;
FILE *pr;
float get_float();
int	gl_hchar;
int	gl_wchar;
int	gl_wbox;
int	gl_hbox;	/* system sizes */

int 	phys_handle;	/* physical workstation handle */
int 	handle;		/* virtual workstation handle */
int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];	/* storage wasted for idiotic bindings */

int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */
int	wi_handle;	/* window handle */
int	top_window;	/* handle of topped window */

int	xdesk,ydesk,hdesk,wdesk;
int	xold,yold,hold,wold;
int	xwork,ywork,hwork,wwork;	/* desktop and work areas */
int xobj,yobj,hobj,wobj;
int mx,my;		/* mouse x and y pos. */
int	butdown;	/* button state tested for, UP/DOWN */
char	 password[6];
int  	 *dummy;
int		 pasok ;
int 	 pass ;
int 	 crec = 1 ;  /*   cheque record */
int 	 srec = 1 ;  /*   standing order rec */
int		 tdate ;
int 	 day ;
int 	 month ;
int      number ;
int      year ;
struct info {
float 	 balance ;
char	 n_password[6] ;
int		 chk_rec ;
int      std_rec ;
int 	 curmth;
			};
			struct info old = {00000.00,"12345",1,1,00};
struct record {
char		 payee[20];
int		     chk_cleared ;
float		 chk_number ;
float		 chk_amount ;

         };
  struct record cheque = {"dddddddd",0,0000000.00,000000.00};
struct stand {
char    payee[20];
int 	number;
int 	date;
float 	amts;
int 	d_flag;
int		m_flag;
			};
			struct stand sords = {"aaaaaa",0000,00000,000000.00,00,00};        
typedef union {
	struct {
		unsigned day	: 5;
		unsigned month	: 4;
		unsigned year	: 7;
		unsigned seconds : 5;
		unsigned minutes : 6;
		unsigned hours	 : 5;
	} part;
	long realtime;
} time;

        
/******************************************************************/
main()

{
int 	 resolution ;
int i ,x,c,cmth,ende;
	long gemdos();
OBJECT *tree;
char dummy1[10],dummy2[10];	
time mytime;
	open_work();
	appl_init();
	graf_mouse(3,&dummy); /* mouse = hand */

	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	resolution = Getrez();
	wi_handle=wind_create(WI_KIND,xdesk,ydesk,wdesk,hdesk);

	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	if (resolution != 1)
		{
			form_alert(1,"[1][ Medium Resolution |    Only ][OK]");
			good_by1();
		}
	if (!rsrc_load("account.rsc"))
    {
        /* If not found display alert box and then abort. */

form_alert(1, "[1][Cannot find account.rsc file|Terminating ...][OK]");
		good_by1();
	}


if((fp1 = fopen("file1","br+"))==0)
{
	fp1 = fopen("file1","bw+");
	fclose(fp1);
	}
if((fp2 = fopen("file2","br+"))==0)
{
	fp2 = fopen("file2","bw+");
	fclose(fp2);
	}     
if((fp3 = fopen("file3","br+"))==0)
{
	fp3 = fopen("file3","bw+");
	fclose(fp3);
	}
fp1 = fopen("file1","br+");
fp2 = fopen("file2","br+");
fp3 = fopen("file3","br+");
setbuf(fp1,NULL);
setbuf(fp2,NULL);
setbuf(fp3,NULL);

	rsrc_gaddr(R_TREE,TREE10,&tree);/* main menu tree*/
	hndl_dialog(tree); /* Call routine to handle the dialog entry. */

	 get(fp1,&old,0);
fflush(stdout);
	
	/*
		Get the date and time with the long word of the time data structure.
	*/
	mytime.realtime = Gettime();

 			day = mytime.part.day;
			month = mytime.part.month;
			year = mytime.part.year + 80;

	  if ( old.curmth != month )
	  {
	 		 cmth = FALSE;
	 		 old.curmth = month;
	  }
	  else
	  		cmth = TRUE;

		crec = old.chk_rec ;
		srec = old.std_rec ;
	passw();

	pasok = strcmp(old.n_password,password);


		if (pasok != 0)
	{	

	form_alert(1, "[3][Incorrect Password| Access Denied !! ][OK]");


	good_by();
		}
		
		
		
			for ( i = 1; i <= srec-1 ; i++)
			{
			if((x =  get3(fp3,&sords,i)) == EOF )
	form_alert(1, "[2][Error in reading record ][OK]");

fflush(stdin);

		 			if ( sords.number != 0 )
				{
						if ( cmth == FALSE )
						sords.d_flag = FALSE;
			if ( day >= sords.date && sords.d_flag == FALSE)
					{
					old.balance = (old.balance - sords.amts);
	               	sords.d_flag = TRUE;
					
					
     				}
     		   }
   					if (( x = put3(fp3,&sords ,i )) != 0)
    			
 form_alert(1, "[2][Error in writing | standing order file ][OK]");
fflush(stdout);                        

			}



display();	
}

/*******************************************************/
display()
{
	int ende;
	long gemdos();
	int item,event;
long tree;
	rsrc_gaddr(R_TREE,TREE03,&tree);/* main menu tree*/
		form_center(tree, &xobj, &yobj, &wobj, &hobj);
	  	form_dial(0,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(1,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		objc_draw(tree, 0, MAX_DEPTH, 0,0, wdesk, hdesk);
	
		 
		while (ende != TRUE)
			{
			event = evnt_button(1,1,1,&mx,&my,&dummy,&dummy);
 
		item = objc_find (tree,0,20,mx,my);
			
			switch(item){
		
		case  AM1:	
		
		objc_change(tree,AM1,0,xwork,ywork,wwork,hwork,SELECTED,1);
				ende = TRUE;
		objc_change(tree,AM1,0,xwork,ywork,wwork,hwork,NORMAL,1);
	  	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
				stand_ord();
				
			break;
			
			case  AM2:	
		objc_change(tree,AM2,0,xwork,ywork,wwork,hwork,SELECTED,1);
				ende = TRUE;
		objc_change(tree,AM2,0,xwork,ywork,wwork,hwork,NORMAL,1);
			
	  	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
	
				cheque_inp();
					break;
			
			case AM3:
	objc_change(tree,AM3,0,xwork,ywork,wwork,hwork,SELECTED,1);
	
				ende = TRUE;
	objc_change(tree,AM3,0,xwork,ywork,wwork,hwork,NORMAL,1);				
	  	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		clear_cheque();
					break;
			
			case AM4:
		objc_change(tree,AM4,0,xwork,ywork,wwork,hwork,SELECTED,1);
				ende = TRUE;
		objc_change(tree,AM4,0,xwork,ywork,wwork,hwork,NORMAL,1);
	  	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		credits();
					break;
					
			case AM5:
		objc_change(tree,AM5,0,xwork,ywork,wwork,hwork,SELECTED,1);
				ende = TRUE;
		objc_change(tree,AM5,0,xwork,ywork,wwork,hwork,NORMAL,1);
	  	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		delete_so();		
					break;

			case AM6:
		objc_change(tree,AM6,0,xwork,ywork,wwork,hwork,SELECTED,1);
				ende = TRUE;
		objc_change(tree,AM6,0,xwork,ywork,wwork,hwork,NORMAL,1);
	  	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		fflush(stdin);
		print_cheque();
					break;
			
			case AM7:
		objc_change(tree,AM7,0,xwork,ywork,wwork,hwork,SELECTED,1);
				ende = TRUE;
		objc_change(tree,AM7,0,xwork,ywork,wwork,hwork,NORMAL,1);
	  	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		new_pass();
					break;
			
			case AM8:
		objc_change(tree,AM8,0,xwork,ywork,wwork,hwork,SELECTED,1);
				ende = TRUE;
		objc_change(tree,AM8,0,xwork,ywork,wwork,hwork,NORMAL,1);
	  	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		fflush(stdout);
		good_by();
					break;

					}
		} /* end for while*/			
}
/****************************************************************/
	/*     standing order setup  */
/****************************************************************/
stand_ord()
{
int x;
char dummy1[10], dummy2[3], dummy3[20], dummy4[10];
OBJECT *tree;
	rsrc_gaddr(0, TREE05, &tree); /* get address of dialog tree */
	sords.date = 0 ; /* set date to default */
		sprintf(dummy1,"%d",srec);
	  dummy2[0] = '\0'; /* initial position for cursor */
	
    /*  Make the TEDINFO string pointer point to your input array.*/
	((TEDINFO *)tree[SO2].ob_spec)->te_ptext = dummy2;
	((TEDINFO *)tree[SO2].ob_spec)->te_txtlen = 3;

	  dummy3[0] = '\0';
	((TEDINFO *)tree[SO3].ob_spec)->te_ptext = dummy3;
	((TEDINFO *)tree[SO3].ob_spec)->te_txtlen = 19;
	  dummy4[0] = '\0';
	((TEDINFO *)tree[SO4].ob_spec)->te_ptext = dummy4;
	((TEDINFO *)tree[SO4].ob_spec)->te_txtlen = 9;
	tree[SO1].ob_spec = dummy1;
	objc_change(tree,EXI,0,xwork,ywork,wwork,hwork,NORMAL,0);
	hndl_dialog(tree); /* Call routine to handle the dialog entry. */

	sscanf(dummy2,"%d",&sords.date);
	sprintf(sords.payee,"%s",dummy3);
	sscanf(dummy4,"%f",&sords.amts);	

if(sords.date == 0)
	{
	fflush(stdout);
	display();
	}

	sords.number = srec;
	 put3(fp3,&sords,srec );

		
			srec++;
			old.std_rec = srec;
		    if (( x = put(fp1,&old,0)) != 0)
	form_alert(1, "[2][Error in writing | info record ][OK]"); 
fflush(stdout);
	

display();
}
/****************************************************************/
	/*     cheque input      */
/****************************************************************/		
cheque_inp()
{
int x ;
OBJECT *tree;
int test; /* test for valid cheque */
char dummy1[10],dummy2[20],dummy3[10],dummy4[10];

	cheque.chk_number = 0 ; /* set default for cheque number */
	cheque.chk_amount = 0 ; /* set default for ammount */
	sprintf(dummy4,"%6.2f",old.balance);/*in memory type convert*/
	rsrc_gaddr(0, TREE00, &tree); /* get address of dialog tree */

    dummy1[0] = '\0'; /* initial position for cursor */

    /*  Make the TEDINFO string pointer point to your input array.*/
	((TEDINFO *)tree[CHKNUM].ob_spec)->te_ptext = dummy1;
	((TEDINFO *)tree[CHKNUM].ob_spec)->te_txtlen = 9;
	  dummy2[0] = '\0';
	((TEDINFO *)tree[CHKPAY].ob_spec)->te_ptext = dummy2;
	((TEDINFO *)tree[CHKPAY].ob_spec)->te_txtlen = 19;
	  dummy3[0] = '\0';
	((TEDINFO *)tree[CHKAMT].ob_spec)->te_ptext = dummy3;
	((TEDINFO *)tree[CHKAMT].ob_spec)->te_txtlen = 9;
	tree[CURBAL].ob_spec = dummy4;
	objc_change(tree,OK,0,xwork,ywork,wwork,hwork,NORMAL,0);
	hndl_dialog(tree); /* Call routine to handle the dialog entry. */
		
	test = 0;
	sscanf(dummy1,"%f",&cheque.chk_number);
	sprintf(cheque.payee,"%s",dummy2);
	sscanf(dummy3,"%f",&cheque.chk_amount);
	sscanf(dummy1,"%d",&test);

	if (test == 0 ) /* test for valid cheque input */
	{
	fflush(stdout);
	fflush(stdin);
	
	display();
	}
cheque.chk_cleared = 1;		
	old.chk_rec = crec;    /* update record number */
	old.balance = (old.balance - cheque.chk_amount);

	 put2(fp2,&cheque,crec );

  crec++;
	old.chk_rec = crec;
		  if (( x = put(fp1,&old,0)) != 0);


fflush(stdout);	
display();

}
/****************************************************************/
	/*     clear cheques      */
/****************************************************************/	
clear_cheque()
{
int x;
char dummy1[10];
char dummy2[10];
int recnum,loop,item,event,i;
OBJECT *tree;

	rsrc_gaddr(0, TREE02, &tree); /* get address of dialog tree */
	
		form_center(tree, &xobj, &yobj, &wobj, &hobj);
	  	form_dial(0,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(1,  1,1,1,1 ,xobj, yobj, wobj, hobj);
	
 
	recnum = crec ;
	for ( loop = 1 ; loop <= ( recnum-1 ) ; loop++)
	{	

		  get2(fp2,&cheque,loop);

	if (cheque.chk_cleared != 0 )
  
					{
		sprintf(dummy1,"%6.0f",cheque.chk_number);/*in memory type convert*/
		sprintf(dummy2,"%6.2f",cheque.chk_amount);
		tree[CCHKNUM].ob_spec = dummy1;
		tree[CCHKPAY].ob_spec = cheque.payee;	
		tree[CCHKAMT].ob_spec = dummy2;
 		objc_draw(tree, 0, MAX_DEPTH, 0,0, wdesk, hdesk);
	 	event = evnt_button(1,1,1,&mx,&my,&dummy,&dummy);
		item = objc_find (tree,0,MAX_DEPTH,mx,my);
			
		objc_change(tree,CLEAR,0,xwork,ywork,wwork,hwork,SELECTED,1);
		objc_change(tree,CLEAR,0,xwork,ywork,wwork,hwork,NORMAL,1);
	    objc_change(tree,UCLEAR,0,xwork,ywork,wwork,hwork,SELECTED,1);
		objc_change(tree,UCLEAR,0,xwork,ywork,wwork,hwork,NORMAL,1);
	
		if ( item == 8)
	cheque.chk_cleared = 0;
	else
	cheque.chk_cleared = 1;
	put2(fp2,&cheque,loop );	
		}
		}
		form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);	 
          
	fflush(stdin);
	display();
	}

/****************************************************************/
	/*   print cheques        */
/****************************************************************/	
print_cheque()
{
int ende,item,event,x;
OBJECT *tree;
ende = FALSE;
	x = Cprnos();
	if (x == 0)
	{
form_alert(1, "[3][Your printer is not | Online please TURN ON !  ][OK]");

	fflush(stdout);
display();
	}
pr = fopen ("PRT:","w");
 setbuf(pr,NULL); 
	rsrc_gaddr(0, TREE04, &tree); /* get address of dialog tree */
		form_center(tree, &xobj, &yobj, &wobj, &hobj);
	  	form_dial(0,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(1,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		objc_draw(tree, 0, MAX_DEPTH, 0,0, wdesk, hdesk);
 
 			while (ende != TRUE)
		{	
		 	event = evnt_button(1,1,1,&mx,&my,&dummy,&dummy);
			item = objc_find (tree,0,MAX_DEPTH,mx,my);
			
			switch(item)
			{
			case PT1:
		objc_change(tree,PT1,0,xwork,ywork,wwork,hwork,SELECTED,1);
		objc_change(tree,PT1,0,xwork,ywork,wwork,hwork,NORMAL,1);
		ende = TRUE;
		form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);	 
		do_p_one();
			break;
			
			case PT2:
			
		objc_change(tree,PT2,0,xwork,ywork,wwork,hwork,SELECTED,1);	
		objc_change(tree,PT2,0,xwork,ywork,wwork,hwork,NORMAL,1);
	 	ende = TRUE;
	 	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		do_p_two();
			break;
			case PT3:
			
		objc_change(tree,PT3,0,xwork,ywork,wwork,hwork,SELECTED,1);	
		objc_change(tree,PT3,0,xwork,ywork,wwork,hwork,NORMAL,1);
	 	ende = TRUE;
	 	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		do_p_three();
			break;
			case RET:
			
		objc_change(tree,RET,0,xwork,ywork,wwork,hwork,SELECTED,1);	
		objc_change(tree,RET,0,xwork,ywork,wwork,hwork,NORMAL,1);
	 	ende = TRUE;
	 	form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);

			break;
			}
		}
	fflush(stdout);
display();

}
/*****************************************************************/
				/* print out 1*/
/*****************************************************************/				
do_p_one()
{

int recnum ;
int loop;
int c;
int x ;

     		
	recnum = crec;
	fprintf(pr,"\t\t CHEQUES ISSUED as of");
		fprintf(pr," %d/%d/%d\n",day,month,year);					
	fprintf(pr,"\nRecord\t\tNumber\t\t Amount\t\tPayee");
fprintf(pr,"\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");

		for (loop = 1 ; loop <= (recnum-1) ; loop++)
		{
				 get2(fp2,&cheque,loop);
	
	fprintf(pr," %d",loop);	
	fprintf(pr,"\t\t%6.0f",cheque.chk_number);
	fprintf(pr,"\t\tœ%6.2f",cheque.chk_amount);
	fprintf(pr,"\t\t%s\n",cheque.payee);
		}
	fprintf(pr,"\t Balance to date :%6.2f",old.balance);
	fflush(pr);

display();
}
/****************************************************************/
       /*          print out 2         */
/****************************************************************/
do_p_two()
{
		
int x ;
int c ;
int loop ;
int recnum ;

	fprintf(pr,"\n\n\n\t\t         UNCLEARED ITEMS");
	fprintf(pr,"\n\t\t         ~~~~~~~~~~~~~~~");
	fprintf(pr,"\n\tUncleared up to %d/%d/%d",day,month,year);

	fprintf(pr,"\n\n\n\n\t\tNumber\t\t Amount\t\tPayee");
	fprintf(pr,"\n\t\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
		
	recnum = crec ;
	for ( loop = 1 ; loop <= ( recnum-1 ) ; loop++)
	{	


		 get2(fp2,&cheque,loop);


	if (cheque.chk_cleared != 0 )
  
					{

	fprintf(pr,"\t\t%6.0f",cheque.chk_number);
	fprintf(pr,"\t\tœ%6.2f",cheque.chk_amount);
	fprintf(pr,"\t\t%s\n",cheque.payee);
					}
					fflush(pr);
	}
	


display();
}
/****************************************************************/
       /*          print out 3         */
/****************************************************************/
do_p_three()
{


int x ;
int c ;
int loop ;
int recnum ;

		fprintf(pr,"\n\t\t STANDING ORDERS");
		fprintf(pr,"\n\t\t ~~~~~~~~~~~~~~~~");
		fprintf(pr,"\n\tActive as of %d/%d/%d\n",day,month,year);

		for (loop = 1 ; loop <= srec-1; loop++)
		{
	
			
		 get3(fp3,&sords,loop);
	
		fflush(stdout);
			if (sords.number != 0 )
			{
    fprintf(pr,"\n     Current record number : %d",loop);
	fprintf(pr,"\n     Standing order number  : %d",sords.number);
	fprintf(pr,"\n     Standing order date    : %d",sords.date);
	fprintf(pr,"\n     Recipient of order     : %s",sords.payee);
	fprintf(pr,"\n     Standing order amount œ %6.2f\n\n",sords.amts);
			}
		}
fflush(pr);	

display();
}
/****************************************************************/
	/*   debit credit        */
/****************************************************************/
credits()
{
OBJECT *tree;
float credit,debit = 0.0;
char dummy1[10],dummy2[10],dummy3[10];
int x;

	rsrc_gaddr(0, TREE06, &tree); /* get address of dialog tree */

	  dummy1[0] = '\0';
	sprintf(dummy3,"%6.2f",old.balance);
	((TEDINFO *)tree[CRED].ob_spec)->te_ptext = dummy1;
	((TEDINFO *)tree[CRED].ob_spec)->te_txtlen = 9;
	  dummy2[0] = '\0';
	((TEDINFO *)tree[DEBI].ob_spec)->te_ptext = dummy2;
	((TEDINFO *)tree[DEBI].ob_spec)->te_txtlen = 9;
	tree[DBAL].ob_spec = dummy3;			
	hndl_dialog(tree); /* Call routine to handle the dialog entry. */
	objc_change(tree,EX,0,xwork,ywork,wwork,hwork,NORMAL,0);
	sscanf(dummy1,"%f",&credit);
	sscanf(dummy2,"%f",&debit);

 	old.balance = ( old.balance + credit );
 	old.balance = ( old.balance - debit );
	
 		    if (( x = put(fp1,&old,10)) != 0)
	form_alert(1, "[2][Error in writing | info record ][OK]"); 
fflush(stdout);

display();

}
/****************************************************************/
	/*    delete s/o       */
/****************************************************************/	
delete_so()
{
char dummy1[10],dummy2[20],dummy3[10];
int recnum;
int item;
int event;
int n;
OBJECT *tree;
	rsrc_gaddr(0, TREE07, &tree); /* get address of dialog tree */
		form_center(tree, &xobj, &yobj, &wobj, &hobj);
	  	form_dial(0,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(1,  1,1,1,1 ,xobj, yobj, wobj, hobj);
		for(n = 1; n <= (srec-1);n++)
		{
		get3(fp3,&sords,n);
		 get(fp1,&old,0);
	
	
		if (sords.number != 0 )
				{

		sprintf(dummy1,"%d",sords.number);
		sprintf(dummy2,"%s",sords.payee);
		sprintf(dummy3,"%6.2f",sords.amts);	
	tree[SNUM].ob_spec = dummy1;
	tree[SPAYEE].ob_spec = dummy2;
	tree[SAMOUNT].ob_spec = dummy3;
		objc_draw(tree, 0, MAX_DEPTH, 0,0, wdesk, hdesk);
	 	event = evnt_button(1,1,1,&mx,&my,&dummy,&dummy);
		item = objc_find (tree,0,MAX_DEPTH,mx,my);
			
		objc_change(tree,SOK,0,xwork,ywork,wwork,hwork,SELECTED,1);
		objc_change(tree,SOK,0,xwork,ywork,wwork,hwork,NORMAL,1);
	    objc_change(tree,SCANCEL,0,xwork,ywork,wwork,hwork,SELECTED,1);
		objc_change(tree,SCANCEL,0,xwork,ywork,wwork,hwork,NORMAL,1);
		form_dial(2,  0,0,0,0,xobj, yobj, wobj, hobj);
		form_dial(3,  1,1,1,1 ,xobj, yobj, wobj, hobj);
	if ( item == 5)
	sords.number = 0 ;
	
		put3(fp3,&sords,n);
	
}
}
fflush(stdout);
display();

}
/*******************************************************************/
/* NEW PASS*/
/******************************************************************/
new_pass()
{
char dummy1[10];
char crypt[10];
int i ;
OBJECT *tree;


rsrc_gaddr(0, TREE08, &tree); /* get address of dialog tree */

	 dummy1[0] = '\0';
	 
	((TEDINFO *)tree[NPASS].ob_spec)->te_ptext = dummy1;
	((TEDINFO *)tree[NPASS].ob_spec)->te_txtlen = 6;
	hndl_dialog(tree); /* Call routine to handle the dialog entry. */
	       
   objc_change(tree,OUT,0,xwork,ywork,wwork,hwork,NORMAL,0);
	strncpy(old.n_password,dummy1,5);
          
          put(fp1,&old,0);
fflush(stdout);
	display();
}

/*******************************************************************/
/* good bye*/
/******************************************************************/
good_by()
{
	
	appl_exit();
	fclose(fp1);
	fclose(fp2);
	fclose(fp3);
	v_clsvwk(handle);
	exit();
	}

/*******************************************************************/
/* good bye1 without closing files */
/******************************************************************/
good_by1()
{
	
	appl_exit();
	v_clsvwk(handle);
	exit();
	}

/****************************************************************/
/* open virtual workstation					*/
/****************************************************************/
open_work()
{
int i;
	handle = phys_handle;
	for ( i = 0 ; i < 10; work_in[i++] = 1 );
	work_in[10] = 2 ;
	v_opnvwk(work_in,&handle,work_out);

}


/**********************************************************************/
		/*GET PASSWORD  */
/**********************************************************************/	


passw()    /* get password */
{

OBJECT *tree;

	rsrc_gaddr(0, TREE09, &tree); /* get address of dialog tree */

    password[0] = '\0'; /* initial position for cursor */
    /*  Make the TEDINFO string pointer point to your input array.*/
	((TEDINFO *)tree[PASSIN].ob_spec)->te_ptext = password;
	((TEDINFO *)tree[PASSIN].ob_spec)->te_txtlen = 6;
 	hndl_dialog(tree); /* Call routine to handle the dialog entry. */
 	fflush(stdout);



 } 
/**********************************************************************/
 		/*  WRITE RANDOM RECORD */
/*********************************************************************/	

put(fp1,recrd,num) 

FILE *fp1;
struct info *recrd;
int num;
{

long strec ;
int code,rlen,i ;

rlen = sizeof *recrd;
strec = num * rlen ;
if (( code = fseek(fp1,strec,0)) != NULL) {
   if (( code = fseek(fp1,0L,2)) != NULL)
   	return(-1);
   		while ((code = fseek(fp1,strec,0)) != NULL)
   			for (i = 0 ; i < rlen ; i++ )
   				fputc('\0',fp1);
   				}
   		if (( code = fwrite(recrd,rlen,1,fp1)) == 1)
   			return(0);
   			else
   			return(1);	
}
/**********************************************************************/
		/* READ RANDOM RECORD */
/**********************************************************************/	

get(fp1,recrd,num) /* read random record */

FILE *fp1;
struct info *recrd ;
int num;
{
long strec ;
int code,rlen,i ;

rlen = sizeof *recrd ;
strec = num * rlen ;
if ((code = fseek(fp1,strec,0)) != NULL)
	return (EOF) ;
if ((code = fread(recrd,rlen,1,fp1)) == 1)

	return (0);
else 
	
		return(1);
}
 /**********************************************************************/
 		/*  WRITE RANDOM RECORD  2 */
/*********************************************************************/	

put2(fp2,recrd,num) 

FILE *fp2;
struct record  *recrd;
int num;
{
long strec ;
int code,rlen,i ;

rlen = sizeof *recrd;
strec = num * rlen ;

if (( code = fseek(fp2,strec,0)) != NULL) {
   if (( code = fseek(fp2,0L,2)) != NULL)
   	return(-1);
   		while ((code = fseek(fp2,strec,0)) != NULL)
   			for (i = 0 ; i < rlen ; i++ )
   				fputc('\0',fp2);
   				}
   		if (( code = fwrite(recrd,rlen,1,fp2)) == 1)
   			return(0);
   			else
   			return(1);	
}
/**********************************************************************/
		/* READ RANDOM RECORD  2 */
/**********************************************************************/	

get2(fp2,recrd,num) /* read random record */
FILE *fp2;

struct record *recrd ;
int num ;
{
	long strec ;
	int code,rlen,i ;

	rlen = sizeof *recrd ;
	strec = num * rlen ;

 	if ((code = fseek(fp2,strec,0)) != NULL)
	return (EOF) ;
 
	if ((code = fread(recrd,rlen,1,fp2)) == 1)
		
				return (0);
	else 
		form_alert(1, "[2][Error in reading info record ][OK]");
return(1);
}
/**********************************************************************/
 		/*  WRITE RANDOM RECORD 3 */
/*********************************************************************/	

put3(fp3,recrd,num) 

FILE *fp3;
struct stand *recrd;
int num;
{

long strec ;
int code,rlen,i ;


rlen = sizeof *recrd;
strec = num * rlen ;
if (( code = fseek(fp3,strec,0)) != NULL) {
   if (( code = fseek(fp3,0L,2)) != NULL)
   	return(-1);
   		while ((code = fseek(fp3,strec,0)) != NULL)
   			for (i = 0 ; i < rlen ; i++ )
   				fputc('\0',fp3);
   				}
   		if (( code = fwrite(recrd,rlen,1,fp3)) == 1)
   			return(0);
   			else
   			return(1);	
}
/**********************************************************************/
		/* READ RANDOM RECORD 3 */
/**********************************************************************/	

get3(fp3,recrd,num) /* read random record */

FILE *fp3;
struct stand *recrd ;
int num;
{
long strec ;
int code,rlen,i ;

rlen = sizeof *recrd ;
strec = num * rlen ;
if ((code = fseek(fp3,strec,0)) != NULL)
	return (EOF) ;
if ((code = fread(recrd,rlen,1,fp3)) == 1)
{

	return (0);}
else 
		form_alert(1, "[2][Error in reading info record ][OK]");
return(1);
}


/******************************************************************/
/*handle diolgue box*/
/******************************************************************/
hndl_dialog(tree)
OBJECT *tree;
{
	int cx, cy, cw, ch;

    /* Last four coordinates are calculated so that when displayed
       the dialog appears in the center of the screen. */

	form_center(tree, &cx, &cy, &cw, &ch);
    /* Initialise AES to prepare it for a dialog. */
   	form_dial(0,  0,0,0,0,cx, cy, cw, ch);
	form_dial(1,  0,0,0,0,cx, cy, cw, ch);
    /* Draw the dialog. */
	objc_draw(tree, ROOT, MAX_DEPTH, cx, cy, cw, ch);
    /* Form_do will not return until the exit button is selected. */
	form_do(tree, 0);  /*  editable field */
    /* Tell the AES to redraw the screen area behind dialog */
	form_dial(2,  0,0,0,0,cx, cy, cw, ch);
	form_dial(3,  0,0,0,0,cx, cy, cw, ch);
}

