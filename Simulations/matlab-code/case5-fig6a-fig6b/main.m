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
n = [0 0];% n = [0.07 0.06]; % valve coeff
lambda = [0 0];% lambda = [0.1 0.2]; % cm^3 / V second
w = [0 0];% w = [0.15 0.23]; % voltage

process = QuadrupleTank22(a, A, g, gamma, k, n, lambda, w);
process_attacked22 = QuadrupleTank22_attacked(a, A, g, gamma, k, n, lambda, w); % a, A, g, [0.25 0.6], [0 3.35], [0.7 0], [3.33 0], [3 0]
process_attacked22_u_a = QuadrupleTank22_attacked_u_a(a, A, g, gamma, k, n, lambda, w);


% PI controller
K = [0.3816; 0.5058; 0.3816; 0.5058]; % 0.015; 1.25
Ti = [62.9557; 91.3960; 62.9557; 91.3960];

controller = PI(K, Ti);
%controller_get_wrong_datas = PI_get_wrong_datas(K, Ti);

% Create simulation
simulation = Simulation(controller, process);
simulation_attacked22 = Simulation(controller, process_attacked22);
simulation_attacked22_u_a = Simulation(controller, process_attacked22_u_a); % J'AI ENLEVE… u_a pour process_attacked

% Define initial states and time interval
simulation.xc0 = [31.4347; 33.4446; 31.4347; 33.4446];
simulation.x0 = [12.4; 12.7; 1.5919; 1.4551; 20];
simulation.t0 = 0;
simulation.tend = 4000;

simulation_attacked22.xc0 = [31.4347; 33.4446; 31.4347; 33.4446];
simulation_attacked22.x0 = [12.4; 12.7; 1.5919; 1.4551; 20];
simulation_attacked22.t0 = 0;
simulation_attacked22.tend = 4000;

simulation_attacked22_u_a.xc0 = [31.4347; 33.4446; 31.4347; 33.4446];
simulation_attacked22_u_a.x0 = [12.4; 12.7; 1.5919; 1.4551; 20; 12.4; 12.7; 1.5919; 1.4551; 20];
simulation_attacked22_u_a.t0 = 0;
simulation_attacked22_u_a.tend = 4000;

% Define set-point conditions
simulation.set_preloaded_reference(1, 15);
simulation.set_preloaded_reference(2, 12.7);

simulation_attacked22.set_preloaded_reference(1, 15);
simulation_attacked22.set_preloaded_reference(2, 12.7);

simulation_attacked22_u_a.set_preloaded_reference(1, 15);
simulation_attacked22_u_a.set_preloaded_reference(2, 12.7);

% Execute simulation
data = simulation.run();
data_attacked22 = simulation_attacked22.run();
data_attacked22_u_a = simulation_attacked22_u_a.run();

%-----------------
% LINEARIZATION
%-----------------

%-----
% T1    % N : y = 10.19
%-----

INTERPRET_22_T1_x = 0:0.1:3999;
INTERPRET_22_T1_y = interp1(data.t, data.y(1,:), INTERPRET_22_T1_x);

INTERPRET_22_T1_a_x = 0:0.1:3999;
INTERPRET_22_T1_a_y = interp1(data_attacked22.t, data_attacked22.y(1,:), INTERPRET_22_T1_a_x);

PERF_T1 = -(abs(INTERPRET_22_T1_y-INTERPRET_22_T1_a_y));

%-----
% T2    % N : y = 2.331
%-----

INTERPRET_22_T2_x = 0:0.1:3999;
INTERPRET_22_T2_y = interp1(data.t, data.y(2,:), INTERPRET_22_T2_x);

INTERPRET_22_T2_a_x = 0:0.1:3999;
INTERPRET_22_T2_a_y = interp1(data_attacked22.t, data_attacked22.y(2,:), INTERPRET_22_T2_a_x);

PERF_T2 = -(abs(INTERPRET_22_T2_y-INTERPRET_22_T2_a_y));

%-----
% T3    % N : y = 8.521
%-----

INTERPRET_22_T3_x = 0:0.1:3999;
INTERPRET_22_T3_y = interp1(data.t, data.y(3,:), INTERPRET_22_T3_x);

INTERPRET_22_T3_a_x = 0:0.1:3999;
INTERPRET_22_T3_a_y = interp1(data_attacked22.t, data_attacked22.y(3,:), INTERPRET_22_T3_a_x);

PERF_T3 = -(INTERPRET_22_T3_y-INTERPRET_22_T3_a_y);

%-----
% T4    % N : y = 2.01
%-----

INTERPRET_22_T4_x = 0:0.1:3999;
INTERPRET_22_T4_y = interp1(data.t, data.y(4,:), INTERPRET_22_T4_x);

INTERPRET_22_T4_a_x = 0:0.1:3999;
INTERPRET_22_T4_a_y = interp1(data_attacked22.t, data_attacked22.y(4,:), INTERPRET_22_T4_a_x);

PERF_T4 = -(INTERPRET_22_T4_y-INTERPRET_22_T4_a_y);

%-----
% WR    % N : y = 20.86
%-----

INTERPRET_22_WR_x = 0:0.1:3999;
INTERPRET_22_WR_y = interp1(data.t, data.x(5,:), INTERPRET_22_WR_x);

INTERPRET_22_WR_a_x = 0:0.1:3999;
INTERPRET_22_WR_a_y = interp1(data_attacked22.t, data_attacked22.x(5,:), INTERPRET_22_WR_a_x);

PERF_WR = -(INTERPRET_22_WR_y-INTERPRET_22_WR_a_y);

%----------
% SUM PERF
%----------

%-------------
% ATTACKED
%-------------

INTERPRET_22_u1_x = 0:0.1:3999;
INTERPRET_22_u1_y = interp1(data_attacked22.t, data_attacked22.u(1,:), INTERPRET_22_u1_x);

INTERPRET_22_u1_a_x = 0:0.1:3999;
INTERPRET_22_u1_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.u(1,:), INTERPRET_22_u1_a_x);

INTERPRET_22_u2_x = 0:0.1:3999;
INTERPRET_22_u2_y = interp1(data_attacked22.t, data_attacked22.u(2,:), INTERPRET_22_u2_x);


INTERPRET_22_y2_x = 0:0.1:3999;
INTERPRET_22_y2_y = interp1(data_attacked22.t, data_attacked22.y(2,:), INTERPRET_22_y2_x);

INTERPRET_22_y2_a_x = 0:0.1:3999;
INTERPRET_22_y2_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.y(2,:), INTERPRET_22_y2_a_x);

INTERPRET_22_y4_x = 0:0.1:3999;
INTERPRET_22_y4_y = interp1(data_attacked22.t, data_attacked22.y(4,:), INTERPRET_22_y4_x);

INTERPRET_22_y6_x = 0:0.1:3999;
INTERPRET_22_y6_y = interp1(data_attacked22.t, data_attacked22.y(6,:), INTERPRET_22_y6_x);

INTERPRET_22_y8_x = 0:0.1:3999;
INTERPRET_22_y8_y = interp1(data_attacked22.t, data_attacked22.y(8,:), INTERPRET_22_y8_x);

INTERPRET_22_y8_a_x = 0:0.1:3999;
INTERPRET_22_y8_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.y(8,:), INTERPRET_22_y8_a_x);

INTERPRET_22_gamma1_x = 0:0.1:3999;
INTERPRET_22_gamma1_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.y(2,:)*(A(1)/k(1)), INTERPRET_22_gamma1_x);

INTERPRET_22_gamma2_x = 0:0.1:3999;
INTERPRET_22_gamma2_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.y(4,:)*(A(2)/k(2)), INTERPRET_22_gamma2_x);

%-----
% ATTACKED U_1 IN PLOT
%-----

%-----
% LIN
%-----

INTERPRET_22_u1_x = 0:0.1:3999;
INTERPRET_22_u1_y = interp1(data_attacked22.t, data_attacked22.u(1,:), INTERPRET_22_u1_x);

INTERPRET_22_u1_a_x = 0:0.1:3999;
INTERPRET_22_u1_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.u(1,:), INTERPRET_22_u1_a_x);


INTERPRET_22_u2_x = 0:0.1:3999;
INTERPRET_22_u2_y = interp1(data_attacked22.t, data_attacked22.u(2,:), INTERPRET_22_u2_x);

INTERPRET_22_u2_a_x = 0:0.1:3999;
INTERPRET_22_u2_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.u(2,:), INTERPRET_22_u2_a_x);

%**********
% TEST U
%**********


%-------------
% ATTACKED
%-------------

INTERPRET_22_u1_x = 0:0.1:3999;
INTERPRET_22_u1_y = interp1(data_attacked22.t, data_attacked22.u(1,:), INTERPRET_22_u1_x);

INTERPRET_22_u1_a_x = 0:0.1:3999;
INTERPRET_22_u1_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.u(1,:), INTERPRET_22_u1_a_x);

INTERPRET_22_u2_x = 0:0.1:3999;
INTERPRET_22_u2_y = interp1(data_attacked22.t, data_attacked22.u(2,:), INTERPRET_22_u2_x);


INTERPRET_22_y2_x = 0:0.1:3999;
INTERPRET_22_y2_y = interp1(data_attacked22.t, data_attacked22.y(2,:), INTERPRET_22_y2_x);

INTERPRET_22_y2_a_x = 0:0.1:3999;
INTERPRET_22_y2_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.y(2,:), INTERPRET_22_y2_a_x);

INTERPRET_22_y4_x = 0:0.1:3999;
INTERPRET_22_y4_y = interp1(data_attacked22.t, data_attacked22.y(4,:), INTERPRET_22_y4_x);

INTERPRET_22_y6_x = 0:0.1:3999;
INTERPRET_22_y6_y = interp1(data_attacked22.t, data_attacked22.y(6,:), INTERPRET_22_y6_x);

INTERPRET_22_y8_x = 0:0.1:3999;
INTERPRET_22_y8_y = interp1(data_attacked22.t, data_attacked22.y(8,:), INTERPRET_22_y8_x);

INTERPRET_22_y8_a_x = 0:0.1:3999;
INTERPRET_22_y8_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.y(8,:), INTERPRET_22_y8_a_x);

INTERPRET_22_gamma1_x = 0:0.1:3999;
INTERPRET_22_gamma1_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.y(2,:)*(A(1)/k(1)), INTERPRET_22_gamma1_x);

INTERPRET_22_gamma2_x = 0:0.1:3999;
INTERPRET_22_gamma2_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.y(4,:)*(A(2)/k(2)), INTERPRET_22_gamma2_x);

INTERPRET_22_u1_x = 0:0.1:3999;
INTERPRET_22_u1_y = interp1(data_attacked22.t, data_attacked22.u(1,:), INTERPRET_22_u1_x);

INTERPRET_22_u1_a_x = 0:0.1:3999;
INTERPRET_22_u1_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.u(1,:), INTERPRET_22_u1_a_x);


INTERPRET_22_u2_x = 0:0.1:3999;
INTERPRET_22_u2_y = interp1(data_attacked22.t, data_attacked22.u(2,:), INTERPRET_22_u2_x);

INTERPRET_22_u2_a_x = 0:0.1:3999;
INTERPRET_22_u2_a_y = interp1(data_attacked22_u_a.t, data_attacked22_u_a.u(2,:), INTERPRET_22_u2_a_x);


%-----------------------------------------------
% CASE 5 Fig.6(b) (2,2)-resilient, under attack
%-----------------------------------------------

figure
plot(data_attacked22_u_a.t, smooth(data_attacked22_u_a.x(1,:), 0.005, 'lowess'), 'm', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.x(1,:), 'm--', 'Linewidth', 1.5); hold on;
plot(data_attacked22_u_a.t, smooth(data_attacked22_u_a.x(4,:), 0.005, 'lowess'), 'b', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.x(4,:), 'b--',  'Linewidth', 1.5);
title('System (2,2)-resilient');
legend({'Level Tank 1 (Attacked)', 'Level Tank 1 (Expected)','Level Tank 4 (Attacked)', 'Level Tank 4 (Expected)'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Level (cm^3)');
grid on;


%--------------------------------
% CASE 5 Fig.6(a) (2,2)-resilient
%--------------------------------

figure
%plot(INTERPRET_22_u1_a_x, INTERPRET_22_u1_a_y - INTERPRET_22_u1_y, 'r');
plot(INTERPRET_22_u1_a_x, smooth(INTERPRET_22_u1_a_y*1.5, 0.015, 'lowess'), 'r--', 'Linewidth', 1.5); hold on;
plot(INTERPRET_22_u1_x, INTERPRET_22_u1_y, 'r', 'Linewidth', 0.9); hold on;
plot(INTERPRET_22_u2_x, INTERPRET_22_u2_y, 'k', 'Linewidth', 0.9);
xlim([0 1500]);
ylim([0 16]);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('System (2,2)-resilient');
legend({'u_i[1] + u_i^a[1]', 'u_i[1]', 'u_i[2]'}, 'Location', 'east');
grid on;



