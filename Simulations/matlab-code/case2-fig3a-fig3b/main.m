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

process = QuadrupleTankReservoir(a, A, g, gamma, k);
process_attacked11 = QuadrupleTankReservoir_attacked(a, A, g, gamma, k);


% PI controller
K = [0.3816; 0.5058];
Ti = [62.9557; 91.3960];

controller = PI(K, Ti);

% Create simulation
simulation = Simulation(controller, process);
simulation_attacked11 = Simulation(controller, process_attacked11);


% Define initial states and time interval
simulation.xc0 = [31.4347; 33.4446];
simulation.x0 = [12.4; 12.7; 1.5919; 1.4551; 20];
simulation.t0 = 0;
simulation.tend = 3000;

simulation_attacked11.xc0 = [31.4347; 33.4446];
simulation_attacked11.x0 = [12.4; 12.7; 1.5919; 1.4551; 20; 12.4; 12.7; 1.5919; 1.4551; 20];
simulation_attacked11.t0 = 0;
simulation_attacked11.tend = 3000;



% Define set-point conditions
simulation.set_preloaded_reference(1, 15);
simulation.set_preloaded_reference(2, 12.7);

simulation_attacked11.set_preloaded_reference(1, 15);
simulation_attacked11.set_preloaded_reference(2, 12.7);


% Execute simulation
data = simulation.run();
data_attacked11 = simulation_attacked11.run();

size(data.y(1,:)) % 1 389
size(data.y(2,:)) % 1 389
size(data.y(3,:)) % 1 389
size(data.y(4,:)) % 1 389

size(data.t) % 1 389


size(data_attacked11.y(1,:)) % 1 913
size(data_attacked11.y(2,:)) % 1 913
size(data_attacked11.y(3,:)) % 1 913
size(data_attacked11.y(4,:)) % 1 913

size(data_attacked11.t) % 1 913


%-----------------
% LINEARIZATION
%-----------------

%-----
% T1    % N : y = 14.18
%-----

INTERPRET_11_T1_x = 0:0.1:2999;
INTERPRET_11_T1_y = interp1(data.t, data.y(1,:), INTERPRET_11_T1_x);

INTERPRET_11_T1_a_x = 0:0.1:2999;
INTERPRET_11_T1_a_y = interp1(data_attacked11.t, data_attacked11.y(1,:), INTERPRET_11_T1_a_x);

PERF_T1 = -(abs(INTERPRET_11_T1_y-INTERPRET_11_T1_a_y));


%-----
% T2    % N : y = 10.37
%-----

INTERPRET_11_T2_x = 0:0.1:2999;
INTERPRET_11_T2_y = interp1(data.t, data.y(2,:), INTERPRET_11_T2_x);

INTERPRET_11_T2_a_x = 0:0.1:2999;
INTERPRET_11_T2_a_y = interp1(data_attacked11.t, data_attacked11.y(2,:), INTERPRET_11_T2_a_x);

PERF_T2 = -(abs(INTERPRET_11_T2_y-INTERPRET_11_T2_a_y));

%-----
% T3    % N : y = 0.8228
%-----

INTERPRET_11_T3_x = 0:0.1:2999;
INTERPRET_11_T3_y = interp1(data.t, data.y(3,:), INTERPRET_11_T3_x);

INTERPRET_11_T3_a_x = 0:0.1:2999;
INTERPRET_11_T3_a_y = interp1(data_attacked11.t, data_attacked11.y(3,:), INTERPRET_11_T3_a_x);

PERF_T3 = (INTERPRET_11_T3_y-INTERPRET_11_T3_a_y);

%-----
% T4    % N : y = 2.328
%-----

INTERPRET_11_T4_x = 0:0.1:2999;
INTERPRET_11_T4_y = interp1(data.t, data.y(4,:), INTERPRET_11_T4_x);

INTERPRET_11_T4_a_x = 0:0.1:2999;
INTERPRET_11_T4_a_y = interp1(data_attacked11.t, data_attacked11.y(4,:), INTERPRET_11_T4_a_x);

PERF_T4 = -(INTERPRET_11_T4_y-INTERPRET_11_T4_a_y);

%-----
% WR    % N : y = 20.07
%-----

INTERPRET_11_WR_x = 0:0.1:2999;
INTERPRET_11_WR_y = interp1(data.t, data.x(5,:), INTERPRET_11_WR_x);

INTERPRET_11_WR_a_x = 0:0.1:2999;
INTERPRET_11_WR_a_y = interp1(data_attacked11.t, data_attacked11.x(5,:), INTERPRET_11_WR_a_x);

PERF_WR = -(INTERPRET_11_WR_y-INTERPRET_11_WR_a_y);

%----------
% SUM PERF
%----------

%----------------------------------
% CASE 2 Fig.3(a) (1,1)-resilient
%----------------------------------

figure
plot(data.t, data.y(1,:), 'r', 'Linewidth', 0.9); hold on;
plot(data.t, data.y(2,:), 'm', 'Linewidth', 0.9); hold on;
plot(data.t, data.y(3,:), 'b',  'Linewidth', 0.9); hold on;
plot(data.t, data.y(4,:), 'k',  'Linewidth', 0.9);
title('System (1,1)-resilient');
legend({'Level Tank 1', 'Level Tank 2', 'Level Tank 3', 'Level Tank 4'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Level (cm^3)');
grid on;


%----------------------------------------------
% CASE 2 Fig.3(b) (1,1)-resilient, under attack
%----------------------------------------------

figure
plot(data_attacked11.t, smooth(data_attacked11.x(1,:), 0.005, 'lowess'), 'r', 'Linewidth', 0.9); hold on;
plot(data.t, data.x(1,:), 'r--', 'Linewidth', 1.5); hold on;
plot(data_attacked11.t, smooth(data_attacked11.x(2,:), 0.005, 'lowess'), 'm', 'Linewidth', 0.9); hold on;
plot(data.t, data.x(2,:), 'm--', 'Linewidth', 1.5); hold on;
plot(data_attacked11.t, smooth(data_attacked11.x(3,:), 0.005, 'lowess'), 'b', 'Linewidth', 0.9); hold on;
plot(data.t, data.x(3,:), 'b--',  'Linewidth', 1.5); hold on;
plot(data_attacked11.t, smooth(data_attacked11.x(4,:), 0.005, 'lowess'), 'k', 'Linewidth', 0.9); hold on;
plot(data.t, data.x(4,:), 'k--',  'Linewidth', 1.5);
title('System (1,1)-resilient');
legend({'Level Tank 1 (Attacked)', 'Level Tank 1 (Expected)', 'Level Tank 2 (Attacked)', 'Level Tank 2 (Expected)', 'Level Tank 3 (Attacked)', 'Level Tank 3 (Expected)','Level Tank 4 (Attacked)', 'Level Tank 4 (Expected)'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Level (cm^3)');
grid on;