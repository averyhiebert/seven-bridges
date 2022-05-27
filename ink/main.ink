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
VAR cathedral_locked = true
VAR cathedral_passage_blocked = true
VAR tunnel_flooded = false

VAR drachmas = 0

// TODO Constants for "look around," "go to...", etc.
// TODO Winning
// TODO change "shore" to "bank"
// TODO some red herrings
// TODO Maybe have to rob a grave
// TODO more flavour text
// TODO colour/styling on interactables?

CONST cancel = "(cancel)"

-> prologue

=== prologue ===

As you awake, a strange voice echoes in your head.

"You will not be free until you can cross each bridge exactly once and return to your starting point outside the Cathedral."

* [Continue...]
  -> Kneiphof.long


=== Example ===
#CLEAR
// Example of the format I'm using for islands/locations.
Short description here
-> options

= long
#CLEAR
Long description here

(multiple paragraphs)
-> options

= options
 + [Look around]
   -> long
 + [Go to...]
 ++ Some bridge
    -> Bridges.iron(->Example, ->Example)
 ++ [{cancel}] -> Example // Cancel? Never mind? What phrasing is best?


// TODO: Maybe don't automatically look around when you get somewhere,
//  but make all go-to locations conditional on having seen them at least once.

=== Kneiphof ====================================================
# SET_BG: kneiphof.png
You are on the island of Kneiphof. #CLEAR
-> check_win_loss(kneiphof) ->
-> options

= long
#CLEAR
You are standing in the cobbled streets of the island of Kneiphof{intro:, in the city of Konigsberg}.  The only sound is the croaking and flitting of crows.  //TODO Randomize flavourtext
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
 + {long}Go to...[] #CLEAR
 ++ the Cathedral
    -> cathedral_door
 ++ the iron bridge (to North Shore)
    -> Bridges.iron(-> Kneiphof, ->North_Shore)
 ++ the marble bridge (to North Shore)
    -> Bridges.marble(->Kneiphof, ->North_Shore)
 ++ the wooden bridge (to Lomse)
    -> Bridges.wooden(->Kneiphof, ->Lomse)
 ++ the brick bridge (to South Shore)
    -> Bridges.brick(->Kneiphof, ->South_Shore)
 ++ the stone bridge (to South Shore)
    -> Bridges.stone(->Kneiphof, ->South_Shore)
 ++ [{cancel}] -> Kneiphof

= cathedral_door
# CLEAR
The cathedral is tall and imposing, with a bell tower rising above an asymmetric peaked roof.
The door is elaborately carved with apocalyptic imagery. It is {cathedral_locked:locked{cathedral_key:, but the golden key you found fits perfectly.|.}|unlocked.}
-> cathedral_door_options
= cathedral_door_options
  + {cathedral_key and cathedral_locked}[Unlock the door.]
    The cathedral door is now unlocked.
    ~ cathedral_locked = false
    -> cathedral_door_options
  + {cathedral_key and not cathedral_locked}[Lock the door.]
    The cathedral door is now locked.
    ~ cathedral_locked = true
    -> cathedral_door_options
  + {not cathedral_locked}Enter the cathedral.
    -> cathedral_interior
  + [Go back.]
    -> Kneiphof

= cathedral_interior
#CLEAR
The cathedral is magnificent.  Colourful windows reach up to vaulted ceilings high overhead.
The far end of the cathedral is occupied by an elaborate pipe organ.  Nearer to the entrance, a cedar coffin lies in an alcove.  {cathedral_passage_blocked:It looks slightly out of place.|It has been moved to the side, exposing a trapdoor.}
- (cathedral_options)
  + Investigate the pipe organ.
    The pipe organ is a massive collection of pipes, with a sprawling, almost organic appearance.
    -> cathedral_options
  + {cathedral_passage_blocked}[Investigate the coffin.]
    You move the coffin slightly, revealing a trapdoor in the floor beneath it.
    ~ cathedral_passage_blocked = false
    -> cathedral_options
  + {not cathedral_passage_blocked}[Investigate the trapdoor.]
    {tunnel_flooded:The trapdoor leads to a flooded tunnel.|The trapdoor seems to be locked from the other side.}
    -> cathedral_options
  + Leave the cathedral.
    -> Kneiphof

=== North_Shore ======================================================
# SET_BG: north_shore.png
You are on the North Shore of the river Pregel. #CLEAR
-> check_win_loss(north) ->
-> options

= long
#CLEAR
You are on the North Shore of the river Pregel.  The fortifications of Konigsberg Castle tower over you.  Moss clings to the cracks in the ancient walls.

To the southwest, a bridge of iron and a bridge of marble lead to the island of Kneiphof.

To the southeast, a drawbridge leads to the island of Lomse.  The bridge is {bridge_crossed?C: drawn up| down}.
-> options

= options
 + [Look around]
   -> long
 + {long}Go to...[] #CLEAR
 ++ the iron bridge (to Kneiphof)
    -> Bridges.iron(->North_Shore, -> Kneiphof)
 ++ the marble bridge (to Kneiphof)
    -> Bridges.marble(->North_Shore, -> Kneiphof)
 ++ the drawbridge (to Lomse)
    -> Bridges.drawbridge(->North_Shore, ->Lomse)
 ++ [{cancel}] -> North_Shore


=== Lomse =======================================================
# SET_BG: lomse.png
You are on the island of Lomse. #CLEAR
-> check_win_loss(lomse) ->
-> options

= long
#CLEAR
You are in a graveyard on the marshy, sparsely inhabited island of Lomse.  Grim grey headstones and scraggly trees stretch into the misty distance.

Nearby is a lonely ossuary.

A drawbridge leads to the North Shore.  The bridge is {bridge_crossed?C: drawn up| down}.

A rope bridge extends precariously to the South Shore.

To the west, a wooden bridge connects to the island of Kneiphof.
-> options

= options
 + [Look around]
   -> long
 + {long}Go to...[] #CLEAR
 ++ the ossuary
    -> ossuary_exterior
 ++ the drawbridge (to North Shore)
    -> Bridges.drawbridge(->Lomse, ->North_Shore)
 ++ the wooden bridge (to Kneiphof)
    -> Bridges.wooden(->Lomse, ->Kneiphof)
 ++ the rope bridge (to South Shore)
    -> Bridges.rope(->Lomse, ->South_Shore)
 ++ [{cancel}] -> Lomse

= ossuary_exterior
#CLEAR
// TODO Lock/unlock the door?
The ossuary is a plain stone building.  The only adornment is a Latin inscription over the entrance.
The oaken door is {ossuary_locked:locked{ossuary_key:, but the iron key you found fits the lock perfectly|}|unlocked}. ->ossuary_options
= ossuary_options
 + {ossuary_locked and ossuary_key}[Unlock the ossuary.]
   The ossuary is now unlocked.
   ~ ossuary_locked = false
   -> ossuary_options
 + {not ossuary_locked}[Lock the ossuary.]
   The ossuary is now locked.
   ~ ossuary_locked = true
   -> ossuary_options
 * [Read the inscription.]
   The inscription says MELIUS EST IRE AD DOMUM LUCTUS QUAM AD DOMUM CONVIVII.
   -> ossuary_options
 + {not ossuary_locked}Enter the ossuary.
   -> ossuary_interior
 + [Go back.] -> Lomse
 
= ossuary_interior
#CLEAR
You are in a dark stone room.  Against each wall is a tightly-packed stack of human bones.  The door casts a beam of light on a pile of skulls grinning against the back wall.
In the floor is a trapdoor leading to a dark tunnel{tunnel_flooded: filled with muddy water.|.}
 * Enter the tunnel.
   -> tunnel_from_ossuary
 + [Go back.] -> Lomse

= tunnel_from_ossuary
#CLEAR
The tunnel is long and damp, and leads quite a ways to the west.  The walls are lined with sarcophagi; this appears to be some sort of catacomb.
Eventually you reach the end of the passage.  If you had to guess, you're somewhere under the cathedral.  There is a trapdoor in the roof above you.
Behind you, the passage begins to fill with water.
~ tunnel_flooded = true
 * {not cathedral_passage_blocked}[Open the trapdoor]
   You climb out of the trapdoor, leaving behind the flooding catacombs.  You find yourself inside the Cathedral. # SET_BG: kneiphof.png
   ** Continue...
      -> Kneiphof.cathedral_interior
 * {cathedral_passage_blocked}[Open the trapdoor]
 -
There seems to be something heavy on top of the trap door, preventing it from opening. //TODO Make trapdoor openable at Cathedral
 * Oh no...
 -
 The tunnel continues filling with water.  You try to keep your head up, but eventually there is no air left to breath and you drown in the darkness.
 * Try again...
   # RESTART
   -> END

=== South_Shore ==================================================
# SET_BG: south_shore.png
You are on the South Shore of the river Pregel. #CLEAR
-> check_win_loss(south) ->
-> options

= long
#CLEAR
You are on the South Shore of the river Pregel.  Further south, many narrow cobbled streets wind maze-like between tall buildings leaning at strange angles.  The streets are dark and empty.

A wooden jetty juts out into the river.{not take_ferry:  At the end stands a silent, grey-cloaked figure.}

To the north west, a bridge of stone and {bridge_crossed?F:the remains of }a bridge of brick lead to the island of Kneiphof.

To the north east, a rope bridge leads to the island of Lomse.
// TODO DENSE MAZE OF BUILDINGS
- (options)
 + [Look around]
   -> long
 + {long}Go to...[] #CLEAR
 ++ {not take_ferry}the jetty
    -> ferryman
 ++ the stone bridge (to Kneiphof)
    -> Bridges.stone(->South_Shore, ->Kneiphof)
 ++ the brick bridge (to Kneiphof)
    -> Bridges.brick(->South_Shore, ->Kneiphof)
 ++ the rope bridge (to Lomse)
    -> Bridges.rope(->South_Shore, ->Lomse)
 ++ [{cancel}] -> South_Shore

= ferryman
# CLEAR
The jetty creaks as the murmuring currents of the Pregel rush past.

A cloaked figure stands next to a small rowboat.  As you approach he says nothing, but holds out a pale hand for payment. {drachmas < 1:Alas, you have nothing to pay him with.}
++ [Go back.] -> South_Shore
++ (take_ferry){drachmas > 0}Pay the ferryman. 
    #CLEAR
    You place the ancient coin you found in the ferryman's outstretched hand. Wordlessly, he leads you into his boat and begins to row you away from the jetty.
    As you cross the river, you glance {shuffle:down into the stygian depths of the Pregel, where nothing but endless darkness meets your gaze.|up at the underside of the wooden bridge connecting Kneiphof and Lomse.  The ancient wood is covered in carvings of wild men, dancing satyrs, and strange forms that you can't quite make sense of.}
    Eventually, the boat arrives on the North Shore and the hooded ferryman silently gestures for you to leave.  You step out of the small boat and onto a stone walkway next to the river.
    *** [Thank the ferryman.]
    --- You turn to thank the ferryman, but he is already gone.
    *** Continue...
        -> North_Shore

=== game_over(island) ======================================================
In the distance, an iron bell tolls mournfully.  You realize that you are trapped here, with no way to reach the remaining uncrossed bridges{island != kneiphof: or return to the Cathedral}.
Unless...
   * [Attempt to swim.]
     You leap into the Pregel river in a desperate final attempt to fulfill your task.
     You are immediately overwhelmed by the cold and the current.  The world fades into darkness as you sink into the inky depths.
   -
   // TODO Varied flavour text
   * Try again...
     # RESTART
   -> END

=== victory ============================================================
Exhausted, you collapse on the steps of the cathedral.  Every bridge has been crossed.  You may rest at last.

-> END


=== Bridges =========================================================

= brick(-> from, -> to)
#CLEAR
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
    # BRIDGE_CROSSED: bridge_f
    ** Continue...
    --
    -> to
  + [Go back.] -> from

= rope(-> from, -> to)
#CLEAR
You stand before a narrow rope bridge hanging low over the rushing river.<>
{bridge_crossed?G:  The bridge is swarming with hostile crows.}
  * [Cross the bridge]
    You begin to cross the precarious rope bridge.  Behind you a dense swarm of crows descends, covering the bridge completely.
    ~ bridge_crossed += G
    # BRIDGE_CROSSED: bridge_g
    ** Continue...
    --
    -> to
  + [Go back.] -> from

= stone(-> from, -> to)
#CLEAR
// Look up Devil's Bridge on Wikipedia for some inspiration
You stand before an arched bridge of ancient masonry.<>
{bridge_crossed?E:  A wall of sulfurous flames prevents you from crossing.|  Medieval legend claims that the bridge was built by the Devil himself.}
  * [Cross the bridge]
    You begin to cross the bridge.  As soon as you pass the halfway point the scent of sulfur fills the air and a wall of blue flame crackles into being behind you.
    ~ bridge_crossed += E
    # BRIDGE_CROSSED: bridge_e
    ** Continue...
    --
    -> to 
  + [Go back] -> from

= iron(-> from, -> to)
#CLEAR
You stand before an imposing suspension bridge of great iron girders, held together by giant rivets and covered in a red layer of rust.<>
{bridge_crossed?A:  The path is barred by a heavy iron gate.}
  * [Cross the bridge]
    You begin to cross the iron bridge.  About halfway across you spot a small golden key lying on the ground.
    ** [Grab it.]
        You grab the key.
        ~cathedral_key = true
    ** [Leave it.]
    --  
    As you step off the other side a gate slams shut behind you with a heavy clang.
    ~bridge_crossed += A     
    # BRIDGE_CROSSED: bridge_a
    ** Continue...
    --
    -> to
  + [Go back.] -> from

= marble(-> from, -> to)
#CLEAR
You stand before a marble bridge in classical Doric style.<>
{bridge_crossed?B:  The way is barred by a crowd of living statues.|  Lifelike statues line both sides of the bridge.}
  * [Cross the bridge]
    You start to walk across the marble bridge.  Halfway across you spot something glinting on the ground.
    ** [Grab it.]
        You pick up the object.  It appears to be some sort of coin, irregularly shaped and bearing an inscription in ancient Greek.
        ~drachmas += 1
    ** [Leave it.]
    --
    As you reach the other side of the bridge the statues begin to move, stiffly and clumsily but with a sense of purpose.  They climb down onto the bridge behind you, barring the way back.
    ~bridge_crossed += B
    # BRIDGE_CROSSED: bridge_b
    ** Continue...
    --
    -> to
  + [Go back] -> from

= drawbridge(-> from, -> to)
#CLEAR
You stand before a drawbridge, a marvel of modern engineering.<>
{bridge_crossed?C: The bridge is drawn up and impassible. | The bridge is down, offering safe passage.}
  * [Cross the bridge]
    You cross the bridge.
    As you step off the other side, gears and pulleys begin to rumble and screech as a great mechanism awakes.  The bridge rises, slowly but surely, until it is impassible.
    ~bridge_crossed += C
    # BRIDGE_CROSSED: bridge_c
    ** Continue...
    --
    -> to
  + [Go back.] -> from

= wooden(-> from, -> to)
#CLEAR
You stand before a rickety wooden bridge.<>
{bridge_crossed?D: The pathway is blocked by a wall of thorn-studded vines that seem to grow out of the wood of the bridge itself.}
 * [Cross the bridge]
    You cross the bridge.
    The dead wood beneath your feet comes back to life as you walk, sprouting leafy branches and thick, thorny vines that quickly block the pathway behind you.
    ~bridge_crossed += D
    # BRIDGE_CROSSED: bridge_d
    ** Continue...
    --
   -> to 
 + [Go back.] -> from




