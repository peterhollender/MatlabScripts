function Y = maxnorm(X,dim)
%MAXNORM  Normalize matrix by maximum value in specified dimension.
%   Y = maxnorm(X,dim) normalizes the matrix X to fractions of maximum value.
%      DIM specifies in which direction to find the maxima, and if left
%      blank, the overall maximum will be used.
%
%   Example
%   X = [1 2;
%        3 4];
%   Y = maxnorm(X)
%       returns [.25 .5
%                .75  1];
%   Y = maxnorm(X,1)
%       returns
%
%   See also

% Author: Peter Hollender
% Created: Jan 2011
% Copyright 2011

if ~exist('dim','var')
    Y = X./max(X(:));
else
    a = ones(1,ndims(X));
    a(dim) = size(X,dim);
    Y = X./repmat(max(X,[],dim),a);
end
    