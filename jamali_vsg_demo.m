% jamali_vsg_demo.m - Bulletproof Octave/MATLAB Script with Extra Plots & Saving
clear; clc; close all;

% Octave compatibility: white backgrounds for projection
if exist('OCTAVE_VERSION', 'builtin')
    set(0, 'defaultfigurecolor', 'w');
    set(0, 'defaultaxescolor', 'w');
end

% --- System Parameters ---
n = 4;
E = [1 0 0; -1 1 0; 0 -1 1; 0 0 -1];
M = 1000*eye(n); D = 13880*eye(n);
Phi = 2e4*eye(3);
psi = [0.10; -0.05; 0.08];
Pnet = E*Phi*sin(psi);
th0 = pinv(E')*psi;

% --- Controller Definitions ---
betas = [0, 100, 100];
Hs = [150, 150, 0];
names = {'Primary only', 'Proposed (H=150)', 'Pure Integral (H=0)'};

% --- 1. Table: Constant Bias Attack ---
masks = {[1 0], [0 1], [1 1]};
mnames = {'delta_u only', 'delta_xi only', 'both'};
fprintf('--- STEADY STATE ERROR TABLE ---\n');
for m = 1:3
    fprintf('\n%s (constant bias attack, t = 5..12 s)\n', mnames{m});
    for c = 1:3
        [T,X] = run_sim(betas(c), Hs(c), 'bias', 1, masks{m}, 0, 15, E, Phi, Pnet, th0, M, D);
        idx = T>11.5 & T<=12;
        fprintf('  %-22s max|w| = %.3e rad/s\n', names{c}, max(max(abs(X(idx,5:8)))));
    end
end

% --- 2. Load Step ---
fprintf('\n--- LOAD STEP RESPONSE ---\n');
fprintf('Load step -2000 W at node 4, no attack, final omega (rad/s)\n');
for c = 1:3
    [~,X] = run_sim(betas(c), Hs(c), 'sin', 0, [1 1], -2000, 40, E, Phi, Pnet, th0, M, D);
    fprintf('  %-22s w = %.4e\n', names{c}, X(end,5));
end

% --- 3. Plot 1: Controller Comparison (3-panel) ---
figure('Color','w', 'Name', 'Fig1_Controller_Comparison');
for c = 1:3
    [T,X] = run_sim(betas(c), Hs(c), 'sin', 1, [1 1], 0, 15, E, Phi, Pnet, th0, M, D);
    subplot(3,1,c); plot(T,X(:,5:8),'LineWidth',1.5); hold on;
    y_lim = ylim;
    patch([5 12 12 5], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], 'r', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    title(names{c}); ylabel('\omega (rad/s)'); grid on;
    try xline(5,'--'); xline(12,'--'); catch end
end
xlabel('Time (s)'); legend('IBR1','IBR2','IBR3','IBR4');
print('Fig1_Controller_Comparison', '-dpng', '-r300');

% --- 4. Plot 2: The "Money Slide" (Proposed Controller: Normal vs Attack) ---
figure('Color','w', 'Name', 'Fig2_Money_Slide');
c = 2; % Proposed Controller
[T,X] = run_sim(betas(c), Hs(c), 'sin', 1, [1 1], 0, 15, E, Phi, Pnet, th0, M, D);
plot(T, X(:,5), 'b', 'LineWidth', 2.5); hold on; % Just IBR 1 for clarity
y_lim = ylim;
patch([5 12 12 5], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
title('Proposed Controller (H=150): Normal Operation vs FDI Attack');
ylabel('Frequency Deviation \omega (rad/s)'); xlabel('Time (s)'); grid on;
legend('IBR 1 Frequency', 'FDI Attack Window');
print('Fig2_Money_Slide', '-dpng', '-r300');

% --- 5. Plot 3: Active Power Sharing (Under Attack) ---
figure('Color','w', 'Name', 'Fig3_Power_Sharing');
c = 2; % Proposed Controller
[T,X] = run_sim(betas(c), Hs(c), 'sin', 1, [1 1], 0, 15, E, Phi, Pnet, th0, M, D);
theta = X(:, 1:4)'; % 4 x N
Pe = (E * Phi * sin(E' * theta))'; % N x 4
plot(T, Pe, 'LineWidth', 1.5); hold on;
y_lim = ylim;
patch([5 12 12 5], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], 'r', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
title('Active Power Sharing (Proposed Controller)');
ylabel('Active Power P_e (W)'); xlabel('Time (s)'); grid on;
try xline(5,'--'); xline(12,'--'); catch end
legend('IBR1','IBR2','IBR3','IBR4');
print('Fig3_Power_Sharing', '-dpng', '-r300');

% --- 6. Plot 4: The H-Sweep Trade-off Curve (Octave-safe, no yyaxis) ---
H_vals = linspace(10, 300, 20);
ss_error = zeros(size(H_vals));
peak_attack = zeros(size(H_vals));
fprintf('\n--- H-SWEEP TRADE-OFF ---\n');
for i = 1:length(H_vals)
    H_curr = H_vals(i);
    % Load step (no attack)
    [~, X_load] = run_sim(100, H_curr, 'sin', 0, [1 1], -2000, 20, E, Phi, Pnet, th0, M, D);
    ss_error(i) = abs(X_load(end,5));
    % Attack (no load step)
    [~, X_att] = run_sim(100, H_curr, 'sin', 1, [1 1], 0, 15, E, Phi, Pnet, th0, M, D);
    peak_attack(i) = max(abs(X_att(:,5)));
    fprintf('H = %.1f | SS Error = %.4e | Peak Attack = %.4e\n', H_curr, ss_error(i), peak_attack(i));
end

figure('Color','w', 'Name', 'Fig4_Tradeoff_Curve');
plot(H_vals, ss_error, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b'); hold on;
plot(H_vals, peak_attack, 'r-s', 'LineWidth', 2, 'MarkerFaceColor', 'r');
ylabel('Frequency Deviation (rad/s)');
xlabel('Leak Matrix Gain (H)'); grid on;
title('The Resilience vs. Accuracy Trade-off');
legend('Steady-State Error (Load Step)', 'Peak Deviation (Under Attack)', 'Location', 'best');
% Mark H = 150 without xline (Octave-safe)
ylim_curr = ylim;
line([150 150], ylim_curr, 'LineStyle', '--', 'Color', 'k', 'LineWidth', 1.5);
text(155, ylim_curr(2)*0.9, 'Paper: H = 150');
print('Fig4_Tradeoff_Curve', '-dpng', '-r300');

fprintf('\nAll plots saved to folder successfully.\n');
