import math
import numpy as np
import matplotlib.pyplot as plt

filter = True

def int8_t(entry):
    if entry & 0x08: return np.int8(entry | 0xF0) 
    return np.int8(entry)

def cap_number(num, limit, len):
    if num > limit:
        return num-len
    return num

length = 512

array1 = np.fromfile("SNESFM-1.bst", dtype=np.int16, offset=147996+1024, count=512)
array2 = np.fromfile("SNESFM-1.bst", dtype=np.int16, offset=66076+0, count=128)
array = np.zeros(length+16)
for i in range(0, len(array1), int(len(array1)/length)):
    array[int(i/len(array1)*length)] = np.sum(array1[i:(i+int(len(array1)/length))])/int(len(array1)/length)


BRRBuffer = np.zeros(16+length+16, np.float128)
brr_old = 0
brr_oldest = 0
BRROutput = np.zeros(int((16+length+16)*9/16), np.uint8)
if filter:
    for i in range(16, len(BRRBuffer)):
        BRRBuffer[i] = (array[cap_number(i-16, length, length)]-brr_old-0.25*brr_oldest)/2
        print (cap_number(i-16, length, length))
        brr_oldest = brr_old
        brr_old = BRRBuffer[i]
        BRRBuffer[i]
else:
    for i in range(16, len(BRRBuffer)):
        BRRBuffer[i] = (array[i-16]-15/16*BRRBuffer[i-1])

# PLot

x = np.arange(0, len(BRRBuffer))

plt.plot(x,BRRBuffer) 
#plt.plot(x,array3,linestyle="--")

# Add Title

plt.title("A sine modulating (a sine modulating a sine with strength 16/32); strength 16/32") 

# Add Axes Labels

plt.xlabel("x axis") 
plt.ylabel("y axis") 

# Display

plt.show()

outindex = 0

for i in range(0, int(len(BRRBuffer)/16)):
    maximumabs = max(abs(np.max(BRRBuffer[(i*16):(i*16+15)])), abs(np.min(BRRBuffer[(i*16):(i*16+15)])))
    if maximumabs > 0:
        logarithm = math.ceil(np.log2(maximumabs))-3
        BRROutput[outindex] = (logarithm<<4) | 2 | 0<<2
        outindex += 1
        for j in range(8):
            BRRBuffer[i*16+j*2] = max(min((round(BRRBuffer[i*16+j*2]/(2**logarithm))),7), -8)
            BRRBuffer[i*16+j*2+1] = max(min(round(BRRBuffer[i*16+j*2+1]/(2**logarithm)), 7), -8)
            BRROutput[outindex] = ((np.uint8(BRRBuffer[i*16+j])&0x0F)<<4)
            BRROutput[outindex] = BRROutput[outindex] | np.uint8(BRRBuffer[i*16+j+1])&0x0F
            outindex += 1
    else:
        BRROutput[outindex] = 2
        outindex += 9

BRROutput[outindex-9] = BRROutput[outindex-9] | 1

print( "=====")
for i in range(0, len(BRRBuffer), 4):
    print (BRRBuffer[i]/1024)

print ("==========")

for i in range(0, len(BRROutput), 9):
    print ("["+str(int(BRROutput[i])>>4), end=": ")
    for j in range(7):
        print (int8_t(BRROutput[i+j+1]>>4), int8_t(BRROutput[i+j+1]&0x0F), sep = ", ", end = ", ")
    print (int8_t(BRROutput[i+8]>>4), int8_t(BRROutput[i+8]&0x0F), sep = ", ", end = "]\n")

print (len(BRRBuffer), len(BRROutput))

BRROutput.tofile("brrtest.brr")

