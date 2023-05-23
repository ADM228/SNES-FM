import math, time
import numpy as np
import matplotlib.pyplot as plt

filter = False
average = False
num = 0

def int8_t(entry):
    if entry & 0x08: return np.int8(entry | 0xF0) 
    return np.int8(entry)

def cap_number(num, limit, len):
    if num > limit:
        return num-len
    return num

length = 128

array1 = np.fromfile("SNESFMTrackDAW-1.bst", dtype=np.int16, offset=131612+0x4000, count=128)
array2 = np.fromfile("SNESFMTrackDAW-1.bst", dtype=np.int16, offset=131612+0x0400, count=128)
arrayA = np.fromfile("SNESFMTrackDAW-1.bst", dtype=np.int16, offset=131612+0x0000, count=16)
arrayB = np.fromfile("SNESFMTrackDAW-1.bst", dtype=np.int16, offset=131612+0x0020, count=16)
array3 = np.zeros(length)
array4 = np.zeros(length)
array = np.zeros(length)


step = int(len(array1)/length)
print (step)
if step > 1:
    if average:
        for i in range(0, len(array1), step):
            print (i)
            array[int(i/step)] = np.sum(array1[i:(i+step)])/step
    else:
        for i in range(0, len(array1), step):
            print (i)
            array[int(i/step)] = np.sum(array1[i])
else:
    array = array1

for i in range(length):
    array3[i] = arrayA[i&0xF]
    array4[i] = arrayB[i&0xF]



BRRBuffer = np.zeros(length, np.int16)
brr_old = 0
brr_oldest = 0
BRROutput = np.zeros(int((length)*9/16), np.uint8)
if filter:
    for i in range(16, len(BRRBuffer)):
        BRRBuffer[i] = (array[(i-16)&(length-1)]+brr_old+0.25*brr_oldest)/4
        brr_oldest = brr_old
        brr_old = BRRBuffer[i]
else:
    for i in range(len(BRRBuffer)):
        BRRBuffer[i] = (array[i&(length-1)])/2

BRRBufferNew = BRRBuffer.copy()

smppoint = BRRBufferNew[15]
print(15, hex(BRRBufferNew[15]))
currentsmppoint = 0
for i in range(16, len(BRRBufferNew)):
    smppoint *= 0.9375
    smppoint += currentsmppoint
    print(i, hex(int(smppoint)))
    currentsmppoint = BRRBufferNew[i]
    currentsmppoint -= smppoint
    BRRBufferNew[i] = currentsmppoint
    print(i, hex(BRRBufferNew[i]))

BRRBuffer = BRRBufferNew
x = np.arange(0, 128)

array1 = array1 / 2
plt.plot(x,BRRBufferNew) 
plt.plot(x,BRRBuffer) 
plt.plot(x,array3,linestyle=":")
plt.plot(x,array4,linestyle=":")


#plt.plot(x,BRRBuffer-array2) 

# Add Title

plt.title("A sine modulating (a sine modulating a sine with strength 16/32); strength 16/32") 

# Add Axes Labels

plt.xlabel("x axis") 
plt.ylabel("y axis") 

# Display

plt.show()

outindex = 0

for i in range(0, len(BRRBuffer), 16):
    maximumabs = max(abs(np.max(BRRBuffer[(i):(i+15)])), abs(np.min(BRRBuffer[(i):(i+15)])))
    if maximumabs > 0:
        logarithm = math.floor(np.log2(maximumabs))-2
        print (logarithm)
        BRROutput[outindex] = ((logarithm<<4)&0xF0) | 2 | 1<<2
        outindex += 1
        for j in range(8):
            BRRBuffer[i+j*2] = max(min((round(BRRBuffer[i+j*2]/(2**logarithm)*7/8)),7), -8)
            BRRBuffer[i+j*2+1] = max(min(round(BRRBuffer[i+j*2+1]/(2**logarithm)*7/8), 7), -8)
            BRROutput[outindex] = ((np.uint8(BRRBuffer[i+j*2])&0x0F)<<4)
            BRROutput[outindex] = BRROutput[outindex] | np.uint8(BRRBuffer[i+j*2+1])&0x0F
            outindex += 1
    else:
        BRROutput[outindex] = 2
        outindex += 9

BRROutput[0] &= 0xF2
BRROutput[outindex-9] |= 1

print( "=====")
for i in range(0, len(BRRBuffer), 4):
    #print (BRRBuffer[i]/1024)
    pass

print ("==========")

# # Pretty much a BRR decoder for debugging purposes

BRRGraph0 = np.zeros(len(BRRBuffer), dtype=BRRBuffer.dtype)
BRRGraph1 = np.zeros(len(BRRBuffer), dtype=BRRBuffer.dtype)
BRRGraph2 = np.zeros(len(BRRBuffer), dtype=BRRBuffer.dtype)
BRRGraph3 = np.zeros(len(BRRBuffer), dtype=BRRBuffer.dtype)
BRRSNES = np.fromfile("SNESFMTrackDAW-1.bst", dtype=np.uint8, offset=131612+256*0x60, count=72)



for i in range(0, len(BRROutput), 9):
    logarithm = int(BRROutput[i])>>4
    print ("["+str(logarithm), end=", ")
    print (bin(int(BRROutput[i])&0x0F)[2:], end=": ")
    for j in range(7):
        print (int8_t(BRROutput[i+j+1]>>4), int8_t(BRROutput[i+j+1]&0x0F), sep = ", ", end = ", ")
        BRRGraph0 [int(i/9*16)+j*2] = int8_t(BRROutput[i+j+1]>>4)*2**logarithm
        BRRGraph0 [int(i/9*16)+j*2+1] = int8_t(BRROutput[i+j+1]&0x0F)*2**logarithm
    print (int8_t(BRROutput[i+8]>>4), int8_t(BRROutput[i+8]&0x0F), sep = ", ", end = "]\n")
    BRRGraph0 [int(i/9*16)+14] = int8_t(BRROutput[i+8]>>4)*2**logarithm
    BRRGraph0 [int(i/9*16)+15] = int8_t(BRROutput[i+8]&0x0F)*2**logarithm
    if (int(BRROutput[i])>>2)&1:
        BRRGraph1 [int(i/9*16):int(i/9*16)+16] = np.copy(BRRGraph0 [int(i/9*16):int(i/9*16)+16])
        BRRGraph0 [int(i/9*16):int(i/9*16)+16] = np.zeros(16)
print (len(BRRBuffer), len(BRROutput))
#BRRGraph0[int((288+9)/9*16)] = 5000
# BRROutput.tofile("brr"+str(num)+".brr")
for i in range(0, len(BRRSNES), 9):
    logarithm = int(BRRSNES[i])>>4
    print ("["+str(logarithm), end=", ")
    print (bin(int(BRRSNES[i])&0x0F)[2:], end=": ")
    for j in range(7):
        print (int8_t(BRRSNES[i+j+1]>>4), int8_t(BRRSNES[i+j+1]&0x0F), sep = ", ", end = ", ")
        BRRGraph2 [int(i/9*16)+j*2] = int8_t(BRRSNES[i+j+1]>>4)*2**logarithm
        BRRGraph2 [int(i/9*16)+j*2+1] = int8_t(BRRSNES[i+j+1]&0x0F)*2**logarithm
    print (int8_t(BRRSNES[i+8]>>4), int8_t(BRRSNES[i+8]&0x0F), sep = ", ", end = "]\n")
    BRRGraph2 [int(i/9*16)+14] = int8_t(BRRSNES[i+8]>>4)*2**logarithm
    BRRGraph2 [int(i/9*16)+15] = int8_t(BRRSNES[i+8]&0x0F)*2**logarithm
    if (int(BRRSNES[i])>>2)&1:
        BRRGraph3 [int(i/9*16):int(i/9*16)+16] = np.copy(BRRGraph2 [int(i/9*16):int(i/9*16)+16])
        BRRGraph2 [int(i/9*16):int(i/9*16)+16] = np.zeros(16)
print (len(BRRBuffer), len(BRRSNES))
# PLot

x = np.arange(0, len(BRRGraph0))

plt.plot(x,BRRGraph0,linestyle=":") 
plt.plot(x,BRRGraph1,linestyle=":")
plt.plot(x,BRRGraph2,linestyle="-")
plt.plot(x,BRRGraph3,linestyle="-")


# Add Title

plt.title("A sine modulating (a sine modulating a sine with strength 16/32); strength 16/32") 

# Add Axes Labels

plt.xlabel("x axis") 
plt.ylabel("y axis") 

# Display

plt.show()
