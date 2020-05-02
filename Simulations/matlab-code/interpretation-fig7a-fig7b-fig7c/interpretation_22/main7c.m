addpath(pwd);
addpath('PCS/Control');
addpath('PCS/Hardware');
addpath('PCS/Network');
addpath('PCS/Process');
addpath('PCS/Utils');
addpath('PCS/');
addpath('lib/');%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PI control of a quadruple-tank process %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Quadruple-tank process
a = [0.071 0.057 0.071 0.057];
A = [28 32 28 32 250];
g = 981;
gamma = [0.7 0.6];
k = [3.33 3.35];
n = [0 0];% n = [0.07 0.06]; % valve coeff
lambda = [0 0];% lambda = [0.1 0.2]; % cm^3 / V second
w = [0 0];% w = [0.15 0.23]; % voltage

process = QuadrupleTank22(a, A, g, gamma, k, n, lambda, w);
process_attacked22 = QuadrupleTank22_performance(a, A, g, gamma, k, n, lambda, w);


% PI controller
K = [0.3816; 0.5058; 0.3816; 0.5058]; % 0.015; 1.25
Ti = [62.9557; 91.3960; 62.9557; 91.3960];

controller = PI(K, Ti);

% Create simulation
simulation = Simulation(controller, process);
simulation_attacked22 = Simulation(controller, process_attacked22);

% Define initial states and time interval
simulation.xc0 = [31.4347; 33.4446; 31.4347; 33.4446];
simulation.x0 = [12.4; 12.7; 1.5919; 1.4551; 20];
simulation.t0 = 0;
simulation.tend = 4000;

simulation_attacked22.xc0 = [31.4347; 33.4446; 31.4347; 33.4446];
simulation_attacked22.x0 = [12.4; 12.7; 1.5919; 1.4551; 20];
simulation_attacked22.t0 = 0;
simulation_attacked22.tend = 4000;

% Define set-point conditions
simulation.set_preloaded_reference(1, 15);
simulation.set_preloaded_reference(2, 12.7);

simulation_attacked22.set_preloaded_reference(1, 15);
simulation_attacked22.set_preloaded_reference(2, 12.7);


% Execute simulation
data = simulation.run();
data_attacked22 = simulation_attacked22.run();



%-----------------
% LINEARIZATION
%-----------------

%--------
% Tank 1
%--------

INTERPRET_22_T1_x = 0:0.1:3999;
INTERPRET_22_T1_y = interp1(data.t, data.y(1,:), INTERPRET_22_T1_x);

INTERPRET_22_T1_a_x = 0:0.1:3999;
INTERPRET_22_T1_a_y = interp1(data_attacked22.t, data_attacked22.y(1,:), INTERPRET_22_T1_a_x);

PERF_T1 = -(abs(INTERPRET_22_T1_y-INTERPRET_22_T1_a_y));


%--------
% Tank 2
%--------

INTERPRET_22_T2_x = 0:0.1:3999;
INTERPRET_22_T2_y = interp1(data.t, data.y(2,:), INTERPRET_22_T2_x);

INTERPRET_22_T2_a_x = 0:0.1:3999;
INTERPRET_22_T2_a_y = interp1(data_attacked22.t, data_attacked22.y(2,:), INTERPRET_22_T2_a_x);

PERF_T2 = -(abs(INTERPRET_22_T2_y-INTERPRET_22_T2_a_y));


%--------
% Tank 3
%--------

INTERPRET_22_T3_x = 0:0.1:3999;
INTERPRET_22_T3_y = interp1(data.t, data.y(3,:), INTERPRET_22_T3_x);

INTERPRET_22_T3_a_x = 0:0.1:3999;
INTERPRET_22_T3_a_y = interp1(data_attacked22.t, data_attacked22.y(3,:), INTERPRET_22_T3_a_x);

PERF_T3 = -(INTERPRET_22_T3_y-INTERPRET_22_T3_a_y);


%--------
% Tank 4
%--------

INTERPRET_22_T4_x = 0:0.1:3999;
INTERPRET_22_T4_y = interp1(data.t, data.y(4,:), INTERPRET_22_T4_x);

INTERPRET_22_T4_a_x = 0:0.1:3999;
INTERPRET_22_T4_a_y = interp1(data_attacked22.t, data_attacked22.y(4,:), INTERPRET_22_T4_a_x);

PERF_T4 = -(INTERPRET_22_T4_y-INTERPRET_22_T4_a_y);


%-----------------
% Water reservoir
%-----------------

INTERPRET_22_WR_x = 0:0.1:3999;
INTERPRET_22_WR_y = interp1(data.t, data.x(5,:), INTERPRET_22_WR_x);

INTERPRET_22_WR_a_x = 0:0.1:3999;
INTERPRET_22_WR_a_y = interp1(data_attacked22.t, data_attacked22.x(5,:), INTERPRET_22_WR_a_x);

PERF_WR = -(INTERPRET_22_WR_y-INTERPRET_22_WR_a_y);


%--------------------------
% Fig.7(c) (2,2)-resilient
%--------------------------

figure
plot(INTERPRET_22_T1_x, smooth(((PERF_T1/10.19)*100+(PERF_T2/2.331)*100+(PERF_T3/8.521)*100+(PERF_T4/2.01)*100+(PERF_WR/20.86)*100)/5, 0.015, 'lowess'),'b', 'Linewidth', 1.5); 
xlim([0 1500]);
ylim([-120 20]);
xlabel('Time (s)');
ylabel('Performance (%)');
ax = gca;
ay = gca;
ay.YTickLabel = ({' ', '0', '20', '40', '60', '80', '100', ' '});
grid on;