# SPM toolbox: MNI Align

SPM12 toolbox to align an image to SPM's template space.

This toolbox uses the initial step from **Segment** under the hood. 

This registration algorithm is more robust than **Coregister** when applied to tissue probability maps, and handles affine transforms.

## Installation

1. Install [SPM12](https://www.fil.ion.ucl.ac.uk/spm/)
2. Copy or link the `spm_mni_align` folder under `spm12/toolbox`

## GUI usage

1. Launch `spm`.
2. Open the **Batch** interface.
3. Load the toolbox from **SPM -> Tools -> MNI Align**. Usage is simlar to that of **Coregister**.
    - **Estimate**: align images to the template and update the header.
    - **Reslice**: reslice already registered images to the grid of another image.
    - **Estimate and Reslice**: align images to the template, then reslice them to the space of the template.

**_Note:_**
By default, **Estimate** does not modify the header of the input files in-place but instead writes a new file. <br/>
To recover the in-place behaviour of **Coregister**, set the *Filename Prefix* option to an empty string.

## Script usage

### Estimate

```matlab
matlabbatch{1}.spm.tools.align.estimate.source = {'<PATH TO FIRST IMAGE>'};  % image used in registration
matlabbatch{1}.spm.tools.align.estimate.other = {
                                                 '<PATH TO OTHER IMAGE 1>'
                                                 '<PATH TO OTHER IMAGE 2>'
                                                 '<PATH TO OTHER IMAGE 3>'
                                                 ...
                                                 };  % estimated transform is applied to these images too
matlabbatch{1}.spm.tools.align.estimate.ref = {
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,1')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,2')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,3')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,4')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,5')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,6')
                                               };  % tissue probability map defining the template space
matlabbatch{1}.spm.tools.align.estimate.eoptions.rigid   = 0;      % 0 = affine, 1 = rigid
matlabbatch{1}.spm.tools.align.estimate.eoptions.sep    = [8 2];   % Distance between sampled points in mm
matlabbatch{1}.spm.tools.align.estimate.eoptions.fwhm   = [32 1];  % Fudge factor in mm (higher = stiff)
matlabbatch{1}.spm.tools.align.estimate.eoptions.prefix = 'e';     % Prefix of the output image
matlabbatch{1}.spm.tools.align.estimate.eoptions.dir    = {''};    % Output folder. Empty '' = same as input
```

### Reslice

```matlab
matlabbatch{1}.spm.tools.align.write.ref             = {'<PATH TO TARGET IMAGE>'};  % defines the resliced space
matlabbatch{1}.spm.tools.align.write.source          = {'<PATH TO SOURCE IMAGE>'};  % image to reslice
matlabbatch{1}.spm.tools.align.write.roptions.interp = 4;         % Interpolation order
matlabbatch{1}.spm.tools.align.write.roptions.wrap   = [0 0 0];   % Dimensions with circulant boundaries 
matlabbatch{1}.spm.tools.align.write.roptions.mask   = 0;         % Mask out voxels where at least one image is out-of-bounds
matlabbatch{1}.spm.tools.align.write.roptions.prefix = 'r';       % Prefix of the output image
matlabbatch{1}.spm.tools.align.write.roptions.dir    = '';        % Output folder. Empty '' = same as input

```

### Estimate & Reslice

```matlab
matlabbatch{1}.spm.tools.align.estwrite.source = {'<PATH TO FIRST IMAGE>'};  % image used in registration
matlabbatch{1}.spm.tools.align.estwrite.other = {
                                                 '<PATH TO OTHER IMAGE 1>'
                                                 '<PATH TO OTHER IMAGE 2>'
                                                 '<PATH TO OTHER IMAGE 3>'
                                                 ...
                                                 };  % estimated transform is applied to these images too
matlabbatch{1}.spm.tools.align.estwrite.ref = {
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,1')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,2')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,3')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,4')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,5')
                                               fullfile(spm('dir'), 'tpm', 'TPM.nii,6')
                                               };  % tissue probability map defining the template space
matlabbatch{1}.spm.tools.align.estwrite.eoptions.rigid  = 0;       % 0 = affine, 1 = rigid
matlabbatch{1}.spm.tools.align.estwrite.eoptions.sep    = [8 2];   % Distance between sampled points in mm
matlabbatch{1}.spm.tools.align.estwrite.eoptions.fwhm   = [32 1];  % Fudge factor in mm (higher = stiff)
matlabbatch{1}.spm.tools.align.estwrite.eoptions.prefix = 'e';     % Prefix of the output estimated image
matlabbatch{1}.spm.tools.align.estwrite.eoptions.dir    = {''};    % Output folder (estimate). Empty '' = same as input
matlabbatch{1}.spm.tools.align.estwrite.roptions.interp = 4;       % Interpolation order
matlabbatch{1}.spm.tools.align.estwrite.roptions.wrap   = [0 0 0]; % Dimensions with circulant boundaries 
matlabbatch{1}.spm.tools.align.estwrite.roptions.mask   = 0;       % Mask out voxels where at least one image is out-of-bounds
matlabbatch{1}.spm.tools.align.estwrite.roptions.prefix = 'r';     % Prefix of the output resliced image
matlabbatch{1}.spm.tools.align.estwrite.roptions.dir    = '';      % Output folder (reslice). Empty '' = same as input
```

## License

GNU-GPL 3
