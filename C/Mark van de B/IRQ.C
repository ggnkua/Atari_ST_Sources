#include <osbind.h>
long int var;
short int index;

synchronize(routine)
int (*routine)(); /* pointer to (=address of) function */
{ register long *vblqueue;
  register short *nvbls;
  register long i,j;
  register short bool=0;
  register long save;
  /* next install a routine in the VBL-queue */
  save=Super(0); /* switch to supervisor status */
  nvbls=0x454; /* address of number of VBL routines */
  i=(*nvbls); /* get the number */
  vblqueue=0x456; /* address of pointer to VBL queue */
  vblqueue=(*vblqueue); /* address of VBL queue */
  for(j=0;j<i;j++)
    { if (*(vblqueue+j)==0) /* check if place is used */
        { *(vblqueue+j)=routine; /* install */
          bool=1; /* synchronizing succeeded */
          break;
        }
    }
  index=j; /* remember index of VBL queue where routine was */
  if(!bool)
    { Cconws("Unable to synchronise routine with VBL-irq");
      Super(save);
      Cconin();
      Pterm0(); /* synchronisation failed, quit */
    }
  Super(save); /* restore previous state */
}

rmsync()
{ register long *vblqueue;
  register long save;
  save=Super(0);
  vblqueue=0x456;
  vblqueue=(*vblqueue);
  *(vblqueue+index)=0;
  Super(save);
}
countirqs()
{ var++;
}

main()
{ synchronize(countirqs);
  Crawcin();
  rmsync();
  printf("%ld VBL-interrupts have been executed",var);
  Crawcin();
}

