This is the root folder for languages management.
If you want to translate VISION into any other language:

1. Create a sub folder for the new language (e.g ITALIAN)

2. Copy VISION.RSC, VISIONB.RSC and VMSG.TXT (from any
   existing translated folder) into this new sub folder

3. Use a ressource editor (Interface is pretty good) and
   translate these 2 resource files and text messages


NOTES:

1. At start, VISION looks for sub folders into this directory,
   when it founds one, it checks if VISION.RSC, VISIONB.RSC
   and VMSG.TXT are present, and if so it adds the name of this
   folder into the available languages.

2. Be careful when translating to NOT CHANGE any object ID !
   This may crash VISION !

3. To check against vmsg.txt consistency, use chkmsg.prg:
   chkmsg.prg: check against DEUTSCH, ENGLISH, FRANCAIS, ITALIAN and SVENSKA language consistency
   chkmsg.prg <lang1> <lang2> ...: check against <lang1> <lang2> consistency

4. For an unknown reason, it seems that it is better to save
   VISION.RSC in 1024 * 768 (4 planes) resolution and VISIONB.RSC
   in 456 * 416 (TC) or some forms will look bad in high resolutions.


   Please send me any translation you make !!!


   Have fun, Jean

   E-Mail : vision.support@free.fr