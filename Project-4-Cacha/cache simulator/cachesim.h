#ifndef __CACHESIM_H
#define __CACHESIM_H
typedef unsigned long long addr_t;
typedef unsigned long long counter_t;

void cachesim_init(int block_size, int cache_size, int ways);
void cachesim_access(addr_t physical_add, int write);

void cachesim_print_stats(void);

#endif
