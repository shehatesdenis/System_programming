#include "read_n.h"

int main(void) {
    long long n;
    if (!read_n(&n)) {
        return 1;
    }

    printf("Numbers:");
    for (long long k = 10; k <= n; ++k) {
        long long last_digit = k % 10;
        long long tens_digit = (k / 10) % 10;
        if (last_digit != 0 && tens_digit != 0 &&
            k % last_digit == 0 && k % tens_digit == 0) {
            printf(" %lld", k);
        }
        if (k == n) {
            break;
        }
    }
    putchar('\n');
    return 0;
}
