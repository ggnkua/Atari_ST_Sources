/*
============================================================================
NAME    : read.c
PURPOSE : translation of lp-problem and storage in sparse matrix
SHORT   : Subroutines for yacc program to store the input in an intermediate
          data-structure. The yacc and lex programs translate the input.
          First the problemsize is determined and the date is read into
          an intermediate structure, then readinput fills the sparse matrix.
USAGE   : call yyparse(); to start reading the input.
          call readinput(); to fill the sparse matrix.
============================================================================
Rows : contains the amount of rows + 1
       Rows-1 is the amount of constraints (no bounds)
       Rows   also contains the rownr 0 which is the objectfunction
Columns : contains the amount of columns (different variable names
          found in the constraints)
Nonnuls : contains the amount of nonnuls = sum of different entries
          of all columns in the constraints and in the objectfunction
Hash_tab : contains all columnnames on the first level of the structure
           the row information is kept under each column structure
           in a linked list (also the objext funtion is in this structure)
           Bound information is also stored under under the column name
First_rside : points to a linked list containing all relational operators
              and the righthandside values of the constraints
              the linked list is in reversed order with respect to the
              rownumbers
============================================================================
*/
#include "defines.h"
#include "globals.h"

/*---------------------------------------------------------------------------*/

/*
 * errorhandeling routine for yyparse()
 */
void yyerror(char *string)
{
  fprintf(stderr, "PARSING ERROR: %s on line %d, quiting\n", string, yylineno);
  exit(1);
}

void check_decl(char *str)
{
  if(strcmp(str, "int"))
    {
      fprintf(stderr, "Unknown declaration specifier %s on line %d, ignored\n",
	      str, yylineno);
      Ignore_decl = TRUE;
    }
}

void add_int_var(char *name)
{
  hashelem *hp;

  if(Verbose)
    fprintf(stderr, "int: %s\n", name);
  if(!(hp = gethash(name)))
    fprintf(stderr,
	    "Unknown variable %s declared integer on line %d, ignored\n",
	    name, yylineno);
  else
    hp->must_be_int = 1;
}


/*
 * initialisation of hashtable and globals.
 */
void init_read(void)
{
  int i;
  Rows = 0;
  Nonnuls = 0;
  Columns = 0;
  for(i = 0; i<HASH_SIZE; Hash_tab[i++] = NULL);
  CALLOC(First_rside, 1, rside);
  First_rside->value = 0;
  First_rside->relat = OF; /* first row (nr 0) is always the objective function */
} /* init */

/*---------------------------------------------------------------------------*/

/*
 * Returns hashvalue of string
 * hashvalue = sum ( asciivalue of character * indexnumber) mod HASHSIZE
 */
int hashvalue(char *string)
{
  int i, j;
  i = j = 0;
  while((int)string[j]&&j<MAXSTRL)
    i += (NAMELEN-j)*(int)string[j++];
  return(i % HASH_SIZE);
} /* hashvalue */



/*
 * Returns a pointer to hashelement with colname = variable
 * If this hashelement does not exists, gethash() returns a NULL pointer
 */
hashelem *gethash(char *variable) 
{
  hashelem *h_tab_p;
  for(h_tab_p = Hash_tab[hashvalue(variable)];
      h_tab_p != NULL;
      h_tab_p = h_tab_p->next)
    if(strcmp(variable, h_tab_p->colname) == 0)
      return(h_tab_p);
  return(h_tab_p);
} /* gethash */



/*
 * searchs in column-list (p is pointer to first element of column-list)
 * for column->row = row.
 * getrow() returns a pointer to this column structure.
 * If not found a NULL-pointer is returned
 */
column *getrow(column *p,
	       int row)
{
  for(; p != NULL; p = p->next)
    if(p->row == row)
      return(p);
  return(p) ;
} /* getrow */



/*
 * Creates a bound record.
 * Set lowbo = 0 and upbo = INFINITE
 *
 */
bound *create_bound_rec(void)
{
  bound *bp;
  CALLOC(bp, 1, bound);
  bp->upbo = INFINITE;
  bp->lowbo = 0;
  return(bp);
} /* create_bound_rec */



/*
 * clears the tmp_store variable after all information has been copied
 */
void null_tmp_store(void)
{
  tmp_store.value = 0;
  tmp_store.rhs_value = 0;
}

/*---------------------------------------------------------------------------*/

/*
 * variable : pointer to text array with name of variable
 * row      : the rownumber of the constraint
 * value    : value of matrixelement
 *            A(row, variable).
 * Sign     : (global)  determines the sign of value.
 * store()  : stores value in matrix
 *	      A(row, variable). If A(row, variable) already contains data,
 *	      value is added to the existing value.
 */
void store(char *variable,
	   int row,
	   double value) 
{ 
  hashelem *h_tab_p;
  column *col_p;
  int hv;

  if(value == (double)0)
    return;
  if((h_tab_p = gethash(variable)) == NULL)
  {
    CALLOC(h_tab_p, 1, hashelem);
    Columns++; /* counter for calloc of final array */
    hv = hashvalue(variable);
    h_tab_p->next = Hash_tab[hv];
    Hash_tab[hv] = h_tab_p;
    strcpy(h_tab_p->colname, variable);
    CALLOC(h_tab_p->col, 1, column);
    Nonnuls++; /* for calloc of final arrays */
    h_tab_p->col->row = row;
    h_tab_p->col->value = value;
  }
  else
    if((col_p = getrow(h_tab_p->col, row)) == NULL)
    {
      CALLOC(col_p, 1, column);
      Nonnuls++; /* for calloc of final arrays */
      col_p->value = value;
      col_p->row = row;
      col_p->next = h_tab_p->col;
      h_tab_p->col = col_p;
    }
    else
      col_p->value += value;
} /* store */



/*---------------------------------------------------------------------------*/

/*
 * store relational operator given in yylex[0] in the rightside list.
 * Also checks if it constaint was a bound and if so stores it in the
 * boundslist
 */
void store_re_op(void)
{
  short tmp_relat;
  switch(yytext[0]) {

  case '=':
    tmp_relat = EQ;
    break;

  case '>':
    tmp_relat=GE;
    break;
    
  case '<':
    tmp_relat=LE;
    break;
    
  default:
    break;
  }
  
  if(Lin_term_count > 1) /* it is not a bound */
    First_rside->relat = tmp_relat;
  else /* could be a bound */
    tmp_store.relat = tmp_relat;
} /* save_re_op */



/*
 * store RHS value in the rightside structure
 * if type = true then
 */
void rhs_store(double value)
{
  if(Lin_term_count <= 1) /* could be a bound */
    tmp_store.rhs_value += value;
  else /* not a bound */
    First_rside->value += value;
} /* RHS_store */



/*
 * store all data in the right place
 * count the amount of lineair terms in a constraint
 * only store in data-structure if the constraint is not a bound
 */
void var_store(char *var,
	       int row,
	       double value)
{
  if(strlen(var) > MAXSTRL)
    {
      fprintf(stderr, "Variable name too long, at most %d characters allowed",
	      MAXSTRL);
      exit(1);
    }
  /* also in a bound the same var name can occur more than once. Check for
     this. Don't increment Lin_term_count */

  if(Lin_term_count != 1 || strcmp(tmp_store.name, var) != 0)
    Lin_term_count++;

  if(row == 0) /* always store objective function with rownr == 0 */
    {
      store(var,  row,  value);
      return;
    }
  
  if(Lin_term_count == 1) /* don't yet store. could be a bound */
    {
      strcpy(tmp_store.name, var);
      tmp_store.row = row;
      tmp_store.value += value;
      return;
    }
  
  if(Lin_term_count == 2) /* now you can also store the first variable */
    {
      rside *rp;
      /* make space for the rhs information */
      CALLOC(rp, 1, rside);
      rp->next = First_rside;
      First_rside = rp;
      First_rside->value = tmp_store.rhs_value;
      First_rside->relat = tmp_store.relat;
      
      if (tmp_store.value != 0)
        store(tmp_store.name, tmp_store.row, tmp_store.value);

      null_tmp_store();
    }

  store(var, row, value);
} /* var_store */



/*
 * store the information in tmp_store because it is a bound
 */
store_bounds(void)
{
  if (tmp_store.value != 0)
    {
      hashelem *h_tab_p;
      int hv;

      if((h_tab_p = gethash(tmp_store.name)) == NULL)
        {
          /* a new columnname is found, create an entry in the hashlist */
          CALLOC(h_tab_p, 1, hashelem);
          Columns++; /* counter for calloc of final array */
	  hv            = hashvalue(tmp_store.name);
	  h_tab_p->next = Hash_tab[hv];
          Hash_tab[hv]  = h_tab_p;
          strcpy(h_tab_p->colname, tmp_store.name);
          /* create a place to store bounds information */
          h_tab_p->bnd = create_bound_rec();
        }
      else
        if(h_tab_p->bnd == NULL)
          /* create a place to store bounds information */
          h_tab_p->bnd = create_bound_rec();
      /* else bound_rec already exists */
   
      if(tmp_store.value < 0) /* divide by negative number, */
  	    	              /* relational operator may change */
        {
          if (tmp_store.relat == GE)
            tmp_store.relat = LE;
          else if (tmp_store.relat == LE)
            tmp_store.relat = GE;
        }
 
      if ((tmp_store.relat == GE) || (tmp_store.relat == EQ))
        h_tab_p->bnd->lowbo = tmp_store.rhs_value / tmp_store.value;
      if ((tmp_store.relat == LE) || (tmp_store.relat == EQ))
        h_tab_p->bnd->upbo = tmp_store.rhs_value / tmp_store.value;
    }
  
  null_tmp_store();
} /* store_bounds */

/* ========================================================================= */


/*
 * reallocates eta
 */
void resize_eta(void)
{
  Cur_eta_size *= 2;
  if (Verbose)
    printf("Resizing Eta_value and Eta_rownr, new size is %d\n", Cur_eta_size);
  if(!(Eta_value = realloc(Eta_value, Cur_eta_size * sizeof(double))))
    {
      fprintf(stderr, "Error: cannot realloc Eta_value to size %d (entries)\n",
	      Cur_eta_size);
      exit(1);
    }
  if(!(Eta_rownr = realloc(Eta_rownr, Cur_eta_size * sizeof(int))))
    {
      fprintf(stderr, "Error: cannot realloc Eta_rownr to size %d (entries)\n",
	      Cur_eta_size);
      exit(1);
    }
} /* resize_eta */




/*
 * transport the data from the intermediate structure to the sparse matrix
 * and free the intermediate structure
 */
void readinput(int *cend,
	       double *rh,
	       short *relat,
	       double *lowbo,
	       double *upbo,
	       matrec *mat,
	       nstring *names)
{
  int    i, j, k, index, nn_ind;
  column *cp,*tcp;    /* tcp (temporary cp) points to memory-space to free */
  hashelem *hp,*thp;
  bound *bp;
  int   x;
  rside *rp;
  intrec *irp;
  
  /* initialize lower and upper bound arrays */
  for (i = 0; i <= Sum; i++)
    {
      lowbo[i] = 0;
      upbo[i] = INFINITE;
    }
  
  /* fill names with the rownames */
  for (i = 0; i <= Rows; i++)
    {
      /* the first row is row zero (the objective function)             */
      sprintf(names[i], "%s%d", STD_ROW_NAME_PREFIX, i);
    }
  
  for (i = Rows;i >= 0;i--)
    {
      rp = First_rside;
      relat[i] = rp->relat;
      rh[i] = rp->value;
      First_rside = rp->next;
      free(rp);  /* free memory when data has been read */
    }
  
  /* change upperbound to zero if the relational operator is the equal sign */
  for (i = 1; i <= Rows; i++)
    if (relat[i] == EQ)
      upbo[i] = 0;
  
  /* start reading the Hash_list structure */
  index = 0;
  nn_ind = 0;
  
  for (i = 0;i < HASH_SIZE;i++)
    {
      hp = Hash_tab[i];
      while (hp != NULL)
        {
	  /* put an index in the cend array when a new name is found */
	  cend[index++] = nn_ind;

	  /* check if it must be an integer variable */
	  if(hp->must_be_int)
	    {
	      CALLOC(irp, 1, intrec);
	      irp->varnr = Rows + index;
	      irp->next  = First_int;
	      First_int  = irp;
	    }
	  /* check for bound */
	  if (hp->bnd != NULL)
	    {
	      bp = hp->bnd;
              lowbo[Rows+index] = bp->lowbo;
              upbo[Rows+index] = bp->upbo;
              free(bp); /* free memory when data has been read*/
	    }
	  
	  /* copy name of column variable */
	  strcpy(names[Rows+index], hp->colname);

	  /* put matrix values in sparse matrix */
          cp = hp->col;
          while (cp!=NULL)
            {
              mat[nn_ind].rownr = cp->row;
	      mat[nn_ind].value = cp->value;
	      nn_ind++;
	      tcp = cp;
	      cp = cp->next;
	      free(tcp);  /* free memory when data has been read */
	    }
	  thp = hp;
	  hp = hp->next;
          free(thp);    /* free memory when data has been read */
        }
    }
  cend[index] = nn_ind; 
  
  if (Verbose)
    {
      printf("\n");
      printf("**********Data read**********\n");
      printf("Rows    : %d\n", Rows);
      printf("Columns : %d\n", Columns);
      printf("Nonnuls : %d\n", Nonnuls);
      printf("\nSparse Matrix\nRow right hand side\n");
      printf("%4s  %8s %3s %s\n\n", "nr", "row", "rel", "Value");
      for (i = 0; i <= Rows; i++)
	{
	  printf("%4d  %8s ", i, names[i]);
	  if (relat[i] == LE) printf(" < ");
	  if (relat[i] == EQ) printf(" = ");
	  if (relat[i] == GE) printf(" > ");
	  if (relat[i] == OF) printf("ObF");
	  printf(" %f\n", rh[i]);
	}
      
      printf("\nMatrix contents\n%8s  %8s  %s\n\n","colname","row","value");
      j = 0;
      for (i = 0; i < Nonnuls; i++)
	{
	  if (i == cend[j])
	    printf("%8s  %8s  %f\n", names[Rows+ ++j], names[mat[i].rownr],
		   mat[i].value);
	  else
	    printf("          %8s  %e\n", names[mat[i].rownr], mat[i].value);
	}
      printf("\nBounds\n%8s %3s %s\n\n", "name", "rel", "value");
      for (i = 0; i <= Sum; i++)
	{
	  if (upbo[i] < (INFINITE/10000))  /* double is to small to contain
					      INFINITE thus is rounded */
	    printf("%8s  <  %f\n", names[i], upbo[i]);
	  if (lowbo[i] > 0)
	    printf("%8s  >  %f\n", names[i], lowbo[i]);
	}
      
      printf("\n**********End data**********\n\n");
    }
} /* readinput */


/* ===================== END OF read.c ===================================== */

