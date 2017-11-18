/* exemple de polymorphisme en C
   Par Golio Junior pour Falk'mag 6
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* d‚finition de la structure des objets polymorphes */
typedef struct obj_polymorphe {
	void (*add)(struct obj_polymorphe *objg, struct obj_polymorphe *objd);		/* addition */
	void (*aff)(struct obj_polymorphe *obj);		/* affichage */
	float (*p_reel)(struct obj_polymorphe *obj);		/* partie reelle */
	float (*p_imag)(struct obj_polymorphe *obj);	/* partie imaginaire */
	void *objet;									/* objet */
	} OBJ_polymorphe;

typedef struct obj_reel {
	float reel;
	} OBJ_reel;

typedef struct obj_imag_rec {
	float reel;
	float imag;
	} OBJ_imag_rec;

typedef struct obj_imag_pol {
	float modu;
	float angl;
	} OBJ_imag_pol;

/* fonctions sur les r‚els */

/* addition */
void reel_add(OBJ_polymorphe *objg, OBJ_polymorphe *objd)
{ ((OBJ_reel *)(objg->objet))->reel+=objd->p_reel(objd);
}

/* affichage */
void reel_aff(OBJ_polymorphe *this)
{ printf(" valeur du r‚el : %f\n",((OBJ_reel *)(this->objet))->reel);
}

/* partie reelle */
float reel_p_reel(OBJ_polymorphe *this)
{ return ((OBJ_reel *)(this->objet))->reel;
}

/* partie imaginaire */
float reel_p_imag(OBJ_polymorphe *this)
{ return 0.;
}

/* fonction de cr‚ation */
void c_OBJ_reel(OBJ_polymorphe *obj, float init)
{ if ((obj->objet=malloc(sizeof(OBJ_reel)))==NULL)
	{ printf("erreur de creation !\n");
	}
	else
	{ ((OBJ_reel *)(obj->objet))->reel=init;
	  obj->add=reel_add;
	  obj->aff=reel_aff;
	  obj->p_reel=reel_p_reel;
	  obj->p_imag=reel_p_imag;
	}
}

/* fonctions sur les complexes rectangulaires */

/* addition */
void imag_rec_add(OBJ_polymorphe *objg, OBJ_polymorphe *objd)
{ ((OBJ_imag_rec *)(objg->objet))->reel+=objd->p_reel(objd);
  ((OBJ_imag_rec *)(objg->objet))->imag+=objd->p_imag(objd);
}

/* affichage */
void imag_rec_aff(OBJ_polymorphe *this)
{ printf(" valeur du complexe : %f + %f i\n",((OBJ_imag_rec *)(this->objet))->reel, ((OBJ_imag_rec *)(this->objet))->imag);
}

/* partie reelle */
float imag_rec_p_reel(OBJ_polymorphe *this)
{ return ((OBJ_imag_rec *)(this->objet))->reel;
}

/* partie imaginaire */
float imag_rec_p_imag(OBJ_polymorphe *this)
{ return ((OBJ_imag_rec *)(this->objet))->imag;
}

/* fonction de cr‚ation */
void c_OBJ_imag_rec(OBJ_polymorphe *obj, float r, float i)
{ if ((obj->objet=malloc(sizeof(OBJ_imag_rec)))==NULL)
	{ printf("erreur de creation !\n");
	}
	else
	{ ((OBJ_imag_rec *)(obj->objet))->reel=r;
	  ((OBJ_imag_rec *)(obj->objet))->imag=i;
	  obj->add=imag_rec_add;
	  obj->aff=imag_rec_aff;
	  obj->p_reel=imag_rec_p_reel;
	  obj->p_imag=imag_rec_p_imag;
	}
}

/* fonctions sur les complexes polaires */

/* addition */
void imag_pol_add(OBJ_polymorphe *objg, OBJ_polymorphe *objd)
{ float a = objg->p_reel(objg);
  float p_reelle = objd->p_reel(objd)+a;
  float p_imag = objd->p_imag(objd)+objg->p_imag(objg);
  float module = sqrt(p_reelle*p_reelle+p_imag*p_imag);
  ((OBJ_imag_pol *)(objg->objet))->modu=module;
  ((OBJ_imag_pol *)(objg->objet))->angl=acos(a/module);
}

/* affichage */
void imag_pol_aff(OBJ_polymorphe *this)
{ printf(" valeur du complexe : module : %f ; angle : %f\n",((OBJ_imag_pol *)(this->objet))->modu, ((OBJ_imag_pol *)(this->objet))->angl);
}

/* partie reelle */
float imag_pol_p_reel(OBJ_polymorphe *this)
{ return ((OBJ_imag_pol *)(this->objet))->modu*cos(((OBJ_imag_pol *)(this->objet))->angl);
}

/* partie imaginaire */
float imag_pol_p_imag(OBJ_polymorphe *this)
{ return ((OBJ_imag_pol *)(this->objet))->modu*sin(((OBJ_imag_pol *)(this->objet))->angl);
}

/* fonctions de cr‚ation */
void c_OBJ_imag_pol(OBJ_polymorphe *obj, float m, float a)
{ if ((obj->objet=malloc(sizeof(OBJ_imag_pol)))==NULL)
	{ printf("erreur de creation !\n");
	}
	else
	{ ((OBJ_imag_pol *)(obj->objet))->modu=m;
	  ((OBJ_imag_pol *)(obj->objet))->angl=a;
	  obj->add=imag_pol_add;
	  obj->aff=imag_pol_aff;
	  obj->p_reel=imag_pol_p_reel;
	  obj->p_imag=imag_pol_p_imag;
	}
}

int main()
{ OBJ_polymorphe a,b,c,d;

  c_OBJ_reel(&a, 10.25);
  c_OBJ_imag_rec(&b, 10, 20);
  c_OBJ_imag_rec(&c, 5, 10);
  c_OBJ_imag_pol(&d, 1, M_PI);
  
  printf("valeur de a : ");
  a.aff(&a);
  
  printf("valeur de b : ");
  b.aff(&b);
  
  printf(" valeur de b+c : ");
  b.add(&b,&c);
  b.aff(&b);
  
  printf(" valeur de c+d : ");
  d.add(&d,&c);
  d.aff(&d);
  
  return(0);
}