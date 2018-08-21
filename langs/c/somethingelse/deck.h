#ifndef DECK_H
#define DECK_H

#define DECK_SIZE ((unsigned)52)
#define SUITS 4

typedef enum suit { hearts, diamonds, spades, clubs } suit_t;

typedef struct card {
    unsigned value;
    suit_t suit;
    char* name;
} card_t;

typedef struct deck {
    unsigned size;
    card_t** cards;
} deck_t;

deck_t* create_deck();
void free_deck(deck_t* deck);
void free_card(card_t* card);
void shuffle(card_t** deck, int iterations);
void print_deck(deck_t* deck);
card_t* remove_card_from_deck(deck_t* deck);

#endif // DECK_H

