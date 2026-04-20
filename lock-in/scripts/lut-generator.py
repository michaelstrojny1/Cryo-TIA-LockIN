import numpy as np

N = 1024
BITS = 16
MAX_VAL = 2**(BITS-1) - 1
MIN_VAL = -2**(BITS-1)

def to_twos_complement(val, bits):
    if val < 0:
        val = (1 << bits) + val
    return val

sin_vals = []
cos_vals = []

for n in range(N):
    angle = 2*np.pi*n/N
    
    sin_val = int(round(MAX_VAL*np.sin(angle)))
    cos_val = int(round(MAX_VAL*np.cos(angle)))
    
    sin_vals.append(sin_val)
    cos_vals.append(cos_val)

with open("sin_lut.hex","w") as f:
    for v in sin_vals:
        f.write(f"{to_twos_complement(v,16):04X}\n")

with open("cos_lut.hex","w") as f:
    for v in cos_vals:
        f.write(f"{to_twos_complement(v,16):04X}\n")

print("Generated sin_lut.hex and cos_lut.hex")