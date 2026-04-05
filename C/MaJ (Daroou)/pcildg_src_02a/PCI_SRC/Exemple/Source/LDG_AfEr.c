
VOID affiche_ldg_error( LONG erreur )
{
	char	texte[256];



	strcpy( texte, "[1]" );

	switch( erreur )
	{
		case LDG_LIB_FULLED:
			strcat( texte, "[Impossible de charger une|nouvelle LDG]");
			break;
		case LDG_APP_FULLED:
			strcat( texte, "[Impossible de g‚rer un|nouveau client]");
			break;
		case LDG_ERR_EXEC:
			strcat( texte, "[La LDG n'est pas un|ex‚cutable GEMDOS");
			break;
		case LDG_BAD_FORMAT:
			strcat( texte, "[La LDG a un mauvais format|ou n'est pas reconnu]");
			break;
		case LDG_LIB_LOCKED:
			strcat( texte, "[La LDG demand‚ est v‚rouill‚]");
			break;
		case LDG_NOT_FOUND:
			strcat( texte, "[La LDG n'est pas install‚e|ou introuvables...]" );
			break;
		case LDG_NO_MEMORY:
			strcat( texte, "[LDG: Plus assez de m‚moire]");
			break;
		case LDG_NO_TSR:
			strcat( texte, "[Gestionnaire LDG (TSR)|non install‚]");
			break;
		case LDG_BAD_TSR:
			strcat( texte, "[Mauvais gestionnaire LDG]");
			break;
		case LDG_NO_FUNC:
			strcat( texte, "[Au moins une fonction LDG|est introuvable...]" );
			break;
		default:
			sprintf( texte, "[1][LDG: erreur inconnu.| |erreur=%ld ]",erreur );
			break;
	}

	strcat( texte, "[  Ok  ]" );

	form_alert ( 1, texte );

}