#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "cachesim.h"
#include <math.h>
#include <stdlib.h>
#include <time.h>

//struct of chche block, each block have valid bit, dirty bit, LRU and tag
typedef struct{
    int valid;
    addr_t tag;
    int LRU;
    int dirty;
} block;
// information of the cache
typedef struct 
{
    int C;
    int S;
    int B;
    int blocks;
    int caches;
    int wayss;
}info;

// inititial my cache
block **cache;
info *inf;

//set lru counter to 0;
int counter = 0;


counter_t accesses = 0, hits = 0, misses = 0, writebacks = 0,write_misses = 0,read_miss=0;;

void cachesim_init(int blocksize, int cachesize, int ways) {
//calcuate how many block in my cache.
int block_num = cachesize/blocksize;
//calcute how many line of block in cacge
int set_number = cachesize/blocksize/ways;
int block_per_set = ways;
//malloc the space for cache.
cache = malloc(set_number*sizeof(block *));
for (int i = 0; i < set_number; i=i+1)
{
    cache[i] = malloc (block_per_set*sizeof(block));
}
//set valid and dirty to 0
for (int i = 0; i < set_number; ++i)
{
    for (int j = 0; j < block_per_set; ++j)
    {
        cache[i][j].valid=0;
        cache[i][j].dirty=0;
    }
}

inf = malloc(sizeof(info));
inf->C=(log(cachesize)/log(2));
inf->S=(log(ways)/log(2));
inf->B=(log(blocksize)/log(2));


}

//get how many bit of offset have 
addr_t offsetbit(info *inf){
    return inf->B;
}
//get how many bit of index have 
addr_t indexbit(info *inf){
    return inf->C-inf->B-inf->S;
}
//get how many bit of tag have 
addr_t tagbit(info *inf){
    return 64-offsetbit(inf)-indexbit(inf);
}


//get my index
addr_t getindex(addr_t address,info *inf){
    return  (address<<(tagbit(inf)))>> (tagbit(inf)+offsetbit(inf));
    
}
//get my tag
addr_t gettag(addr_t address,info *inf){
return address>>(offsetbit(inf)+indexbit(inf));
}







//find the block I need according to tag, index and valid bit.
block* getblock(addr_t address,block **cache,info *inf){
addr_t index = getindex(address,inf);
addr_t tag = gettag(address,inf);

for (int i = 0; i < pow(2,inf->S); i=i+ 1)
{ 
   
    if (cache[index][i].tag==tag && cache[index][i].valid==1)
    {   
        counter = counter +1;
        cache[index][i].LRU=counter;
         return &(cache[index][i]);
    }

}
return NULL;
}

//find a invalid block to evit.
block* find_invalid(addr_t address,block **cache,info *inf) {
   addr_t index = getindex(address,inf);
addr_t tag = gettag(address,inf);

for (int i = 0; i < pow(2,inf->S); i=i+1)
{   
    if (cache[index][i].valid==0)
    {
       counter = counter +1;
        cache[index][i].LRU=counter;
        return &(cache[index][i]);
    }
}
return NULL;
}

//function to find the LRU block.
block* find_lru(addr_t address,block **cache,info *inf){
    addr_t index = getindex(address,inf);
    addr_t choose= 0;
for (int i = 0; i < pow(2,inf->S); ++i)
{   
    if (cache[index][choose].LRU>cache[index][i].LRU)
    {

        choose = i;
    }
}
        counter = counter +1;
        cache[index][choose].LRU=counter;
        return &(cache[index][choose]);

}






void cachesim_access(addr_t physical_addr, int write) {
//if the cache access is read
if (write !=1)
{
     block* find_block;
     addr_t tag=gettag(physical_addr,inf);
     addr_t index=getindex(physical_addr,inf);
    accesses++;

    //find the block we want
   find_block = getblock(physical_addr,cache,inf);
  //if we can not find a block
   if (find_block==NULL)
   {   // find a invalid block to evit
        find_block=find_invalid(physical_addr,cache,inf);
     if (find_block==NULL)
        {  // find the LRU block
            find_block = find_lru(physical_addr,cache,inf);
            //write back if the block is dirty
            if (find_block->dirty==1)
            {
                writebacks++;

            }

        }
        //set block to valid to 1 and dirty to 0 and update the miss.
        find_block->valid =1;
        find_block->dirty =0;
        find_block->tag=tag;
        misses++;
        read_miss++;
    }
    else{
        hits++;
    }
}
//if cache access is write.
if (write==1)
{
    addr_t tag=gettag(physical_addr,inf);
    addr_t index=getindex(physical_addr,inf);
    accesses++;
    block *find_block;
    //find the block we want
    find_block = getblock(physical_addr,cache,inf);
    if (find_block==NULL)
    {
        // find a invalid block to evit
        find_block = find_invalid(physical_addr,cache,inf);
        if (find_block==NULL)
        {
            // find a LRU block
            find_block = find_lru(physical_addr,cache,inf);
            if (find_block->dirty==1)
            {
                writebacks++;
            }

        }
//set block to valid and dirty to 1 and update the miss.
        find_block->valid =1;
        find_block->dirty=1;
        find_block->tag=tag;
       misses++;
       write_misses++;
        /* code */
    }
    else
    {
          hits++;
    find_block->dirty=1;
    }
}
}


void cachesim_print_stats() {
//print the result we have
  printf("%llu, %llu,%llu, %llu\n", accesses, hits, misses, writebacks);
}
