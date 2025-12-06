clc;
% Initializing Meta Data
Tdata = -40:5:85;  % Temperature range
Vdata = 1.026E-1 + -1.125E-4 * Tdata + 1.125E-5 * Tdata.^2;  % Objective voltage curve

% Load Components
load('StandardComponentValues.mat');

% Key Parameters
popSize = [190,200,210,220,230,240,250,260,270,280];  % Population size
Iteration = 100;   % Max Generation
mutationRate = 0.1;  % Mutation Rate
crossoverRate = 0.75;  % Crossover rate
lb = [1 1 1 1 1 1];  % Lower Bound
ub = [70 70 70 70 9 9];  % Upper Bound
runs=10;

BestFitnessValues=zeros(1, runs);
AvgFitnessEachGen=zeros(runs,Iteration);

for loop=1:runs
% Initialize population
population = initializePopulation(popSize(loop), lb, ub);

% Fitness of every generation
fitnessHistory = zeros(Iteration, 1);

% Main loop
for gen = 1:Iteration
    % Fitness calculation
    fitness = zeros(popSize(loop), 1);
    for i = 1:popSize(loop)
        fitness(i) = objectiveFunction(population(i,:), Res, ThVal, ThBeta, Tdata, Vdata);
    end
    
    % Best fitness of every generation
    fitnessHistory(gen) = min(fitness);

    % RWS selection
    selectedParents = selectParents(population, fitness, popSize(loop));
    
    % Crossover
    offspring = crossover(selectedParents, crossoverRate);
    
    % Mutation
    offspring = mutate(offspring, mutationRate, lb, ub);
    
    % Refresh population
    population = offspring;
    
    % Fitness convergence figure
    plotFitnessConvergence(fitnessHistory, gen);

    AvgFitnessEachGen(runs,gen)=mean(fitness);% A matrix, which records the
    % average fitness values of each generation in each loop
end

% Best solution
[~,bestIdx] = min(fitness);
bestSolution = population(bestIdx, :);
disp('Best solution：');
disp(bestSolution);

best=min(fitness);
worst=max(fitness);
mea=mean(fitness);

BestFitnessValues(loop)=best;
WorstFitnessValues(loop)=worst;
MeanFitnessValues(loop)=mea;

bestV = voltageCurve(Tdata, bestSolution, Res, ThVal, ThBeta);
figure;
    plot(Tdata, Vdata, '-b*'); hold on;
    plot(Tdata, bestV, '-or');
    xlabel('Temperature (^oC)');
    ylabel('Voltage (V)');
    title('Best Solution - Thermistor Network Temperature Curve');
    legend('Target Curve', 'GA Solution', 'Location', 'southeast');
    grid on;
    hold off;
end


bestp=min(BestFitnessValues);
disp('best fitness');
disp(bestp);
worstp=max(BestFitnessValues);
disp('worst fitness');
disp(worstp);
mediump=median(BestFitnessValues);
disp('medium fitness');
disp(mediump);

% Final Best solution
[~,bestIdx] = min(BestFitnessValues);
finalbestSolution = population(bestIdx, :);
disp('Final Best solution：');
disp(finalbestSolution);

%Decide Resistor values
disp('Resistor parameters are:');
disp(Res(finalbestSolution(1)));
disp(Res(finalbestSolution(2)));
disp(Res(finalbestSolution(3)));
disp(Res(finalbestSolution(4)));
disp(ThBeta(finalbestSolution(5)));
disp(ThVal(finalbestSolution(5)));
disp(ThBeta(finalbestSolution(6)));
disp(ThVal(finalbestSolution(6)));

avg=zeros(1,Iteration);

for i=1:Iteration
avg(i)=mean(AvgFitnessEachGen(:,i));
end

%Plot The Average Fitness of Each Generation in 10 Runs
plotdata=1:1:Iteration;
clf;
xlabel('Generation');
ylabel('Average Fitness Value');
plot(plotdata,avg,'m*--');
title('The Average Fitness of Each Generation in 10 Runs');

% Objective Function: Calculate fitness, this function is actually
% objectiveFunction.m
function fitness = objectiveFunction(x, Res, ThVal, ThBeta, Tdata, Vdata)
    y = zeros(8, 1);
    y(1) = Res(x(1));
    y(2) = Res(x(2));
    y(3) = Res(x(3));
    y(4) = Res(x(4));
    y(5) = ThVal(x(5));
    y(6) = ThBeta(x(5));
    y(7) = ThVal(x(6));
    y(8) = ThBeta(x(6));
    
    F = tempCompCurve(y, Tdata);
    Residual = F(:) - Vdata(:);
    Residual = Residual(1:2:26);
    fitness = sum(Residual.^2);  
end

% Function of Initialize Population 
function population = initializePopulation(popSize, lb, ub)
    population = zeros(popSize, length(lb));
    for i = 1:popSize
        for j = 1:length(lb)
            population(i,j) = round(rand * (ub(j) - lb(j)) + lb(j));
        end
    end
end

% RWS Selection Function
function selectedParents = selectParents(population, fitness, popSize)
    selectedParents = zeros(popSize, size(population, 2));
    totalFitness = sum(1 ./ (fitness + 1e-5));
    probs = (1 ./ (fitness + 1e-5)) / totalFitness;
    for i = 1:popSize
        r = rand;
        cumulativeProb = 0;
        for j = 1:popSize
            cumulativeProb = cumulativeProb + probs(j);
            if r <= cumulativeProb
                selectedParents(i, :) = population(j, :);
                break;
            end
        end
    end
end

% Crossover: binary crossover
function offspring = crossover(parents, crossoverRate)
    popSize = size(parents, 1);
    offspring = parents;
    for i = 1:2:popSize
        if rand < crossoverRate
            crossoverPoint = randi(size(parents, 2)-1);
            offspring(i, crossoverPoint+1:end) = parents(i+1, crossoverPoint+1:end);
            offspring(i+1, crossoverPoint+1:end) = parents(i, crossoverPoint+1:end);
        end
    end
end

% Mutation operation
function offspring = mutate(offspring, mutationRate, lb, ub)
    [popSize, nGenes] = size(offspring);
    for i = 1:popSize
        for j = 1:nGenes
            if rand < mutationRate
                offspring(i,j) = round(rand * (ub(j) - lb(j)) + lb(j));
            end
        end
    end
end

% Plot fitness convergence figure
function plotFitnessConvergence(fitnessHistory, gen)
    figure(1);
    plot(1:gen, fitnessHistory(1:gen), '-o');
    xlabel('Generation');
    ylabel('Best Fitness');
    title('Convergence of 10 Runs');
    drawnow;
    hold on;
end