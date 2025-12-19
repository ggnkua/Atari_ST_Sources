/*  *** readval.c ***  27.11.90 */

#include "rayscene.h"

#define ERROR(a) {error_str = a; goto exit99;}
#define C_COMMENT      '#'
#define C_END_OF_NAME  '/'
#define C_END_OF_GROUP ','
#define MAX_GROUP_SIZE 50     

int FindStart(void);
int PrintMissingVars(int read_count,char *var_tmp);

readval()
{
    float in_val;
    char *name_tmp, *var_tmp;
    
    int *var_ind;
    int c,i,j,k,name_count,val_count,read_count=0;
    

    putchar('\n');   
    if ((stream = fopen(arr_name,"r"))==NULL)      /* Open array-file */
        ERROR("Couldn't open array-file")
    if ((name_tmp = (char *) malloc(MAX_VAR_LENGTH + 1))==NULL)
        ERROR("Out of memory")
    if ((var_ind = (int *) malloc(MAX_GROUP_SIZE * sizeof(int)))==NULL)
        ERROR("Out of memory")
    if ((var_tmp = (char *) malloc(var_count))==NULL)
        ERROR("Out of memory")
    
    memset(name_tmp, '\0', MAX_VAR_LENGTH + 1);     /* empty name buffer */
    memset(var_tmp,  '\0', var_count);              /* no variables found */
    
    do 
    {
        if (FindStart())
        {
            PrintMissingVars(read_count,var_tmp);
            ERROR("Unexpected end of file")
        } 

                    /* Read variable names that are grouped */  
        name_count = k = 0; 
        do
        {
                    /* Read variable name */  
            i=0;
            do 
            {
                c = fgetc(stream);
                if (c == EOF)
                {
                    PrintMissingVars(read_count,var_tmp);
                    ERROR("Unexpected end of file")
                }
                if (c != C_END_OF_NAME  &&  c != C_END_OF_GROUP)   
                {
                    if (i >= MAX_VAR_LENGTH)
                    {
                        printf("%s\n", name_tmp );
                        ERROR("Variable name too long")
                    }
                    *(name_tmp + i) = (char) c;
                    i++;
                }
            } while( c != C_END_OF_NAME  && c != C_END_OF_GROUP );
            
            *(name_tmp + i) = 0;
            
                
                        /* find index for name */
            
            *(var_ind + name_count ) = -1;      /* default: no index */
            for(i=0; i<var_count; i++)
            {
                if (!(strnicmp(name_tmp, names + i * MAX_VAR_LENGTH,
                                                     MAX_VAR_LENGTH)))
                {
                    *(var_ind + name_count) = i;
                    *(var_tmp + i) = 1;         /* variable found */
                    k++;
                    read_count++;
                    break;
                } 
            }
            name_count++;

        } while ( c != C_END_OF_GROUP );
        
        if (!(fscanf(stream,"%d",&val_count)))
        {
            printf("Variable(s)  ");
            for(i=0; i< name_count; i++)
            {
                j = *(var_ind + i);
                if (j != -1)
                    printf(" %s ", names + (j * MAX_VAR_LENGTH));
            }
            ERROR("\nCouldn't read array size")
        }
        if (val_count < 1)
        {
            printf("Variable(s)  ");
            for(i=0; i< name_count; i++)
            {
                j = *(var_ind + i);
                if (j != -1)
                    printf(" %s ", names + (j * MAX_VAR_LENGTH));
            }
            ERROR("\nArray size can't be < 1 !")
        }
        
                   /*  if we are going to read values from this group, 
                        check that there are enough of them */
        if (k)  
        {
            if (val_count < count)
            {
                for(i=0; i<name_count; i++) 
                {
                    j = *(var_ind + i);
                    if ( j >= 0)
                        break;
                }
                printf("%d < %d\n",val_count,count);
                printf("Variable  %s  ",names + j * MAX_VAR_LENGTH);
                ERROR("doesn't have requested number of values")
            }
        }
            
            /* Read the values from file */
            
        for(i=0; i<val_count; i++)  
        {
            if (FindStart())
            {
                for(k=0; k<name_count; k++) 
                {
                    j = *(var_ind + k);
                    if ( k >= 0)
                        break;
                }
                printf("Variable %s: %d values still unread\n",
                    names + (j * MAX_VAR_LENGTH), (val_count - i));
                ERROR("Unexpected end of file")
            } 
            for(j=0; j<name_count; j++)
            {
                if(!(fscanf(stream,"%f",&in_val)))
                {
                    printf("%s[%d]\n",(name_tmp+j*(MAX_VAR_LENGTH+1)),i);
                    ERROR("Couldn't read value!")
                }
                                        /* Do we need this value? */
                k = *(var_ind + j);
                if ( k >= 0  &&  i < count)
                {
                    *(values + i + k * count) = in_val;
                } 
            }
        }
    } while (read_count < var_count); 
    
    return(0);
    
exit99:
    printf("%s\n",error_str);
    exit(10);
    return(1);
}


/* Skips comments and white space */

int FindStart(void)
{
    int c;
    
    do                            
    {
        c = fgetc(stream);
        if (c == C_COMMENT)
        {
            do  
                c = fgetc(stream);
            while( c != EOF && c != C_COMMENT );
            c = fgetc(stream);     
        }
    } while( c != EOF && isspace(c) );
    
    if (c == EOF)
        return(10);
    else 
    {
        ungetc(c,stream);
        return(0);
    }
}


/* Print variable names that we haven't found */

PrintMissingVars(read_count,var_tmp)
int read_count;
char *var_tmp;
{
    int i;
    
    printf("%d variables still unread:\n",(var_count - read_count));
    for(i=0; i<var_count; i++)
    {
        if (*(var_tmp + i) == 0)
            printf("\t %s\n", names + (i * MAX_VAR_LENGTH));
    }

    return(0);    
}
