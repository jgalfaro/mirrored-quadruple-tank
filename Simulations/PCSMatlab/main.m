addpath(pwd);
addpath('PCS/Control');
addpath('PCS/Hardware');
addpath('PCS/Network');
addpath('PCS/Process');
addpath('PCS/Utils');
addpath('PCS/');

disp('PCS classes successfully installed.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PI control of a quadruple-tank process %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Quadruple-tank process
a = [0.071 0.057 0.071 0.057];
A = [28 32 28 32];
g = 981;
gamma = [0.7 0.6];
k = [3.33 3.35];

process = QuadrupleTank(a, A, g, gamma, k);

% PI controller
K = [0.3816; 0.5058];
Ti = [62.9557; 91.3960];

controller = PI(K, Ti);

% Create simulation
simulation = Simulation(controller, process);

% Define initial states and time interval
simulation.xc0 = [31.4347; 33.4446];
simulation.x0 = [12.4; 12.7; 1.5919; 1.4551];
simulation.t0 = 0;
simulation.tend = 5000;

% Define set-point conditions
simulation.set_preloaded_reference(1, 15);
simulation.set_preloaded_reference(2, 12.7);

% Execute simulation
data = simulation.run();

% Plot results
plot(data.t, data.x);
