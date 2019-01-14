% function [theta_t,phi_t,vn_t,aindx,T,N,B]=angles(Rt,start,missing,hp)

% use Quine's formula to compute bond/torsion angles
% bond angles are positive, within [0, pi]

% INPUT   Rt    -  coordinates of the points on curve
%                  default size: 3 x n, n>=3
%         start -  the index of first aa on protein, may not be 1
%         missing - indices of missing aa's
%         hp    -  handle of plotting, 1 - plot
% OUTPUT  theta -  bond angles
%         phi   -  torsion angles
%         vn    -  bond lengthes
%         T,N,B -  local Frenet frames, ignored after second change
% by Hu2, 21-04-2009; modified at 23-04-2009

% changed at 10-03-2010: if some aa's are missing, the angles
%                        will be taken as NaN. For each missing
%                        aa piece, # of angles will be two shorter.
%                        Indices are taken to be consistent with
%                        PDB, see "Convention_of_indexing2.pdf".


% changed at 18-12-2010: renamed as "angles"; length(theta)=n-2;
%                        length(phi)=n-3;

% changed at 11-07-2011: extended to the closed curve, which has
%                        no NaN value!

% [mt,nt]=size(Rt);
% if nt<length(Rt)
%     Rt=Rt';nt=mt;
% end
% theta_t=[];
% phi_t=[];
% vn_t=[];
% aindx=[];
% if nargin==1
%     [theta_t,phi_t,vn_t]=angle_piece(Rt);
% else
%     pn=start;
%     for im=1:size(missing,1)
%         mi=missing{im,1};
%         pi=pn:mi(1)-start+1;
%         aindx=[aindx pi(3:end)];
%         pn=mi(end)-start+3;
%         Ri=Rt(:,missing{im,2});
%         [theta,phi,vn,T,N,B]=angle_piece(Ri);
%         theta_t=[theta_t theta];
%         phi_t=[phi_t phi];
%         vn_t=[vn_t vn];
%         if hp==1
%             hold on
%             %         plot(theta,'b-')
%             %         pl=length(pi),tl=length(theta)
%             plot(pi(3:end),theta,'b-',pi(3:end),phi,'r-.')
%         end
%     end
% end

function [theta,phi,vn,T,N,B]=angles(R)
% function [theta,phi,vn,T,N,B]=angle_piece(R)
% modification at 02/06/2011: assign the nan values
%                             for ending points
% NOTE for index
%--------------------------------------------------------------------------
% t_i = (R_i+1 - R_i)/|R_i+1 - R_i|
% b_i = (t_i-1 x t_i)/|t_i-1 x t_i|
% n_i = b_i x t_i
% vn_i = |t_i|
% cos(theta_i) = t_i-1 * t_i
% cos(phi_i) = b_i-1 * b_i
% for example (x for nan)
%    R: 1 2 3 4 5... n-3 n-2 n-1 n
%    t: 1 2 3 4 5... n-3 n-2 n-1 x
%    b: x 2 3 4 5... n-3 n-2 n-1 x
%    n: x 2 3 4 5... n-3 n-2 n-1 x
%theta: x 2 3 4 5... n-3 n-2 n-1 x
%  phi: x x 3 4 5... n-3 n-2 n-1 x
%   vn: 1 2 3 4 5... n-3 n-2 n-1 x
%--------------------------------------------------------------------------
% m: number of rows
% n: number of column
% transfer R into 3xn matrix
[m,n]=size(R);
if n<length(R)
    R=R';n=m;
end

if norm(R(:,1)-R(:,end))>1e-1 % taken as open curve
    % initialization
    T=ones(3,n-1); % tangent vector
    B=T; % binormal vector
    N=T; % normal vector
    vn=ones(1,n-1); % bond length
    theta=ones(1,n-1); % curvature
    phi=ones(1,n-2); % torsion
    % calculate tangent vectors and bond length
    T=diff(R,1,2);
    for id=1:length(T)
        vn(id)=norm(T(:,id));
        T(:,id)=T(:,id)/vn(id); % normalization
    end
    % give random value to the first element of B, N, theta
    B(:,1)=rand(3,1);
    N(:,1)=rand(3,1);
    theta(1)=rand;    
    for id=2:length(T)
        % calculate bionormal vectors and normal vectors
        B(:,id)=cross(T(:,id-1),T(:,id));
        B(:,id)=B(:,id)/norm(B(:,id)); % normalization
        N(:,id)=cross(B(:,id),T(:,id));
        % calculate curvature and torsion
        theta(id)=-sign(dot(N(:,id),T(:,id-1)))*...
            acos(dot(T(:,id),T(:,id-1))); % theta(2) to theta(n-1)
        phi(id-1)=-sign(dot(B(:,id),N(:,id-1)))*...
            acos(dot(B(:,id),B(:,id-1))); % phi(1) to phi(n-2)
        % since B(:,1) is random, phi(1) is also random value
    end
    % ?
    theta(n-1)=-sign(dot(N(:,n-1),T(:,n-2)))*...
        acos(dot(T(:,n-1),T(:,n-2)));
    % delete the first element of B, N, theta, phi
    B(:,1)=[];
    % T(:,1)=[];
    N(:,1)=[];
    theta(1)=[];
    phi(1)=[];
    % vn(1)=[];
    % assign nan values
    T=[T [nan;nan;nan]];
    B=[[nan;nan;nan] B [nan;nan;nan]];
    N=[[nan;nan;nan] N [nan;nan;nan]];
    vn=[vn nan];
    theta=[nan theta nan];
    phi=[nan nan phi nan]; % NOTE:shift phi's index by +1!
    % Because the dot product of T,N,B's absolute value might be greater than 1;
    theta=real(theta);
    phi=real(phi);
    
%     % for discontinuous curve
%     for i=3:length(theta)-1
%             if vn(i)>4.1 || vn(i)<3.5
%                 if i<length(theta)-1
%                     theta(i-1:i+2)=nan;
%                     phi(i-1:i+2)=nan;
%                 else
%                     theta(i-1:i)=nan;
%                     phi(i-1:i)=nan;
%                 end
%             end
%     end
    
else % closed curve
    Re=[R R(:,2:3)];
    [thetae,phie,vne,Te,Ne,Be]=angles(Re);
    theta=[thetae(n) thetae(2:n)];
    phi=[phie(n) phie(n+1) phie(3:n)];
    vn=vne(1:n);
    T=[Te(:,n) Te(:,2:n)];
    N=[Ne(:,n) Ne(:,2:n)];
    B=[Be(:,n) Be(:,2:n)];
end