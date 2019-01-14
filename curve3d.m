function [R,T,N,B]=curve3d(theta,phi,ds)
% this is a clean version of the curve reconstruction from angles
% the main change is the indexing
% Ref: curve3d2.m, curve3d5.m
%      DFF.pdf (the note about the convention of indexing)

% standardize the angles
% tl=length(theta);
% pl=length(phi);
% L=pl+3;
% tnew=ones(L,1);
% pnew=tnew;
% if tl==pl
%     tnew(1)=nan;tnew(2)=rand;
%     pnew(1)=nan; pnew(2)=nan;
%     tnew(3:end-1)=theta;
%     pnew(3:end-1)=phi;
%     tnew(end)=nan;
%     pnew(end)=nan;
% elseif tl==(pl+1)
%     tnew(1)=nan;
%     pnew(1)=nan; pnew(2)=nan;
%     tnew(2:end-1)=theta;
%     pnew(3:end-1)=phi;
%     tnew(end)=nan;
%     pnew(end)=nan;
% end

L=length(theta);
tnew=theta;
pnew=phi;
% default bond length is 3.8 angstroms
if nargin<3
    ds=3.8*ones(L,1);
end

% for open curve
% if isnan(tnew(1)) || norm(tnew(1)-tnew(end)) >1e-2 ...
%         || norm(pnew(1)-pnew(end))>1e-2
    
    R=ones(L,3); % NOTE: coordinates vector have the same length as theta vector!
    T=R;
    N=R;
    B=R;
    % for index = 1
    N(1,:)=[nan nan nan];
    B(1,:)=[nan nan nan];
    R(1,:)=ds(1)*[-cos(tnew(2)), sin(tnew(2)), 0];
    T(1,:)=[cos(tnew(2)), -sin(tnew(2)), 0];
    % for index = 2
    R(2,:)=[0,0,0]; % NOTE: choose the second coordinates to be the original point!
    T(2,:)=[1 0 0]; % t_2 point to x-axis
    N(2,:)=[0 1 0]; % n_2 point to y-axis
    B(2,:)=[0 0 1]; % b_2 point to z-axis
    % for index = 3 ... L-1
    for id=2:L-2
        d=ds(id);
%             N(id+1,:)=cos(theta(id))*cos(phi(id))*N(id,:)+...
%                 cos(theta(id))*sin(phi(id))*B(id,:)-...
%                 sin(theta(id))*T(id,:);
%             B(id+1,:)=-sin(pnew(id+1))*N(id,:)+...
%                 cos(pnew(id+1))*B(id,:);
%             T(id+1,:)=sin(tnew(id+1))*cos(pnew(id+1))*N(id,:)+...
%                 sin(tnew(id+1))*sin(pnew(id+1))*B(id,:)+cos(tnew(id+1))*T(id,:);
%             T(id+1,:)=T(id+1,:)-dot(T(id+1,:),B(id+1,:))*B(id+1,:);
%             T(id+1,:)=T(id+1,:)/norm(T(id+1,:));
%             N(id+1,:)=cross(B(id+1,:),T(id+1,:));
%             R(id+1,:)=R(id,:)+d*T(id,:);
%             if theta(id+1)<0
%                 theta(id+1)=-theta(id+1);
%                 phi(id)=phi(id)+pi;
%             end     % not suitable!!!!!!!!!
        Pt=[0 T(id,3) -T(id,2);-T(id,3) 0 T(id,1);T(id,2) -T(id,1) 0];
        Qt=eye(3)-sin(pnew(id+1))*Pt+(1-cos(pnew(id+1)))*Pt^2;
        B(id+1,:)=B(id,:)*Qt';
%         B(id+1,:)=B(id+1,:)/norm(B(id+1,:));
        Pb=[0 B(id+1,3) -B(id+1,2);...
            -B(id+1,3) 0 B(id+1,1);...
            B(id+1,2) -B(id+1,1) 0];
        Qb=eye(3)-sin(tnew(id+1))*Pb+(1-cos(tnew(id+1)))*Pb^2;
        T(id+1,:)=T(id,:)*Qb';
        T(id+1,:)=T(id+1,:)-dot(T(id+1,:),B(id+1,:))*B(id+1,:);
        T(id+1,:)=T(id+1,:)/norm(T(id+1,:));
        N(id+1,:)=cross(B(id+1,:),T(id+1,:));
        R(id+1,:)=R(id,:)+d*T(id,:);
    end
    % for index = L
    R(L,:)=R(L-1,:)+ds(L-1)*T(L-1,:);
    T(L,:)=[nan nan nan];
    N(L,:)=[nan nan nan];
    B(L,:)=[nan nan nan];
    % transfer R, T, N, B into 3xL vectors
    R=R';
    T=T';
    N=N';
    B=B';
    
% for closed curve
% else norm(tnew(1)-tnew(end)) <1e-2 && norm(pnew(1)-pnew(end))<1e-2;
%     R=ones(3,L);
%     T=R;N=R;B=R;
%     te=[tnew tnew(2:4)];
%     pe=[pnew(end) pnew pnew(2:4)];
%     [Re,Te,Ne,Be]=curve3d(te,pe);
%     R=Re(:,2:L+1);
%     T=Te(:,2:L+1);
%     N=Ne(:,2:L+1);
%     B=Be(:,2:L+1);
% end