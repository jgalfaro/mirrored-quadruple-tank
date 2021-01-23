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


%--------
% CASE 4
%--------

%-------------
% NORMAL
%-------------


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

%--------
% CASE 4
%--------

%-------------
% NORMAL
%-------------


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


%--------------------------------
% CASE 4 Fig.5(a) (2,2)-resilient
%--------------------------------

figure

plot(INTERPRET_22_y2_x, smooth((INTERPRET_22_y2_a_y).*INTERPRET_22_u1_a_y*1.5, 0.008, 'lowess'), 'r', 'Linewidth', 0.6); hold on;
%yline(((0.7*3.33)/A(1))*3.5, 'r--', 'Linewidth', 1.5); hold on; %requires Matlab2018 or higher
plot(INTERPRET_22_y4_x, smooth((INTERPRET_22_y4_y).*INTERPRET_22_u2_y*1.5, 0.008, 'lowess'), 'b', 'Linewidth', 0.6); hold on;
%yline((((0.6)*3.35)/A(2))*3.5, 'b--', 'Linewidth', 1.5); hold on; %requires Matlab2018 or higher
plot(INTERPRET_22_y6_x, smooth((INTERPRET_22_y6_y).*INTERPRET_22_u2_y*1.5, 0.008, 'lowess'), 'k', 'Linewidth', 0.6); hold on;
%yline((((1-0.6)*3.35)/A(3))*3.5, 'k--', 'Linewidth', 1.5); hold on; %requires Matlab2018 or higher
plot(INTERPRET_22_y8_x, smooth((INTERPRET_22_y8_a_y).*INTERPRET_22_u1_a_y*1.5, 0.008, 'lowess'), 'm', 'Linewidth', 0.6); hold on;
%yline((((1-0.7)*3.33)/A(4))*3.5, 'm--', 'Linewidth', 1.5); %requires Matlab2018 or higher

%legend({'Inflow Tank 1 (Pump 1)','Inflow Tank 1 (Pump 3)','Inflow Tank 2 (Pump 2)','Inflow Tank 2 (Pump 4)','Inflow Tank 3 (Pump 2)','Inflow Tank 3 (Pump 4)','Inflow Tank 4 (Pump 1)','Inflow Tank 4 (Pump 3)'}, 'Location', 'northeast');
legend({'Inflow Tank 1 (Pump 1)','Inflow Tank 2 (Pump 2)','Inflow Tank 3 (Pump 2)','Inflow Tank 4 (Pump 1)'}, 'Location', 'northeast');
xlim([0 1500]);
ylim([0 1]);
title('System (2,2)-resilient')
xlabel('Time (s)');
ylabel('Flow (cm^3/s)');
grid on;



%-----------------------------------------------
% CASE 4 Fig.5(b) (2,2)-resilient, under attack
%-----------------------------------------------

figure

plot(INTERPRET_22_y2_x, smooth((INTERPRET_22_y2_y).*INTERPRET_22_u1_y, 0.008, 'lowess'), 'r', 'Linewidth', 0.6); hold on;
%yline(((0.7*3.33)/A(1))*3.5, 'r--', 'Linewidth', 1.5); hold on; %requires Matlab2018 or higher
plot(INTERPRET_22_y4_x, smooth((INTERPRET_22_y4_y).*INTERPRET_22_u2_y, 0.008, 'lowess'), 'b', 'Linewidth', 0.6); hold on;
%yline((((0.6)*3.35)/A(2))*3.5, 'b--', 'Linewidth', 1.5); hold on;%requires Matlab2018 or higher
plot(INTERPRET_22_y6_x, smooth((INTERPRET_22_y6_y).*INTERPRET_22_u2_y, 0.008, 'lowess'), 'k', 'Linewidth', 0.6); hold on;
%yline((((1-0.6)*3.35)/A(3))*3.5, 'k--', 'Linewidth', 1.5); hold on;%requires Matlab2018 or higher
plot(INTERPRET_22_y8_x, smooth((INTERPRET_22_y8_y).*INTERPRET_22_u1_y, 0.008, 'lowess'), 'm', 'Linewidth', 0.6); hold on;
%yline((((1-0.7)*3.33)/A(4))*3.5, 'm--', 'Linewidth', 1.5);%requires Matlab2018 or higher

%legend({'Inflow Tank 1 (Pump 1)','Inflow Tank 1 (Pump 3)','Inflow Tank 2 (Pump 2)','Inflow Tank 2 (Pump 4)','Inflow Tank 3 (Pump 2)','Inflow Tank 3 (Pump 4)','Inflow Tank 4 (Pump 1)','Inflow Tank 4 (Pump 3)'}, 'Location', 'northeast');
legend({'Inflow Tank 1 (Pump 1)','Inflow Tank 2 (Pump 2)','Inflow Tank 3 (Pump 2)','Inflow Tank 4 (Pump 1)'}, 'Location', 'northeast');
xlim([0 1500]);
ylim([0 1]);
title('System (2,2)-resilient')
xlabel('Time (s)');
ylabel('Flow (cm^3/s)');
grid on;
