% Cleaned-up version of init_calib.m

fprintf(1,'\nProcessing image %d...\n',kk);

eval(['I = I_' num2str(kk) ';']);

if exist(['wintx_' num2str(kk)]),
    
    eval(['wintxkk = wintx_' num2str(kk) ';']);
    
    if ~isempty(wintxkk) & ~isnan(wintxkk),
        
        eval(['wintx = wintx_' num2str(kk) ';']);
        eval(['winty = winty_' num2str(kk) ';']);
        
    end;
end;


fprintf(1,'Using (wintx,winty)=(%d,%d) - Window size = %dx%d      (Note: To reset the window size, run script clearwin)\n',wintx,winty,2*wintx+1,2*winty+1);
%fprintf(1,'Note: To reset the window size, clear wintx and winty and run ''Extract grid corners'' again\n');

if exist('load_corner_file','var') && ~isempty(load_corner_file),
  tmp = load(load_corner_file);
  
  % load data 
  dX = tmp.(sprintf('dX_%d',kk));
  dY = tmp.(sprintf('dY_%d',kk));
  wintx = tmp.(sprintf('wintx_%d',kk));
  winty = tmp.(sprintf('winty_%d',kk));
  x = tmp.(sprintf('x_%d',kk));
  X = tmp.(sprintf('X_%d',kk));
  n_sq_x = tmp.(sprintf('n_sq_x_%d',kk));
  n_sq_y = tmp.(sprintf('n_sq_y_%d',kk));
  
  grid_pts = x;
  x_box_kk = [grid_pts(1,:)-(wintx+.5);grid_pts(1,:)+(wintx+.5);grid_pts(1,:)+(wintx+.5);grid_pts(1,:)-(wintx+.5);grid_pts(1,:)-(wintx+.5)];
  y_box_kk = [grid_pts(2,:)-(winty+.5);grid_pts(2,:)-(winty+.5);grid_pts(2,:)+(winty+.5);grid_pts(2,:)+(winty+.5);grid_pts(2,:)-(winty+.5)];
  ind_corners = [1 n_sq_x+1 (n_sq_x+1)*n_sq_y+1 (n_sq_x+1)*(n_sq_y+1)]; % index of the 4 corners
  ind_orig = (n_sq_x+1)*n_sq_y + 1;
  xorig = grid_pts(1,ind_orig);
  yorig = grid_pts(2,ind_orig);
  dxpos = mean([grid_pts(:,ind_orig) grid_pts(:,ind_orig+1)]');
  dypos = mean([grid_pts(:,ind_orig) grid_pts(:,ind_orig-n_sq_x-1)]');
  delta = 30;
  
  ind_corners = [1 n_sq_x+1 (n_sq_x+1)*n_sq_y+1 (n_sq_x+1)*(n_sq_y+1)]; % index of the 4 corners
  ind_orig = (n_sq_x+1)*n_sq_y + 1;

  
  figure(3);
  clf;
  image(I); colormap(map); hold on;
  plot(grid_pts(1,:)+1,grid_pts(2,:)+1,'r+');
  plot(x_box_kk+1,y_box_kk+1,'-b');
  plot(grid_pts(1,ind_corners)+1,grid_pts(2,ind_corners)+1,'mo');
  plot(xorig+1,yorig+1,'*m');
  %h = text(xorig+delta*vO(1),yorig+delta*vO(2),'O');
  %set(h,'Color','m','FontSize',14);
  %h2 = text(dxpos(1)+delta*vX(1),dxpos(2)+delta*vX(2),'dX');
  %set(h2,'Color','g','FontSize',14);
  %h3 = text(dypos(1)+delta*vY(1),dypos(2)+delta*vY(2),'dY');
  %set(h3,'Color','g','FontSize',14);
  for tmpi = 1:size(grid_pts,2),
    text(grid_pts(1,tmpi)+1,grid_pts(2,tmpi)+1,num2str(tmpi),'Color','r','FontSize',14);
  end
  for tmpi = 1:numel(ind_corners),
    text(grid_pts(1,ind_corners(tmpi))+1,grid_pts(2,ind_corners(tmpi))+1,sprintf('Corner %d',tmpi),'Color','m','FontSize',14);
  end

  xlabel('Xc (in camera frame)');
  ylabel('Yc (in camera frame)');
  title('Extracted corners');
  zoom on;
  drawnow;
  hold off;
  
else
  
  while true
    [x, y] = get_rectangle(I, map, kk, wintx, winty);
    [Xc,good,bad,type] = cornerfinder([x';y'],I,winty,wintx); % the four corners
    
    x = Xc(1,:)';
    y = Xc(2,:)';
    
    
    % Sort the corners:
    x_mean = mean(x);
    y_mean = mean(y);
    x_v = x - x_mean;
    y_v = y - y_mean;
    
    theta = atan2(-y_v,x_v);
    [junk,ind] = sort(theta);
    
    [junk,ind] = sort(mod(theta-theta(1),2*pi));
    
    %ind = ind([2 3 4 1]);
    
    ind = ind([4 3 2 1]); %-> New: the Z axis is pointing uppward
    
    % x = x(ind);
    % y = y(ind);
    x1= x(1); x2 = x(2); x3 = x(3); x4 = x(4);
    y1= y(1); y2 = y(2); y3 = y(3); y4 = y(4);
    
    
    % Find center:
    p_center = cross(cross([x1;y1;1],[x3;y3;1]),cross([x2;y2;1],[x4;y4;1]));
    x5 = p_center(1)/p_center(3);
    y5 = p_center(2)/p_center(3);
    
    % center on the X axis:
    x6 = (x3 + x4)/2;
    y6 = (y3 + y4)/2;
    
    % center on the Y axis:
    x7 = (x1 + x4)/2;
    y7 = (y1 + y4)/2;
    
    % Direction of displacement for the X axis:
    vX = [x6-x5;y6-y5];
    vX = vX / norm(vX);
    
    % Direction of displacement for the X axis:
    vY = [x7-x5;y7-y5];
    vY = vY / norm(vY);
    
    % Direction of diagonal:
    vO = [x4 - x5; y4 - y5];
    vO = vO / norm(vO);
    
    delta = 30;
    
    
    figure(2);
    image(I);
    colormap(map);
    hold on;
    plot([x;x(1)],[y;y(1)],'g-');
    plot(x,y,'og');
    hx=text(x6 + delta * vX(1) ,y6 + delta*vX(2),'X');
    set(hx,'color','g','Fontsize',14);
    hy=text(x7 + delta*vY(1), y7 + delta*vY(2),'Y');
    set(hy,'color','g','Fontsize',14);
    hO=text(x4 + delta * vO(1) ,y4 + delta*vO(2),'O','color','g','Fontsize',14);
    hold off;
    res = input('Redo rectangle? 0 = no (default), 1 = yes: ');
    if isempty(res) || res == 0,
      break;
    end
  end
      
  
  if manual_squares,
    
    n_sq_x = input(['Number of squares along the X direction ([]=' num2str(n_sq_x_default) ') = ']); %6
    if isempty(n_sq_x), n_sq_x = n_sq_x_default; end;
    n_sq_y = input(['Number of squares along the Y direction ([]=' num2str(n_sq_y_default) ') = ']); %6
    if isempty(n_sq_y), n_sq_y = n_sq_y_default; end;
    
  else
    
    % Try to automatically count the number of squares in the grid
    
    n_sq_x1 = count_squares(I,x1,y1,x2,y2,wintx);
    n_sq_x2 = count_squares(I,x3,y3,x4,y4,wintx);
    n_sq_y1 = count_squares(I,x2,y2,x3,y3,wintx);
    n_sq_y2 = count_squares(I,x4,y4,x1,y1,wintx);
    
    
    
    % If could not count the number of squares, enter manually
    
    if (n_sq_x1~=n_sq_x2)|(n_sq_y1~=n_sq_y2),
      
      
      disp('Could not count the number of squares in the grid. Enter manually.');
      n_sq_x = input(['Number of squares along the X direction ([]=' num2str(n_sq_x_default) ') = ']); %6
      if isempty(n_sq_x), n_sq_x = n_sq_x_default; end;
      n_sq_y = input(['Number of squares along the Y direction ([]=' num2str(n_sq_y_default) ') = ']); %6
      if isempty(n_sq_y), n_sq_y = n_sq_y_default; end;
      
    else
      
      n_sq_x = n_sq_x1;
      n_sq_y = n_sq_y1;
      
    end;
    
  end;
  
  
  n_sq_x_default = n_sq_x;
  n_sq_y_default = n_sq_y;
  
  
  if (exist('dX')~=1)|(exist('dY')~=1), % This question is now asked only once
    % Enter the size of each square
    
    dX = input(['Size dX of each square along the X direction ([]=' num2str(dX_default) 'mm) = ']);
    dY = input(['Size dY of each square along the Y direction ([]=' num2str(dY_default) 'mm) = ']);
    if isempty(dX), dX = dX_default; else dX_default = dX; end;
    if isempty(dY), dY = dY_default; else dY_default = dY; end;
    
  else
    
    fprintf(1,['Size of each square along the X direction: dX=' num2str(dX) 'mm\n']);
    fprintf(1,['Size of each square along the Y direction: dY=' num2str(dY) 'mm   (Note: To reset the size of the squares, clear the variables dX and dY)\n']);
    %fprintf(1,'Note: To reset the size of the squares, clear the variables dX and dY\n');
    
  end;
  
  
  % Compute the inside points through computation of the planar homography (collineation)
  
  a00 = [x(1);y(1);1];
  a10 = [x(2);y(2);1];
  a11 = [x(3);y(3);1];
  a01 = [x(4);y(4);1];
  
  
  % Compute the planar collineation: (return the normalization matrix as well)
  
  [Homo,Hnorm,inv_Hnorm] = compute_homography([a00 a10 a11 a01],[0 1 1 0;0 0 1 1;1 1 1 1]);
  
  
  % Build the grid using the planar collineation:
  
  x_l = ((0:n_sq_x)'*ones(1,n_sq_y+1))/n_sq_x;
  y_l = (ones(n_sq_x+1,1)*(0:n_sq_y))/n_sq_y;
  pts = [x_l(:) y_l(:) ones((n_sq_x+1)*(n_sq_y+1),1)]';
  
  XX = Homo*pts;
  XX = XX(1:2,:) ./ (ones(2,1)*XX(3,:));
  
  
  % Complete size of the rectangle
  
  W = n_sq_x*dX;
  L = n_sq_y*dY;
  
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL STUFF IN THE CASE OF HIGHLY DISTORTED IMAGES %%%%%%%%%%%%%
  figure(2);
  hold on;
  plot(XX(1,:),XX(2,:),'r+');
  title('The red crosses should be close to the image corners');
  hold off;
  
  disp('If the guessed grid corners (red crosses on the image) are not close to the actual corners,');
  disp('it is necessary to enter an initial guess for the radial distortion factor kc (useful for subpixel detection)');
  quest_distort = input('Need of an initial guess for distortion? ([]=no, other=yes) ');
  
  quest_distort = ~isempty(quest_distort);
  
  if quest_distort,
    % Estimation of focal length:
    c_g = [size(I,2);size(I,1)]/2 + .5;
    f_g = Distor2Calib(0,[[x(1) x(2) x(4) x(3)] - c_g(1);[y(1) y(2) y(4) y(3)] - c_g(2)],1,1,4,W,L,[-W/2 W/2 W/2 -W/2;L/2 L/2 -L/2 -L/2; 0 0 0 0],100,1,1);
    f_g = mean(f_g);
    script_fit_distortion;
  end;

  quest_distort = input('fix by hand? ([]=no, other=yes) ');
  hand_clicked = false;
  if quest_distort
    disp('use the figure''s zoom tools to focus on a region. then press enter.');
    figure(100);
    clf
    ax = gca;
    disableDefaultInteractivity(ax);
    image(I);
    colormap(map);
    hold on
    pause;

    disp('click on corners.');
    % for iz = 1:42
    %     [x, y] = ginputc(1);
    %     plot(x, y, 'xr');
    %     XX(1, iz) = x;
    %     XX(2, iz) = y;
    % end
    [x, y] = ginputc(42, 'showpoints', true);
	XX = [x'; y'];
    hand_clicked = true;
  end
  %%%%%%%%%%%%%%%%%%%%% END ADDITIONAL STUFF IN THE CASE OF HIGHLY DISTORTED IMAGES %%%%%%%%%%%%%
  
  Np = (n_sq_x+1)*(n_sq_y+1);
  
  disp('Corner extraction...');
  
  grid_pts = cornerfinder(XX,I,winty,wintx); %%% Finds the exact corners at every points!
  if hand_clicked == true
      grid_pts = XX;
  end
  
  
  %save all_corners x y grid_pts
  
  grid_pts = grid_pts - 1; % subtract 1 to bring the origin to (0,0) instead of (1,1) in matlab (not necessary in C)
  
  
  
  ind_corners = [1 n_sq_x+1 (n_sq_x+1)*n_sq_y+1 (n_sq_x+1)*(n_sq_y+1)]; % index of the 4 corners
  ind_orig = (n_sq_x+1)*n_sq_y + 1;
  xorig = grid_pts(1,ind_orig);
  yorig = grid_pts(2,ind_orig);
  dxpos = mean([grid_pts(:,ind_orig) grid_pts(:,ind_orig+1)]');
  dypos = mean([grid_pts(:,ind_orig) grid_pts(:,ind_orig-n_sq_x-1)]');
  
  
  x_box_kk = [grid_pts(1,:)-(wintx+.5);grid_pts(1,:)+(wintx+.5);grid_pts(1,:)+(wintx+.5);grid_pts(1,:)-(wintx+.5);grid_pts(1,:)-(wintx+.5)];
  y_box_kk = [grid_pts(2,:)-(winty+.5);grid_pts(2,:)-(winty+.5);grid_pts(2,:)+(winty+.5);grid_pts(2,:)+(winty+.5);grid_pts(2,:)-(winty+.5)];
  
  figure(3);
  image(I); colormap(map); hold on;
  plot(grid_pts(1,:)+1,grid_pts(2,:)+1,'r+');
  plot(x_box_kk+1,y_box_kk+1,'-b');
  plot(grid_pts(1,ind_corners)+1,grid_pts(2,ind_corners)+1,'mo');
  plot(xorig+1,yorig+1,'*m');
  h = text(xorig+delta*vO(1),yorig+delta*vO(2),'O');
  set(h,'Color','m','FontSize',14);
  h2 = text(dxpos(1)+delta*vX(1),dxpos(2)+delta*vX(2),'dX');
  set(h2,'Color','g','FontSize',14);
  h3 = text(dypos(1)+delta*vY(1),dypos(2)+delta*vY(2),'dY');
  set(h3,'Color','g','FontSize',14);
  xlabel('Xc (in camera frame)');
  ylabel('Yc (in camera frame)');
  title('Extracted corners');
  zoom on;
  drawnow;
  hold off;
  
  
  Xi = reshape(([0:n_sq_x]*dX)'*ones(1,n_sq_y+1),Np,1)';
  Yi = reshape(ones(n_sq_x+1,1)*[n_sq_y:-1:0]*dY,Np,1)';
  Zi = zeros(1,Np);
  
  Xgrid = [Xi;Yi;Zi];
  
  
  % All the point coordinates (on the image, and in 3D) - for global optimization:
  
  x = grid_pts;
  X = Xgrid;
  
  
  % Saves all the data into variables:
end

eval(['dX_' num2str(kk) ' = dX;']);
eval(['dY_' num2str(kk) ' = dY;']);  

eval(['wintx_' num2str(kk) ' = wintx;']);
eval(['winty_' num2str(kk) ' = winty;']);

eval(['x_' num2str(kk) ' = x;']);
eval(['X_' num2str(kk) ' = X;']);

eval(['n_sq_x_' num2str(kk) ' = n_sq_x;']);
eval(['n_sq_y_' num2str(kk) ' = n_sq_y;']);
