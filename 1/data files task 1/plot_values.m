
load('T_junction_best.mat')
freq_S11=value{1,1};
S11_val=value{1,2};
freq_S21=value{1,3};
S21_val=value{1,4};
freq_S31=value{1,5};
S31_val=value{1,6};

perf=evaluate(freq,S11_val, S21_val, S31_val);
disp(perf);