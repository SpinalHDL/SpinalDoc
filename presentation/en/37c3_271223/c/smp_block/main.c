#define _GNU_SOURCE  // To get gettid()
#include <pthread.h>
#include <sys/types.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/time.h>

#define WORD_TYPE int
#define ITERATIONS 10000000

void * work(void *arg)
{
  volatile WORD_TYPE *value = (int*) arg;
  for(int i = 0;i < ITERATIONS;i++){
    *value += 1;
  }
  return NULL;  
}

int __attribute__ ((aligned (64))) array[1024];

int main() {
  int byte_offset = 4;
  assert(byte_offset%sizeof(WORD_TYPE) == 0);
  int word_offset = byte_offset / sizeof(WORD_TYPE);
    
  array[0] = 0;
  array[word_offset] = 0;

  struct timespec start, end;
  clock_gettime(CLOCK_MONOTONIC_RAW, &start);

  pthread_t tid1, tid2;
  pthread_create(&tid1,NULL, work, array+0);
  pthread_create(&tid2,NULL, work, array+word_offset);
 
  (void) pthread_join(tid1, NULL);
  (void) pthread_join(tid2, NULL);

  clock_gettime(CLOCK_MONOTONIC_RAW, &end);
  unsigned long delta_us = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_nsec - start.tv_nsec) / 1000;

  assert(array[0] == 10000000 && array[word_offset] == 10000000);
  printf("toke %5ld ms %8ld ps/iter/thread\n", delta_us/1000, delta_us*1000000/ITERATIONS);
  return 0; 
}
