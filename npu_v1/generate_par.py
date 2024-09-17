from keras.models import load_model
import keras
import numpy as np

print(keras.__version__)

img_rows = 28
img_cols = 28

model = load_model('mymodel')
weight_ori = model.get_weights()

images = keras.preprocessing.image.load_img("img/7.png", target_size=(28,28))
img_tensor = keras.preprocessing.image.img_to_array(images)

img_tensor = np.expand_dims(img_tensor, axis=0)

img_tensor.reshape(1, 28, 28, 3)

img_tensor = img_tensor[:,:,:,0]
img_tensor = 255 - img_tensor

weight0 = weight_ori[0]
weight0 = (weight0*256).astype(int)
weight0_bin = np.vectorize(np.binary_repr)(weight0, 8)

weightl0 = np.concatenate((weight0_bin[:,:,0,0], [ ["00000000","00000000","00000000"], ["00000000","00000000","00000000"], ["00000000","00000000","00000000"]]), axis=0)
weightl0 = np.concatenate((weightl0, [ ["00000000","00000000","00000000"], ["00000000","00000000","00000000"], ["00000000","00000000","00000000"]]), axis=0)
weightl0 = np.concatenate((weightl0, [ ["00000000","00000000","00000000"], ["00000000","00000000","00000000"], ["00000000","00000000","00000000"]]), axis=0)
weightl0 = np.concatenate((weightl0, [ ["00000000","00000000","00000000"], ["00000000","00000000","00000000"], ["00000000","00000000","00000000"]]), axis=0)
weightl0 = np.concatenate((weightl0, [ ["00000000","00000000","00000000"], ["00000000","00000000","00000000"], ["00000000","00000000","00000000"]]), axis=0)
weightl0 = np.concatenate((weightl0, [ ["00000000","00000000","00000000"], ["00000000","00000000","00000000"], ["00000000","00000000","00000000"]]), axis=0)
weightl0 = np.concatenate((weightl0, [ ["00000000","00000000","00000000"], ["00000000","00000000","00000000"], ["00000000","00000000","00000000"]]), axis=0)

bias0 = weight_ori[1]
bias0 = np.append(bias0, 0)
bias0 = (bias0*128).astype(int)
bias0_bin = np.vectorize(np.binary_repr)(bias0, 16)


img_int = img_tensor[0,:,:]/2
img_int = img_int.astype(int)
img_int_bin = np.vectorize(np.binary_repr)(img_int, 8)

np.savetxt("verilog/input_npu.txt", np.transpose(img_int_bin), delimiter="\n", fmt= '%s')
np.savetxt("verilog/l0 weight.txt", weightl0, delimiter="\n", fmt= '%s')
np.savetxt("verilog/l0 bias.txt", bias0_bin, delimiter="\n", fmt= '%s')


weight1 = weight_ori[2]
weight1 = (weight1*256).astype(int)
weight1_bin = np.vectorize(np.binary_repr)(weight1, 8)


bias1 = weight_ori[3]
bias1 = (bias1*128).astype(int)
bias1_bin = np.vectorize(np.binary_repr)(bias1, 16)

weightl1 = np.concatenate((weight1_bin[:,:,0,0], weight1_bin[:,:,0,1]), axis=0)
weightl1 = np.concatenate((weightl1, weight1_bin[:,:,0,2]), axis=0)
weightl1 = np.concatenate((weightl1, weight1_bin[:,:,0,3]), axis=0)
weightl1 = np.concatenate((weightl1, weight1_bin[:,:,0,4]), axis=0)
weightl1 = np.concatenate((weightl1, weight1_bin[:,:,0,5]), axis=0)
weightl1 = np.concatenate((weightl1, weight1_bin[:,:,0,6]), axis=0)
weightl1 = np.concatenate((weightl1, weight1_bin[:,:,0,7]), axis=0)

np.savetxt("verilog/l2 weight.txt", weightl1, delimiter="\n", fmt= '%s')

np.savetxt("verilog/l2 bias.txt", bias1_bin, delimiter="\n", fmt= '%s')

