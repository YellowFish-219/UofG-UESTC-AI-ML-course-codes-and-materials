clc, clear
close all
 
%% 画出函数图
figure(1);
y = (x(1)-10)^2+5*(x(2)-12)^2+x(3)^4+3*(x(4)-11)^2+...
10x(5)^6+7x(6)^2+x(7)^4-4x(6)x(7)-10x(6)-8x(7);
ezmesh('x*cos(2*pi*y) + y*sin(2*pi*x)', [lbx, ubx, lby, uby], 50);
hold on;
 
%% 定义遗传算法参数
nind = 40;      %种群大小
maxgen = 50;    %最大遗传迭代次数
preci = 20;     %个体长度
ggap = 0.95;    %代沟
px = 0.7;       %交叉概率
pm = 0.01;      %变异概率
trace = zeros(3, maxgen);               %寻优结果初始化
fieldd = [preci preci;lbx lby;ubx uby;1 1;0 0;1 1;1 1]; %区域描述器
chrom = crtbp(nind, preci * 2);         %种群初始化（任意离散随机种群）
 
%% 优化
gen = 0;                                                %代计数器
XY = bs2rv(chrom, fieldd);                              %初始种群二进制转十进制
X = XY(:, 1); Y = XY(:, 2); 
objv = X .* cos(2*pi*Y) + Y .* sin(2*pi*X);             %计算目标函数值
while gen < maxgen
    fitnv = ranking(-objv);                             %分配适应度值
    selch = select('sus', chrom, fitnv, ggap);          %选择
    selch = recombin('xovsp', selch, px);               %交叉
    selch = mut(selch, pm);                             %变异
    XY = bs2rv(selch, fieldd);                          %子代个体十进制转换
    X = XY(:, 1); Y = XY(:, 2);
    objvsel = X .* cos(2*pi*Y) + Y .* sin(2*pi*X);
    [chrom, objv] = reins(chrom, selch, 1, 1, objv, objvsel);   %重插入子代到父代，得到新种群
    XY = bs2rv(chrom, fieldd);
    gen = gen + 1;
    %获取每代的最优解及其序号，Y为最优解，i为个体的序号
    [Y, i] = max(objv);
    trace(1:2, gen) = XY(i, :);
    trace(3, gen) = Y;
end
plot3(trace(1, :), trace(2, :), trace(3, :), 'bo');   %绘制每一代的最优点
grid on;
plot3(XY(:, 1), XY(:, 2), objv, 'b*');
hold off
 
%% 画进化图
figure(2);
plot(1 : maxgen, trace(3, :));
grid on;
xlabel('遗传代数')
ylabel('解的变化')
title('进化过程')
best_z = trace(3, end);
best_y = trace(2, end);
best_x = trace(1, end);
fprintf(['最优解:\nX=', num2str(best_x), '\nY=', num2str(best_y), '\nZ=', num2str(best_z), '\n'])

%% 约束函数PrG9c
function y = PrG9c(x)
    % 定义约束
    v1 = 2*x(1)^2;
    v2 = x(2)^2;
    y(1) = v1 + 3*v2^2 + x(3) + 4*x(4)^2 + 5*x(5) - 127;
    y(2) = 7*x(1) + 3*x(2) + 10*x(3)^2 + x(4) - x(5) - 282;
    y(3) = 23*x(1) + v2 + 6*x(6)^2 - 8*x(7) - 196;
    y(4) = 2*v1 + v2 - 3*x(1)*x(2) + 2*x(3)^2 + 5*x(6) - 11*x(7);
    % 变量下限
    for j=1:7; y(j+4) = -x(j) - 10; end
    % 变量上限
    for j=1:7; y(j+11) = x(j) - 10; end
    y = y';
end
