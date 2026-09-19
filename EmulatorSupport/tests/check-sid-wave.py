#!/usr/bin/env python3
"""Check a WAV produced by sid-smoke.cpp; Python standard library only."""
import array, math, sys, wave
with wave.open(sys.argv[1],'rb') as w:
    assert w.getnchannels()==1 and w.getsampwidth()==2 and w.getframerate()==48000
    samples=array.array('h',w.readframes(w.getnframes()))
    if sys.byteorder!='little':samples.byteswap()
fs=48000
def chunk(a,b):return samples[int(a*fs):int(b*fs)]
def rms(a,b):
    x=chunk(a,b);mean=sum(x)/len(x)
    return math.sqrt(sum((v-mean)**2 for v in x)/len(x))
x=chunk(1.5,2.5);mean=sum(x)/len(x)
edges=[i for i in range(1,len(x)) if x[i-1]<=mean<x[i]]
hz=(len(edges)-1)*fs/(edges[-1]-edges[0])
assert abs(hz-440)<1,(hz,'pitch')
assert 6.99<len(samples)/fs<7.02
assert rms(.8,.95)<5 and rms(3.8,3.95)<5 and rms(6.8,6.95)<5
assert rms(1.5,2.5)>100 and rms(4.3,4.8)>100 and rms(5.3,5.8)>100
assert max(abs(v) for v in samples)<32767
print(f'PASS: {hz:.2f} Hz; triangle, noise, voices 2+3, settled mute, duration and no clipping')
