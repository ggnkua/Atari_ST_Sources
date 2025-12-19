BEGIN		{printf("struct {int n; char *name;} tok_tab[] = {\n");}
/# define/	{printf("    {%d, \"%s\"},\n", $4, $3);}
END		{printf("};\n#define N_TOK (sizeof tok_tab / sizeof tok_tab[0])\nint n_tok = N_TOK;\n");}
