
# include "y1.h" 

void summary( )
{
  /* output the summary on the tty */

  if ( foutput != NULL )
    {
      fprintf( foutput,
               "\n%d/%d terminals, %d/%d nonterminals\n",
               ntokens,
               NTERMS,
               nnonter,
               NNONTERM );
      fprintf( foutput,
               "%d/%d grammar rules, %d/%d states\n",
               nprod,
               NPROD,
               nstate,
               NSTATES );
      fprintf( foutput,
               "%d shift/reduce, %d reduce/reduce conflicts reported\n",
               zzsrconf,
               zzrrconf );
      fprintf( foutput,
               "%d/%d working sets used\n",
               ( int )( zzcwp - wsets ),
               WSETSIZE );
      fprintf( foutput,
               "memory: states,etc. %d/%d, parser %d/%d\n",
               ( int )( zzmemsz - mem0 ),
               MEMSIZE,
               ( int )( memp - amem ),
               ACTSIZE );
      fprintf( foutput,
               "%d/%d distinct lookahead sets\n",
               nlset,
               LSETSIZE );
      fprintf( foutput,
               "%d extra closures\n",
               ( int )( zzclose - 2 * nstate ) );
      fprintf( foutput,
               "%d shift entries, %d exceptions\n",
               zzacent,
               zzexcp );
      fprintf( foutput, "%d goto entries\n", zzgoent );
      fprintf( foutput, "%d entries saved by goto default\n", zzgobest );
    }
  if ( zzsrconf != 0 || zzrrconf != 0 )
    {
      fprintf( stdout, "\nconflicts: " );
      if ( zzsrconf )
        fprintf( stdout, "%d shift/reduce", zzsrconf );
      if ( zzsrconf && zzrrconf )
        fprintf( stdout, ", " );
      if ( zzrrconf )
        fprintf( stdout, "%d reduce/reduce", zzrrconf );
      fprintf( stdout, "\n" );
    }

  if ( ftemp != NULL )
    fclose( ftemp );
  if ( fdefine != NULL )
    fclose( fdefine );
}
