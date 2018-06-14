====================================================
Atari ST file manager for HxC SdCard Floppy Emulator
====================================================
This is the release note for the 2.00 beta 1 version of the manager
This is a major rewrite of the manager. Almost everything has been rewritten, so some bugs may have passed though initial testings. This version also change many things, many keys have been replaced, there are some new behaviours, so it will definitely breaks your habits.


Behaviour changes
-----------------
 * Changes are always saved (see Quit menu)
 * Save includes the selected slot number. After reboot, the HxC will go directly to the selected slot.


Keys changes
------------
====================================== ===================================================================
Before                                 New
====================================== ===================================================================
Undo (select the next slot)            replaced by Right (next slot)
Backspace (clear the current slot)     replaced by Delete (clear slot)
Delete (clear curr. slot, next slot)   replaced by Delete (clear slot), then Right (next slot)
Caps Lock (go back to top of folder)   (wasn't working). Replaced by Control-Up (go to first page)
Pipe (insert in A:, next slot)         replaced by Insert (insert in A:), then Right (next slot)
left/right (go prev/next page)         replaced by Shift Up/down. (page up/down)
F3 (setting menu)                      replaced by F4 (settings menu)
F8 (reboot)                            replaced by Undo (revert changes), Esc (Quit menu), then R (reboot)
F9 (save)                              replaced by Ctrl-S (save)
F10 (save, reboot)                     replaced by Esc (Quit menu), then R (reboot)
====================================== ===================================================================


New keys
--------
====================================== ===================================================================
Key                                    Effect
====================================== ===================================================================
 Ctrl-S                                save change
 F1                                    "search" is now called "filter" (same feature)
 F3                                    File viewer
 Tab                                   Slots manager
 Undo                                  Revert changes
 Backspace                             go to parent folder
 Left/Right                            Browse the slots
 Ctrl-Left/Right                       go to first/last slot
 Shift-Up/Down                         go to the previous/next page of the files list
 Ctrl-Up/Down                          go to the first/last page of the files list
 Esc                                   Quit menu
 [0-9a-z]                              Instajump
 Alt-F4                                Loose changes and exit
====================================== ===================================================================


New Features
------------
* **Instajump** : type the beginning of a file, and the cursor will jump to it.

* **Slots manager** : This is an improved version of the "View All Slots". It is accessed with the TAB key. It allows Copy/Cut/Paste slots (with the standard Ctrl-X/C/V), inserting and deleting a slot. Most of the standard keys are available in this view (including Esc (*Quit menu*), Undo (*revert changes*) and F7 (*insert, save, quickboot*)). It is also a quick way to choose the slot to boot to.

* **Sorting** : The files are now always alphabetically sorted. Dirs are always listed first. This is a big usability plus. You can no longer see the unordered list of file.

* **File viewer** : can view text file, or binary file (in hex mode). It tries to guess if the file is binary/text. Ability to scroll up/down. Shift-Up/Down: skip 10 pages and Ctrl-Up/Down (first/last page) is supported. Switch text/hex mode with F2.

* **Quit menu** : The F8 (*reboot*), F9 (*save*), F10 (*save, reboot*) have all been replaced by "Esc" (*Quit menu*). From there, you can choose either Quit, Reboot and Fastboot (more on this later). If they are changes, the menu tell you so. The new behaviour is to always save your changes. To not save your change, you must "revert" your changes. This can be done by pressing "Undo". Undo works in the quit menu, in the main screen, and in the slots manager. F7 (*insert, save, quickboot*) is still available, though.

* **Fastboot** : this is only available when the manager has been loaded with the bootloader. (AUTOBOOT.HFE mode). This is the same as Reboot, only faster. Especially on Tos >=2.5, it can reduce boot time by several seconds. This is a hack, and even if it *should* work everywhere, I choose to let the possibility to use normal Reboot instead.

* Support for **extended resolutions**. Tested up to 1280x960 in 16-color mode. It means that the manager finally uses all the screen real-estate in monochrome mode. It *should* work 256-color mode (not tested). It has not been tested on Falcon or with fancy graphic card. Note that only bitplane-based color modes are supported, i.e. it will not work in true color on Falcon.

* Ability to **Quit without rebooting** (only when the manager is started from the desktop with HXCFEMNG.PRG)

* Alt-F4 almost always quit/reboot the manager, even when a fatal error occurs. (the manager no longer locks up). This key is available almost everywhere. It's a shortcut for *Loose change and exit*.


Changes
-------
* Many, many optimisations. Most actions are quicker. The manager still loads in less than 2 seconds.

* Huge directory support. Testing with directories with 6000+ files.

* File list: the "." folder is no longer showed

* File list: no icon is shown before regular files (it makes viewing directories easier)

* the search filter is kept when navigating through folders.

* File list show the current page number, and the total pages.

* More space for current directory

* The manager is more colorful. New color schemes. New default color scheme.

* "Busy" character no longer flickers. It is also displayed while filtering.

* Version numbering: the new scheme is now 2.01a where "2" is the major version, it will only upgrade on really important new feature, "0" will upgrade on new feature, "1" for minor feature addition, change or improvement, and "a" is used for bugfix and small changes.



Notes
-----
* With NVDI, the mouse cursor might not be hidden. You'll have to use the NVDI configuration program (CPX) and enable Line-A under the compatibility tab.

