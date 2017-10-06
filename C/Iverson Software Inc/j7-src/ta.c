/* ----------------------------------------------------------------------- */
/* J-Source Version 7 - COPYRIGHT 1993 Iverson Software Inc.               */
/* 33 Major Street, Toronto, Ontario, Canada, M5S 2K9, (416) 925 6096      */
/*                                                                         */
/* J-Source is provided "as is" without warranty of any kind.              */
/*                                                                         */
/* J-Source Version 7 license agreement:  You may use, copy, and           */
/* modify the source.  You have a non-exclusive, royalty-free right        */
/* to redistribute source and executable files.                            */
/* ----------------------------------------------------------------------- */
/*                                                                         */
/* Tables for Atomic Verbs                                                 */

#include "j.h"
#include "v.h"

static VA va[]={
/*       */ {0,      0,     {{0,      0              },
                             {0,      0              },
                             {0,      0              },
                             {0,      0              },
                             {0,      0              }  }},

/* 21 !  */ {CBANG,  V1101, {{ble,    VB+VBB         },
                             {dbin,   VD+VDD+VRI     },
                             {dbin,   VD+VDD         },
                             {jbin,   VZ+VZZ         },
                             {ble,    VB+VBB         },
                             {dbin,   VD+VDD+VRI     }  }},

/* 25 %  */ {CDIV,   0,     {{ddiv,   VD+VDD         },
                             {ddiv,   VD+VDD         },
                             {ddiv,   VD+VDD         },
                             {jdiv,   VZ+VZZ         },
                             {bdiv,   VD+VBB         },
                             {idiv,   VD+VII         }  }},

/* 2a *  */ {CSTAR,  V0001, {{band,   VB+VBB    +VASS},
                             {dtymes, VD+VDD+VRI+VASS},
                             {dtymes, VD+VDD    +VASS},
                             {jtymes, VZ+VZZ    +VASS},
                             {band,   VB+VBB,        },
                             {itymes, VD+VII+VRI     }  }},

/* 2b +  */ {CPLUS,  0,     {{bplus,  VI+VII    +VASS},
                             {dplus,  VD+VDD+VRI+VASS},
                             {dplus,  VD+VDD    +VASS},
                             {jplus,  VZ+VZZ    +VASS},
                             {bplus2, VI+VBB         },
                             {iplus,  VD+VII+VRI     }  }},

/* 2d -  */ {CMINUS, 0,     {{bminus, VI+VII         },
                             {dminus, VD+VDD+VRI     },
                             {dminus, VD+VDD         },
                             {jminus, VZ+VZZ         },
                             {bminus2,VI+VBB         },
                             {iminus, VD+VII+VRI     }  }},

/* 3c <  */ {CLT,    V0100, {{blt,    VB+VBB         },
                             {ilt,    VB+VII         },
                             {dlt,    VB+VDD         },
                             {dlt,    VB+VDD         },
                             {blt,    VB+VBB         },
                             {ilt,    VB+VII         }  }},

/* 3d =  */ {CEQ,    V1001, {{beq,    VB+VBB    +VASS},
                             {ieq,    VB+VII         },
                             {deq,    VB+VDD         },
                             {jeq,    VB+VZZ         },
                             {beq,    VB+VBB         },
                             {ieq,    VB+VII         }  }},

/* 3e >  */ {CGT,    V0010, {{bgt,    VB+VBB         },
                             {igt,    VB+VII         },
                             {dgt,    VB+VDD         },
                             {dgt,    VB+VDD         },
                             {bgt,    VB+VBB         },
                             {igt,    VB+VII         }  }},

/* 5e ^  */ {CEXP,   V1011, {{bge,    VB+VBB         },
                             {jpow,   VZ+VZZ+VRD     },
                             {jpow,   VZ+VZZ+VRD     },
                             {jpow,   VZ+VZZ         },
                             {bge,    VB+VBB         },
                             {jpow,   VZ+VZZ+VRJ     }  }},

/* 7c |  */ {CSTILE, V0100, {{blt,    VB+VBB         },
                             {irem,   VI+VII         },
                             {dren,   VD+VDD         },
                             {jrem,   VZ+VZZ         },
                             {blt,    VB+VBB         },
                             {irem,   VI+VII         }  }},

/* 82 <. */ {CMIN,   V0001, {{band,   VB+VBB    +VASS},
                             {imin,   VI+VII    +VASS},
                             {dmin,   VD+VDD    +VASS},
                             {dmin,   VD+VDD    +VASS},
                             {band,   VB+VBB         },
                             {imin,   VI+VII         }  }},

/* 83 <: */ {CLE,    V1101, {{ble,    VB+VBB         },
                             {ile,    VB+VII         },
                             {dle,    VB+VDD         },
                             {dle,    VB+VDD         },
                             {ble,    VB+VBB         },
                             {ile,    VB+VII         }  }},

/* 84 >. */ {CMAX,   V0111, {{bor,    VB+VBB    +VASS},
                             {imax,   VI+VII    +VASS},
                             {dmax,   VD+VDD    +VASS},
                             {dmax,   VD+VDD    +VASS},
                             {bor,    VB+VBB         },
                             {imax,   VI+VII         }  }},

/* 85 >: */ {CGE,    V1011, {{bge,    VB+VBB         },
                             {ige,    VB+VII         },
                             {dge,    VB+VDD         },
                             {dge,    VB+VDD         },
                             {bge,    VB+VBB         },
                             {ige,    VB+VII         }  }},

/* 88 +. */ {COR,    V0111, {{bor,    VB+VBB    +VASS},
                             {igcd,   VI+VII    +VASS},
                             {dgcd,   VD+VDD    +VASS},
                             {jgcd,   VZ+VZZ    +VASS},
                             {bor,    VB+VBB         },
                             {igcd,   VI+VII         }  }},

/* 89 +: */ {CNOR,   V1000, {{bnor,   VB+VBB         },
                             {bnor,   VB+VBB         },
                             {bnor,   VB+VBB         },
                             {bnor,   VB+VBB         },
                             {bnor,   VB+VBB         },
                             {bnor,   VB+VBB         }  }},

/* 8a *. */ {CAND,   V0001, {{band,   VB+VBB    +VASS},
                             {dlcm,   VI+VDD+VRI+VASS},
                             {dlcm,   VD+VDD    +VASS},
                             {jlcm,   VZ+VZZ    +VASS},
                             {band,   VB+VBB         },
                             {ilcm,   VD+VII+VRI     }  }},

/* 8b *: */ {CNAND,  V1110, {{bnand,  VB+VBB         },
                             {bnand,  VB+VBB         },
                             {bnand,  VB+VBB         },
                             {bnand,  VB+VBB         },
                             {bnand,  VB+VBB         },
                             {bnand,  VB+VBB         }  }},

/* 95 ~: */ {CNE,    V0110, {{bne,    VB+VBB    +VASS},
                             {ine,    VB+VII         },
                             {dne,    VB+VDD         },
                             {jne,    VB+VZZ         },
                             {bne,    VB+VBB         },
                             {ine,    VB+VII         }  }},

/* cb o. */ {CCIRCLE,0,     {{jcir,   VZ+VZZ+VRD     },
                             {jcir,   VZ+VZZ+VRD     },
                             {jcir,   VZ+VZZ+VRD     },
                             {jcir,   VZ+VZZ         },
                             {jcir,   VZ+VZZ+VRD     },
                             {jcir,   VZ+VZZ+VRD     }  }},
};

UC vaptr[256]={
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 0 */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 1 */
 0,  1,  0,  0,  0,  2,  0,  0,    0,  0,  3,  4,  0,  5,  0,  0, /* 2 */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  6,  7,  8,  0, /* 3 */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 4 */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  9,  0, /* 5 */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 6 */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0, 10,  0,  0,  0, /* 7 */
 0,  0, 11, 12, 13, 14,  0,  0,   15, 16, 17, 18,  0,  0,  0,  0, /* 8 */
 0,  0,  0,  0,  0, 19,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 9 */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* a */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* b */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0, 20,  0,  0,  0,  0, /* c */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* d */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* e */
 0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* f */
};   /* index in va[] for each ID */
/*   1   2   3   4   5   6   7     8   9   a   b   c   d   e   f   */


A va2(a,w,id)C id;A a,w;{I at,cv,t,wt;SF f2;
 RZ(a&&w);
 at=AN(a)?AT(a):BOOL; wt=AN(w)?AT(w):BOOL; t=MAX(at,wt);
 var(id,t,&f2,&cv);
 t=atype(cv);
 R cvz(cv,sex2(t==at?a:cvt(t,a),t==wt?w:cvt(t,w),rtype(cv),f2));
}    /* atomic dyad evaluator */

I atype(cv)I cv;{R cv&VBB?BOOL:cv&VII?INT:cv&VDD?FL:CMPX;}
     /* argument type */
     
I rtype(cv)I cv;{R cv&VB ?BOOL:cv&VI ?INT:cv&VD ?FL:CMPX;}
     /* result type */
     
VA*vap(w)A w;{A fs; RZ(w); fs=VAV(w)->f; R va+vaptr[(UC)ID(fs)];}
     /* va[] entry for verb w */ 

void vaa(w,t,f2,cv)A w;SF*f2;I*cv,t;{A fs;C id;VA2*p;
 fs=VAV(w)->f; id=ID(fs);
 p=((va+vaptr[(UC)id])->fcv)+(t&BOOL?0:t&INT?1:t&FL?2:3);
 *f2=p->f; *cv=p->cv;
}    /* function and control for insert */

void var(id,t,f2,cv)C id;SF*f2;I*cv,t;{VA2*p;
 p=((va+vaptr[(UC)id])->fcv)+(t&BOOL?4:t&INT?5:t&FL?2:3);
 *f2=p->f; *cv=p->cv;
}    /* function and control for rank */

A cva(cv,w)I cv;A w;{I t;
 RZ(w);
 t=AT(w);
 if(cv&VDD&&t!=FL  )R cvt(FL,  w);
 if(cv&VII&&t!=INT )R cvt(INT, w);
 if(cv&VZZ&&t!=CMPX)R cvt(CMPX,w);
 if(cv&VBB&&t!=BOOL)R cvt(BOOL,w);
 R ca(w);
}    /* convert argument */

A cvz(cv,w)I cv;A w;{I t;
 RZ(w);
 t=AT(w);
 if(cv&VRD&&t!=FL )R pcvt(FL,w);
 if(cv&VRI&&t!=INT)R icvt(w);
 if(cv&VRJ&&t!=INT){RZ(w=pcvt(FL,w)); R CMPX&AT(w)?w:pcvt(INT,w);}
 R w;
}    /* convert result */
