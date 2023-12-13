main : main.c
	gcc main.c -l pthread -o main


run : main
	taskset -c 0 ./main .
	taskset -c 0,1 ./main .
	taskset -c 0,2 ./main .
	taskset -c 0,4 ./main .
	taskset -c 0,8 ./main .
	taskset -c 0,16 ./main .

