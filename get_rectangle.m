function [x, y] = get_rectangle(I, map, kk, wintx, winty)

  while true,
    
    figure(2);
    fig2 = gcf;
    image(I);
    colormap(map);
    set(fig2,'color',[1 1 1]);
    
    title(['Click on the four extreme corners of the rectangular pattern (first corner = origin)... Image ' num2str(kk)]);
    
    disp('Click on the four extreme corners of the rectangular complete pattern (the first clicked corner is the origin)...');
    
    x= [];y = [];
    figure(fig2); hold on;
    [x,y] = getline(fig2,'closed');
    %
    %   for count = 1:4,
    %     [xi,yi] = ginput4(1);
    %     [xxi] = cornerfinder([xi;yi],I,winty,wintx);
    %     xi = xxi(1);
    %     yi = xxi(2);
    %     figure(2);
    %     plot(xi,yi,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2);
    %     plot(xi + [wintx+.5 -(wintx+.5) -(wintx+.5) wintx+.5 wintx+.5],yi + [winty+.5 winty+.5 -(winty+.5) -(winty+.5)  winty+.5],'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
    %     x = [x;xi];
    %     y = [y;yi];
    %     plot(x,y,'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
    %     drawnow;
    %   end;
    x = x(1:4); y = y(1:4);
    plot(x,y,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2);
    for i = 1:4,
      xi = x(i);
      yi = y(i);
      plot(xi + [wintx+.5 -(wintx+.5) -(wintx+.5) wintx+.5 wintx+.5],yi + [winty+.5 winty+.5 -(winty+.5) -(winty+.5)  winty+.5],'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
    end
    plot([x;x(1)],[y;y(1)],'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
    drawnow;
    hold off;
    
    res = input('Redo rectangle? 0 = no (default), 1 = yes: ');
    if isempty(res) || res == 0,
      break;
    end
  end

end
