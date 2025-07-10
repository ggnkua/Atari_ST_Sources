/* ==========================================================
	Modul:	EX_ECONO.C  
				A simple multiplier-accelerator model.
	Author:	Ch. Hoofe
	Source:	A. Stobbe Volkswirtschaftslehre III  p. 107 
	Version:	1.0  29.6.91
   ========================================================== */
#define SIM_END 41

long		length;
long		t;

			/* simulation variables declaration */	
double I[SIM_END];		/* investment */
double C[SIM_END];		/* consumption */	
double Y[SIM_END];		/* national income */
	
		/* global variables */
int C_aut;		/* autonomous consumption */
int G_aut;		/* autonomous government expenditures */ 
/* ==========================================================
	Function:	initialization()
	
	Parameter:	void
	Return:		void
   ========================================================== */
void initialization(void)
{
	length=SIM_END;
	t=1;
	
	I[0] = 0;
	C_aut = 30;	
	C[0] = C_aut+400;
	G_aut = 70;
	Y[0] = I[0]+C[0]+G_aut;

							/* after period 0 increase */
	G_aut = 90;			/* goverment expenditures */ 
}

			/* parameter */
#define C_QUOTE 0.8		/* marginal propensity to comsume */
#define ACCELERATOR 1
/* ==========================================================
	Function:	simulation()
	
	Parameter:	void
	Return:		void
   ========================================================== */
void simulation(void)
{	
	C[t] = C_aut + C_QUOTE * Y[t-1];
	I[t] = ACCELERATOR * (C[t]-C[t-1]);   
	Y[t] = I[t]+C[t]+G_aut;	
}
/* ==========================================================
	Function:	main()
				
	Parameter:	void
	Return:		void
   ========================================================== */
void main(void)
{

							/* initialization */
	initialization();
							/* simulation call */
	simulation();

}

/* ==========================================================
	Copy the following commands to the
	Command window to display the results
	
	simlist("multiplier-accelerator-model Y %6.2f  C %6.2f I %6.2f",&Y[0],&C[0],&I[0]);	
	simgraf("multiplier-accelerator-model Y %6.2f  C %6.2f I %6.2f",&Y[0],&C[0],&I[0]);
   ========================================================== */


