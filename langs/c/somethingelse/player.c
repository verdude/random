#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "player.h"
#include "deck.h"

player_t* create_player(char* name) {
    player_t* player = malloc(sizeof(player_t));
    player->name = strdup(name);
    player->hand = NULL;
    player->num_cards = 0;
    return player;
}

void free_player(player_t* player) {
    int i;
    free(player->name);
    for (i = 0; i < player->num_cards; ++i) {
        free_card(player->hand[i]);
    }
    if (player->hand != NULL)
        free(player->hand);
    free(player);
}

void add_to_hand(player_t* player,  card_t* card) {
    player->hand = reallocarray(player->hand, ++player->num_cards, sizeof(card_t*));
    if (player->hand == NULL) {
        fprintf(stderr, "Failure reallocating %s's hand.\n", player->name);
    }
    player->hand[player->num_cards-1] = card;
}

unsigned points(player_t* player) {
    int i, total;
    for (i = 0; i < player->num_cards; i++) {
        total += player->hand[i]->value;
    }
    return value;
}

void print_hand(player_t* player) {
    int i;

    for (i = 0; i < player->num_cards; ++i) {
        printf("%s\n", player->hand[i]->name);
    }
}

