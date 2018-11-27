DECLARE SUB Instructions ()
DECLARE SUB GetUpgraded (w%)
DECLARE SUB PutTheBulletBackground (m%)
DECLARE SUB GetTheBulletBackground (m%)
DECLARE SUB PLACE (kind$, px%, py%)
DECLARE SUB NewBG (myBG%())
DECLARE SUB SNOOZE (delay!)
DECLARE SUB Hablar (a$(), b%, e%)
DECLARE SUB PlayIntro ()
DECLARE SUB CONVERT (a%, b%)
DECLARE SUB GETMASK (a%, b%)
DECLARE SUB GetMyPics ()
DECLARE SUB LoadAsm ()
DECLARE SUB OPENBMP (FileName$)
DECLARE FUNCTION ClosestColor% (Red%, Green%, Blue%)
DECLARE SUB MemCopyBD (FromSeg%, FromOff%, ToSeg%, ToOff%, Bytes%)

TYPE BMPHeader
   ValidID AS STRING * 2          '/* Must be 'BM'
   SizeOfFile AS LONG             '/* Size of entire file in bytes
   Reserved AS LONG               '/* Four empty bytes
   OffsetOfBitMap AS LONG         '/* The location in the file where the
                                  '   image data is located
END TYPE

TYPE OS2Ver1InfoHeader
   SizeOfHeader AS LONG           '/* Size of Information Header [12]
   Widthz AS INTEGER              '/* Width of image in pixels
   Heightz AS INTEGER             '/* Height of image in pixels
   Planes AS INTEGER              '/* Number of Planes. Must be '1'
   BitsPerPixel AS INTEGER        '/* Number of bits per pixel
                                  ' Possible values are 1, 4, 8, 16, 24, 32
END TYPE

TYPE WindowsInfoHeader
   SizeOfHeader AS LONG        '/* Size of Information Header [40]
   Widthz AS LONG              '/* Width of image in pixels
   Heightz AS LONG             '/* Height of image in pixels
   Planes AS INTEGER           '/* Number of Planes. Must be '1'
   BitsPerPixel AS INTEGER     '/* Number of bits per pixel
                               ' Possible values are 1, 4, 8, 16, 24, 32
   CompressMethod AS LONG      '/* Compression Method
                               ' 0 - Uncompressed
                               ' 1 - 8 Bit RLE Compression
                               ' 2 - 4 Bit RLE Compression
   ImageSizeInBytes AS LONG    '/* Size of image in bytes
   HorizontalResol AS LONG     '/* Horizontal Resolution
   VerticalResol AS LONG       '/* Vertical Resolution
   ColorsUsed AS LONG          '/* Number of Colors used | 0 - All Used
   ImportantColors AS LONG     '/* Number of Important Colors
END TYPE

'$DYNAMIC

DEFINT A-Z
DIM SHARED ASM$, ArrayNo, ColorDif
DIM SHARED PixelArray(2000, 3), ColorPalette(255, 3)

ON ERROR GOTO Errrr

CLS
CHDIR "c:\zantar\"

OPEN "c:\zantar\hiscore.zan" FOR INPUT AS #1
INPUT #1, theInitials$, theHiScore
CLOSE

DIM welcome(13000)
CALL OPENBMP("welc.bmp")
GET (0, 0)-(205, 63), welcome
CLS

displayWelcomeScreen:

LINE (0, 28)-(50, 55), 2
LINE (0, 58)-(60, 75), 2
LINE (0, 95)-(60, 85), 2
iw = 195
LINE (319, 138)-(50 + iw, 103), 2
LINE (319, 102)-(60 + iw, 93), 2
LINE (319, 70)-(60 + iw, 80), 2

PUT (50, 50), welcome, PSET

LINE (319, 35)-(58 + iw, 63), 2
LINE (0, 129)-(50, 100), 2

LINE (95, 118)-(212, 118), 4
LINE (95, 128)-(212, 128), 4

COLOR 4
LOCATE 16, 13: PRINT "PRESS ANY KEY!"
COLOR 1
LOCATE 23, 6: PRINT "Copyright (c) 2004 Grand Games"
COLOR 15

SLEEP
'GOTO dead

 FOR j = 1 TO 50 STEP 2
   LINE (95, 118)-(212, 119 + j), 4, BF
   LINE (96, 119)-(211, 118 + j), 0, BF
   SNOOZE .0000001
 NEXT

COLOR 4

DIM introScr$(4), tutOff

introScr$(0) = "  NEW GAME"
introScr$(1) = " HIGH SCORE"
introScr$(2) = "TUTORIAL(Y/N)"
introScr$(3) = "    QUIT"

LOCATE 17, 14: PRINT introScr$(0)
LOCATE 18, 14: PRINT introScr$(1)
LOCATE 19, 14: PRINT introScr$(2)

COLOR 12
IF tutOff <> 1 THEN
   LOCATE 19, 23: PRINT "Y"
ELSEIF totOff = 1 THEN
   LOCATE 19, 25: PRINT "N"
END IF
COLOR 4

LOCATE 20, 14: PRINT introScr$(3)

curs = 0
k$ = ""
begStrt:
DO: k$ = INKEY$: LOOP UNTIL k$ <> ""

oldcurs = curs
SELECT CASE k$
  CASE CHR$(0) + "P"
    IF curs < 3 THEN curs = curs + 1
  CASE CHR$(0) + "H"
    IF curs > 0 THEN curs = curs - 1
  CASE CHR$(32)
    IF curs = 0 THEN
       GOTO endStrt
    ELSEIF curs = 1 THEN
       GOSUB displayHighScores
    ELSEIF curs = 2 THEN
       IF tutOff = 0 THEN
         tutOff = 1
       ELSEIF tutOff = 1 THEN
         tutOff = 0
       END IF
    ELSEIF curs = 3 THEN
       COLOR 15
       SYSTEM
       END
    END IF

END SELECT

LOCATE 17 + oldcurs, 14: COLOR 4: PRINT introScr$(oldcurs)
LOCATE 17 + curs, 14: COLOR 14: PRINT introScr$(curs)

COLOR 12
IF tutOff = 0 THEN
   LOCATE 19, 23: PRINT "Y"
ELSEIF tutOff = 1 THEN
   LOCATE 19, 25: PRINT "N"
END IF
COLOR 4

GOTO begStrt

endStrt:
COLOR 15

ERASE welcome

bobbo:


'My Images
DIM SHARED dzant(400), dzantmask(400), lsold(400), lsoldmask(400)
DIM SHARED rsold(400), rsoldmask(400), usold(400), usoldmask(400)
DIM SHARED dsold(400), dsoldmask(400), xsold(400), xsoldmask(400)
DIM SHARED x2sold(400), x2soldmask(400), uzant(400), uzantmask(400)
DIM SHARED bglob(100), bglobmask(100), ammo(100), ammomask(100)
DIM SHARED umadsci(400), umadscimask(400), dmadsci(400), dmadscimask(400)

DIM SHARED lmgun(400), lmgunmask(400)
DIM SHARED rmgun(400), rmgunmask(400)
DIM SHARED umgun(400), umgunmask(400)
DIM SHARED dmgun(400), dmgunmask(400)
'Miscelanious
DIM SHARED table(800), tablemask(800), bullet(16), BG(400)
DIM SHARED chair(400), chairmask(400)
DIM SHARED plant(400), plantmask(400)
DIM SHARED fcab(400), fcabmask(400)
DIM SHARED udwall(10), lrwall(10), corner(25), title(949)
DIM SHARED square(16), medkit(100)
DIM SHARED mine(100), minemask(100), lmine(100), lminemask(100)
DIM SHARED metal(400), tile(400), diamond(400), checker(400)
DIM SHARED stairs(400), stairsmask(400)
DIM SHARED xplode(400), xplodemask(400)

DIM SHARED sbg1(16), sbg2(16), sbg3(16), sbg4(16), sbg5(16), sbg6(16)
DIM SHARED gbg1(1400), gbg2(1400), gbg3(1400), gbg4(1400)
DIM SHARED ammobar(1500), background(100)

'Variables
DIM SHARED shotFired, theDude, x, y
DIM SHARED farLeft, farRight, farTop, farBottom
DIM SHARED sx(10), sy(10), ox(20), oy(20), gx(10), gy(10)
DIM SHARED wx(50), wy(100)
DIM SHARED sbx(10), sby(10)
DIM SHARED realX, realY
DIM SHARED madscix(5), madsciy(5), totSci, SciTalk(5)
DIM SHARED minex(20), miney(20), totMines, mineBlown(20)
DIM SHARED gbulletx(4), gbullety(4)
DIM SHARED totSold, totObjects, totGunners, totPOW
DIM SHARED typeOfPow$(100), typeOfGunner$(100), typeOfScientist$(50)
DIM SHARED deadgunner(10), thec, powEaten(50), aRat, ratx, raty
DIM SHARED cx(30), cy(30), totCheese
DIM SHARED ratCurAmmo, ratTotAmmo, cheeseEaten(30)
CONST maxTimeStuck = 3, gunnerScore = 1000, ratScore = 5000, soldScore = 500


level = 0

x = 20: y = 80: Mx = 20: my = 20
totBlobs = 10: curBlobs = totBlobs
flag = 2
totHealth = 100
curHealth = totHealth
bulletDmg = 20
mineDmg = 20
throw = 2
blobDelay! = .03
soundOn = 0
minedelay! = .2
ratdelay! = .4
ratTotTimeVuln! = 3
score = 0
realX = -1
realY = -1

GetMyPics
CLS

IF tutOff = 0 THEN Instructions

GOSUB determinelevel
PlayIntro

RANDOMIZE TIMER
TIMER ON
ON TIMER(1) GOSUB MoveSold

' \/---PLACE TITLE AND AMMOBAR IN CORRECT POSITIONS

GOSUB determinelevel

DO
 DO

IF TIMER >= (minetime! + minedelay!) THEN GOSUB blinkMine: minetime! = TIMER

IF aRat = 1 THEN
  IF TIMER >= (rattime! + ratdelay!) THEN GOSUB moveRat: rattime! = TIMER
END IF

'IF deadsold = totSold AND deadgunners = totGunners THEN do nothing
 FOR z = 1 TO totPOW
 IF powEaten(z) <> 1 THEN
   powX = wx(z)
   powY = wy(z)
   SELECT CASE typeOfPow$(z)
     CASE "freeblob1"
      PUT (powX, powY), ammomask, AND
      PUT (powX, powY), ammo, OR
     CASE "medkit"
      PUT (powX, powY), medkit, PSET
   END SELECT
   END IF
 NEXT
  
   '### This block of code checks for collisions
   ' $$ If the blob collides with a wall or a person then actions are taken

   k$ = INKEY$

   GOSUB shootMGun

  IF ratShotFired = 1 AND ratVulnerable <> 1 THEN GOSUB shootCheese


' \/------CHECK FOR SOLDIER'S BULLET COLLISIONS
  FOR m = 1 TO totSold
   IF soldShotFired(m) = 1 THEN   'IF THE SOLDIER FIRED A SHOT THEN...
  
'~~@@ This line checks to see if the bullet has been displayed for a long
'    enough time... @@~~
  
   IF TIMER >= myTime!(m) + .001 THEN waitForBulletShow(m) = 0
   
    '&& IF BULLET COLLIDES WITH ZANTAR, DEDUCT HP AND UPDATE HEALTH
    IF sbx(m) >= x AND sbx(m) <= x + 20 AND sby(m) >= y AND sby(m) <= y + 20 THEN soldShotFired(m) = 0: PutTheBulletBackground m: curHealth = curHealth - bulletDmg: GOSUB updateHealth: GOTO stopIT
    '## IF BULLET COLLIDES WITH WALL, CANCEL SHOT
    IF sbx(m) <= farLeft OR sbx(m) + 10 > farRight OR sby(m) <= farTop OR sby(m) + 10 > farBottom THEN soldShotFired(m) = 0: PutTheBulletBackground m: GOTO stopIT
    '## IF BULLET COLLIDES WITH OBJECT, CANCEL SHOT
    FOR o = 1 TO totObjects
     IF stuckgunner(o) <> 3 THEN
      IF sbx(m) >= ox(o) AND sbx(m) <= ox(o) + 20 AND sby(m) >= oy(o) AND sby(m) <= oy(o) + 20 THEN soldShotFired(m) = 0: PutTheBulletBackground m: GOTO stopIT
     END IF
    NEXT
    '## IF BULLET COLLIDES WITH gunner, CANCEL SHOT
    FOR o = 1 TO totGunners
      IF sbx(m) >= gx(o) AND sbx(m) <= gx(o) + 20 AND sby(m) >= gy(o) AND sby(m) <= gy(o) + 20 THEN soldShotFired(m) = 0: PutTheBulletBackground m: GOTO stopIT
    NEXT

 'IF ITS TIME TO REFRESH THE BULLET THEN....
    IF waitForBulletShow(m) = 0 THEN
'RESET THE TIMER
    myTime!(m) = TIMER

PutTheBulletBackground m

'               \/------DETERMINE WHICH WAY THE BULLET IS SHOOTING
   
    SELECT CASE scurflag(m)
      CASE 1
        sby(m) = sby(m) - 10
      CASE 2
        sbx(m) = sbx(m) + 10
      CASE 3
        sby(m) = sby(m) + 10
      CASE 4
        sbx(m) = sbx(m) - 10
    END SELECT

GetTheBulletBackground m

'PUT THE BULLET
   PUT (sbx(m), sby(m)), bullet, PSET
'START THE BULLET DISPLAY DELAY
stopIT:
   waitForBulletShow(m) = 1
   END IF   '<----end if for "if its time to refresh the bullets"
  
   END IF   '<--- endif for "if the soldier fired a shot"
  NEXT      '<--check for next soldier bullet collision

' \/----------CHECK FOR ZANTAR'S BLOB COLLISIONS
  IF shotFired = 1 THEN

      GET (ax, ay)-(ax + 10, ay + 10), background
      PUT (ax, ay), bglobmask, AND: PUT (ax, ay), bglob, OR
      SNOOZE blobDelay!
      PUT (ax, ay), background, PSET

      oldax = ax: olday = ay

   IF shotFiredUp = 1 THEN
      ay = ay - 10
   ELSEIF shotFiredRight = 1 THEN
      ax = ax + 10
   ELSEIF shotFiredDown = 1 THEN
      ay = ay + 10
   ELSEIF shotFiredLeft = 1 THEN
      ax = ax - 10
   END IF

'### OBJECT COLLISION ###
      FOR o = 1 TO totObjects
        IF ax > ox(o) AND ax < (ox(o) + 20) AND ay > oy(o) AND ay < (oy(o) + 20) THEN
         PLACE "freeblob1", oldax, olday
         shotFiredUp = 0: shotFiredRight = 0: shotFiredDown = 0: shotFiredLeft = 0
         shotFired = 0
       END IF
      NEXT

distance = distance + 1

   FOR w = 1 TO totSold

'$$ SOLDIER COLLISION
     IF stucksold(w) <> 3 THEN
      IF ax > sx(w) AND ax < (sx(w) + 20) AND ay > sy(w) AND ay < (sy(w) + 20) THEN
         shotFiredUp = 0: shotFiredRight = 0: shotFiredDown = 0: shotFiredLeft = 0
          
           IF stucksold(w) = 1 THEN
              stucksold(w) = 2
              PUT (sx(w), sy(w)), x2soldmask, AND: PUT (sx(w), sy(w)), x2sold, OR
              IF soundOn = 1 THEN SOUND 400, 3
           ELSEIF stucksold(w) = 0 THEN
              stucksold(w) = 1
              PUT (sx(w), sy(w)), xsoldmask, AND: PUT (sx(w), sy(w)), xsold, OR
              IF soundOn = 1 THEN SOUND 500, 3
           END IF
          
           shotFired = 0
           skipWall = 1
      END IF
     END IF
  NEXT


'$$ GUNNER COLLISION
   FOR w = 1 TO totGunners
     IF stuckgunner(w) <> 3 THEN
      IF ax > gx(w) AND ax < (gx(w) + 20) AND ay > gy(w) AND ay < (gy(w) + 20) THEN
         shotFiredUp = 0: shotFiredRight = 0: shotFiredDown = 0: shotFiredLeft = 0
         
           IF stuckgunner(w) = 1 THEN
              stuckgunner(w) = 2
              PUT (gx(w), gy(w)), x2soldmask, AND: PUT (gx(w), gy(w)), x2sold, OR
              IF soundOn = 1 THEN SOUND 400, 3
           ELSEIF stuckgunner(w) = 0 THEN
              stuckgunner(w) = 1
              PUT (gx(w), gy(w)), xsoldmask, AND: PUT (gx(w), gy(w)), xsold, OR
              IF soundOn = 1 THEN SOUND 500, 3
           END IF
         
           shotFired = 0
           skipWall = 1
      END IF
     END IF
  NEXT

IF skipWall = 1 THEN GOTO skipW
'%% WALL COLLISION
'IF shotFired = 1 THEN
      IF distance = throw OR ax <= farLeft OR ax + 10 >= farRight OR ay <= farTop OR ay + 10 >= farBottom THEN
        
        PLACE "freeblob1", ax, ay
        
         shotFiredUp = 0: shotFiredRight = 0: shotFiredDown = 0: shotFiredLeft = 0
         shotFired = 0
      END IF
END IF
skipW:
skipWall = 0
LOOP UNTIL UCASE$(k$) <> ""  'WAIT FOR KEYPRESS

oldx = x: oldy = y
    SELECT CASE UCASE$(k$)
      CASE CHR$(0) + "K"                'LEFT
        flag = 4
        IF x <> farLeft THEN x = x - Mx                '###### # #######
      CASE CHR$(0) + "M" 'RIGHT                        '# Key trapping #
        flag = 2                                       '###### # #######
        IF x + Mx <> farRight THEN x = x + Mx
      CASE CHR$(0) + "H" 'UP
        flag = 1
        IF y <> farTop THEN y = y - my
      CASE CHR$(0) + "P" 'DOWN
        flag = 3
        IF y + my <> farBottom THEN y = y + my
      CASE "Q"
        GOTO dead
        SYSTEM
      CASE CHR$(27)
        GOTO dead
        SYSTEM
      CASE "S"
        IF soundOn = 1 THEN
           soundOn = 0
        ELSE soundOn = 1
        END IF
      CASE CHR$(32)
' IF ZANTAR HAS AMMO LEFT
       IF shotFired <> 1 AND curBlobs > 0 THEN
' IF HE'S POINTING .....
        SELECT CASE flag
          CASE 1                        'UP
            FOR o = 1 TO totObjects
              IF y = oy(o) + 20 AND x = ox(o) THEN GOTO nogoodkey
            NEXT
            IF y = farTop THEN GOTO nogoodkey
            ax = x + 5: ay = y
            IF shotFiredUp <> 1 THEN shotFiredUp = 1
          CASE 2
            FOR o = 1 TO totObjects
              IF x + 20 = ox(o) AND y = oy(o) THEN GOTO nogoodkey
            NEXT
            IF x + 20 = farRight THEN GOTO nogoodkey
            ax = x + 10: ay = y + 5     'RIGHT
            IF shotFiredRight <> 1 THEN shotFiredRight = 1
          CASE 3
            FOR o = 1 TO totObjects
              IF y + 20 = oy(o) AND x = ox(o) THEN GOTO nogoodkey
            NEXT
            IF y + 20 = farBottom THEN GOTO nogoodkey
            ax = x + 5: ay = y + 10      'DOWN
            IF shotFiredDown <> 1 THEN shotFiredDown = 1
          CASE 4
            FOR o = 1 TO totObjects
              IF x = ox(o) + 20 AND y = oy(o) THEN GOTO nogoodkey
            NEXT
            IF x = farLeft THEN GOTO nogoodkey
            ax = x: ay = y + 5       'LEFT
            IF shotFiredLeft <> 1 THEN shotFiredLeft = 1
        END SELECT
       
        IF soundOn = 1 THEN SOUND 350, 1

' HE SHOOTS A BLOB AND LOSES ONE PIECE OF AMMO
        distance = 0
        shotFired = 1
        curBlobs = curBlobs - 1
'UPDATE AMMO ====\/
        GOSUB updateAmmoStandings

       END IF
       
      CASE ELSE  '<--IF AN UNAUTHORIZED KEY IS PRESSED, SKIP ANIMATIONS
        GOTO nogoodkey
      END SELECT

'CHECK FOR STAIRS
        IF x = stairsX AND y = stairsY THEN level = level + 1: GOSUB determinelevel: GOTO nogoodkey
    
'CHECK FOR MINES
      FOR m = 1 TO totMines
       IF mineBlown(m) <> 1 THEN
        IF x = minex(m) AND y = miney(m) THEN
         PUT (oldx, oldy), BG, PSET  '<-- COVER PREVIOUS SPRITE
         curHealth = curHealth - mineDmg: GOSUB updateHealth
         GOSUB blowMine
         score = score - 50: GOSUB updateScore
         PUT (x, y), BG, PSET
         PUT (x, y), uzantmask, AND
         PUT (x, y), uzant, OR
         mineBlown(m) = 1
         GOTO nogoodkey
        END IF
      END IF
      NEXT

'CHECK FOR SCIENTISTS
            FOR myo = 1 TO totSci
              IF x = madscix(myo) AND y = madsciy(myo) THEN
               IF SciTalk(myo) <> 1 THEN
                GetUpgraded myo
                score = score + INT(RND * 5) + 1
                score = score + 2000: GOSUB updateScore

                SELECT CASE typeOfScientist$(myo)
                  CASE "mashp"
                   totHealth = totHealth + 25
                  CASE "ammo2"
                   totBlobs = totBlobs + 2
                  CASE "ammo5"
                   totBlobs = totBlobs + 5
                  CASE "dist"
                   throw = throw + 2
                  CASE "speed"
                   delay! = delay! - .5
                END SELECT
                SciTalk(myo) = 1
               GOSUB updateAmmoStandings
               GOSUB updateHealth
               END IF
                x = oldx: y = oldy
               
              END IF
            NEXT

      FOR c = 1 TO totSold               ' FOR EVERY SOLDIER,
        IF x = sx(c) AND y = sy(c) THEN    ' IF ZANTAR IS ON TOP OF THE SOLD,
          IF stucksold(c) = 2 THEN         ' IF THE SOLD IS FULLY COVERED,
             GOSUB deadsold                ' EAT THE SOLDIER.
          ELSEIF stucksold(c) = 3 THEN     ' IF THE SOLDIER IS DEAD,
             EXIT FOR                      ' STEP OVER THE CORPSE.
          ELSE                             ' IF THE SOLDIER IS STILL ALIVE,
             x = oldx: y = oldy            ' DO NOT RUN INTO IT.
          END IF
        END IF
      NEXT

      FOR c = 1 TO totGunners               ' FOR EVERY SOLDIER,
        IF x = gx(c) AND y = gy(c) THEN    ' IF ZANTAR IS ON TOP OF THE SOLD,
          IF stuckgunner(c) = 2 THEN         ' IF THE SOLD IS FULLY COVERED,
             GOSUB deadgunner                ' EAT THE SOLDIER.
          ELSEIF stuckgunner(c) = 3 THEN     ' IF THE SOLDIER IS DEAD,
             EXIT FOR                      ' STEP OVER THE CORPSE.
          ELSE                             ' IF THE SOLDIER IS STILL ALIVE,
             x = oldx: y = oldy            ' DO NOT RUN INTO IT.
          END IF
        END IF
      NEXT

      FOR o = 1 TO totObjects
        IF x = ox(o) AND y = oy(o) THEN x = oldx: y = oldy
      NEXT

'RATTY RAT CHEESE CHECK
     IF aRat = 1 THEN
      FOR su = 0 TO 20 STEP 20
       FOR sw = 0 TO 20 STEP 20
        IF x = ratx + sw AND y = raty + su THEN x = oldx: y = oldy
       NEXT
      NEXT

      FOR c = 1 TO totCheese
        IF cheeseEaten(c) <> 1 THEN
          IF x <= cx(c) AND x + 20 > cx(c) AND y <= cy(c) AND y + 20 > cy(c) THEN cheeseEaten(c) = 1: GOSUB updateRatCheese
        END IF
      NEXT
     END IF
'END RATTY RAT CHEESE CHECK
     
      FOR o = 0 TO totPOW
       IF powEaten(o) <> 1 THEN
                powX = wx(o)
                powY = wy(o)
        IF x <= powX AND y <= powY AND x + 20 > powX AND y + 20 > powY THEN
        SELECT CASE typeOfPow$(o)
                CASE "medkit"
                  curHealth = curHealth + 20
                  GOSUB updateHealth
                CASE "freeblob1"
                   IF curBlobs < totBlobs THEN curBlobs = curBlobs + 1
                   GOSUB updateAmmoStandings
               
                END SELECT
        powEaten(o) = 1
        END IF
       END IF
      NEXT
     

IF oldx = stairsX AND oldy = stairsY THEN
  PUT (oldx, oldy), stairsmask, AND: PUT (oldx, oldy), stairs, OR
ELSE
  PUT (oldx, oldy), BG, PSET  '<-- COVER PREVIOUS SPRITE
END IF


IF d = 1 THEN  '<-------MAKE ZANTAR BOUNCE UP AND DOWN  ****
  PUT (x, y), uzantmask, AND
  PUT (x, y), uzant, OR: d = d - 1
 ELSE
   PUT (x, y), dzantmask, AND
   PUT (x, y), dzant, OR: d = d + 1
END IF

SELECT CASE flag
  CASE 1
    PSET (x + 10, y), 4
    LINE (x + 9, y + 1)-(x + 11, y + 1), 4
    LINE (x + 8, y + 2)-(x + 12, y + 2), 4
  CASE 2
    PSET (x + 19, y + 10), 4
    LINE (x + 18, y + 9)-(x + 18, y + 11), 4
    LINE (x + 17, y + 8)-(x + 17, y + 12), 4
  CASE 3
    PSET (x + 10, y + 19), 4
    LINE (x + 9, y + 18)-(x + 11, y + 18), 4
    LINE (x + 8, y + 17)-(x + 12, y + 17), 4
  CASE 4
    PSET (x, y + 10), 4
    LINE (x + 1, y + 9)-(x + 1, y + 11), 4
    LINE (x + 2, y + 8)-(x + 2, y + 12), 4
END SELECT

nogoodkey:
LOOP

MoveSold:
' CHECK ALL SOLDIERS IN LEVEL
 FOR n = 1 TO totSold

' %% ## IF THE SOLDIER IN QUESTION HAS BEEN HIT... ## %%
' ------------------------------------------------------
   IF stucksold(n) = 1 THEN timeStuck(n) = timeStuck(n) + 1: PUT (sx(n), sy(n)), BG, PSET: PUT (sx(n), sy(n)), xsoldmask, AND: PUT (sx(n), sy(n)), xsold, OR: GOTO badmove
   IF stucksold(n) = 2 THEN timeStuck(n) = timeStuck(n) + 1: PUT (sx(n), sy(n)), BG, PSET: PUT (sx(n), sy(n)), x2soldmask, AND: PUT (sx(n), sy(n)), x2sold, OR: GOTO badmove
   IF stucksold(n) = 3 THEN GOTO badmove

   PUT (sx(n), sy(n)), BG, PSET '<-- COVER PREVIOUS SOLDIER
   

   oldsx(n) = sx(n): oldsy(n) = sy(n)

   isDumb = INT(RND * 3) + 1
   IF isDumb = 2 THEN 'IF SOLDIER IS NOT STUPID
     IF x > sx(n) THEN
       randdir = 2   'if zantar = RIGHT
     ELSEIF x < sx(n) THEN
       randdir = 1   'if zantar = LEFT
     END IF

     IF y < sy(n) THEN       'if zantar = UP
       randdir = 3
     ELSEIF y > sy(n) THEN   'if zantar = DOWN
       randdir = 4
     END IF
   ELSEIF isDumb = 1 OR isDumb = 3 THEN 'IF SOLDIER IS STUPID
     randdir = INT(RND * 4) + 1
   END IF

   SELECT CASE randdir
    CASE 1    '<------- MOVE LEFT
      IF sx(n) <> farLeft THEN sx(n) = sx(n) - 20
    CASE 2    '<------- MOVE RIGHT
      IF sx(n) + 20 <> farRight THEN sx(n) = sx(n) + 20
    CASE 3    '<------- MOVE UP
      IF sy(n) <> farTop THEN sy(n) = sy(n) - 20
    CASE 4    '<------- MOVE DOWN
      IF sy(n) + 20 <> farBottom THEN sy(n) = sy(n) + 20
    END SELECT
      
'IF GOING TO COLLIDE WITH ZANTAR WHILE MOVING LEFT...
      IF sx(n) = x AND sy(n) = y THEN sx(n) = oldsx(n): sy(n) = oldsy(n)

      IF sx(n) = stairsX AND sy(n) = stairsY THEN sx(n) = oldsx(n): sy(n) = oldsy(n)

      FOR o = 1 TO totObjects
        IF sx(n) = ox(o) AND sy(n) = oy(o) THEN sx(n) = oldsx(n): sy(n) = oldsy(n)
      NEXT

      FOR c = 1 TO totGunners
      IF sx(n) = gx(c) AND sy(n) = gy(c) THEN sx(n) = oldsx(n): sy(n) = oldsy(n)
      NEXT

      FOR m = 1 TO totMines
       IF mineBlown(m) <> 1 THEN
        IF sx(n) = minex(m) AND sy(n) = miney(m) THEN
         GOSUB blowMine
         stucksold(n) = 3
         PUT (sx(n), sy(n)), BG, PSET
         deadsold = deadsold + 1
         mineBlown(m) = 1
         RETURN
        END IF
      END IF
      NEXT

   SELECT CASE randdir
    CASE 1
      PUT (sx(n), sy(n)), lsoldmask, AND
      PUT (sx(n), sy(n)), lsold, OR
      sflag(n) = 4
    CASE 2
      PUT (sx(n), sy(n)), rsoldmask, AND
      PUT (sx(n), sy(n)), rsold, OR
      sflag(n) = 2
    CASE 3
      PUT (sx(n), sy(n)), usoldmask, AND
      PUT (sx(n), sy(n)), usold, OR
      sflag(n) = 1
    CASE 4
      PUT (sx(n), sy(n)), dsoldmask, AND
      PUT (sx(n), sy(n)), dsold, OR
      sflag(n) = 3
    END SELECT

    FOR a = 1 TO totPOW
    IF typeOfPow$(a) = "freeblob1" OR typeOfPow$(a) = "freeblob2" THEN
         IF sx(n) <= wx(a) AND sx(n) + 20 >= wx(a) AND sy(n) <= wy(a) AND sy(n) + 20 >= wy(a) THEN
            powEaten(a) = 1
            IF soundOn = 1 THEN SOUND 400, .3
         END IF
    END IF
    NEXT

   IF soldShotFired(n) <> 1 THEN
    scurflag(n) = sflag(n)
    soldShotFired(n) = 1
    SELECT CASE sflag(n)
      CASE 1
        sbx(n) = sx(n) + 10
        sby(n) = sy(n) - 5
     CASE 2
       sbx(n) = sx(n) + 20
       sby(n) = sy(n) + 10
      CASE 3
        sbx(n) = sx(n) + 10
        sby(n) = sy(n) + 20
      CASE 4
        sbx(n) = sx(n) - 5
        sby(n) = sy(n) + 10
    END SELECT

   GetTheBulletBackground n
   END IF

badmove:
'IF SOLDIER IS DONE BEING STUCK.... RESET VARIABLES FOR THAT SOLDIER
IF timeStuck(n) = maxTimeStuck THEN stucksold(n) = 0: timeStuck(n) = 0
NEXT

RETURN

GOTO dead

blowMine:             '~~~~~~~~~~~~~BLOW MINE!~~~~~~~~~~~~~~~
   PUT (minex(m), miney(m)), xplodemask, AND
   PUT (minex(m), miney(m)), xplode, OR
   mineBlown(m) = 1
   SNOOZE .1
RETURN

shootMGun:                        '***SHOOT MACHINE GUN***

FOR g = 1 TO totGunners
  IF stuckgunner(g) <> 3 THEN
     SELECT CASE typeOfGunner$(g)
       CASE "left"
          startPos = gx(g) - 25
          endPos = farLeft
          theStep = -10
      
       CASE "right"
          startPos = gx(g) + 45
          endPos = farRight
          theStep = 10
        
       CASE "up"
          startPos = gy(g) - 25
          endPos = farTop
          theStep = -10
        
       CASE "down"
          startPos = gy(g) + 45
          endPos = farBottom
          theStep = 10
        
     END SELECT

          FOR i = startPos TO endPos STEP theStep
             IF typeOfGunner$(g) = "left" OR typeOfGunner$(g) = "right" THEN
                FOR oz = 1 TO totObjects
                  IF i >= ox(oz) AND i <= ox(oz) + 20 AND gy(g) = oy(oz) THEN
                     PUT (i, gy(g) + 5), bullet, PSET
                     endPos = i: GOTO StopGBullets
                  END IF
                NEXT
                PUT (i, gy(g) + 5), bullet, PSET
             ELSE
                FOR oz = 1 TO totObjects
                  IF i >= oy(oz) AND i <= oy(oz) + 20 AND gx(g) = ox(oz) THEN
                     PUT (gx(g) + 9, i), bullet, PSET
                     endPos = i: GOTO StopGBullets
                  END IF
                NEXT
                PUT (gx(g) + 9, i), bullet, PSET
             END IF
          NEXT

StopGBullets:
     IF typeOfGunner$(g) = "left" THEN
        IF y = gy(g) AND x > endPos AND x < startPos THEN curHealth = curHealth - 2: GOSUB updateHealth
     ELSEIF typeOfGunner$(g) = "right" THEN
        IF y = gy(g) AND x < endPos AND x + 10 > startPos THEN curHealth = curHealth - 2: GOSUB updateHealth
     ELSEIF typeOfGunner$(g) = "down" THEN
        IF x = gx(g) AND y + 5 >= startPos AND y < endPos THEN curHealth = curHealth - 2: GOSUB updateHealth
     ELSEIF typeOfGunner$(g) = "up" THEN
        IF x = gx(g) AND y < startPos AND y + 5 > endPos THEN curHealth = curHealth - 2: GOSUB updateHealth
     END IF
  END IF
NEXT

RETURN


setBG:    '<------ DRAW ALL THE BACKGROUND AT THE BEGINNING

FOR r = farLeft TO farRight - 1 STEP 20
  FOR q = farTop TO farBottom - 1 STEP 20
    PUT (r, q), BG, PSET
  NEXT
NEXT

FOR ii = farLeft TO farRight
PUT (ii, farTop - 5), lrwall, PSET
PUT (ii, farBottom), lrwall, PSET
NEXT

FOR jj = farTop TO farBottom
PUT (farLeft - 5, jj), udwall, PSET
PUT (farRight, jj), udwall, PSET
NEXT

PUT (farLeft - 5, farTop - 5), corner, PSET
PUT (farLeft - 5, farBottom), corner, PSET
PUT (farRight, farTop - 5), corner, PSET
PUT (farRight, farBottom), corner, PSET

PUT (120, 5), title, PSET                 'yellow = 79
PUT (10, 40), ammobar, PSET               'red = 224

GOSUB updateAmmoStandings
GOSUB updateHealth
GOSUB updateScore

RETURN

determinelevel:     '<-------- LEVEL CHANGED HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FOR w = 1 TO totPOW
 powEaten(w) = 0
NEXT

FOR w = 1 TO totSold
 stucksold(w) = 0
NEXT

FOR w = 1 TO totSci
 SciTalk(w) = 0
NEXT

FOR w = 1 TO totMines
 mineBlown(w) = 0
NEXT

FOR w = 1 TO totGunners
 stuckgunner(w) = 0
NEXT


'RESET VARIABLES--\/
'################################
oldStairsX = stairsX
oldStairsY = stairsY
deadsold = 0
deadgunners = 0
totSold = 0
totObjects = 0
totGunners = 0
totMines = 0
totPOW = 0
totSci = 0
'################################

IF level = 0 THEN
   farLeft = 80: farRight = 220: farTop = 40: farBottom = 140
   NewBG tile()
   GOSUB setBG
   stairsX = farRight - 20
   stairsY = farBottom - 20
   'PLACE "fcab", 20, 60
   PLACE "usoldier", 40, 60
   PLACE "usoldier", 80, 60
   PLACE "table", 40, 0
   PLACE "freeblob1", 185, 65
 ELSEIF level = 1 THEN
   farLeft = 60: farRight = 240: farTop = 40: farBottom = 140
   NewBG diamond()
   GOSUB setBG
   stairsX = farLeft
   stairsY = farTop
   PLACE "umadsci a2", 0, 80
   PLACE "lsoldier", 140, 40
   PLACE "dsoldier", 80, 80
   PLACE "dist", 5, 85
   PLACE "chair", 40, 60
   PLACE "lgunner", 140, 60
   PLACE "chair", 60, 40
   PLACE "chair", 100, 80
  ELSEIF level = 2 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   NewBG diamond()
   GOSUB setBG
   stairsX = farLeft
   stairsY = farTop + 40
   PLACE "rsoldier", 100, 80
   PLACE "table", 80, 40
   PLACE "lsoldier", 20, 60
   PLACE "chair", 0, 0
   PLACE "chair", 0, 80
   PLACE "chair", 200, 0
   PLACE "chair", 200, 80
   PLACE "freeblob1", 185, 65
   PLACE "freeblob1", 185, 85
   PLACE "freeblob1", 185, 105
  ELSEIF level = 3 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   NewBG tile()
   GOSUB setBG
   stairsX = farLeft + 100
   stairsY = farTop + 40
   PLACE "dgunner", 40, 0
   PLACE "lgunner", 200, 20
   PLACE "ugunner", 160, 80
   PLACE "rgunner", 0, 60
   PLACE "freeblob1", farLeft + 83, farTop + 46
   PLACE "freeblob1", farLeft + 66, farTop + 43
   'PLACE "freeblob1", 85, 105
   'PLACE "freeblob1", 65, 105
   PLACE "medkit", 205, 5
   PLACE "ammo2", 145, 105
  ELSEIF level = 4 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   NewBG checker()
   GOSUB setBG
   stairsX = farLeft + 20
   stairsY = farTop + 40
   PLACE "mine", 80, 40
   PLACE "mine", 120, 40
   PLACE "mine", 100, 20
   PLACE "mine", 100, 60
   PLACE "chair", 140, 40
   PLACE "chair", 60, 40
   PLACE "dsoldier", 140, 20
   PLACE "usoldier", 60, 60
   PLACE "plant", 0, 80
   PLACE "dmadsci ds", 200, 60
   PLACE "table", 180, 80
  ELSEIF level = 5 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   NewBG checker()
   GOSUB setBG
   realX = 180: realY = 40
   stairsX = farLeft + 100: stairsY = farTop
   PLACE "mine", 0, 20
   PLACE "plant", 20, 20
   PLACE "mine", 40, 20
   PLACE "plant", 60, 20
   PLACE "mine", 80, 20
   PLACE "plant", 100, 20
   PLACE "mine", 120, 20
   PLACE "plant", 140, 20
   PLACE "mine", 160, 20
   PLACE "plant", 180, 20
   PLACE "mine", 200, 20

   PLACE "rsoldier", 60, 0
   PLACE "lsoldier", 160, 0

   PLACE "fcab", 120, 40
  
   PLACE "mine", 0, 60
   PLACE "plant", 20, 60
   PLACE "mine", 40, 60
   PLACE "plant", 60, 60
   PLACE "mine", 80, 60
   PLACE "plant", 100, 60
   PLACE "mine", 120, 60
   PLACE "plant", 140, 60
   PLACE "mine", 160, 60
   PLACE "plant", 180, 60
   PLACE "mine", 200, 60
  
   PLACE "rsoldier", 60, 80
   PLACE "lsoldier", 160, 80
   PLACE "dmadsci hp", 0, 80
   TIMER STOP
   DIM cs$(10)
   cs$(0) = "*Soldier #1: Do you guys remember"
   cs$(1) = " where Master told us the mines"
   cs$(2) = " are be placed?"
   cs$(3) = "*Other Soldiers: Uhh.. I thought you"
   cs$(4) = " would remember..."
   cs$(5) = "*Soldier #1: AHrmmm... OF COURSE I"
   cs$(6) = " know where the mines are.. I was"
   cs$(7) = " just, uh, testing you.. Yeah that's"
   cs$(8) = " right, testing you. Eh heh heh."
   PUT (220, 80), dzantmask, AND: PUT (220, 80), dzant, OR
   Hablar cs$(), 0, 2
   Hablar cs$(), 3, 4
   Hablar cs$(), 5, 8
   GOSUB updateHealth: GOSUB updateAmmoStandings
   TIMER ON
  ELSEIF level = 6 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   NewBG diamond()
   GOSUB setBG
   stairsX = 60
   stairsY = 40
   oldStairsX = 200
   oldStairsY = 40
   PLACE "chair", 100, 20
   PLACE "chair", 100, 60
   PLACE "mine", 100, 0
   PLACE "rgunner", 0, 20
   PLACE "lgunner", 200, 20
   PLACE "mine", 100, 40
   PLACE "rgunner", 0, 60
   PLACE "lgunner", 200, 60
   PLACE "freeblob1", 85, 127
   PLACE "medkit", 63, 85
  ELSEIF level = 7 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   NewBG diamond()
   GOSUB setBG
   stairsX = farLeft + 20
   stairsY = 120
   realX = 200: realY = 40
   PLACE "chair", 180, 60
   PLACE "dgunner", 60, 0
   PLACE "ugunner", 120, 80
   PLACE "rgunner", 0, 60
   PLACE "lgunner", 200, 20
   PLACE "rsoldier", 20, 20
   PLACE "usoldier", 160, 80
   PLACE "freeblob1", 120, 88
   PLACE "freeblob1", 134, 82
   PLACE "medkit", 110, 45
  ELSEIF level = 8 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   NewBG tile()
   GOSUB setBG
   stairsX = farLeft + 100
   stairsY = farTop + 40
   realX = 200: realY = 80
   PLACE "freeblob1", 45, 45
   PLACE "freeblob1", 45, 65
   PLACE "freeblob1", 45, 85
   PLACE "freeblob1", 45, 105
   PLACE "freeblob1", 45, 125
   PLACE "plant", 180, 80
   PLACE "plant", 180, 60
   PLACE "plant", 200, 20
 
   PUT (120, 80), rsoldmask, AND: PUT (120, 80), rsold, OR
   PUT (160, 80), lsoldmask, AND: PUT (160, 80), lsold, OR
   PUT (140, 80), dmadscimask, AND: PUT (140, 80), dmadsci, OR
   PUT (145, 125), lminemask, AND: PUT (145, 125), lmine, OR
   DIM d$(37)
   d$(1) = "*Soldier #1: Now that we have you"
   d$(2) = " right where we want you, Prof. Nick,"
   d$(3) = " we need to have a little friendly"
   d$(4) = " conversation."
   d$(5) = "*Soldier #2: Since there couldn't"
   d$(6) = " possibly be anyone within earshot,"
   d$(7) = " let us explain our evil plan in"
   d$(8) = " full detail."
   d$(9) = "¯Prof. Nick: I'll never talk to the"
   d$(10) = " likes of you!"
   d$(11) = "*Soldier #1: We thought you would"
   d$(12) = " say that. But first, think of"
   d$(13) = " this: once Master's plans take"
   d$(14) = " effect, the world will be ours."
   d$(15) = "Master will need genius scientists"
   d$(16) = " such as yourself to make him"
   d$(17) = " weapons of mass destruction, and"
   d$(18) = " he'll need soldiers to keep order."
   d$(19) = "*Soldier #2: And good work will"
   d$(20) = " most definitely mean even better"
   d$(21) = " rewards...perhaps your own private"
   d$(22) = " research facility...?"
   d$(23) = "¯Prof. Nick: Your bribery may work"
   d$(24) = " on weaker scientists, but it will"
   d$(25) = " NEVER work on me!!!"
   d$(26) = "I WILL NEVER HELP SCUM LIKE YOU"
   d$(27) = " TAKE OVER THE WORLD! I'D DIE"
   d$(28) = " BEFORE I'D HELP YOUR MASTER!!!"
   d$(29) = "*Soldier #2: Blast! Another scientist"
   d$(30) = " slipped through our fingertips."
   d$(31) = "Master will not be very pleased."
   d$(32) = "       < rustle, rustle >"
   d$(33) = "*Soldier #1: What was that? I heard"
   d$(34) = " a noise."
   d$(35) = "*Soldier #2: Let's check it out."
   PUT (240, 120), dzantmask, AND: PUT (240, 120), dzant, OR
   Hablar d$(), 1, 4
   Hablar d$(), 5, 8
   Hablar d$(), 9, 10
   Hablar d$(), 11, 14
   Hablar d$(), 15, 18
   Hablar d$(), 19, 22
   Hablar d$(), 23, 25
   Hablar d$(), 26, 28
 
   PUT (120, 80), BG, PSET: PUT (160, 80), BG, PSET
   PUT (120, 80), dsoldmask, AND: PUT (120, 80), dsold, OR
   PUT (160, 80), dsoldmask, AND: PUT (160, 80), dsold, OR
 
   PUT (140, 80), BG, PSET
   PUT (140, 100), dmadscimask, AND: PUT (140, 100), dmadsci, OR
   SNOOZE .3
   PUT (140, 100), BG, PSET
   PUT (140, 120), dmadscimask, AND: PUT (140, 120), dmadsci, OR
   
   PUT (140, 120), xplodemask, AND: PUT (140, 120), xplode, OR
   SNOOZE .1
   PUT (140, 120), BG, PSET
 
   Hablar d$(), 29, 30
   Hablar d$(), 31, 31
   Hablar d$(), 32, 32
   Hablar d$(), 33, 34
   Hablar d$(), 35, 35
   ERASE d$
 
 
   PLACE "rsoldier", 80, 40
   PLACE "lsoldier", 120, 40
 
   GOSUB updateAmmoStandings
   GOSUB updateHealth
   GOSUB updateScore
   GOSUB updateTime
  ELSEIF level = 9 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   GOSUB rattyRat
   NewBG diamond()
   GOSUB setBG
   stairsX = -20
   stairsY = -20
   realX = 40: realY = 40
   PLACE "rat", 180, 20
   DIM rat$(30)
   rat$(1) = "*Pierre: ­Hola! ¨Como estas LT"
   rat$(2) = " Zantar? You must either be very"
   rat$(3) = " lucky or very stupid to have met"
   rat$(4) = " mi."
   rat$(5) = "Don't you get it? You're the only"
   rat$(6) = " soldier in this lab that I knew"
   rat$(7) = " was too inteligente to fall for"
   rat$(8) = " my diabolical plan."
   rat$(9) = "With you out of the picture, I'm"
   rat$(10) = " free to manipulate the soldiers"
   rat$(11) = " para mejorar mi vida."
   rat$(12) = "¨Que pasa? The sight of a giant"
   rat$(13) = " Spanish speaking rat is muy loco,"
   rat$(14) = " ¨No?"
   rat$(15) = "All rats speak Spanish you know..."
   rat$(16) = " It's the best language en todo el"
   rat$(17) = " mundo! ­Que idiota!"
   rat$(18) = "Pues, si, I am the one the sold-"
   rat$(19) = " iers call Master. All these years"
   rat$(20) = " of eating chemically altered"
   rat$(21) = " cheese has made me mas grande."
   rat$(22) = "La una cosa that it didn't change"
   rat$(23) = " was mi appetite. Oye, you look un"
   rat$(24) = " poco like a piece of cheese..."
   rat$(25) = " yeah..green cheese! ­Mi favorito!"
   rat$(26) = "*Pierre: Get over here you"
   rat$(27) = " little green cheese puff!"
   rat$(28) = " ­­­TENGO HAMBRE!!!"
   GOSUB updateRatCheese
   PUT (80, 80), uzantmask, AND: PUT (80, 80), uzant, OR
   Hablar rat$(), 1, 4
   Hablar rat$(), 5, 8
   Hablar rat$(), 9, 11
   Hablar rat$(), 12, 14
   Hablar rat$(), 15, 17
   Hablar rat$(), 18, 21
   Hablar rat$(), 22, 25
   Hablar rat$(), 26, 28
   ERASE rat$
   GOSUB updateHealth: GOSUB updateAmmoStandings
   skipStairs = 1
  ELSEIF level = 10 THEN
   farLeft = 40: farRight = 260: farTop = 40: farBottom = 140
   NewBG tile()
   GOSUB setBG
   skipStairs = 1
   stairsX = -20
   stairsY = -20
   realX = 120: realY = 80
   TIMER OFF
  
   PLACE "plant", 80, 0
   PLACE "plant", 120, 0
   PLACE "dmadsci", 60, 20
   PLACE "dmadsci", 100, 20
   PLACE "dmadsci", 140, 20
   PLACE "xsold", 0, 0
   PLACE "xsold", 20, 20
   PLACE "xsold", 0, 40
   PLACE "xsold", 20, 60
   PLACE "xsold", 0, 80
   PUT (140, 100), uzantmask, AND
   PUT (140, 100), uzant, OR

   DIM tet$(80)
   tet$(0) = "¯Prof. Gage: Thank heavens you're"
   tet$(1) = " finally awake LT Zantar! We have "
   tet$(2) = " much to tell you."
   tet$(3) = "¯Prof. Roy: As you can see, every"
   tet$(4) = " soldier that was part of Pierre's"
   tet$(5) = " evil plan has been apprehended."
   tet$(6) = "¯Prof. Dorsey: I'm so glad you"
   tet$(7) = " recovered...you see, ummm...it was"
   tet$(8) = " kinda my fault that you were turned"
   tet$(9) = " into a blob in the first place."
   tet$(10) = "I was forced to put the wrong"
   tet$(11) = " chemicals into Prof. Mattay's"
   tet$(12) = " potion...I had no choice."
   tet$(13) = "I'm sure you understand."
   tet$(14) = "¯Prof. Roy: Without you, we would"
   tet$(15) = " be imprisoned by the evil soldiers"
   tet$(16) = " and Pierre forever."
   tet$(17) = "¯Prof. Gage: As a small token of"
   tet$(18) = " our appreciation, we whipped up"
   tet$(19) = " one last potion for your enjoyment."
   tet$(20) = "¯Lieutennant Zantar: Wow it feels"
   tet$(21) = " great to be back in my own body."
   tet$(22) = " Thank you Prof. Gage, Prof. Roy."
   tet$(23) = " ...I have just one thing to say"
   tet$(24) = "to you, Prof. Dorsey.........."
   tet$(25) = "YOU SWITCHED THE CHEMICALS IN THAT"
   tet$(26) = " POTION?!!??! WHY I OUGHTA...!!!"
   tet$(27) = " I'M GONNA MURTALIZE YA!! COME"
   tet$(28) = " HERE!!!!"
   Hablar tet$(), 0, 2
   Hablar tet$(), 3, 5
   Hablar tet$(), 6, 9
   Hablar tet$(), 10, 12
   Hablar tet$(), 13, 13
   Hablar tet$(), 14, 16
   Hablar tet$(), 17, 19

   RANDOMIZE TIMER
   FOR iz = 1 TO 10
      randcolor = INT(RND * 14) + 1
      CIRCLE (149, 110), 29, randcolor
      PAINT (150, 110), randcolor, randcolor
      SNOOZE .1
     
      FOR bb = 1 TO 3
       FOR ba = 1 TO 3
         PUT (100 + (20 * bb), 60 + (20 * ba)), BG, PSET
       NEXT
      NEXT

      PUT (140, 100), uzantmask, AND
      PUT (140, 100), uzant, OR
      SNOOZE .1
   NEXT                                          'The TRANSFORMATION
  
   FOR ip = 1 TO 10
      randcolor = INT(RND * 14) + 1
      CIRCLE (149, 110), 29, randcolor
      PAINT (150, 110), randcolor, randcolor
      SNOOZE .05
    
      FOR bb = 1 TO 3
       FOR ba = 1 TO 3
         PUT (100 + (20 * bb), 60 + (20 * ba)), BG, PSET
       NEXT
      NEXT

      PUT (140, 100), usoldmask, AND
      PUT (140, 100), usold, OR
      SNOOZE .05
   NEXT

   Hablar tet$(), 20, 22
   Hablar tet$(), 23, 24
   Hablar tet$(), 25, 28
   PUT (145, 89), bglobmask, AND
   PUT (145, 89), bglob, OR
   SNOOZE .3
   PUT (140, 80), BG, PSET
   PUT (145, 76), bglobmask, AND
   PUT (145, 76), bglob, OR
   SNOOZE .3
   PUT (140, 80), BG, PSET
   PUT (140, 60), dzantmask, AND
   PUT (140, 60), dzant, OR
   SNOOZE .5
   PUT (140, 100), BG, PSET
   PUT (140, 100), dsoldmask, AND
   PUT (140, 100), dsold, OR
  
   tet$(29) = "¯Lieutennant Zantar: Huh. I"
   tet$(30) = " guess I had a little blob"
   tet$(31) = " left in me after all."
   tet$(32) = "¯Prof. Dorsey: In the end, isn't"
   tet$(33) = " there a little blob inside each"
   tet$(34) = " and every one of us?"
   tet$(35) = "¯Prof. Roy: No... What the"
   tet$(36) = " heck are you talking about"
   tet$(37) = " Dorsey?"
   tet$(38) = "¯Prof. Gage: Ah, that crazy"
   tet$(39) = " Dorsey...always playing his"
   tet$(40) = " crazy Dorsey games."
   tet$(41) = "¯Lieutennant Zantar: Right you are,"
   tet$(42) = " Professor. Right you are."
   tet$(43) = "¯Everyone (even the barely conscious"
   tet$(44) = " soldiers): Hahahahahahahahaha!"
   Hablar tet$(), 29, 31
   Hablar tet$(), 32, 34
   Hablar tet$(), 35, 37
   Hablar tet$(), 38, 40
   Hablar tet$(), 41, 42
   Hablar tet$(), 43, 44

FOR xxx = 130 TO 30 STEP -10
   CIRCLE (150, 110), xxx, 10
   PAINT (150 - xxx - 7, 110), 2, 10
   PAINT (150 + xxx + 7, 110), 2, 10
   SNOOZE .3
NEXT
SNOOZE 1
 FOR i = 0 TO 110 STEP 3
  LINE (0, i)-(319, i - 3), 0, BF
  LINE (0, 210 - i)-(319, 210 - i + 3), 0, BF
  SNOOZE .0000001
 NEXT

 tet$(45) = "¯Prof. Roy: You know, with our"
 tet$(46) = " entire military base being wiped"
 tet$(47) = " out by you, we could use some"
 tet$(48) = " help..."
 tet$(49) = "With a little bit of biological"
 tet$(50) = " tweaking, you could be a one man"
 tet$(51) = " killing machine again. You up"
 tet$(52) = " for it?"
 tet$(53) = "¯Lieutennant Zantar: Maybe I am..."
 tet$(54) = " Maybe I am....."
 Hablar tet$(), 45, 48
 Hablar tet$(), 49, 52
 Hablar tet$(), 53, 54
 SNOOZE 1
 COLOR 224: LOCATE 12, 16: PRINT "THE END"
 SNOOZE 5
 LOCATE 12, 23: PRINT "."
 SNOOZE .5
 LOCATE 12, 24: PRINT "."
 SNOOZE .5
 LOCATE 12, 25: PRINT "."
 SNOOZE .5
 LOCATE 12, 26: PRINT "?"
 SNOOZE 4

 CLS
 COLOR 15

 LOCATE 2, 1: PRINT "========================================"
 COLOR 10
 LOCATE 2, 9: PRINT "THE MANDATORY CREDITS"

 COLOR 2
 LOCATE 6, 10: PRINT "EVERYTHING DONE BY"
 COLOR 15
 LOCATE 8, 13: PRINT "Joey LeGrand"

 COLOR 2
 LOCATE 12, 11: PRINT "SPECIAL THANKS TO"
 COLOR 15
 LOCATE 14, 9: PRINT "Yousuf Philips of YPI"
 COLOR 10
 LOCATE 15, 7: PRINT "For an awesome BMP loader"

 COLOR 15
 LOCATE 18, 13: PRINT "Wayne's World"
 COLOR 10
 LOCATE 19, 9: PRINT "For the idea and name"
 LOCATE 20, 2: PRINT "(and for being a totally sweet movie)"

 SNOOZE 5
 SLEEP

 GOSUB dead


  END IF
IF skipStairs <> 1 THEN
' ()()() PUT STAIRS ()()()
PUT (stairsX, stairsY), stairsmask, AND: PUT (stairsX, stairsY), stairs, OR
END IF
' ()()()()()()()()()()()()()

'PUT A ZANTAR TO START OUT
IF level = 0 THEN oldStairsX = farLeft + 40: oldStairsY = farTop + 20
PLACE "zantar", oldStairsX, oldStairsY

COLOR 15: LOCATE 4, 17: PRINT "FLOOR"; level: COLOR 15

RETURN

updateAmmoStandings:    '<------ AMMO STANDINGS ARE UPDATED HERE
        blobPrct! = curBlobs / totBlobs
        barHeight = blobPrct! * 86
      
        barColor = 2
        IF blobPrct! <= .5 THEN barColor = 79
        IF blobPrct! <= .25 THEN barColor = 224
       
        LINE (15, 47)-(19, 133), 0, BF
        LINE (15, 133 - barHeight)-(19, 133), barColor, BF
'        LOCATE 22, 21: PRINT "Ammo: "
 '       LOCATE 22, 26: PRINT curBlobs
  '      LOCATE 22, 29: PRINT "/"
   '     LOCATE 22, 30: PRINT totBlobs
        IF curBlobs <= 0 THEN GOTO dead
RETURN

updateHealth:      '<-----------HEALTH UPDATED AQUI
barSpace = 44
barrY = 10
IF curHealth > totHealth THEN curHealth = totHealth

healthPrct = (curHealth / totHealth) * 100

COLOR 2
LOCATE 4, 5: PRINT healthPrct;
COLOR 15
LOCATE 4, 9: PRINT "% HP"

LINE (barSpace - 1, barrY - 1)-(barSpace + (4 * (totHealth / 10)) + 1, barrY + 5), 0, BF
LINE (barSpace - 1, barrY - 1)-(barSpace + (4 * (totHealth / 10)) + 1, barrY + 5), 2, B
FOR healthBar = 1 TO curHealth / 10
   PUT (barSpace, barrY), square, PSET        'PUT THE NEW HEALTH
   barSpace = barSpace + 4
NEXT

IF curHealth <= 0 THEN GOTO dead
RETURN

updateScore:
COLOR 2
LOCATE 4, 28: PRINT score
LOCATE 2, 28: PRINT theHiScore
COLOR 15
LOCATE 1, 27: PRINT "HI SCORE"
LOCATE 3, 28: PRINT "SCORE"
RETURN

deadsold:
PUT (sx(c), sy(c)), BG, PSET
deadsold = deadsold + 1
stucksold(c) = 3
IF curBlobs < totBlobs THEN curBlobs = curBlobs + 1: GOSUB updateAmmoStandings
score = score + INT(RND * 5) + 1
score = score + soldScore: GOSUB updateScore
RETURN

deadgunner:
PUT (gx(c), gy(c)), BG, PSET
deadgunners = deadgunners + 1
stuckgunner(c) = 3

 SELECT CASE c
       CASE 1
         PUT (gbulletx(c), gbullety(c)), gbg1, PSET
       CASE 2
         PUT (gbulletx(c), gbullety(c)), gbg2, PSET
       CASE 3
         PUT (gbulletx(c), gbullety(c)), gbg3, PSET
       CASE 4
         PUT (gbulletx(c), gbullety(c)), gbg4, PSET
     END SELECT
 

IF curBlobs < totBlobs THEN curBlobs = curBlobs + 1: GOSUB updateAmmoStandings
score = score + INT(RND * 5) + 1
score = score + gunnerScore: GOSUB updateScore
RETURN

blinkMine:
IF mineBlink = 0 THEN
  mineBlink = 1
ELSEIF mineBlink = 1 THEN
  mineBlink = 0
END IF
 
FOR m = 1 TO totMines
 IF mineBlown(m) <> 1 THEN
  IF mineBlink = 1 THEN
   PUT (minex(m) + 5, miney(m) + 5), lminemask, AND
   PUT (minex(m) + 5, miney(m) + 5), lmine, OR
  ELSE
   PUT (minex(m) + 5, miney(m) + 5), minemask, AND
   PUT (minex(m) + 5, miney(m) + 5), mine, OR
  END IF
 END IF
NEXT
RETURN

rattyRat:
ERASE gbg1, gbg2, gbg3, gbg4, lmgun, lmgunmask, rmgun, rmgunmask, umgun, umgunmask
ERASE dmgun, dmgunmask, lsold, lsoldmask, rsold, rsoldmask
ERASE x2sold, x2soldmask, metal, fcab, fcabmask, checker
ERASE table, tablemask

DIM SHARED lrat(1600), lratmask(1600)
DIM SHARED rrat(1600), rratmask(1600)
DIM SHARED drat(1600), dratmask(1600)
DIM SHARED urat(1600), uratmask(1600)
DIM SHARED cheese(300), cheesemask(300), cheesebackground(300)

CALL OPENBMP("cheese.bmp")
CONVERT 15, 15
GET (0, 0)-(14, 14), cheese
GETMASK 15, 15
GET (0, 0)-(14, 14), cheesemask

CALL OPENBMP("lrat.bmp")
CONVERT 40, 40
GET (0, 0)-(39, 39), lrat
GETMASK 40, 40
GET (0, 0)-(39, 39), lratmask

CALL OPENBMP("rrat.bmp")
CONVERT 40, 40
GET (0, 0)-(39, 39), rrat
GETMASK 40, 40
GET (0, 0)-(39, 39), rratmask

CALL OPENBMP("drat.bmp")
CONVERT 40, 40
GET (0, 0)-(39, 39), drat
GETMASK 40, 40
GET (0, 0)-(39, 39), dratmask

CALL OPENBMP("urat.bmp")
CONVERT 40, 40
GET (0, 0)-(39, 39), urat
GETMASK 40, 40
GET (0, 0)-(39, 39), uratmask

CLS

PUT (farRight + 15, 40), ammobar, PSET
PAINT (farRight + 20, 43), 79, 0
PAINT (farRight + 18, 89), 79, 0

FOR randdot = 1 TO 100
  randx = INT(RND * 20) + 1
  randy = INT(RND * 105) + 1
  PSET (farRight + 15 + randx, 40 + randy), 0
NEXT

RETURN

moveRat:
ratm = 20
oldratx = ratx: oldraty = raty

IF ratVulnerable = 1 THEN
  IF TIMER >= (ratVulnStartTime! + ratTotTimeVuln!) THEN
     ratdelay! = oldratdelay!
     ratVulnerable = 0
     goingDown = 0
    
  ELSE
     IF goingDown = 1 THEN
         ratdir = 3
         IF raty + 40 <> farBottom THEN raty = raty + ratm
         GOTO rm
     ELSEIF goingDown = -1 THEN
         ratdir = 1
         IF raty <> farTop THEN raty = raty - ratm
         GOTO rm
     END IF
     

     IF ratx + 40 = farRight OR ratx = farLeft THEN
       IF raty < farTop + 50 THEN
          goingDown = -1
       ELSE
          goingDown = 1
       END IF
       GOTO rm
     END IF

     IF ratx > farLeft + 110 THEN
        IF ratx + 40 <> farRight THEN ratdir = 2: ratx = ratx + ratm: GOTO rm
     ELSE
        IF ratx <> farLeft THEN ratdir = 4: ratx = ratx - ratm: GOTO rm
     END IF

  END IF
END IF

ratmoves = ratmoves + 1
IF ratmoves = 4 THEN
  ratmoves = 0
    IF ratShotFired <> 1 THEN
       rax = ratx + 2
         IF y >= raty + 20 THEN
            ray = raty + 22
         ELSE ray = raty + 2
         END IF
       ratShotFired = 1
     END IF

END IF

IF x < ratx THEN
   IF ratShotFired <> 1 THEN ratFireDir = 4
   ratdir = 4
   IF ratx <> farLeft THEN ratx = ratx - ratm
   GOTO rm
ELSEIF x > ratx THEN
   IF ratShotFired <> 1 THEN ratFireDir = 2
   ratdir = 2
   IF ratx + 40 <> farRight THEN ratx = ratx + ratm
   GOTO rm
ELSEIF y < raty THEN
   IF ratShotFired <> 1 THEN ratFireDir = 1
   ratdir = 1
   IF raty <> farTop THEN raty = raty - ratm
   GOTO rm
ELSEIF y >= raty THEN
   IF ratShotFired <> 1 THEN ratFireDir = 3
   ratdir = 3
   IF raty + 40 <> farBottom THEN raty = raty + ratm
   GOTO rm
END IF
rm:

FOR o = 1 TO totObjects
 IF raty + 20 = oy(o) THEN raty = oldraty
NEXT

FOR rp = 0 TO 20 STEP 20
 FOR ru = 0 TO 20 STEP 20
  PUT (oldratx + rp, oldraty + ru), BG, PSET

 IF ratx + ru = x AND raty + rp = y THEN
    ratx = oldratx: raty = oldraty
    curHealth = curHealth - 10: GOSUB updateHealth
 END IF
 
  FOR c = 1 TO totCheese
   IF cheeseEaten(c) <> 1 THEN
     IF ratx + ru <= cx(c) AND ratx + ru + 20 > cx(c) AND raty + rp <= cy(c) AND raty + rp + 20 > cy(c) THEN
      cheeseEaten(c) = 1: ratCurAmmo = ratCurAmmo + 1
      GOSUB updateRatCheese
     END IF
   END IF
  NEXT
 NEXT
NEXT

SELECT CASE ratdir
 CASE 4
  PUT (ratx, raty), lratmask, AND: PUT (ratx, raty), lrat, OR
 CASE 2
  PUT (ratx, raty), rratmask, AND: PUT (ratx, raty), rrat, OR
 CASE 3
  PUT (ratx, raty), dratmask, AND: PUT (ratx, raty), drat, OR
 CASE 1
  PUT (ratx, raty), uratmask, AND: PUT (ratx, raty), urat, OR

END SELECT
RETURN

shootCheese:

      GET (rax, ray)-(rax + 15, ray + 15), cheesebackground
      PUT (rax, ray), cheesemask, AND: PUT (rax, ray), cheese, OR
      SNOOZE blobDelay!
      PUT (rax, ray), cheesebackground, PSET

      oldrax = rax: oldray = ray
      
   IF ratFireDir = 1 THEN
      ray = ray - 10
   ELSEIF ratFireDir = 2 THEN
      rax = rax + 10
   ELSEIF ratFireDir = 3 THEN
      ray = ray + 10
   ELSEIF ratFireDir = 4 THEN
      rax = rax - 10
   END IF

'IF ZANTAR GETS HIT BY CHEESE!
      IF x < rax AND x + 20 > rax AND y < ray AND y + 20 > ray THEN
        cheesesFired = cheesesFired + 1
        ratCurAmmo = ratCurAmmo - 1
        curHealth = curHealth - 10
        GOSUB updateHealth
        ratShotFired = 0
        GOSUB updateRatCheese
      END IF

'IF CHEESE HITS A WALL!
      IF rax - 10 <= farLeft OR rax + 20 >= farRight OR ray - 10 <= farTop OR ray + 20 >= farBottom THEN
        cheesesFired = cheesesFired + 1
        PLACE "cheese", rax, ray
        ratCurAmmo = ratCurAmmo - 1
        ratShotFired = 0
        GOSUB updateRatCheese
      END IF
       
   
'IF A CERTAIN AMOUNT OF CHEESE IS FIRED, RATTY RAT
'REALIZES WHAT HE'S DOING AND STARTS COLLECTING CHEESE
        IF ratCurAmmo > 0 THEN
        IF cheesesFired = 3 THEN
          amtOfTimes = amtOfTimes + 1
          SELECT CASE amtOfTimes
          CASE 1
          r$(1) = "*Pierre: ­Ay mi! You little piece"
          r$(2) = " of queso verde! You made me lose"
          r$(3) = " my cheese..Now I have to go find"
          r$(4) = " it... ­Que lastima!"
          Hablar r$(), 1, 4
          CASE 2
          r$(1) = "*Pierre: Not again! Why do I keep"
          r$(2) = " doing this to myself?! Yo se...."
          r$(3) = " Estoy loco por el queso."
          Hablar r$(), 1, 3
          CASE 3
          r$(1) = "*Pierre: ­Ay, Dios mio! I must"
          r$(2) = " remember where I threw that"
          r$(3) = " cheese this time."
          Hablar r$(), 1, 3
          CASE 4
          r$(1) = "*Pierre: ­Oye como va! This has"
          r$(2) = " to stop. I'm getting weaker by"
          r$(3) = " the second. But I must! . No."
          r$(4) = " Si.. NO.. SI.. NO..­­­ SI !!!"
          Hablar r$(), 1, 4
          CASE ELSE
          r$(1) = "*Pierre: OK, I'm definitely"
          r$(2) = " stopping now. Si, es la verdad."
          r$(3) = " No more cheese throwing for me."
          r$(4) = " ..Pues.. Maybe one more round!"
          Hablar r$(), 1, 4
          END SELECT

          GOSUB updateHealth: GOSUB updateAmmoStandings
          ratVulnerable = 1
          ratVulnStartTime! = TIMER
          oldratdelay! = ratdelay!
          ratdelay! = .2
          cheesesFired = 0
        END IF
        END IF
        
RETURN

updateRatCheese:
cheesePrct! = ratCurAmmo / ratTotAmmo
cheeseHt = cheesePrct! * 86

LINE (farRight + 20, 47)-(farRight + 24, 133), 0, BF
LINE (farRight + 20, 133 - cheeseHt)-(farRight + 24, 133), 224, BF

IF ratCurAmmo <= 0 THEN
    c$(1) = "*Pierre: NOOOOOOOOOO!!! I am"
    c$(2) = " nada without my cheese......"
'    c$(3) = "Lo siento, Sr. Queso Verde. Por"
'    c$(4) = " favor, let me go. I promise to be"
'    c$(5) = " the best spanish speaking lab"
'    c$(6) = " rat with a french name ever......"
'    SNOOZE .5
'    c$(7) = "Gracias Sr. Queso Verde. You are"
'    c$(8) = " truly a kind and merciful ... ummm"
'    c$(9) = " ... well, a kind and merciful"
'    c$(10) = "  whatever you are."
'    c$(11) = "Adios. I will never forget this."
    Hablar c$(), 1, 2
'    Hablar c$(), 3, 6
'    Hablar c$(), 7, 10
'    Hablar c$(), 11, 11
    aRat = 0
    ERASE lrat, lratmask, rrat, rratmask, drat, dratmask
    ERASE urat, uratmask, cheese, cheesemask, cheesebackground
   
    RANDOMIZE TIMER
  
    FOR ttt = 1 TO 200
    randxpx = INT(RND * (farRight - farLeft - 20)) + 1
    randxpy = INT(RND * (farBottom - farTop - 20)) + 1
   
    PUT (farLeft + randxpx, farTop + randxpy), xplodemask, AND
    PUT (farLeft + randxpx, farTop + randxpy), xplode, OR
    SNOOZE .000000000001#
    NEXT


'Get rid of RAT's ammo bar
   ' LINE (farRight + 10, farTop - 10)-(farRight + 70, farBottom + 10), 0, BF
'Blank out the RAT himself
      ' FOR rp = 0 TO 20 STEP 20
      '   FOR ru = 0 TO 20 STEP 20
      '     PUT (ratx + rp, raty + ru), BG, PSET
      '   NEXT
      ' NEXT

    GOSUB updateHealth: GOSUB updateAmmoStandings
    'stairsX = farLeft + 160: stairsY = farTop + 40
    'PUT (stairsX, stairsY), stairsmask, AND
    'PUT (stairsX, stairsY), stairs, OR
    score = score + ratScore
    IF amtOfTimes = 2 THEN
      score = score + 3000
    ELSEIF amtOfTimes = 3 THEN
      score = score + 1500
    END IF
    score = score + INT(RND * 5) + 1
    GOSUB updateScore
    skipStairs = 0
   

    SNOOZE 1

 FOR i = 0 TO 165 STEP 3
  LINE (i, 0)-(i - 3, 210), 0, BF
  LINE (319 - i, 0)-(319 - i + 3, 210), 0, BF
  SNOOZE .00001
 NEXT

 COLOR 14: LOCATE 12, 16: PRINT "A FEW HOURS"
 COLOR 14: LOCATE 13, 16: PRINT " LATER ...": COLOR 15
 SNOOZE 3
 level = level + 1: GOTO determinelevel
END IF

RETURN

updateTime:
second = second + 1
IF second = 60 THEN minute = minute + 1: second = 0
RETURN

yourWarning:
IF blobPrct! <= .4 THEN
 IF bc = 1 THEN
  LOCATE 22, 10: COLOR 224: PRINT "YOU NEED MORE BLOBS!!!!!": COLOR 15
 ELSE
  LOCATE 22, 10: PRINT "                        "
 END IF
 bc = bc * -1
END IF

IF healthPrct <= 40 THEN
 IF hc = 1 THEN
  LOCATE 23, 10: COLOR 224: PRINT "YOU NEED MORE HEALTH!!!!!": COLOR 15
 ELSE
  LOCATE 23, 10: PRINT "                          "
 END IF
 hc = hc * -1
END IF

IF healthPrct > 40 THEN LOCATE 23, 10: PRINT "                         "
IF blobPrct! > .4 THEN LOCATE 22, 10: PRINT "                         "
RETURN

displayHighScores:
'%$#%$^$^ MODIFY THIS TO DISPLAY UP TO 5 HIGH SCORES!!!$ $^$^$^^$&&*
  CLS
  COLOR 14
  LOCATE 6, 16
  PRINT "HI SCORE!"
  LOCATE 10, 15
  COLOR 15
  PRINT theInitials$
  LOCATE 10, 21
  COLOR 2
  PRINT theHiScore
  SLEEP
  CLS
  GOTO displayWelcomeScreen
RETURN
  
dead:
 TIMER OFF

 FOR i = 0 TO 110 STEP 3
  LINE (0, i)-(319, i - 3), 0, BF
  LINE (0, 210 - i)-(319, 210 - i + 3), 0, BF
  SNOOZE .00001
 NEXT
 COLOR 224: LOCATE 12, 16: PRINT "GAME OVER": COLOR 15

 IF score > theHiScore THEN
  LOCATE 14, 13
  COLOR 15
  PRINT "NEW HI SCORE!"
 
  LOCATE 15, 9
  COLOR 2
  INPUT "Enter your initials: ", hisInitials$
  CHDIR "c:\zantar\"
  OPEN "c:\zantar\hiscore.zan" FOR OUTPUT AS #1
  PRINT #1, USING "&, #####"; hisInitials$; score
  CLOSE
  COLOR 15
 END IF
SLEEP
SYSTEM

Errrr:
RESUME NEXT

REM $STATIC
FUNCTION ClosestColor (PixelRed, PixelGreen, PixelBlue)

Movement = ColorDif
FOR PixelArraySearch = 1 TO ArrayNo
   IF PixelBlue >= PixelArray(PixelArraySearch, 1) - ColorDif AND PixelBlue <= PixelArray(PixelArraySearch, 1) + ColorDif THEN
      IF PixelGreen >= PixelArray(PixelArraySearch, 2) - ColorDif AND PixelGreen <= PixelArray(PixelArraySearch, 2) + ColorDif THEN
         IF PixelRed >= PixelArray(PixelArraySearch, 3) - ColorDif AND PixelRed <= PixelArray(PixelArraySearch, 3) + ColorDif THEN
            ClosestColor = PixelArray(PixelArraySearch, 0)
            EXIT FUNCTION
         END IF
      END IF
   END IF
NEXT PixelArraySearch

DO
    FOR Loopsz = 0 TO 255
       IF PixelBlue >= (ColorPalette(Loopsz, 3) - Movement) AND PixelBlue <= (ColorPalette(Loopsz, 3) + Movement) THEN
          IF PixelGreen >= (ColorPalette(Loopsz, 2) - Movement) AND PixelGreen <= (ColorPalette(Loopsz, 2) + Movement) THEN
             IF PixelRed >= (ColorPalette(Loopsz, 1) - Movement) AND PixelRed <= (ColorPalette(Loopsz, 1) + Movement) THEN
                IF ColorPalette(Loopsz, 1) = ColorPalette(Loopsz, 2) AND ColorPalette(Loopsz, 2) = ColorPalette(Loopsz, 3) AND Movement > 3 THEN
                   IF PixelBlue = PixelGreen AND PixelBlue = PixelRed THEN
                      ClosestColor = Loopsz
                      IF ArrayNo < 2000 THEN
                         ArrayNo = ArrayNo + 1
                         PixelArray(ArrayNo, 1) = PixelBlue
                         PixelArray(ArrayNo, 2) = PixelGreen
                         PixelArray(ArrayNo, 3) = PixelRed
                         PixelArray(ArrayNo, 0) = Loopsz
                      END IF
                      EXIT FUNCTION
                   END IF
                ELSE
                   ClosestColor = Loopsz
                   IF ArrayNo < 2000 THEN
                      ArrayNo = ArrayNo + 1
                      PixelArray(ArrayNo, 1) = PixelBlue
                      PixelArray(ArrayNo, 2) = PixelGreen
                      PixelArray(ArrayNo, 3) = PixelRed
                      PixelArray(ArrayNo, 0) = Loopsz
                   END IF
                   EXIT FUNCTION
                END IF
             END IF
          END IF
       END IF
    NEXT Loopsz
    Movement = Movement + 1
LOOP

END FUNCTION

SUB CONVERT (a%, b%)
itsX = a%
itsY = b%
IF a% = 0 THEN itsX = 20
IF b% = 0 THEN itsY = 20

FOR ScanY = 0 TO itsY
FOR ScanX = 0 TO itsX
  IF POINT(ScanX, ScanY) = 0 THEN PRESET (ScanX, ScanY), 16
  IF POINT(ScanX, ScanY) = 15 THEN PSET (ScanX, ScanY), 0
NEXT: NEXT
END SUB

SUB GETMASK (a%, b%)
itsX = a%
itsY = b%
IF a% = 0 THEN itsX = 20
IF b% = 0 THEN itsY = 20

FOR ScanY = 0 TO itsY
FOR ScanX = 0 TO itsX
  IF POINT(ScanX, ScanY) = 0 THEN PSET (ScanX, ScanY), 255
NEXT: NEXT
END SUB

SUB GetMyPics
CALL LoadAsm
CHDIR "c:\zantar\"
CALL OPENBMP("fcab.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), fcab
GETMASK 0, 0
GET (0, 0)-(19, 19), fcabmask

CALL OPENBMP("plant.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), plant
GETMASK 0, 0
GET (0, 0)-(19, 19), plantmask

CALL OPENBMP("mine.bmp")
CONVERT 9, 9
GET (0, 0)-(9, 9), mine
GETMASK 9, 9
GET (0, 0)-(9, 9), minemask

CALL OPENBMP("lmine.bmp")
CONVERT 9, 9
GET (0, 0)-(9, 9), lmine
GETMASK 9, 9
GET (0, 0)-(9, 9), lminemask

CALL OPENBMP("xplode.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), xplode
GETMASK 0, 0
GET (0, 0)-(19, 19), xplodemask

CALL OPENBMP("stairs.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), stairs
GETMASK 0, 0
GET (0, 0)-(19, 19), stairsmask

CALL OPENBMP("corner.bmp")
GET (0, 0)-(4, 4), corner

CALL OPENBMP("lrwall.bmp")
GET (0, 0)-(1, 4), lrwall

CALL OPENBMP("udwall.bmp")
GET (0, 0)-(4, 1), udwall

CALL OPENBMP("medkit.bmp")
GET (0, 0)-(9, 9), medkit
CALL OPENBMP("checker.bmp")
GET (0, 0)-(19, 19), checker
CALL OPENBMP("diamond.bmp")
GET (0, 0)-(19, 19), diamond
CALL OPENBMP("bump.bmp")
GET (0, 0)-(19, 19), metal
CALL OPENBMP("tile.bmp")
GET (0, 0)-(19, 19), tile

CALL OPENBMP("bullet.bmp")
GET (0, 0)-(3, 3), bullet
CALL OPENBMP("square.bmp")
GET (0, 0)-(4, 4), square
CALL OPENBMP("title.bmp")
GET (0, 0)-(72, 12), title
CALL OPENBMP("ammobar.bmp")
GET (0, 0)-(15, 100), ammobar

CALL OPENBMP("ammo.bmp")
CONVERT 0, 0
GET (0, 0)-(9, 9), ammo
GETMASK 0, 0
GET (0, 0)-(9, 9), ammomask

CALL OPENBMP("lmgun.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), lmgun
GETMASK 0, 0
GET (0, 0)-(19, 19), lmgunmask

CALL OPENBMP("rmgun.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), rmgun
GETMASK 0, 0
GET (0, 0)-(19, 19), rmgunmask

CALL OPENBMP("umgun.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), umgun
GETMASK 0, 0
GET (0, 0)-(19, 19), umgunmask

CALL OPENBMP("dmgun.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), dmgun
GETMASK 0, 0
GET (0, 0)-(19, 19), dmgunmask

CALL OPENBMP("dzant.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), dzant
GETMASK 0, 0
GET (0, 0)-(19, 19), dzantmask

CALL OPENBMP("uzant.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), uzant
GETMASK 0, 0
GET (0, 0)-(19, 19), uzantmask

CALL OPENBMP("lsold.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), lsold
GETMASK 0, 0
GET (0, 0)-(19, 19), lsoldmask

CALL OPENBMP("rsold.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), rsold
GETMASK 0, 0
GET (0, 0)-(19, 19), rsoldmask

CALL OPENBMP("usold.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), usold
GETMASK 0, 0
GET (0, 0)-(19, 19), usoldmask

CALL OPENBMP("dsold.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), dsold
GETMASK 0, 0
GET (0, 0)-(19, 19), dsoldmask

CALL OPENBMP("xsold.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), xsold
GETMASK 0, 0
GET (0, 0)-(19, 19), xsoldmask

CALL OPENBMP("x2sold.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), x2sold
GETMASK 0, 0
GET (0, 0)-(19, 19), x2soldmask

CALL OPENBMP("dmadsci.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), dmadsci
GETMASK 0, 0
GET (0, 0)-(19, 19), dmadscimask

CALL OPENBMP("umadsci.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), umadsci
GETMASK 0, 0
GET (0, 0)-(19, 19), umadscimask

CALL OPENBMP("bglob.bmp")
CONVERT 0, 0
GET (0, 0)-(9, 9), bglob
GETMASK 0, 0
GET (0, 0)-(9, 9), bglobmask

CALL OPENBMP("table.bmp")
CONVERT 40, 0
GET (0, 0)-(39, 19), table
GETMASK 40, 0
GET (0, 0)-(39, 19), tablemask

CALL OPENBMP("chair.bmp")
CONVERT 0, 0
GET (0, 0)-(19, 19), chair
GETMASK 0, 0
GET (0, 0)-(19, 19), chairmask

CLS
END SUB

SUB GetTheBulletBackground (m)
'MORE CRAP CODE THAT GETS THE BACKGROUND
   SELECT CASE m
     CASE 1
      GET (sbx(m), sby(m))-(sbx(m) + 4, sby(m) + 4), sbg1
     CASE 2
      GET (sbx(m), sby(m))-(sbx(m) + 4, sby(m) + 4), sbg2
     CASE 3
      GET (sbx(m), sby(m))-(sbx(m) + 4, sby(m) + 4), sbg3
     CASE 4
      GET (sbx(m), sby(m))-(sbx(m) + 4, sby(m) + 4), sbg4
     CASE 5
      GET (sbx(m), sby(m))-(sbx(m) + 4, sby(m) + 4), sbg5
     CASE 6
      GET (sbx(m), sby(m))-(sbx(m) + 4, sby(m) + 4), sbg6
    END SELECT
END SUB

SUB GetUpgraded (w)
TIMER STOP
DIM d$(22)

FOR abc = 1 TO 4
  LOCATE 19 + abc, 1: PRINT "                                   "
NEXT

SELECT CASE typeOfScientist$(w)
  CASE "ammo2"
    d$(1) = "¯Prof Selman: Lieutennant Zantar..."
    d$(2) = " Erhm... terribly sorry about what"
    d$(3) = " happened back there."
    d$(4) = "The soldiers won't give up until you"
    d$(5) = " are in a bodybag...or a zip-loc bag"
    d$(6) = " depending on if you find the anti-"
    d$(7) = " dote. (Hahaha I made a funny!)"
    d$(8) = "But seriously...the scientists you"
    d$(9) = " meet along your way will help you"
    d$(10) = " fight back."
    d$(11) = "Now, since you are technically a"
    d$(12) = " blob, you must be careful not to"
    d$(13) = " dry up. If you throw too many blobs"
    d$(14) = " at your enemies, you will die."
    d$(15) = "Don't worry, though...I've come up"
    d$(16) = " with the rockin-est invention. It"
    d$(17) = " OWNS all the other scientists'"
    d$(18) = " creations. Here, it's all yours."
    d$(19) = "        Now you can carry"
    d$(20) = "       up to 2 more blobs!"

    Hablar d$(), 1, 3
    Hablar d$(), 4, 7
    Hablar d$(), 8, 10
    Hablar d$(), 11, 14
    Hablar d$(), 15, 18
    Hablar d$(), 19, 20

    PLACE "freeblob1", farLeft + 60, farTop + 0
    PLACE "freeblob1", farLeft + 80, farTop + 0
    PLACE "freeblob1", farLeft + 60, farTop + 20
    PLACE "freeblob1", farLeft + 80, farTop + 20
  CASE "dist"
    d$(1) = "¯Prof Clark: Lieutennant Zantar!  So"
    d$(2) = " good to see you!"
    d$(3) = "Don't tell the soldiers about this,"
    d$(4) = " but I've created a potion that allows"
    d$(5) = " you to snipe all your enemies!"
    d$(6) = "Shhhhh.... this is our little secret."
    d$(7) = ""
    d$(8) = "       You can now throw blobs"
    d$(9) = "       twice as far as before!"
    Hablar d$(), 1, 2
    Hablar d$(), 3, 5
    Hablar d$(), 6, 9

    PLACE "medkit", 185, 25
  CASE "mashp"
    d$(1) = "¯Prof Keers: Is it really you? That"
    d$(2) = " explosion would have killed a lesser"
    d$(3) = " man."
    d$(4) = "Just in case something like that does"
    d$(5) = " happen again, I'm going to pump....."
    d$(6) = " ............... you up.             "
    d$(7) = "       You now have a larger"
    d$(8) = "           health tank!!"
    Hablar d$(), 1, 3
    Hablar d$(), 4, 6
    Hablar d$(), 7, 8
    PLACE "medkit", 8, 8
  CASE "speed"
END SELECT

FOR abc = 1 TO 4
  LOCATE 19 + abc, 1: PRINT "                                   "
NEXT

TIMER ON
END SUB

'### THIS SUB TYPES OUT THE DIALOGUE BETWEEN CHARACTERS ###
SUB Hablar (a$(), b, e)

FOR abc = 1 TO 4
  LOCATE 19 + abc, 1: PRINT "                                   "
NEXT

FOR lineNum = b TO e
  FOR t = 1 TO LEN(a$(lineNum))
    IF MID$(a$(lineNum), t, 1) = ":" THEN COLOR 15
    IF MID$(a$(lineNum), t, 1) = "" THEN COLOR 4: SNOOZE .8
    IF MID$(a$(lineNum), t, 1) = " " THEN GOTO aSpace
    LOCATE 19 + lineNum - b + 1, 2 + t
    PRINT MID$(a$(lineNum), t, 1)
    IF INKEY$ <> "" THEN GOTO aSpace
    SNOOZE .04
aSpace:
    IF MID$(a$(lineNum), t, 1) = "¯" THEN COLOR 2
    IF MID$(a$(lineNum), t, 1) = "*" THEN COLOR 4
  NEXT
NEXT
   
SNOOZE .8

FOR b = 1 TO 4
  LOCATE 19 + b, 3: PRINT STRING$(38, " ")
NEXT
COLOR 15
END SUB

SUB Instructions
COLOR 4: LOCATE 2, 15: PRINT "GENERAL INFO": COLOR 15
LOCATE 5, 4: PRINT "1"
LOCATE 5, 10: PRINT "2"
PUT (20, 40), xsold, PSET
LOCATE 7, 7: PRINT ""
PUT (65, 40), x2sold, PSET
LOCATE 5, 14: PRINT "Soldiers need to be"
LOCATE 6, 14: PRINT "hit with a blob twice"
LOCATE 7, 14: PRINT "before they can be"
LOCATE 8, 14: PRINT "eaten by Zantar."

'PUT (27, 70), dzant, PSET
'PUT (47, 70), x2sold, PSET

'PUT (47, 90), uzant, PSET

'PUT (67, 110), dzant, PSET

LOCATE 10, 14: PRINT "Once a soldier is"
LOCATE 11, 14: PRINT "stuck to the ground,"
LOCATE 12, 14: PRINT "Zantar needs to move"
LOCATE 13, 14: PRINT "to the soldier's space"
LOCATE 14, 14: PRINT "to eat him before he"
LOCATE 15, 14: PRINT "breaks free."

PUT (30, 135), rsold, PSET
PUT (50, 135), rmgun, PSET
PUT (73, 140), bullet, PSET
PUT (80, 140), bullet, PSET
PUT (87, 140), bullet, PSET

LOCATE 17, 14: PRINT "Machine guns stop"
LOCATE 18, 14: PRINT "shooting once the"
LOCATE 19, 14: PRINT "soldier controlling"
LOCATE 20, 14: PRINT "them is dead."


LOCATE 23, 20: PRINT "NEXT"
COLOR 1: LOCATE 23, 25: PRINT "": COLOR 15
SLEEP: CLS

COLOR 1: LOCATE 2, 15: PRINT "GAMEPLAY": COLOR 15
PUT (20, 40), umadsci, PSET
PUT (60, 40), dmadsci, PSET
LOCATE 5, 14: PRINT "Talk to the scientists"
LOCATE 6, 14: PRINT "in order to receive"
LOCATE 7, 14: PRINT "power-ups. These are"
LOCATE 8, 14: PRINT "vital to the game."
PUT (40, 85), stairs, PSET
LOCATE 11, 14: PRINT "Get to the stairs on"
LOCATE 12, 14: PRINT "each floor so you"
LOCATE 13, 14: PRINT "can move one level"
LOCATE 14, 14: PRINT "closer to your goal."

LOCATE 18, 5: PRINT "0 / 10"
LOCATE 17, 14: PRINT "Be careful because"
LOCATE 18, 14: PRINT "when Zantar runs out"
LOCATE 19, 14: PRINT "of health OR blobs,"
LOCATE 20, 14: PRINT "he will die."

LOCATE 23, 20: PRINT "NEXT"
COLOR 1: LOCATE 23, 25: PRINT "": COLOR 15
SLEEP
SLEEP
CLS
COLOR 2: LOCATE 2, 15: PRINT "ITEMS": COLOR 15

PUT (65, 40), ammo, PSET
LOCATE 5, 14: PRINT "Used blobs will raise"
LOCATE 6, 14: PRINT "your current amount"
LOCATE 7, 14: PRINT "of blobs by one."

PUT (65, 79), medkit, PSET
LOCATE 10, 14: PRINT "Medkits are used to"
LOCATE 11, 14: PRINT "replenish Zantar's"
LOCATE 12, 14: PRINT "hitpoints."

PUT (35, 112), chair, PSET
PUT (65, 112), plant, PSET
LOCATE 15, 14: PRINT "Hide behind objects"
LOCATE 16, 14: PRINT "like these to avoid"
LOCATE 17, 14: PRINT "enemy bullets."


FOR bbx = 0 TO 60 STEP 7
  PUT (30 + bbx, 152), bullet, PSET
NEXT
LOCATE 20, 14: PRINT "Bullets hurt..."

PUT (45, 159), mine, PSET
PUT (66, 159), lmine, PSET
LOCATE 21, 14: PRINT "Mines hurt more."

LOCATE 23, 20: PRINT "NEXT"
COLOR 1: LOCATE 23, 25: PRINT "": COLOR 15
SLEEP: CLS
END SUB

SUB LoadAsm

'/* Assembly Used To Display 8-Bit Images (c) YPI 1999                     */'
ASM$ = ASM$ + CHR$(&H55) + CHR$(&H89) + CHR$(&HE5) + CHR$(&H1E) + CHR$(&HC5)
ASM$ = ASM$ + CHR$(&H76) + CHR$(&HC) + CHR$(&HC4) + CHR$(&H7E) + CHR$(&H8)
ASM$ = ASM$ + CHR$(&H8B) + CHR$(&H4E) + CHR$(&H6) + CHR$(&H89) + CHR$(&HCB)
ASM$ = ASM$ + CHR$(&H81) + CHR$(&HE3) + CHR$(&H3) + CHR$(&H0) + CHR$(&HC1)
ASM$ = ASM$ + CHR$(&HE9) + CHR$(&H2) + CHR$(&HF3) + CHR$(&H66) + CHR$(&HA5)
ASM$ = ASM$ + CHR$(&H81) + CHR$(&HFB) + CHR$(&H0) + CHR$(&H0) + CHR$(&H74)
ASM$ = ASM$ + CHR$(&H4) + CHR$(&H89) + CHR$(&HD9) + CHR$(&HF3) + CHR$(&HA4)
ASM$ = ASM$ + CHR$(&H1F) + CHR$(&H5D) + CHR$(&HCA) + CHR$(&HA) + CHR$(&H0)
'PUSH BP | MOV BP, SP | PUSH DS | LDS SI,[BP+0Ch] | LES DI,[BP+08h]
'MOV CX,[BP+06h] | MOV BX, CX | AND BX,03h | SHR CX,02h | REP MOVSD
'CMP BX,0h | JE FINISH | MOV CX, BX | REP MOVSB | FINISH: | POP DS
'POP BP | RETF 0Ah

END SUB

'/* Memory Copying Routine To Copy Bytes From One Location To Another      */'
SUB MemCopyBD (FromSeg, FromOff, ToSeg, ToOff, Bytes)

 DEF SEG = VARSEG(ASM$)
    CALL ABSOLUTE(BYVAL FromSeg, BYVAL FromOff, BYVAL ToSeg, BYVAL ToOff, BYVAL Bytes, SADD(ASM$))
 DEF SEG

END SUB

SUB MoveSold
 PUT (x, y), BG, PSET
  SELECT CASE k$
    CASE CHR$(0) + "K"
      x = x - Mx
      PUT (x, y), lsold, PSET
    CASE CHR$(0) + "M"          ' Key trapping
      x = x + Mx
      PUT (x, y), rsold, PSET
    CASE CHR$(0) + "H"
      y = y - my
      PUT (x, y), usold, PSET
    CASE CHR$(0) + "P"
      y = y + my
      PUT (x, y), dsold, PSET
    'CASE CHR$(32)
  END SELECT
END SUB

SUB NewBG (myBG())

PUT (0, 0), myBG, PSET
GET (0, 0)-(19, 19), BG
LINE (0, 0)-(19, 19), 0, BF

END SUB

SUB OPENBMP (FileName$)

DIM BMPHeader AS BMPHeader
DIM OS2Ver1InfoHeader AS OS2Ver1InfoHeader
DIM WindowsInfoHeader AS WindowsInfoHeader
DIM Word AS INTEGER
DIM ImageWidth AS LONG
DIM ImageHeight AS LONG

CLS
OPEN FileName$ FOR BINARY AS #255
IF LOF(255) = 0 THEN
   PRINT " File Is Empty"
   CLOSE : KILL FileName$
   EXIT SUB
END IF

GET #255, , BMPHeader
IF BMPHeader.ValidID <> "BM" THEN
   PRINT " Invalid BMP File"
   CLOSE : EXIT SUB
END IF

GET #255, , Word
SEEK #255, LOC(255) - 1
IF Word = 12 THEN
   GET #255, , OS2Ver1InfoHeader
   ImageWidth = OS2Ver1InfoHeader.Widthz
   ImageHeight = OS2Ver1InfoHeader.Heightz
   BitsPerPixel = OS2Ver1InfoHeader.BitsPerPixel
   Compression = 0
   BytesPerPalette = 3
ELSEIF Word = 40 THEN
   GET #255, , WindowsInfoHeader
   ImageWidth = WindowsInfoHeader.Widthz
   ImageHeight = WindowsInfoHeader.Heightz
   BitsPerPixel = WindowsInfoHeader.BitsPerPixel
   Compression = WindowsInfoHeader.CompressMethod
   BytesPerPalette = 4
END IF

IF BitsPerPixel = 32 THEN
   PRINT " 32-bit Images Can't Be Displayed | Please send this image to philipz85@hotmail.com"
   CLOSE : EXIT SUB
END IF

IF BitsPerPixel > 8 THEN
      ColorDif = 0
      Greyscale = 0
      SCREEN 13
      '/* An excellent color palette from PALSTUFF.BAS [Graphics.abc|09/1995] */'
      Change$ = "#####M#M##MMM##M#MM8#MMM88888b8b88bbb88b8bbb8bbb+++"
      Change$ = Change$ + "...222555999===@@@DDDHHHKKKOOOSSSVVVZZZ^^^bbb3##8##"
      Change$ = Change$ + "=##?&&B**E--H11K55N88Q<<T@@XDDZII]NN_SSbYY3+#8-#=/#"
      Change$ = Change$ + "B2#G4#L6#Q9#V;#\>#\B*]F2^K:_OA`TIaXQb]Y33#66#99#<<#"
      Change$ = Change$ + "??#BB#EE#HH#LL#OO#RR#UU#XX#[[#^^#bb##8%#:(#<,#?/#A3"
      Change$ = Change$ + "#C7#F:#H>#KB#ME#OI#RM#TP#WT#YX#\\YbYRbQJbJG^GDZDAWA"
      Change$ = Change$ + ">S>;O;8L85H52E2/A/,=,):)&6&$3#YbbQbbJbbE__A\\=ZZ:VV"
      Change$ = Change$ + "7RR5NN2JJ0FF-BB*>>(::%66#33Y^bQ[bJXbBUb:Rb3Ob+Mb#Jb"
      Change$ = Change$ + "#F\#BV#>P#:J#6D#3?#/9#,3YYbQRbJJbEE_@@\<<Y88V55R33N"
      Change$ = Change$ + "11J..F,,B**>'':%%6##3/@$2B#5D#8F#;H#>J#AL#DN#GP#JR#"
      Change$ = Change$ + "MT#PV#SX#VZ#Y\#]_#bYb`S`^N^\H\ZCZX=XV8VT3UP0QL.MH+I"
      Change$ = Change$ + "D(EA&A<%<7$73#3-+&1-'5/):2+;3+=4,?5-@6-B7.D8/E9/G:0"
      Change$ = Change$ + "I;1J<1L=2N>3O?3Q@4SA5UB6VD8WF;XH>YJAZMD[OG\QJ]SM^VP"
      Change$ = Change$ + "_XS`ZVb]ZZ##X)#W0#U6#T;#S@#RF#PJ#ON#CN#6M#*M##L(#K3"
      Change$ = Change$ + "#K?#KH#FL#>M#5M#-N6#Q>#QD#QL#QQ#NQ#FQ#@Q#9Q#1R#+R##"
      Change$ = Change$ + "bbb"
      OUT &H3C8, 0
      FOR Loops = 0 TO 255
         Red = ASC(MID$(Change$, Loops * 3 + 1, 1)) - 35
         Green = ASC(MID$(Change$, Loops * 3 + 2, 1)) - 35
         Blue = ASC(MID$(Change$, Loops * 3 + 3, 1)) - 35
         ColorPalette(Loops, 1) = Red
         ColorPalette(Loops, 2) = Green
         ColorPalette(Loops, 3) = Blue
         OUT &H3C9, Red
         OUT &H3C9, Green
         OUT &H3C9, Blue
      NEXT Loops
      Change$ = ""
   END IF

   IF BitsPerPixel = 1 OR BitsPerPixel = 4 THEN
      SCREEN 12
   ELSE
      SCREEN 13
   END IF
   NoOfColors = 2 ^ BitsPerPixel
   Palette$ = SPACE$(NoOfColors * BytesPerPalette)
   GET #255, , Palette$
   OUT &H3C8, 0
   FOR Loops = 0 TO NoOfColors - 1
      IF BitsPerPixel = 1 AND Loops = 1 THEN
         OUT &H3C8, 15
      END IF
      OUT &H3C9, ASC(MID$(Palette$, Loops * BytesPerPalette + 3, 1)) \ 4
      OUT &H3C9, ASC(MID$(Palette$, Loops * BytesPerPalette + 2, 1)) \ 4
      OUT &H3C9, ASC(MID$(Palette$, Loops * BytesPerPalette + 1, 1)) \ 4
   NEXT Loops


Movements = 20
IF BMPHeader.OffsetOfBitMap <> 0 THEN
   SEEK #255, BMPHeader.OffsetOfBitMap + 1
END IF

ByteCopy = ImageWidth
IF ImageWidth > 320 THEN
   ByteCopy = 320
END IF

IF Compression = 0 THEN
   Extract = (BitsPerPixel / 8) * ImageWidth
   IF (Extract MOD 4) <> 0 THEN
      Extract = Extract + (4 - (Extract MOD 4))
   END IF
   Extract$ = SPACE$(Extract)
   DO
   IF BMPHeader.OffsetOfBitMap <> 0 THEN
      SEEK #255, BMPHeader.OffsetOfBitMap + 1
   END IF
   FOR YHeight = ImageHeight - 1 TO 0 STEP -1
      GET #255, , Extract$
      IF BitsPerPixel = 1 THEN
         FOR XWidth = 0 TO Extract - 1
            Byte = ASC(MID$(Extract$, XWidth + 1, 1))
            FOR EachByte = 7 TO 0 STEP -1
               IF XWidth * 8 + (7 - EachByte) > ImageWidth THEN EXIT FOR
               IF (Byte AND 2 ^ EachByte) <> 0 THEN
                  PSET (XWidth * 8 + (7 - EachByte), YHeight), 15
               ELSE
                  PSET (XWidth * 8 + (7 - EachByte), YHeight), 0
               END IF
            NEXT EachByte
         NEXT XWidth
      ELSEIF BitsPerPixel = 4 THEN
         FOR XWidth = 0 TO (ImageWidth / 2) - 1
            Byte = ASC(MID$(Extract$, XWidth + 1, 1))
            PSET (XWidth * 2, YHeight), Byte \ 16
            PSET (XWidth * 2 + 1, YHeight), Byte AND 15
         NEXT XWidth
      ELSEIF BitsPerPixel = 8 THEN
         IF (YHeight - ImageHM) < 101 AND (YHeight - ImageHM) > -1 THEN
            CALL MemCopyBD(VARSEG(Extract$), SADD(Extract$) + ImageWM, &HA000, (YHeight - ImageHM) * 320, ByteCopy)
         ELSEIF (YHeight - ImageHM) < 201 AND (YHeight - ImageHM) > 99 THEN
            CALL MemCopyBD(VARSEG(Extract$), SADD(Extract$) + ImageWM, &HA7D0, (YHeight - 100 - ImageHM) * 320, ByteCopy)
         END IF
         IF (YHeight - ImageHM) < 0 THEN EXIT FOR
      ELSEIF BitsPerPixel = 16 AND Greyscale = 1 THEN
         FOR XWidth = 0 TO ImageWidth - 1
            Bit16 = CVI(MID$(Extract$, XWidth * 2 + 1, 2))
            Red = Bit16 AND 31: Bit16 = Bit16 \ 32
            Green = Bit16 AND 63: Bit16 = Bit16 \ 64
            Blue = Bit16
            PSET (XWidth, YHeight), (Red + (Green \ 2) + Blue) \ 3
         NEXT XWidth
      ELSEIF BitsPerPixel = 16 AND Greyscale = 0 THEN
         FOR XWidth = 0 TO ImageWidth - 1
            Bit16 = CVI(MID$(Extract$, XWidth * 2 + 1, 2))
            Red = (Bit16 AND 31) * 2: Bit16 = Bit16 \ 32
            Green = Bit16 AND 63: Bit16 = Bit16 \ 64
            Blue = Bit16 * 2
            PSET (XWidth, YHeight), ClosestColor(Red, Green, Blue)
         NEXT XWidth
      ELSEIF BitsPerPixel = 24 AND Greyscale = 1 THEN
         FOR XWidth = 0 TO ImageWidth - 1
            Red = ASC(MID$(Extract$, XWidth * 3 + 1, 1))
            Green = ASC(MID$(Extract$, XWidth * 3 + 2, 1))
            Blue = ASC(MID$(Extract$, XWidth * 3 + 3, 1))
            PSET (XWidth, YHeight), (Red + Green + Blue) \ 3
         NEXT XWidth
      ELSEIF BitsPerPixel = 24 AND Greyscale = 0 THEN
         FOR XWidth = 0 TO ImageWidth - 1
            Red = ASC(MID$(Extract$, XWidth * 3 + 3, 1)) \ 4
            Green = ASC(MID$(Extract$, XWidth * 3 + 2, 1)) \ 4
            Blue = ASC(MID$(Extract$, XWidth * 3 + 1, 1)) \ 4
            PSET (XWidth, YHeight), ClosestColor(Red, Green, Blue)
         NEXT XWidth
      END IF
   NEXT YHeight
'   IF Continue = 0 THEN
      'WHILE INKEY$ <> "": WEND
      'DO
      '   Wait$ = INKEY$
      'LOOP WHILE Wait$ = ""
'   END IF
   IF BitsPerPixel <> 8 THEN EXIT DO
   IF INKEY$ <> "" THEN Continue = 0: Wait$ = ""
   IF Wait$ = "4" OR Wait$ = CHR$(0) + CHR$(&H4B) THEN
      ImageWM = ImageWM - Movements: Continue = 1
   ELSEIF Wait$ = "2" OR Wait$ = CHR$(0) + CHR$(&H50) THEN
      ImageHM = ImageHM + Movements: Continue = 1
   ELSEIF Wait$ = "6" OR Wait$ = CHR$(0) + CHR$(&H4D) THEN
      ImageWM = ImageWM + Movements: Continue = 1
   ELSEIF Wait$ = "8" OR Wait$ = CHR$(0) + CHR$(&H48) THEN
      ImageHM = ImageHM - Movements: Continue = 1
   END IF
  
   IF ImageWM < -1 THEN
      ImageWM = 0: Continue = 0
   ELSEIF ImageHM < -1 THEN
      ImageHM = 0: Continue = 0
   ELSEIF (ImageHM + 200) > ImageHeight THEN
      ImageHM = ImageHeight - 200: Continue = 0
   ELSEIF (ImageWM + 320) > ImageWidth THEN
      ImageWM = ImageWidth - 320: Continue = 0
   END IF

   LOOP UNTIL Wait$ = CHR$(32)
ELSE
   PixelColors$ = SPACE$(1): NoOfSameColors$ = SPACE$(1)
   RightMovement$ = SPACE$(1): UpMovement$ = SPACE$(1)
   x = 0: y = ImageHeight - 1
   DO
      GET #255, , NoOfSameColors$
      GET #255, , PixelColors$
      NoOfSameColors = ASC(NoOfSameColors$)
      PixelColor = ASC(PixelColors$)
      IF NoOfSameColors <> 0 THEN
         IF BitsPerPixel = 8 THEN
            LINE (x, y)-STEP(ASC(NoOfSameColors$), 0), PixelColor
            x = x + NoOfSameColors
         ELSE
            Pixel1 = PixelColor \ 16
            Pixel2 = PixelColor AND 15
            FOR Loops = 1 TO NoOfSameColors STEP 2
               PSET (x, y), Pixel1
               PSET (x + 1, y), Pixel2
               x = x + 2
            NEXT Loops
            IF (NoOfSameColors MOD 2) = 1 THEN x = x - 1
         END IF
      ELSEIF NoOfSameColors = 0 AND PixelColor = 0 THEN
         x = 0: y = y - 1
      ELSEIF NoOfSameColors = 0 AND PixelColor = 1 THEN
         EXIT DO
      ELSEIF NoOfSameColors = 0 AND PixelColor = 2 THEN
         GET #255, , RightMovement$
         GET #255, , UpMovement$
         x = x + ASC(RightMovement$): y = y + ASC(UpMovement$)
      ELSEIF NoOfSameColors = 0 THEN
         PixelColor$ = SPACE$(PixelColor * (BitsPerPixel / 8))
         GET #255, , PixelColor$
         IF BitsPerPixel = 8 THEN
            IF y < 101 AND y > -1 THEN
               CALL MemCopyBD(VARSEG(PixelColor$), SADD(PixelColor$), &HA000, (y * 320) + x, PixelColor)
            ELSEIF y < 201 AND y > 100 THEN
               CALL MemCopyBD(VARSEG(PixelColor$), SADD(PixelColor$), &HA7D0, ((y - 100) * 320) + x, PixelColor)
            END IF
            x = x + PixelColor
            IF (PixelColor MOD 2) = 1 THEN GET #255, , NoOfSameColors$
         ELSE
            FOR Loops = 1 TO LEN(PixelColor$)
               PicColor = ASC(MID$(PixelColor$, Loops, 1))
               PSET (x, y), PicColor \ 16
               PSET (x + 1, y), PicColor AND 15
               x = x + 2
            NEXT Loops
            IF (PixelColor MOD 2) = 1 THEN x = x - 1
            IF ((Loops - 1) MOD 2) = 1 THEN GET #255, , NoOfSameColors$
         END IF
      END IF
   LOOP
   
END IF
CLOSE

END SUB

SUB PLACE (kind$, px, py)

  IF LCASE$(kind$) = "zantar" THEN
         x = px
         y = py
         IF realX <> -1 AND realY <> -1 THEN x = farLeft + realX: y = farTop + realY
         PUT (x, y), uzantmask, AND
         PUT (x, y), uzant, OR
         PSET (x + 19, y + 10), 4
         LINE (x + 18, y + 9)-(x + 18, y + 11), 4
         LINE (x + 17, y + 8)-(x + 17, y + 12), 4
         flag = 2
 
  ELSEIF LCASE$(kind$) = "xsold" THEN
     bamax = farLeft + px
     bamay = farTop + py
     PUT (bamax, bamay), xsoldmask, AND
     PUT (bamax, bamay), xsold, OR
 
  ELSEIF MID$(LCASE$(kind$), 2) = "soldier" THEN
     totSold = totSold + 1
     sx(totSold) = farLeft + px
     sy(totSold) = farTop + py
    
     SELECT CASE LEFT$(LCASE$(kind$), 1)
       CASE "l"
         PUT (sx(totSold), sy(totSold)), lsoldmask, AND
         PUT (sx(totSold), sy(totSold)), lsold, OR
       CASE "u"
         PUT (sx(totSold), sy(totSold)), usoldmask, AND
         PUT (sx(totSold), sy(totSold)), usold, OR
       CASE "r"
         PUT (sx(totSold), sy(totSold)), rsoldmask, AND
         PUT (sx(totSold), sy(totSold)), rsold, OR
       CASE "d"
         PUT (sx(totSold), sy(totSold)), dsoldmask, AND
         PUT (sx(totSold), sy(totSold)), dsold, OR
     END SELECT
 
     ELSEIF MID$(LCASE$(kind$), 2, 6) = "madsci" THEN
       totObjects = totObjects + 1
       ox(totObjects) = farLeft + px
       oy(totObjects) = farTop + py
       totSci = totSci + 1
       madscix(totSci) = ox(totObjects)
       madsciy(totSci) = oy(totObjects)
      
       IF LEFT$(LCASE$(kind$), 1) = "u" THEN
         PUT (ox(totObjects), oy(totObjects)), umadscimask, AND
         PUT (ox(totObjects), oy(totObjects)), umadsci, OR
       ELSEIF LEFT$(LCASE$(kind$), 1) = "d" THEN
         PUT (ox(totObjects), oy(totObjects)), dmadscimask, AND
         PUT (ox(totObjects), oy(totObjects)), dmadsci, OR
       END IF

       SELECT CASE RIGHT$(LCASE$(kind$), 2)
         CASE "hp"
           typeOfScientist$(totSci) = "mashp"
         CASE "a2"
           typeOfScientist$(totSci) = "ammo2"
         CASE "a5"
           typeOfScientist$(totSci) = "ammo5"
         CASE "sp"
           typeOfScientist$(totSci) = "speed"
         CASE "ds"
           typeOfScientist$(totSci) = "dist"
       END SELECT
        
  ELSEIF LCASE$(kind$) = "table" THEN
     totObjects = totObjects + 1
     ox(totObjects) = farLeft + px
     oy(totObjects) = farTop + py
     PUT (ox(totObjects), oy(totObjects)), tablemask, AND
     PUT (ox(totObjects), oy(totObjects)), table, OR
     totObjects = totObjects + 1
     ox(totObjects) = farLeft + px + 20
     oy(totObjects) = farTop + py
  ELSEIF LCASE$(kind$) = "chair" THEN
     totObjects = totObjects + 1
     ox(totObjects) = farLeft + px
     oy(totObjects) = farTop + py
     PUT (ox(totObjects), oy(totObjects)), chairmask, AND
     PUT (ox(totObjects), oy(totObjects)), chair, OR
  ELSEIF LCASE$(kind$) = "plant" THEN
     totObjects = totObjects + 1
     ox(totObjects) = farLeft + px
     oy(totObjects) = farTop + py
     PUT (ox(totObjects), oy(totObjects)), plantmask, AND
     PUT (ox(totObjects), oy(totObjects)), plant, OR
  ELSEIF LCASE$(kind$) = "fcab" THEN
     totObjects = totObjects + 1
     ox(totObjects) = farLeft + px
     oy(totObjects) = farTop + py
     PUT (ox(totObjects), oy(totObjects)), fcabmask, AND
     PUT (ox(totObjects), oy(totObjects)), fcab, OR
 
  ELSEIF MID$(LCASE$(kind$), 2) = "gunner" THEN
     totGunners = totGunners + 1
     gx(totGunners) = farLeft + px
     gy(totGunners) = farTop + py
    
     SELECT CASE LEFT$(LCASE$(kind$), 1)
       CASE "l"
         PUT (gx(totGunners), gy(totGunners)), lsoldmask, AND
         PUT (gx(totGunners), gy(totGunners)), lsold, OR
         typeOfGunner$(totGunners) = "left"
       CASE "u"
         PUT (gx(totGunners), gy(totGunners)), usoldmask, AND
         PUT (gx(totGunners), gy(totGunners)), usold, OR
         typeOfGunner$(totGunners) = "up"
       CASE "r"
         PUT (gx(totGunners), gy(totGunners)), rsoldmask, AND
         PUT (gx(totGunners), gy(totGunners)), rsold, OR
         typeOfGunner$(totGunners) = "right"
       CASE "d"
         PUT (gx(totGunners), gy(totGunners)), dsoldmask, AND
         PUT (gx(totGunners), gy(totGunners)), dsold, OR
         typeOfGunner$(totGunners) = "down"
     END SELECT

     totObjects = totObjects + 1
    
     SELECT CASE LEFT$(LCASE$(kind$), 1)
        CASE "l"
           ox(totObjects) = farLeft + px - 20
           oy(totObjects) = farTop + py
           PUT (ox(totObjects), oy(totObjects)), lmgunmask, AND
           PUT (ox(totObjects), oy(totObjects)), lmgun, OR
           thex1 = farLeft: they1 = oy(totObjects) + 5
           thex2 = ox(totObjects): they2 = oy(totObjects) + 9
        CASE "r"
           ox(totObjects) = farLeft + px + 20
           oy(totObjects) = farTop + py
           PUT (ox(totObjects), oy(totObjects)), rmgunmask, AND
           PUT (ox(totObjects), oy(totObjects)), rmgun, OR
           thex1 = ox(totObjects) + 20: they1 = oy(totObjects) + 5
           thex2 = farRight: they2 = oy(totObjects) + 9
        CASE "u"
           ox(totObjects) = farLeft + px
           oy(totObjects) = farTop + py - 20
           PUT (ox(totObjects), oy(totObjects)), umgunmask, AND
           PUT (ox(totObjects), oy(totObjects)), umgun, OR
           thex1 = ox(totObjects) + 9: they1 = farTop
           thex2 = ox(totObjects) + 14: they2 = oy(totObjects)
        CASE "d"
           ox(totObjects) = farLeft + px
           oy(totObjects) = farTop + py + 20
           PUT (ox(totObjects), oy(totObjects)), dmgunmask, AND
           PUT (ox(totObjects), oy(totObjects)), dmgun, OR
           thex1 = ox(totObjects) + 9: they1 = oy(totObjects) + 20
           thex2 = ox(totObjects) + 14: they2 = farBottom
     END SELECT

     gbulletx(totGunners) = thex1
     gbullety(totGunners) = they1
        
     SELECT CASE totGunners
       CASE 1
         GET (thex1, they1)-(thex2, they2), gbg1
       CASE 2
         GET (thex1, they1)-(thex2, they2), gbg2
       CASE 3
         GET (thex1, they1)-(thex2, they2), gbg3
       CASE 4
         GET (thex1, they1)-(thex2, they2), gbg4
     END SELECT

  ELSEIF LCASE$(kind$) = "medkit" THEN
     totPOW = totPOW + 1
     wx(totPOW) = px + farLeft
     wy(totPOW) = py + farTop
     typeOfPow$(totPOW) = "medkit"
  ELSEIF LCASE$(kind$) = "freeblob1" THEN
     totPOW = totPOW + 1
     wx(totPOW) = px: wy(totPOW) = py
     typeOfPow$(totPOW) = "freeblob1"
  ELSEIF LCASE$(kind$) = "mine" THEN
     totMines = totMines + 1
     minex(totMines) = farLeft + px: miney(totMines) = farTop + py
     PUT (minex(totMines) + 5, miney(totMines) + 5), lminemask, AND
     PUT (minex(totMines) + 5, miney(totMines) + 5), lmine, OR
  ELSEIF LCASE$(kind$) = "rat" THEN
     aRat = 1
     ratx = farLeft + px: raty = farTop + py
     ratTotAmmo = 12: ratCurAmmo = ratTotAmmo
     PUT (ratx, raty), lratmask, AND
     PUT (ratx, raty), lrat, OR
  ELSEIF LCASE$(kind$) = "cheese" THEN
     totCheese = totCheese + 1
     cx(totCheese) = px
     cy(totCheese) = py
     PUT (cx(totCheese), cy(totCheese)), cheesemask, AND
     PUT (cx(totCheese), cy(totCheese)), cheese, OR
 END IF

END SUB

SUB PlayIntro
DIM d$(20)

FOR abc = 1 TO 4
  LOCATE 19 + abc, 1: PRINT "                                   "
NEXT

d$(1) = "¯Prof Mattay: Thank you all for"
d$(2) = "  coming to see today's presentation."
d$(3) = "  I will be demonstrating some brand"
d$(4) = "  new advances in biological warfare."
d$(5) = "Lieutennant Zantar, would you like me"
d$(6) = " to demonstrate the effects these"
d$(7) = " weapons have on a simple laboratory"
d$(8) = " rat?"
d$(9) = "¯Lieutennant Zantar: Of course. I am"
d$(10) = " always interested in new research."
d$(11) = "¯Prof. Mattay: Excellent... Come."
d$(12) = "¯Prof. Mattay: Now, all I have to do"
d$(13) = " is mix these two chemicals here..."
d$(14) = "           .....WAIT!"
d$(15) = " THESE AREN'T THE RIGHT CHEMICALS!"
d$(16) = " AHHHHHHHHHHHHHHHHHHHHHHH!"

FOR a = 40 TO 120 STEP 20
FOR b = 80 TO 200 STEP 20
PUT (b, a), tile, PSET
NEXT
NEXT

PUT (140, 60), dmadscimask, AND: PUT (140, 60), dmadsci, OR
PUT (120, 40), tablemask, AND: PUT (120, 40), table, OR

FOR someX = 200 TO 120 STEP -20
  IF someX = 140 THEN PUT (200, 100), BG, PSET
  IF someX = 120 THEN PUT (180, 100), BG, PSET: PUT (200, 100), BG, PSET
  PUT (someX, 100), lsoldmask, AND: PUT (someX, 100), lsold, OR
  SNOOZE .8
NEXT

FOR c = 1 TO 3
PUT (100 + (20 * c), 100), BG, PSET
PUT (100 + (20 * c), 100), usoldmask, AND: PUT (100 + (20 * c), 100), usold, OR
NEXT

Hablar d$(), 1, 4
Hablar d$(), 5, 8
PUT (140, 100), tile, PSET
PUT (140, 80), usoldmask, AND: PUT (140, 80), usold, OR
Hablar d$(), 9, 10
Hablar d$(), 11, 11
PUT (140, 60), tile, PSET
PUT (140, 60), umadscimask, AND: PUT (140, 60), umadsci, OR
SNOOZE .2
PUT (140, 80), tile, PSET
PUT (120, 80), lsoldmask, AND: PUT (120, 80), lsold, OR
SNOOZE .2
PUT (120, 80), tile, PSET
PUT (120, 60), usoldmask, AND: PUT (120, 60), usold, OR
SNOOZE .8

Hablar d$(), 12, 13
Hablar d$(), 14, 16

RANDOMIZE TIMER
FOR myNum = 1 TO 50
   xx = INT(RND * 80) + 1
   xy = INT(RND * 40) + 1
   PUT (farLeft + 20 + xx, farTop + xy), xplodemask, AND
   PUT (farLeft + 20 + xx, farTop + xy), xplode, OR
SNOOZE .0000001
NEXT

FOR ss = (farTop + 60) TO 120 STEP 20
  PUT (140, ss), umadscimask, AND: PUT (140, ss), umadsci, OR
  SNOOZE .3
  PUT (140, ss), BG, PSET
NEXT
SNOOZE .6
PUT (120, 100), tile, PSET
PUT (120, 100), rsoldmask, AND: PUT (120, 100), rsold, OR
SNOOZE .6
PUT (160, 100), tile, PSET
PUT (160, 100), lsoldmask, AND: PUT (160, 100), lsold, OR
SNOOZE .6

DIM soc$(25)
soc$(0) = "*Soldier #1: Excellent! Switching the"
soc$(1) = " chemicals was a brilliant idea."
soc$(2) = " Master will be most pleased with us."
soc$(3) = "*Soldier #2: Now that LT Zantar is out"
soc$(4) = " of the way, Master's plans can begin"
soc$(5) = " taking effect."
soc$(6) = "*Soldier #1: It's a shame that Prof."
soc$(7) = " Mattay was blown to bits. We could"
soc$(8) = " have used his brilliant mind to help"
soc$(9) = " us take over the world."
Hablar soc$(), 0, 2
Hablar soc$(), 3, 5
Hablar soc$(), 6, 9
PUT (120, 60), uzantmask, AND: PUT (120, 60), uzant, OR

SNOOZE .2
PUT (120, 100), tile, PSET
PUT (120, 100), usoldmask, AND: PUT (120, 100), usold, OR
PUT (160, 100), tile, PSET
PUT (160, 100), usoldmask, AND: PUT (160, 100), usold, OR
SNOOZE .5
PUT (120, 100), tile, PSET
PUT (120, 100), rsoldmask, AND: PUT (120, 100), rsold, OR
PUT (160, 100), tile, PSET
PUT (160, 100), lsoldmask, AND: PUT (160, 100), lsold, OR
SNOOZE .5
PUT (120, 100), tile, PSET
PUT (120, 100), usoldmask, AND: PUT (120, 100), usold, OR
PUT (160, 100), tile, PSET
PUT (160, 100), usoldmask, AND: PUT (160, 100), usold, OR
SNOOZE .2

soc$(10) = "*Soldier #1: Am I seeing a ghost?"
soc$(11) = "Nope, that's definitely LT Zantar"
soc$(12) = " ...maybe a little green and"
soc$(13) = " mutated, but that's definitely"
soc$(14) = " him. How can that be?"
soc$(15) = "*Soldier #2: WHAAAAT?!?! HE'S"
soc$(16) = " SUPPOSED TO BE DEAD!!!"
soc$(17) = " HOW COULD ANYONE POSSIBLY"
soc$(18) = " SURVIVE THAT?!!?!??!?!?!?!??!!"
soc$(19) = "*Soldier #1: Don't let him"
soc$(20) = " escape!!! KILL HIM!!!"
Hablar soc$(), 10, 10
Hablar soc$(), 11, 14
Hablar soc$(), 15, 18
Hablar soc$(), 19, 20
ERASE soc$, d$
CLS
END SUB

SUB PutTheBulletBackground (m)
'CRAP CODE CUZ I CANT FIGURE OUT ARRAYS OF IMAGES
'IT PUTS THE BACKGROUND OF THE BULLET
   SELECT CASE m
     CASE 1
       PUT (sbx(m), sby(m)), sbg1, PSET
     CASE 2
       PUT (sbx(m), sby(m)), sbg2, PSET
     CASE 3
       PUT (sbx(m), sby(m)), sbg3, PSET
     CASE 4
       PUT (sbx(m), sby(m)), sbg4, PSET
     CASE 5
       PUT (sbx(m), sby(m)), sbg5, PSET
     CASE 6
       PUT (sbx(m), sby(m)), sbg6, PSET
   END SELECT
END SUB

SUB SNOOZE (delay!)
  startTime! = TIMER
  WHILE TIMER < (startTime! + delay!): WEND
END SUB

