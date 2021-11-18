function [start_da, final_da, FWHM] = Voigt_fit_edMM(spec,histcenters,peak,percent)
%% Pseudo Voigt Fitting

%Modifications by MM: input data was "read_in_g" matrix, is now spectrum vector "spec"
%Todo MM: swap from fixed bin size to variable size maybe by adding histbins as input param

spec = double(spec); % data type single doesn't work
histcenters = double(histcenters);


%Defines location of left and right points bordering peak
peak_left = peak - 0.2;
peak_right= peak + 0.2;
%Finds indexes corresponding to peak,peak_left,peak_right in exported csv 
[~, peak_index] = min(abs(histcenters-peak)); % index(peak);
[~, peak_left_index] = min(abs(histcenters-peak_left)); % index(peak_left);
[~, peak_right_index] = min(abs(histcenters-peak_right)); % index(peak_right);

if peak_left_index < 1 || peak_right_index==numel(histcenters) || peak_left_index==peak_right_index
    warning("peak out of histogram range. Cannot fit peak. Returning zero.")
    start_da = 0; final_da = 0; FWHM = 0;
    return;
end


%Creates array of spectrum between peak_left and peak_right of only daltons
%and uncorrected counts
curr = [histcenters(peak_left_index:peak_right_index)',spec(peak_left_index:peak_right_index)'];

%Finds fit curve max, index, and Da value between left and right bounds
[max_value,max_index] = max(curr(:,2));
max_Da = curr(max_index,1);

%Fits peak with gaussian 
a = linefit(curr);
%find peak


a.CurveModelIndex = 11;
a.BkgdModelIndex = 2;
a.PeaksFound = [max_value; max_Da];
a.FitOptions.FunctionTolerance = 1e-4;
a.FitOptions.OptimalityTolerance = 1e-4;
a.FitOptions.StepTolerance = 1e-4;
a.FitOptions.MaxIterations = 1000;
a = applypeaks(a);
a = startfit(a);
a = acceptfit(a);


%Creates array of values from gaussian fitted curve 
X = curr(:,1);
Y = evalmodel(a,X);
Voigt = [X,Y];

%% Gaussian FWHM Analysis

%Defines percentage of max to use for decomposition width
perc =percent/100;

%Finds fit curve max, index, and Da value between left and right bounds
[max_value_fit,max_index_fit] = max(Voigt(:,2));
max_Da = Voigt(max_index_fit,1);

%Finds min value and index between (peak value -0.1) and max
[min_value_left,min_index_left] = min(Voigt(1:max_index_fit,2));
% Corrects min_value to 0 if negative, no negative counts
if (min_value_left <0)
    min_value_left = 0;
end

%Finds half max value for left side of peak
p5_max_left = perc*(max_value_fit - min_value_left)+ min_value_left;

%Finds min value and index between max and (peak value + 0.1)
[min_value_right,min_index_right] = min(Voigt(max_index_fit:length(Voigt),2));
% Corrects min_value to 0 if negative, no negative counts
if (min_value_right <0)
    min_value_right = 0;
end

%Finds half max value for left side of peak
p5_max_right = perc*(max_value_fit - min_value_right)+ min_value_right;

%Finds indices of left and right bounds when p5_max achieved
half_left_index = find(Voigt(1:max_index_fit,2) <= p5_max_left, 1,'last');
half_right_index = find(Voigt(max_index_fit:length(Voigt),2) <= p5_max_right, 1,'first')+max_index_fit-1;


%Finds Da values for start and final
start_da = Voigt(half_left_index,1);
final_da = Voigt(half_right_index,1);


%Finds FWHM
FWHM = Voigt(half_right_index,1)- Voigt(half_left_index,1);

% plot(a,'fit');
end