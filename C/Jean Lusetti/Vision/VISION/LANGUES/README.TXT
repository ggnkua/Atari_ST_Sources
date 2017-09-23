This is the root folder for languages management.
If you want to translate VISION into any other language:

1. Create a sub folder for the new language (e.g ITALIAN)

2. Copy VISION.RSC, VISIONB.RSC and VMSG.RSC (from any
   existing translated folder) into this new sub folder

3. Use a ressource editor (Interface is pretty good) and
   translate this 3 resource files


NOTES:

1. At start, VISION looks for sub folders into this directory,
   when it founds one, it checks if VISION.RSC, VISIONB.RSC
   and VMSG.RSC are present, and if so it adds the name of this
   folder into the available languages.

2. Be careful when translating to NOT CHANGE any object ID !
   This may crash VISION !

3. Be careful when translating VMSG.RSC to respect the GEM syntax
   of message boxes (msg with '[' and ']' caracters). As GEM does
   not provide any control, this may crash VISION !

4. For an unknown reason, it seems that it is better to save
   VISION.RSC in 1024 * 768 (4 planes) resolution and VISIONB.RSC
   in 456 * 416 (TC) or some forms will look bad in high resolutions.


   Please send me any translation you make !!!


   Have fun, Jean

   E-Mail : j-lusetti@usa.net