Michael Sikora <m.sikora@uky.edu>
2018.05.21

Graphic User Interface for simulating the Steered Response Coherent Power
with dynamic platform arrays and analyzing the resulting performance.

INTRODUCTION
The platforms of interest will be flat 3D printed models to hold electret
microphones. The models will sit on pan-tilt mounts moved by two micro-servos. 

VARIABLES - stored as vars.label{nn} and vars.value{nn}
1.Mics per platform
2.Number of platforms
3.Distance to source (only used for equidistant setups)
4.Platform angle
5.Distance between mics ( secant between adjacent microphones on a platform)
6.Source type
    -CHIRP
    -MOZART
    -SINE
    -WHITE NOISE
7.Source locations
    -CENTERED
    -CHOOSE (CLICKS)
    -RANDOM XY
8.Platform locations
    -EQUIDISTANT
    -CHOOSE (CLICKS)
    -RANDOM XY

vars.independent - string keyword to distinguish independent variable
vars.sigpos - xyz coordinates of source posititions
vars.setup - string keyword to distinguish platform arrangement
    -EQUIDISTANT
    -CHOSEN
    -RANDOM


    