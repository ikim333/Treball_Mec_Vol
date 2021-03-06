%Treball mecanica de vol
clear all 
clc
%% Problem Data

m=288778;   % [kg]
S=511;      % [m^2]
MAC=8.32;   % [m]
b=59.74;    % [m]
CD0=0.025; 
h=6069;     % [m]

Ix=2.47e7;  % [kgm2]
Iy=4.49e7;  % [kgm2]
Iz=6.74e7;  % [kgm2]
Ixz=1.32e6; % [kgm2]

Ixp=Ix-Ixz^2/Iz;
Izp=Iz-Ixz^2/Ix;
Ixzp=Ixz/(Ix*Iz-Ixz^2);

mach = 0.65;
a = sqrt(287*294*1.15); % [m/s]
theta0=0;
u0=a*mach;              % [m/s]
g=9.81;                 % [m/s^2]
dens=1.225*exp(-(g/(287*(273+21)))*(h));
CL0=(2*m*g)/(dens*S*u0^2);
Cw0=(m*g)/(1/2*dens*u0^2*S);

save('data_mv.mat', 'm', 'S', 'MAC', 'b', 'CD0', 'h', 'Ix', 'Iy','Iz','Ixz','Ixp','Izp','Ixzp','mach','a','theta0','u0','g','dens','CL0','Cw0'); 
%% Uncontrolled Longitudinal Motion
%% QUESTION 1: 
%Find the eigenvalues and their corresponding eigenvectors

%      CT       CD      CL      Cm
data_1=[-0.055   0       0.13    0.013;  %û
        0        0.2     4.4     -1.0;   %alpha
        0        0       5.65    -20.5;  %^q
        0        0       6.6     -4.0];  %alpha_prima

Cxu = data_1(1,1)-data_1(1,2);  % Cxu = CTu - CDu
Czu = -data_1(1,3);             % Czu = -CLu
Cxa = CL0-data_1(2,2);          % Cxa = CL0 - CDa
Cza = -data_1(2,3)-CD0;         % Cza = -CLa - CD0
Cxq = -data_1(3,2);             % Cxq = -CDq
Czq = -data_1(3,3);             % Czq = -CLq
Cxap = -data_1(4,2);            % Cxap = -CDap
Czap = -data_1(4,3);            % Czap = -CLap

% Longitudinal Stability Derivatives
%           X                                 Z                                M
ctrlderiv=[0.5*dens*u0*S*Cxu         -dens*u0*S*Cw0+0.5*dens*u0*S*Czu    0.5*dens*u0*S*MAC*data_1(1,4);      %u
      0.5*dens*u0*S*Cxa         0.5*dens*u0*S*Cza                   0.5*dens*u0*S*MAC*data_1(2,4);      %w
      0.25*dens*u0*S*MAC*Cxq    0.25*dens*u0*S*MAC*Czq              0.25*dens*u0*S*MAC^2*data_1(3,4);   %q
      0.25*dens*S*MAC*Cxap      0.25*dens*S*MAC*Czap                0.25*dens*S*MAC^2*data_1(4,4)];     %w·

A=zeros(4);

% Linearized Dynamic System
% Delta u Row
A(1,1)=ctrlderiv(1,1)/m;
A(1,2)=ctrlderiv(2,1)/m;
A(1,4)=-g;

% Delta w· Row
A(2,1)=ctrlderiv(1,2)/(m-ctrlderiv(4,2));
A(2,2)=ctrlderiv(2,2)/(m-ctrlderiv(4,2));
A(2,3)=(ctrlderiv(3,2)+m*u0)/(m-ctrlderiv(4,2));

% q· Row
A(3,1)=(1/Iy)*(ctrlderiv(1,3)+ctrlderiv(4,3)*ctrlderiv(1,2)/(m-ctrlderiv(4,2)));
A(3,2)=(1/Iy)*(ctrlderiv(2,3)+ctrlderiv(4,3)*ctrlderiv(2,2)/(m-ctrlderiv(4,2)));
A(3,3)=(1/Iy)*(ctrlderiv(3,3)+ctrlderiv(4,3)*(ctrlderiv(3,2)+m*u0)/(m-ctrlderiv(4,2)));

% Delta Theta· Row
A(4,3)=1;

% Short Period Approximation
Ashort=zeros(3);

Ashort(1,1)=A(2,2);
Ashort(1,2)=A(2,3);
Ashort(2,1)=A(3,2);
Ashort(2,2)=A(3,3);
Ashort(3,2)=A(4,3);

% Fugoid Approximation
Afug=zeros(3);

Afug(1,1)=A(1,1)-(A(3,1)/A(3,3))*A(1,3);
Afug(1,2)=A(1,2)-(A(3,2)/A(3,3))*A(1,3);
Afug(1,3)=A(1,4);
Afug(2,1)=A(2,1)-(A(3,1)/A(3,3))*A(2,3);
Afug(2,2)=A(2,2)-(A(3,2)/A(3,3))*A(2,3);
Afug(3,1)=-A(3,1)/A(3,3);
Afug(3,2)=-A(3,2)/A(3,3);

[eigenvectors,eigenvalues]=eig(A);
eigenvalues=diag(eigenvalues);
[eigenvectors_short,eigenvalues_short]=eig(Ashort);
eigenvalues_short=diag(eigenvalues_short);
[eigenvectors_fug,eigenvalues_fug]=eig(Afug);
eigenvalues_fug=diag(eigenvalues_fug);

% Plot Q1
% Convert to polar in the report
disp('Question 1 results:');
display(eigenvalues);
display(eigenvalues_short);
display(eigenvalues_fug);


%% QUESTION 2 
% Plot in the complex plane the locus of the eigenvalues when the 
% stability derivative Cmq varies within an interval +- 50% about the
% nominal value, but the rest of stability derivatives remain unchanged

figure;
hold on;
grid on;
xlabel("Re");
ylabel("Im");

for i =1:11
    % Longitudinal Stability Derivatives
    %      CT       CD      CL      Cm
    data_1_2=[-0.055   0       0.13    0.013;  %û
            0        0.2     4.4     -1.0;   %alpha
            0        0       5.65    -10.25-2.05*(i-1);  %^q As the value from the cmq in Q1 was 20.5, we will make a range with +-50% of it
            0        0       6.6     -4.0];  %alpha_prima

    Cxu = data_1_2(1,1)-data_1_2(1,2);  % Cxu = CTu - CDu
    Czu = -data_1_2(1,3);             % Czu = -CLu
    Cxa = CL0-data_1_2(2,2);          % Cxa = CL0 - CDa
    Cza = -data_1_2(2,3)-CD0;         % Cza = -CLa - CD0
    Cxq = -data_1_2(3,2);             % Cxq = -CDq
    Czq = -data_1_2(3,3);             % Czq = -CLq
    Cxap = -data_1_2(4,2);            % Cxap = -CDap
    Czap = -data_1_2(4,3);            % Czap = -CLap
    
    %           X                       Z                           M
    ctrlderiv_cmq=[0.5*dens*u0*S*Cxu      -dens*u0*S*Cw0+0.5*dens*u0*S*Czu   0.5*dens*u0*S*MAC*data_1_2(1,4);      %u
              0.5*dens*u0*S*Cxa      0.5*dens*u0*S*Cza                 0.5*dens*u0*S*MAC*data_1_2(2,4);      %w
              0.25*dens*u0*S*MAC*Cxq 0.25*dens*u0*S*MAC*Czq            0.25*dens*u0*S*MAC^2*data_1_2(3,4);   %q
              0.25*dens*S*MAC*Cxap   0.25*dens*S*MAC*Czap              0.25*dens*S*MAC^2*data_1_2(4,4)];     %w·

    A_cmq=zeros(4);
    A_cmq(1,1)=ctrlderiv_cmq(1,1)/m;
    A_cmq(1,2)=ctrlderiv_cmq(2,1)/m;
    A_cmq(1,4)=-g;
    A_cmq(2,1)=ctrlderiv_cmq(1,2)/(m-ctrlderiv_cmq(4,2));
    A_cmq(2,2)=ctrlderiv_cmq(2,2)/(m-ctrlderiv_cmq(4,2));
    A_cmq(2,3)=(ctrlderiv_cmq(3,2)+m*u0)/(m-ctrlderiv_cmq(4,2));
    A_cmq(3,1)=(1/Iy)*(ctrlderiv_cmq(1,3)+ctrlderiv_cmq(4,3)*ctrlderiv_cmq(1,2)/(m-ctrlderiv_cmq(4,2)));
    A_cmq(3,2)=(1/Iy)*(ctrlderiv_cmq(2,3)+ctrlderiv_cmq(4,3)*ctrlderiv_cmq(2,2)/(m-ctrlderiv_cmq(4,2)));
    A_cmq(3,3)=(1/Iy)*(ctrlderiv_cmq(3,3)+ctrlderiv_cmq(4,3)*(ctrlderiv_cmq(3,2)+m*u0)/(m-ctrlderiv_cmq(4,2)));
    A_cmq(4,3)=1;
    
    cmq(i)=-10.25-2.05*(i-1);
    [eigenvectors_cmq,eigenvalues_cmq]=eig(A_cmq);
    eigenvalues_cmq=diag(eigenvalues_cmq);
    x=real(eigenvalues_cmq);
    y=imag(eigenvalues_cmq);
    scatter(x,y,25,'filled')
end
title('Eigenvalues variation with Cmq')
%legend('[-10.25,-12.3,-14.35,-16.4,-18.45,-20.5,-22.55,-24.6,-26.65,-28.7,-30.75]')


%% QUESTION 3
% For the lowest value of Cmq plot the short period mode corresponding to
% an initial perturbed angle of attack alpha = 3º

tf=200; %[s]
Nstep=201;
tspan=linspace(0,tf,Nstep);
options=odeset("RelTol",1e-12,"AbsTol",1e-12);

xi=[0 0 0 0];

[t,x]=ode45(@section3,tspan,xi,options);
figure
hold on
grid on
plot(t(:),x(:,1))    
xlabel('t [s]')
ylabel('\Deltau [m/s]')

figure
hold on
grid on
plot(t(:),x(:,2))
xlabel('t [s]')
ylabel('w [m/s]')

figure
hold on
grid on
plot(t(:),x(:,3))
xlabel('t [s]')
ylabel('q [rad/s]')

figure
hold on
grid on
plot(t(:),x(:,4))
xlabel('t [s]')
ylabel('\Delta\Theta [rad]')



