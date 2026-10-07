#define N 5

mtype = { msgtype, REQUEST, GRANT, DONE };

chan c[N] = [0] of { mtype };
chan d[N] = [0] of { mtype };
chan w[N] = [0] of { mtype };

proctype phil(chan left, right, waiter; byte mn) {
    byte cur_state = 0;
    printf("MSC: phil # %d \n", mn);
    do
    :: (cur_state == 1) ->
        waiter ! REQUEST;
        waiter ? GRANT;
        cur_state = 2;
    :: (cur_state == 2) ->
        left ! msgtype;
        cur_state = 3;
    :: (cur_state == 3) ->
        right ! msgtype;
        cur_state = 4;
    :: (cur_state == 4) ->
        cur_state = 5;
    :: (cur_state == 5) ->
        right ! msgtype;
        cur_state = 6;
    :: (cur_state == 6) ->
        left ! msgtype;
        cur_state = 7;
    :: (cur_state == 7) ->
        waiter ! DONE;
        cur_state = 0;
    :: (cur_state == 0) ->
        cur_state = 1;
    od
}

proctype fork(chan left_phil, right_phil) {
    byte cur_state_fork = 0;
end:
    do
    :: (cur_state_fork == 0) ->
        if
        :: right_phil ? msgtype -> cur_state_fork = 2;
        :: left_phil  ? msgtype -> cur_state_fork = 1;
        :: skip;
        fi
    :: (cur_state_fork == 1) ->
        left_phil ? msgtype -> cur_state_fork = 0;
    :: (cur_state_fork == 2) ->
        right_phil ? msgtype -> cur_state_fork = 0;
    od
}

proctype waiter() {
    byte count = 0;
    do
    :: (count < N-1) ->
        if
        :: w[0] ? REQUEST -> w[0] ! GRANT; count++
        :: w[1] ? REQUEST -> w[1] ! GRANT; count++
        :: w[2] ? REQUEST -> w[2] ! GRANT; count++
        :: w[3] ? REQUEST -> w[3] ! GRANT; count++
        :: w[4] ? REQUEST -> w[4] ! GRANT; count++
        fi
    :: (count > 0) ->
        if
        :: w[0] ? DONE -> count--
        :: w[1] ? DONE -> count--
        :: w[2] ? DONE -> count--
        :: w[3] ? DONE -> count--
        :: w[4] ? DONE -> count--
        fi
    od
}

init {
    run phil(d[0], c[0], w[0], 0);
    run phil(d[1], c[1], w[1], 1);
    run phil(d[2], c[2], w[2], 2);
    run phil(d[3], c[3], w[3], 3);
    run phil(d[4], c[4], w[4], 4);

    run fork(c[0], d[1]);
    run fork(c[1], d[2]);
    run fork(c[2], d[3]);
    run fork(c[3], d[4]);
    run fork(c[4], d[0]);

    run waiter();
}
