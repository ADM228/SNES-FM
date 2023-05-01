import math
# import numpy as np
# import matplotlib

# length = 128
# sinIncrement = 2/length
# type = np.int16
# maximum = (np.iinfo(type).max+1)

# a = np.zeros(length, type)

# for i in range (length):
#     a[i] = math.sin(i*sinIncrement*math.pi)*maximum-0.5

# print (np.iinfo(a.dtype).min)

# b = (a[:int(length/4+1)]).tobytes('C')
# a = a.tobytes('C')

# # file = open("sinetable.bin", 'wb')
# # file.write(a)
# # file.close()

# file = open("quartersinetable.bin", 'wb')
# file.write(b)
# file.close()

highbyte = 0
locale = [0x0053, 0x0061, 0x0076, 0x0065, 0x0020, 0x0066, 0x0069, 0x006c, 0x0065, 0x0020, 0x0069, 0x0073, 0x0020, 0x006e, 0x0065, 0x0077, 0x0065, 0x0072, 0x0020, 0x0074, 0x0068, 0x0061, 0x006e, 0x0020, 0x0074, 0x0068, 0x0065, 0x0020, 0x0053, 0x004e, 0x0045, 0x0053, 0x0046, 0x004d, 0x0020, 0x0076, 0x0065, 0x0072, 0x0073, 0x0069, 0x006f, 0x006e, 0x0020, 0x0079, 0x006f, 0x0075, 0x0027, 0x0072, 0x0065, 0x0020, 0x0075, 0x0073, 0x0069, 0x006e, 0x0067, 0x002e, 0x0020, 0x0050, 0x006c, 0x0065, 0x0061, 0x0073, 0x0065, 0x0020, 0x0075, 0x0070, 0x0064, 0x0061, 0x0074, 0x0065, 0x0020, 0x0053, 0x004e, 0x0045, 0x0053, 0x0046, 0x004d, 0x0020, 0x0074, 0x006f, 0x0020, 0x0075, 0x0073, 0x0065, 0x0020, 0x0074, 0x0068, 0x0065, 0x0020, 0x0073, 0x0061, 0x0076, 0x0065, 0x0020, 0x0066, 0x0069, 0x006c, 0x0065, 0x002e]
locale += (128-len(locale)) * [0x0020,]
lobytes = []
string = ""
for i in range(0, len(locale), 8):
    highbyte = (((locale[i] & 0xff00) != 0) << 7) | (((locale[i+1] & 0xff00) != 0) << 6) | (((locale[i+2] & 0xff00) != 0) << 5) | (((locale[i+3] & 0xff00) != 0) << 4) | (((locale[i+4] & 0xff00) != 0) << 3) | (((locale[i+5] & 0xff00) != 0) << 2) | (((locale[i+6] & 0xff00) != 0) << 1) | ((locale[i+7] & 0xff00) != 0)
    lobytes = [f'{locale[i] & 0xff:02x}', f'{locale[i+1] & 0xff:02x}', f'{locale[i+2] & 0xff:02x}', f'{locale[i+3] & 0xff:02x}', f'{locale[i+4] & 0xff:02x}', f'{locale[i+5] & 0xff:02x}', f'{locale[i+6] & 0xff:02x}', f'{locale[i+7] & 0xff:02x}']
    string = "    ;\"" + locale[i].to_bytes(2, 'big').decode(encoding="utf-16-BE") + locale[i+1].to_bytes(2, 'big').decode(encoding="utf-16-BE") + locale[i+2].to_bytes(2, 'big').decode(encoding="utf-16-BE") + locale[i+3].to_bytes(2, 'big').decode(encoding="utf-16-BE") + locale[i+4].to_bytes(2, 'big').decode(encoding="utf-16-BE") + locale[i+5].to_bytes(2, 'big').decode(encoding="utf-16-BE") + locale[i+6].to_bytes(2, 'big').decode(encoding="utf-16-BE") + locale[i+7].to_bytes(2, 'big').decode(encoding="utf-16-BE") + "\""
    print ("        db %" + f'{highbyte:08b}' + ", $" + ", $".join(lobytes) + string)