# Stacks and Queues

| Program   | Description                                                    |
| --------- | -------------------------------------------------------------- |
| stack.bas | Implementation of a simple stack with N-dimensioned values     |
| queue.bas | Implementation a a simple FIFO queue with N-dimensioned values |

As listed, the applications are configured with N = 2 and expect the value to be enqueued or pushed to be in variable V, which is a 2-dimentional array:

```vb
220 LET V(1) = I
230 LET V(2) = I * 10
```

When a value is dequeued/popped, it is placed back into the V array.
