#include <stdio.h>

int main(void) {
    long long n;
    if (scanf("%lld", &n) != 1) return 1;
    printf("Numbers:");
    for (long long k = 1; k <= n; ++k) {
        long long last_digit = k % 10;
        long long tens_digit = (k / 10) % 10;
        if (k >= 10 && last_digit != 0 && tens_digit != 0 &&
            k % last_digit == 0 && k % tens_digit == 0)
            printf(" %lld", k);
    }
    putchar('\n');
    return 0;
}
