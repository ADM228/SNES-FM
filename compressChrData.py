import math, time
import numpy as np

inChrData = np.fromfile("tilesetUnicode.chr", dtype=np.int64)
outChrData = np.zeros(len(inChrData), dtype=np.int64)

for i in range(1024):
    outChrData[i] = inChrData[((i&0x1E)<<3)|((i&0xE0)>>4)|(i&0xF01)]

outChrData.tofile("tilesetUnicode.bin")
