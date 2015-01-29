%SUBPLOTS - Creates Matrix of Subplots
%
%sp = subplots(M,N,innerMargin,outerMargin)
%Inputs:
% M - Number of rows
% N - Number of columns
% innerMargin - [1x2] row, column inner spacing
%               [1x1] row and column, inner spacing
% outerMargin - defaults to innerMargin
%               [1x4] top,bottom,left,right margin
%               [1x2] top and bottom, left and right spacing
%               [1x1] top and bottom and left and right spacing
% pjh7 2013.04.09
function sp = subplots_new(M,N,innerMargin,outerMargin)
if length(M)==1
    Mfrac = ones(M,1);
else
    Mfrac = M/sum(M)*length(M);
    M = length(M);
end
if length(N)==1
    Nfrac = ones(N,1);
else
    Nfrac = N/sum(N)*length(N);
    N = length(N);
end

if ~exist('innerMargin','var')
innerMargin = [0.1 0.1];
end
if length(innerMargin) == 1
    innerMargin = innerMargin([1 1]);
end
if ~exist('outerMargin','var')
    outerMargin = innerMargin([1 1 2 2]);
end
if length(outerMargin) == 1
    outerMargin = outerMargin([1 1 1 1]);
elseif length(outerMargin) == 2
    outerMargin = outerMargin([1 1 2 2]);
end

clf;
H = (1-(outerMargin(1)+outerMargin(2))-(innerMargin(1)*(M-1)))/M;
W = (1-(outerMargin(3)+outerMargin(4))-(innerMargin(2)*(N-1)))/N;
%sp = zeros(M,N);
for m = 1:M;
    for n = 1:N
        %sp(m,n) = subplot('position',[outerMargin(3)+(n-1)*(W+innerMargin(2)) 1-outerMargin(1)-(m)*(H+innerMargin(1))+innerMargin(1) W H]);
        sp(m,n) = subplot('position',[outerMargin(3)+sum(W*Nfrac(1:n-1))+(n-1)*innerMargin(2) 1-outerMargin(1)-sum(H*Mfrac(1:m))-((m-1)*innerMargin(1)) W*Nfrac(n) H*Mfrac(m)]);
    end
end