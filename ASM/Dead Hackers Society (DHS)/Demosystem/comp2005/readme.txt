Onlinecompo 2005 - ST demoscreen competition

Testing enviornment and example source



* A loader that is similar to what will be used in the 
  final megademo. The loader here has a ten kilobytes
  extra BSS-buffer just to be on the safe side memory
  wise to the final loader.
  
* A simple main menu from where you can launch your demo
  and see how it works. Your demo needs to be called 
  "dmo.bin" and placed in the same folderas "men.bin". 
  Please UPX pack it for authentic results. UPX can
  be downloaded from http://upx.sf.net/.
  
* For 1MB users, you can assume that loader.prg is placed in
  the auto-folder without anything else started (including
  harddisk drivers). You should be able to use something like
  900k memory for your screen, exact testing is up to you.

* For >1MB users, loader.prg is also present in the root
  directory. The idea is that it should work from harddisk
  as well with this loader. So make sure that your contrib
  restores vectors and timers properly.

* Example source, this is just a simple setup source that
  gives you a double-buffering screen, SNDH player and 
  clean return to desktop. It works on ST, STe and Falcon.
  You're free to use the source as-is, or take parts of it
  as help. The example source is however not required to be
  used by the screens.

