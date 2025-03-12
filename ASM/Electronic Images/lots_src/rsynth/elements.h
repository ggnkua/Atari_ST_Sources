/* $Id: elements.h,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
typedef struct
 {float stdy;
  float fixd;
  char  prop;
  char  ed;
  char  id;
 } interp_t, *interp_ptr;

enum Eparm_e
 {
  fn, f1, f2, f3, b1, b2, b3, an, a1, a2, a3, a4, a5, a6, ab, av, avc, asp, af,
  nEparm
 };

extern char *Ep_name[nEparm];

typedef struct Elm_s
 {
  char *name;
  char rk;
  char du;
  char ud;
  interp_t p[nEparm];
 } Elm_t, *Elm_ptr;

extern Elm_t Elements[];
extern unsigned num_Elements;


