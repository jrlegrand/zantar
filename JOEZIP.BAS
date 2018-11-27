1
CLS
PRINT "What kind of operating system do you have?"
PRINT "  1.) Windows 95"
PRINT "  2.) Windows 98"
PRINT "  3.) Windows XP"
PRINT "  4.) Mac OS"
INPUT theOS
IF theOS < 1 OR theOS > 4 THEN GOTO 1

IF theOS = 3 THEN
   INPUT "Type your Windows XP profile as it appears on your computer"; theProf$
   SHELL "copy a:*.pif c:\docume~1\" + theProf$ + "\desktop"

ELSEIF theOS = 4 THEN
   PRINT "Sux to be u!  Get a real computer, NERD!": END
END IF

SHELL "md c:\Zantar"

SHELL "copy a:*.* c:\Zantar"

PRINT "CONGRATULATIONS!!! You are now a proud owner of Zantar!"
PRINT "A shortcut has been placed on your desktop"
PRINT "Enjoy!"
PRINT "~Joey"

