#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct deplist {
  char *name;
  
  struct deplist *next;
}DEPLIST;

DEPLIST *dl = NULL;

void depcheck(char *file,char toplevel) {
  FILE    *fp1;
  DEPLIST *dwalk = dl;
  
  if(toplevel) {
    printf("%s: ",file);
  }

  while(dwalk) {
    if(!strcmp(dwalk->name,file)) {
      break;
    }

    dwalk = dwalk->next;
  };

  if(!dwalk && (fp1 = fopen(file,"r"))) {
    while(1) {
      char line[200],depname[50],command[50];
      
      fgets(line,200,fp1);
      
      if(feof(fp1)) {
	break;
      }
      
      if(sscanf(line,"%s \"%[^>\"]>",command,depname) == 2) {
	if(!strcmp("#include",command)) {
	  DEPLIST **dlwalk = &dl;
	  int cmp = -1;
	  
	  while(*dlwalk) {


	    if((cmp = strcmp(depname,(*dlwalk)->name)) < 0) {
	      break;
	    }
	    else if(cmp == 0) {
	      break;
	    };

	    dlwalk = &(*dlwalk)->next;
	  }
	  
	  if(cmp) {
	    DEPLIST *d = (DEPLIST *)malloc(sizeof(DEPLIST));

	    d->next = *dlwalk;
	    *dlwalk = d;

	    d->name = (char *)malloc(strlen(depname) + 1);
	    strcpy(d->name,depname);
	  }

	  depcheck(depname,0);
	};
      }
    }
    
    fclose(fp1);
  }
  else if(!fp1) {
    printf("Couldn't open file: %s!\n",file);
  }
  
  if(toplevel) {
    while(dl) {
      DEPLIST *tmp = dl;

      dl = dl->next;

      printf("%s ",tmp->name);

      free(tmp->name);
      free(tmp);
    }

    printf("\n");
  }
}

void main(int argc,char *argv[]) {
  int i;
  
  for(i = 1; i < argc; i++) {
    depcheck(argv[i],1);
  }
}
