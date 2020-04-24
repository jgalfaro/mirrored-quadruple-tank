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
simulation = PCS.Simulation(controller, process);
simulation_attacked11 = PCS.Simulation(controller, process_attacked11);


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


% if data.t > 1.2047e+03
%     gamma = [0.95 0.6];
%     disp('AAA');
%     
% end



%          compteur = 0;
%          for i=1:length(data.t)
%              data.t(i)
%              compteur = compteur + 1
%              
%          end



% if data.t(169) > 1204
%     disp('AAA');
%     data.t(169);
%     
%     process_attacked11 = QuadrupleTankReservoir(a, A, g, [0.95 0.6], k); % a, A, g, [0.25 0.6], [1.33 3.35]
%   
%     simulation_attacked11 = PCS.Simulation(controller, process_attacked11);
%        
%     simulation_attacked11.xc0 = [31.4347; 33.4446];
%     simulation_attacked11.x0 = [12.4; 12.7; 1.5919; 1.4551; 20];
%     simulation_attacked11.t0 = 0;
%     simulation_attacked11.tend = 1500;
%          
%     simulation_attacked11.set_preloaded_reference(1, 15);
%     simulation_attacked11.set_preloaded_reference(2, 12.7);
%           
%     data_attacked11 = simulation_attacked11.run();
% else
%     disp('ERROR');
%     data.t(169)
% end




% plot(data.t, data.y(1,:), 'b'); hold on;
% plot(data.t, data.y(2,:), 'c'); hold on;
% plot(data.t, data.y(3,:), 'r'); hold on;
% plot(data.t, data.y(4,:), 'm'); hold on;


% plot(data.t, data.y(4,:), 'b'); hold on;
% plot(data_attacked11.t, data_attacked11.y(4,:),'b');

% size(data_attacked11.y(4,:))    % 1 913
% size(data_attacked11.t)         % 1 913




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
% LINÉARISATION
%-----------------

%-----
% T1    % N : y = 14.18
%-----

INTERPRET_11_T1_x = 0:0.1:2999;
INTERPRET_11_T1_y = interp1(data.t, data.y(1,:), INTERPRET_11_T1_x);

INTERPRET_11_T1_a_x = 0:0.1:2999;
INTERPRET_11_T1_a_y = interp1(data_attacked11.t, data_attacked11.y(1,:), INTERPRET_11_T1_a_x);

PERF_T1 = -(abs(INTERPRET_11_T1_y-INTERPRET_11_T1_a_y));

% figure
% plot(data.t,data.y(1,:),'o'); hold on;
% plot(INTERPRET_11_T1_x,INTERPRET_11_T1_y,':.'); hold on;
% plot(data_attacked11.t,data_attacked11.y(1,:),'o'); hold on;
% plot(INTERPRET_11_T1_a_x,INTERPRET_11_T1_a_y,':.'); hold on;
% plot(INTERPRET_11_T1_x, PERF_T1, 'g');
% legend({'T1 normal', 'T1 linearized', 'T1 attacked normal', 'T1 attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (1,1)');
% xlim([0 3000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%-----
% T2    % N : y = 10.37
%-----

INTERPRET_11_T2_x = 0:0.1:2999;
INTERPRET_11_T2_y = interp1(data.t, data.y(2,:), INTERPRET_11_T2_x);

INTERPRET_11_T2_a_x = 0:0.1:2999;
INTERPRET_11_T2_a_y = interp1(data_attacked11.t, data_attacked11.y(2,:), INTERPRET_11_T2_a_x);

PERF_T2 = -(abs(INTERPRET_11_T2_y-INTERPRET_11_T2_a_y));

% figure
% plot(data.t,data.y(2,:),'o'); hold on;
% plot(INTERPRET_11_T2_x,INTERPRET_11_T2_y,':.'); hold on;
% plot(data_attacked11.t,data_attacked11.y(2,:),'o'); hold on;
% plot(INTERPRET_11_T2_a_x,INTERPRET_11_T2_a_y,':.'); hold on;
% plot(INTERPRET_11_T2_x, PERF_T2, 'g');
% legend({'T2 normal', 'T2 linearized', 'T2 attacked normal', 'T2 attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (1,1)');
% xlim([0 3000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%-----
% T3    % N : y = 0.8228
%-----

INTERPRET_11_T3_x = 0:0.1:2999;
INTERPRET_11_T3_y = interp1(data.t, data.y(3,:), INTERPRET_11_T3_x);

INTERPRET_11_T3_a_x = 0:0.1:2999;
INTERPRET_11_T3_a_y = interp1(data_attacked11.t, data_attacked11.y(3,:), INTERPRET_11_T3_a_x);

PERF_T3 = (INTERPRET_11_T3_y-INTERPRET_11_T3_a_y);

% figure
% plot(data.t,data.y(3,:),'o'); hold on;
% plot(INTERPRET_11_T3_x,INTERPRET_11_T3_y,':.'); hold on;
% plot(data_attacked11.t,data_attacked11.y(3,:),'o'); hold on;
% plot(INTERPRET_11_T3_a_x,INTERPRET_11_T3_a_y,':.'); hold on;
% plot(INTERPRET_11_T3_x, PERF_T3, 'g');
% legend({'T3 normal', 'T3 linearized', 'T3 attacked normal', 'T3 attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (1,1)');
% xlim([0 3000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%-----
% T4    % N : y = 2.328
%-----

INTERPRET_11_T4_x = 0:0.1:2999;
INTERPRET_11_T4_y = interp1(data.t, data.y(4,:), INTERPRET_11_T4_x);

INTERPRET_11_T4_a_x = 0:0.1:2999;
INTERPRET_11_T4_a_y = interp1(data_attacked11.t, data_attacked11.y(4,:), INTERPRET_11_T4_a_x);

PERF_T4 = -(INTERPRET_11_T4_y-INTERPRET_11_T4_a_y);

% figure
% plot(data.t,data.y(4,:),'o'); hold on;
% plot(INTERPRET_11_T4_x,INTERPRET_11_T4_y,':.'); hold on;
% plot(data_attacked11.t,data_attacked11.y(4,:),'o'); hold on;
% plot(INTERPRET_11_T4_a_x,INTERPRET_11_T4_a_y,':.'); hold on;
% plot(INTERPRET_11_T4_x, PERF_T4, 'g');
% legend({'T4 normal', 'T4 linearized', 'T4 attacked normal', 'T4 attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (1,1)');
% xlim([0 3000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%-----
% WR    % N : y = 20.07
%-----

INTERPRET_11_WR_x = 0:0.1:2999;
INTERPRET_11_WR_y = interp1(data.t, data.x(5,:), INTERPRET_11_WR_x);

INTERPRET_11_WR_a_x = 0:0.1:2999;
INTERPRET_11_WR_a_y = interp1(data_attacked11.t, data_attacked11.x(5,:), INTERPRET_11_WR_a_x);

PERF_WR = -(INTERPRET_11_WR_y-INTERPRET_11_WR_a_y);

% figure
% plot(data.t,data.x(5,:),'o'); hold on;
% plot(INTERPRET_11_WR_x,INTERPRET_11_WR_y,':.'); hold on;
% plot(data_attacked11.t,data_attacked11.x(5,:),'o'); hold on;
% plot(INTERPRET_11_WR_a_x,INTERPRET_11_WR_a_y,':.'); hold on;
% plot(INTERPRET_11_WR_x, PERF_WR, 'g');
% legend({'WR normal', 'WR linearized', 'WR attacked normal', 'WR attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (1,1)');
% xlim([0 3000]);
% xlabel('Time (s)');
% ylabel('Relative value');


%----------
% SUM PERF
%----------

% figure
% plot(INTERPRET_11_T1_x, smooth(((PERF_T1/14.18)*100+(PERF_T2/10.37)*100+(PERF_T3/0.8228)*100+(PERF_T4/2.328)*100+(PERF_WR/20.07)*100)/5, 0.015, 'lowess'),'b', 'LineWidth', 1.5);
% title('System (1,1)-resilient');
% xlim([0 1500]);
% ylim([-120 20]);
% xlabel('Time (s)');
% ylabel('Performance (%)');
% ax = gca;
% ay = gca;
% %ax.XTickLabel = ({'T = 0', 'T=500 : Attack starts', 'T = 1000', 'T = 1500'});
% ay.YTickLabel = ({' ', '0', '20', '40', '60', '80', '100', ' '});
% grid on;



% figure
% plot(INTERPRET_11_T1_x, INTERPRET_11_T1_y); hold on;
% plot(INTERPRET_11_T2_x, INTERPRET_11_T2_y); hold on;
% plot(INTERPRET_11_T3_x, INTERPRET_11_T3_y); hold on;
% plot(INTERPRET_11_T4_x, INTERPRET_11_T4_y);
% title('System (1,1)-resilient');
% legend({'Tank 1', 'Tank 2', 'Tank 3', 'Tank 4'}, 'Location', 'east');
% xlabel('Time (s)');
% ylabel('Height (cm)');
% xlim([0 1500]);
% 
% figure
% plot(INTERPRET_11_T1_a_x, INTERPRET_11_T1_a_y); hold on;
% plot(INTERPRET_11_T2_a_x, INTERPRET_11_T2_a_y); hold on;
% plot(INTERPRET_11_T3_a_x, INTERPRET_11_T3_a_y); hold on;
% plot(INTERPRET_11_T4_a_x, INTERPRET_11_T4_a_y);
% title('System (1,1)-resilient');
% legend({'Tank 1', 'Tank 2', 'Tank 3', 'Tank 4'}, 'Location', 'east');
% xlabel('Time (s)');
% ylabel('Height (cm)');
% xlim([0 1500]);



 
% for i=0:1:length(AXE)
%     for x=0:1:length(data.y(4,:))
%         
%     end
% end



%plot(data_attacked11.t, data_attacked11.y(1,:), 'y'); hold on;
% plot(data_attacked11.t, data_attacked11.y(1,:), 'r');
%plot(data_attacked11.t, data_attacked11.y(4,:), 'm'); % hold on;
%plot(data_attacked.t, data_attacked.y(4,:), 'm');
% size(data.y(4,:))
% size(data_attacked.y(4,:))
%plot(data.t, data.x(5,:), 'g','LineWidth',1); hold on;
%plot(data_attacked11.t, data_attacked11.x(5,:), 'r','LineWidth',1);
% legend({'T1', 'T2', 'T3', 'T4'}, 'Location','northeast');
% title('Performance (1,1)');
% xlabel('Time (s)');
% ylabel('Relative value');
%axis([0 500 15 23]); % for reservoir
%axis([0 500 -1 2]); % for T4
%axis([0 3000 0 30]);
%save('../GLOBAL/QTP-11.mat')



%**********
% TEST U
%**********

% figure
% plot(data_attacked11.t, data_attacked11.u(1,:)); hold on;
% plot(data_attacked11.t, data_attacked11.u(2,:));
% legend({'u1', 'u2'}, 'Location', 'best');
% xlim([0 500]);
% ylim([-5 20]);




%-------------------------
% CASE 2 figure 1 : (1,1)
%-------------------------

figure
plot(data.t, data.y(1,:), 'r', 'Linewidth', 0.9); hold on;
plot(data.t, data.y(2,:), 'm', 'Linewidth', 0.9); hold on;
plot(data.t, data.y(3,:), 'b',  'Linewidth', 0.9); hold on;
plot(data.t, data.y(4,:), 'k',  'Linewidth', 0.9);
title('System (1,1)-resilient');
legend({'Level Tank 1 (From attacked sensor)', 'Level Tank 2 (From attacked sensor)', 'Level Tank 3 (From attacked sensor)', 'Level Tank 4 (From attacked sensor)'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Height (cm)');
grid on;


%-------------------------
% CASE 2 figure 2 : (1,1)
%-------------------------

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
ylabel('Height (cm)');
grid on;