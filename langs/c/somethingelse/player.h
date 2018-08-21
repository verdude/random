#ifndef PLAYER_H
#define PLAYER_H

#include "deck.h"

typedef struct player {
    char* name;
    card_t** hand;
    unsigned hand_size;
    unsigned num_cards;
} player_t;

player_t* create_player(char* name);
void free_player(player_t* player);
void add_to_hand(player_t* player, card_t* card);
void print_hand(player_t* player);

#endif // PLAYER_H

