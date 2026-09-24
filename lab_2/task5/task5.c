#include <stdio.h>

int main() {
    unsigned long long n = 5277616985ULL;
    unsigned long long sum = 0;
    while (n > 0) {
        sum += n % 10;
        n /= 10;
    }
    printf("%llu\n", sum);
    return 0;
}
