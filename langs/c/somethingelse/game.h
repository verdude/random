#ifndef GAME_H
#define GAME_H

#include "deck.h"
#include "player.h"

typedef struct game {
    deck_t* deck;
    player_t* dealer;
    player_t* player;
} game_t;

game_t* create_game();
void free_game();
void start_game(game_t* game);

#endif // GAME_H
