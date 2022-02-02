function out = run_mni_align(job)
% SPM job execution function
% takes a harvested job data structure and call SPM functions to perform
% computations on the data.
% Input:
% job    - harvested job data structure (see matlabbatch help)
% Output:
% out    - computation results, usually a struct variable.
%__________________________________________________________________________
% Copyright (C) 2005-2014 Wellcome Trust Centre for Neuroimaging
% Copyright (C) 2021 Yael Balbastre

% Modified from `spm_run_coreg`
% $Id: spm_run_coreg.m 5956 2014-04-16 14:34:25Z guillaume $


if ~isfield(job,'other') || isempty(job.other{1}), job.other = {}; end
PO = [job.source(:); job.other(:)];
PO = spm_select('expand',PO);

%-Coregister
%--------------------------------------------------------------------------
if isfield(job,'eoptions')
    odir = job.eoptions.dir{1};
    PE = spm_file(PO,'prefix',job.eoptions.prefix);
    if ~isempty(odir)
        PE = spm_file(PE, 'path', odir);
    end
    PE = spm_select('expand',PE);
    if ~isempty(job.eoptions.prefix) || ~isempty(odir)
        for j=1:numel(PE)
            src = PO{j};
            dst = PE{j};
            src = strsplit(src, ',');
            src = strjoin(src(1:end-1), ',');
            dst = strsplit(dst, ',');
            dst = strjoin(dst(1:end-1), ',');
            mni_copyfile(src, dst, 'nifti', true);
        end
    end
    
    M = mni_align(char(job.ref), char(job.source), job.eoptions);

    MM = zeros(4,4,numel(PE));
    for j=1:numel(PE)
        MM(:,:,j) = spm_get_space(PE{j});
    end
    for j=1:numel(PE)
        spm_get_space(PE{j}, M\MM(:,:,j));
    end
end

%-Reslice
%--------------------------------------------------------------------------
if isfield(job,'roptions')
    P            = char(job.ref{:},job.source{:},job.other{:});
    P            = spm_file(P, 'prefix', job.eoptions.prefix);
    odir = job.eoptions.dir{1};
    if ~isempty(odir)
        P        = spm_file(P, 'path', odir);
    end
    flags.mask   = job.roptions.mask;
    flags.mean   = 0;
    flags.interp = job.roptions.interp;
    flags.which  = 1;
    flags.wrap   = job.roptions.wrap;
    flags.prefix = job.roptions.prefix;

    spm_reslice(P, flags);
end

%-Dependencies
%--------------------------------------------------------------------------
if isfield(job,'eoptions')
    out.cfiles   = spm_file(PO, 'prefix', job.eoptions.prefix);
    odir = job.eoptions.dir{1};
    if ~isempty(odir)
        out.cfiles = spm_file(out.cfiles, 'path', odir);
    end
    out.M        = M;
end
if isfield(job,'roptions')
    out.rfiles   = spm_file(PO, 'prefix', job.roptions.prefix);
    odir = job.roptions.dir{1};
    if ~isempty(odir)
        out.rfiles = spm_file(out.rfiles, 'path', odir);
    end
end