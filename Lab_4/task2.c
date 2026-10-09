#include <stdio.h>

int main(void) {
    long long n;
    if (scanf("%lld", &n) != 1) return 1;
    long long sum = 0;
    for (long long k = 1; k <= n; ++k) {
        long long square = k * k;
        sum += (k % 2 == 1) ? square : -square;
    }
    printf("Sum: %lld\n", sum);
    return 0;
}
