# Universal_NPU-CNN_Accelerator
### hardware design of universal NPU (CNN accelerator) for various convolution neural networks

It can perform various cnns by calculating convolution for multiple clock cycles.

see here [https://velog.io/@hyal/%EB%B2%94%EC%9A%A9%EC%A0%81%EC%9D%B8-NPU-%EA%B0%9C%EB%B0%9C%EA%B8%B00-%EB%93%A4%EC%96%B4%EA%B0%80%EA%B8%B0-%EC%95%9E%EC%84%9C](https://velog.io/@hyal/series/%EB%B2%94%EC%9A%A9%EC%A0%81%EC%9D%B8-NPU-%EA%B0%9C%EB%B0%9C%EA%B8%B0) (korean)


There are many modules for same function. This is because, I don't have any synthesis tool(vivado is not useful for asic design), so, I can't determine which is most efficient.

If you have suitable tools, such as design compiler or else, please give me timing, area and power reports of modules. It will be very helpful.

<br/>

---
# Descripton

### Mechanism
It'

 <br/> 

### Input

|Input|Description|
|:---|:---|
|in|Port for input feature map. Each input data is 8bit, and this port receives 9 input datas every clock cycle.|
|weight|Port for weights of filters. Each weight is 8bit, and this port receives 9*8 weights every clock cycle. <br/> But it can only receive 9 weights per filter in a clock cycle.|
|bias|Port for biases of filters. Each bias is 16bit, and this port receives 8 biases every clock cycle.|
|bound_level|Port for setting a maximum value and step size of data. <br/> output (bound_level=n) = output (bound_level=0) * 2^n |
|step|Port for setting the period for convolution. <br/> If you set step=2, processing_element module will compute the convolution for 3 clock cycles, <br/>  so it can be used to compute a filter with 27 weights. |
|en|Input data validation port|
|en_relu|Port for enabling relu function|
|en_mp|Port for enabling max pooling function|

 <br/> 
 
### Module
dd



---
# Usage
1. run generate_par.py (I use pycharm)
2. simulate tb_ap
3. run predict.py

If you want to use this module for other cnn model, you have to edit tb_ap for it.

Because control part is not implemented yet, so it can't be done automatically.

<br/>

### CNN Model

<br/>

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/932f9015-8a5c-491c-b11b-26dd91d5f754)

<br/>
layer0~3 are calculated by the accelerator.



---
# Architecture

### NPU & Arithmetic_part (overall structure)

![npu](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/ae880dd7-c8e4-4abe-a55a-8ab0d594dfb2)

&nbsp;
<br/>
<br/>

### arithmetic_core

<img width="627" alt="ac" src="https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/f8caeed0-95ff-4824-aa35-fe35c83ffef8">

&nbsp;
<br/>
<br/>

### processing_element

<img width="588" alt="pe0" src="https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/425ce009-53be-417a-90cd-fa29df127c4a">

&nbsp;
<br/>
<br/>

### processing_element_mod

<img width="588" alt="pe1" src="https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/6258036d-11b6-40ce-88cd-592609f57fd4">

&nbsp;
<br/>
<br/>

### multiplier

![multiplier](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/61ab435a-f7a7-4598-a08d-5bc963d8a909)

&nbsp;
<br/>
<br/>

### Relu

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/d0748433-32b7-4fa2-b8cb-4f1216470b67)

&nbsp;
<br/>
<br/>

### maxpooling

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/b0c27dd5-766b-4336-b7a8-0523e284bb66)

&nbsp;
<br/>
<br/>


















