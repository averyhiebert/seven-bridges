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
  -> Kneiphof


=== Kneiphof ====================================================
# SET_BG: kneiphof.png
# CLEAR
-> check_win_loss(kneiphof) ->
You are standing in the cobbled streets of the island of Kneiphof{intro:, in the city of Konigsberg}.  The only sound is the croaking and flitting of crows.  //TODO Randomize flavourtext
{intro:The windows are dark.  The streets are empty.  The glow of twilight (or perhaps sunrise) lingers in the sky, as though frozen in time.}
~intro = false

Above you looms the ((Konigsberg Cathedral)).
// TODO Handle bridges already crossed.
To the north, an ((iron bridge)) and a ((marble bridge)) cross over the river Pregel to the North Shore.

To the south, a ((bridge of stone)) and a ((bridge of brick)) stretch towards the South Shore.

To the east, a ((wooden bridge)) leads to the island of Lomse.
~ island_seen += kneiphof

 + ((Konigsberg Cathedral))
    -> cathedral_door
 + ((iron bridge))
    -> Bridges.iron(-> Kneiphof, ->North_Shore)
 + ((marble bridge))
    -> Bridges.marble(->Kneiphof, ->North_Shore)
 + ((wooden bridge))
    -> Bridges.wooden(->Kneiphof, ->Lomse)
 + ((bridge of brick))
    -> Bridges.brick(->Kneiphof, ->South_Shore)
 + ((bridge of stone))
    -> Bridges.stone(->Kneiphof, ->South_Shore)

= cathedral_door
# CLEAR
The cathedral is tall and imposing, with a bell tower rising above an asymmetric peaked roof.
The door is elaborately carved with apocalyptic imagery.  It is <>
{
-cathedral_locked and cathedral_key:
    ((locked)), but the golden key you found fits perfectly.
-cathedral_locked:
    locked.
-else:
    ((unlocked)).
}
+ {cathedral_locked and cathedral_key}((locked))
    ~ cathedral_locked = false
    -> cathedral_door
+ {cathedral_key and not cathedral_locked}((unlocked))
    ~ cathedral_locked = true
    -> cathedral_door
+ {not cathedral_locked}[Enter the cathedral.]
    -> cathedral_interior
+ [Go back.]
    -> Kneiphof

= cathedral_interior
#CLEAR
The cathedral is magnificent.  Colourful windows reach up to vaulted ceilings high overhead.
The far end of the cathedral is occupied by an elaborate {investigated_organ:pipe organ, a massive collection of pipes with a sprawling, almost organic appearance|((pipe organ))}.
Nearer to the entrance, a <>
    {cathedral_passage_blocked:
        ((cedar coffin)) lies in an alcove.
    -else:
        cedar coffin lies in an alcove. It has been moved to the side, exposing a ((trapdoor)).
    }
 * (investigated_organ)((pipe organ))
    -> cathedral_interior
 * {cathedral_passage_blocked}[((cedar coffin))]
    You move the coffin slightly, revealing a trapdoor in the floor beneath it.
    ~ cathedral_passage_blocked = false
    ++ [Ok] // TODO better handling
        -> cathedral_interior
 + {not cathedral_passage_blocked}[((trapdoor))]
    {tunnel_flooded:The trapdoor leads to a flooded tunnel.|The trapdoor seems to be locked from the other side.}
    ++ [Ok] // TODO better handling
        -> cathedral_interior
 + Leave the cathedral.
    -> Kneiphof

=== North_Shore ======================================================
# SET_BG: north_shore.png
# CLEAR
-> check_win_loss(north) ->
You are on the North Shore of the river Pregel.  The fortifications of Konigsberg Castle tower over you.  Moss clings to the cracks in the ancient walls.

To the southwest, a ((bridge of iron)) and a ((bridge of marble)) lead to the island of Kneiphof.

To the southeast, a ((drawbridge)) leads to the island of Lomse.  The bridge is {bridge_crossed?C: drawn up| down}.

 + ((bridge of iron))
    -> Bridges.iron(->North_Shore, -> Kneiphof)
 + ((bridge of marble))
    -> Bridges.marble(->North_Shore, -> Kneiphof)
 + ((drawbridge))
    -> Bridges.drawbridge(->North_Shore, ->Lomse)


=== Lomse =======================================================
# SET_BG: lomse.png
# CLEAR
-> check_win_loss(lomse) ->

You are in a graveyard on the marshy, sparsely inhabited island of Lomse.  Grim grey headstones and scraggly trees stretch into the misty distance.

Nearby is a lonely ((ossuary)).

A ((drawbridge)) leads to the North Shore.  The bridge is {bridge_crossed?C: drawn up| down}.

A ((rope bridge)) extends precariously to the South Shore.

To the west, a ((wooden bridge)) connects to the island of Kneiphof.

 + ((ossuary))
    -> ossuary_exterior
 + ((drawbridge))
    -> Bridges.drawbridge(->Lomse, ->North_Shore)
 + ((wooden bridge))
    -> Bridges.wooden(->Lomse, ->Kneiphof)
 + ((rope bridge))
    -> Bridges.rope(->Lomse, ->South_Shore)

= ossuary_exterior
#CLEAR
The ossuary is a plain stone building.  The only adornment is a Latin {read_inscription:inscription over the entrance: MELIUS EST IRE AD DOMUM LUCTUS QUAM AD DOMUM CONVIVII|((inscription)) over the entrance}.
The oaken door is {ossuary_locked:locked{ossuary_key:, but the iron key you found fits the lock perfectly|}|unlocked}.

// TODO Proper lock/unlock behaviour, like the cathedral.
 + {ossuary_locked and ossuary_key}Unlock the ossuary.
   ~ ossuary_locked = false
   -> ossuary_exterior
 + {not ossuary_locked}Lock the ossuary.
   ~ ossuary_locked = true
   -> ossuary_exterior
 * (read_inscription)((inscription))
   -> ossuary_exterior
 + {not ossuary_locked}Enter the ossuary.
   -> ossuary_interior
 + [Go back.] -> Lomse
 
= ossuary_interior
#CLEAR
You are in a dark stone room.  Against each wall is a tightly-packed stack of human bones.  The door casts a beam of light on a pile of skulls grinning against the back wall.
In the floor is a trapdoor leading to a {tunnel_flooded:dark tunnel filled with muddy water.|((dark tunnel)).}
 * ((dark tunnel))
   -> tunnel_from_ossuary
 + [Leave.] -> ossuary_exterior

= tunnel_from_ossuary
#CLEAR
The tunnel is long and damp, and leads quite a ways to the west.  The walls are lined with sarcophagi; this appears to be some sort of catacomb.
Eventually you reach the end of the passage.  If you had to guess, you're somewhere under the cathedral.  There is a trapdoor in the roof above you.
Behind you, the passage begins to fill with water.
~ tunnel_flooded = true
 * {not cathedral_passage_blocked}[Open the trapdoor] # CLEAR
   You climb out of the trapdoor, leaving behind the flooding catacombs.  You find yourself inside the Cathedral. # SET_BG: kneiphof.png
   ** Continue...
      -> Kneiphof.cathedral_interior
 * {cathedral_passage_blocked}[Open the trapdoor] # CLEAR
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
# CLEAR
-> check_win_loss(south) ->
You are on the South Shore of the river Pregel.  Further south, many narrow cobbled streets wind maze-like between tall buildings leaning at strange angles.  The streets are dark and empty.

A {take_ferry:wooden jetty|((wooden jetty))} juts out into the river.{not take_ferry:  At the end stands a silent, grey-cloaked figure.}

To the north west, a ((bridge of stone)) and {bridge_crossed?F:the remains of }a ((bridge of brick)) lead to the island of Kneiphof.

To the north east, a ((rope bridge)) leads to the island of Lomse.
// TODO DENSE MAZE OF BUILDINGS
 + {not take_ferry}((wooden jetty))
    -> ferryman
 + ((bridge of stone))
    -> Bridges.stone(->South_Shore, ->Kneiphof)
 + ((bridge of brick))
    -> Bridges.brick(->South_Shore, ->Kneiphof)
 + ((rope bridge))
    -> Bridges.rope(->South_Shore, ->Lomse)

= ferryman
# CLEAR
The jetty creaks as the murmuring currents of the Pregel rush past.

A cloaked figure stands next to a small rowboat.  As you approach he says nothing, but holds out a pale hand for payment. {drachmas < 1:Alas, you have nothing to pay him with.}
+ [Go back.] -> South_Shore
* (take_ferry){drachmas > 0}Pay the ferryman. 
    #CLEAR
    You place the ancient coin you found in the ferryman's outstretched hand. Wordlessly, he leads you into his boat and begins to row you away from the jetty.
    ** [Wait...]
    -- # CLEAR
    As you cross the river, you glance {shuffle:down into the stygian depths of the Pregel, where nothing but endless darkness meets your gaze.|up at the underside of the wooden bridge connecting Kneiphof and Lomse.  The ancient wood is covered in carvings of wild men, dancing satyrs, and strange forms that you can't quite make sense of.}
    ** [Wait...]
    -- # CLEAR
    Eventually, the boat arrives on the North Shore and the hooded ferryman silently gestures for you to leave.  You step out of the small boat and onto a stone walkway next to the river.
    ** [Thank the ferryman.]
    -- You turn to thank the ferryman, but he is already gone.
    ** Continue...
        -> North_Shore

=== game_over(island) ======================================================
In the distance, an iron bell tolls mournfully.  You realize that you are trapped here, with no way to reach the remaining uncrossed bridges{island != kneiphof: or return to the Cathedral}.
Unless...
   * [Attempt to swim.]
     You leap into the Pregel river in a desperate final attempt to fulfill your task.
     You are immediately overwhelmed by the cold and the current.  The world fades into darkness as you sink into the inky depths.
   -
   // TODO Varied flavour text
   * Your penance is not yet over...
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
        You grab the key. # CLEAR
        ~ossuary_key = true
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
        You grab the key. # CLEAR
        ~cathedral_key = true
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
        You pick up the object.  It appears to be some sort of coin, irregularly shaped and bearing an inscription in ancient Greek. #CLEAR
        ~drachmas += 1
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




