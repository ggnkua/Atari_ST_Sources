WS   [ \n\t]+
LT   [A-Za-z]
KR   [A-Za-z0-9_]
DI   [0-9]
NM   {DI}*\.?{DI}+([Ee][-+]?{DI}+)?
VR   {LT}{KR}*"'"?
S_OP [-+ \t\n]+		
LOG  [<>]?=?	

%start COMMENT

%%
<INITIAL>"/*"				{
           BEGIN COMMENT;		} /* begin skip comment */

<COMMENT>"*/"				{
           BEGIN INITIAL;		} /* end skip comment */

<COMMENT>.                              {
                                        }

<COMMENT>\n                             {
                                        }

<INITIAL>{WS}                           {
                                        }

<INITIAL>","                            {
	return(COMMA);
                                        }

<INITIAL>{NM}				{
        sscanf(yytext,"%lf",&f);
        return(CONS);                  
                                        } /* f contains the last float */

<INITIAL>{S_OP}				{ Sign=0;
					  for(x=0;x<yyleng;x++)
					    if(yytext[x]=='-'||yytext[x]=='+')
					      Sign=(Sign==(yytext[x]=='+'));
					  return (SIGN);
					/* Sign is TRUE if the sign-string
					   represents a '-'. Otherwise Sign
					   is FALSE */
					}


<INITIAL>{VR}				{
          {strcpy(Last_var, yytext);}
          return(VAR);
                                        }

<INITIAL>"*"				{
          return(AR_M_OP);		}

<INITIAL>{LOG}				{
          return(RE_OP);		}

<INITIAL>";"				{
          return(END_C);		}

<INITIAL>.				{
          fprintf(stderr,"LEX ERROR : %s lineno %d \n" ,yytext,yylineno);     }

%%
