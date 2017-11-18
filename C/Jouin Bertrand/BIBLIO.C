/* bibliothŠque d'exemple */

/* d‚claration des variables globales */
float mul_op1, mul_op2, resul_mul;

/* d‚claration des fonctions */
static float sous(float a, float b)
{ return a*b;	/* cette fonction n'est pas export‚e
                   elle restera donc interne au module
                   heureusement, car son r‚sultat ne correspond
                   pas son nom!
                */
}

int compteur(void)
{ static a=1;
  return a++;	/* la valeur de a va ˆtre incr‚ment‚ … chaque appel
  				   c'est un exemple classique d'utilisation de
  				   variable statique
  				*/
}

float som(float a, float b)
{ return a+b;
}

void mul(void)
{ resul_mul=mul_op1*mul_op2;
}
