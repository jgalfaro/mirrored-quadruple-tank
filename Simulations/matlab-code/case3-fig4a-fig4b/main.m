addpath(pwd);
addpath('PCS/Control');
addpath('PCS/Hardware');
addpath('PCS/Network');
addpath('PCS/Process');
addpath('PCS/Utils');
addpath('PCS/');
addpath('lib/');

disp('PCS classes successfully installed.');

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
process_attacked12 = QuadrupleTank12_attacked(a, A, g, gamma, k); % a, A, g, [0.25 0.6], [1.33 3.35]

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
simulation_attacked12.x0 = [12.4; 12.7; 1.5919; 1.4551; 20; 12.4; 12.7; 1.5919; 1.4551; 20];
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

%-----
% T1    % N : y = 10.19
%-----

INTERPRET_12_T1_x = 0:0.1:2999;
INTERPRET_12_T1_y = interp1(data.t, data.y(1,:), INTERPRET_12_T1_x);

INTERPRET_12_T1_a_x = 0:0.1:2999;
INTERPRET_12_T1_a_y = interp1(data_attacked12.t, data_attacked12.y(1,:), INTERPRET_12_T1_a_x);

PERF_T1 = -(abs(INTERPRET_12_T1_y-INTERPRET_12_T1_a_y));


%-----
% T2    % N : y = 2.331
%-----

INTERPRET_12_T2_x = 0:0.1:2999;
INTERPRET_12_T2_y = interp1(data.t, data.y(2,:), INTERPRET_12_T2_x);

INTERPRET_12_T2_a_x = 0:0.1:2999;
INTERPRET_12_T2_a_y = interp1(data_attacked12.t, data_attacked12.y(2,:), INTERPRET_12_T2_a_x);

PERF_T2 = -(abs(INTERPRET_12_T2_y-INTERPRET_12_T2_a_y));


%-----
% T3    % N : y = 8.521
%-----

INTERPRET_12_T3_x = 0:0.1:2999;
INTERPRET_12_T3_y = interp1(data.t, data.y(3,:), INTERPRET_12_T3_x);

INTERPRET_12_T3_a_x = 0:0.1:2999;
INTERPRET_12_T3_a_y = interp1(data_attacked12.t, data_attacked12.y(3,:), INTERPRET_12_T3_a_x);

PERF_T3 = -(INTERPRET_12_T3_y-INTERPRET_12_T3_a_y);


%-----
% T4    % N : y = 2.01
%-----

INTERPRET_12_T4_x = 0:0.1:2999;
INTERPRET_12_T4_y = interp1(data.t, data.y(4,:), INTERPRET_12_T4_x);

INTERPRET_12_T4_a_x = 0:0.1:2999;
INTERPRET_12_T4_a_y = interp1(data_attacked12.t, data_attacked12.y(4,:), INTERPRET_12_T4_a_x);

PERF_T4 = -(INTERPRET_12_T4_y-INTERPRET_12_T4_a_y);


%-----
% WR    % N : y = 20.86
%-----

INTERPRET_12_WR_x = 0:0.1:2999;
INTERPRET_12_WR_y = interp1(data.t, data.x(5,:), INTERPRET_12_WR_x);

INTERPRET_12_WR_a_x = 0:0.1:2999;
INTERPRET_12_WR_a_y = interp1(data_attacked12.t, data_attacked12.x(5,:), INTERPRET_12_WR_a_x);

PERF_WR = -(INTERPRET_12_WR_y-INTERPRET_12_WR_a_y);



%----------
% SUM PERF
%----------


%----------------------------------
% CASE 3 Fig.4(b) (1,2)-resilient
%----------------------------------

figure
plot(data_attacked12.t, smooth(data_attacked12.x(1,:), 0.005, 'lowess'), 'r', 'Linewidth', 0.9); hold on;
plot(data.t, data.x(1,:), 'r--', 'Linewidth', 1.5); hold on;
plot(data_attacked12.t, smooth(data_attacked12.x(2,:), 0.005, 'lowess'), 'm', 'Linewidth', 0.9); hold on;
plot(data.t, data.x(2,:), 'm--', 'Linewidth', 1.5); hold on;
plot(data_attacked12.t, smooth(data_attacked12.x(3,:), 0.005, 'lowess'), 'b', 'Linewidth', 0.9); hold on;
plot(data.t, data.x(3,:), 'b--',  'Linewidth', 1.5); hold on;
plot(data_attacked12.t, smooth(data_attacked12.x(4,:), 0.005, 'lowess'), 'k', 'Linewidth', 0.9); hold on;
plot(data.t, data.x(4,:), 'k--',  'Linewidth', 1.5);
title('System (1,2)-resilient');
legend({'Level Tank 1 (Attacked)', 'Level Tank 1 (Expected)', 'Level Tank 2 (Attacked)', 'Level Tank 2 (Expected)', 'Level Tank 3 (Attacked)', 'Level Tank 3 (Expected)','Level Tank 4 (Attacked)', 'Level Tank 4 (Expected)'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Level (cm^3)');


%------------------------------------------------
% CASE 3 Fig.4(a) (1,2)-resilient, under attack
%------------------------------------------------

figure
plot(data.t, data.y(1,:), 'r', 'Linewidth', 0.9); hold on;
plot(data.t, data.y(3,:), 'm', 'Linewidth', 0.9); hold on;
plot(data.t, data.y(5,:), 'b',  'Linewidth', 0.9); hold on;
plot(data.t, data.y(7,:), 'k',  'Linewidth', 0.9);
title('System (1,2)-resilient');
legend({'Level Tank 1', 'Level Tank 2', 'Level Tank 3', 'Level Tank 4'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Level (cm^3)');