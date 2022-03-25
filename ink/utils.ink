
=== check_win_loss(island)
    // TODO Finish this properly
    {island:
        - north:
            {bridge_crossed?(A,B,C):-> game_over(island)}
        - south:
            {bridge_crossed?(E,F,G):-> game_over(island)}
        - kneiphof:
            {bridge_crossed?(A,B,C,D,E,F,G):-> victory()}
            {bridge_crossed?(A,B,D,E,F):-> game_over(island)}
        - lomse:
            {bridge_crossed?(C,D,G):-> game_over(island)}
    }
    ->->