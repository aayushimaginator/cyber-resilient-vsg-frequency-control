function dx = rhs_func(t, x_state, beta, H, atk_type, scale, mask, dP, E, Phi, Pnet, M, D)
    th = x_state(1:4); w = x_state(5:8); xi = x_state(9:12);

    % Attack generation
    a = zeros(8,1);
    if t >= 5 && t <= 12
        if strcmp(atk_type, 'sin')
            du = [8*sin(t); 7*sin(t+pi/2); 5*sin(t+pi/3); 3*sin(t+pi/2)];
            dx_a = [10*sin(t); 8.75*sin(t+pi/2); 6.25*sin(t+pi/3); 3.75*sin(t+pi/2)];
        elseif strcmp(atk_type, 'bias')
            du = [8;7;5;3]; dx_a = [10;8.75;6.25;3.75];
        elseif strcmp(atk_type, 'square')
            s = sign(sin(2*pi*t/4));
            du = s*[8;7;5;3]; dx_a = s*[10;8.75;6.25;3.75];
        end
        a = scale * [mask(1)*du; mask(2)*dx_a];
    end

    P = Pnet;
    if t >= 2, P(4) = P(4) + dP; end

    K = 2*eye(4);
    dw = M \ (-D*w + P - E*Phi*sin(E'*th) + beta*K*xi + a(1:4));
    dxi = -H*xi - beta*K'*w + a(5:8);
    dx = [w; dw; dxi];
end
