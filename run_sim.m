function [T,X] = run_sim(beta, H, atk_type, scale, mask, dP, Tend, E, Phi, Pnet, th0, M, D)
    breaks = unique([0 2 5 12 Tend]); breaks = breaks(breaks<=Tend);
    x = [th0; zeros(8,1)];
    T = []; X = [];
    opts = odeset('RelTol',1e-6,'AbsTol',1e-8,'MaxStep',0.01);

    for k = 1:numel(breaks)-1
        f = @(t,x_state) rhs_func(t, x_state, beta, H, atk_type, scale, mask, dP, E, Phi, Pnet, M, D);
        [t,y] = ode45(f, [breaks(k) breaks(k+1)], x, opts);
        if k > 1, t = t(2:end); y = y(2:end,:); end
        T = [T; t]; X = [X; y];
        x = y(end,:)';
    end
end
