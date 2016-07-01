function [AA, AI, BI] = CStrUnique(A)
% Unique elements of a cell string [MEX]
% [AA, AI, BI] = CStrUnique(A)
% INPUT:
%   A:  Cell string of any size.
% OUTPUT:
%   AA: Cell of unique strings of A. If the input A is a column cell, AA is a
%       column cell also. Otherwise AA is a row cell. The comparison considers
%       spaces, empty strings and case of letters.
%   AI: Linear indices (see IND2SUB) of unique strings such that A(AI) is
%       unique. The first occurrence of a string is preferred.
%       The order of AI corresponds with the order of strings in A, so AI is
%       strict monotonically increasing.
%   BI: List of linear indices of input strings according to output:
%       AA(BI) = A.
%
% Differences to Matlab's UNIQUE:
%   Faster.
%   Output is not sorted.
%
% Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
% Author: Jan Simon, Heidelberg, (C) 2006-2012 matlab.THISYEAR@nMINUSsimonDOTde
% License: BSD, use, copy, modify on own risk, mention the author

nA = numel(A);
if nA > 1
    [As, SV] = sort(A(:));
    
    if nargout < 3
        UV(SV)  = [1; strcmp(As(2:nA), As(1:nA - 1)) == 0];
        AI      = find(UV);
    else  % Indices requested:
        UV      = [1; strcmp(As(2:nA), As(1:nA - 1)) == 0];
        UVs(SV) = UV;
        AI      = find(UVs);
        
        % Get BI such that AA(BI) == A:
        v      = zeros(1, nA);
        v(AI)  = 1:length(AI);    % Sequence related to AA
        vs     = v(SV);           % Sorted like A
        vf     = vs(find(vs));    %#ok<FNDSB> % Just the filled entries
        BI(SV) = vf(cumsum(UV));  % Inflate multiple elements
    end
elseif nA  % Comparison of subsequent elements fails for nA == 1
    AI = 1;
    BI = 1;
else
    AI = [];
    BI = [];
end

AA = A(AI);
