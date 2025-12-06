function div = division(p,Clipping,each,Data_spec_MTI2,MD_DopplerAxis,MD_TimeAxis,Te,Diff,Comb1,Comb2,Comb3,Comb4,Comb5,Comb6,OF,TW,PF,filename)

MD_TimeAxis = MD_TimeAxis(:,1:Clipping*each);

for r = 0:p-1    
Data_spec_MTI2_c = Data_spec_MTI2(:,1+Clipping*each*r:Clipping*each*(r+1));
%% Spectrogram with axis
% figure
% imagesc(MD_TimeAxis,MD_DopplerAxis.*3e8/2/5.8e9,20*log10(abs(Data_spec_MTI2))); colormap('jet'); axis xy
% xlabel('Time[s]', 'FontSize',16);
% ylabel('Doppler [Hz]','FontSize',16)
% title(Files(i).name);
% ylim([-5 5]); 
% colormap; %xlim([1 9])
% clim = get(gca,'CLim');
% set(gca, 'CLim', clim(2)+[-40,0]);
% set(gca, 'FontSize',16)
% colorbar
% %saveas(gcf,[Spectrogram_Image_path,Files(i).name,'.png']);
% delete(gcf);
%% Spectrogram image
figure
imagesc(MD_TimeAxis,MD_DopplerAxis.*3e8/2/5.8e9,20*log10(abs(Data_spec_MTI2_c))); colormap('jet'); 
axis xy
clim = get(gca,'CLim');
set(gca, 'CLim', clim(2)+[-40,0]);
box off  
% %移除坐标轴边框%%
set(gca,'Visible','off');
set(gca,'position',[0 0 1 1])
grid off
axis normal
axis off
Fspec = getframe;
RGB_spec = frame2im(Fspec);
saveas(gcf,[pwd,'\',char(filename),'_MD','_prm_TWL_',TW,'_OF_',OF,'_PF_',PF,'_clipping_',clipping,'_',r,'.png'])
save([pwd,'\',char(filename),'_MD','_prm_TWL_',TW,'_OF_',OF,'_PF_',PF,'_clipping_',clipping,'_',r,'.mat'], 'Data_spec_MTI2')
saveas(gcf,[pwd,'\',char(filename(1:end-4)),'_MD','_prm_TWL_',num2str(TW),'_OF_',num2str(OF),'_PF_',num2str(PF),'_clipping',num2str(clipping),'_',num2str(r),'.png'])
save([pwd,'\',char(filename(1:end-4)),'_MD','_prm_TWL_',num2str(TW),'_OF_',num2str(OF),'_PF_',num2str(PF),'_clipping',num2str(clipping),'_',num2str(r),'.mat'], 'Data_spec_MTI2')
delete(gcf);

%% wrapped phase
% figure
% imagesc(MD_TimeAxis,MD_DopplerAxis.*3e8/2/5.8e9,20*angle(Data_spec_MTI2_c)); colormap('jet'); 
% axis xy
% %ylim([-5 5]); 
% clim = get(gca,'CLim');
% set(gca, 'CLim', clim(2)+[-40,0]);
% box off  
% %%移除坐标轴边框
% set(gca,'Visible','off');
% set(gca,'position',[0 0 1 1])
% grid off
% axis normal
% axis off
% Fph = getframe;
% RGB_ph = frame2im(Fph);
% delete(gcf);

%% unwrapped phase
% figure
% imagesc(MD_TimeAxis,MD_DopplerAxis.*3e8/2/5.8e9,20*unwrap(angle(Data_spec_MTI2_c))); colormap('jet'); 
% axis xy
% %ylim([-5 5]); 
% %clim = get(gca,'CLim');
% box off  
% %%移除坐标轴边框
% set(gca,'Visible','off');
% set(gca,'position',[0 0 1 1])
% grid off
% axis normal
% axis off
% Fuph = getframe;
% RGB_uph = frame2im(Fuph);
% delete(gcf);

%% Mask Image
I=RGB_spec;
spec = im2gray(I);
T1 = mean(spec,'all');

    for m = 1:1000
    C1 = spec;
    C2 = spec;
    C1(C1<T1) = 0;
    C2(C2>=T1) = 0;
    u1 = C1(C1>0);
    u2 = C2(C2>0);
    T2 = (mean(u1)+mean(u2))/2;
      if abs(T2-T1)>Diff
        T1 = T2;
      else 
        T = T2;
        break;
      end       
    end

T = T+Te;
%threshold(1,i) = T;% thresholding of each graph.
%steps_iterative(1,i) = m;
level = T/255;
BW = imbinarize(spec,level);
% imwrite(BW,[Mask_path,Files(i).name,'.bmp']);

%% Masked phase
wp = RGB_ph;
up = RGB_uph;
wp = im2gray(wp);
up = im2gray(up);
wp = im2double(wp);
up = im2double(up);

masked_phase = BW.*wp;
masked_unwrapped_phase = BW.*up;
masked_phase = im2uint8(masked_phase);
masked_unwrapped_phase = im2uint8(masked_unwrapped_phase);
% imwrite(masked_phase,[Masked_Phase_path,Files(i).name,'.bmp']);
% imwrite(masked_unwrapped_phase,[Masked_Unwrapped_Phase_path,Files(i).name,'.bmp']);

%% Masked Spectrogram Image
gray_I = rgb2gray(I);
gray_I = im2double(gray_I);
masked_spectrogram_image = BW.*gray_I;
masked_spectrogram_image = im2uint8(masked_spectrogram_image);
% imwrite(masked_spectrogram_image,[Masked_Spec_Image_path,Files(i).name,'.bmp']);

%% Masked Spectrogram
I2 = im2gray(I);
M_shape = size(Data_spec_MTI2_c);
spec2 = imresize(I2,[M_shape(1) M_shape(2)]);
BW2 = imbinarize(spec2,level);
masked_spectrogram = BW2.*Data_spec_MTI2_c;

%% Patent features for different masked domains.
%Mask
if Comb1 == 1
a=regionprops(BW,'centroid');
b=regionprops(BW,'Eccentricity');
c=regionprops(BW,'MajorAxisLength');
d=regionprops(BW,'MinorAxisLength');
e=regionprops(BW,'Orientation');
f=regionprops(BW,'Area');
g=regionprops(BW,'Perimeter');

centroids = cat(1, a.Centroid);
eccentricity = cat(1, b.Eccentricity);
major = cat(1, c.MajorAxisLength);
minor = cat(1, d.MinorAxisLength);
orient = cat(1, e.Orientation);
area = cat(1, f.Area);
perimeter_is = cat(1, g.Perimeter);
surface = sum(area);
Total_perimeter = sum(perimeter_is);
MomentI = moment(BW,2,'all');
LBP = extractLBPFeatures(BW);
num=find(area==max(area)); %find the biggest objects
num=num(1);
mask_features = [MomentI,surface,Total_perimeter,orient(num),major(num),minor(num),centroids(num,1),centroids(num,2),eccentricity(num),LBP]; 
mask_results_c(r+1,:) = mask_features;
else 
mask_results_c(r+1,:) = 0;
end

%Masked phase
if Comb2 == 1
masked_phase_binary = imbinarize(masked_phase,level);
a=regionprops(masked_phase_binary,masked_phase,'centroid');
b=regionprops(masked_phase_binary,masked_phase,'Eccentricity');
c=regionprops(masked_phase_binary,masked_phase,'MajorAxisLength');
d=regionprops(masked_phase_binary,masked_phase,'MinorAxisLength');
e=regionprops(masked_phase_binary,masked_phase,'Orientation');
f=regionprops(masked_phase_binary,masked_phase,'Area');
g=regionprops(masked_phase_binary,masked_phase,'Perimeter');

centroids = cat(1, a.Centroid);
eccentricity = cat(1, b.Eccentricity);
major = cat(1, c.MajorAxisLength);
minor = cat(1, d.MinorAxisLength);
orient = cat(1, e.Orientation);
area = cat(1, f.Area);
perimeter_is = cat(1, g.Perimeter);
surface = sum(area);
Total_perimeter = sum(perimeter_is);
MomentI = moment(masked_phase,2,'all');
LBP = extractLBPFeatures(masked_phase);
num=find(area==max(area)); %find the biggest objects
num=num(1);
masked_phase_features = [MomentI,surface,Total_perimeter,orient(num),major(num),minor(num),centroids(num,1),centroids(num,2),eccentricity(num),LBP]; 
masked_phase_results_c(r+1,:) = masked_phase_features;
else 
masked_phase_results_c(r+1,:) = 0;
end

%masked unwrapped phase
if Comb3 == 1
masked_unwrapped_phase_binary = imbinarize(masked_unwrapped_phase,level);
a=regionprops(masked_unwrapped_phase_binary,masked_unwrapped_phase,'centroid');
b=regionprops(masked_unwrapped_phase_binary,masked_unwrapped_phase,'Eccentricity');
c=regionprops(masked_unwrapped_phase_binary,masked_unwrapped_phase,'MajorAxisLength');
d=regionprops(masked_unwrapped_phase_binary,masked_unwrapped_phase,'MinorAxisLength');
e=regionprops(masked_unwrapped_phase_binary,masked_unwrapped_phase,'Orientation');
f=regionprops(masked_unwrapped_phase_binary,masked_unwrapped_phase,'Area');
g=regionprops(masked_unwrapped_phase_binary,masked_unwrapped_phase,'Perimeter');

centroids = cat(1, a.Centroid);
eccentricity = cat(1, b.Eccentricity);
major = cat(1, c.MajorAxisLength);
minor = cat(1, d.MinorAxisLength);
orient = cat(1, e.Orientation);
area = cat(1, f.Area);
perimeter_is = cat(1, g.Perimeter);
surface = sum(area);
Total_perimeter = sum(perimeter_is);
MomentI = moment(masked_unwrapped_phase,2,'all');
LBP = extractLBPFeatures(masked_unwrapped_phase);
num=find(area==max(area)); %find the biggest objects
num=num(1);
masked_unwrapped_features = [MomentI,surface,Total_perimeter,orient(num),major(num),minor(num),centroids(num,1),centroids(num,2),eccentricity(num),LBP]; 
masked_unwrapped_results_c(r+1,:) = masked_unwrapped_features;
else 
masked_unwrapped_results_c(r+1,:) = 0;
end

%masked spectrogram image (patent)
if Comb4 == 1
masked_spectrogram_image_binary = imbinarize(masked_spectrogram_image,level);
a=regionprops(masked_spectrogram_image_binary,masked_spectrogram_image,'centroid');
b=regionprops(masked_spectrogram_image_binary,masked_spectrogram_image,'Eccentricity');
c=regionprops(masked_spectrogram_image_binary,masked_spectrogram_image,'MajorAxisLength');
d=regionprops(masked_spectrogram_image_binary,masked_spectrogram_image,'MinorAxisLength');
e=regionprops(masked_spectrogram_image_binary,masked_spectrogram_image,'Orientation');
f=regionprops(masked_spectrogram_image_binary,masked_spectrogram_image,'Area');
g=regionprops(masked_spectrogram_image_binary,masked_spectrogram_image,'Perimeter');

centroids = cat(1, a.Centroid);
eccentricity = cat(1, b.Eccentricity);
major = cat(1, c.MajorAxisLength);
minor = cat(1, d.MinorAxisLength);
orient = cat(1, e.Orientation);
area = cat(1, f.Area);
perimeter_is = cat(1, g.Perimeter);
surface = sum(area);
Total_perimeter = sum(perimeter_is);
MomentI = moment(masked_spectrogram_image,2,'all');
LBP = extractLBPFeatures(masked_spectrogram_image);
num=find(area==max(area)); %find the biggest objects
num=num(1);
masked_spectrogram_features = [MomentI,surface,Total_perimeter,orient(num),major(num),minor(num),centroids(num,1),centroids(num,2),eccentricity(num),LBP]; 
masked_spectrogram_image_results_c(r+1,:) = masked_spectrogram_features;
else
    masked_spectrogram_image_results_c(r+1,:) = 0;
end

%% Spectrogram Features
if Comb5 == 1
Spectrogram=Data_spec_MTI2_c; 
Nb_elts = size(Spectrogram,2);
Mo_mean_ment_real=sum(real(Spectrogram),2)/Nb_elts; %Mean of real elements in time direction
Mo_mean_ment_imag = sum(imag(Spectrogram),2)/Nb_elts;       %Mean of imaginary elements in time direction
Mo_mean_ment_cplx = Mo_mean_ment_real+1i.*Mo_mean_ment_imag;  %Cplx Mean sum of the previous 2 real+1i*imag 
Mo_mean_ment_abs = sum(abs(Spectrogram),2)/Nb_elts;         %Mean of amplitude in time direction
%% calculating the standard deviation of the complex mean
cplx_mean = repmat(Mo_mean_ment_cplx,[1 Nb_elts]); % creating a matrix of the same size as the spectrogram with replication of the mean_cplx to calculate variance
var_cplx = sum(abs(Spectrogram-cplx_mean),2).^2/Nb_elts; %complex variance in time direction
std_cplx = sqrt(var_cplx);
%% calculating the standard devaition of the amplitude
abs_mean = repmat(Mo_mean_ment_abs,[1 Nb_elts]); % creating a matrix of the same size as the spectrogram with replication of the mean_abs to calculate variance
var_abs = sum(abs(Spectrogram-abs_mean),2).^2/Nb_elts; %complex variance in time direction
std_abs = sqrt(var_abs);
%% calculating the standard deviation of the real part
real_mean = repmat(Mo_mean_ment_real,[1 Nb_elts]); % creating a matrix of the same size as the spectrogram with replication of the mean_real to calculate variance
var_real = sum(abs(real(Spectrogram)-real_mean),2).^2/Nb_elts; % real variance in time direction
std_real = sqrt(var_real); 
%% calculating the standard deviation of the imaginary part
imag_mean = repmat(Mo_mean_ment_imag,[1 Nb_elts]); % creating a matrix of the same size as the spectrogram with replication of the mean_imag to calculate variance
var_imag = sum(abs(imag(Spectrogram)-imag_mean),2).^2/Nb_elts; % imag variance in time direction
std_imag = sqrt(var_imag);

%% calculating the pseudo standard deviation 
%pvar_cplx = sum((Spectrogram-cplx_mean).^2,2)./Nb_elts;
%pstd_cplx = sqrt(pvar_cplx);

%% root mean squared value and pseudo RMS
% create a function for this
MS = sum(abs(Spectrogram).^2,2)/Nb_elts;
PMS = sum(Spectrogram.^2,2)/Nb_elts;
%RMS = sqrt(MS);
%PRMS = sqrt(PMS);
real_MS = sum(abs(real(Spectrogram)).^2,2)/Nb_elts;
imag_MS = sum(abs(imag(Spectrogram)).^2,2)/Nb_elts;
real_RMS = sqrt(real_MS);
imag_RMS = sqrt(imag_MS);

%% Kurtosis
kurt = sum(abs(Spectrogram).^4,2)/Nb_elts-abs(PMS).^2-2*(MS).^2;

%% peak to peak of real part and imaginary part
p2preal = max(real(Spectrogram),[],2)-min(real(Spectrogram),[],2);
p2pimag = max(imag(Spectrogram),[],2)-min(imag(Spectrogram),[],2);

%% image processing type features
Graylvls = 64; %This variable could be used to set the number of gray
% levels per mat2gray transformations
% this part requires rewriting a fundction to calculate the entropy,
% skewness, kurtosis, bandwidth
% thresholding at this stage would greatly help in filtering out the noise
% in the background
% example below of masking down manually 
% SpectroLOG = 20*log10(abs(Spectrogram)/max(max(abs(Spectrogram))));
% figure(100)
% imagesc(SpectroLOG)
% colorbar

%SpectroLOG(SpectroLOG < -60)=-60;
%SpectroLOG_eq = histeq(mat2gray(SpectroLOG)); %equalize grayscales
%SpectroLOG_unchanged = mat2gray(SpectroLOG); % converting the matrix to a grayscale image using the minimum and mximum values


Spectrogram_logamp_eq = histeq(mat2gray(20*log10(abs(Spectrogram))),Graylvls); %equalize grayscales
Spectrogram_logamp_unchanged = mat2gray(20*log10(abs(Spectrogram))); % converting the matrix to a grayscale image using the minimum and mximum values

Spectrogram_amp_eq = histeq(mat2gray(abs(Spectrogram)),Graylvls);
Spectrogram_real_eq = histeq(mat2gray(real(Spectrogram)),Graylvls);
Spectrogram_imag_eq = histeq(mat2gray(imag(Spectrogram)),Graylvls);
Spectrogram_phase_eq = histeq(mat2gray(180/pi*angle(Spectrogram)),Graylvls);

Spectrogram_amp_unchanged = mat2gray(abs(Spectrogram));
Spectrogram_real_unchanged = mat2gray(real(Spectrogram));
Spectrogram_imag_unchanged = mat2gray(imag(Spectrogram));
Spectrogram_phase_unchanged = mat2gray(180/pi*angle(Spectrogram));


%% calculating the probabilities so that they equate 1 in the end
% create a function for this
p_logamp_eq = imhist(Spectrogram_logamp_eq,Graylvls);
np_logamp_eq = sum(p_logamp_eq,1);
p_logamp_eq = p_logamp_eq./np_logamp_eq;

p_logamp_unchanged = imhist(Spectrogram_logamp_unchanged,Graylvls);
np_logamp_unchanged = sum(p_logamp_unchanged,1);
p_logamp_unchanged = p_logamp_unchanged./np_logamp_unchanged;

p_amp_eq = imhist(Spectrogram_amp_eq,Graylvls);
np_amp_eq = sum(p_amp_eq,1);
p_amp_eq = p_amp_eq./np_amp_eq;

p_amp_unchanged = imhist(Spectrogram_amp_unchanged,Graylvls);
np_amp_unchanged = sum(p_amp_unchanged,1);
p_amp_unchanged = p_amp_unchanged./np_amp_unchanged;

p_real_eq = imhist(Spectrogram_real_eq,Graylvls);
np_real_eq = sum(p_real_eq,1);
p_real_eq = p_real_eq./np_real_eq;

p_real_unchanged = imhist(Spectrogram_real_unchanged,Graylvls);
np_real_unchanged = sum(p_real_unchanged,1);
p_real_unchanged = p_real_unchanged./np_real_unchanged;

p_imag_eq = imhist(Spectrogram_imag_eq,Graylvls);
np_imag_eq = sum(p_imag_eq,1);
p_imag_eq = p_imag_eq./np_imag_eq;

p_imag_unchanged = imhist(Spectrogram_imag_unchanged,Graylvls);
np_imag_unchanged = sum(p_imag_unchanged,1);
p_imag_unchanged = p_imag_unchanged./np_imag_unchanged;

p_phase_eq = imhist(Spectrogram_phase_eq,Graylvls);
np_phase_eq = sum(p_phase_eq,1);
p_phase_eq = p_phase_eq./np_phase_eq;

p_phase_unchanged = imhist(Spectrogram_phase_unchanged,Graylvls);
np_phase_unchanged = sum(p_phase_unchanged,1);
p_phase_unchanged = p_phase_unchanged./np_phase_unchanged;

%% finds the zeros in the arrays and eliminates them from the array before entropy calculation as the log function would return an error for a zero
% create a function for this
p_logamp_eq(p_logamp_eq==0) = [];
p_logamp_unchanged(p_logamp_unchanged==0) = [];
p_amp_eq(p_amp_eq==0) = [];
p_amp_unchanged(p_amp_unchanged==0) = [];
p_real_eq(p_real_eq==0) = [];
p_real_unchanged(p_real_unchanged==0) = [];
p_imag_eq(p_imag_eq==0) = [];
p_imag_unchanged(p_imag_unchanged==0) = [];
p_phase_eq(p_phase_eq==0) = [];
p_phase_unchanged(p_phase_unchanged==0) = [];
%% calculting entropy
% create a function to calculate entropy
entropy_logamp_eq = -p_logamp_eq.'*log2(p_logamp_eq);
entropy_logamp_unchanged = -p_logamp_unchanged.'*log2(p_logamp_unchanged);
entropy_amp_eq = -p_amp_eq.'*log2(p_amp_eq);
entropy_amp_unchanged = -p_amp_unchanged.'*log2(p_amp_unchanged);
entropy_real_eq = -p_real_eq.'*log2(p_real_eq);
entropy_real_unchanged = -p_real_unchanged.'*log2(p_real_unchanged);
entropy_imag_eq = -p_imag_eq.'*log2(p_imag_eq);
entropy_imag_unchanged = -p_imag_unchanged.'*log2(p_imag_unchanged);
entropy_phase_eq = -p_phase_eq.'*log2(p_phase_eq);
entropy_phase_unchanged = -p_phase_unchanged.'*log2(p_phase_unchanged);

%% calculating the skewness
skewness_logamp_eq = skewness(p_logamp_eq);
skewness_logamp_unchanged = skewness(p_logamp_unchanged);
skewness_amp_eq = skewness(p_amp_eq);
skewness_amp_unchanged = skewness(p_amp_unchanged);
skewness_real_eq = skewness(p_real_eq);
skewness_real_unchanged = skewness(p_real_unchanged);
skewness_imag_eq = skewness(p_imag_eq);
skewness_imag_unchanged = skewness(p_imag_unchanged);
skewness_phase_eq = skewness(p_phase_eq);
skewness_phase_unchanged = skewness(p_phase_unchanged);
%% calculating the kurtosis
kurtosis_logamp_eq = kurtosis(p_logamp_eq);
kurtosis_logamp_unchanged = kurtosis(p_logamp_unchanged);
kurtosis_amp_eq = kurtosis(p_amp_eq);
kurtosis_amp_unchanged = kurtosis(p_amp_unchanged);
kurtosis_real_eq = kurtosis(p_real_eq);
kurtosis_real_unchanged = kurtosis(p_real_unchanged);
kurtosis_imag_eq = kurtosis(p_imag_eq);
kurtosis_imag_unchanged = kurtosis(p_imag_unchanged);
kurtosis_phase_eq = kurtosis(p_phase_eq);
kurtosis_phase_unchanged = kurtosis(p_phase_unchanged);
%% calcualting centroid
Spectrogram_logamp = mat2gray(20*log10(abs(Spectrogram./max(max(abs(Spectrogram))))),[-50 0]);
Spectrogram_amp = mat2gray(abs(Spectrogram./max(max(abs(Spectrogram)))));
Spectrogram_real = mat2gray(real(Spectrogram./max(max(abs(Spectrogram)))));
Spectrogram_imag = mat2gray(imag(Spectrogram./max(max(abs(Spectrogram)))));
Spectrogram_phase = mat2gray(180/pi*angle(Spectrogram./max(max(abs(Spectrogram)))));
% denominator - mean of segments
Spectrogram_logamp_d = sum(Spectrogram_logamp,1);
Spectrogram_amp_d = sum(Spectrogram_amp,1);
Spectrogram_real_d = sum(Spectrogram_real,1);
Spectrogram_imag_d = sum(Spectrogram_imag,1);
Spectrogram_phase_d = sum(Spectrogram_phase,1);
% numerator - weigthed mean of segments
Spectrogram_logamp_n = fliplr(MD_DopplerAxis)*Spectrogram_logamp;
Spectrogram_amp_n = fliplr(MD_DopplerAxis)*Spectrogram_amp;
Spectrogram_real_n = fliplr(MD_DopplerAxis)*Spectrogram_real;
Spectrogram_imag_n = fliplr(MD_DopplerAxis)*Spectrogram_imag;
Spectrogram_phase_n = fliplr(MD_DopplerAxis)*Spectrogram_phase;
% centroid
%t_axis = 1:Nb_elts;
Spectrogram_logamp_c = Spectrogram_logamp_n./Spectrogram_logamp_d;
Spectrogram_amp_c = Spectrogram_amp_n./Spectrogram_amp_d;
Spectrogram_real_c = Spectrogram_real_n./Spectrogram_real_d;
Spectrogram_imag_c = Spectrogram_imag_n./Spectrogram_imag_d;
Spectrogram_phase_c = Spectrogram_phase_n./Spectrogram_phase_d;
% normalise
Spectrogram_logamp_c = Spectrogram_logamp_c/max(abs(Spectrogram_logamp_c));
Spectrogram_amp_c = Spectrogram_amp_c/max(abs(Spectrogram_amp_c));
Spectrogram_real_c = Spectrogram_real_c/max(abs(Spectrogram_real_c));
Spectrogram_imag_c = Spectrogram_imag_c/max(abs(Spectrogram_imag_c));
Spectrogram_phase_c = Spectrogram_phase_c/max(abs(Spectrogram_phase_c));

%% calculating bandwidth
% numerator - weigthed mean of segments
Doppler_axis2mat = repmat(flipud(MD_DopplerAxis.'), [1 Nb_elts]).^2;
Spectrogram_logamp_n = sum(Doppler_axis2mat.*Spectrogram_logamp,1);
Spectrogram_amp_n = sum(Doppler_axis2mat.*Spectrogram_amp,1);
Spectrogram_real_n = sum(Doppler_axis2mat.*Spectrogram_real,1);
Spectrogram_imag_n = sum(Doppler_axis2mat.*Spectrogram_imag,1);
Spectrogram_phase_n = sum(Doppler_axis2mat.*Spectrogram_phase,1);
% bandwidth
Spectrogram_logamp_Bw = (Spectrogram_logamp_n./Spectrogram_logamp_d).^0.5;
Spectrogram_amp_Bw = (Spectrogram_amp_n./Spectrogram_amp_d).^0.5;
Spectrogram_real_Bw = (Spectrogram_real_n./Spectrogram_real_d).^0.5;
Spectrogram_imag_Bw = (Spectrogram_imag_n./Spectrogram_imag_d).^0.5;
Spectrogram_phase_Bw = (Spectrogram_phase_n./Spectrogram_phase_d).^0.5;

%% calculating SVD
[U_logamp,S_logamp,V_logamp] = svd(Spectrogram_logamp,'econ');
[U_amp,S_amp,V_amp] = svd(Spectrogram_amp,'econ');
[U_real,S_real,V_real] = svd(Spectrogram_real,'econ');
[U_imag_imag,S_imag,V_imag] = svd(Spectrogram_imag,'econ');
[U_phase,S_phase,V_phase] = svd(Spectrogram_phase,'econ');
[U_cplx,S__cplx,V__cplx] = svd(Spectrogram,'econ');
% further reduction is possible to a rank r lower than min m x n -
% https://arxiv.org/abs/1305.5870
% The Optimal Hard Threshold for Singular Values is 4/sqrt(3)
% Matan Gavish, David L. Donoho
% also see https://eleanor.lib.gla.ac.uk/record=b3345402
% Title	Data-driven science and engineering : machine learning, dynamical systems, and control / Steven L. Brunton, J. Nathan Kutz.
% Author	Brunton, Steven L. (Steven Lee), 1984- author.
% Publisher	Cambridge : Cambridge University Press, 2019.
% this will give the interpretation of the data extracted using SVD and how
% to calculate PCA from an SVD decomposition

%% calculating energy curve time series

Spectrogram_logamp = 20*log10(abs(Spectrogram./max(max(abs(Spectrogram)))));
Spectrogram_amp = abs(Spectrogram./max(max(abs(Spectrogram))));
Spectrogram_real = real(Spectrogram./max(max(abs(Spectrogram))));
Spectrogram_imag = imag(Spectrogram./max(max(abs(Spectrogram))));
Spectrogram_phase = 180/pi*angle(Spectrogram./max(max(abs(Spectrogram))));

%energy curve summing the Doppler over each time bin
EBC_logamp = sum(Spectrogram_logamp,1)-mean(sum(Spectrogram_logamp,1));
EBC_amp = sum(Spectrogram_amp,1)-mean(sum(Spectrogram_amp,1));
EBC_real = sum(Spectrogram_real,1)-mean(sum(Spectrogram_real,1));
EBC_imag = sum(Spectrogram_imag,1)-mean(sum(Spectrogram_imag,1));
EBC_phase = sum(Spectrogram_phase,1)-mean(sum(Spectrogram_phase,1));
EBC_cplx = sum(Spectrogram,1)-mean(sum(Spectrogram,1));

%standard deviation of the energy curve
EBCstd_logamp = std(EBC_logamp);
EBCstd_amp = std(EBC_amp);
EBCstd_real = std(EBC_real);
EBCstd_imag = std(EBC_imag);
EBCstd_phase = std(EBC_phase);
EBCstd_cplx = std(EBC_cplx);

%integral of the energy curve
EBCint_logamp = trapz(EBC_logamp);
EBCint_amp = trapz(EBC_amp);
EBCint_real = trapz(EBC_real);
EBCint_imag = trapz(EBC_imag);
EBCint_phase = trapz(EBC_phase);
%EBCint_cplx = trapz(EBC_cplx);

%mean(Mo_mean_ment_real),mean(Mo_mean_ment_imag),mean(Mo_mean_ment_abs),mean(std_cplx),mean(std_abs),...
%    mean(std_real),mean(std_imag),mean(real_RMS),mean(imag_RMS),mean(kurt),...
%    mean(p2preal),mean(p2pimag),

Spec_Feature = [mean(std_abs),mean(std_cplx),mean(std_imag),mean(std_real),mean(real_RMS),mean(imag_RMS),mean(kurt),mean(p2preal),mean(p2pimag)...
                entropy_logamp_eq,entropy_logamp_unchanged,entropy_amp_eq,entropy_amp_unchanged,entropy_real_eq,entropy_real_unchanged,...
                entropy_imag_eq,entropy_imag_unchanged,entropy_phase_eq,entropy_phase_unchanged,skewness_logamp_eq,skewness_logamp_unchanged,...
                skewness_amp_eq,skewness_amp_unchanged,skewness_real_eq,skewness_real_unchanged,skewness_imag_eq,skewness_imag_unchanged,...
                skewness_phase_eq,skewness_phase_unchanged,kurtosis_logamp_eq,kurtosis_logamp_unchanged,kurtosis_amp_eq,...
                kurtosis_amp_unchanged,kurtosis_real_eq,kurtosis_real_unchanged,kurtosis_imag_eq,kurtosis_imag_unchanged,kurtosis_phase_eq,...
                kurtosis_phase_unchanged,mean(Spectrogram_logamp_c),mean(Spectrogram_amp_c),mean(Spectrogram_real_c),mean(Spectrogram_imag_c),...
                mean(Spectrogram_phase_c),std(Spectrogram_logamp_c),std(Spectrogram_amp_c),std(Spectrogram_real_c),std(Spectrogram_imag_c),...
                std(Spectrogram_phase_c),mean(Spectrogram_logamp_Bw),mean(Spectrogram_amp_Bw),mean(Spectrogram_real_Bw),...
                mean(Spectrogram_imag_Bw),mean(Spectrogram_phase_Bw),EBCstd_logamp,EBCstd_amp,EBCstd_real,EBCstd_imag,EBCstd_phase,EBCstd_cplx,...
                EBCint_logamp,EBCint_amp,EBCint_real,EBCint_imag,EBCint_phase,mean(U_logamp(:,1)),mean(V_logamp(:,1)),...
                mean(U_amp(:,1)),mean(V_amp(:,1)),mean(U_real(:,1)),mean(V_real(:,1)),mean(U_imag_imag(:,1)),mean(V_imag(:,1)),...
                mean(U_phase(:,1)),mean(V_phase(:,1)),std(U_logamp(:,1)),std(V_logamp(:,1)),std(U_amp(:,1)),std(V_amp(:,1)),std(U_real(:,1)),...
                std(V_real(:,1)),std(U_imag_imag(:,1)),std(V_imag(:,1)),std(U_phase(:,1)),std(V_phase(:,1)),std(U_cplx(:,1)),std(V__cplx(:,1))];

Spec_Fea_Result_c(r+1,:) = Spec_Feature; 
else
    Spec_Fea_Result_c(r+1,:) = 0;
end
Spectrogram = [];
%% Masked spectrogram Features
if Comb6 == 1
Spectrogram=masked_spectrogram; 
Nb_elts = size(Spectrogram,2);
Mo_mean_ment_real=sum(real(Spectrogram),2)/Nb_elts; %Mean of real elements in time direction
Mo_mean_ment_imag = sum(imag(Spectrogram),2)/Nb_elts;       %Mean of imaginary elements in time direction
Mo_mean_ment_cplx = Mo_mean_ment_real+1i.*Mo_mean_ment_imag;  %Cplx Mean sum of the previous 2 real+1i*imag 
Mo_mean_ment_abs = sum(abs(Spectrogram),2)/Nb_elts;         %Mean of amplitude in time direction
%% calculating the standard deviation of the complex mean
cplx_mean = repmat(Mo_mean_ment_cplx,[1 Nb_elts]); % creating a matrix of the same size as the spectrogram with replication of the mean_cplx to calculate variance
var_cplx = sum(abs(Spectrogram-cplx_mean),2).^2/Nb_elts; %complex variance in time direction
std_cplx = sqrt(var_cplx);
%% calculating the standard devaition of the amplitude
abs_mean = repmat(Mo_mean_ment_abs,[1 Nb_elts]); % creating a matrix of the same size as the spectrogram with replication of the mean_abs to calculate variance
var_abs = sum(abs(Spectrogram-abs_mean),2).^2/Nb_elts; %complex variance in time direction
std_abs = sqrt(var_abs);
%% calculating the standard deviation of the real part
real_mean = repmat(Mo_mean_ment_real,[1 Nb_elts]); % creating a matrix of the same size as the spectrogram with replication of the mean_real to calculate variance
var_real = sum(abs(real(Spectrogram)-real_mean),2).^2/Nb_elts; % real variance in time direction
std_real = sqrt(var_real); 
%% calculating the standard deviation of the imaginary part
imag_mean = repmat(Mo_mean_ment_imag,[1 Nb_elts]); % creating a matrix of the same size as the spectrogram with replication of the mean_imag to calculate variance
var_imag = sum(abs(imag(Spectrogram)-imag_mean),2).^2/Nb_elts; % imag variance in time direction
std_imag = sqrt(var_imag);

%% calculating the pseudo standard deviation 
%pvar_cplx = sum((Spectrogram-cplx_mean).^2,2)./Nb_elts;
%pstd_cplx = sqrt(pvar_cplx);

%% root mean squared value and pseudo RMS
% create a function for this
MS = sum(abs(Spectrogram).^2,2)/Nb_elts;
PMS = sum(Spectrogram.^2,2)/Nb_elts;
%RMS = sqrt(MS);
%PRMS = sqrt(PMS);
real_MS = sum(abs(real(Spectrogram)).^2,2)/Nb_elts;
imag_MS = sum(abs(imag(Spectrogram)).^2,2)/Nb_elts;
real_RMS = sqrt(real_MS);
imag_RMS = sqrt(imag_MS);

%% Kurtosis
kurt = sum(abs(Spectrogram).^4,2)/Nb_elts-abs(PMS).^2-2*(MS).^2;

%% peak to peak of real part and imaginary part
p2preal = max(real(Spectrogram),[],2)-min(real(Spectrogram),[],2);
p2pimag = max(imag(Spectrogram),[],2)-min(imag(Spectrogram),[],2);

%% image processing type features
Graylvls = 64; %This variable could be used to set the number of gray
% levels per mat2gray transformations
% this part requires rewriting a fundction to calculate the entropy,
% skewness, kurtosis, bandwidth
% thresholding at this stage would greatly help in filtering out the noise
% in the background
% example below of masking down manually 
% SpectroLOG = 20*log10(abs(Spectrogram)/max(max(abs(Spectrogram))));
% figure(100)
% imagesc(SpectroLOG)
% colorbar

%SpectroLOG(SpectroLOG < -60)=-60;
%SpectroLOG_eq = histeq(mat2gray(SpectroLOG)); %equalize grayscales
%SpectroLOG_unchanged = mat2gray(SpectroLOG); % converting the matrix to a grayscale image using the minimum and mximum values


%Spectrogram_logamp_eq = histeq(mat2gray(20*log10(abs(Spectrogram))),Graylvls); %equalize grayscales
%Spectrogram_logamp_unchanged = mat2gray(20*log10(abs(Spectrogram))); % converting the matrix to a grayscale image using the minimum and mximum values


Spectrogram_amp_eq = histeq(mat2gray(abs(Spectrogram)),Graylvls);
Spectrogram_real_eq = histeq(mat2gray(real(Spectrogram)),Graylvls);
Spectrogram_imag_eq = histeq(mat2gray(imag(Spectrogram)),Graylvls);
Spectrogram_phase_eq = histeq(mat2gray(180/pi*angle(Spectrogram)),Graylvls);

Spectrogram_amp_unchanged = mat2gray(abs(Spectrogram));
Spectrogram_real_unchanged = mat2gray(real(Spectrogram));
Spectrogram_imag_unchanged = mat2gray(imag(Spectrogram));
Spectrogram_phase_unchanged = mat2gray(180/pi*angle(Spectrogram));


%% calculating the probabilities so that they equate 1 in the end
% create a function for this
%p_logamp_eq = imhist(Spectrogram_logamp_eq,Graylvls);
%np_logamp_eq = sum(p_logamp_eq,1);
%p_logamp_eq = p_logamp_eq./np_logamp_eq;

%p_logamp_unchanged = imhist(Spectrogram_logamp_unchanged,Graylvls);
%np_logamp_unchanged = sum(p_logamp_unchanged,1);
%p_logamp_unchanged = p_logamp_unchanged./np_logamp_unchanged;

p_amp_eq = imhist(Spectrogram_amp_eq,Graylvls);
np_amp_eq = sum(p_amp_eq,1);
p_amp_eq = p_amp_eq./np_amp_eq;

p_amp_unchanged = imhist(Spectrogram_amp_unchanged,Graylvls);
np_amp_unchanged = sum(p_amp_unchanged,1);
p_amp_unchanged = p_amp_unchanged./np_amp_unchanged;

p_real_eq = imhist(Spectrogram_real_eq,Graylvls);
np_real_eq = sum(p_real_eq,1);
p_real_eq = p_real_eq./np_real_eq;

p_real_unchanged = imhist(Spectrogram_real_unchanged,Graylvls);
np_real_unchanged = sum(p_real_unchanged,1);
p_real_unchanged = p_real_unchanged./np_real_unchanged;

p_imag_eq = imhist(Spectrogram_imag_eq,Graylvls);
np_imag_eq = sum(p_imag_eq,1);
p_imag_eq = p_imag_eq./np_imag_eq;

p_imag_unchanged = imhist(Spectrogram_imag_unchanged,Graylvls);
np_imag_unchanged = sum(p_imag_unchanged,1);
p_imag_unchanged = p_imag_unchanged./np_imag_unchanged;

p_phase_eq = imhist(Spectrogram_phase_eq,Graylvls);
np_phase_eq = sum(p_phase_eq,1);
p_phase_eq = p_phase_eq./np_phase_eq;

p_phase_unchanged = imhist(Spectrogram_phase_unchanged,Graylvls);
np_phase_unchanged = sum(p_phase_unchanged,1);
p_phase_unchanged = p_phase_unchanged./np_phase_unchanged;

%% finds the zeros in the arrays and eliminates them from the array before entropy calculation as the log function would return an error for a zero
% create a function for this
%p_logamp_eq(p_logamp_eq==0) = [];
%p_logamp_unchanged(p_logamp_unchanged==0) = [];
p_amp_eq(p_amp_eq==0) = [];
p_amp_unchanged(p_amp_unchanged==0) = [];
p_real_eq(p_real_eq==0) = [];
p_real_unchanged(p_real_unchanged==0) = [];
p_imag_eq(p_imag_eq==0) = [];
p_imag_unchanged(p_imag_unchanged==0) = [];
p_phase_eq(p_phase_eq==0) = [];
p_phase_unchanged(p_phase_unchanged==0) = [];
%% calculting entropy
% create a function to calculate entropy
%entropy_logamp_eq = -p_logamp_eq.'*log2(p_logamp_eq);
%entropy_logamp_unchanged = -p_logamp_unchanged.'*log2(p_logamp_unchanged);
entropy_amp_eq = -p_amp_eq.'*log2(p_amp_eq);
entropy_amp_unchanged = -p_amp_unchanged.'*log2(p_amp_unchanged);
entropy_real_eq = -p_real_eq.'*log2(p_real_eq);
entropy_real_unchanged = -p_real_unchanged.'*log2(p_real_unchanged);
entropy_imag_eq = -p_imag_eq.'*log2(p_imag_eq);
entropy_imag_unchanged = -p_imag_unchanged.'*log2(p_imag_unchanged);
entropy_phase_eq = -p_phase_eq.'*log2(p_phase_eq);
entropy_phase_unchanged = -p_phase_unchanged.'*log2(p_phase_unchanged);

%% calculating the skewness
%skewness_logamp_eq = skewness(p_logamp_eq);
%skewness_logamp_unchanged = skewness(p_logamp_unchanged);
skewness_amp_eq = skewness(p_amp_eq);
skewness_amp_unchanged = skewness(p_amp_unchanged);
skewness_real_eq = skewness(p_real_eq);
skewness_real_unchanged = skewness(p_real_unchanged);
skewness_imag_eq = skewness(p_imag_eq);
skewness_imag_unchanged = skewness(p_imag_unchanged);
skewness_phase_eq = skewness(p_phase_eq);
skewness_phase_unchanged = skewness(p_phase_unchanged);
%% calculating the kurtosis
%kurtosis_logamp_eq = kurtosis(p_logamp_eq);
%kurtosis_logamp_unchanged = kurtosis(p_logamp_unchanged);
kurtosis_amp_eq = kurtosis(p_amp_eq);
kurtosis_amp_unchanged = kurtosis(p_amp_unchanged);
kurtosis_real_eq = kurtosis(p_real_eq);
kurtosis_real_unchanged = kurtosis(p_real_unchanged);
kurtosis_imag_eq = kurtosis(p_imag_eq);
kurtosis_imag_unchanged = kurtosis(p_imag_unchanged);
kurtosis_phase_eq = kurtosis(p_phase_eq);
kurtosis_phase_unchanged = kurtosis(p_phase_unchanged);
%% calcualting centroid
Spectrogram_logamp = mat2gray(20*log10(abs(Spectrogram./max(max(abs(Spectrogram))))),[-50 0]);
Spectrogram_amp = mat2gray(abs(Spectrogram./max(max(abs(Spectrogram)))));
Spectrogram_real = mat2gray(real(Spectrogram./max(max(abs(Spectrogram)))));
Spectrogram_imag = mat2gray(imag(Spectrogram./max(max(abs(Spectrogram)))));
Spectrogram_phase = mat2gray(180/pi*angle(Spectrogram./max(max(abs(Spectrogram)))));
% denominator - mean of segments
%Spectrogram_logamp_d = sum(Spectrogram_logamp,1);
%Spectrogram_amp_d = sum(Spectrogram_amp,1);
Spectrogram_real_d = sum(Spectrogram_real,1);
Spectrogram_imag_d = sum(Spectrogram_imag,1);
Spectrogram_phase_d = sum(Spectrogram_phase,1);
% numerator - weigthed mean of segments
%Spectrogram_logamp_n = fliplr(MD_DopplerAxis)*Spectrogram_logamp;
%Spectrogram_amp_n = fliplr(MD_DopplerAxis)*Spectrogram_amp;
Spectrogram_real_n = fliplr(MD_DopplerAxis)*Spectrogram_real;
Spectrogram_imag_n = fliplr(MD_DopplerAxis)*Spectrogram_imag;
Spectrogram_phase_n = fliplr(MD_DopplerAxis)*Spectrogram_phase;
% centroid
%t_axis = 1:Nb_elts;
%Spectrogram_logamp_c = Spectrogram_logamp_n./Spectrogram_logamp_d;
%Spectrogram_amp_c = Spectrogram_amp_n./Spectrogram_amp_d;
Spectrogram_real_c = Spectrogram_real_n./Spectrogram_real_d;
Spectrogram_imag_c = Spectrogram_imag_n./Spectrogram_imag_d;
Spectrogram_phase_c = Spectrogram_phase_n./Spectrogram_phase_d;
% normalise
%Spectrogram_logamp_c = Spectrogram_logamp_c/max(abs(Spectrogram_logamp_c));
%Spectrogram_amp_c = Spectrogram_amp_c/max(abs(Spectrogram_amp_c));
Spectrogram_real_c = Spectrogram_real_c/max(abs(Spectrogram_real_c));
Spectrogram_imag_c = Spectrogram_imag_c/max(abs(Spectrogram_imag_c));
Spectrogram_phase_c = Spectrogram_phase_c/max(abs(Spectrogram_phase_c));

%% calculating bandwidth
% numerator - weigthed mean of segments
Doppler_axis2mat = repmat(flipud(MD_DopplerAxis.'), [1 Nb_elts]).^2;
%Spectrogram_logamp_n = sum(Doppler_axis2mat.*Spectrogram_logamp,1);
%Spectrogram_amp_n = sum(Doppler_axis2mat.*Spectrogram_amp,1);
Spectrogram_real_n = sum(Doppler_axis2mat.*Spectrogram_real,1);
Spectrogram_imag_n = sum(Doppler_axis2mat.*Spectrogram_imag,1);
Spectrogram_phase_n = sum(Doppler_axis2mat.*Spectrogram_phase,1);
% bandwidth
%Spectrogram_logamp_Bw = (Spectrogram_logamp_n./Spectrogram_logamp_d).^0.5;
%Spectrogram_amp_Bw = (Spectrogram_amp_n./Spectrogram_amp_d).^0.5;
Spectrogram_real_Bw = (Spectrogram_real_n./Spectrogram_real_d).^0.5;
Spectrogram_imag_Bw = (Spectrogram_imag_n./Spectrogram_imag_d).^0.5;
Spectrogram_phase_Bw = (Spectrogram_phase_n./Spectrogram_phase_d).^0.5;

%% calculating SVD
[U_logamp,S_logamp,V_logamp] = svd(Spectrogram_logamp,'econ');
[U_amp,S_amp,V_amp] = svd(Spectrogram_amp,'econ');
[U_real,S_real,V_real] = svd(Spectrogram_real,'econ');
[U_imag_imag,S_imag,V_imag] = svd(Spectrogram_imag,'econ');
[U_phase,S_phase,V_phase] = svd(Spectrogram_phase,'econ');
[U_cplx,S__cplx,V__cplx] = svd(Spectrogram,'econ');
% further reduction is possible to a rank r lower than min m x n -
% https://arxiv.org/abs/1305.5870
% The Optimal Hard Threshold for Singular Values is 4/sqrt(3)
% Matan Gavish, David L. Donoho
% also see https://eleanor.lib.gla.ac.uk/record=b3345402
% Title	Data-driven science and engineering : machine learning, dynamical systems, and control / Steven L. Brunton, J. Nathan Kutz.
% Author	Brunton, Steven L. (Steven Lee), 1984- author.
% Publisher	Cambridge : Cambridge University Press, 2019.
% this will give the interpretation of the data extracted using SVD and how
% to calculate PCA from an SVD decomposition

%% calculating energy curve time series

%Spectrogram_logamp = 20*log10(abs(Spectrogram./max(max(abs(Spectrogram)))));
Spectrogram_amp = abs(Spectrogram./max(max(abs(Spectrogram))));
Spectrogram_real = real(Spectrogram./max(max(abs(Spectrogram))));
Spectrogram_imag = imag(Spectrogram./max(max(abs(Spectrogram))));
Spectrogram_phase = 180/pi*angle(Spectrogram./max(max(abs(Spectrogram))));

%energy curve summing the Doppler over each time bin
%EBC_logamp = sum(Spectrogram_logamp,1)-mean(sum(Spectrogram_logamp,1));
EBC_amp = sum(Spectrogram_amp,1)-mean(sum(Spectrogram_amp,1));
EBC_real = sum(Spectrogram_real,1)-mean(sum(Spectrogram_real,1));
EBC_imag = sum(Spectrogram_imag,1)-mean(sum(Spectrogram_imag,1));
EBC_phase = sum(Spectrogram_phase,1)-mean(sum(Spectrogram_phase,1));
EBC_cplx = sum(Spectrogram,1)-mean(sum(Spectrogram,1));

%standard deviation of the energy curve
%EBCstd_logamp = std(EBC_logamp);
EBCstd_amp = std(EBC_amp);
EBCstd_real = std(EBC_real);
EBCstd_imag = std(EBC_imag);
EBCstd_phase = std(EBC_phase);
EBCstd_cplx = std(EBC_cplx);

%integral of the energy curve
%EBCint_logamp = trapz(EBC_logamp);
EBCint_amp = trapz(EBC_amp);
EBCint_real = trapz(EBC_real);
EBCint_imag = trapz(EBC_imag);
EBCint_phase = trapz(EBC_phase);
%EBCint_cplx = trapz(EBC_cplx);

Masked_Spec_Feature = [mean(std_cplx),mean(std_abs),mean(std_real),mean(std_imag),mean(real_RMS),mean(imag_RMS),mean(kurt),...
    mean(p2preal),mean(p2pimag),entropy_amp_eq,entropy_amp_unchanged,entropy_real_eq,entropy_real_unchanged,entropy_imag_eq,...
    entropy_imag_unchanged,entropy_phase_eq,entropy_phase_unchanged,skewness_amp_eq,skewness_amp_unchanged,skewness_real_eq,...
    skewness_real_unchanged,skewness_imag_eq,skewness_imag_unchanged,skewness_phase_eq,skewness_phase_unchanged,...
    kurtosis_amp_eq,kurtosis_amp_unchanged,kurtosis_real_eq,kurtosis_real_unchanged,kurtosis_imag_eq,kurtosis_imag_unchanged,...
    kurtosis_phase_eq,kurtosis_phase_unchanged,mean(Spectrogram_real_c),...
    mean(Spectrogram_imag_c),mean(Spectrogram_phase_c),mean(Spectrogram_real_Bw),...
    mean(Spectrogram_imag_Bw),mean(Spectrogram_phase_Bw),EBCstd_amp,EBCstd_real,EBCstd_imag,EBCstd_phase,EBCstd_cplx,...
    EBCint_amp,EBCint_real,EBCint_imag,EBCint_phase,mean(U_logamp(:,1)),mean(V_logamp(:,1)),...
    mean(U_amp(:,1)),mean(V_amp(:,1)),mean(U_real(:,1)),mean(V_real(:,1)),mean(U_imag_imag(:,1)),mean(V_imag(:,1)),mean(U_phase(:,1)),...
    mean(V_phase(:,1)),std(U_logamp(:,1)),std(V_logamp(:,1)),std(U_amp(:,1)),std(V_amp(:,1)),std(U_real(:,1)),std(V_real(:,1)),...
    std(U_imag_imag(:,1)),std(V_imag(:,1)),std(U_phase(:,1)),std(V_phase(:,1)),std(U_cplx(:,1)),std(V__cplx(:,1))];

Masked_Spec_Fea_Result_c(r+1,:) = Masked_Spec_Feature; 
else
    Masked_Spec_Fea_Result_c(r+1,:) = 0;
end
end
div = [mask_results_c masked_phase_results_c masked_unwrapped_results_c masked_spectrogram_image_results_c Spec_Fea_Result_c Masked_Spec_Fea_Result_c];
div = gather(div);
end