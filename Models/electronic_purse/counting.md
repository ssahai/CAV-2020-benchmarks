## Counting the number of assignments to valid

The valid function, V(Y) is given by the following invariant in the model:
``` 0bv8 <_u p1 && p1 <=_u 255bv8 ```

which imposes the following condition `V(Y) := 0 <= Y <= 255`. 

Hence, to count the number of satisfying assignments to `V(Y)` we require a simple "Range" rule for counting as presented in the paper. This gives us the following count:

```#Y.V(Y) = 256```

