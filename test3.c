#include<stdio.h>

int multiply(int a)
{
   return 2*a;
}

int main()
{
    int a = 5;
    int b = multiply(a);
    printf("%d", b);
}