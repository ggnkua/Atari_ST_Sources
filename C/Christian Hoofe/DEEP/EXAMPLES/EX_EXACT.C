/* =============================================================
	Modul:	EX_EXACT.C  
				Example of a differential equation with an
				exact solution
	Author:	Ch. Hoofe
	Source:	
	Version:	1.0  22.6.91
   ============================================================= */
#define SIM_END 6
					/* global simulation variables */
long		length;
long		t;
double	dt;

			/* simulation variables declaration */
double Y[SIM_END];	
double Y_exact[SIM_END];

			/* global variables */

			/* parameter */

/* =============================================================
	Function:	initialization()
	
	Parameter:	void
	Return:		void
   ============================================================= */
void initialization(void)
{
	length=SIM_END;
	t=1;
	dt=0.2;
	
	Y[0]=1;
	Y_exact[0] = exp(0.0);
}

/* =============================================================
	Function:	integration_rk4()
	
	Parameter:	void
	Return:		void
   ============================================================= */
void integration_rk4(void)
{	
	double tmp1;
	
	tmp1 = Y[t] * T;
	/*printf("\nt: %ld T:%f tmp1: %f",t,T,tmp1);*/

	Y[t] ~= tmp1;
}
/* =============================================================
	Function:	simulation()
	
	Parameter:	void
	Return:		void
   ============================================================= */
void simulation(void)
{

	Y[t]=Y[t-1];
						/* calculate the exact solution */
	Y_exact[t] = exp(pow(t,2)/2);

	integration_rk4();

}
/* =============================================================
	Function:	main()
				
	Parameter:	void
	Return:		void
   ============================================================= */
void main(void)
{

							/* initialization */
	initialization();
							/* simulation call */
	simulation();

}

/* =============================================================
	Copy the following commands to the
	Command window to display the results
	
	simlist("Y-Y_exact Y1 %13.6f  Y_exact %13.6f ",&Y[0],&Y_exact[0]);				
   ============================================================= */













