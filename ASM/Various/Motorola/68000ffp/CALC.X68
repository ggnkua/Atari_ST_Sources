* Motorola Fast Floating Point
*   Desk Calculator
* EASy68K I/O, EASy68K assembler

          ORG       $001000
START     BRA.L     MAIN
          INCLUDE   'FFPCPYRT.X68'
          INCLUDE   'IOEASY.X68'
          INCLUDE   'FFPADD.X68'
          INCLUDE   'FFPMUL.X68'
          INCLUDE   'FFPDIV.X68'
          INCLUDE   'FFPSQRT.X68'
          INCLUDE   'FFP10TBL.X68'
          INCLUDE   'FFPDBF.X68'
          INCLUDE   'FFPAFP.X68'
          INCLUDE   'FFPFPA.X68'
          INCLUDE   'FFPTNORM.X68'
          INCLUDE   'FFPTHETA.X68'
          INCLUDE   'FFPSIN.X68'
          INCLUDE   'FFPABS.X68'
          INCLUDE   'FFPCMP.X68'
          INCLUDE   'FFPARND.X68'
          INCLUDE   'FFPFPI.X68'
          INCLUDE   'FFPIFP.X68'
          INCLUDE   'FFPHTHET.X68'
          INCLUDE   'FFPATAN.X68'
          INCLUDE   'FFPEXP.X68'
          INCLUDE   'FFPLOG.X68'
          INCLUDE   'FFPPWR.X68'
          INCLUDE   'FFPSINH.X68'
          INCLUDE   'FFPCALC.X68'
MAIN      BRA       FFPCALC
          END       START
