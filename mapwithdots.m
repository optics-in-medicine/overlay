function [DPC] = mapWithDots( I, p )
% %MAPWITHDOTS Summary of this function goes here
% %   Detailed explanation goes here
% % 
% clear all
% close all
% 
% load('test_files/rat_test1.mat')
% 
% I = fluo;
% p.levels = 3;
% p.high = 5.5;
p.dist = 'random';

[X,Y] = size( I );    
% return size of image
h1 = figure();
[C, h] = contour( I , p.levels);                                            % contours which define the levels of scalar values of I.
close(h1);

% 
% end
% 


counter = 1;
i = 1;

while( counter < length(C) )
        L(i) = C(2,counter);
        D(i) = C(1,counter);
        v{i} = [C(1, counter+1 : 10: counter + L(i)); ...
            C(2,counter+1: 10: counter+ L(i) )];
        mask(:,:,i) = poly2mask(C(1, counter+1 : counter + L(i)), ...
            C(2,counter+1:counter+ L(i) ), X, Y);
        counter = counter + L(i) + 1;
        i = i + 1;
end

u = unique(D);
l_x = 1000 .* 2.^(linspace(2,p.high,length(u)));
DPC = [];
u_x = length(u):-1:1;

for i = 1:length(u)
    rand_x{i} = (X - 1) .* rand( fix( l_x(i) ), 1 ) + 1;
    rand_y{i} = (Y - 1) .* rand( fix( l_x(i) ), 1 ) + 1;
end

for i = 1:length(D)
    if strcmpi(p.dist, 'random')
        % generate random vector.
        x = rand_x{find( u >= D(i), 1, 'first' )};
        y = rand_y{find( u >= D(i), 1, 'first' )};;
   
    elseif strcmpi(p.dist, 'uniform')
        dl = u_x( find( u >= D(i), 1, 'first' ) );
        
        x = []; y = [];
        for j = 1:dl:X
            for k = 1:dl:Y
                x = [x; j];
                y = [y; k];
            end
        end
    end
    
%     DPC = [DPC; x( logical( mask(:,:,i) ) );
    in = inpolygon(x,y,v{i}(1,:),v{i}(2,:));
    DPC = [DPC; [x(in) y(in)]];
    clear x y
end


% 
% image(wl); hold on; plot(DPC(:,1), DPC(:,2), 'o', 'MarkerSize', 2, ...
% 'MarkerEdgeColor', [0.0 0.0 0.5], 'MarkerFaceColor',[0.0,0.0,0.5]' ); hold off
% 
