import matplotlib.pyplot as plt
from keras.models import load_model
import keras
import numpy as np

img_rows = 28
img_cols = 28

model = load_model('mymodel')
weight_ori = model.get_weights()

images = keras.preprocessing.image.load_img("img/7.png", target_size=(28,28))
img_tensor = keras.preprocessing.image.img_to_array(images)


img_tensor = np.expand_dims(img_tensor, axis=0)

img_tensor.reshape(1, 28, 28, 3)

plt.imshow(img_tensor[0,:,:,:]/255)
plt.show()

img_tensor = img_tensor[:,:,:,0]
img_tensor.reshape(28, 28, 1)
img_tensor = 255 - img_tensor

y_prob = model.predict(img_tensor)
predicted = y_prob.argmax(axis=-1)

print('The Answer by cpu is ', predicted)
print('and the possibility is ', y_prob)

layer4output00 = np.loadtxt('verilog/output_npu_l2c00.txt')
layer4output01 = np.loadtxt('verilog/output_npu_l2c01.txt')
layer4output02 = np.loadtxt('verilog/output_npu_l2c02.txt')
layer4output03 = np.loadtxt('verilog/output_npu_l2c03.txt')
layer4output04 = np.loadtxt('verilog/output_npu_l2c04.txt')
layer4output05 = np.loadtxt('verilog/output_npu_l2c05.txt')
layer4output06 = np.loadtxt('verilog/output_npu_l2c06.txt')
layer4output07 = np.loadtxt('verilog/output_npu_l2c07.txt')



layer4output = np.stack( (layer4output00, layer4output01, layer4output02, layer4output03, layer4output04, layer4output05, layer4output06, layer4output07), axis=1)
layer4output = layer4output/2
layer4output = layer4output.reshape(1,7,7,8)

layer4output[:,:,:,0] = np.transpose(layer4output[0,:,:,0])
layer4output[:,:,:,1] = np.transpose(layer4output[0,:,:,1])
layer4output[:,:,:,2] = np.transpose(layer4output[0,:,:,2])
layer4output[:,:,:,3] = np.transpose(layer4output[0,:,:,3])
layer4output[:,:,:,4] = np.transpose(layer4output[0,:,:,4])
layer4output[:,:,:,5] = np.transpose(layer4output[0,:,:,5])
layer4output[:,:,:,6] = np.transpose(layer4output[0,:,:,6])
layer4output[:,:,:,7] = np.transpose(layer4output[0,:,:,7])


model4 = keras.Model(inputs=model.get_layer(index = 5).input, outputs=model.get_layer(index = 9).output)
model4_output = model4.predict(layer4output)

predicted4 = model4_output.argmax(axis=-1)

print('The Answer by accelerator is ', predicted4)
print('and the possibility is ', model4_output)

"""
model04 = keras.Model(inputs=model.input, outputs=model.get_layer(index = 4).output)
model04_output = model04.predict(img_tensor)

print (layer4output[:,:,:,3])
print (model04_output[:,:,:,3].astype(int))

# weight_ori = model.get_weights()
# weight1 = weight_ori[2]
# weight1 = (weight1*256).astype(int)
# print(weight1)
"""