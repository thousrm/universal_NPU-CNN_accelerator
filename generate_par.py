from keras.models import load_model
import keras
import numpy as np


img_rows = 28
img_cols = 28

model = load_model('model.h5')
weight_ori = model.get_weights()

images = keras.preprocessing.image.load_img("img/7.png", target_size=(28,28))
img_tensor = keras.preprocessing.image.img_to_array(images)

img_tensor = np.expand_dims(img_tensor, axis=0)

img_tensor.reshape(1, 28, 28, 3)

img_tensor = img_tensor[:,:,:,0]


weight0 = weight_ori[0]
bias0 = weight_ori[1]

binary_repr_vec = np.vectorize(np.binary_repr)

img_int = img_tensor[0,:,:].astype(int)
np.savetxt("verilog/input_map_hex.txt", img_int, delimiter="", fmt= '%02x')

wei0_int = (weight0[:,:,0,0]*256).astype(int)
np.savetxt("verilog/l0c0 weight.txt", np.vectorize(np.binary_repr)(wei0_int, 8), delimiter="\n", fmt= '%s')

bias0_int = (bias0*128).astype(np.int8)
np.savetxt("verilog/l0 bias.txt", np.vectorize(np.binary_repr)(bias0_int, 16), delimiter="\n", fmt= '%s')



weight1 = weight_ori[2]
weight1 = (weight1*256).astype(int)
weight1_bin = np.vectorize(np.binary_repr)(weight1, 8)


bias1 = weight_ori[3]
bias1 = (bias1*128).astype(int)
bias1_bin = np.vectorize(np.binary_repr)(bias1, 16)


np.savetxt("verilog/l2c0 weight.txt", weight1_bin[:,:,0,0], delimiter="\n", fmt= '%s')
np.savetxt("verilog/l2c1 weight.txt", weight1_bin[:,:,0,1], delimiter="\n", fmt= '%s')
np.savetxt("verilog/l2c2 weight.txt", weight1_bin[:,:,0,2], delimiter="\n", fmt= '%s')
np.savetxt("verilog/l2c3 weight.txt", weight1_bin[:,:,0,3], delimiter="\n", fmt= '%s')
np.savetxt("verilog/l2c4 weight.txt", weight1_bin[:,:,0,4], delimiter="\n", fmt= '%s')
np.savetxt("verilog/l2c5 weight.txt", weight1_bin[:,:,0,5], delimiter="\n", fmt= '%s')
np.savetxt("verilog/l2c6 weight.txt", weight1_bin[:,:,0,6], delimiter="\n", fmt= '%s')
np.savetxt("verilog/l2c7 weight.txt", weight1_bin[:,:,0,7], delimiter="\n", fmt= '%s')
np.savetxt("verilog/l2 bias.txt", bias1_bin, delimiter="\n", fmt= '%s')

