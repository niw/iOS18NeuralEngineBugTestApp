iOS 18 Neural Engine Bug
========================

This is a minium iOS application project to reproduce a CoreML bug caused with
a specific model on Neural Engine on iOS 18 devices.

The bug is reported as FB15290156.


Details
-------

If there is a model that has following pattern, when predication is executed on
Neural Engine, likely the result would be broken and have many zero values
in the output tensor.

1. Convolution
2. Pooling
3. Transpose
4. Reshape
5. Cast to fp32

This is confirmed on iOS 18.0 (22A3354) and iOS 18.1 beta on iPhone 15 Pro,
but it may be reproducible on the other devices or it may not on other
iOS and devices combinations such as iOS 18.1 beta on iPad with M1 versions.
