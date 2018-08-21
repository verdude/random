#include <stdlib.h>
#include <time.h>
#include <stdio.h>

#include "game.h"

int main() {
    srand(time(NULL));
    game_t* game = create_game();
    start_game(game);
    free_game(game);
}

