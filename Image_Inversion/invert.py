import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
# Load your bitstream and instantiate your IP
# Update the bitstream filename and IP name as appropriate for your design.
overlay = Overlay('your_bitstream.bit') # <-- Change to your actual bitstream filename
ip = overlay.myip_apple_v1_0_0 # <-- Change to your actual IP name in the overlay
# Load and prepare the image (ensure grayscale)
img = Image.open('your_image.png').convert('L') # <-- Change filename if needed
img_np = np.array(img)
inverted = np.zeros_like(img_np)
# Process each pixel through the AXI4-Lite IP
for i in range(img_np.shape[0]):
for j in range(img_np.shape[1]):
ip.write(0x00, int(img_np[i, j])) # Write input pixel to register 0x00
ip.write(0x04, 1) # Pulse start by writing 1 to register 0x04
while ip.read(0x0C) == 0: # Wait for valid/ready flag at register 0x0C
pass
inv_pixel = ip.read(0x08) & 0xFF # Read output pixel from register 0x08 (mask to 8 bits)
inverted[i, j] = inv_pixel
# Display original and inverted images
plt.figure(figsize=(10,4))
plt.subplot(1,2,1)
plt.imshow(img_np, cmap='gray')
plt.title('Original')
plt.axis('off')
plt.subplot(1,2,2)
plt.imshow(inverted, cmap='gray')
plt.title('Inverted')
plt.axis('off')
plt.tight_layout()
plt.show()
# Optionally, save the inverted image

Image.fromarray(inverted).save('inverted_result.png')
614461446144

