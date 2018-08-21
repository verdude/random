#include <stdlib.h>
#include <stdio.h>

#include "game.h"
#include "deck.h"
#include "player.h"

game_t* create_game() {
    game_t* game = malloc(sizeof(game_t));
    game->deck = create_deck();
    game->dealer = create_player("dealer");
    game->player = create_player("bob");
    return game;
}

void free_game(game_t* game) {
    free_deck(game->deck);
    free_player(game->dealer);
    free_player(game->player);
    free(game);
}

void deal_card(deck_t* deck, player_t* player) {
    card_t* card = remove_card_from_deck(deck);
    if (card == NULL) {
        printf("TIS THE END OF TIMES.\n");
        return;
    }
    add_to_hand(player, card);
}

void start_game(game_t* game) {
    char letter;
    printf("Welcome %s.\n", game->player->name);
    shuffle(game->deck->cards, 5);
    deal_card(game->deck, game->player);
    deal_card(game->deck, game->dealer);
    deal_card(game->deck, game->player);
    deal_card(game->deck, game->dealer);
    while (points(game->player) < 21) {
        print_hand(game->player);
        print_hand(game->dealer);
        do {
            printf("\nHit or stand [h|s]: ");
            letter = getchar();
        } while (letter != 'h' || letter != 's');
        if (letter == 'h') {
            deal_card(game->deck, game->player);
        } else if (letter == 's') {
            break;
        }
    }
    print_hand(game->player);
    print_hand(game->dealer);
}

