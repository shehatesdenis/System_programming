#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Function prototypes for assembly functions
void* init_queue(int initial_capacity);
int add_to_end(void* queue, int value);
int remove_from_start(void* queue);
int fill_random(void* queue);
int count_primes(void* queue);
int get_odds(void* queue, int* out_list);
int count_ends_with_1(void* queue);

int main() {
    printf("Testing Assignment 1 (Variant 23): Queue via Heap\n");
    srand(time(NULL));

    void* q = init_queue(20);
    if (!q) {
        printf("Failed to initialize queue\n");
        return 1;
    }
    printf("Queue initialized in heap at %p.\n", q);

    printf("Filling queue with random numbers...\n");
    fill_random(q);

    // We can't easily read the whole queue without a 'get_element' function,
    // but we can test the analysis functions.
    printf("Primes count: %d\n", count_primes(q));
    printf("Ends with 1 count: %d\n", count_ends_with_1(q));

    int odds[20];
    int odd_count = get_odds(q, odds);
    printf("Odds count: %d\n", odd_count);
    printf("Odds: ");
    for(int i=0; i<odd_count; i++) printf("%d ", odds[i]);
    printf("\n");

    printf("Adding 11 to end...\n");
    add_to_end(q, 11);

    printf("Removing from start...\n");
    remove_from_start(q);

    printf("Test completed successfully.\n");
    return 0;
}
