addpath(pwd);
addpath('PCS/Control');
addpath('PCS/Hardware');
addpath('PCS/Network');
addpath('PCS/Process');
addpath('PCS/Utils');
addpath('PCS/');
addpath('lib/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PI control of a quadruple-tank process %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Quadruple-tank process
a = [0.071 0.057 0.071 0.057];
A = [28 32 28 32 250];
g = 981;
gamma = [0.7 0.6];
k = [3.33 3.35];

process = QuadrupleTank12(a, A, g, gamma, k);
process_attacked12 = QuadrupleTank12_performance(a, A, g, gamma, k);

% PI controller
K = [0.3816; 0.5058];
Ti = [62.9557; 91.3960];

controller = PI(K, Ti);

% Create simulation
simulation = Simulation(controller, process);
simulation_attacked12 = Simulation(controller, process_attacked12);

% Define initial states and time interval
simulation.xc0 = [31.4347; 33.4446];
simulation.x0 = [12.4; 12.7; 1.5919; 1.4551; 20];
simulation.t0 = 0;
simulation.tend = 3000;

simulation_attacked12.xc0 = [31.4347; 33.4446];
simulation_attacked12.x0 = [12.4; 12.7; 1.5919; 1.4551; 20];
simulation_attacked12.t0 = 0;
simulation_attacked12.tend = 3000;

% Define set-point conditions
simulation.set_preloaded_reference(1, 15);
simulation.set_preloaded_reference(2, 12.7);

simulation_attacked12.set_preloaded_reference(1, 15);
simulation_attacked12.set_preloaded_reference(2, 12.7);

% Execute simulation
data = simulation.run();
data_attacked12 = simulation_attacked12.run();



%-----------------
% LINEARIZATION
%-----------------

%--------
% Tank 1
%--------

INTERPRET_12_T1_x = 0:0.1:2999;
INTERPRET_12_T1_y = interp1(data.t, data.y(1,:), INTERPRET_12_T1_x);

INTERPRET_12_T1_a_x = 0:0.1:2999;
INTERPRET_12_T1_a_y = interp1(data_attacked12.t, data_attacked12.y(1,:), INTERPRET_12_T1_a_x);

PERF_T1 = -(abs(INTERPRET_12_T1_y-INTERPRET_12_T1_a_y));


%--------
% Tank 2
%--------

INTERPRET_12_T2_x = 0:0.1:2999;
INTERPRET_12_T2_y = interp1(data.t, data.y(2,:), INTERPRET_12_T2_x);

INTERPRET_12_T2_a_x = 0:0.1:2999;
INTERPRET_12_T2_a_y = interp1(data_attacked12.t, data_attacked12.y(2,:), INTERPRET_12_T2_a_x);

PERF_T2 = -(abs(INTERPRET_12_T2_y-INTERPRET_12_T2_a_y));


%--------
% Tank 3
%--------

INTERPRET_12_T3_x = 0:0.1:2999;
INTERPRET_12_T3_y = interp1(data.t, data.y(3,:), INTERPRET_12_T3_x);

INTERPRET_12_T3_a_x = 0:0.1:2999;
INTERPRET_12_T3_a_y = interp1(data_attacked12.t, data_attacked12.y(3,:), INTERPRET_12_T3_a_x);

PERF_T3 = -(INTERPRET_12_T3_y-INTERPRET_12_T3_a_y);


%--------
% Tank 4
%--------

INTERPRET_12_T4_x = 0:0.1:2999;
INTERPRET_12_T4_y = interp1(data.t, data.y(4,:), INTERPRET_12_T4_x);

INTERPRET_12_T4_a_x = 0:0.1:2999;
INTERPRET_12_T4_a_y = interp1(data_attacked12.t, data_attacked12.y(4,:), INTERPRET_12_T4_a_x);

PERF_T4 = -(INTERPRET_12_T4_y-INTERPRET_12_T4_a_y);



%------------------
% Water reservoir
%------------------

INTERPRET_12_WR_x = 0:0.1:2999;
INTERPRET_12_WR_y = interp1(data.t, data.x(5,:), INTERPRET_12_WR_x);

INTERPRET_12_WR_a_x = 0:0.1:2999;
INTERPRET_12_WR_a_y = interp1(data_attacked12.t, data_attacked12.x(5,:), INTERPRET_12_WR_a_x);

PERF_WR = -(INTERPRET_12_WR_y-INTERPRET_12_WR_a_y);

%--------------------------
% Fig.7(b) (1,2)-resilient
%--------------------------


figure
plot(INTERPRET_12_T1_x, smooth(((PERF_T1/10.19)*100+(PERF_T2/2.331)*100+(PERF_T3/8.521)*100+(PERF_T4/2.01)*100+(PERF_WR/20.86)*100)/5, 0.015, 'lowess'),'b', 'LineWidth',1.5);
xlim([0 1500]);
ylim([-120 20]);
xlabel('Time (s)');
ylabel('Performance (%)');
ax = gca;
ay = gca;
ay.YTickLabel = ({' ', '0', '20', '40', '60', '80', '100', ' '});
grid on;


