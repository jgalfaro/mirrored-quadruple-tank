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
a = [0.071];
A = [28];
g = 981;
gamma = [0.7];
k = [3.33];

process = OT(a, A, g, gamma, k);
process_attacked = OT_attacked(a, A, g, gamma, k);


% PI controller
K = [0.3816];
Ti = [62.9557];

controller = PI(K, Ti);

% Create simulation
simulation = Simulation(controller, process);
simulation_attackedOT = Simulation(controller, process_attacked);


% Define initial states and time interval
simulation.xc0 = [31.4347];
simulation.x0 = [0];
simulation.t0 = 0;
simulation.tend = 3000;

simulation_attackedOT.xc0 = [31.4347];
simulation_attackedOT.x0 = [12.4];
simulation_attackedOT.t0 = 0;
simulation_attackedOT.tend = 3000;



% Define set-point conditions
simulation.set_preloaded_reference(1, 15);
simulation.set_preloaded_reference(2, 12.7);

simulation_attackedOT.set_preloaded_reference(1, 15);
simulation_attackedOT.set_preloaded_reference(2, 12.7);


% Execute simulation
data = simulation.run();
data_attackedOT = simulation_attackedOT.run();


%----------------------------------
% CASE 1 Fig.2(a) one-tank scenario
%----------------------------------

figure
plot(data.t, data.x(1,:), 'b', 'Linewidth', 0.9); 
legend({'Level Tank (Unattacked)'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Level (cm^3)');
grid on;