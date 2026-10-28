% params.m -- call from the model InitFcn:  params
% Same plant and numbers as jamali_vsg_demo.m, so results can be cross-checked.
if ~exist('ctrl_case','var'), ctrl_case = 2; end   % 1 primary only, 2 proposed, 3 H = 0
if ~exist('dP','var'),        dP = [0;0;0;0]; end  % load step vector, e.g. [0;0;0;-2000]

M    = 1000*eye(4);
invM = inv(M);
D    = 13880*eye(4);

ET  = [1 -1  0  0;      % 3 lines, path 1-2-3-4 (Fig. 13)
       0  1 -1  0;
       0  0  1 -1];
E   = ET';
Phi = 2e4*eye(3);       % assumed, the paper does not give it
psi = [0.10; -0.05; 0.08];
Pnet   = E*Phi*sin(psi);    % zero-sum, makes theta0 an exact equilibrium
theta0 = pinv(ET)*psi;      % initial condition for the theta integrator

K = 2*eye(4);
switch ctrl_case
    case 1, beta = 0;   H = 150*eye(4);
    case 2, beta = 100; H = 150*eye(4);
    case 3, beta = 100; H = zeros(4);
end
Gain_H       = -H;
Gain_w_to_xi = -beta*K';
Gain_xi_to_u = beta*K;
