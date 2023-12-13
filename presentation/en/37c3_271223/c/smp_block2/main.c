#define _GNU_SOURCE  // To get gettid()
#include <pthread.h>
#include <sys/types.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/time.h>

#define WORD_TYPE int
#define ITERATIONS 50000000

void *thread0(void *arg)
{
  volatile WORD_TYPE *value = (int*) arg;
  while(1){
    *value = 1;
  }
  return NULL;  
}

void *thread1(void *arg)
{
  volatile WORD_TYPE *value = (int*) arg;
  int accumulator = 0;
  for(int i = 0;i < ITERATIONS;i++){
    accumulator += *value;
  }
  *value = accumulator;
  return NULL;  
}


int __attribute__ ((aligned (64))) array[1024];

int main() {
  int byte_offset = 16;
  assert(byte_offset%sizeof(WORD_TYPE) == 0);
  int word_offset = byte_offset / sizeof(WORD_TYPE);
    
  array[0] = 1;
  array[word_offset] = 1;

  struct timespec start, end;
  clock_gettime(CLOCK_MONOTONIC_RAW, &start);

  pthread_t tid1, tid2;
  pthread_create(&tid1,NULL, thread0, array+0);
  pthread_create(&tid2,NULL, thread1, array+word_offset);
 
 // (void) pthread_join(tid1, NULL);
  (void) pthread_join(tid2, NULL);

  clock_gettime(CLOCK_MONOTONIC_RAW, &end);
  unsigned long delta_us = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_nsec - start.tv_nsec) / 1000;

  assert(array[word_offset] == ITERATIONS);
  printf("toke %5ld ms %8ld ps/iter/thread\n", delta_us/1000, delta_us*1000000/ITERATIONS);
  return 0; 
}
