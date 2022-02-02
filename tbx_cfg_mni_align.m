function align = tbx_cfg_mni_align
% SPM Configuration file for MNI-alignment
%__________________________________________________________________________
% Copyright (C) 2005-2016 Wellcome Trust Centre for Neuroimaging
% Copyright (C) 2021 Yael Balbastre

% Modified from `spm_cfg_coreg`
% $Id: spm_cfg_coreg.m 7665 2019-09-23 11:27:40Z john $


if ~isdeployed, addpath(fullfile(spm('dir'),'toolbox','spm_mni_align')); end

%--------------------------------------------------------------------------
% ref Reference Image
%--------------------------------------------------------------------------
ref         = cfg_files;
ref.tag     = 'ref';
ref.name    = 'Tissue Probability Map';
ref.help    = {'The source image will be moved to this space.'};
ref.filter  = 'image';
ref.ufilter = '.*';
ref.val     = {{''}};
ref.num     = [0 Inf];
ref.preview = @(f) spm_image('Display',char(f));

tpm_nam     = fullfile(spm('dir'),'tpm','TPM.nii');
val         = cell(6, 1);
for k=1:6
    val{k}  = [tpm_nam ',' num2str(k)];
end
ref.val     = {val};

%--------------------------------------------------------------------------
% source Source Image
%--------------------------------------------------------------------------
source         = cfg_files;
source.tag     = 'source';
source.name    = 'Source Image';
source.help    = {'This is the image that is jiggled about to best match the template.'};
source.filter  = 'image';
source.ufilter = '.*';
source.num     = [1 1];
source.preview = @(f) spm_image('Display',char(f));

%--------------------------------------------------------------------------
% other Other Images
%--------------------------------------------------------------------------
other         = cfg_files;
other.tag     = 'other';
other.name    = 'Other Images';
other.val     = {{''}};
other.help    = {'These are any images that need to remain in alignment with the source image.'};
other.filter  = 'image';
other.ufilter = '.*';
other.num     = [0 Inf];
other.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% rig Rigid
%--------------------------------------------------------------------------
rigid         = cfg_menu;
rigid.tag     = 'rigid';
rigid.name    = 'Transformation';
rigid.help    = {
    'Whether to use a pure rigid or a similitude transformation model.'
    }';
rigid.labels  = {
                'Rigid'
                'Affine'
}';
rigid.values  = {1 0};
rigid.val     = {0};

%--------------------------------------------------------------------------
% sep Separation
%--------------------------------------------------------------------------
sep         = cfg_entry;
sep.tag     = 'sep';
sep.name    = 'Separation';
sep.help    = {
    'The average distance between sampled points (in mm).'
    'Can be a vector to allow a coarse registration followed by increasingly fine ones.'
    }';
sep.strtype = 'r';
sep.num     = [1 Inf];
sep.val     = {[8 2]};

%--------------------------------------------------------------------------
% fwhm Histogram Smoothing
%--------------------------------------------------------------------------
fwhm         = cfg_entry;
fwhm.tag     = 'fwhm';
fwhm.name    = 'Fudge factor';
fwhm.help    = {
    'Smoothness estimate for computing a fudge factor. '
    'Estimate is a full width at half maximum of a Gaussian (in mm). '
    'Larger values will give more weight to the prior (closer to rigid). '
    'Can be a vector to allow heavily regularised registration followed by '
    'increasingly lightly regularised ones.'
    }';
fwhm.strtype = 'r';
fwhm.num     = [1 Inf];
fwhm.val     = {[32 1]};

%--------------------------------------------------------------------------
% eprefix Filename Prefix
%--------------------------------------------------------------------------
eprefix         = cfg_entry;
eprefix.tag     = 'prefix';
eprefix.name    = 'Filename Prefix';
eprefix.help    = {'String to be prepended to the filenames of the estimated image file(s). Default prefix is ''e''.'};
eprefix.strtype = 's';
eprefix.num     = [0 Inf];
eprefix.val     = {'e'};

%--------------------------------------------------------------------------
% edir Output directory
%--------------------------------------------------------------------------
edir         = cfg_files;
edir.tag     = 'dir';
edir.name    = 'Output directory';
edir.help    = {'Output directory. If unset, same as the input file.'};
edir.filter  = 'dir';
edir.ufilter = '.*';
edir.num     = [0 1];
edir.val     = {{''}};

%--------------------------------------------------------------------------
% eoptions Estimation Options
%--------------------------------------------------------------------------
eoptions         = cfg_branch;
eoptions.tag     = 'eoptions';
eoptions.name    = 'Estimation Options';
eoptions.val     = {rigid sep fwhm eprefix edir};
eoptions.help    = {'Various registration options.'};

%--------------------------------------------------------------------------
% estimate Coreg: Estimate
%--------------------------------------------------------------------------
estimate         = cfg_exbranch;
estimate.tag     = 'estimate';
estimate.name    = 'MNI Align: Estimate';
estimate.val     = {source other ref eoptions};
estimate.help    = {
    'Within-subject registration using a rigid-body model.'
    ''
    'The registration method used here is based on work by Collignon et al/* \cite{collignon95}*/. The original interpolation method described in this paper has been changed in order to give a smoother cost function.  The images are also smoothed slightly, as is the histogram.  This is all in order to make the cost function as smooth as possible, to give faster convergence and less chance of local minima.'
    ''
    'At the end of coregistration, the voxel-to-voxel affine transformation matrix is displayed, along with the histograms for the images in the original orientations, and the final orientations.  The registered images are displayed at the bottom.'
    ''
    'Registration parameters are stored in the headers of the "source" and the "other" images.'
    }';
estimate.prog = @run_mni_align;
estimate.vout = @vout_estimate;

%--------------------------------------------------------------------------
% ref Image Defining Space
%--------------------------------------------------------------------------
refwrite         = cfg_files;
refwrite.tag     = 'ref';
refwrite.name    = 'Template Defining Space';
refwrite.help    = {'This is analogous to the reference image. Images are resliced to match this image (providing they have been coregistered first).'};
refwrite.filter  = 'image';
refwrite.ufilter = '.*';
refwrite.num     = [1 1];
refwrite.preview = @(f) spm_image('Display',char(f));

%--------------------------------------------------------------------------
% source Images to Reslice
%--------------------------------------------------------------------------
source         = cfg_files;
source.tag     = 'source';
source.name    = 'Images to Reslice';
source.help    = {'These images are resliced to the same dimensions, voxel sizes, orientation etc as the space defining image.'};
source.filter  = 'image';
source.ufilter = '.*';
source.num     = [1 Inf];
source.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% interp Interpolation
%--------------------------------------------------------------------------
interp         = cfg_menu;
interp.tag     = 'interp';
interp.name    = 'Interpolation';
interp.help    = {
    'The method by which the images are sampled when being written in a different space.'
    'Nearest Neighbour is fastest, but not normally recommended. It can be useful for re-orienting images while preserving the original intensities (e.g. an image consisting of labels). Trilinear Interpolation is OK for PET, or realigned and re-sliced fMRI. If subject movement (from an fMRI time series) is included in the transformations then it may be better to use a higher degree approach. Note that higher degree B-spline interpolation/* \cite{thevenaz00a,unser93a,unser93b}*/ is slower because it uses more neighbours.'
    }';
interp.labels  = {
                  'Nearest neighbour'
                  'Trilinear'
                  '2nd Degree B-Spline'
                  '3rd Degree B-Spline'
                  '4th Degree B-Spline'
                  '5th Degree B-Spline'
                  '6th Degree B-Spline'
                  '7th Degree B-Spline'
}';
interp.values  = {0 1 2 3 4 5 6 7};
interp.def     = @(val)spm_get_defaults('coreg.write.interp', val{:});

%--------------------------------------------------------------------------
% wrap Wrapping
%--------------------------------------------------------------------------
wrap         = cfg_menu;
wrap.tag     = 'wrap';
wrap.name    = 'Wrapping';
wrap.help    = {
    'This indicates which directions in the volumes the values should wrap around in.'
    'These are typically:'
    '    No wrapping - for PET or images that have already been spatially transformed.'
    '    Wrap in  Y  - for (un-resliced) MRI where phase encoding is in the Y direction (voxel space).'
    }';
wrap.labels  = {
                'No wrap'
                'Wrap X'
                'Wrap Y'
                'Wrap X & Y'
                'Wrap Z'
                'Wrap X & Z'
                'Wrap Y & Z'
                'Wrap X, Y & Z'
}';
wrap.values  = {[0 0 0] [1 0 0] [0 1 0] [1 1 0] [0 0 1] [1 0 1] [0 1 1]...
               [1 1 1]};
wrap.def     = @(val)spm_get_defaults('coreg.write.wrap', val{:});

%--------------------------------------------------------------------------
% mask Masking
%--------------------------------------------------------------------------
mask         = cfg_menu;
mask.tag     = 'mask';
mask.name    = 'Masking';
mask.help    = {'Because of subject motion, different images are likely to have different patterns of zeros from where it was not possible to sample data. With masking enabled, the program searches through the whole time series looking for voxels which need to be sampled from outside the original images. Where this occurs, that voxel is set to zero for the whole set of images (unless the image format can represent NaN, in which case NaNs are used where possible).'};
mask.labels  = {
                'Mask images'
                'Dont mask images'
}';
mask.values  = {1 0};
mask.def     = @(val)spm_get_defaults('coreg.write.mask', val{:});

%--------------------------------------------------------------------------
% prefix Filename Prefix
%--------------------------------------------------------------------------
prefix         = cfg_entry;
prefix.tag     = 'prefix';
prefix.name    = 'Filename Prefix';
prefix.help    = {'String to be prepended to the filenames of the resliced image file(s). Default prefix is ''r''.'};
prefix.strtype = 's';
prefix.num     = [1 Inf];
prefix.def     = @(val)spm_get_defaults('coreg.write.prefix', val{:});

%--------------------------------------------------------------------------
% rdir Output directory
%--------------------------------------------------------------------------
rdir         = cfg_files;
rdir.tag     = 'dir';
rdir.name    = 'Output directory';
rdir.help    = {'Output directory. If unset, same as the input file.'};
rdir.filter  = 'dir';
rdir.ufilter = '.*';
rdir.num     = [0 1];
rdir.val     = {''};

%--------------------------------------------------------------------------
% roptions Reslice Options
%--------------------------------------------------------------------------
roptions         = cfg_branch;
roptions.tag     = 'roptions';
roptions.name    = 'Reslice Options';
roptions.val     = {interp wrap mask prefix rdir};
roptions.help    = {'Various reslicing options.'};

%--------------------------------------------------------------------------
% write Coreg: Reslice
%--------------------------------------------------------------------------
write         = cfg_exbranch;
write.tag     = 'write';
write.name    = 'MNI Align: Reslice';
write.val     = {refwrite source roptions};
write.help    = {
    'Reslice images to match voxel-for-voxel with an image defining some space.'
    'The resliced images are named the same as the originals except that they are prefixed by ''r''.'
    }';
write.prog    = @run_mni_align;
write.vout    = @vout_reslice;

%--------------------------------------------------------------------------
% source Source Image
%--------------------------------------------------------------------------
source         = cfg_files;
source.tag     = 'source';
source.name    = 'Source Image';
source.help    = {'This is the image that is jiggled about to best match the reference.'};
source.filter  = 'image';
source.ufilter = '.*';
source.num     = [1 1];
source.preview = @(f) spm_image('Display',char(f));

%--------------------------------------------------------------------------
% estwrite Coreg: Estimate & Reslice
%--------------------------------------------------------------------------
estwrite      = cfg_exbranch;
estwrite.tag  = 'estwrite';
estwrite.name = 'MNI Align: Estimate & Reslice';
estwrite.val  = {ref source other eoptions roptions};
estwrite.help = {
    'Within-subject registration using a rigid-body model and image reslicing.'
    ''
    'The registration method used here is based on work by Collignon et al/* \cite{collignon95}*/. The original interpolation method described in this paper has been changed in order to give a smoother cost function.  The images are also smoothed slightly, as is the histogram.  This is all in order to make the cost function as smooth as possible, to give faster convergence and less chance of local minima.'
    ''
    'At the end of coregistration, the voxel-to-voxel affine transformation matrix is displayed, along with the histograms for the images in the original orientations, and the final orientations.  The registered images are displayed at the bottom.'
    ''
    'Please note that Coreg only attempts rigid alignment between the images. fMRI tend to have large distortions, which are not corrected by rigid-alignment alone. There is not yet any functionality in the SPM software that is intended to correct this type of distortion when aligning distorted fMRI with relatively undistorted anatomical scans (e.g. MPRAGE).'
    ''
    'Registration parameters are stored in the headers of the "source" and the "other" images. These images are also resliced to match the source image voxel-for-voxel. The resliced images are named the same as the originals except that they are prefixed by ''r''.'
    }';
estwrite.prog = @run_mni_align;
estwrite.vout = @vout_estwrite;

%--------------------------------------------------------------------------
% coreg Coreg
%--------------------------------------------------------------------------
align         = cfg_choice;
align.tag     = 'align';
align.name    = 'MNI Align';
align.help    = {
    'Subject to Template registration using a similitude or rigid-body model.'
    ''
    'You get the options of estimating the transformation, reslicing images according to some transformations, or estimating and applying transformations.'
    }';
align.values  = {estimate write estwrite};


%==========================================================================
function dep = vout_estimate(job)
dep(1)            = cfg_dep;
dep(1).sname      = 'Coregistered Images';
dep(1).src_output = substruct('.','cfiles');
dep(1).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
dep(2)            = cfg_dep;
dep(2).sname      = 'Coregistration Matrix';
dep(2).src_output = substruct('.','M');
dep(2).tgt_spec   = cfg_findspec({{'strtype','r'}});


%==========================================================================
function dep = vout_reslice(job)
dep(1)            = cfg_dep;
dep(1).sname      = 'Resliced Images';
dep(1).src_output = substruct('.','rfiles');
dep(1).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});


%==========================================================================
function dep = vout_estwrite(job)
depe = vout_estimate(job);
depc = vout_reslice(job);
dep = [depe depc];