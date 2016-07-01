function [vx vy] = calculateVelocityConditions(xx,yy,S,Nx,Ny,Nt)

vx = zeros(Nx,Ny,Nt);vy = zeros(Nx,Ny,Nt);

for nnn=1:Nt,
    kk = nnn;
    for ii =1:Nx,
        for jj =1:Ny
            
            vv_x = xx - xx(ii,jj);vv_y = yy - yy(ii,jj);
            vhatx = vv_x./(vv_x.^2 + vv_y.^2 + eps);
            vhaty = vv_y./(vv_x.^2 + vv_y.^2 + eps);
            
%             vhatx = vv_x;
%             vhaty = vv_y;
            
            vx(:,:,nnn) = S(ii,jj,kk)*vhatx/2/pi + vx(:,:,nnn);
            vy(:,:,nnn) = S(ii,jj,kk)*vhaty/2/pi + vy(:,:,nnn);
        end
    end
end


% 
vx = vx - reshape(repmat(reshape(vx(:,:,3),Nx*Ny,1),1,Nt),Nx,Ny,Nt);
vy = vy - reshape(repmat(reshape(vy(:,:,3),Nx*Ny,1),1,Nt),Nx,Ny,Nt);


vx = vx/(Nx*Ny)/(Nx-1)/(Ny-1);
vy = vy/(Nx*Ny)/(Nx-1)/(Ny-1);

end