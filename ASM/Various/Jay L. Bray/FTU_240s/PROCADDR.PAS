{ -----------------------------------------------------------------------------

                                 NOTICE:

      THESE MATERIALS are UNSUPPORTED by OSS!  If you do not understand how to
      use them do not contact OSS for help!  We will not teach you how to 
      program in Pascal.  If you find an error in these materials, feel free
      to SEND US A LETTER explaining the error, and how to fix it.

      THE BOTTOM LINE:

         Use it, enjoy it, but you are on your own when using these materials!


                               DISCLAIMER:

      OSS makes no representations or warranties with respect to the contents
      hereof and specifically disclaim all warranties of merchantability or
      fitness for any particular purpose.   This document is subject to change
      without notice.
      
      OSS provides these materials for use with Personal Pascal.  Use them in
      any way you wish.

   -------------------------------------------------------------------------- }


{***************************************************************************

        Module to be linked with your program.  WILL NOT RUN AS-IS!

        You must declare Proc_addr in your program as follows:

           FUNCTION Proc_addr( PROCEDURE p ) : Long_Integer; External;

        Link into your program using "Additional Link Files" in
        LINKER OPTIONS BOX.

        October 1, 1986 MJC
        Copyright 1986 OSS, Inc.

****************************************************************************}

{$m+,e+,d-}
PROGRAM Procaddr;

   FUNCTION Proc_addr( scope_link, address: Long_Integer ) : Long_Integer;

      BEGIN
         Proc_addr := address;
      END;

BEGIN
END.
{ END OF PROCADDR.PAS }

