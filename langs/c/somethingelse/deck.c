#define _GNU_SOURCE // required for reallocarray
#include <stdlib.h>
#include <stdio.h>

#include "deck.h"

deck_t* create_deck() {
    unsigned i, j, offset;
    char* suit;
    const char* values[] = { "Ace", "Two", "Three", "Four", "Five",
        "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King" };
    card_t** cards = malloc(sizeof(card_t*) * DECK_SIZE);
    deck_t* deck = malloc(sizeof(deck_t));
    deck->cards = cards;

    for (j = 0; j < SUITS; j++) {
        offset = j * DECK_SIZE/SUITS;
        for (i = 0; i < DECK_SIZE/SUITS; i++) {
            cards[i+offset] = malloc(sizeof(card_t));
            cards[i+offset]->value = (unsigned)(i+1);
            cards[i+offset]->suit = j;
            switch (j) {
                case hearts:
                    suit = "Hearts";
                    break;
                case diamonds:
                    suit = "Diamonds";
                    break;
                case spades:
                    suit = "Spades";
                    break;
                case clubs:
                    suit = "Clubs";
                    break;
            }
            cards[i+offset]->name = calloc(20, sizeof(char));
            sprintf(cards[i+offset]->name, "%s of %s", values[i], suit);
        }
    }
    deck->size = DECK_SIZE;
    return deck;
}

void free_deck(deck_t* deck) {
    int i;
    for (i = 0; i < deck->size; i++) {
        free(deck->cards[i]->name);
        free(deck->cards[i]);
    }
    free(deck->cards);
    free(deck);
}

void free_card(card_t* card) {
    free(card->name);
    free(card);
}

// the deck gets shuffled the exact same way in
// separate instances if they are run in the same second.
void shuffle(card_t** deck, int iterations) {
    int i, j, random;
    card_t* placeholder;

    for (j = 0; j < iterations; j++) {
        for (i = 0; i < DECK_SIZE; i++) {
            // random might be equal to i.
            // in which case the card will be swapped with
            // itself. Meaning there will be no change
            random = rand() % DECK_SIZE;
            placeholder = deck[i];
            deck[i] = deck[random];
            deck[random] = placeholder;
        }
    }
}

void print_deck(deck_t* deck) {
    int i;

    for (i = 0; i < deck->size; i++) {
        printf("[%s]\n", deck->cards[i]->name);
    }
}

card_t* remove_card_from_deck(deck_t* deck) {
    if (deck->size == 0) {
        printf("OMG THE DECK IS EMPTY WTF");
        return NULL;
    }
    card_t* card = deck->cards[--deck->size];
    deck->cards = reallocarray(deck->cards, deck->size, sizeof(card_t*));
    if (deck->cards == NULL) {
        fprintf(stderr, "Failure reallocating deck.\n");
    }
    return card;
}

