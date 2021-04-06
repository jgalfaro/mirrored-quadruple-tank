Supplementary Material for Switched-based Control 
Testbed to Assure Cyber-Physical Resilience by Design
===

### Mariana Segovia, Institut Polytechnique de Paris, Telecom SudParis, France.

### Jose Rubio-Hernan, Institut Polytechnique de Paris, Telecom SudParis, France.

### Ana Rosa Cavalli , Institut Polytechnique de Paris, Telecom SudParis, France.

### Joaquin Garcia-Alfaro, Institut Polytechnique de Paris, Telecom SudParis, France.

## Abstract

Cyber-Physical Systems (CPS) integrate control systems engineering, computer science, 
and networking to control a physical process. The main challenge after detecting malicious 
actions in a CPS is to choose the correct reaction that the system has to carry out. 

We propose a deployment platform for cyber-physical configurations evaluation to satisfy 
cyber-physical resilience properties. Experimental testbeds are crucial to analyze new 
proposals. For this reason, we discuss some actions for the development of a replicable 
and affordable cyber-physical testbed for training and research. The architecture is based 
on real-world components. This solution combines diverse parameters that come from cyber 
and physical layer.

## Keywords

Cyber-Physical Systems, Resilience, Testbed, Cyber-Physical Adversary.

## Disclaimer

We reused existing code from:

<a href="https://github.com/karrocon/pcsmatlab">PCSMATLAB</a>,
<a
href="https://github.com/dry3ss/IEC-608670-5-104-Grovepi">IEC-608670-5-104-Grovepi</a>,
<a href="https://github.com/dry3ss/IEC-104_MitM_utilities">IEC-104_MitM_utilities</a>,
and <a href="https://github.com/dry3ss/ARP_detox">ARP Detox</a>.

and the Quadruple Tank Scenario by K. H. Johansson (cf. Ref. <a href="https://doi.org/10.1109/87.845876">[DOI: 10.1109/87.845876]</a>).

## Quadruple-tank Plant

![figure1-scheme](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/fourtanks.png)
#### Figure 1. Quadruple-tank Plant Scheme, based on Ref. <a href="https://doi.org/10.1109/87.845876">[DOI: 10.1109/87.845876].</a>

[![figure2a-video](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/testbed.png)](https://youtu.be/FZg0F96bYhk) [![figure2c-video](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/testbed3.png)](https://youtu.be/FZg0F96bYhk) [![figure2b-video](https://github.com/jgalfaro/mirrored-quadruple-tank/blob/master/Figures/testbed2.png)](https://youtu.be/FZg0F96bYhk)
#### Figure 2. Current SCADA (Supervisory Control And Data Acquisition) Testbed (videocapture <a href="https://youtu.be/FZg0F96bYhk">here</a>).


