%Summative started April 15, 2017

%Version 5.0.0
%Changelog
%-RELEASE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%-Fixed timer glitch thing
%-Fully mouse and keyboard supported menus
%-Music
%-Revamped & Functional inventory + item system
%-Fixed assertion error
    %-Hiscores!
%-Fixed bug that prevented diagonal movement when moving at max speed
%-Implemented Enemy movement
%-Implemented enemy attacks
%-Barrels are now rendered
%-Decreased speed of everything to make game smoother
%-Fixed bug where the game would kill off more enemies than actually died

import GUI

%Generic Vars

var x,y, lastX, lastY, button : int := 0
var input : array char of boolean
var random, codeCounter, random2, random3 : int := 1
var startTime : int
var timeToEscape : int := 601000 %in milliseconds, 1 second to load
var outOfTime : boolean := false

var hpBarColour : int := RGB.AddColor(80/255,255/255,80/255)
var menuColour : int := RGB.AddColor(24/255,189/255,38/255)
var titleFont : int := Font.New ("Leelawadee UI:26")
var hiscoreFont : int := Font.New ("power green:12")
var font : int := Font.New("power green:16")
var font2: int := Font.New("power green:24")
var getItemBox : int := Pic.FileNew("assets/textures/items/text.bmp")
%Vectors 
type vectorType :
record
    x,y : real %Stores target x and y
    limit : int
    baseMagnitude: int
end record

%Map
var mapData : int
var tile : flexible array 1 .. 1000, 1 .. 1000 of string
var wallHeight : int := 200
var mapSize : array 1 .. 2 of int := init (10,10)
var numOfEnemies : int := 0
const gridSize : int := 20
%Pic.ScreenLoad ("assets/maps/test.bmp", 0, 0, picCopy)

%for i : 0 .. mapSize (2)
% for i2 : 0 .. mapSize (1)
%    if whatdotcolour ((i2*gridSize)-10, (i*gridSize)-10) = black then
%     tile (i,i2) := true
% else 
%   tile (i,i2) := false
%   end if
% end for
    %end for
    
%cls

type weaponType : 
record
    name : string
    picture : int
    firePicture : int
    damage : int
    accuracy : int
    refire : int
    magazineSize : int
    bulletSize : int
end record

var weapon : array 1 .. 4 of weaponType

weapon (1).name := "Pistol"
weapon (1).damage := 25
weapon (1).accuracy := 40 %Spread of gun in pixels in one direction
weapon (1).refire := 500 %In milliseconds
weapon (1).magazineSize := 60
weapon (1).bulletSize := 20 %in pixels
weapon (1).picture := Pic.FileNew ("assets/textures/weapon/pistol.bmp")
weapon (1).firePicture := Pic.FileNew ("assets/textures/weapon/pistolFire.bmp")

weapon (2).name := "Assault Rifle"
weapon (2).damage := 15
weapon (2).accuracy := 80 %Spread of gun in pixels in one direction
weapon (2).refire := 10 %In milliseconds
weapon (2).magazineSize := 200
weapon (2).bulletSize := 5 %in pixels
weapon (2).picture := Pic.FileNew ("assets/textures/weapon/assaultrifle.bmp")
weapon (2).firePicture := Pic.FileNew ("assets/textures/weapon/assaultrifleFire.bmp")

weapon (3).name := "Rifle"
weapon (3).damage := 75
weapon (3).accuracy := 0 %Spread of gun in pixels in one direction
weapon (3).refire := 2500 %In milliseconds
weapon (3).magazineSize := 5
weapon (3).bulletSize := 30 %in pixels
weapon (3).picture := Pic.FileNew ("assets/textures/weapon/rifle.bmp")
weapon (3).firePicture := Pic.FileNew ("assets/textures/weapon/rifleFire.bmp")

weapon (4).name := "Shotgun"
weapon (4).damage := 45
weapon (4).accuracy := 120 %Spread of gun in pixels in one direction
weapon (4).refire := 1000 %In milliseconds
weapon (4).magazineSize := 25
weapon (4).bulletSize := 15 %in pixels
weapon (4).picture := Pic.FileNew ("assets/textures/weapon/shotgun.bmp")
weapon (4).firePicture := Pic.FileNew ("assets/textures/weapon/shotgunFire.bmp")


type inv :
record
    name : string
    description : string
    itemId : int
    picture : int
    itemType : string
    healPercent : real
end record

var tempItem : inv %For sorting
var item : array 1 .. 10 of inv
item (1).itemId := 1
item (1).name := weapon (1).name
item (1).picture := Pic.FileNew ("assets/textures/weapon/pistolMini.bmp")
item (1).description := "A standard pistol. Nothin' special"
item (1).itemType := "weapon"

item (2).itemId := 2
item (2).name := weapon (2).name
item (2).picture := Pic.FileNew ("assets/textures/weapon/assaultrifleMini.bmp")
item (2).description := "Low damage and accuracy, but high refire rate"
item (2).itemType := "weapon"


item (3).itemId := 3
item (3).name := weapon (3).name
item (3).picture := Pic.FileNew ("assets/textures/weapon/rifleMini.bmp")
item (3).description := "Slow, but hits hard and with pinpoint accuracy"
item (3).itemType := "weapon"

item (4).itemId := 4
item (4).name := weapon (4).name
item (4).picture := Pic.FileNew ("assets/textures/weapon/shotgunMini.bmp")
item (4).description := "Splash damage that is devastating at close range"
item (4).itemType := "weapon"

item (5).itemId := 5
item (5).name := "Health Pack"
item (5).picture := Pic.FileNew ("assets/textures/items/health.bmp")
item (5).description := "Use to heal a little of your HP"
item (5).itemType := "healing"
item (5).healPercent := 0.5

%Inventory
var inventoryBG : int := Pic.FileNew("assets/textures/items/inventory.bmp")
var selected : boolean := false
var itemNum : int := 1


type playerType :

record
    height, width : int
    direction : real
    speed : int
    walkForce : vectorType
    vector, acceleration : vectorType
    weight : int
    FOV : int
    x,y : real
    hp, maxHp : int
    spawnX, spawnY : int
    distanceToProjection : real
    cameraAcceleration, cameraDeceleration :int
    cameraSpeed, cameraSpeedLimit : int
    equippedWeapon, equippedItem : int
    refireTimer : int %Stores time weapon was fired
    ammo : int
    inventory : array 1 .. 9 of inv
    itemsInInventory : int
    invincible : boolean
end record
var player : playerType
player.x := 90
player.y := 90
player.FOV := 60
player.direction := 225
player.distanceToProjection := (maxx div 2) div tan (player.FOV div 2)
player.height := 200
player.width := 100
player.speed := 8

player.vector.x := 0
player.vector.y := 0
player.vector.limit := 6
player.acceleration.x := 0
player.acceleration.y := 0
player.acceleration.limit := 0
player.weight := 15
player.walkForce.baseMagnitude := 45

player.cameraSpeed := 0
player.cameraSpeedLimit := 12
player.cameraAcceleration := 4
player.cameraDeceleration := 6

player.equippedWeapon := 1
player.equippedItem := 1
player.refireTimer := 0
player.ammo := 1000

player.maxHp := 150
player.hp := player.maxHp
player.invincible := false

for i: 1 .. 9
    player.inventory(i).name := "Empty"
    player.inventory (i).itemType := "Empty"
end for
    
player.itemsInInventory := 1
player.inventory (player.itemsInInventory) := item (player.equippedWeapon)

type typeOfEnemy : %Type for each type of enemy
record 
    name : string
    baseWidth, baseHeight : int
    pictureFile, picture : array 0 .. 100 of array 1 .. 100 of array 1 .. 1000 of int %array 1 = animation, 2 = frame, 3= slice
    maxFrame : array 0 .. 100 of int
    delayBetweenFrames : int 
    maxHp : int
    
    aiType : string
    walkForce, accelerationLimit, vectorLimit, weight : int
    
    minTargetRadius, maxTargetRadius, aggroRadius : int
    refire, damage, accuracy : int
    invulnerable : boolean
end record

var enemyData : array 1 .. 4 of typeOfEnemy

enemyData (1).name := "guard"
enemyData (1).baseWidth := 80
enemyData (1).baseHeight := 150
enemyData (1).maxHp := 50
enemyData (1).delayBetweenFrames := 250 %In milliseconds
for i : 1 .. enemyData (1).baseWidth
    enemyData (1).pictureFile (1) (1) (i) := Pic.FileNew ("assets/textures/guard/default/guard"+intstr (i)+".bmp")
end for    
    enemyData (1).maxFrame (1) := 1
for i : 1 .. enemyData (1).baseWidth
    enemyData (1).pictureFile (2) (1) (i) := Pic.FileNew ("assets/textures/guard/walk 1/guard"+intstr (i)+".bmp")
end for    
    for i : 1 .. enemyData (1).baseWidth
    enemyData (1).pictureFile (2) (2) (i) := Pic.FileNew ("assets/textures/guard/walk 2/guard"+intstr (i)+".bmp")
end for   
    enemyData (1).maxFrame (2) := 2
for i : 1 .. enemyData (1).baseWidth
    enemyData (1).pictureFile (3) (1) (i) := Pic.FileNew ("assets/textures/guard/shooting/guard"+intstr (i)+".bmp")
end for    
    for i : 1 .. enemyData (1).baseWidth
    enemyData (1).pictureFile (3) (2) (i) := Pic.FileNew ("assets/textures/guard/shooting 2/guard"+intstr (i)+".bmp")
end for    
    enemyData (1).maxFrame (3) := 2
for i : 1 .. enemyData (1).baseWidth
    enemyData (1).pictureFile (0) (1) (i) := Pic.FileNew ("assets/textures/explosion/boom"+intstr (i)+".bmp")
end for
    enemyData (1).maxFrame (0) := 1

enemyData (1).walkForce := 30
enemyData (1).accelerationLimit := 0
enemyData (1).vectorLimit := 5
enemyData (1).weight := 14
enemyData (1).aiType := "guard"

enemyData (1).invulnerable := false
enemyData (1).minTargetRadius := gridSize * 4 %Distance at which enemy will back away
enemyData (1).maxTargetRadius := gridSize * 6
enemyData (1).aggroRadius := gridSize * 12 %Distance at which enemy will begin to advance
%Note: enemy will attack inbetween the min and max target radii
enemyData (1).damage := 20
enemyData (1).refire := 1000
enemyData (1).accuracy := 100 %Spread of the enemy's attack in pixels (in one direction)

enemyData (2).name := "barrel"
enemyData (2).baseWidth := 74
enemyData (2).baseHeight := 100
enemyData (2).maxHp := 25
enemyData (2).delayBetweenFrames := 0 %0 = infinite
for i : 1 .. enemyData (2).baseWidth
    enemyData (2).pictureFile (1) (1) (i) := Pic.FileNew ("assets/textures/barrel/barrel"+intstr (i)+".bmp")
end for    
    enemyData (2).maxFrame (1) := 1
enemyData (2).walkForce := 0
enemyData (2).accelerationLimit := 0
enemyData (2).vectorLimit := 10
enemyData (2).weight := 25
enemyData (2).aiType := "crate"

enemyData (2).invulnerable := true

enemyData (3).name := "goal"
enemyData (3).baseWidth := 74
enemyData (3).baseHeight := 150
enemyData (3).maxHp := 25
enemyData (3).delayBetweenFrames := 350 %0 = infinite
for i : 1 .. enemyData (2).baseWidth
    enemyData (3).pictureFile (1) (1) (i) := Pic.FileNew ("assets/textures/goal/goal 1/energy"+intstr (i)+".bmp")
    enemyData (3).pictureFile (1) (2) (i) := Pic.FileNew ("assets/textures/goal/goal 2/energy"+intstr (i)+".bmp")
end for    
    enemyData (3).maxFrame (1) := 2
enemyData (3).walkForce := 0
enemyData (3).accelerationLimit := 0
enemyData (3).vectorLimit := 10
enemyData (3).weight := 25
enemyData (3).aiType := "goal"

enemyData (3).invulnerable := true

enemyData (4).name := "boss"
enemyData (4).baseWidth := 82
enemyData (4).baseHeight := 175
enemyData (4).maxHp := 125
enemyData (4).delayBetweenFrames := 250 %In milliseconds
for i : 1 .. enemyData (4).baseWidth
    enemyData (4).pictureFile (1) (1) (i) := Pic.FileNew ("assets/textures/boss/default/boss"+intstr (i)+".bmp")
end for    
    enemyData (4).maxFrame (1) := 1
for i : 1 .. enemyData (4).baseWidth
    enemyData (4).pictureFile (3) (1) (i) := Pic.FileNew ("assets/textures/boss/fire/boss"+intstr (i)+".bmp")
    put Error.LastMsg
end for    
    enemyData (4).maxFrame (3) := 2 %Special code for boss because not enough pictures left in turing
for i : 1 .. enemyData (4).baseWidth
    enemyData (4).pictureFile (0) (1) (i) := Pic.FileNew ("assets/textures/explosion/boom"+intstr (i)+".bmp")
end for
    enemyData (4).maxFrame (0) := 1

enemyData (4).walkForce := 30
enemyData (4).accelerationLimit := 0
enemyData (4).vectorLimit := 5
enemyData (4).weight := 14
enemyData (4).aiType := "guard"

enemyData (4).invulnerable := false
enemyData (4).minTargetRadius := 0 %Distance at which enemy will back away
enemyData (4).maxTargetRadius := gridSize*14
enemyData (4).aggroRadius := gridSize *14 %Distance at which enemy will begin to advance
%Note: enemy will attack inbetween the min and max target radii
enemyData (4).damage := 30
enemyData (4).refire := 1250
enemyData (4).accuracy := 70 %Spread of the enemy's attack in pixels (in one direction)

type enemyType : %Type for each enemy
record
    id : int
    x,y : real
    hp, maxHp : int
    speed : int
    kindOfEnemy : int
    animation,lastAnimation, frame : int
    attackTimer, animationTimer : int
    lineOfSight : boolean
    
    angleToEnemy,angleToPlayer,direction : real
    walkForce : vectorType
    vector, acceleration : vectorType
    weight : int
    
    loot : int
end record

var enemy : flexible array 1 .. 1 of enemyType
var tempEnemy : enemyType

%Hiscores
type hiscore :
record
    name :string
    timer : string
end record
var score : array 1 .. 6 of hiscore
var temp: hiscore

var hiscoreWindow : int
var hiscoreData : int

var textbox, textboxFrame, textboxLabel : int  

%Forces
var tempVector : vectorType
var friction : vectorType
const mu : real := 0.06

%Ray casting variables
var angle : real := player.direction
var refX, refY : array 1 .. 2 of real := init (0,0)
var distanceToXWall, distanceToYWall : real := 10000

var distanceToWall : array 1 .. 640 of real

%Enemy ray casting variables
var angleToEnemy, distanceToEnemy, drawAngle : real := 0
var drawX : int := 0
var enemyWidth : int := 0

var enemyAtLocation : array 1 .. 640 of int %Stores what enemy is at each x coordinate; 0 means no enemy

%Floor casting variables
var distanceToFloor : int := 0
var floorColour, floorR,floorG,floorB : int := 8

%Load Textures
var wallTexture : array 1 .. gridSize, 1 .. 2 of int
for i : 1 .. gridSize
    wallTexture (i,1):= Pic.FileNew ("assets/textures/wall/wall"+intstr (gridSize - i+ 1)+".bmp") %the intstr loads pictures backwards to unflip them when rendered
end for
    
%Vector procedures
%Note: baseX and baseY are location values for the thing the vector applies to; eg. player.x and player.y
%Note2: vector x and y are relative to the baseX and baseY, so when adding and subtracting pretend baseX and baseY are the origin
procedure addVector (var baseX,baseY:real,vector:vectorType) %Add vector to a location
    baseX += vector.x
    baseY += vector.y
end addVector
    
procedure multiplyVector (var vector:vectorType,amount:real) %Multiply magnitude of vector
        vector.x := vector.x*amount
    vector.y := vector.y*amount
end multiplyVector
    
procedure addTwoVectors (var vector1: vectorType,vector2:vectorType) %Add two vectors together
    vector1.x += vector2.x
    vector1.y += vector2.y
    
    if Math.Distance (0,0, (vector1.x + vector2.x), (vector1.y+vector2.y)) >= vector1.limit and vector1.limit not= 0 then %Adjust vector to prevent vector from exceeding limit, limit of 0 = infinite limit
        multiplyVector (vector1, vector1.limit/Math.Distance (0,0, (vector1.x + vector2.x), (vector1.y+vector2.y)))
    end if
end addTwoVectors

procedure normalizeVector (var vector:vectorType) %Set a vector to have a magnitude of 1
    if Math.Distance (0,0,vector.x,vector.y) not= 0 then
        tempVector := vector
            vector.x := vector.x/Math.Distance (0,0,tempVector.x,tempVector.y)
        vector.y := vector.y/Math.Distance (0,0,tempVector.x,tempVector.y)
    end if
end normalizeVector
    
function forceVector (var force:vectorType, var mass : int):vectorType %F=ma (for adding)
    var resultForce :vectorType := force
    multiplyVector (resultForce, 1/mass)
    result resultForce
end forceVector
    
procedure changeVectorAngle (var force:vectorType, angle:real)
    if angle = 0 then
        force.x := force.baseMagnitude
        force.y := 0
    elsif angle = 90 then
        force.x := 0
        force.y := force.baseMagnitude
    elsif angle = 180 then
        force.x := -1*force.baseMagnitude
        force.y := 0
    elsif angle = 270 then
        force.x := 0
        force.y := -1*force.baseMagnitude
    else
        force.x := round (cosd ((angle - (angle div 360)*360))* force.baseMagnitude)
        force.y := round (sind ((angle - (angle div 360)*360))* force.baseMagnitude)
    end if
end changeVectorAngle

%Other procedures
function coord (pixel : real): int %Get coordinate value of entities on the grid
    result pixel div gridSize
end coord

procedure wrapAngle (var angle:real)
    if angle < 0 then %If angle is negative, loop to positive
        angle += ceil(abs (angle)/360)*360 
    elsif angle > 360 then %Keep angle from 0 - 360
        angle -= (angle div 360)*360
    end if
end wrapAngle

function map (x,y:int):string %Prevent errors resulting from requesting tiles out of bounds
    if y > mapSize (2) or y < 1 or x > mapSize (1) or x < 1 then
        result "o"
    else
        result tile (y,x)
    end if
end map

procedure spawnEnemy (kindOfEnemy,x,y:int)
    %Spawn a guard
    numOfEnemies += 1
    new enemy, numOfEnemies
    enemy (numOfEnemies).id := numOfEnemies
    enemy (numOfEnemies).kindOfEnemy := kindOfEnemy
    enemy (numOfEnemies).x := x*gridSize + gridSize div 2
    enemy (numOfEnemies).y:= y*gridSize + gridSize div 2
    enemy (numOfEnemies).animation := 1
    enemy (numOfEnemies).animationTimer := Time.Elapsed
    enemy (numOfEnemies).lastAnimation := 1
    enemy (numOfEnemies).frame := 1
    enemy (numOfEnemies).maxHp := enemyData (enemy (numOfEnemies).kindOfEnemy).maxHp
    enemy (numOfEnemies).hp := enemy (numOfEnemies).maxHp
    enemy (numOfEnemies).attackTimer := 0
    
    enemy (numOfEnemies).vector.x := 0
    enemy (numOfEnemies).vector.y := 0
    enemy (numOfEnemies).vector.limit := enemyData (enemy (numOfEnemies).kindOfEnemy).vectorLimit
    enemy (numOfEnemies).acceleration.x := 0
    enemy (numOfEnemies).acceleration.y := 0
    enemy (numOfEnemies).acceleration.limit := enemyData (enemy (numOfEnemies).kindOfEnemy).accelerationLimit
    enemy (numOfEnemies).weight := enemyData (enemy (numOfEnemies).kindOfEnemy).weight
    enemy (numOfEnemies).walkForce.baseMagnitude := enemyData (enemy (numOfEnemies).kindOfEnemy).walkForce
end spawnEnemy                

procedure loadMap %Load the map
    open : mapData, "assets/maps/level1.txt", get
    get : mapData, mapSize (1)
    get : mapData, mapSize (2)
    for decreasing i : mapSize (2) .. 1
        for i2 : 1 .. mapSize (1)
            get : mapData, tile (i, i2)
        end for
    end for
        close : mapData
    
    for i : 1 .. mapSize (2)
        for i2 : 1 .. mapSize (1)
            if map (i2,i) = "s" then
                %Set player spawnpoint
                player.spawnX := i2
                player.spawnY := i
            elsif map (i2,i) = "g" then
                spawnEnemy (3, i2, i)
            elsif map (i2,i) = "e" then
                spawnEnemy (1, i2, i)
            elsif map (i2,i) = "1" or map (i2,i) = "2" or map (i2,i) = "3" or map (i2,i) = "4" or map (i2,i) = "5" then
                spawnEnemy (2, i2, i)
                enemy (numOfEnemies).loot := strint (map (i2,i))
            elsif map (i2,i) = "b" then
                spawnEnemy (4,i2,i)
            end if
        end for
    end for
        
    player.x := player.spawnX*gridSize + gridSize div 2
    player.y := player.spawnY*gridSize + gridSize div 2
end loadMap

loadMap

var randomTrack : int := 1
process playMusic (track:int)
    if track = 1 then
        Music.PlayFile ("assets/sounds/gunfire.wav")
    elsif track = 2 then
        Music.PlayFile ("assets/sounds/heal.wav")
    elsif track = 3 then
        Music.PlayFile ("assets/sounds/equipWeapon.wav")
    elsif track = 4 then
        Music.PlayFile ("assets/sounds/getItem.wav")
    elsif track = 5 then
        Music.PlayFileLoop ("assets/sounds/mainMenu.mp3")
    elsif track = 6 then
        Music.PlayFileLoop ("assets/sounds/Dark Crater.mp3")
    elsif track = 7 then
        Music.PlayFileLoop ("assets/sounds/Lament.mp3")
    elsif track = 8 then
        Music.PlayFileLoop ("assets/sounds/Objection.mp3")
    elsif track = 9 then
        Music.PlayFile ("assets/sounds/menuHover.wav")
    elsif track = 10 then
        Music.PlayFile ("assets/sounds/menuSelect.wav")
    elsif track = 11 then
        Music.PlayFile ("assets/sounds/openMenu.wav")
    elsif track = 12 then
        Music.PlayFile ("assets/sounds/closeMenu.wav")
    elsif track = 13 then
        Music.PlayFile ("assets/sounds/enemyDeath.wav")
    elsif track = 14 then
        Music.PlayFile ("assets/sounds/outOfTime.wav")
    elsif track = 15 then
        Music.PlayFile ("assets/sounds/ow.wav")
    elsif track = 16 then
        Music.PlayFile ("assets/sounds/enemyFire.wav")
    end if
end playMusic

function getTime  :string
    if floor(((timeToEscape - (Time.Elapsed - startTime)) rem 60000)div 1000) <= 9 and floor(((timeToEscape - (Time.Elapsed - startTime)) rem 60000)div 1000) >= 0 then %Add a 0 if necessary
        result intstr ((timeToEscape - (Time.Elapsed - startTime)) div 60000) +":0"+intstr (floor(((timeToEscape - (Time.Elapsed - startTime)) rem 60000)div 1000))
    else
        result intstr ((timeToEscape - (Time.Elapsed - startTime)) div 60000) +":"+intstr (floor(((timeToEscape - (Time.Elapsed - startTime)) rem 60000)div 1000))
    end if
end getTime

function plusOrMinus (var num:real):int
    if num >= 0 then
        result +1
    else
        result -1
    end if
end plusOrMinus

function plusOrMinusX : int %Useless
    if angle < 270 and angle > 180 then
        result +1
    elsif angle < 180 and angle > 90 then
        result +1
    elsif angle > 0 and angle < 90 then
        result +1
    else
        result +1
    end if
end plusOrMinusX

function plusOrMinusY : int %Useless
    if angle > 0 and angle < 90 then
        result +1
    elsif angle > 90 and angle < 180 then
        result +1   
    elsif angle > 180 and angle < 270 then
        result +1
    else
        result +1
    end if
end plusOrMinusY

function offset (xy:real): int %What part of wall did ray intercept?
    result round (xy) - (coord (round (xy))*gridSize) + 1
end offset

procedure renderFloor (pixelX,pixelY:int, angle:real) %Deprecated (Too Slow)
    %Player's feet is the reference point
    distanceToFloor := -1*(0 - (player.height - ((player.height - pixelY) div player.distanceToProjection)))div  ((player.height - pixelY) div player.distanceToProjection) %Find x coordinate of floor from head, times -1 to give distance (since player is 0)
    
    if angle not= player.direction then %Correct if necessary for straight line distance
        distanceToFloor := distanceToFloor div cosd (player.direction - angle)
    end if
    
    if 0.75/(distanceToFloor div player.distanceToProjection) > 1 then
        RGB.SetColor (floorColour,1,1,1)
    else
        RGB.SetColor (floorColour, 0.75/(distanceToFloor div player.distanceToProjection),0.75/(distanceToFloor div player.distanceToProjection),0.75/(distanceToFloor div player.distanceToProjection))
    end if
    
    drawdot (pixelX,pixelY, floorColour)
    
end renderFloor
    
procedure reorderEnemies %Order enemies from furthest to closest
    for i : 1 .. numOfEnemies - 1 %For 6 times (each 1 is a pass, moves highest to back)
        for i2 : 1 .. numOfEnemies - 1 %This for is a swap, swaps 2 numbers
            if Math.Distance (player.x,player.y,enemy (i2).x,enemy (i2).y) < Math.Distance (player.x,player.y,enemy (i2 + 1).x,enemy (i2 + 1).y) then
                
                tempEnemy := enemy (i2 + 1)
                enemy (i2 + 1) := enemy (i2)
                enemy (i2) := tempEnemy
                
                %Swap back IDs so enemies keep same identifier
                tempEnemy.id := enemy (i2).id  
                enemy (i2).id  :=  enemy (i2 + 1).id
                enemy (i2 + 1).id :=  tempEnemy.id 
                
            end if
        end for
    end for
end reorderEnemies

procedure castRay (angle, x,y :real)
    if angle < 0.01 and angle >= 0 or angle > 359.9 and angle <= 360 then
        for i2 : coord (x) ..  mapSize (1)
            distanceToYWall := (i2)*gridSize - (x)
            exit when map (i2,coord (y)) = "w"
        end for
            refY (2) := y
    elsif angle < 90.01 and angle > 89.99  then
        for i2 : coord (y) ..  mapSize (2)
            distanceToXWall := (i2*gridSize - (y))
            exit when map (coord (x),i2) = "w"
        end for
            refX (1) := x
    elsif angle < 180.01 and angle > 179.99 then
        for decreasing i2 : coord (x) .. 0
            distanceToYWall := ((x) - (i2 + 1)*gridSize)
            exit when map (i2,coord (y)) = "w"
        end for
            refY (2) := y
    elsif angle < 270.01 and angle > 269.99 then
        for decreasing i2 : coord (y) .. 0
            distanceToXWall := ((y) - (i2 + 1)*gridSize) 
            %put distanceToXWall, " ", i2
            %Input.Pause
            exit when map (coord (x),i2) = "w"
        end for
            refX (1) := x
    else
        %Calculate starting coordinate for ray
        if angle > 0 and angle < 180 then
            refY (1) := (coord (y))*gridSize + gridSize
        else 
            refY (1) := coord (y)*gridSize - 1
        end if
        refX (1) := x + plusOrMinusX*(((refY (1) - y) / tand (angle)))
        
        loop %Check for nearest wall (horizontally)
            
            if coord (refX (1)) > mapSize (2) or coord (refX (1)) < 0 then
                distanceToXWall := 1000000
                exit
            end if
            
            % put coord (refX (1)),",",refX (1), " ", coord (refY (1)),",",refY (1), " ", angle
            % put x, " ", refY (1), " ", y (1), " ",tand (angle), " ", angle
            %Input.Pause
            
            if map (coord (refX (1)),coord (refY (1))) not= "w" then
                
                if angle > 0 and angle < 180 then
                    refY (1) += gridSize
                else
                    refY (1) -= gridSize
                end if
                
                refX (1) := x + plusOrMinusX*((refY (1) - y) / tand (angle))
                % refX := round ((refY - (y - (abs (tand (angle))* x))) / (tand (angle)))
                
            else
                distanceToXWall := sqrt ((x-refX (1))**2 + (y-refY (1))**2)
                exit
            end if
            
        end loop
        
        %Calculate starting coordinate for ray
        if angle > 90 and angle < 270 then
            refX (2) := coord (x)*gridSize - 1
        else 
            refX (2) := (coord (x))*gridSize + gridSize
        end if
        %put y + (refX - x)*tand (angle), " ", angle
        refY (2) := y + plusOrMinusY*(((refX (2) - x)*tand (angle)))
        
        loop %Check for nearest wall (vertically)
            
            if coord (refY (2)) > mapSize (2) or coord (refY (2)) < 0 then
                distanceToYWall := 1000000
                exit
            end if
            
            % put coord (refX),",",refX, " ", coord (refY),",",refY, " ", angle
            % put y, " ", refX, " ", x, " ",tand (angle), " ", angle
            %  Input.Pause
            if map (coord (refX (2)),coord (refY (2))) not= "w" then
                
                if angle < 270 and angle > 90 then
                    refX (2) -= gridSize
                else
                    refX (2) += gridSize
                end if
                
                refY (2) := y + plusOrMinusY*(((refX (2) - x)*tand (angle)))
                %refY := round (tand (angle)*refX + (y - (abs (tand (angle))* x)))
                
            else
                distanceToYWall := sqrt ((x-refX (2))**2 + (y-refY (2))**2)
                exit
            end if
            
        end loop
        
    end if
    
end castRay

procedure renderEnemy (var enemy : enemyType)
    
    %Special angles
    if player.x = enemy.x and player.y = enemy.y then
        angleToEnemy := 0
    elsif player.y = enemy.y and player.x > enemy.x then
        angleToEnemy := 180
    elsif player.y = enemy.y and player.x < enemy.x then
        angleToEnemy := 0
    elsif player.x = enemy.x and player.y > enemy.y then
        angleToEnemy := 270
    elsif player.x = enemy.x and player.y < enemy.y then
        angleToEnemy := 90
    else
        angleToEnemy := arctand ((enemy.y - player.y)/(enemy.x - player.x))
    end if
    
    if (enemy.y - player.y) > 0 and (enemy.x - player.x) < 0 then %If in quadrant 2
        angleToEnemy += 180
    elsif (enemy.y - player.y) < 0 and (enemy.x - player.x) < 0 then %If in quadrant 3
        angleToEnemy += 180
    elsif (enemy.y - player.y) < 0 and (enemy.x - player.x) > 0 then %If in quadrant 4
        angleToEnemy += 360 %Because angle is negative
    end if
    
    %Wrap around if needed
    wrapAngle (angleToEnemy)
    
    enemy.angleToEnemy := angleToEnemy %Save angleToEnemy for movement purposes
    
    %Wrap around angles again if needed
    if angleToEnemy > 270 and player.direction < 90 then
        drawAngle := player.direction + (player.FOV div 2) - angleToEnemy + 360
    elsif player.direction > 270 and angleToEnemy < 90 then
        drawAngle := player.direction + (player.FOV div 2) - angleToEnemy - 360
    else
        drawAngle := (player.direction + player.FOV div 2) - angleToEnemy
    end if
    
    
    drawX := round (drawAngle * (maxx/player.FOV))
    
    % if angleToEnemy - arctand ((enemy.width div 2)/Math.Distance (player.x,player.y,enemy.x,enemy.y)) > player.direction - (player.FOV div 2) and angleToEnemy - arctand ((enemy.width div 2)/Math.Distance (player.x,player.y,enemy.x,enemy.y)) < player.direction + (player.FOV div 2)  then
    %      for i : 1 .. enemy.width
    
    %     end for
        %  end if
    
    distanceToEnemy := Math.Distance (player.x,player.y,enemy.x,enemy.y)
    
    %Prevent program from breaking
    if distanceToEnemy = 0 then 
        distanceToEnemy := 1
    end if
    
    enemyWidth := floor (enemyData (enemy.kindOfEnemy).baseWidth * ((enemyData (enemy.kindOfEnemy).baseHeight/distanceToEnemy)*player.distanceToProjection*-2)/enemyData (enemy.kindOfEnemy).baseHeight)
    
    
    if drawX + ceil (enemyWidth/2) < maxx then %If right side is in frame then start from there
        for decreasing i : enemyWidth div 2 .. -1*(enemyWidth div 2)+1
            
            exit when drawX + i < 1 %Stop when out of frame
            
            if input ('i') then
                put distanceToEnemy, " ", distanceToWall (drawX + i)
                View.Update
                Input.Pause
            end if
            
            if distanceToEnemy < distanceToWall (drawX + i) then
                %put ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)
                
                if floor ((enemyData (enemy.kindOfEnemy).baseHeight/distanceToEnemy)*player.distanceToProjection*-2) > 4096 then
                    enemyData (enemy.kindOfEnemy).picture (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)) := Pic.Scale (enemyData (enemy.kindOfEnemy).pictureFile  (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)),1,4096)
                else
                    enemyData (enemy.kindOfEnemy).picture (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)) := Pic.Scale (enemyData (enemy.kindOfEnemy).pictureFile  (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)),1,ceil ((enemyData (enemy.kindOfEnemy).baseHeight/distanceToEnemy)*player.distanceToProjection*-2))
                end if
                Pic.Draw (enemyData (enemy.kindOfEnemy).picture (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)), drawX + i, player.height + floor ((wallHeight/distanceToEnemy)*player.distanceToProjection), picMerge)%Draw enemy where you would draw a wall
                Pic.Free (enemyData (enemy.kindOfEnemy).picture (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)))
                
                enemyAtLocation (drawX + i) := enemy.id
                % if drawX + i = maxx div 2 then
                % put enemy.id, enemyAtLocation
                %  View.Update
                %  Input.Pause
                %  end if
            end if
        end for
            
    elsif drawX - enemyWidth div 2 > 1 then %Elsif left side is in frame
        for i : -1*(enemyWidth div 2)+ 1 .. enemyWidth div 2 
            exit when drawX + i > maxx %Stop when out of frame
            if distanceToEnemy < distanceToWall (drawX + i) then
                %  put ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)
                
                if floor ((enemyData (enemy.kindOfEnemy).baseHeight/distanceToEnemy)*player.distanceToProjection*-2) > 4096 then
                    enemyData (enemy.kindOfEnemy).picture (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)) := Pic.Scale (enemyData (enemy.kindOfEnemy).pictureFile  (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)),1,4096)
                else
                    enemyData (enemy.kindOfEnemy).picture (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)) := Pic.Scale (enemyData (enemy.kindOfEnemy).pictureFile  (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)),1,floor ((enemyData (enemy.kindOfEnemy).baseHeight/distanceToEnemy)*player.distanceToProjection*-2))
                end if
                Pic.Draw (enemyData (enemy.kindOfEnemy).picture (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)), drawX + i, player.height + floor ((wallHeight/distanceToEnemy)*player.distanceToProjection), picMerge)
                Pic.Free (enemyData (enemy.kindOfEnemy).picture (enemy.animation)  (enemy.frame)  (ceil(enemyData (enemy.kindOfEnemy).baseWidth * (i+enemyWidth/2)/enemyWidth)))
                
                enemyAtLocation (drawX + i) := enemy.id
                
            end if
        end for
    end if
    
    enemy.angleToPlayer := angleToEnemy + 180
    
    %Does enemy have a line of sight to player?
    enemy.angleToPlayer := enemy.angleToEnemy + 180
    wrapAngle (enemy.angleToPlayer)
    castRay (enemy.angleToPlayer,enemy.x,enemy.y)
    if distanceToXWall <= distanceToYWall and distanceToEnemy < distanceToXWall or distanceToYWall < distanceToXWall and distanceToEnemy < distanceToYWall then
        
        enemy.lineOfSight := true
    else
        enemy.lineOfSight := false
    end if
    %Reset distances
    distanceToYWall := 10000
    distanceToXWall := 10000
    
end renderEnemy

%Render Image (Ray casting)
procedure render
    angle := player.direction - (player.FOV div 2)
    View.Set ("offscreenonly")
    cls
    
    %  put player.x, " ", player.y
    % put player.vector.x," ", player.vector.y
    for decreasing i : maxx .. 1
        
        castRay (angle,player.x,player.y)
        
        %put distanceToXWall," ", distanceToYWall, " ",angle
        %put refX (1), " ", refY (1), " ", offset (refX (1)), " ", offset (refY(1)), " ", distanceToXWall, " ", distanceToYWall, " ", angle
        %Input.Pause
        
        % Mouse.Where (x,y,button)
        % if button = 1 then
        %put angle
        %end if
        
        
        if distanceToXWall <= distanceToYWall and distanceToXWall not= 0 then
            %Not=0 prevents errors
            
            % if input ('i') then
            %     put offset (refX (1))
            %     View.Update
            % end if
            
            distanceToWall (i) := distanceToXWall %Store actual distance for enemy rendering
            distanceToXWall := distanceToXWall * cosd (player.direction-angle) %Remove fish eye
            
            %drawfillbox (i,player.height - floor ((wallHeight/distanceToXWall)*player.distanceToProjection),i+player.FOV div maxx, player.height + floor ((wallHeight/distanceToXWall)*player.distanceToProjection), black)
            %  loop
            
            % if input ('i') then
            %     put refX (1)," ", offset (refX (1))
            %     View.Update
            %      Input.Pause
            % end if
            
            if floor ((wallHeight/distanceToXWall)*player.distanceToProjection)*-2 > 4096 then %Prevent erroring out
                wallTexture (offset (refX (1)),2) := Pic.Scale (wallTexture (offset (refX (1)),1),1,4069)
            else
                wallTexture (offset (refX (1)),2) := Pic.Scale (wallTexture (offset (refX (1)),1),1,floor ((wallHeight/distanceToXWall)*player.distanceToProjection)*-2) %Scale wall picture to wall size, and *-2 to unflip the image
            end if
            
            % exit when wallTexture (offset (refX (1)),2) not= 0
            %           put Error.LastMsg
            %     View.Update
            % end loop
            
            
            Pic.Draw (wallTexture (offset (refX (1)),2),i,player.height + floor ((wallHeight/distanceToXWall)*player.distanceToProjection), picCopy) %Draw texture
            Pic.Free (wallTexture (offset (refX (1)),2))
            
            %  for decreasing j : player.height + floor ((wallHeight/distanceToXWall)*player.distanceToProjection) .. 1
            %       renderFloor (i,j,angle)
            %  end for
                
            %put refX (1), " ", refY (1), " ", offset (refX (1)), " ", offset (refY(1)), " ", distanceToXWall, " ", distanceToYWall, " ", angle
            % View.Update
            % Input.Pause
            
        elsif distanceToYWall < distanceToXWall and distanceToYWall not= 0 then
            %Not= 0 prevents errors
            
            % if input ('i') then
            %    put offset (refY (2))
            %     View.Update
            % end if
            
            distanceToWall (i) := distanceToYWall %Store actual distance for enemy rendering
            distanceToYWall := distanceToYWall * cosd (player.direction-angle) %Remove fish eye
            
            %drawfillbox (i,player.height - floor ((wallHeight/distanceToYWall)*player.distanceToProjection),i+player.FOV div maxx, player.height + floor ((wallHeight/distanceToYWall)*player.distanceToProjection), black)
            %loop
            
            if floor ((wallHeight/distanceToYWall)*player.distanceToProjection)*-2 > 4096 then %Prevent erroring out
                wallTexture (offset (refY (2)),2) := Pic.Scale (wallTexture (offset (refY (2)),1),1,4096)
            else
                wallTexture (offset (refY (2)),2) := Pic.Scale (wallTexture (offset (refY (2)),1),1,floor ((wallHeight/distanceToYWall)*player.distanceToProjection)*-2) %Scale wall picture to wall size, and *-2 to unflip the image
            end if
            
            %    exit when wallTexture (offset (refY (1)),2) not= 0
            %  put Error.LastMsg
            %   View.Update
            % end loop
            %   if input ('i') then
            %   put wallTexture (offset (refY (1)),2)
            %    View.Update
            %  end if
            Pic.Draw (wallTexture (offset (refY (2)),2),i,player.height + floor ((wallHeight/distanceToYWall)*player.distanceToProjection), picCopy) %Draw texture
            Pic.Free (wallTexture (offset (refY (2)),2))
            
            % for decreasing j : player.height + floor ((wallHeight/distanceToYWall)*player.distanceToProjection) .. 1
            %       renderFloor (i,j,angle)
            % end for
                
            % put refX (2), " ", refY (2), " ", offset (refX (2)), " ", offset (refY(2)), " ", distanceToXWall, " ", distanceToYWall, " ", angle
            % Input.Pause
            
        end if 
        
        if angle + player.FOV/ maxx >= 360 then
            angle := 0  
        else
            angle += player.FOV/ maxx
        end if
        
        %Reset distances
        distanceToXWall := 10000
        distanceToYWall := 10000
        
        enemyAtLocation (i) := 0
    end for
        
    if numOfEnemies > 0 then
        reorderEnemies
        
        %DrawSprites
        for i : 1 .. numOfEnemies
            renderEnemy (enemy (i))
        end for
            
    end if
    %DEBUG
    %  put player.x, " ", player.y
    
    
    %Draw GUI
    Pic.ScreenLoad ("assets/textures/GUI/hpBar.bmp", 20,20,picMerge)
    drawfillbox (51,30,51 + round (player.hp/player.maxHp * 216),36,hpBarColour) %draw hp bar
    Pic.Draw (weapon (player.equippedWeapon).picture,0,0,picMerge)
    %drawbox (320 - weapon (player.equippedWeapon).accuracy,200 - 20, 320 + weapon (player.equippedWeapon).accuracy, 200 + 20, magenta)
    Draw.ThickLine (maxx div 2, maxy div 2 + 10, maxx div 2, maxy div 2 + 30, 3, hpBarColour)
    Draw.ThickLine (maxx div 2, maxy div 2 - 10, maxx div 2, maxy div 2 - 30, 3, hpBarColour)
    Draw.ThickLine (maxx div 2  + 10, maxy div 2, maxx div 2  + 30, maxy div 2, 3, hpBarColour)
    Draw.ThickLine (maxx div 2  - 10, maxy div 2, maxx div 2  - 30, maxy div 2, 3, hpBarColour)
    
    if (timeToEscape - (Time.Elapsed - startTime)) div 60000 <= 0 then
        Font.Draw (getTime,maxx - 10 - Font.Width (getTime,font), 375, font, 12)
        
        %Play out of time music
        if outOfTime = false then
            fork playMusic (14)
            outOfTime := true
        end if
        
    else
        Font.Draw (getTime,maxx - 10 - Font.Width (getTime,font), 375, font, hpBarColour)
    end if
    View.Set ("nooffscreenonly")
end render


procedure OldMove (angle : real) %Move player
    if (angle - (angle div 360)*360) = 0 or (angle - (angle div 360)*360) = 360 then %Subtract if necessary to get angle below 360
        %Special Angles
        if map (coord (player.x+player.speed+gridSize div 3), coord (player.y)) not= 'w' then %If statements prevent walking through walls
            player.x += player.speed
        end if
    elsif (angle - (angle div 360)*360) = 90 then
        if map (coord (player.x), coord (player.y+player.speed+gridSize div 3)) not= 'w' then
            player.y += player.speed
        end if
    elsif (angle - (angle div 360)*360) = 180 then 
        if map (coord (player.x-player.speed-gridSize div 3), coord (player.y)) not= 'w' then
            player.x -= player.speed
        end if
    elsif (angle - (angle div 360)*360) = 270 then
        if map (coord (player.x), coord (player.y-player.speed-gridSize div 3)) not= 'w' then
            player.y -= player.speed
        end if
    else
        %Not Special Angles
        if round (cosd ((angle - (angle div 360)*360))* player.speed) > 0 and map (coord(player.x + round (cosd ((angle - (angle div 360)*360))* player.speed)+gridSize div 3),coord (player.y)) not= 'w' or round (cosd ((angle - (angle div 360)*360))* player.speed) < 0 and map (coord(player.x + round (cosd ((angle - (angle div 360)*360))* player.speed)-gridSize div 3),coord (player.y)) not= 'w' then
            player.x += round (cosd ((angle - (angle div 360)*360))* player.speed)
        end if
        if round (sind ((angle - (angle div 360)*360))* player.speed) > 0 and map (coord(player.x),coord (player.y + round (sind ((angle - (angle div 360)*360))* player.speed)+gridSize div 3)) not= 'w' or round (sind ((angle - (angle div 360)*360))* player.speed) < 0 and map (coord (player.x),coord(player.y + round (sind ((angle - (angle div 360)*360))* player.speed)-gridSize div 3)) not= 'w' then
            player.y += round (sind ((angle - (angle div 360)*360))* player.speed)
        end if
    end if
end OldMove

procedure move %Move player
    %put Math.Distance (0,0,player.vector.x,player.vector.y)
    
    %Friction
    friction := player.vector
        normalizeVector (friction)
    multiplyVector (friction, (-1*mu*20))
    if abs (Math.Distance (0,0,player.vector.x,player.vector.y)) > abs (Math.Distance (0,0,friction.x,friction.y)) then %If player velocity > friction then apply friction
        addTwoVectors (player.acceleration,friction)
    else %Otherwise stop object
        multiplyVector (player.vector,0) 
    end if
    
    %Add acceleration to player
    addTwoVectors (player.vector,player.acceleration)
    
    % put player.vector.x," ",player.vector.y
    % Input.Pause
    
    %Move player
    if map (coord (player.x+player.vector.x+(plusOrMinus (player.vector.x)*gridSize/3)), coord (player.y+player.vector.y+(plusOrMinus (player.vector.y)*gridSize/3))) not= 'w' then
        addVector (player.x,player.y,player.vector)
        %   put player.x," ",player.y, " ", player.vector.x, " ", player.vector.y
    elsif map (coord (player.x+player.vector.x+(plusOrMinus (player.vector.x)*gridSize/3)),coord (player.y)) not= 'w' then
        %     put player.x," ",player.y
        player.x += player.vector.x
        %     put player.x," ",player.y
        
    elsif map (coord (player.x), coord (player.y+player.vector.y+(plusOrMinus (player.vector.y)*gridSize/3))) not= 'w' then
        % put player.x," ",player.y
        player.y += player.vector.y
        %put player.x," ",player.y
    end if
    
    multiplyVector (player.acceleration, 0)%Reset player acceleration
end move

procedure changeAnimation (var entity : enemyType, animation:int)
    
    if entity.lastAnimation not= animation then
        entity.animation := animation
        entity.frame := 1
        entity.animationTimer := Time.Elapsed
        entity.lastAnimation := animation
    end if
end changeAnimation

procedure drawHit (centerPixel : int)
    %Draw hit marker when hit
    Draw.ThickLine (centerPixel + 10, maxy div 2 + 10, centerPixel + 17, maxy div 2 + 17, 3, hpBarColour)
    Draw.ThickLine (centerPixel - 10, maxy div 2 + 10, centerPixel - 17, maxy div 2 + 17, 3, hpBarColour)
    Draw.ThickLine (centerPixel - 10, maxy div 2 - 10, centerPixel - 17, maxy div 2 - 17, 3, hpBarColour)
    Draw.ThickLine (centerPixel + 10, maxy div 2 - 10, centerPixel + 17, maxy div 2 - 17, 3, hpBarColour)
    
end drawHit

procedure shoot (targetPixel : int) %Shoot gun
    
    for i : 0 .. weapon (player.equippedWeapon).bulletSize div 2 
        
        if enemyAtLocation (targetPixel + maxx div 2 + i) not= 0 and enemyData (enemy (enemyAtLocation (targetPixel + maxx div 2 + i)).kindOfEnemy).invulnerable = false then %if on right side of bullet center and enemy can be damaged
            
            enemy (enemyAtLocation (targetPixel + maxx div 2 + i)).hp -= weapon (player.equippedWeapon).damage
            
            drawHit (targetPixel + maxx div 2 + i)
            
            %If enemy's hp is less than 0 then
            if enemy (enemyAtLocation (targetPixel + maxx div 2 + i)).hp <= 0 then
                changeAnimation (enemy (enemyAtLocation (targetPixel + maxx div 2 + i)),0)
                %Animation of 0 = dead
            end if
            
            exit %Exit if bullet has hit a target
        elsif enemyAtLocation (targetPixel + maxx div 2 - i) not= 0 and enemyData (enemy (enemyAtLocation (targetPixel + maxx div 2 - i)).kindOfEnemy).invulnerable = false then %If on left side of bullet center
            
            enemy (enemyAtLocation (targetPixel + maxx div 2 - i)).hp -= weapon (player.equippedWeapon).damage
            
            drawHit (targetPixel + maxx div 2 - i)
            
            %If enemy's hp is less than 0 then
            if enemy (enemyAtLocation (targetPixel + maxx div 2 - i)).hp <= 0 then
                changeAnimation (enemy (enemyAtLocation (targetPixel + maxx div 2 - i)),0)
                %Animation of 0 = dead
            end if
            
            exit %Exit if bullet has hit a target
        end if
    end for
        player.refireTimer := Time.Elapsed
    
end shoot

function scoreIsLess (score1,score2:string):boolean %See which time is better
    for i : 1 .. length (score1)
        if score1 (i) = ":" then
            for j: 1 .. length (score2)
                if score2 (j) = ":" then
                    if strint (score1 (1 .. i - 1)) < strint  (score2 (1 .. j - 1)) then
                        result true
                    elsif strint (score1 (1 .. i - 1)) = strint  (score2 (1 .. j - 1)) then
                        if strint (score1 (i + 1 .. length (score1))) < strint  (score2 (j + 1 .. length (score2))) then
                            result true
                        else 
                            result false
                        end if
                    else 
                        result false
                    end if
                end if
            end for
        end if
    end for
        
end scoreIsLess

function scoreIsEqual (score1, score2:string): boolean
    for i : 1 .. length (score1)
        if score1 (i) = ":" then
            for j: 1 .. length (score2)
                if score2 (j) = ":" then
                    if strint (score1 (1 .. i - 1)) = strint  (score2 (1 .. j - 1)) and strint (score1 (i + 1 .. length (score1))) = strint  (score2 (j + 1 .. length (score2))) then
                        result true
                    else 
                        result false
                    end if
                end if
            end for
        end if
    end for
end scoreIsEqual

procedure nameEntered (name:string) %If player has inputted a name
    fork playMusic (10)
    if scoreIsLess (score (6).timer,score (5).timer) or scoreIsEqual (score (6).timer,score (5).timer) then
        Font.Draw ("Your time remaining is too low!", 10, 58,font,black)
        GUI.Hide (textbox)
        GUI.Refresh
        random := 1
    else
        %Redraw hiscores
        cls
        GUI.Dispose (textbox)
        GUI.Dispose (textboxFrame)
        GUI.Dispose (textboxLabel)
        random3 := 2
        Font.Draw ("High Scores", maxx div 2 - Font.Width ("High Scores",titleFont) div 2, 320, titleFont, black)
        
        %Make sure player has a name
        random3 := 1
        for i : 1 .. length (score (6).name)
            if score (6).name (i) not= " " then
                random3 := 2
            end if
        end for
            if random3 = 1 then
            score (6).name := "No Name"
        end if
        
        %Reorder highscores from least to greatest
        for i : 1 .. 5
            for j : 1 .. 5
                if scoreIsLess (score (j).timer,score (j+1).timer) then
                    temp.timer := score (j+1).timer
                    temp.name := score (j+1).name
                    score (j+1).timer := score (j).timer
                    score (j+1).name := score (j).name
                    score (j).timer := temp.timer
                    score (j).name := temp.name
                end if
            end for
        end for
            
        %Draw hiscores
        for i : 1 .. 5
            Font.Draw (score (i).name, 10, 270 - (i-1)*30,hiscoreFont,black)
            Font.Draw (score (i).timer, maxx - 10 - Font.Width (score (i).timer,hiscoreFont), 270 - (i-1)*30,hiscoreFont,black)
        end for
            
        %Save new hiscores
        open : hiscoreData, "assets/hiScores.txt", put
        for i : 1 .. 5
            put : hiscoreData, score (i).name
            put : hiscoreData, score (i).timer
        end for
            close : hiscoreData
        
        drawfillbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2,maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, 117)
        Font.Draw ("Exit", maxx div 2 - Font.Width ("Exit",font) div 2, 5,font, black)
        
        loop
            mousewhere (x,y,button)
            Input.KeyDown (input)
            
            if lastX not= x and lastY not= y then
                if x > maxx div 2 - 10 - Font.Width ("Exit",font) div 2 and x < maxx div 2 + Font.Width ("Exit",font) div 2 + 10 and y > 2 and y < 20 then
                    
                    drawbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2, maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, brightgreen)
                    random := 6
                    
                    if random2 = 0 then
                        fork playMusic (9)
                        random2 := 1
                    end if
                else
                    drawbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2, maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, green)
                    random2 := 0
                    random := 1
                end if
                lastX := x
                lastY := y
            end if
            
            if input (KEY_UP_ARROW) or input (KEY_DOWN_ARROW) or input (KEY_LEFT_ARROW) or input (KEY_RIGHT_ARROW) then
                drawbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2, maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, brightgreen)
                random := 2
                fork playMusic (9)
            end if
            
            exit when x >= maxx div 2 - 10 - Font.Width ("Exit",font) div 2 and x <= maxx div 2 + Font.Width ("Exit",font) div 2 + 10 and y >= 2 and y <= 20 and button = 1 or input (' ') and random = 2 or input (KEY_ENTER) and random = 2 %Exit when button is pressed
        end loop
    end if
    
    
end nameEntered

procedure openHighScores
    
    hiscoreWindow := Window.Open ("title:High Scores, position:top;center,graphics:300;350")
    Window.Select (hiscoreWindow)
    
    random3 := 1
    
    Font.Draw ("High Scores", maxx div 2 - Font.Width ("High Scores",titleFont) div 2, 320, titleFont, black)
    
    %Get high score data from file
    open : hiscoreData, "assets/hiScores.txt", get
    for i : 1 .. 5
        get : hiscoreData, score (i).name :*
        get : hiscoreData , score (i).timer :*
    end for
        close : hiscoreData
    
    %Draw hiscores
    Font.Draw ("Name", 10, 275, font, darkgrey)
    Font.Draw ("Time Remaining", maxx - 10 - Font.Width ("Time Remaining",font), 275, font, darkgrey)
    for i : 1 .. 5
        Font.Draw (score (i).name, 10, 250 - (i-1)*30,hiscoreFont,black)
        Font.Draw (score (i).timer, maxx - 10 - Font.Width (score (i).timer,hiscoreFont), 250 - (i-1)*30,hiscoreFont,black)
    end for
        
    %Textbox
    
    Font.Draw (score (6).timer, maxx - Font.Width (score (6).timer,hiscoreFont),30,hiscoreFont,black)
    textboxFrame := GUI.CreateFrame (10,25,maxx - 30 - Font.Width (score (6).timer,hiscoreFont), 46, GUI.INDENT)
    textboxLabel := GUI.CreateLabelFull (10,25, "Type in name to save score",maxx - 30 - Font.Width (score (6).timer,hiscoreFont) - 10,46 - 25, GUI.CENTER + GUI.TOP,hiscoreFont) 
    textbox := GUI.CreateTextFieldFull (10,25,maxx - 30 - Font.Width (score (6).timer,hiscoreFont),"", nameEntered, GUI.INDENT, hiscoreFont,GUI.ANY)
    GUI.Hide (textbox)
    GUI.Refresh
    
    drawfillbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2,maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, 117)
    Font.Draw ("Exit", maxx div 2 - Font.Width ("Exit",font) div 2, 5,font, white)
    
    random := 1
    random2 := 0
    mousewhere (x,y,button)
    lastX := x
    lastY := y
    loop
        mousewhere (x,y,button)
        score (6).name := GUI.GetText (textbox)
        exit when GUI.ProcessEvent
        
        exit when random = 6
        
        if lastX not= x and lastY not= y then
            if x > 10 and x < maxx - 30 - Font.Width (score (6).timer,hiscoreFont) and y > 25 and y < 46 then
                
                GUI.Show (textbox)
                GUI.SetActive (textbox)
                drawbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2, maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, green)
                random := 0
                
                if random2 = 0 then
                    fork playMusic (9)
                    random2 := 1
                end if
            elsif x > maxx div 2 - 10 - Font.Width ("Exit",font) div 2 and x < maxx div 2 + Font.Width ("Exit",font) div 2 + 10 and y > 2 and y < 20 then
                
                GUI.Hide (textbox)
                GUI.Refresh
                drawbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2, maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, brightgreen)
                random := 2
                
                if random2 = 0 then
                    fork playMusic (9)
                    random2 := 1
                end if
            else
                GUI.Hide (textbox)
                GUI.Refresh
                drawbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2, maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, green)
                random2 := 0
                random := 1
            end if
            lastX := x
            lastY := y
        end if
        
        if random = 1 or random = 2 then
            Input.KeyDown (input)
            
            if input (KEY_UP_ARROW) then
                GUI.Show (textbox)
                GUI.SetActive (textbox)
                drawbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2, maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, green)
                random := 0
                fork playMusic (9)
            elsif input (KEY_DOWN_ARROW) then
                GUI.Hide (textbox)
                GUI.Refresh
                drawbox (maxx div 2 - 10 - Font.Width ("Exit",font) div 2, 2, maxx div 2 + Font.Width ("Exit",font) div 2 + 10, 20, brightgreen)
                random := 2
                fork playMusic (9)
            end if
        end if
        
        exit when x > maxx div 2 - 10 - Font.Width ("Exit",font) div 2 and x < maxx div 2 + Font.Width ("Exit",font) div 2 + 10 and y > 2 and y < 20 and button = 1 or random = 2 and input (KEY_ENTER) or random = 2 and input (' ')
    end loop
    
    fork playMusic (10)
    
    if random3 = 1 then %If not already gotten rid of
        GUI.Dispose (textbox)
        GUI.Dispose (textboxFrame)
        GUI.Dispose (textboxLabel)
    end if
    
    random := 1 %Leave cursor on highscores on victory screen
    Input.KeyDown (input)
    Window.Close (hiscoreWindow)
    
end openHighScores

procedure reload %Reload game, reset variables
    fork playMusic (6)
    player.hp := player.maxHp
    player.itemsInInventory := 1
    player.equippedItem := 1
    player.equippedWeapon := 1
    player.direction := 225
    numOfEnemies := 0
    outOfTime := false
    loadMap
    
    startTime := Time.Elapsed
end reload

procedure winScreen
    fork playMusic (8)
    score (6).timer := getTime
    random := 0
    random2 := 0
    View.Set ("offscreenonly")
    %Store x and y
    mousewhere (x,y,button)
    lastX := x
    lastY := y
    loop
        mousewhere(x,y,button)
        Input.KeyDown (input)
        
        %If mouse changes position, switch to mouse control
        if lastX not= x and lastY not= y then
            if x > maxx div 4 - Font.Width ("High Scores",font2) div 2 - 10 and x < (maxx div 4 + Font.Width ("High Scores",font2) div 2 + 10) and y > 302 and y < 328 then
                random := 1
                
                if random2 = 0 then
                    fork playMusic (9)
                    random2 := 1
                end if
            elsif x > (maxx div 4) * 3 - Font.Width ("Retry",font2) div 2 - 10 and x < (maxx div 4) * 3 + Font.Width ("Retry",font2) div 2 + 10 and y > 47 and y < 73 then
                random := 2
                if random2 = 0 then
                    fork playMusic (9)
                    random2 := 1
                end if
            else
                random := 0
                random2 := 0
            end if
            lastX := x
            lastY := y
        end if
        
        if input (KEY_RIGHT_ARROW) or input (KEY_DOWN_ARROW) then
            random := 2
            fork playMusic (9)
        elsif input (KEY_LEFT_ARROW) or input (KEY_UP_ARROW) then
            random := 1
            fork playMusic (9)
        end if
        
        %Draw screen
        if random = 1 then
            Pic.ScreenLoad("assets/textures/GUI/victory.bmp", 0, 0, picMerge)
            Font.Draw("High Scores", maxx div 4 - Font.Width ("High Scores",font2) div 2, 305, font2, menuColour)
            Font.Draw("Retry",  (maxx div 4) * 3 - Font.Width ("Retry",font2) div 2, 52, font2, menuColour)
            drawbox (maxx div 4 - Font.Width ("High Scores",font2) div 2 - 10, 302, (maxx div 4 + Font.Width ("High Scores",font2) div 2 + 10), 328,menuColour)
            if button = 1 or input (' ') or input (KEY_ENTER) then
                fork playMusic (10)
                openHighScores
            end if
        elsif random = 2 then
            Pic.ScreenLoad("assets/textures/GUI/victory.bmp", 0, 0, picMerge)
            Font.Draw("High Scores", maxx div 4 - Font.Width ("High Scores",font2) div 2, 305, font2, menuColour)
            Font.Draw("Retry",  (maxx div 4) * 3 - Font.Width ("Retry",font2) div 2, 52, font2, menuColour)
            drawbox ((maxx div 4) * 3 - Font.Width ("Retry",font2) div 2 - 10, 47,(maxx div 4) * 3 + Font.Width ("Retry",font2) div 2 + 10, 73, menuColour)
            if button = 1 or input (' ') or input (KEY_ENTER) then
                fork playMusic (10)
                exit
            end if
        else
            Pic.ScreenLoad("assets/textures/GUI/victory.bmp", 0, 0, picMerge)
            Font.Draw("High Scores", maxx div 4 - Font.Width ("High Scores",font2) div 2, 305, font2, menuColour)
            Font.Draw("Retry",  (maxx div 4) * 3 - Font.Width ("Retry",font2) div 2, 52, font2, menuColour)
        end if                
        View.Update
    end loop
    View.Set ("nooffscreenonly")
    
    %Reset game
    reload
end winScreen

procedure loseScreen
    
    fork playMusic (7)
    
    random := 0
    random2 := 0
    %Store x and y
    mousewhere (x,y,button)
    lastX := x
    lastY := y
    
    View.Set ("offscreenonly")
    loop
        mousewhere(x,y,button)
        Input.KeyDown (input)
        
        %If mouse changes position, switch to mouse control
        if lastX not= x and lastY not= y then
            if x > maxx div 2 - Font.Width ("Retry", font2) div 2 - 10 and x < maxx div 2 + Font.Width ("Retry", font2) div 2 + 10 and y > 52 and y < 78 then
                random := 1
                
                if random2 = 0 then
                    fork playMusic (9)
                    random2 := 1
                end if
            else
                random := 0
                random2 := 0
            end if
            lastX := x
            lastY := y
        end if
        
        if input (KEY_RIGHT_ARROW) or input (KEY_DOWN_ARROW) or input (KEY_LEFT_ARROW) or input (KEY_UP_ARROW) then
            random := 1
            fork playMusic (9)
        end if
        
        %Draw screen
        if random = 1 then
            Pic.ScreenLoad("assets/textures/GUI/you-died.bmp", 0, 0, picMerge)
            Font.Draw("Retry", maxx div 2 - Font.Width ("Retry", font2) div 2, 55, font2, menuColour)
            drawbox (maxx div 2 - Font.Width ("Retry", font2) div 2 - 10, 52, maxx div 2 + Font.Width ("Retry", font2) div 2 + 10, 78,menuColour)
            if button = 1 or input (' ') or input (KEY_ENTER) then
                fork playMusic (10)
                exit
            end if
        else
            Pic.ScreenLoad("assets/textures/GUI/you-died.bmp", 0, 0, picMerge)
            Font.Draw("Retry", maxx div 2 - Font.Width ("Retry", font2) div 2, 55, font2, menuColour)
        end if
        
        View.Update
    end loop
    View.Set ("nooffscreenonly")
    
    %Reload game
    reload
end loseScreen

procedure controlsScreen
    random := 0
    random2 := 0
    %Store x and y
    mousewhere (x,y,button)
    lastX := x
    lastY := y
    
    View.Set ("offscreenonly")
    loop
        mousewhere(x,y,button)
        Input.KeyDown (input)
        
        %If mouse changes position, switch to mouse control
        if lastX not= x and lastY not= y then
            if x > 10 and x < 20 + Font.Width ("Back", titleFont) + 10 and y > 367 and y < 396 then
                random := 1
                
                if random2 = 0 then
                    fork playMusic (9)
                    random2 := 1
                end if
            else
                random := 0
                random2 := 0
            end if
            lastX := x
            lastY := y
        end if
        
        if input (KEY_RIGHT_ARROW) or input (KEY_DOWN_ARROW) or input (KEY_LEFT_ARROW) or input (KEY_UP_ARROW) then
            random := 1
            fork playMusic (9)
        end if
        
        %Draw screen
        if random = 1 then
            Pic.ScreenLoad("assets/textures/GUI/controls.bmp", 0, 0, picMerge)
            Font.Draw("Back", 20, 370, titleFont, white)
            drawbox (10, 367, 20 + Font.Width ("Back", titleFont) + 10, 396,menuColour)
            if button = 1 or input (' ') or input (KEY_ENTER) then
                fork playMusic (10)
                exit
            end if
        else
            Pic.ScreenLoad("assets/textures/GUI/controls.bmp", 0, 0, picMerge)
            Font.Draw("Back", 20, 370, titleFont, white)
        end if
        
        View.Update
    end loop
    View.Set ("nooffscreenonly")
    
    %Reset vars
    random := 2
    delay (150)
    Input.KeyDown (input)
end controlsScreen

procedure itemGet (var itemName : string, itemPic : int) %Popup when getting item
    fork playMusic (4)
    
    Pic.Draw(getItemBox, maxx div 2 - Pic.Width (getItemBox) div 2, 270, picMerge)
    Font.Draw ("Item Obtained", maxx div 2 - Font.Width ("Item Obtained",font) div 2, 347, font, white)
    Font.Draw(itemName, maxx div 2 - Pic.Width (getItemBox) div 2 + 50, 310, font, white)
    Pic.Draw(itemPic,  maxx div 2 + Pic.Width (getItemBox) div 2 - Pic.Width (itemPic) - 50, 270 + Pic.Height (getItemBox) div 2 - Pic.Height (itemPic) div 2, picMerge)
    Font.Draw ("Press Enter/Space to Continue", maxx div 2 - Font.Width ("Press Enter/Space to Continue",font) div 2, 272, font, white)
    loop
        Input.KeyDown (input)
        Mouse.Where (x,y,button)
        exit when input(KEY_ENTER) or input (' ') or button = 1
    end loop
    
    delay (150) %Allow time for player to release space bar
    Input.KeyDown (input) %Refresh input
end itemGet

procedure displayParagraph (paragraph : string, startingCharacter, leftX, rightX, y,padding, font, clr : int)
    
    random := startingCharacter - 1
    for i : startingCharacter .. length (paragraph)
        if paragraph (i) = " " then
            random := i %Store value of spaces so program only line skips after a word
        end if
        
        if Font.Width (paragraph (startingCharacter .. i),font) >= rightX - leftX then %If string too long, move to next line and call procedure again
            Font.Draw (paragraph (startingCharacter .. random),leftX,y,font,clr)
            if random < length (paragraph) then
                displayParagraph (paragraph, random + 1, leftX, rightX, y - padding,padding, font, clr) %THE POWER OF RECURSION -> call upon itself continually to draw each line
            end if
        elsif i >= length (paragraph) then %Elsif string is over then
            Font.Draw (paragraph (startingCharacter .. length (paragraph)),leftX,y,font,clr)
            random := -1
        end if
        
        exit when random = -1 %Exits all of the nested displayParagraphs after it's done
    end for
        
end displayParagraph

procedure inventory
    fork playMusic (11)
    View.Set("offscreenonly")
    random3 := 2
    random2 := itemNum
    %Set last x and y
    Mouse.Where (x,y,button)
    lastX := x
    lastY := y
    loop
        Pic.Draw(inventoryBG, 0, 0, picMerge)
        %Draw item names
        for i: 1 .. player.itemsInInventory
            Font.Draw(player.inventory(i).name, 100, 300-i*25, font2, menuColour)
        end for
            
        %Move cursor up and down
        Input.KeyDown (input)
        if input(KEY_UP_ARROW) and itemNum - 1 >= lower (player.inventory) then
            itemNum -= 1
        elsif input(KEY_DOWN_ARROW) and itemNum + 1 <= player.itemsInInventory then
            itemNum += 1
        end if
        
        %Mouse controls
        Mouse.Where (x,y,button)
        if lastX not= x and lastY not= y then
            itemNum := ((325-y) div 25)
            if itemNum < 1 then
                itemNum := 1
            elsif itemNum > player.itemsInInventory then
                itemNum := player.itemsInInventory
            end if
            
            lastX := x
            lastY := y
        end if
        
        if random2 not= itemNum then
            fork playMusic (9)
            random2 := itemNum
        end if
        
        %Press enter/select to use/equip item
        if input(' ') or input (KEY_ENTER) or button = 1 then
            selected := true
        end if
        if selected = true then
            if player.inventory (itemNum).itemType = "weapon" then
                fork playMusic (3)
                
                %Equip Item
                player.equippedWeapon := player.inventory(itemNum).itemId
                player.equippedItem := itemNum
            elsif player.inventory (itemNum).itemType = "healing" then
                %Use healing item
                fork playMusic (2)
                
                if player.hp + player.maxHp*player.inventory (itemNum).healPercent >= player.maxHp then
                    player.hp := player.maxHp
                else
                    player.hp += round (player.maxHp*player.inventory(itemNum).healPercent)
                end if
                
                %Remove Item (swap to back and lower items in inventory)
                for i : itemNum .. player.itemsInInventory - 1
                    tempItem := player.inventory (i + 1)
                    player.inventory (i + 1) := player.inventory (i)
                    player.inventory (i) := tempItem                
                end for
                    player.itemsInInventory -= 1
                
                if itemNum > player.itemsInInventory then
                    itemNum -= 1
                end if
            end if
            delay (200)
        end if
        selected := false
        
        
        %Draw itemPicture
        Pic.Draw (player.inventory (itemNum).picture, maxx div 1.4 - Pic.Width (player.inventory (itemNum).picture), 320 - Pic.Height (player.inventory (itemNum).picture), picMerge)
        %Draw description
        displayParagraph (player.inventory (itemNum).description, 1, maxx div 2.2, maxx div 1.3, 200, 20,font,menuColour)
        %Draw dot beside equipped item
        drawfillbox (80,300-player.equippedItem*25 + 10,85,300-(player.equippedItem-1)*25-10,menuColour)
        %Draw cursor
            drawbox(90, 300-itemNum*25, 100 + Font.Width (player.inventory (itemNum).name,font2) + 10, 300-itemNum*25 + 23, menuColour)
        %Draw tooltip
        if itemNum not= player.equippedItem then
            if player.inventory (itemNum).itemType = "weapon" then
                Font.Draw ("Equip with Enter/Space", maxx div 2.4 - Font.Width ("Equip with Enter/Space",font) div 2, 60, font, menuColour)
            elsif player.inventory (itemNum).itemType = "healing" then
                Font.Draw ("Use with Enter/Space", maxx div 2.4 - Font.Width ("Use with Enter/Space",font) div 2, 60, font, menuColour)
            end if
        end if
        
        delay(75)
        View.Update
        
        if input (KEY_SHIFT) not= true then %Make so you need to release shift and press again to exit
            random3 := 1
        end if
        
        exit when input (KEY_SHIFT) and random3 = 1
    end loop
    fork playMusic (12)
    View.Set("nooffscreenonly")
end inventory

procedure enemyAI (var enemy : enemyType)
    
    if enemyData (enemy.kindOfEnemy).aiType = "guard" then
        
        if enemy.animation not= 0 then %If guard isn't dead then
            
            if Math.Distance (player.x,player.y,enemy.x,enemy.y) <= enemyData (enemy.kindOfEnemy).aggroRadius and Math.Distance (player.x,player.y,enemy.x,enemy.y) > enemyData (enemy.kindOfEnemy).maxTargetRadius then %If enemy is within aggro range but out of attack range
                
                enemy.direction := enemy.angleToPlayer
                changeVectorAngle (enemy.walkForce,enemy.direction)
                addTwoVectors (enemy.acceleration, forceVector (enemy.walkForce,enemy.weight))
                changeAnimation (enemy, 2)
            elsif Math.Distance (player.x,player.y,enemy.x,enemy.y) <= enemyData (enemy.kindOfEnemy).maxTargetRadius and Math.Distance (player.x,player.y,enemy.x,enemy.y) > enemyData (enemy.kindOfEnemy).minTargetRadius then %Enemy is in attack range
                
                changeAnimation (enemy,3)
            elsif Math.Distance (player.x,player.y,enemy.x,enemy.y) <= enemyData (enemy.kindOfEnemy).minTargetRadius then %Enemy is too close to player
                
                enemy.direction := enemy.angleToEnemy
                changeVectorAngle (enemy.walkForce,enemy.direction)
                addTwoVectors (enemy.acceleration, forceVector (enemy.walkForce,enemy.weight))
                changeAnimation (enemy, 2)
            else
                changeAnimation (enemy, 1)
            end if
        end if
    elsif enemyData (enemy.kindOfEnemy).aiType = "goal" then
        %If player is on top of goal 
        if coord (player.x) = coord (enemy.x) and coord (player.y) = coord (enemy.y) then
            winScreen        
        end if
        
    elsif enemyData (enemy.kindOfEnemy).aiType = "crate" then
        %If player is on top of crate
        if coord (player.x) = coord (enemy.x) and coord (player.y) = coord (enemy.y) and player.itemsInInventory < upper (player.inventory) then
            player.itemsInInventory += 1
            player.inventory (player.itemsInInventory) := item (enemy.loot)
            itemGet (item (enemy.loot).name,item (enemy.loot).picture)
            
            %Delete enemy
            enemy.x := player.x
            enemy.y := player.y
            reorderEnemies %Reorder enemies sorts from furthest to closest, so set to player x and y so the dead enemy is last
            numOfEnemies -= 1 %Then remove it
            random := 2 %Make game loop through enemyAI again
            
        end if
        
    end if
    
    %Move Enemy
    friction := enemy.vector
        normalizeVector (friction)
    multiplyVector (friction, (-1*mu*20))
    if abs (Math.Distance (0,0,enemy.vector.x,enemy.vector.y)) > abs (Math.Distance (0,0,friction.x,friction.y)) then %If enemy velocity > friction then apply friction
        addTwoVectors (enemy.acceleration,friction)
    else %Otherwise stop object
        multiplyVector (enemy.vector,0) 
    end if
    
    %Add acceleration to enemy
    addTwoVectors (enemy.vector,enemy.acceleration)
    
    % put enemy.vector.x," ",enemy.vector.y
    % Input.Pause
    
    %Move enemy
    if map (coord (enemy.x+enemy.vector.x+(plusOrMinus (enemy.vector.x)*gridSize/3)), coord (enemy.y+enemy.vector.y+(plusOrMinus (enemy.vector.y)*gridSize/3))) not= 'w' then
        addVector (enemy.x,enemy.y,enemy.vector)
        %   put enemy.x," ",enemy.y, " ", enemy.vector.x, " ", enemy.vector.y
    elsif map (coord (enemy.x+enemy.vector.x+(plusOrMinus (enemy.vector.x)*gridSize/3)),coord (enemy.y)) not= 'w' then
        %     put enemy.x," ",enemy.y
        enemy.x += enemy.vector.x
        %     put enemy.x," ",enemy.y
        
    elsif map (coord (enemy.x), coord (enemy.y+enemy.vector.y+(plusOrMinus (enemy.vector.y)*gridSize/3))) not= 'w' then
        % put enemy.x," ",enemy.y
        enemy.y += enemy.vector.y
        %put enemy.x," ",enemy.y
    end if
    
    multiplyVector (enemy.acceleration, 0)%Reset enemy acceleration
    
end enemyAI

%Start Program

%Title Screen
fork playMusic (5)

Pic.ScreenLoad("assets/textures/GUI/title-screen.bmp", 0, 0, picMerge)
Font.Draw("Start!", maxx div 4 - Font.Width ("Start!",titleFont) div 2, 125, titleFont, white)
Font.Draw("Controls", maxx div 4 * 3 - Font.Width ("Controls",titleFont) div 2, 125, titleFont, white)
random := 0
random3 := 1
View.Set ("offscreenonly")
loop
    Mouse.Where (x, y,button)
    Input.KeyDown (input)
    
    if x not= lastX and y not= lastY then
        
        if x >  maxx div 4 - Font.Width ("Start!",titleFont) div 2 - 10 and x < maxx div 4 + Font.Width ("Start!",titleFont) div 2 + 10 and y > 125 and y < 150 then
            random := 1
            
            if random3 = 1 then
                fork playMusic (9)
                random3 := 2
            end if
        elsif x > maxx div 4 * 3 - Font.Width ("Controls",titleFont) div 2 - 10 and x < maxx div 4 * 3 + Font.Width ("Controls",titleFont) div 2 + 10 and y > 125 and y < 150 then
            random := 2
            
            if random3 = 1 then
                fork playMusic (9)
                random3 := 2
            end if
        else
            random := 0
            random3 := 1
        end if
        
        lastX := x
        lastY := y
    end if
    
    if input (KEY_RIGHT_ARROW) or input (KEY_DOWN_ARROW) then
        random := 2
        fork playMusic (9)
    elsif input (KEY_LEFT_ARROW) or input (KEY_UP_ARROW) then
        random := 1
        fork playMusic (9)
    end if
    
    if random = 1 then
        Pic.ScreenLoad("assets/textures/GUI/title-screen.bmp", 0, 0, picMerge)
        Font.Draw("Start!", maxx div 4 - Font.Width ("Start!",titleFont) div 2, 125, titleFont, white)
        Font.Draw("Controls", maxx div 4 * 3 - Font.Width ("Controls",titleFont) div 2, 125, titleFont, white)
        drawbox (maxx div 4 - Font.Width ("Start!",titleFont) div 2 - 10,125,maxx div 4 + Font.Width ("Start!",titleFont) div 2 + 10,150,menuColour)
        
        if button = 1 or input (' ') or input (KEY_ENTER) then
            fork playMusic (10)
            exit
        end if
    elsif random = 2 then
        Pic.ScreenLoad("assets/textures/GUI/title-screen.bmp", 0, 0, picMerge)
        Font.Draw("Start!", maxx div 4 - Font.Width ("Start!",titleFont) div 2, 125, titleFont, white)
        Font.Draw("Controls", maxx div 4 * 3 - Font.Width ("Controls",titleFont) div 2, 125, titleFont, white)
        drawbox (maxx div 4 * 3 - Font.Width ("Controls",titleFont) div 2 - 10,125,maxx div 4 * 3 + Font.Width ("Controls",titleFont) div 2 + 10,150,menuColour)
        
        if button = 1 or input (' ') or input (KEY_ENTER) then
            fork playMusic (10)
            controlsScreen
        end if
        
    else
        Pic.ScreenLoad("assets/textures/GUI/title-screen.bmp", 0, 0, picMerge)
        Font.Draw("Start!", maxx div 4 - Font.Width ("Start!",titleFont) div 2, 125, titleFont, white)
        Font.Draw("Controls", maxx div 4 * 3 - Font.Width ("Controls",titleFont) div 2, 125, titleFont, white)
    end if    
    
    %Konami Code
    if input (KEY_UP_ARROW) and codeCounter >= 1  and codeCounter <= 2 and random2 = 1 then
        codeCounter += 1
        random2 := 2
    elsif input (KEY_DOWN_ARROW) and codeCounter >= 3 and codeCounter <= 4 and random2 = 1 then
        codeCounter += 1 
        random2 := 2
    elsif input (KEY_LEFT_ARROW) and codeCounter = 5 and random2 = 1 or input (KEY_LEFT_ARROW) and codeCounter = 7 and random2 = 1 then
        codeCounter += 1
        random2 := 2
    elsif input (KEY_RIGHT_ARROW) and codeCounter = 6 and random2 = 1 or input (KEY_RIGHT_ARROW) and codeCounter = 8 and random2 = 1 then
        codeCounter += 1
        random2 := 2
    elsif input ('b') and codeCounter = 9 and random2 = 1 then
        fork playMusic (9)
        codeCounter += 1
        random2 := 2
    elsif input ('a') and codeCounter = 10 and random2 = 1 then
        fork playMusic (9)
        codeCounter := 1
        if player.invincible = false then
            player.invincible := true
        else
            player.invincible := false
        end if
    elsif random2 = 1 then
        for i : char
            if input (i) then
                codeCounter := 1
                random2 := 2
            end if
        end for
    end if
    
    %Only accept code after button has been released
    if random2 = 2 then
        random2 := 1
        %Assume no key is pressed until loop says yes
        for i : char
            if input (i) then
                random2 := 2
            end if
        end for
    end if
    Time.DelaySinceLast (1000 div 15)
    View.Update
end loop
View.Set ("nooffscreenonly")

fork playMusic (6)

%Draw lore box
startTime := Time.Elapsed
render
drawfillbox (maxx div 2 - 350 div 2,100, maxx div 2 + 350 div 2, 300, green)
displayParagraph ("You wake up in a dungeon surrounded by guards. The only way to escape is through a portal located at the end of the dungeon, but you only have 10 minutes before reinforcements arrive and you're screwed. Good Luck!",1, maxx div 2 - 350 div 2 + 20, maxx div 2 + 350 div 2 - 20, 253, 20, font, white)

Font.Draw ("The Story", maxx div 2 - Font.Width ("The Story", font) div 2, 283, font, grey)
Font.Draw ("Press Enter/Space to begin", maxx div 2 - Font.Width ("Press Enter/Space to begin", font) div 2, 102, font, grey)

delay (150)
loop
    Mouse.Where (x,y,button)
    Input.KeyDown (input)
    
    exit when button = 1 or input (' ') or input (KEY_ENTER) 
end loop
fork playMusic (10)
delay (150)

random3 := 1 %For inventory so you must release and press again to open/close

startTime := Time.Elapsed

loop
    
    Mouse.Where (x,y,button)
    Input.KeyDown (input)
    
    %Change camera angle
    % exit when button = 1
    if player.cameraSpeed + player.cameraAcceleration <= player.cameraSpeedLimit and input (KEY_LEFT_ARROW) then
        player.cameraSpeed += player.cameraAcceleration
    elsif player.cameraSpeed - player.cameraAcceleration >= -player.cameraSpeedLimit  and input (KEY_RIGHT_ARROW) then
        player.cameraSpeed -= player.cameraAcceleration
    elsif player.cameraSpeed > 0 and input (KEY_LEFT_ARROW) = false and input (KEY_RIGHT_ARROW) = false then
        %Prevent camera from entering a loop
        if player.cameraSpeed - player.cameraDeceleration < 0 then
            player.cameraSpeed := 0
        else
            player.cameraSpeed -= player.cameraDeceleration
        end if
    elsif player.cameraSpeed < 0 and input (KEY_LEFT_ARROW) = false and input (KEY_RIGHT_ARROW) = false then
        
        %Prevent camera from entering a loop
        if player.cameraSpeed + player.cameraDeceleration > 0 then
            player.cameraSpeed := 0
        else
            player.cameraSpeed += player.cameraDeceleration
        end if
    end if
    
    % put player.cameraSpeed, " ", player.cameraAcceleration
    % Input.Pause
    
    %loop angle around if necessary
    player.direction += player.cameraSpeed
    wrapAngle (player.direction)
    
    
    %Decrease camera acceleration
    
    %Move
    if input ('s') then
        %  OldMove (player.direction + 180)
        changeVectorAngle (player.walkForce,player.direction+180)
        addTwoVectors (player.acceleration, forceVector (player.walkForce,player.weight))
    end if
    if input ('a') then
        %  OldMove (player.direction + 90)
        changeVectorAngle (player.walkForce,player.direction+90)
        addTwoVectors (player.acceleration, forceVector (player.walkForce,player.weight))
    end if
    if input ('d') then
        %OldMove (player.direction + 270)
        changeVectorAngle (player.walkForce,player.direction+270)
        addTwoVectors (player.acceleration, forceVector (player.walkForce,player.weight))
    end if
    if input ('w') then
        %  OldMove (player.direction)
        changeVectorAngle (player.walkForce,player.direction)
        addTwoVectors (player.acceleration, forceVector (player.walkForce,player.weight))
    end if
    if input (KEY_SHIFT) and random3 = 1 then
        inventory
        random3 := 0
    elsif input (KEY_SHIFT) not= true then
        random3 := 1
    end if
    
    move
    
    render
    
    if player.hp <= 0 or (timeToEscape - (Time.Elapsed - startTime)) <= 0 then
        loseScreen
    end if
    
    %Enemy AI
    
    loop
        random := 1
        if numOfEnemies > 0 then
            for i : 1 .. numOfEnemies
                enemyAI (enemy (i))
                exit when random = 2 %Rerun loop if enemy is deleted
            end for
        end if
        exit when random = 1
    end loop
    
    %Advance Animation Frames
    if numOfEnemies > 0 then
        loop
            random := 1 %loop exits if random = 1
            for i : 1 .. numOfEnemies
                if Time.Elapsed - enemy (i).animationTimer >= enemyData (enemy (i).kindOfEnemy).delayBetweenFrames  then 
                    
                    %If death animation finishes
                    if enemy (i).animation = 0 and enemy (i).frame = enemyData (enemy (i).kindOfEnemy).maxFrame (enemy (i).animation) then
                        
                        fork playMusic (13)
                        %Delete enemy
                        enemy (i).x := player.x
                        enemy (i).y := player.y
                        
                        reorderEnemies %Reorder enemies sorts from furthest to closest, so set to player x and y so the dead enemy is last
                        
                        numOfEnemies -= 1 %Then remove it
                        
                        random := 2 %Causes loop to restart if enemy dies (since you can't alter a for loop's num of loops while it's running)
                        exit
                    elsif enemy (i).frame + 1 > enemyData (enemy (i).kindOfEnemy).maxFrame (enemy (i).animation) then
                        enemy (i).frame := 1
                    else
                        enemy (i).frame += 1
                        %If the enemy shot at you, then
                        if enemy (i).animation = 3 and enemy (i).frame >=  enemyData (enemy (i).kindOfEnemy).maxFrame (enemy (i).animation) then
                            
                            if Time.Elapsed - enemy (i).attackTimer < enemyData (enemy (i).kindOfEnemy).refire then
                                enemy (i).frame -= 1 %Reset frame if enemy can't attack yet
                            else
                                %If enemy has possibility to hit, run Rand.Int
                                if enemy (i).lineOfSight = true and player.invincible = false then
                                    random := Rand.Int (0,enemyData (enemy (i).kindOfEnemy).accuracy*2)
                                    
                                    fork playMusic (16)
                                    
                                    %If enemy hits then
                                    if random <= floor (player.width * ((player.height/Math.Distance (player.x,player.y,enemy (i).x,enemy (i).y))*player.distanceToProjection*-2)/player.height) then
                                        
                                        fork playMusic (15)
                                        %Prevent hp from going negative
                                        if player.hp -  enemyData (enemy(i).kindOfEnemy).damage < 0 then
                                            player.hp := 0
                                        else
                                            player.hp -= enemyData (enemy(i).kindOfEnemy).damage
                                        end if
                                    end if
                                end if
                                enemy (i).attackTimer := Time.Elapsed
                            end if
                        end if
                        
                        %Special code for boss because he only has 1 attack frame
                        if enemy (i).animation = 3 and enemy (i).kindOfEnemy = 4 and enemy (i).frame > 1 then
                            changeAnimation (enemy (i),1)
                        end if
                    end if
                    
                    if enemy (i).kindOfEnemy not= 4 then
                        enemy (i).animationTimer := Time.Elapsed
                    end if
                end if
            end for
                
            exit when random = 1
        end loop
    end if
    
    %Shoot
    if input (' ') and Time.Elapsed - player.refireTimer >= weapon (player.equippedWeapon).refire then
        shoot (Rand.Int (-weapon (player.equippedWeapon).accuracy, weapon (player.equippedWeapon).accuracy))
        
        if weapon (player.equippedWeapon).name = "shotgun" then %Shotgun shoots 5 rounds at once
            for i : 1 .. 4
                shoot (Rand.Int (-weapon (player.equippedWeapon).accuracy, weapon (player.equippedWeapon).accuracy))
            end for
        end if
        
        Pic.Draw (weapon (player.equippedWeapon).firePicture,0,0,picMerge)
        fork playMusic (1)
    end if
    
end loop
put angle