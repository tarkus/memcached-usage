# Memcached Usage

memcached-usage is a tool can help analyzing memcached memory usage in various scenarios.

## How it works

memcached-usage will spawn a memcached server, fill it up with varying or particular size values, and output a usage report.
With the usage report, you can fine tune the related settings e.g. chunk_size, growth_factor.
This bundle also included some test scenarios, check it out before write your own.

## Requirement

- memcached
- node
- npm

## Installation

clone this repo

```
git clone git@github.com:tarkus/memcached-usage.git
```

install the dependencies with npm
```
cd memcached-usage
npm install
```

now you are ready to run the test scenario
```
node run.js
```
or 
```
node server.js
```
then open it in your browser `http://localhost:4000/`

## A Peek at Memcached's Memory Management

### Slabs

Slab is the way memcached used to allocate chunks, basically, they are representing different sizes memory chunks. 
When you request memory, memcached will calculate the chunk size based on the settings of chunk_size and growth_factor, 
then give you whether a free chunk or create a new slab class, in closest size.

### Useful Command
- `stats` - general information
- `stats slabs` - useful information dedicated on slabs class and slab usage.
- `stats settings` - some settings can be set using command options, man memcached for details

### Tools

You can use [memcache-top](http://code.google.com/p/memcache-top/) to monitor memcached status.

### Reference

[Memcached protocol](https://github.com/memcached/memcached/blob/master/doc/protocol.txt)

## Analysis

Set the fixture size and run through the test, I figure out, 

- if only store fixed size objects, the usage are too dynamical, 
in range from 50% up to 98%,
it's depend on the object size, chunk_size, and growth_factor,
the best fit object produces highest usage.

- if store small objects in varying size, you can get average usage near 93%

## Conclusion

- Storing fixed size objects in memcached is very tricky, 
you need to carefully adjust the chunk_size and growth_factor to match the object size.

- Using memcached as a pool to store varying size objects is the mature way.

- Avoiding store big objects into memcached. 
Besides memcached's 1MB hard limit on object size, you need very special settings to reduce the wasted memory.
The usage of store big objects is much lower than store small ones.
