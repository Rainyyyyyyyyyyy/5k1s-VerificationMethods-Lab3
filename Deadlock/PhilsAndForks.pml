#define N 5
bit forks[N];
proctype phil (chan left, right; byte mn) 
{ 
 byte cur_state = 0; 
 do 
 	:: (cur_state == 1) ->  (forks[left] == 0) ->					atomic {forks[left] = 1; cur_state = 2 } 
	:: (cur_state == 2) -> (forks[right] == 0) ->					atomic {forks[right] = 1; cur_state = 3 } 
	::(cur_state == 3) ->  cur_state = 4;
	:: (cur_state == 4) -> atomic {forks[right] = 0; 							cur_state = 5 }  
	:: (cur_state == 5) -> atomic {forks[left] = 0; 							cur_state = 0 } 
	::(cur_state == 0) -> 	cur_state = 1; 
od } 


init 
{ 
byte proc; 
proc = 1; 
do 
:: proc <= N -> 
	run phil (proc-1, (proc%N), proc);   	proc++; 
:: proc > N -> 	 break ;
od 
}
