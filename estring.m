function s = estring(x,sigfigs,delim)
%ESTRING  Make string with Engineering Unit Exponent
%   s = estring(x,sigfigs,delim)
%   Converts numbers into strings corresponding to typical engineering
%   denominations i.e. 5.3e3 -> 5.3k, 6.0001e-6 -> 6u, etc.
%   INPUTS:
%       x       Input number to be converted
%       sigfigs Number of requested significant figures (default 3)
%       delim   decimal point delimiter (default '.')
%
%   Example
%   estring(5.3e6,2,'p') returns 5p3M
%   estring(6.005e-6,3) returns 6.01u
%
%   See also sprintf

% Author: Peter Hollender
% Created: Jan 2011
% Copyright 2011

if ~exist('sigfigs','var')
    sigfigs = 3;
end

if ~exist('delim','var')
    delim = '.';
end

prefixes = {'y','z','a','f','p','n','u','m','','k','M','G','T','P','E','Z','Y'};
exponents = [-24 -21 -18 -15 -12 -9 -6 -3 0 3 6 9 12 15 18 21 24];

if x<0
sgn = '-';
x = -1*x;
else
sgn = '';
end

i = length(exponents);
while i >= 1 && floor(x*10^-exponents(i))==0
    i = i-1;
end
if x==0
if sigfigs <= 1
s = '0';
else
s = ['0' delim repmat('0',1,sigfigs-1)];
end
else

integers = num2str(floor(x*10^-exponents(i)));
l = length(integers);
remainder = x - (10^exponents(i)*floor(x*10^-exponents(i)));

if l>=sigfigs
    if remainder * 10^-exponents(i)>=.5
        integers = num2str(round(x*10^-exponents(i)));
    end
    s = [sgn integers prefixes{i}];
else
str = sprintf('%%0%1.0f.0f',sigfigs-l);
    s = [sgn integers delim sprintf(str,round(remainder*10^(-exponents(i) + (sigfigs-l)+1))/10) prefixes{i}];
end
end
