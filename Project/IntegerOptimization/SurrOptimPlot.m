function stop = SurrOptimPlot(x,~,state,Tdata,VData,Res,ThVal,ThBeta)
% SurrOptimPlot plots the best temperature curve at each iteration.
% Copyright (c) 2019, MathWorks, Inc.

stop = false;

switch state
    case 'init'
        fig = findobj(0,'Tag','tempCurve');
        if isempty(fig)
            figure('Position',[40 535 800 520],'Tag','tempCurve');
        else
            figure(fig(end));
        end
        set(gca,'Tag','ax1');
        set(gca,'YLim',[0.09 0.19]);
        grid on;
        hold on;
        plot(Tdata,VData,'-*b');
        xlabel('Temperature (^oC)');
        ylabel('Voltage (V)');
        title('Thermistor Network Temperature Curve','FontSize',12);
        x0 = [57,63,10,64,6,2]; % random initial point
        bestV = voltageCurve(Tdata,x0,Res,ThVal,ThBeta);
        plotBest = plot(Tdata,bestV,'-or');
        set(plotBest,'Tag','bestVLine'); % Update voltage curve
        legend('Ideal Curve','surrogateopt Solution','Location','southeast');
        drawnow;
    case 'iter'
        fig = findobj(0,'Tag','tempCurve');
        figure(fig(end));
        bestV = voltageCurve(Tdata,x,Res,ThVal,ThBeta);
        ax1 = findobj(get(gcf,'Children'),'Tag','ax1');
        plotBest = findobj(get(ax1,'Children'),'Tag','bestVLine');
        set(plotBest, 'Ydata', bestV); % Update voltage curve
        drawnow;
    case 'done'
        fig = findobj(0,'Tag','tempCurve');
        figure(fig(end));
        s{1} = sprintf('Optimal solution found by surrogateopt: \n');
        s{2} = sprintf('R1 = %6.0f ohms \n', Res(x(1)));
        s{3} = sprintf('R2 = %6.0f ohms \n', Res(x(2)));
        s{4} = sprintf('R3 = %6.0f ohms \n', Res(x(3)));
        s{5} = sprintf('R4 = %6.0f ohms \n', Res(x(4)));
        s{6} = sprintf('TH1 = %6.0f ohms, %6.0f beta \n', ...
        ThVal(x(5)), ThBeta(x(5)));
        s{7} = sprintf('TH2 = %6.0f ohms, %6.0f beta \n', ...
        ThVal(x(6)), ThBeta(x(6)));
        % Display the text in "s" in an annotation object on the
        % temperature curve figure.  The four-element vector is used to 
        % specify the location.
        annotation(gcf, 'textbox', [0.15 0.45 0.22 0.45], 'String', s,...
            'BackGroundColor','w','FontSize',8);
        hold off;
end
