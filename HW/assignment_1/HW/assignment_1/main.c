#include <stdio.h>
#include <stdlib.h>

// Function prototypes for assembly functions
void* init_array(int initial_capacity);
int add_to_end(void* array, int value);
int remove_from_start(void* array);
int count_primes(void* array);
int get_odds(void* array, int* out_list);
int count_ends_with_1(void* array);

int main() {
    printf("Testing Assignment 1: Dynamic Array via mmap\\n");

    void* arr = init_array(20);
    if (!arr) {
        printf("Failed to initialize array\\n");
        return 1;
    }
    printf("Array initialized at %p.\\n", arr);

    int vals[] = {2, 3, 4, 5, 11, 13, 21, 17};
    int n = sizeof(vals)/sizeof(vals[0]);
    for(int i=0; i<n; i++) {
        add_to_end(arr, vals[i]);
        printf("Added %d\\n", vals[i]);
    }

    printf("Primes count: %d (Expected: 5 [2,3,5,11,13,17])\\n", count_primes(arr));
    printf("Ends with 1 count: %d (Expected: 2 [11,21])\\n", count_ends_with_1(arr));

    int odds[20];
    int odd_count = get_odds(arr, odds);
    printf("Odds count: %d\\n", odd_count);
    printf("Odds: ");
    for(int i=0; i<odd_count; i++) printf("%d ", odds[i]);
    printf("\\n");

    remove_from_start(arr);
    printf("Removed first element.\\n");

    return 0;
}
