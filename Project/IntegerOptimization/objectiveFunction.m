function G = objectiveFunction(x,StdRes, StdTherm_Val, StdTherm_Beta,Tdata,Vdata)
%% Objective function for the thermistor problem
% Copyright (c) 2012-2019, MathWorks, Inc.

% % StdRes = vector of resistor values
% StdTherm_val = vector of nominal thermistor resistances
% StdTherm_Beta = vector of thermistor temperature coefficients

% Extract component values from tables using integers in x as indices
y = zeros(8,1);
x = round(x); % in case of noninteger components
y(1) = StdRes(x(1));
y(2) = StdRes(x(2));
y(3) = StdRes(x(3));
y(4) = StdRes(x(4));
y(5) = StdTherm_Val(x(5));
y(6) = StdTherm_Beta(x(5));
y(7) = StdTherm_Val(x(6));
y(8) = StdTherm_Beta(x(6));

% Calculate temperature curve for a particular set of components
F = tempCompCurve(y, Tdata);

% Compare simulated results to target curve
Residual = F(:) - Vdata(:);
Residual = Residual(1:2:26);
%%
G = Residual'*Residual; % sum of squares
