

LONG test_cookies( ULONG val_cookie )
{
	LONG	adr_super;
	ULONG	*pt_cookie;


	adr_super=Super(0L);	/* On passe en mode Superviseur */

	pt_cookie=(ULONG *)(*( (ULONG *)0x5A0L));	/* On recupere l'adresse de la table */
												/* des cookies                       */

	(VOID)Super(adr_super);	/* On repasse en mode Utilisateur */


	if(!pt_cookie)  return(FALSE);

	while(*pt_cookie)
	{
		if	(*pt_cookie == val_cookie)
		{
			return(TRUE);
		}
		pt_cookie += 2;
	}

	return(FALSE);


}

