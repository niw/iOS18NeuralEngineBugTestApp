iOS 18 Neural Engine Bug
========================

This is a minium iOS application project to reproduce a bug related to predicate
a specific model on Neural Engine on iOS 18 devices.

The bug is reported as FB15290156.


Details
-------

If there is a model that has following pattern, when predication is executed on
Neural Engine, likely the result would cause a zero value in the output tensor.

1. Convolution
2. Pooling
3. Transpose
4. Reshape
5. Cast to fp32

This is confirmed on iOS 18.0 (22A3354) on iPhone 15 Pro but it could cause
on the other devices and it may not reproducible on other SoC devices such as
iPad with M1 or iOS 18.1 beta versions.
