What Is This?
-------------

A tool used to help analysis memory usage of memcached instance in different scenario.
This tool can generate values in varying size, and fill up the memcached server.
With the usage report, you can fine tune the related settings like chunk_size, growth_factor.


Slabs
=====

Slab is the way memcached used to allocate chunks, basically, they are visualizing memory chunks of different sizes, e.g. you request store a 100 bytes object, memcached will give you a chunk in closest size class, the size based on the settings of chunk_size and growth_factor, 
memcached can either use a existence one or create a new one automatically.

Conclusion
----------

Given a chunk_size and growth_factor, 

if only store objects in same size, 
before eviction, depends on the object size, 
you can get memory usage from 50% up to 98%, 
for the 98% usage, 
it must be best fit, but in real world, it's not reliable, 
e.g. if you get 98% memory usage when you filled up memcached instance with objects of 50KB, 
you change the object size to 51KB, then you run the test again, 
you will get much lower usage, 80% usage in my case.

if you store objects in varying sizes,
you can get memory usage near 93%

so, if you want to only store fixed size objects in memcached, 
you need to carefully adjust the chunk_size and growth_factor to match the size
otherwise, store objects in varying size.
