function M = mni_align(T, S, opt)
% Reposition an image by affine aligning to MNI space and Procrustes adjustment
% FORMAT M = rigid_align(T, S, opt)
% T   - name of Tissue Probability Map
% S   - name of NIfTI file to register
% opt - structure with fields `rigid`, `sep`, `fwhm`
% M   - Affine matrix
%__________________________________________________________________________
% Copyright (C) 2008-2015 Wellcome Trust Centre for Neuroimaging

% 2018 Mikael Brudfors
% 2022 Yael Balbastre
%
% Copied from Mikael Brudfors' `realign2mni`, which is itself mostly copied
% from `spm_preproc8`

% Load tissue probability data
tpm = spm_load_priors8(T);

sep = opt.sep;
fwhm = opt.fwhm;
sep0 = sep(1);
fwhm0 = fwhm(1);
if numel(sep) > 1
    sep = sep(2:end);
end

V = spm_vol(S);
M = V(1).mat;
c = (V(1).dim+1)/2;

% Run using the origin from the header
V(1).mat    = M;
[Affine,ll] = spm_maff8(V(1),sep0,fwhm0,tpm,[],'mni');

P = eye(4);
if opt.reorient
    % Try all possible orientations
    for perm=perms(1:3)'
    for flip=combvec([0 1], [0 1], [0 1])
        P1            = eye(4);
        P1            = P1 .* [(1-2*flip); 1];           % flip
        P1            = P1([perm; 4],:);                 % permute
        M1            = P1 * M;
        M1(1:3,4)     = -M1(1:3,1:3) * c(:);             % center
        P1            = M1/M;
        V(1).mat      = M1;
        [Affine1,ll1] = spm_maff8(V(1),sep0,fwhm0,tpm,[],'mni');
        if ll1 > ll
            ll     = ll1;
            Affine = Affine1;
            P      = P1;
        end
    end
    end
else
    % Run using the origin at the center of the FOV
    M1            = M;
    M1(1:3,4)     = -M1(1:3,1:3)*c(:);
    P1            = M1/M;
    V(1).mat      = M1;
    [Affine1,ll1] = spm_maff8(V(1),sep0,fwhm0,tpm,[],'mni');
    if ll1 > ll
        ll     = ll1;
        Affine = Affine1;
        P      = P1;
    end
end

% Fine tune
V(1).mat = P * M;
for i=1:numel(fwhm)
for j=1:numel(sep)
    Affine = spm_maff8(V(1),sep(j),fwhm(i),tpm,Affine,'mni');
end
end

% Generate mm coordinates of where deformations map from
x = affind(rgrid(size(tpm.dat{1})),tpm.M);

% Generate mm coordinates of where deformation maps to
y = affind(x,inv(Affine));

% Weight the transform via GM+WM
w = single(exp(tpm.dat{1})+exp(tpm.dat{2}));

% Weighted Procrustes analysis
[Affine,R] = spm_get_closest_affine(x,y,w);

fprintf('affine:\n');
inv(Affine)

if opt.rigid
    M = R;
else
    M = Affine;
end

% Apply permutation
M = P \ M;

%==========================================================================

%==========================================================================
function x = rgrid(d)
x = zeros([d(1:3) 3],'single');
[x1,x2] = ndgrid(single(1:d(1)),single(1:d(2)));
for i=1:d(3)
    x(:,:,i,1) = x1;
    x(:,:,i,2) = x2;
    x(:,:,i,3) = single(i);
end
%==========================================================================

%==========================================================================
function y1 = affind(y0,M)
y1 = zeros(size(y0),'single');
for d=1:3
    y1(:,:,:,d) = y0(:,:,:,1)*M(d,1) + y0(:,:,:,2)*M(d,2) + y0(:,:,:,3)*M(d,3) + M(d,4);
end
%==========================================================================