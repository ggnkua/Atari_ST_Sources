/**[Fonction commune]***************/
/* Fonction GFA adapt‚             */
/* 21/08/2013 # 21/08/2013         */
/***********************************/


/* Prototype */
void Fcm_bmove( const char *source, const char *destination, int nombre );


/* Fonction */
void Fcm_bmove( const char *source, const char *destination, int nombre )
{

    char *pt_source       = (char *)source;
    char *pt_destination  = (char *)destination;


    printf(CRLF"* Fcm_Bmove *"CRLF);


    printf("source=%p  destination=%p   nombre=%d "CRLF, source, destination, nombre );

/*    printf("source=%s\n", source);
    printf("destination=%s\n", destination);*/

/*    printf("Copie de: "CRLF);*/

    for( ; nombre>0; nombre--)
    {
/*	    printf("%c-", *pt_source);*/
        *pt_destination++ = *pt_source++;
    }

    printf(CRLF"source=%p  destination=%p   nombre=%d "CRLF, source, destination, nombre );

/*    printf("source=%s"CRLF, source);
    printf("destination=%s"CRLF, destination);*/

    return;

}
