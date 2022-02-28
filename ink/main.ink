INCLUDE utils.ink

LIST bridge_id = A,B,C,D,E,F,G
// A = iron, B = marble,
// E = stone, F = brick
// D = wood
// C = drawbridge
// G = rope
LIST islands = north,south,kneiphof,lomse

VAR bridge_crossed = ()
VAR island_seen = ()
VAR intro = true // TODO Avoid this using a separate knot

VAR ossuary_key = false
VAR cathedral_key = false

VAR ossuary_locked = true
VAR cathedral_passage_locked = true

VAR drachmas = 0

// TODO Constants for "look around," "go to...", etc.
// TODO Winning
// TODO change "shore" to "bank"
// TODO some red herrings
// TODO Maybe have to rob a grave
// TODO more flavour text
// TODO colour/styling on interactables?

-> prologue

=== prologue ===

As you awake, a strange voice echoes in your head.

"You will not be free until you can cross each bridge exactly once and return to your starting point outside the Cathedral."

* [Continue...]
  -> Kneiphof.long


=== Example ===
// Example of the format I'm using for islands/locations.
Short description here
-> options

= long
Long description here

(multiple paragraphs)
-> options

= options
 + [Look around]
   -> long
 + [Go to...]
 ++ Some bridge # CLEAR
    -> Bridges.iron(->Example, ->Example)
 ++ [nowhere] -> Example // Cancel? Never mind? What phrasing is best?


// TODO: Maybe don't automatically look around when you get somewhere,
//  but make all go-to locations conditional on having seen them at least once.

=== Kneiphof ====================================================
You are on the island of Kneiphof.
-> check_win_loss(kneiphof) ->
-> options

= long
You are standing in the cobbled streets of the island of Kneiphof{intro:, in the city of Konigsberg}.  The only sound is the croaking and flitting of crows.//TODO Randomize flavourtext
{intro:The windows are dark.  The streets are empty.  The glow of twilight (or perhaps sunrise) lingers in the sky, as though frozen in time.}
~intro = false

Above you looms the Konigsberg Cathedral.
// TODO Handle bridges already crossed.
To the north, an iron bridge and a marble bridge cross over the river Pregel to the North Shore.

To the south, a bridge of stone and a bridge of brick stretch towards the South Shore.

To the east, a wooden bridge leads to the island of Lomse.
~ island_seen += kneiphof
-> options

= options
 + [Look around]
   -> Kneiphof.long
 + {long}Go to...[]
 ++ the Cathedral
 ++ the bridge of iron #CLEAR
    -> Bridges.iron(-> Kneiphof, ->North_Shore)
 ++ the bridge of marble #CLEAR
    -> Bridges.marble(->Kneiphof, ->North_Shore)
 ++ the wooden bridge #CLEAR
    -> Bridges.wooden(->Kneiphof, ->Lomse)
 ++ the bridge of brick # CLEAR
    -> Bridges.brick(->Kneiphof, ->South_Shore)
 ++ the bridge of stone # CLEAR
    -> Bridges.stone(->Kneiphof, ->South_Shore)
 ++ [nowhere] -> Kneiphof


=== North_Shore ======================================================
You are on the North Shore of the river Pregel.
-> check_win_loss(north) ->
-> options

= long
You stand on the North Shore of the river Pregel.  Above you stand the fortifications of Konigsberg Castle.  Moss clings to the cracks in the ancient walls.

To the southwest, a bridge of iron and a bridge of marble lead to the island of Kneiphof.

To the southeast, a drawbridge leads to the island of Lomse.  The bridge is {bridge_crossed?C: drawn up| down}.
-> options

= options
 + [Look around]
   -> long
 + {long}Go to...[]
 ++ the bridge of iron #CLEAR
    -> Bridges.iron(->North_Shore, -> Kneiphof)
 ++ the bridge of marble #CLEAR
    -> Bridges.marble(->North_Shore, -> Kneiphof)
 ++ the drawbridge # CLEAR
    -> Bridges.drawbridge(->North_Shore, ->Lomse)
 ++ [nowhere] -> North_Shore


=== Lomse =======================================================
You are on the island of Lomse.
-> check_win_loss(lomse) ->
-> options

= long
You stand in a graveyard on the marshy, sparsely inhabited island of Lomse.  Grim grey headstones and scraggly trees stretch into the misty distance.

Nearby is a lonely ossuary.

A drawbridge leads to the North Shore.  The bridge is {bridge_crossed?C: drawn up| down}.

A rope bridge extends precariously to the South Shore.

To the west, a wooden bridge connects to the island of Kneiphof.
-> options

= options
 + [Look around]
   -> long
 + {long}Go to...[]
 ++ the ossuary # CLEAR
    -> ossuary_exterior
 ++ the drawbridge # CLEAR
    -> Bridges.drawbridge(->Lomse, ->North_Shore)
 ++ the wooden bridge #CLEAR
    -> Bridges.wooden(->Lomse, ->Kneiphof)
 ++ the rope bridge # CLEAR
    -> Bridges.rope(->Lomse, ->South_Shore)
 ++ [nowhere] -> Lomse

= ossuary_exterior
// TODO Lock/unlock the door?
The ossuary is a plain stone building.  The only adornment is a Latin inscription over the entrance.
The oaken door is {ossuary_locked:locked{ossuary_key:, but the iron key you found fits the lock perfectly|}|unlocked}. ->ossuary_options
= ossuary_options
 + {ossuary_locked and ossuary_key}[Unlock the ossuary.]
   The ossuary is now unlocked.
   ~ ossuary_locked = false
   -> ossuary_options
 + {not ossuary_locked}[Lock the ossuary.]
   The ossuary is locked.
   ~ ossuary_locked = true
   -> ossuary_options
 * [Read the inscription.]
   The inscription says MELIUS EST IRE AD DOMUM LUCTUS QUAM AD DOMUM CONVIVII.
   -> ossuary_options
 + {not ossuary_locked}Enter the ossuary.
   -> ossuary_interior
 + [Go back.] -> Lomse
 
= ossuary_interior
You are inside a dark stone room.  Against each wall is a tightly-packed stack of ancient bones.  The door casts a beam of light on a pile of skulls grinning against the back wall.
In the floor is a trapdoor leading to a dark passage.
 + Enter the passage.
 + [Go back.] -> ossuary_exterior # CLEAR

=== South_Shore ==================================================
You are on the South Shore of the river Pregel.
-> check_win_loss(south) ->
-> options

= long
You stand on the South Shore of the river Pregel.  Further south, many narrow cobbled streets wind maze-like between tall buildings leaning at strange angles.  The streets are dark and empty.

A wooden jetty juts out into the river.  At the end stands a silent, grey-cloaked figure.

To the north west, a bridge of stone and {bridge_crossed?F:the remains of }a bridge of brick lead to the island of Kneiphof.

To the north east, a rope bridge leads to the island of Lomse.
// TODO DENSE MAZE OF BUILDINGS


-> options

= options
 + [Look around]
   -> long
 + {long}Go to...[]
 ++ the stone bridge # CLEAR
    -> Bridges.stone(->South_Shore, ->Kneiphof)
 ++ the brick bridge # CLEAR
    -> Bridges.brick(->South_Shore, ->Kneiphof)
 ++ the rope bridge # CLEAR
    -> Bridges.rope(->South_Shore, ->Lomse)
 ++ [nowhere] -> South_Shore

=== game_over(island) ======================================================
In the distance, an iron bell tolls mournfully.  You realize that you are trapped here, with no way to reach the remaining uncrossed bridges{island != kneiphof: or return to the Cathedral}.
Unless...
   * [Attempt to swim]
     In a desperate last attempt, you leap into the Pregel river.
     You are immediately overwhelmed by the cold and the current.  The world fades into darkness as you sink into the inky depths.
   -
   // TODO Varied flavour text
   * Try again...
     # RESTART
-> END


=== Bridges =========================================================

= brick(-> from, -> to)
You stand before {bridge_crossed?F:the crumbling remains of a brick bridge|a bridge made of red brick}.
  * [Cross the bridge]
    You start to cross the bridge.  About halfway across you spot a large iron key lying on the ground.
    ** [Grab it.]
        You grab the key.
        ~ossuary_key = true
    ** [Leave it.]
    --  
    As you reach the other side and step off the bridge you hear the wailing of a far-off wind.  The bridge begins to age rapidly.  The bricks crumble as they are overtaken by moss, erosion, and the unrelenting march of time.  Soon, only an impassible ruin remains.
    ~ bridge_crossed += F
    -> to
  * [Go back] -> from

= rope(-> from, -> to)
You stand before a narrow rope bridge hanging low over the rushing river.<>
{bridge_crossed?G:  The bridge is swarming with hostile crows.}
  * [Cross the bridge]
    You begin to cross the precarious rope bridge.  Behind you, a dense swarm of crows descends, covering the bridge completely.
    ~ bridge_crossed += G
    -> to
  + [Go back] -> from

= stone(-> from, -> to)
// Look up Devil's Bridge on Wikipedia for some inspiration
You stand before an arched bridge of ancient masonry.<>
{bridge_crossed?E:  A wall of sulfurous flames prevents you from crossing.|  Medieval legend claims that the bridge was built by the Devil himself.}
  * [Cross the bridge]
    You begin to cross the bridge.  As soon as you pass the halfway point the scent of sulfur fills the air and a wall of blue flame crackles into being behind you.
    ~ bridge_crossed += E
    -> to 
  * [Go back] -> from

= iron(-> from, -> to)
You stand before an imposing suspension bridge of great iron girders, held together by giant rivets and covered in a red layer of rust.<>
{bridge_crossed?A:  The path is barred by a heavy iron gate.}
  * [Cross the bridge]
    You begin to cross the iron bridge.
    As you step off the other side a gate slams shut behind you with a heavy clang.
    ~bridge_crossed += A 
    -> to
  + [Go back] -> from

= marble(-> from, -> to)
You stand before a marble bridge in classical Doric style.<>
{bridge_crossed?B:  The way is barred by a crowd of living statues.|  Lifelike statues line both sides of the bridge.}
  * [Cross the bridge]
    You start to walk across the marble bridge.  Halfway across you spot spot something glinting on the ground.
    ** [Grab it.]
        You pick up the object.  It appears to be some sort of coin, irregularly shaped and bearing an inscription in ancient Greek.
        ~drachmas += 1
    ** [Leave it.]
    --
    As you reach the other side the statues begin to move, stiffly and clumsily but with a sense of purpose.  They climb down onto the bridge behind you, barring the way back.
    ~bridge_crossed += B
    -> to
  + [Go back] -> from

= drawbridge(-> from, -> to)
You stand before a drawbridge, a marvel of modern engineering.<>
{bridge_crossed?C: The bridge is drawn up and impassible. | The bridge is down, offering safe passage.}
  * [Cross the bridge]
    You cross the bridge.
    As you step off the other side, gears and pulleys begin to rumble and screech as a great mechanism awakes.  The bridge rises, slowly but surely, until it is impassible.
    ~bridge_crossed += C
    -> to
  + [Go back] -> from

= wooden(-> from, -> to)
You stand before a rickety wooden bridge.<>
{bridge_crossed?D: The pathway is blocked by a wall of thorn-studded vines that seem to grow out of the wood of the bridge itself.}
 * [Cross the bridge]
   You cross the bridge.
   The dead wood beneath your feet comes back to life as you walk, sprouting leafy branches and thick, thorny vines that quickly block the pathway behind you.
   ~bridge_crossed += D
   -> to 
 * [Go back] -> from




