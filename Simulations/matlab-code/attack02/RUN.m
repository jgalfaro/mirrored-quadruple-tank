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
simulation = PCS.Simulation(controller, process);
simulation_attacked22 = PCS.Simulation(controller, process_attacked22);
simulation_attacked22_u_a = PCS.Simulation(controller, process_attacked22_u_a); % J'AI ENLEVEÉ u_a pour process_attacked

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

% Plot results
% plot(data.t, data.y(1,:), 'g'); hold on;
% plot(data_attacked22.t, data_attacked22.y(1,:), 'r'); %hold on;
% plot(data.t, data.y(3,:), 'c'); hold on;
% plot(data.t, data.y(5,:), 'r'); hold on;
% plot(data_attacked22.t, data_attacked22.y(7,:), 'm'); %hold on;
% plot(data.t, data.x(5,:), 'g','LineWidth',1); hold on;
% plot(data_attacked22.t, data_attacked22.x(5,:), 'r','LineWidth',1);
% legend({'Performance (2,2)-resilient : Unattacked', 'Performance (2,2)-resilient : Attacked'}, 'Location','northeast');
% title('Performance (2,2)');
% xlabel('Time (s)');
% ylabel('Relative value');
%axis([0 500 15 23]); % for reservoir
%axis([0 500 -1 2]); % for T4
%save('../GLOBAL/QTP-22.mat')


%-----------------
% LINÉARISATION
%-----------------

%-----
% T1    % N : y = 10.19
%-----

INTERPRET_22_T1_x = 0:0.1:3999;
INTERPRET_22_T1_y = interp1(data.t, data.y(1,:), INTERPRET_22_T1_x);

INTERPRET_22_T1_a_x = 0:0.1:3999;
INTERPRET_22_T1_a_y = interp1(data_attacked22.t, data_attacked22.y(1,:), INTERPRET_22_T1_a_x);

PERF_T1 = -(abs(INTERPRET_22_T1_y-INTERPRET_22_T1_a_y));

% figure
% plot(data.t,data.y(1,:),'o'); hold on;
% plot(INTERPRET_22_T1_x,INTERPRET_22_T1_y,':.'); hold on;
% plot(data_attacked22.t,data_attacked22.y(1,:),'o'); hold on;
% plot(INTERPRET_22_T1_a_x,INTERPRET_22_T1_a_y,':.'); hold on;
% plot(INTERPRET_22_T1_x, PERF_T1, 'g');
% legend({'T1 normal', 'T1 linearized', 'T1 attacked normal', 'T1 attacked linearized', 'Performance linearized'}, 'Location', 'southeast');
% title('Performance (2,2)');
% xlim([0 4000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%-----
% T2    % N : y = 2.331
%-----

INTERPRET_22_T2_x = 0:0.1:3999;
INTERPRET_22_T2_y = interp1(data.t, data.y(2,:), INTERPRET_22_T2_x);

INTERPRET_22_T2_a_x = 0:0.1:3999;
INTERPRET_22_T2_a_y = interp1(data_attacked22.t, data_attacked22.y(2,:), INTERPRET_22_T2_a_x);

PERF_T2 = -(abs(INTERPRET_22_T2_y-INTERPRET_22_T2_a_y));

% figure
% plot(data.t,data.y(2,:),'o'); hold on;
% plot(INTERPRET_22_T2_x,INTERPRET_22_T2_y,':.'); hold on;
% plot(data_attacked22.t,data_attacked22.y(2,:),'o'); hold on;
% plot(INTERPRET_22_T2_a_x,INTERPRET_22_T2_a_y,':.'); hold on;
% plot(INTERPRET_22_T2_x, PERF_T2, 'g');
% legend({'T2 normal', 'T2 linearized', 'T2 attacked normal', 'T2 attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (2,2)');
% xlim([0 4000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%-----
% T3    % N : y = 8.521
%-----

INTERPRET_22_T3_x = 0:0.1:3999;
INTERPRET_22_T3_y = interp1(data.t, data.y(3,:), INTERPRET_22_T3_x);

INTERPRET_22_T3_a_x = 0:0.1:3999;
INTERPRET_22_T3_a_y = interp1(data_attacked22.t, data_attacked22.y(3,:), INTERPRET_22_T3_a_x);

PERF_T3 = -(INTERPRET_22_T3_y-INTERPRET_22_T3_a_y);

% figure
% plot(data.t,data.y(3,:),'o'); hold on;
% plot(INTERPRET_22_T3_x,INTERPRET_22_T3_y,':.'); hold on;
% plot(data_attacked22.t,data_attacked22.y(3,:),'o'); hold on;
% plot(INTERPRET_22_T3_a_x,INTERPRET_22_T3_a_y,':.'); hold on;
% plot(INTERPRET_22_T3_x, PERF_T3, 'g');
% legend({'T3 normal', 'T3 linearized', 'T3 attacked normal', 'T3 attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (2,2)');
% xlim([0 4000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%-----
% T4    % N : y = 2.01
%-----

INTERPRET_22_T4_x = 0:0.1:3999;
INTERPRET_22_T4_y = interp1(data.t, data.y(4,:), INTERPRET_22_T4_x);

INTERPRET_22_T4_a_x = 0:0.1:3999;
INTERPRET_22_T4_a_y = interp1(data_attacked22.t, data_attacked22.y(4,:), INTERPRET_22_T4_a_x);

PERF_T4 = -(INTERPRET_22_T4_y-INTERPRET_22_T4_a_y);

% figure
% plot(data.t,data.y(4,:),'o'); hold on;
% plot(INTERPRET_22_T4_x,INTERPRET_22_T4_y,':.'); hold on;
% plot(data_attacked22.t,data_attacked22.y(4,:),'o'); hold on;
% plot(INTERPRET_22_T4_a_x,INTERPRET_22_T4_a_y,':.'); hold on;
% plot(INTERPRET_22_T4_x, PERF_T4, 'g');
% legend({'T4 normal', 'T4 linearized', 'T4 attacked normal', 'T4 attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (2,2)');
% xlim([0 4000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%-----
% WR    % N : y = 20.86
%-----

INTERPRET_22_WR_x = 0:0.1:3999;
INTERPRET_22_WR_y = interp1(data.t, data.x(5,:), INTERPRET_22_WR_x);

INTERPRET_22_WR_a_x = 0:0.1:3999;
INTERPRET_22_WR_a_y = interp1(data_attacked22.t, data_attacked22.x(5,:), INTERPRET_22_WR_a_x);

PERF_WR = -(INTERPRET_22_WR_y-INTERPRET_22_WR_a_y);

% figure
% plot(data.t,data.x(5,:),'o'); hold on;
% plot(INTERPRET_22_WR_x,INTERPRET_22_WR_y,':.'); hold on;
% plot(data_attacked22.t,data_attacked22.x(5,:),'o'); hold on;
% plot(INTERPRET_22_WR_a_x,INTERPRET_22_WR_a_y,':.'); hold on;
% plot(INTERPRET_22_WR_x, PERF_WR, 'g');
% legend({'WR normal', 'WR linearized', 'WR attacked normal', 'WR attacked linearized', 'Performance linearized'}, 'Location', 'northeast');
% title('Performance (2,2)');
% xlim([0 4000]);
% xlabel('Time (s)');
% ylabel('Relative value');

%----------
% SUM PERF
%----------

% figure
% plot(INTERPRET_22_T1_x, smooth(((PERF_T1/10.19)*100+(PERF_T2/2.331)*100+(PERF_T3/8.521)*100+(PERF_T4/2.01)*100+(PERF_WR/20.86)*100)/5, 0.015, 'lowess'),'b', 'Linewidth', 1.5); 
% title('System (2,2)-resilient');
% xlim([0 1500]);
% ylim([-120 20]);
% xlabel('Time (s)');
% ylabel('Performance (%)');
% ax = gca;
% ay = gca;
% %ax.XTickLabel = [0 500 1000 1500];
% ay.YTickLabel = ({' ', '0', '20', '40', '60', '80', '100', ' '});
% grid on;


% figure
% plot(data_attacked22.t, data_attacked22.u(1,:)); hold on;
% plot(data_attacked22.t,   ); hold on;
% plot(data_attacked22.t,  ( (( ( data_attacked22.x(7,:) + a(4)/A(4)*sqrt(2*g*data_attacked22.x(4,:))) / (1-gamma(1))*k(1)/A(4) ) )      ) ); hold on;
% plot(data_attacked22.t, data_attacked22.u(2,:));

% ode1 = ( diff(data_attacked22.x(6,:)) + a(1)/A(1)*sqrt(2*g*data_attacked22.x(1,:)) -  a(3)/A(1)*sqrt(2*g*data_attacked22.x(3,:)) ) / gamma(1)*k(1)/A(1) == data_attacked22.u(1,:);
% ode4 = diff(data_attacked22.x(4,:)) == -a(4)/A(4)*sqrt(2*g*data_attacked22.x(4,:)) + (1-gamma(1))*k(1)/A(4)*data_attacked22.u(1,:);


% S = dsolve(ode1);
% uSol(t) = S.data_attacked22.u(1,:);

% plot(data_attacked22.t, uSol(t));


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



% figure
% %plot(INTERPRET_22_y2_x, (INTERPRET_22_y2_y).*INTERPRET_22_u1_a_y, 'r'); hold on;
% %plot(INTERPRET_22_y2_x, (0.7*3.33).*INTERPRET_22_u1_y, 'b');
% 
% plot(INTERPRET_22_y2_x, (INTERPRET_22_y2_y).*INTERPRET_22_u1_y, 'r', 'Linewidth', 0.6); hold on;
% yline(((0.7*3.33)/A(1))*3.5, 'r--', 'Linewidth', 1.5); hold on;
% plot(INTERPRET_22_y4_x, (INTERPRET_22_y4_y).*INTERPRET_22_u2_y, 'b', 'Linewidth', 0.6); hold on;
% yline((((0.6)*3.35)/A(2))*3.5, 'b--', 'Linewidth', 1.5); hold on;
% plot(INTERPRET_22_y6_x, (INTERPRET_22_y6_y).*INTERPRET_22_u2_y, 'k', 'Linewidth', 0.6); hold on;
% yline((((1-0.6)*3.35)/A(3))*3.5, 'k--', 'Linewidth', 1.5); hold on;
% plot(INTERPRET_22_y8_x, (INTERPRET_22_y8_y).*INTERPRET_22_u1_y, 'm', 'Linewidth', 0.6); hold on;
% yline((((1-0.7)*3.33)/A(4))*3.5, 'm--', 'Linewidth', 1.5);
% 
% %yline((0.7*3.33*1) / A(1)); hold on; %plot(data_attacked22.t, ((0.7*3.33*1) / A(1)), 'b'); hold on;
% % plot(INTERPRET_22_y4_x, INTERPRET_22_y4_y.*INTERPRET_22_u2_y, 'c'); hold on;
% % yline((0.6*3.35*1) / A(2)); hold on; %plot(data_attacked22.t, ((0.6*3.35*1) / A(2)), 'c'); hold on;
% % plot(INTERPRET_22_y6_x, INTERPRET_22_y6_y.*INTERPRET_22_u2_y, 'g'); hold on;
% % yline(((1-0.6)*3.35*1) / A(3)); hold on; %plot(data_attacked22.t, (((1-0.6)*3.35*1) / A(3)), 'g'); hold on;
% % plot(INTERPRET_22_y8_x, INTERPRET_22_y8_y.*INTERPRET_22_u1_y, 'm'); hold on;
% % yline(((1-0.7)*3.33*1) / A(4)); %plot(data_attacked22.t, (((1-0.7)*3.33*1) / A(4)), 'm');
% legend({'Inflow Tank 1 (Pump 1)','Inflow Tank 1 (Pump 3)','Inflow Tank 2 (Pump 2)','Inflow Tank 2 (Pump 4)','Inflow Tank 3 (Pump 2)','Inflow Tank 3 (Pump 4)','Inflow Tank 4 (Pump 1)','Inflow Tank 4 (Pump 3)'}, 'Location', 'northeast');
% xlim([0 500]);
% ylim([0 1]);
% title('System (2,2)-resilient')
% xlabel('Time (s)');







% figure
% plot(INTERPRET_22_y2_a_x, ((INTERPRET_22_y2_a_y).*INTERPRET_22_u1_a_y) - ((INTERPRET_22_y2_y).*INTERPRET_22_u1_y), 'r') ; hold on;
% plot(INTERPRET_22_u1_a_x, ((INTERPRET_22_y8_a_y).*INTERPRET_22_u1_a_y) - ((INTERPRET_22_y8_y).*INTERPRET_22_u1_y), 'b');
% legend({'Additionnal / loss 1', 'Additionnal / loss 4'}, 'Location', 'best');
% xlim([0 500]);

% TEST
% figure
% % plot(INTERPRET_22_u1_a_x, INTERPRET_22_u1_a_y, 'r'); hold on;
% plot(INTERPRET_22_y2_a_x, INTERPRET_22_y2_a_y.*INTERPRET_22_u1_a_y, 'r'); hold on;
% plot(INTERPRET_22_y8_a_x, INTERPRET_22_y8_a_y.*INTERPRET_22_u1_a_y, 'b'); hold on;
% % plot(INTERPRET_22_y2_x, INTERPRET_22_u1_y, 'b'); hold on;
% plot(INTERPRET_22_y2_x, INTERPRET_22_y2_y.*INTERPRET_22_u1_y, 'm');  hold on;
% plot(INTERPRET_22_y8_x, INTERPRET_22_y8_y.*INTERPRET_22_u1_y, 'c'); 
% xlim([0 500]);
% legend({'Inflow 1 attacked', 'Inflow 4 attacked', 'Inflow 1 normal', 'Inflow 4 normal'}, 'Location', 'best');






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


% figure
% plot(INTERPRET_22_u1_x, INTERPRET_22_u1_y); hold on;
% plot(INTERPRET_22_u1_a_x, INTERPRET_22_u1_a_y); hold on;
% plot(INTERPRET_22_u1_a_x, INTERPRET_22_u1_a_y - INTERPRET_22_u1_y);
% legend({'u1', 'u1 attacked', 'Attack signal'}, 'Location', 'best');
% xlim([0 500]);
% ylim([-5 20]);

% figure
% plot(INTERPRET_22_u2_x, INTERPRET_22_u2_y); hold on;
% plot(INTERPRET_22_u2_a_x, INTERPRET_22_u2_a_y); hold on;
% plot(INTERPRET_22_u2_a_x, INTERPRET_22_u2_a_y - INTERPRET_22_u2_y);
% legend({'u2', 'u2 attacked', 'Attack signal'}, 'Location', 'best');
% xlim([0 500]);
% ylim([-5 20]);
% 
% figure
% plot(data_attacked22.t, data_attacked22.u(1,:)*1.35); hold on;
% %plot(data_attacked22.t,  ( (( data_attacked22.x(6,:) + a(1)/A(1)*sqrt(2*g*data_attacked22.x(1,:)) - a(3)/A(1)*sqrt(2*g*data_attacked22.x(3,:)) ) / gamma(1)*k(1)/A(1) )      ) ); hold on;
% %plot(data_attacked22.t,  ( (( ( data_attacked22.x(7,:) + a(4)/A(4)*sqrt(2*g*data_attacked22.x(4,:))) / (1-gamma(1))*k(1)/A(4) ) )      ) ); hold on;
% plot(data_attacked22.t, data_attacked22.u(2,:)); hold on;
% plot(data_attacked22.t, data_attacked22.u(1,:)*1.35-data_attacked22.u(1,:)); hold on;
% plot(data_attacked22.t, data_attacked22.u(1,:)*1.35 - (data_attacked22.u(1,:)*1.35-data_attacked22.u(1,:))); hold on;
% legend({'u1 attacked', 'u2 normal', 'Attack signal', 'Recovery normal u1'}, 'Location', 'best');
% xlim([0 500]);
% ylim([-5 20]);


% ATTACKED U_1 IN PI

% figure
% plot(data_attacked22.t, data_attacked22.u(1,:)); hold on;
% plot(data_attacked22.t, data_attacked22.u(1,:)-data_attacked22.u(1,:)*0.35); hold on;
% plot(data_attacked22.t, data_attacked22.u(2,:)); hold on;
% plot(data_attacked22.t, data_attacked22.u(2,:)-data_attacked22.u(2,:));
% legend({'u1', 'attack on u1', 'u2', 'attack on u2'}, 'Location', 'best');
% xlim([0 500]);
% ylim([-5 20]);


%**********
% TEST U
%**********

% figure
% plot(data_attacked22.t, data_attacked22.u(1,:)); hold on;
% plot(data_attacked22.t, data_attacked22.u(2,:));
% legend({'u1', 'u2'}, 'Location', 'best');
% xlim([0 500]);
% ylim([-5 20]);




%-------------------------
% CASE 2 figure 3 : (2,2)
%-------------------------

figure
plot(data_attacked22.t, data_attacked22.y(1,:), 'r', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.y(3,:), 'm', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.y(5,:), 'b',  'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.y(7,:), 'k',  'Linewidth', 0.9);
%title('System (2,2)-resilient');
legend({'Level Tank 1 (From attacked sensor)', 'Level Tank 2 (From attacked sensor)', 'Level Tank 3 (From attacked sensor)', 'Level Tank 4 (From attacked sensor)'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Height (cm)');
grid on;



%-------------------------
% CASE 2 figure 4 : (2,2)
%-------------------------

figure
plot(data_attacked22_u_a.t, smooth(data_attacked22_u_a.x(1,:), 0.005, 'lowess'), 'r', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.x(1,:), 'r--', 'Linewidth', 1.5); hold on;
plot(data_attacked22_u_a.t, smooth(data_attacked22_u_a.x(2,:), 0.005, 'lowess'), 'm', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.x(2,:), 'm--', 'Linewidth', 1.5); hold on;
plot(data_attacked22_u_a.t, smooth(data_attacked22_u_a.x(3,:), 0.005, 'lowess'), 'b', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.x(3,:), 'b--',  'Linewidth', 1.5); hold on;
plot(data_attacked22_u_a.t, smooth(data_attacked22_u_a.x(4,:), 0.005, 'lowess'), 'k', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.x(4,:), 'k--',  'Linewidth', 1.5);
%title('System (2,2)-resilient');
legend({'Level Tank 1 (Attacked)', 'Level Tank 1 (Expected)', 'Level Tank 2 (Attacked)', 'Level Tank 2 (Expected)', 'Level Tank 3 (Attacked)', 'Level Tank 3 (Expected)','Level Tank 4 (Attacked)', 'Level Tank 4 (Expected)'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Height (cm)');
grid on;





%-----------------
% CASE 4 figure 1
%-----------------

figure

plot(INTERPRET_22_y2_x, smooth((INTERPRET_22_y2_a_y).*INTERPRET_22_u1_a_y*1.5, 0.008, 'lowess'), 'r', 'Linewidth', 0.6); hold on;
yline(((0.7*3.33)/A(1))*3.5, 'r--', 'Linewidth', 1.5); hold on;
plot(INTERPRET_22_y4_x, smooth((INTERPRET_22_y4_y).*INTERPRET_22_u2_y*1.5, 0.008, 'lowess'), 'b', 'Linewidth', 0.6); hold on;
yline((((0.6)*3.35)/A(2))*3.5, 'b--', 'Linewidth', 1.5); hold on;
plot(INTERPRET_22_y6_x, smooth((INTERPRET_22_y6_y).*INTERPRET_22_u2_y*1.5, 0.008, 'lowess'), 'k', 'Linewidth', 0.6); hold on;
yline((((1-0.6)*3.35)/A(3))*3.5, 'k--', 'Linewidth', 1.5); hold on;
plot(INTERPRET_22_y8_x, smooth((INTERPRET_22_y8_a_y).*INTERPRET_22_u1_a_y*1.5, 0.008, 'lowess'), 'm', 'Linewidth', 0.6); hold on;
yline((((1-0.7)*3.33)/A(4))*3.5, 'm--', 'Linewidth', 1.5);

legend({'Inflow Tank 1 (Pump 1)','Inflow Tank 1 (Pump 3)','Inflow Tank 2 (Pump 2)','Inflow Tank 2 (Pump 4)','Inflow Tank 3 (Pump 2)','Inflow Tank 3 (Pump 4)','Inflow Tank 4 (Pump 1)','Inflow Tank 4 (Pump 3)'}, 'Location', 'northeast');
xlim([0 500]);
ylim([0 1]);
%title('System (2,2)-resilient')
xlabel('Time (s)');
grid on;



%-----------------
% CASE 4 figure 2
%-----------------

figure

plot(INTERPRET_22_y2_x, smooth((INTERPRET_22_y2_y).*INTERPRET_22_u1_y, 0.008, 'lowess'), 'r', 'Linewidth', 0.6); hold on;
yline(((0.7*3.33)/A(1))*3.5, 'r--', 'Linewidth', 1.5); hold on;
plot(INTERPRET_22_y4_x, smooth((INTERPRET_22_y4_y).*INTERPRET_22_u2_y, 0.008, 'lowess'), 'b', 'Linewidth', 0.6); hold on;
yline((((0.6)*3.35)/A(2))*3.5, 'b--', 'Linewidth', 1.5); hold on;
plot(INTERPRET_22_y6_x, smooth((INTERPRET_22_y6_y).*INTERPRET_22_u2_y, 0.008, 'lowess'), 'k', 'Linewidth', 0.6); hold on;
yline((((1-0.6)*3.35)/A(3))*3.5, 'k--', 'Linewidth', 1.5); hold on;
plot(INTERPRET_22_y8_x, smooth((INTERPRET_22_y8_y).*INTERPRET_22_u1_y, 0.008, 'lowess'), 'm', 'Linewidth', 0.6); hold on;
yline((((1-0.7)*3.33)/A(4))*3.5, 'm--', 'Linewidth', 1.5);

legend({'Inflow Tank 1 (Pump 1)','Inflow Tank 1 (Pump 3)','Inflow Tank 2 (Pump 2)','Inflow Tank 2 (Pump 4)','Inflow Tank 3 (Pump 2)','Inflow Tank 3 (Pump 4)','Inflow Tank 4 (Pump 1)','Inflow Tank 4 (Pump 3)'}, 'Location', 'northeast');
xlim([0 500]);
ylim([0 1]);
%title('System (2,2)-resilient')
xlabel('Time (s)');
grid on;



%-----------------
% CASE 5 figure 1
%-----------------

figure
plot(data_attacked22_u_a.t, smooth(data_attacked22_u_a.x(1,:), 0.005, 'lowess'), 'm', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.x(1,:), 'm--', 'Linewidth', 1.5); hold on;
plot(data_attacked22_u_a.t, smooth(data_attacked22_u_a.x(4,:), 0.005, 'lowess'), 'b', 'Linewidth', 0.9); hold on;
plot(data_attacked22.t, data_attacked22.x(4,:), 'b--',  'Linewidth', 1.5);
%title('System (2,2)-resilient');
legend({'Level Tank 1 (Attacked)', 'Level Tank 1 (Expected)','Level Tank 4 (Attacked)', 'Level Tank 4 (Expected)'}, 'Location', 'best');
xlim([0 1500]);
ylim([0 50]);
xlabel('Time (s)');
ylabel('Height (cm)');
grid on;


%-----------------
% CASE 5 figure 2
%-----------------

figure
%plot(INTERPRET_22_u1_a_x, INTERPRET_22_u1_a_y - INTERPRET_22_u1_y, 'r');
plot(INTERPRET_22_u1_a_x, smooth(INTERPRET_22_u1_a_y*1.5, 0.015, 'lowess'), 'r--', 'Linewidth', 1.5); hold on;
plot(INTERPRET_22_u1_x, INTERPRET_22_u1_y, 'r', 'Linewidth', 0.9); hold on;
plot(INTERPRET_22_u2_x, INTERPRET_22_u2_y, 'k', 'Linewidth', 0.9);
xlim([0 500]);
ylim([0 16]);
xlabel('Time (s)');
%title('System (2,2)-resilient');
legend({'u_1 + u_a', 'u_1', 'u_2'}, 'Location', 'east');
grid on;



