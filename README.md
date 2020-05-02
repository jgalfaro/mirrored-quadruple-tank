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
#### Figure 1. Quadruple-tank plant scenario. (a) Original scheme, based on based on Ref. <a href="https://doi.org/10.1109/87.845876">[DOI: 10.1109/87.845876].</a>, representing our (1,1)-resilient scheme. (b) Extended (1,2)-resilient scheme, with four additional sensors. (c) Extended (2,2)-resilient scheme, with two additional pumps and four additional sensors

### Simulation of Case 1.

The one-tank system has one level sensor and one outflow sensor. The
state of this system is recoverable if the level sensor or the outflow
sensor is attacked, but not both. Fig. 2(a,b), based on <a
href="https://github.com/jgalfaro/mirrored-quadruple-tank/tree/master/Simulations/matlab-code/case1-fig2a-fig2b">this
matlab code</a> shows that we can recover the state of the system from
the outflow sensor, in case of an attack is targeting the level
sensor.

![figure2](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig2.png)
#### Figure 2. Simulation of Case 1. <a href="https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Simulations/matlab-code/case1-fig2a-fig2b/main2a.m">Part (a)</a> plots the level in a one tank system under normal operation (solid blue line). In <a href="https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Simulations/matlab-code/case1-fig2a-fig2b/main2b.m">Part (b)</a>, and assuming solely the ultrasonic sensor is attacked, it is possible to track the level using the outflow sensor (solid red line).

### Simulation of Case 2.

The (1,1)-resilient system has only four levels sensors (one per
tank). When an adversary perpetrates an attack on these sensors, the
state of the system is not recoverable. Figs. 3(a) and 3(b), based on
<a
href="https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Simulations/matlab-code/case2-fig3a-fig3b/main.m">this
matlab code</a> show the levels in each tank (Part (a)), when the
system is not attacked; and the levels when an attack is perpetrated
(Part (b)). Since there is no non-attacked sensor type implementing an
injective function on its elements, the state is not recoverable.
Figs. 3(c) and 3(d), based on <a
href="https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Simulations/matlab-code/case2-fig3c-fig3d/main.m">this
matlab code</a>, show tanks levels in the (2,2)-resilient system. Part
(c) shows the tanks levels tracked with ultrasonic sensors. In Part
(d), an adversary spoofs actuators and manipulates solely ultrasonic
sensor signals (dashed lines). Part (d) shows that the actual levels
can be recovered using observations from outflow sensors.

![figure3](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig3.png)
#### Figure 3. Simulation of Case 2. <a href="https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Simulations/matlab-code/case2-fig3a-fig3b/main.m">In Part (a)</a>, tank levels are tracked with ultrasonic sensors in the (1,1)-resilient system. <a href="https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Simulations/matlab-code/case2-fig3a-fig3b/main.m">In Part (b)</a>, an adversary spoofs actuators and manipulates sensor signals such that they look as expected (dashed lines), although actual levels (solid lines) are different. The degree of resilience does not enable state recovery. In <a href="https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Simulations/matlab-code/case2-fig3c-fig3d/main.m">Part (c)</a>, tanks levels are tracked with ultrasonic sensors in the (2,2)-resilient system. In <a href="https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Simulations/matlab-code/case2-fig3c-fig3d/main.m">Part (d)</a>, an adversary spoofs actuators and manipulates solely ultrasonic sensor signals (dashed lines). Actual levels (solid lines) can be recovered using observations from outflow sensors.

### Simulation of Case 3.

With respect to the (1,2)-resilient system, Fig. 4 shows the plant
signals associated to the Case 3. The (1,2)-resilient system has eight
sensors (four ultrasonic sensors and four outflow meters) and two
actuators (Pumps 1 and 2). If only the ultrasonic level sensors (or
only the outflow meters sensors) are attacked, then the state is
recoverable. Fig. 4(a) shows the signals from the non-attacked level
sensors. When only one family of sensors is attacked (either the
ultrasonic or the outflow meters ones), then we can appreciate the
system can recover the state by using the non-attacked outflow
sensors, as shown in Fig. 4(b). Notice that if we were conducting the
full covert attack over the (2,2)- resilient system (cf. Fig. 1(c)
above), the controller will also be able to recover the system state,
using the additional pumps (Pumps 3 and 4), in a more optimal way, as
we will show below, in Fig. 7(c).


![figure4](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig4.png)
#### Figure 4. Simulation results associated with Case 3, with regard to the (1,2)-resilient design. In Part (a) we show the levels of the plant under normal operation (the ultrasonic level sensors are not under attack). In Part (b), attack mode, and assuming solely the ultrasonic sensor are attacked, we track the level using the outflow rate meters.

### Simulation of Case 4.

Case 4 is simulated in Fig. 5. Inflows to Tanks 1, 2, 3 and 4 are
shown by pump number. In Part (a), because they are variable flow,
Pumps 1 and 2 can achieve inflows that are the same or below the
inflows achievable by fixed-flow Pumps 3 and 4. When inflows are below
what fixed-flow pumps can achieve, they can only be attributed to
variable-flow pumps. When either Pumps 1 and 2 operate or Pumps 3 and
4 operate, we can tell which pair is involved. Discrimination is
possible. Part (b) shows a condition where Pumps 1 and 2 are operated
in ranges above what fixed-flow pumps can achieve. For example, an
adversary adds voltages to signals and provokes inflow increases. Such
a condition is achievable operating Pumps 1 and 2 alone, or also in
combination with Pumps 3 and 4. For this example, discrimination might
be impossible.


![figure5](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig5.png)
#### Figure 5. Simulation of Case 4. Plots show inflows to Tanks 1, 2, 3 and 4, attributed to each pump. In Part (a), variable-flow pumps push liquid into tanks at rates below what fixed-flow pumps can do. In Part (b), variable-flow pumps push liquid into tanks  at rates above what fixed-flow pumps can do.

### Simulation of Case 5.

Fig. 6(a) shows the input voltages u<sub>1</sub>, and u<sub>2</sub>,
respectively applied to Pump 1 and Pump 2. The dashed line represents
the attack signal used by an adversary. Fig. 6(b) represents the
levels in Tank 1 and Tank 4, when the attack starts at T=500
seconds.

![figure6](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig6.png)
#### Figure 6. Simulation results of Case 5. As a function of time, Part (a) shows values of input signals u<sub>i</sub>[1] (solid read), u<sub>i</sub>[2] (solid blue) and spoofed input signal u<sub>i</sub><sup>a</sup>[1] (dashed red). In Part (a), the adversary manipulates the ultrasonic sensor signal such that they look as expected (dashed) lines. Actual levels (solid lines) are recovered using the outflow sensors. Assuming inflows are below what fixed-flow pumps can achieved, it is possible to determine and track the values of the adversary signal u<sub>i</sub><sup>a</sup>[1].


### Interpretation of results.

Fig. 7 provides an interpretation of all our simulations. We consider
that the performance of a system is the capacity to maintain expected
level in tanks. Hence, the performance degradation corresponds to the
deviation from the expected levels. The larger the deviation, the
lower the performance. In Fig. 7, we represent these deviations in
percentages.

![figure7](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/FIG/Fig7.png)
#### Figure 7. Performance evolution of the (1,1)-, (1,2)- and (2,2)-resilient systems, when they are confronted to a covert attack. Performance degradation corresponds to the deviation from  their expected levels. The larger the deviation, the lower the performance. The (1,1)-resilient system, with no recovery capability, experiences a performance drop. In contrast, the (1,2)- and (2,2)-resilient systems recover from the attack. The (1,2)-resilient system recovers with graceful degradation, due to the absence of actuator redundancy, while the (2,2)-resilient system fully recovers.

Figs. 7(a), (b), and (c) respectively show the performance of the
(1,1)-, (1,2)- and (2,2)-resilient systems, when attacks are
perpetrated. When a system is not attacked, performance is 100%.
Attacks start at T=500 seconds. The adversary manipulates inputs to
drive more liquid in the Tanks 1 and 4. The consequence of the attack
is a deviation from the expected system state. Quantifying this
deviation, we obtain a percentage of performance loss. When the
(1,1)-resilient system (with no recovery capability) is under attack,
it experiences a performance drop. In the (1,2)- and (2,2)-resilient
systems, it is possible to mitigate the effects of attacks and bounce
back. As shown in Figs. 7(b) and 7(c), respectively, the
(1,2)-resilient system recovers with graceful degradation, due to the
absence of actuator redundancy, while the (2,2)-resilient system fully
recovers.
