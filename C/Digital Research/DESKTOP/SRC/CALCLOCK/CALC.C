/*	CALC.C		08/03/84 - 06/20/85	Andrew Muir		*/

/*** INCLUDE FILES ******************************************************/

#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#endif
#include "taddr.h"
#include "calc.h"

/*** DEFINES ***********************************************************/

/*** GLOBAL VARIABLES ***************************************************/

EXTERN WORD	gl_apid;
EXTERN WORD	gl_handle;

EXTERN WORD color;

GLOBAL LONG	ad_calc;
GLOBAL WORD	wh_calc;
GLOBAL WORD	gl_itcalc;

GLOBAL BYTE	*gl_disp;
GLOBAL WORD	equal_clr;	/* NEW LINE 1/29 */
WORD		last_op, last_key;
BYTE		inp_str[DISP_LEN+1], inp_idx;

WORD		last_calc;
WORD		not_zero;

BYTE	stack_num;
BYTE	dec_pt1,dec_pt2;
UBYTE	neg1,neg2;
BYTE	num_dig;
WORD	add_on;
BYTE	stack_pt;
BYTE	pt_seen,eror;
UBYTE	op1[10],op2[10],result[10],memory[10];
BYTE	temp_pt;
LONG    MEMEMPTY;
LONG    MEMFULL;


VOID zero_res(VOID);
VOID zero_clr(VOID);


/*
*	Initializes the calculator. Assigns the ted infos to the proper
*	objects	and the strings to the proper ted infos.
*/
LONG ini_calc(VOID)
{
	LONG		tree;
	WORD		i, j;

	tree = (LONG)ADDR(&the_calc[0]);
	gl_disp = the_str[0];

	j = 0;			  
    MEMEMPTY = 0x20001106L;
    MEMFULL =  0x6d001106L;
	for (i=0; i<NUM_OBS; i++)
	{
		rsrc_obfix((OBJECT FAR *)tree, i);
		if (the_calc[i].ob_type == G_BOXTEXT)
		{
#if TURBO_C
			the_calc[i].ob_spec.tedinfo = ADDR(&the_ted[j]);
#else
			the_calc[i].ob_spec = ADDR(&the_ted[j]);
#endif
			the_ted[j].te_ptext = ADDR(the_str[j]);
			j++;
		}
	}
	/* If the current system has more   */
	/* than two colors, change the color*/
	/* and the fill pattern to take ad- */
	/* vantage of that fact		    */
	if (color == 2)
	{
		MEMEMPTY = 0x20001170L;
		MEMFULL  = 0x6d001170L;
#if TURBO_C
		the_calc[0].ob_spec.index = 0x00fd1272L;
		the_calc[3].ob_spec.index = 0x43ff1173L;
		the_calc[5].ob_spec.index = 0x2aff1173L;
		the_calc[7].ob_spec.index = 0x37ff1170L;
		the_calc[8].ob_spec.index = 0x38ff1170L;
		the_calc[9].ob_spec.index = 0x39ff1170L;
		the_calc[10].ob_spec.index = 0x2fff1173L;
		the_calc[12].ob_spec.index = 0x34ff1170L;
		the_calc[13].ob_spec.index = 0x35ff1170L;
		the_calc[14].ob_spec.index = 0x36ff1170L;
		the_calc[15].ob_spec.index = 0x2bff1173L;
		the_calc[17].ob_spec.index = 0x31ff1170L;
		the_calc[18].ob_spec.index = 0x32ff1170L;
		the_calc[19].ob_spec.index = 0x33ff1170L;
		the_calc[20].ob_spec.index = 0x2dff1173L;
		the_calc[22].ob_spec.index = 0x30ff1170L;
		the_calc[23].ob_spec.index = 0x2eff1173L;
		the_calc[24].ob_spec.index = 0x25ff1173L;
		the_calc[25].ob_spec.index = 0x20001170L;
		the_calc[26].ob_spec.index = 0x20001170L;
		the_calc[27].ob_spec.index = 0x3dff1173L;
#else
		the_calc[0].ob_spec = 0x00fd1272L;
		the_calc[3].ob_spec = 0x43ff1173L;
		the_calc[5].ob_spec = 0x2aff1173L;
		the_calc[7].ob_spec = 0x37ff1170L;
		the_calc[8].ob_spec = 0x38ff1170L;
		the_calc[9].ob_spec = 0x39ff1170L;
		the_calc[10].ob_spec = 0x2fff1173L;
		the_calc[12].ob_spec = 0x34ff1170L;
		the_calc[13].ob_spec = 0x35ff1170L;
		the_calc[14].ob_spec = 0x36ff1170L;
		the_calc[15].ob_spec = 0x2bff1173L;
		the_calc[17].ob_spec = 0x31ff1170L;
		the_calc[18].ob_spec = 0x32ff1170L;
		the_calc[19].ob_spec = 0x33ff1170L;
		the_calc[20].ob_spec = 0x2dff1173L;
		the_calc[22].ob_spec = 0x30ff1170L;
		the_calc[23].ob_spec = 0x2eff1173L;
		the_calc[24].ob_spec = 0x25ff1173L;
		the_calc[25].ob_spec = 0x20001170L;
		the_calc[26].ob_spec = 0x20001170L;
		the_calc[27].ob_spec = 0x3dff1173L;
#endif
		the_ted[0].te_color = 0x1170;
		the_ted[1].te_color = 0x1173;
		the_ted[2].te_color = 0x1173;
		the_ted[3].te_color = 0x1173;
		the_ted[4].te_color = 0x1173;
		the_ted[5].te_color = 0x1173;
		the_ted[6].te_color = 0x1173;
	}  
	if (color >= 3)
	{
		MEMEMPTY = 0x20001176L;
		MEMFULL  = 0x6d001176L;
#if TURBO_C
		the_calc[0].ob_spec.index = 0x00fd1274L;
		the_calc[3].ob_spec.index = 0x43ff1175L;
		the_calc[5].ob_spec.index = 0x2aff1175L;
		the_calc[7].ob_spec.index = 0x37ff1170L;
		the_calc[8].ob_spec.index = 0x38ff1170L;
		the_calc[9].ob_spec.index = 0x39ff1170L;
		the_calc[10].ob_spec.index = 0x2fff1175L;
		the_calc[12].ob_spec.index = 0x34ff1170L;
		the_calc[13].ob_spec.index = 0x35ff1170L;
		the_calc[14].ob_spec.index = 0x36ff1170L;
		the_calc[15].ob_spec.index = 0x2bff1175L;
		the_calc[17].ob_spec.index = 0x31ff1170L;
		the_calc[18].ob_spec.index = 0x32ff1170L;
		the_calc[19].ob_spec.index = 0x33ff1170L;
		the_calc[20].ob_spec.index = 0x2dff1175L;
		the_calc[22].ob_spec.index = 0x30ff1170L;
		the_calc[23].ob_spec.index = 0x2eff1175L;
		the_calc[24].ob_spec.index = 0x25ff1175L;
		the_calc[25].ob_spec.index = 0x20001176L;
		the_calc[26].ob_spec.index = 0x20001176L;
		the_calc[27].ob_spec.index = 0x3dff1175L;
#else
		the_calc[0].ob_spec = 0x00fd1274L;
		the_calc[3].ob_spec = 0x43ff1175L;
		the_calc[5].ob_spec = 0x2aff1175L;
		the_calc[7].ob_spec = 0x37ff1170L;
		the_calc[8].ob_spec = 0x38ff1170L;
		the_calc[9].ob_spec = 0x39ff1170L;
		the_calc[10].ob_spec = 0x2fff1175L;
		the_calc[12].ob_spec = 0x34ff1170L;
		the_calc[13].ob_spec = 0x35ff1170L;
		the_calc[14].ob_spec = 0x36ff1170L;
		the_calc[15].ob_spec = 0x2bff1175L;
		the_calc[17].ob_spec = 0x31ff1170L;
		the_calc[18].ob_spec = 0x32ff1170L;
		the_calc[19].ob_spec = 0x33ff1170L;
		the_calc[20].ob_spec = 0x2dff1175L;
		the_calc[22].ob_spec = 0x30ff1170L;
		the_calc[23].ob_spec = 0x2eff1175L;
		the_calc[24].ob_spec = 0x25ff1175L;
		the_calc[25].ob_spec = 0x20001176L;
		the_calc[26].ob_spec = 0x20001176L;
		the_calc[27].ob_spec = 0x3dff1175L;
#endif
		the_ted[0].te_color = 0x1176;
		the_ted[1].te_color = 0x1175;
		the_ted[2].te_color = 0x1175;
		the_ted[3].te_color = 0x1175;
		the_ted[4].te_color = 0x1175;
		the_ted[5].te_color = 0x1175;
		the_ted[6].te_color = 0x1175;
	}  
	return(tree);
} /* ini_calc */


/*
*		Clears the calculator's display
*/
VOID clr_calc(VOID)
{
	WORD		ii;

	for(ii = 0; ii < DISP_LEN; inp_str[ii++] = ' ')
		;
	inp_str[DISP_LEN] = NULL;
	inp_idx = 0;
	inp_str[0] = '0';
} /* clr_calc */


VOID rjust(BYTE *pnumstr)
{
 	WORD		ii, jj;

	/* right-just display string	*/
 	jj = DISP_LEN;
	for (ii = jj; ii >= 0; ii--)
	{
		if (pnumstr[ii] != ' ')
		{
			gl_disp[jj] = pnumstr[ii];
			jj--;
		}
	}
	for (ii = jj; ii >= 0; gl_disp[ii--] = ' ')
		;
}


VOID calc_reset(VOID)
{
	WORD		ii;

	last_key = THECLR;
	not_zero = FALSE;
	last_calc = NUM;
	zero_res();
	gl_disp[0] = NULL;
	for(ii = 0;ii < 10;result[ii++] = NULL)
		;
	for(ii = 0;ii < 10;memory[ii++] = NULL)
		;
	rjust(&inp_str[0]);
}


/*
* 		Dispalys,on the calculator the string pointed to by
*		pnumstr.
*/
VOID display(BYTE *pnumstr)
{
	WORD		xdisp, ydisp;       

	/* right-just display string	*/
	rjust(pnumstr);
	objc_offset((OBJECT FAR *)ad_calc, THEDISP, &xdisp, &ydisp);
	do_redraw(wh_calc, THEDISP, 0, xdisp, ydisp,
		the_calc[THEDISP].ob_width,the_calc[THEDISP].ob_height); 
}


/*
*		Creates the error message.
*/
VOID dsply_err(VOID)
{	       
	clr_calc();
	strcpy("error", &inp_str[0]);
/*	stack_num = 1;*/
	stack_pt = 19;
	pt_seen = 0;	
}


/*		
*		Check for the overflow error.If the error occurs display
*		the error message.
*/
VOID over_err(VOID)
{
	if (num_dig > 13)
	{
		eror = TRUE;
		dsply_err();	  
	} 
}             


/*
*		Check for the divide by zero error. If the error occurs dis-
*		play the error message.
*/
VOID zero_err(VOID)
{
	BYTE		non_zero;
	WORD		ii;

	non_zero = FALSE;
   	if (last_op == DIVIDE)
    {
		for (ii = 1;ii < 10;ii++)
			if (op2[ii] != 0)
				non_zero = TRUE;
		if (!non_zero)
		{
			eror = TRUE;
			dsply_err();
		}					 
	}
}	


/*
*		Check for error conditions, and if none exist perform
*		the operation.
*/
VOID do_op(WORD oper)
{
	if (!eror)	
		zero_err();
    if (!eror) 
	{
		switch( oper )
		{	
	    	case PLUS:
				_FLD_ADD(result,op2,op1);
				break;
			case TIMES:			   
				_FLD_MUL(result,op2,op1);
				break;
			case MINUS:			   
				_FLD_SUB(result,op2,op1);
				break;
			case DIVIDE:
				_FLD_DIV(result,op2,op1);
				break;
		}
		if (result[0] == 0)
			result[0] = 63;
	}
}


/*
*		Take the parameter "number" and push it on one of the
*		operand stacks.Most significant digit in the first half
*		of the last byte. Second most significant in the second
*		half of the last byte.
*/
VOID push_bcd(BYTE number)
{
	UBYTE	tmp_num;

	tmp_num =  number - '0'; 
	if (stack_pt % 2)
		tmp_num = (tmp_num << 4) & 0xf0;
	if (stack_num == 0)
		op1[stack_pt/2] = (op1[stack_pt/2]) | tmp_num;
	else
		op2[stack_pt/2] = (op2[stack_pt/2]) | tmp_num;
	stack_pt--;
}			


/*
*	Clears out trailing zeroes.  If the last non-zero value is a
*	decimal point then it clears that out too.  If everything was
*	cleared out then it turns the whole display into a single zero.
*/
VOID clr_zero(VOID)
{      	    
	WORD		jj;
  
	jj = 14;
   	while (((inp_str[jj] == '0') ||
		(inp_str[jj] == ' ')) &&
		(jj >= temp_pt))
	{
		inp_str[jj--] = ' ';
	}
	if (inp_str[jj] == '.')
		inp_str[jj] = ' ';		
	if (inp_str[0] == ' ')
		clr_calc();
}


/*
*	Adds a leading minus sign to the display string.  This should only
*	be called if the sign of the display is negative
*/
VOID do_sign(VOID)
{	
	WORD		jj;

	for (jj = 12;jj >= 1;jj--)
		inp_str[jj + 1] = inp_str[jj];
	inp_str[1] = inp_str[0];	
	inp_str[0] = '-';	  
	temp_pt++;	
}	  


/*
*	Clears the calculators display string and draws a zero display.
*	Then takes the result of the last operation and converts it into 
*	a number that can be placed in the display string.
*/
VOID get_rslt(VOID)
{
	BYTE		num_temp;
	BYTE		temp;
	WORD		counter;
	WORD		ii;

	clr_calc();
	counter = 19;	
	if ((result[0] & 0x7f) < 63)
		temp_pt = (63 - (result[0] & 0x7f));
	else
		temp_pt = ((result[0] & 0x7f) - 63);
	for(ii = 0;ii < 13;ii++)
	{
		if (counter > 2)
		{	
			temp = result[counter/2];
			num_temp = counter << 7;
			counter-- ;
			if (num_temp)
				temp  = (temp & 0xf0) >> 4;
			else
				temp = temp & 0x0f;			   
			inp_str[ii] = temp + '0';
		}
	}
	/* if a fraction, then	*/
	/*   put in the right #	*/
	/*   of leading zeroes	*/
	if (((result[0] & 0x7f) <= 63) && 
		(!(((result[0] & 0x7f) == 63) && 
		(last_op == TIMES))))		   
	{
		if ( last_calc != RETMEM )
		{
			if (last_op == TIMES)
				temp_pt--;
			if (last_op == DIVIDE)
				temp_pt++;
		}
		temp_pt = (temp_pt > 14) ? 14 : temp_pt;
		for (ii = 14;ii >= temp_pt;ii--)
			inp_str[ii] = inp_str[ii - temp_pt];
		if (!((inp_str[0] == '0') && (inp_str[1] != '.')))
			for (ii = 0;ii < temp_pt;inp_str[ii++] = '0')
				;
		if ( last_calc != RETMEM )
		{ 
			if (last_op == TIMES)
				temp_pt++;
			if (last_op == DIVIDE)
				temp_pt--;
		}
	}
}


/*
*	Zero the calculator display string and other related globals
*/
VOID zero_res(VOID)
{
	  zero_clr();
	  stack_num = 0;
	  last_op = NOP;
	  eror = FALSE;
}


/*
*	Convert raw display string from last operation into a 
*	displayable string with a decimal point and a sign.
*/
VOID pop_bcd(VOID)
{
	WORD		ii;

	/* get raw display str.	*/
	get_rslt();
	/* special kludge for times and divide */
	if ((last_calc != RETMEM) && (last_calc != PERCENT))
	{	
		if (last_op == TIMES)
			temp_pt++;
		if ((last_op == DIVIDE) && (temp_pt != 0))
			temp_pt--;
	}
	/* insert decimal pt */
	temp_pt = ((result[0] & 0x7f) < 63) ? 0 : temp_pt;
	for (ii = 13;ii >= temp_pt;ii--)
		inp_str[ii + 1] = inp_str[ii];
	inp_str[temp_pt] = '.';
	/* insert minus sign	*/
	if ((result[0] & 0x7f) < 63) 
		temp_pt = 1;
	if (result[0] & 0x80)	     
		do_sign();
	/* clear trailing zeros	*/
	clr_zero();
/*	if ((inp_str[0] == '0') && (inp_str[1] != '.'))
	{
		last_calc = NOP;
		zero_res();
	}  */
}


/*
*		Changes the sign of the number in the display.
*/
VOID do_neg(VOID)
{
	WORD		ii;

	if (inp_str[0] != '0') 
    {
		if ((stack_num == 0) ||
			(last_calc == EQUAL) ||
			(last_calc == NOP))
		{
			/* Change the first operand. */
			if (last_calc == RETMEM)
			{
				/* Loads the contents of the memory */
				/* into the first operand.	    */

				for (ii = 0;ii < 10;op1[ii] = memory[ii++])
					;
				dec_pt1 = (op1[0] & 0x7f) - 64;
				neg1 = (memory[0] & 0x80);
				op1[0] = (op1[0] ^ 0x80);	
			}
			if (last_calc == EQUAL)
			{ 
				neg1 = (op1[0] & 0x80);	
				op1[0] = (op1[0] ^ 0x80);
			}
			neg1 = (neg1 ^ 0x80);
		}
		else
		{
			if (last_calc == RETMEM)
			{
				for (ii = 0;ii < 10;op2[ii] = memory[ii++])
					;
				dec_pt2 = (op2[0] & 0x7f) - 64;
				neg2 = (memory[0] & 0x80);
			}
			neg2 = (neg2 ^ 0x80);
			op2[0] = (op2[0] ^ 0x80);
		}
		if (last_calc != EQUAL)
			last_calc = NUM;
		if (inp_str[0] == '-')
		{ 
			inp_str[0] = inp_str[1];
			for (ii = 1;ii < 14;ii++)
				inp_str[ii] = inp_str[ii + 1];
		}
		else	       	  
			/* Display the sign of the number */
			/* in the display.		  */
			do_sign();
	}
	last_calc = (inp_str[0] == '0') ? NOP : PLUMIN; 
}


/*
*		Clears the last entry of the calculator.
*/
VOID clr_ent(WORD stk_num)
{
	WORD		ii;

	/* Set the display to "0" */
	clr_calc();
	num_dig = 0;
	pt_seen = 0;
	stack_pt = 19;
	add_on = 64;
	/* Clear the first operand, and reset the flags. */
	if (stk_num == 0)
	{
		dec_pt1 = 64;
		neg1 = 0;
		for (ii = 0; ii < 10;op1[ii++] = 0)
			;
	}
	else
	{
		dec_pt2 = 64;	
		neg2 = 0;
		for (ii = 0; ii < 10;op2[ii++] = 0)
			;
	}
}


/*
*		Clear the contents of the memory and clear the displays
*		memory flag.
*/
VOID clr_mem(VOID)
{
	WORD		ii;

	for (ii=1; ii < 10; memory[ii++] = 0)
		;
	memory[0] = 0;			/* NEW LINE 1/29 */
#if TURBO_C
	the_calc[MEMFLG].ob_spec.index = MEMEMPTY;
#else
	the_calc[MEMFLG].ob_spec = MEMEMPTY;
#endif
	/* Draw the memory flag */
	objc_draw((OBJECT FAR *)ad_calc, MEMFLG , 0,
		the_calc[MEMFLG].ob_x + the_calc[ROOT].ob_x,
		the_calc[MEMFLG].ob_y + the_calc[ROOT].ob_y,
		the_calc[MEMFLG].ob_width,the_calc[MEMFLG].ob_height);
}


/*
*		Display the contents of the memory.
*/
VOID ret_mem(VOID)
{
	WORD		ii;

	for (ii=0; ii < 10; result[ii] = memory[ii++])
		;
	last_calc = RETMEM;
	pop_bcd(); 
	inp_idx = 0;
	num_dig = 0;
}


/*
*		Transfers the results of all arithmatic involving the
*		memory from the result stack to the memory. As well as
*		setting the displays memory flag.
*/
VOID mem_op(VOID)
{
	WORD		ii;

    for (ii = 0;ii < 10;memory[ii] = result[ii++])
    	;
	if ( last_calc != NOP )		/* NEW LINE 3/3/86 */
		last_calc = EQUAL;
#if TURBO_C
	the_calc[MEMFLG].ob_spec.index = MEMFULL;
#else
	the_calc[MEMFLG].ob_spec = MEMFULL;
#endif
	objc_draw((OBJECT FAR *)ad_calc, MEMFLG , 0,
		the_calc[MEMFLG].ob_x + the_calc[ROOT].ob_x,
		the_calc[MEMFLG].ob_y + the_calc[ROOT].ob_y,
		the_calc[MEMFLG].ob_width,the_calc[MEMFLG].ob_height);
}


/*
*		Adds the value shown in the display to the memory.
*/
VOID mem_plus(VOID)
{
	WORD		ii;

   	if (((stack_num == 0) || (last_calc == EQUAL) || ( last_calc == NOP )) || 
		((stack_num == 1) && (last_calc == PLUMIN)))
	{  	
		if (dec_pt1 == 64)
			dec_pt1 = num_dig - 1;
		if (last_calc == PLUMIN)
		{
			if (last_op == DIVIDE)
				op1[0]--;
			if ((last_op == TIMES) || (last_op == PLUS))
				op1[0]++;
		}
		if ((last_calc == PLUMIN) && (op1[0] == 0))
			op1[0] = (64 + dec_pt1) | neg1;
		if ((last_calc != EQUAL) && (last_calc != PLUMIN) &&
			( last_calc != NOP ))
		{
			op1[0] = (64 + dec_pt1) | neg1;
		}
		dec_pt1 =64;
		if (last_calc == RETMEM)
			for (ii = 0;ii < 10;op1[ii] = memory[ii++])
				;
		_FLD_ADD(result,op1,memory);
	}
    else
	{
		if (dec_pt2 == 64)
			dec_pt2 = num_dig - 1;
		op2[0] = (64 + dec_pt2) | neg2;
		dec_pt2 = 64;	
		if (last_calc == RETMEM)
			for (ii = 0; ii < 10;op2[ii] = memory[ii++])
				;
		_FLD_ADD(result,op2,memory);
	}	  
	mem_op(); 
}


/*
*		Subtracts the number in the display from the
*		contents of the memory.
*/		
VOID mem_sub(VOID)
{
	WORD		ii;

	/* NEW LINE 3/3/86 */
   	if (((stack_num == 0) || (last_calc == EQUAL) || ( last_calc == NOP )) || 
		((stack_num == 1) && (last_calc == PLUMIN)))
	{
		if (dec_pt1 == 64)
			dec_pt1 = num_dig - 1;
		if (last_calc == PLUMIN)
		{
			if (last_op == DIVIDE)
				op1[0]--;
			if ((last_op == TIMES) || (last_op == PLUS))
				op1[0]++;
		}
		if ((last_calc == PLUMIN) && (op1[0] == 0))
			op1[0] = (64 + dec_pt1) | neg1;
		if ((last_calc != EQUAL) && (last_calc != PLUMIN) &&
			( last_calc != NOP ))
		{
			op1[0] = (64 + dec_pt1) | neg1;
		}
		dec_pt1 =64;
		if (last_calc == RETMEM)
			for (ii = 0;ii < 10;op1[ii] = memory[ii++])
				;
		_FLD_SUB(result,op1,memory);
	}
    else
	{
		if (dec_pt2 == 64)
			dec_pt2 = num_dig - 1;
		op2[0] = (64 + dec_pt2) | neg2;
		dec_pt2 = 64;	
		if (last_calc == RETMEM)
			for (ii = 0; ii < 10;op2[ii] = memory[ii++])
				;
		_FLD_SUB(result,op2,memory);
	}	  
	mem_op(); 
}


/*
*		Performs the arithmatic operation specified.
*/
VOID solve(VOID)
{	      
	WORD		dummy;
	WORD		ii;
	WORD		the_same;

	/*Reset the flags */
    dec_pt2 = 64;	
	neg1 = 0;
	neg2 = 0;
	add_on = 64;
	not_zero = FALSE;
	pt_seen = 0;
	the_same = TRUE;
	/* Perform the arithmatic operation */
	do_op(last_op);  
	/* Check for error conditions  and  */
	/* display the result, if no error. */
	over_err();	
	if (!eror)				  
		pop_bcd();
	dummy = result[0] & 0x7f;
    if (dummy > 76)
		dsply_err();	
	eror = FALSE;	
	/* Transfer the result to the first operand */
	for(ii = 0;ii < 10;op1[ii++] = NULL)
		;
	for(ii = 0;ii < 10;op1[ii] = result[ii++])
		;
    num_dig = 0;
	inp_idx = 0;
	stack_pt = 19;
	/* Correct the exponent */
	if (last_op == TIMES)
		op1[0]++;
    if (last_op == DIVIDE)
		op1[0]--;	
}


/*
*		Set the second operand up for the operation.
*
*/
VOID set_op2(VOID)
{	 
 	if (dec_pt2 == 64)
		dec_pt2 = num_dig - 1; 
    num_dig = 0; 
	op2[0] = (add_on + dec_pt2) | neg2;	    
	add_on = 64;
	if (last_calc == PERCENT)
		op2[0] = result[0];      
}


/*
*		Reset the calculator.
*/
VOID zero_clr(VOID)
{
	clr_ent(0);
	clr_ent(1);
}


/*
*		Process all calculator functions.
*/
WORD hndl_calc(WORD obj)
{
	WORD		value;
	WORD		ii;
	BYTE		is_neg;
	BYTE		inp_num;

	value = 0;
	switch(obj)
	{
	  case THECALC:
		break;
	  case NINE:
		value++;
	  case EIGHT:
		value++;
	  case SEVEN:
		value++;
	  case SIX:
		value++;
	  case FIVE:
		value++;
	  case FOUR:
		value++;
	  case THREE:
		value++;
	  case TWO:
		value++;
	  case ONE:
		value++;
	  case ZERO:
		/* If a digit is selected, push     */
		/* it on the correct operand stack. */
		if ( (last_calc == EQUAL) ||
		     (last_calc == RETMEM) || ( equal_clr ) )  	/* NEW LINE 1/29 */
		   /* Reset calculator */
		  zero_res();
        if ( (last_calc == NOP) ||
		     (last_calc == EQUAL) || ( equal_clr ) )	/* NEW LINE 1/29 */
			/* Clear for a new number */
    		  clr_calc();
		
		if ((num_dig != 14) && (last_calc != PLUMIN))
	    {
		  if (value != 0) 
			not_zero = TRUE;	
	      inp_num = '0' + value;
		  inp_str[inp_idx++] = value + '0';
		  /* If the digit is a "0"   */
		  /* and only zeros and a    */
		  /* decimal point have been */
		  /* seen decrement the ex-  */
		  /* ponent.		   */ 
		  if ((value == 0) && (!not_zero) && (inp_idx != 1))
			add_on--;
		  else
          {	 
		        num_dig++;	
	            push_bcd(inp_num);
		  }
		  /* If a zero is the first digit */
		  /* ignore it.			*/
		  last_calc = NUM;	
	      if ((inp_idx == 1) && (inp_str[0] == '0'))   
		  {
		         inp_idx--;  
		         num_dig--;
		         stack_pt = 19;
/*			 last_calc = NOP; */
		  }	 
        }
		if (num_dig == 14)
		{
		  clr_ent(stack_num);
		  last_calc = NOP;
		  dsply_err();
		}
		break;
	  case RETMEM:
	  	ret_mem();
		break;
	  case MEMPLU:
		mem_plus();
		break;	     
	  case MEMMIN:
		mem_sub();
		break;
	  case CLRMEM:
		clr_mem();
		break;
	  case PLUMIN:
		/* Can only change sign after a  */
		/* number is displayed.          */
		if (last_calc != NOP)
		{
		  do_neg();
/*		  if (last_calc != EQUAL)
	            last_calc = PLUMIN;*/
		}
		break;
	  case POINT:
		if ( (last_calc == EQUAL) ||
		     (last_calc == RETMEM) || 
		     (last_calc == PLUMIN)  )
		  /* Reset calculator for a new operation */
		  zero_res();
	    if ((stack_pt != 1) && (pt_seen == 0))
	    {
			/* Clear calculator for a new number */
	       	if (last_calc != NUM)
			    clr_calc();
			/* Set the decimal point to the number of */
			/* digits entered.			  */
			if (num_dig != 14)
			{
			  if (stack_num == 0)		
			    dec_pt1 = inp_idx - 1;
	          else
			    dec_pt2 = inp_idx - 1;
			  last_calc = POINT;
			  inp_str[inp_idx++] = '.';
			  pt_seen = 1;
			}
		}
		break;	 
	  case PERCENT:
		/* Detremine the percentage of the value, and */
		/* display that percentage.		      */	 
		if (last_calc == NUM)
		{  
	         if (dec_pt2 == 64)
		       dec_pt2 = num_dig - 1; 
		     last_calc = PERCENT;	
		     op2[0] = 63 + dec_pt2;
		     _FLD_MUL(result,op2,op1);
		     last_calc = PERCENT;
		     pop_bcd();		
		     for (ii = 0;ii < 10;op2[ii] = result[ii++])
		       ;
		}
		break;	
	  case MINUS:
	  case PLUS:
	  case TIMES:
	  case DIVIDE: 		     
		if (last_calc != NOP)
		{
		  is_neg = FALSE;
		  stack_pt = 19;			  
		  pt_seen = 0;
	      if (last_calc == RETMEM)
		  {
			/* Transfer the contents of the memory to  */
			/* proper operand stack, and solve the     */
			/* operation if required.		   */
       	    if (stack_num == 0)
		      for (ii = 0;ii < 10;op1[ii] = memory[ii++]);
            else
       	    {
	          for (ii = 0;ii < 10;op2[ii] = memory[ii++]);	 
/*		      last_calc = NOP;	DELETE LINE 3/3/86 */
		      if (last_op != NOP)
		        solve();
       	    }
		  } 
		  if ( (last_op == NOP) && 
		       (last_calc != RETMEM))
		  {				      
			  	/* Setup the first operand */	
		    stack_num = 0;
		    over_err();
		    if (dec_pt1 == 64)
		      dec_pt1 = num_dig - 1;
       	    num_dig = 0;
		    op1[0] = (add_on + dec_pt1) | neg1;
		    add_on = 64;
		    not_zero = FALSE;
		    neg1 = 0;
          }
		  else
		  {
            if ((last_op != EQUAL) && (last_calc != RETMEM))	 
		    {     
		      set_op2();
		      solve();	
		    }
		  }
		  for(ii = 0;ii < 10;op2[ii++] = NULL);
	 	  for(ii = 0;ii < 10;result[ii++] = NULL);
		  last_calc = NOP;
		  last_op = obj;		  
		  stack_num = 1;
		}
		break;
	  case EQUAL:		
		if ((last_op != EQUAL) && ( last_op != NOP ))	/* NEW LINE 1/29 */
		{	   
          if (last_calc == RETMEM)
		    for (ii = 0;ii < 10;op2[ii] = memory[ii++]);	 
		  else
		    set_op2();	
		  last_calc = EQUAL;
		  solve();
		  stack_num = 1;
		  last_op = EQUAL;
		}
		break;
	  case CLRNTRY:
		/* Clear the last entry. */
		num_dig = 0;
		pt_seen = 0;
		clr_ent(stack_num);
		last_calc = NOP;
        break;
	  case THECLR:
		/* Reset the calculator. */
		last_calc = NUM;
		zero_res();
		break;
	} /* switch */
	equal_clr = ( obj == EQUAL );		/* NEW LINE 1/29 */
	display(&inp_str[0]);
	if ((last_calc == PERCENT) || 
	    (inp_str[0] == 'e'))	
	clr_calc ();		
	return(FALSE);
} /* hndl_calc */


/*
*		Convert a key stroke to the proper calculator button.
*/
WORD find_chr(WORD key)
{
	WORD		ob;
	WORD		value;

	ob = 0;
	value = 0;
	switch(key)
    {
	   case '0':
  		ob = ZERO;
		break;
           case '9':
		value++;
	   case '8':
		value++;
	   case '7':	
		value++;
	   case '6':	
		value++;
	   case '5':	
		value++;
	   case '4':	
		value++;
	   case '3':	
		value++;
	   case '2':	
		value++;
	   case '1':
		ob = (16 - (8 * (value / 3)) + (value + 1));		
		break;
	   case 'M':
	   case 'm':
		ob = THE_M;
		break;	      
	   case 'E':
	   case 'e':
		ob = THE_E;
	        break;
	   case 'R':
	   case 'r':
         if (last_key == THE_M)
			ob = RETMEM;
	     break; 			
	   case 'C':
	   case 'c':
		if (last_key == THE_E)
		  ob = CLRNTRY;
        else if (last_key == THE_M)
		  ob = CLRMEM;
		else	       
		  ob = THECLR;
		break;
	   case '%':
		ob = PERCENT;
		break;
	   case '+':
		if (last_key == THE_M)
		  ob = MEMPLU;
		else
	      ob = PLUS;
		break;
	   case '-':  
		if (last_key == THE_M)	
		  ob = MEMMIN;
		else
		  ob = MINUS;
		break;
	    case '*':
		ob = TIMES;
		break;
	    case 92:
		ob = PLUMIN;
		break;	
	    case '/':
		ob = DIVIDE;
		break;
	    case '.':
		ob = POINT;
		break;
	    case '=':
		ob = EQUAL;
		break;
    }
	return(ob);
}
