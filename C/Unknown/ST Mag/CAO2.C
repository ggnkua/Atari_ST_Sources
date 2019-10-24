
typedef struct
{
	struct
	{
		uint en_exist:1;
		uint en_rsvd :15;
	} en_state;

	union
	{
		PTI en_point[ET_NBMAXPT];

		struct
		{						/* Arc d'ellipse */
			long en_e_pt1;
			long en_e_centre;
			int en_e_a1;
			int en_e_a2;
			long en_e_r1;
			long en_e_r2;
			long en_e_rsvd[ET_NBMAXPT - 6];
			long en_e_pt2;
		} en_aellipse;
		
		struct
		{
			long en_c3_pt1;
			long en_c3_pt2;
			long en_c3_cx;
			long en_c3_cy;
			long en_c3_rayon;
			long en_c3_rsvd[ET_NBMAXPT - 6];
			long en_c3_pt3;
		} en_cercle3;

		struct
		{						/* Arc par de cercle 3 points */
			long en_a3_pt1;
			long en_a3_pt2;
			long en_a3_cx;
			long en_a3_cy;
			long en_a3_rayon;
			int en_a3_a1;
			int en_a3_a2;
			int en_a3_revflag;
			int en_a3_rsvd;
			long en_a3_rsvd2[ET_NBMAXPT - 8];
			long en_a3_pt3;
		} en_arc3;
	} en_def;
} ENTITE;

int alpha_test (int a0, int a1, int a2)
{
  if (a0 > a2)
    a2 += 3600;
  if (a0 > a1)
    a1 += 3600;
  return (a0 <= a1 && a1 <= a2);
}

double angle (double dx, double dy)
{
	/* Renvoie l'angle form‚ entre les vecteurs (1,0) et
		(dx, dy) sur [0;3600[ dans le sens math‚matique et
		dans le repŠre math‚matique. */
	double r, a;
	
	if (dx != 0)
	{
		r = dy / dx;
		
		if (dx > 0)
			a = atan (r);
		else
			a = atan (r) + M_PI;
		
		if (a < 0)
			a = a + 2 * M_PI;
		
		/* Convertit en degr‚s : */
		return (a * (double)3600 / (double)(M_PI * 2));
	}
	else if (dy > 0)
		return 900;
	else if (dy < 0)
		return 2700;
	else
		return 0;
}

double ell_angle (double dx, double dy, long r1, long r2)
{
	/* Renvoie l'angle elliptique form‚ entre les vecteurs (1,0)
			et (dx, dy) sur [0;3600[ dans le sens math‚matique et
			dans le repŠre math‚matique. */
	double r, a;
	
	if (dx != 0)
	{
		r = (dy * r1) / (dx * r2);
		
		if (dx > 0)
			a = atan (r);
		else
			a = atan (r) + M_PI;
		if (a < 0)
			a += 2 * M_PI;
		/* Convertit en degr‚s : */
		return (a * (float)3600 / (float)(M_PI * 2));
	}
	else if (dy > 0)
		return 900;
	else if (dy < 0)
		return 2700;
	else
		return 0;
}
