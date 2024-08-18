#include <stdio.h>

// Function to compute factorial iteratively
unsigned long long factorial_iterative(int n) {
    unsigned long long result = 1;
    for (int i = 1; i <= n; i++) {
        result *= i;
    }
    return result;
}

int main() {
    int number;
    
    printf("Enter a number: ");
    scanf("%d", &number);
    
    if (number < 0) {
        printf("Factorial is not defined for negative numbers.\n");
    } else {
        printf("Factorial of %d (iterative) is %llu\n", number, factorial_iterative(number));
    }
    
    return 0;
}
