#!/usr/bin/env python

def fib(n):
    if n <= 1:
        return n
    return fib(n - 1)

print fib(5)
