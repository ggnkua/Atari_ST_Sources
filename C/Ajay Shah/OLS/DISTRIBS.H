

/* File bivnor.c */
double pnorm2 (double ah, double ak, double r);
/* Bivariate normal probability */
double dnorm2 (double x, double y, double rho);
/* Bivariate normal density */
void ranbivnor (double mu1, double mu2,
		double a, double b, double c,
		double *x, double *y);
/* return draw from bivariate normal.  Creates x and y.
	mu1 and mu2 are means.
	a b and c are created by next function. */
int mk_abc_bivnor (double v1, double v2, double rho,
		   double *a, double *b, double *c);
/* creates magic numbers a b and c for previous function.
	Input: two variances and one correlation coefficient.
	Returns magic numbers a b and c. */

/* File normal.c */
double critz (double p);
/* Inverse Univariate Normal Probability. */
double dnorm1 (double x);
/* Univariate Normal Density */
double lndnorm1 (double x);
/* ln(dnorm1), faster. */

/* File pnorm1.c */
double pnorm1 (double x);
/* Univariate Normal Probability */

/* File binomial.c */
double binomc (int x, int n);
/* cumulative binomial */
double binomp (int x, int n, double p);
/* binomial probability */

/* File t.c */
int tprob (double t, int dof, double *probability);
/* probability of t_{dof} */
double critt (double p, int dof);
/* what is the t which can give this p? */

/* File chisq.c */
double pchisq (double x, int dof);
/* Prob(chisq < x) with dof degrees of freedom. */
double critchi (double p, int dof);
/* Return x s.t. Prob(chisq < x) = p, we're talking dof d.o.f.  */

/* File f.c */
double pF (double F, int df1, int df2);
/* Prob(f < F) with (df1, df2) degrees of freedom. */
double critF (double p, int df1, int df2);
/* find x s.t. Prob(f<F) = p.  F(df1, df2). */

/* File gasdev.c */
double gasdev (int *idum);

/* File ranev.c */
double ranev (int *idum);

/* File beta.c
Beta distribution.  WARNING: horribly inefficient.  Not too precise. */
double beta_dens (double a, double b, double x);
double beta_prob (double beta_a, double beta_b, double x);
double beta_inv (double beta_a, double beta_b, double P);
double betadev (double a, double b, int *seed);

/* File gamma.c */
double gamma (double x);	/* gamma function, not distribution */

/* File gammln.c */
double gammln (double x);	/* log gamma */

/* File psi.c */
double psi (double x);		/* derivative of log gamma */

/* File gammln_cr.c */
double gammln_cr (double x);	/* "crude" log gamma (from Numerical Recipes) */

/* File bindev.c */
/* binomially distributed random numbers */
int bindev (int n, float pp, int *iseed);

/* File cheapnor.c */
double ipnorm1 (double *table, double x);
void tsetup (double *table);

/* File censbc.c */
double mc_e_cens_bc (double sigma, double lambda,
		     double betax, double min, double max,
		     double convergence);

/* File mvn.c */
void ranmvn (int N, double *mu, double **P, double *v);
