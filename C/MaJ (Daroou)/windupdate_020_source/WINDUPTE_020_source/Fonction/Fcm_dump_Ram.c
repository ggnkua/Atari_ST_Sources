/* **[Fonction commune]********** */
/* *                            * */
/* * 11/05/2002 :: 06/04/2004   * */
/* ****************************** */



#define MODE 1


VOID Fcm_dump_ram( const ULONG adresse );


VOID Fcm_dump_ram( const ULONG adresse )
{
	UCHAR *pt_ram;
	WORD ligne,colonne;
	CHAR buffer_dump[256];
	CHAR buffer_char[32];



	sprintf( buf_log, "#Fcm_dump_ram(%08lx)"CRLF, adresse);
	log_print(FALSE);

	sprintf( buf_log, "========================================================="CRLF);
	log_print(FALSE);

	pt_ram=(UCHAR *)(adresse-256);

	for( ligne=0; ligne<4; ligne++)
	{
		sprintf( buffer_dump, "$%08lx: ", (ULONG)pt_ram);

		for( colonne=0; colonne<64; colonne++)
		{

			switch( MODE )
			{
				case 1:	/* hexa */
					sprintf( buffer_char, "%02x ", *pt_ram);
					break;
				case 2: /* ASCII */
					if( *pt_ram>31 )
					{
						sprintf( buffer_char, "%c", *pt_ram);
					}
					else
					{
						sprintf( buffer_char, "." );
					}
					break;
			}
			strcat ( buffer_dump, buffer_char);
			pt_ram++;

		}

		strcpy( buf_log, buffer_dump);
		log_print(FALSE);

		sprintf( buf_log, CRLF);
		log_print(FALSE);
	}


	sprintf( buf_log, CRLF);
	log_print(FALSE);


	sprintf( buf_log, "----------------------------------------------------------------"CRLF);
	log_print(FALSE);


	pt_ram=(UCHAR *)adresse;

	for( ligne=0; ligne<4/*60*/; ligne++)
	{
		sprintf( buffer_dump, "$%08lx: ", (ULONG)pt_ram);

		for( colonne=0; colonne<64; colonne++)
		{

			switch( MODE )
			{
				case 1:	/* hexa */
					sprintf( buffer_char, "%02x ", *pt_ram);
					break;
				case 2: /* ASCII */
					if( *pt_ram>31 )
					{
						sprintf( buffer_char, "%c", *pt_ram);
					}
					else
					{
						sprintf( buffer_char, "." );
					}
					break;
			}
			strcat ( buffer_dump, buffer_char);
			pt_ram++;

		}

		strcpy( buf_log, buffer_dump);
		log_print(FALSE);

		sprintf( buf_log, CRLF);
		log_print(FALSE);

	}



	sprintf( buf_log, "========================================================="CRLF);
	log_print(FALSE);

	return;

}

#undef MODE

