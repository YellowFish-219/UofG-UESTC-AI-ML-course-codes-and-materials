function perf=evaluate(f, S11_val, S21_val, S31_val)
S11 = [f,S11_val];%Matrix: frequency corresponds to amptitude of S11
S21 = [f,S21_val];%Matrix: frequency corresponds to amptitude of S21
S31 = [f,S31_val];%Matrix: frequency corresponds to amptitude of S31

s11index1= find(12.5<S11(:,1)&12.75>S11(:,1));
S11(s11index1,2);
S11_vioa=max(S11(s11index1,2))+20;%Find violence in the 1st interval

s11index2= find(13<S11(:,1)&13.25>S11(:,1));
S11(s11index2,2);
S11_viob=max(S11(s11index2,2))+20;%Find violence in the 2nd interval


if S11_vioa<=0
    S11_vioa=0;
end%If violence is lower or equal to 0, then we define the violence is zero.
if S11_viob<=0
    S11_viob=0;
end
% Calculate the violence of S11
s21index1= find(12<S21(:,1)&12.3>S21(:,1));
S21(s21index1,2);
S21_vioa=max(S21(s21index1,2))+20;

s21index2= find(13<S21(:,1)&13.25>S21(:,1));
S21(s21index2,2);
S21_viob=max(S21(s21index2,2))+55;

if S21_vioa<=0
    S21_vioa=0;
end
if S21_viob<=0
    S21_viob=0;
end
%% Calculate the violence of S21
s31index1= find(12.5<S31(:,1)&12.75>S31(:,1));
S31(s31index1,2);
S31_vioa=max(S31(s31index1,2))+55;

s31index2= find(13.4<S31(:,1)&13.75>S31(:,1));
S31(s31index2,2);
S31_viob=max(S31(s31index2,2))+20;


if S31_vioa<=0
    S31_vioa=0;
end
if S31_viob<=0
    S31_viob=0;
end
% Calculate the violence of S31
perf=[S11_vioa, S11_viob, S21_vioa, S21_viob, S31_vioa, S31_viob];%Output the final values
end