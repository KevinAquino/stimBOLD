function f = spfilt(g, type, m, n, parameter)
% SPFILT Performs linear and nonlinear spatial filtering.
%   F = SPFILT(G, TYPE, M, N, PARAMETER) performs spatial filtering
%   of image G using a TYPE filter of size M-by-N. Valid calls to
%   SPFILT are as follows:
%
%     F = SPFILT(G, 'amean', M, N)       Arithmetic mean filtering.
%     F = SPFILT(G, 'gmean', M, N)       Geometric mean filtering.
%     F = SPFILT(G, 'hmean', M, N)       Harmonic mean filtering.
%     F = SPFILT(G, 'chmean', M, N, Q)   Contraharmonic mean
%                                        filtering of order Q. The
%                                        default Q is 1.5.
%     F = SPFILT(G, 'median', M, N)      Median filtering.
%     F = SPFILT(G, 'max', M, N)         Max filtering.
%     F = SPFILT(G, 'min', M, N)         Min filtering.
%     F = SPFILT(G, 'midpoint', M, N)    Midpoint filtering.
%     F = SPFILT(G, 'atrimmed', M, N, D) Alpha-trimmed mean
%                                        filtering. Parameter D must
%                                        be a nonnegative even
%                                        integer; its default value
%                                        is 2.
%
%   The default values when only G and TYPE are input are M = N = 3,
%   Q = 1.5, and D = 2.

%   The code is from R. C. Gonzalez, R. E. Woods, and S. L. Eddins
%   From the book Digital Image Processing Using MATLAB, 2nd ed., pp. 159-162
%

% Process inputs.
if nargin ==2
    m = 3;
    n = 3;
    Q = 1.5;
    D = 2;
elseif nargin ==5
    Q = parameter;
    D = parameter;
elseif nargin==4
    Q = 1.5;
    D = 2;
else
    error('Wrong number of inputs');
end


% Do the filtering.
switch type
    case 'amean'
        w = fspecial('average', [m n]);
        f = imfilter(g, w, 'replicate');
    case 'gmean'
        f = gmean(g, m, n);
    case 'hmean'
        f = harmean(g, m, n);
    case 'chmean'
        f = charmean(g, m, n, Q);
    case 'median'
        f = medfilt2(g, [m n], 'symmetric');
    case 'max'
        f = imdilate(g, ones(m, n));
    case 'min'
        f = imerode(g, ones(m, n));
    case 'midpoint'
        f1 = ordfilt2(g, 1, ones(m, n), 'symmetric');
        f2 = ordfilt2(g, m*n, ones(m, n), 'symmetric');
        f = imlincomb(0.5, f1, 0.5, f2);
    case 'atrimmed'
        f = alphatrim(g, m, n, D);
    otherwise
        error('Unknown filter type.')
end

%------------------------------------------------------------------%
function f = gmean(g, m, n)
%  Implements a geometric mean filter.
[g, revertClass] = tofloat(g);
f = exp(imfilter(log(g), ones(m, n), 'replicate')).^(1 / m / n);
f = revertClass(f);

%------------------------------------------------------------------%
function f = harmean(g, m, n)
%  Implements a harmonic mean filter.
[g, revertClass] = tofloat(g);
f = m * n ./ imfilter(1./(g + eps),ones(m, n), 'replicate');
f = revertClass(f);

%------------------------------------------------------------------%
function f = charmean(g, m, n, q)
%  Implements a contraharmonic mean filter.
[g, revertClass] = tofloat(g);
f = imfilter(g.^(q+1), ones(m, n), 'replicate');
f = f ./ (imfilter(g.^q, ones(m, n), 'replicate') + eps);
f = revertClass(f);

%------------------------------------------------------------------%
function f = alphatrim(g, m, n, d)
%  Implements an alpha-trimmed mean filter.

if (d <= 0) || (d/2 ~= round(d/2))
    error('d must be a positive, even integer.')
end

[g, revertClass] = tofloat(g);
f = imfilter(g, ones(m, n), 'symmetric');
for k = 1:d/2
    f = f - ordfilt2(g, k, ones(m, n), 'symmetric');
end
for k = (m*n - (d/2) + 1):m*n
    f = f - ordfilt2(g, k, ones(m, n), 'symmetric');
end
f = f / (m*n - d);
f = revertClass(f);

