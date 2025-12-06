function x_opt = ackley_optimization()
    % Define parameters for the Ackley function
    n = 10; % 10 dimensions
    a = 20; b = 0.2; c = 2 * pi;

    % Define the Ackley function as a nested function
    function y = ackley(x)
        s1 = 0; s2 = 0;
        for i = 1:n
            s1 = s1 + x(i)^2;
            s2 = s2 + cos(c * x(i));
        end
        y = -a * exp(-b * sqrt(1/n * s1)) - exp(1/n * s2) + a + exp(1);
    end

    number_vars = 10; % number of variables
    lower_bnd = -15 * ones(1, number_vars); % Lower_bound
    upper_bnd = 30 * ones(1, number_vars); % Upper_bound

    % Use genetic algorithm to minimize the Ackley function
    options = optimoptions('ga', 'Display', 'iter'); % Display options for the GA
    [x_opt, f_val] = ga(@ackley, number_vars, [], [], [], [], lower_bnd, upper_bnd, [], options);
    
    % Display the optimized result
    disp(x_opt);
    disp("Function Optmized Value");
    disp(f_val);
end