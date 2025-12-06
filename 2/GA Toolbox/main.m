clc;
% Parameter settings
IterationNum=50; % Iteration generations
PopulationSize=200; % Size of population
Crossover_Rate=0.69; % Crossover possibility
mutationRate=[0.4,0.85];   % Mutation possibility and shrink coefficient
Runs=20; % Run times
Penalty_Coefficient=2350; % Penalty coefficient
FieldDR=[-10,-10,-10,-10,-10,-10,-10;10,10,10,10,10,10,10];% A vector which defines the upper bound and the lower bound of mutation

% Fitness values of each generation
allBestFitnessValues=zeros(Runs, IterationNum);

% Main loop, run Runs times
for run=1:Runs
    % Initialize the population
    population=-5 + 10 * rand(PopulationSize, 7); 
    
    % Initialize the fitness values
    bestFitnessValues=zeros(1, IterationNum);
    
    % Generation loops
    for gen=1:IterationNum
        % Calculate the fitness value
        fitnessValues=arrayfun(@(i) PrG9f_withPenalty(population(i, :), Penalty_Coefficient), 1:PopulationSize);
        
        % Storage the best fitness value of earlier generation
        bestFitnessValues(gen)=min(fitnessValues);
        
        % Storage the best individual at present
        elite=population(find(fitnessValues==min(fitnessValues), 1), :);
        
        % Selection operation using RWS
        selectedPopulation=population(rws(fitnessValues, PopulationSize), :);
        
        % Crossover operation using linear crossover
        newPopulation=selectedPopulation;
        for i=1:2:PopulationSize
                crsover=[selectedPopulation(i, :), selectedPopulation(i+1, :)];
                crossed=reclin(crsover,Crossover_Rate);  
                newPopulation(i, :)=crossed(1:7);
                newPopulation(i+1, :)=crossed(8:14);
            %end
        end
        
        % Real value mutation
        for i=1:PopulationSize
            if rand<mutationRate
                newPopulation(i, :)=mutbga(newPopulation(i, :),FieldDR,mutationRate);
            end
    end        
        % Refresh the population and add elite individuals
        population=newPopulation;
        population(1, :)=elite;
    end
    
    % Storage the best fitness value of each generation
    allBestFitnessValues(run, :)=bestFitnessValues;
end

% Calculate the medium value of each generation
medianBestFitnessValues=median(allBestFitnessValues);
% Calculate the best value of each generation
bestBestFitnessValues=min(allBestFitnessValues);
% Calculate the worst value of each generation
worstBestFitnessValues=max(allBestFitnessValues);

% Draw the median values with literation
figure;
plot(1:IterationNum, medianBestFitnessValues, 'LineWidth', 1);
xlabel('Generation');
ylabel('Median Value');
title('Convergence Trend of Median values');

% Draw the best values with literation
figure;
plot(1:IterationNum, bestBestFitnessValues, 'LineWidth', 1);
xlabel('Generation');
ylabel('Median Value');
title('Convergence Trend of Best values');

% Draw the median values with literation
figure;
plot(1:IterationNum, worstBestFitnessValues, 'LineWidth', 1);
xlabel('Generation');
ylabel('Median Value');
title('Convergence Trend of Worst values');

% Calculate the final best value
finalBestValues = allBestFitnessValues(:, end); % Find the best fitness of each iteration

% Draw the final best values with each run
figure;
plot(1:Runs, finalBestValues, 'LineWidth', 1);
xlabel('Run Times');
ylabel('Best Value');
title('Best Values in Each Run');

bestResult=min(finalBestValues);
worstResult=max(finalBestValues);
meanResult=mean(finalBestValues);
medianResult=median(finalBestValues);

% Print the best values
fprintf('BestValue of 20 Runs: %.4f\n', bestResult);
fprintf('WorstValue of 20 Runs: %.4f\n', worstResult);
fprintf('MeanValue of 20 Runs: %.4f\n', meanResult);
fprintf('MediumValue of 20 Runs: %.4f\n', medianResult);

% Define the objective function
% G9function, which contains the penalty
function y=PrG9f_withPenalty(x, penaltyFactor)
    % Original function
    y = (x(1)-10)^2 + 5*(x(2)-12)^2 + x(3)^4 + 3*(x(4)-11)^2 ...
        + 10*x(5)^6 + 7*x(6)^2 + x(7)^4 - 4*x(6)*x(7) - 10*x(6) - 8*x(7);
    
    % Constrains and plenty values
    constraints=PrG9c(x);
    penalties=sum(max(0, constraints) .* penaltyFactor);
    y=y + penalties;
end

% Function PrG9c
function y = PrG9c(x)
    % Constrain defination
    v1 = 2*x(1)^2;
    v2 = x(2)^2;
    y(1) = v1 + 3*v2^2 + x(3) + 4*x(4)^2 + 5*x(5) - 127;
    y(2) = 7*x(1) + 3*x(2) + 10*x(3)^2 + x(4) - x(5) - 282;
    y(3) = 23*x(1) + v2 + 6*x(6)^2 - 8*x(7) - 196;
    y(4) = 2*v1 + v2 - 3*x(1)*x(2) + 2*x(3)^2 + 5*x(6) - 11*x(7);
    % Lower bounds of variables
    for j=1:7; y(j+4) = -x(j) - 10; end
    % Upper bounds of variables
    for j=1:7; y(j+11) = x(j) - 10; end
    y = y';
end
