Supplementary Material for Simulation and Experiment Cyber-Physical
Resilience Work using the Quadruple Tank Scenario
===

We reused existing code from:

<a href="https://github.com/karrocon/pcsmatlab">PCSMATLAB</a>,
<a
href="https://github.com/dry3ss/IEC-608670-5-104-Grovepi">IEC-608670-5-104-Grovepi</a>,
<a href="https://github.com/dry3ss/IEC-104_MitM_utilities">IEC-104_MitM_utilities</a>,
and <a href="https://github.com/dry3ss/ARP_detox">ARP Detox</a>.

and the Quadruple Tank Scenario by K. H. Johansson (cf. Ref. <a href="https://doi.org/10.1109/87.845876">[DOI: 10.1109/87.845876]</a>).

## Simulated Systems

![figure1](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig1.png)
#### Figure 1. Quadruple-tank plant scenario. (a) Original scheme,
based on based on Ref. <a href="https://doi.org/10.1109/87.845876">[DOI: 10.1109/87.845876].</a>,
representing our (1,1)-resilient scheme. (b) Extended (1,2)-resilient scheme, with four
additional sensors. (c) Extended (2,2)-resilient scheme, with two additional pumps and
four additional sensors

### Simulation of Case 1. The one-tank system has one level sensor and
one out ow sensor. The state of this system is recoverable if the
level sensor or the out ow sensor is attacked, but not both. Fig. 2(a,b)
shows that we can recover the state of the system from the out
ow sensor, in case of an attack is targeting the level sensor.

![figure2](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig2.png)
#### Figure 2. Simulation of Case 1. Part (a) plots the level in a one tank system under normal
operation (solid blue line). In Part (b), and assuming solely the ultrasonic sensor is
attacked, it is possible to track the level using the outflow sensor (solid red line).

### Simulation of Case 2. The (1,1)-resilient system has only four
levels sensors (one per tank). When an adversary perpetrates an attack
on these sensors, the state of the system is not recoverable. Fig. 3
(a) shows the levels in each tank, when the system is not attacked.
Fig. 2 (b) shows the levels when an attack is perpetrated. Since there
is no non-attacked sensor type implementing an injective function on
its elements, the state is not recoverable.

![figure3](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig3.png)
#### Figure 3. Simulation of Case 2. In Part (a), tank levels are
tracked with ultrasonic sensors in the (1,1)-resilient system. In
Part (b) an adversary spoofs actuators and manipulates sensor signals
such that they look as expected (dashed lines), although actual levels
(solid lines) are different. The degree of resilience does not enable
state recovery. In Part (c), tanks levels are tracked with ultrasonic
sensors in the (2,2)-resilient system. In Part (d), an adversary
spoofs actuators and manipulates solely ultrasonic sensor signals
(dashed lines). Actual levels (solid lines) can be recovered using
observations from out ow sensors.

### Simulation of Case 3. With respect to the (1,2)-resilient system,
Fig. 4 shows the plant signals associated to the Case 3. The
(1,2)-resilient system has eight sensors (four ultrasonic sensors and
four outflow meters) and two actuators (Pumps 1 and 2). If only the
ultrasonic level sensors (or only the outflow meters sensors) are
attacked, then the state is recoverable. Fig. 4(a) shows the signals
from the non-attacked level sensors. When only one family of sensors
is attacked (either the ultrasonic or the outflow meters ones), then
we can appreciate the system can recover the state by using the
non-attacked outflow sensors, as shown in Fig. 4(b). Notice that if we
were conducting the full covert attack over the (2,2)- resilient
system (cf. Fig. 1(c) above), the controller will also be able to
recover the system state, using the additional pumps (Pumps 3 and 4),
in a more optimal way, as we will show below, in Fig. 7(c).


![figure4](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig4.png)
#### Figure 4. Simulation results associated with Case 3, with regard
to the (1,2)-resilient design. In Part (a) we show the levels of the
plant under normal operation (the ultrasonic level sensors are not
under attack). In Part (b), attack mode, and assuming solely the
ultrasonic sensor are attacked, we track the level using the outflow
rate meters.
